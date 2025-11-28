#!/usr/bin/env pwsh
<#
    .SYNOPSIS
    Installs the Winget Package Manager Update Suite to the system.

    .DESCRIPTION
    This script installs the Update Winget Packages automation suite to a system location
    and creates a Windows Task Scheduler job to run updates on a configurable schedule.
    
    The installation includes:
    - Update-WingetPackages.ps1 (main update script)
    - Update-WingetPackages-CreateStartMenuShortcut.ps1 (shortcut creation)
    - Configuration files and documentation

    .PARAMETER InstallPath
    The installation directory. Defaults to 'C:\Program Files\WingetUpdater'

    .PARAMETER ScheduleFrequency
    How often to run updates. Options: 'Daily', 'Weekly', 'Monthly'
    Defaults to 'Weekly'

    .PARAMETER ScheduleTime
    The time to run scheduled updates in HH:mm format. Defaults to '02:00' (2 AM)

    .PARAMETER CreateStartMenuShortcut
    If $true, creates a Start Menu shortcut for manual execution. Defaults to $true

    .PARAMETER Force
    If $true, overwrites existing installation without prompting. Defaults to $false

    .EXAMPLE
    .\install-winget-updater.ps1

    .\install-winget-updater.ps1 -InstallPath 'C:\Tools\WingetUpdater' -ScheduleFrequency Weekly

    .\install-winget-updater.ps1 -ScheduleFrequency Daily -ScheduleTime 03:00 -Force

    .NOTES
    - Requires administrator privileges
    - Windows 10/11 or Windows Server 2019+
    - Winget must be installed and available
    - PowerShell 5.1+ required

    .LINK
    https://github.com/poslogica/generalscripts
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateNotNullOrEmpty()]
    [string]$InstallPath = 'C:\Program Files\WingetUpdater',

    [ValidateSet('Daily', 'Weekly', 'Monthly')]
    [string]$ScheduleFrequency = 'Weekly',

    [ValidatePattern('^\d{2}:\d{2}$')]
    [string]$ScheduleTime = '02:00',

    [bool]$CreateStartMenuShortcut = $true,

    [switch]$Force
)

# ===== Helper Functions =====

function Test-AdminPrivileges {
    <#
        .SYNOPSIS
        Checks if the script is running with administrator privileges.
    #>
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WingetAvailable {
    <#
        .SYNOPSIS
        Checks if winget is installed and available.
    #>
    try {
        $null = winget --version
        return $true
    }
    catch {
        return $false
    }
}

function New-Directory {
    <#
        .SYNOPSIS
        Creates a directory if it doesn't exist.
    #>
    param([string]$Path)
    
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "✓ Created directory: $Path" -ForegroundColor Green
    }
}

function Copy-ScriptFiles {
    <#
        .SYNOPSIS
        Copies script files to the installation directory.
    #>
    param([string]$SourceDir, [string]$DestDir)
    
    $filesToCopy = @(
        'update-winget-packages.ps1',
        'update-winget-packages-create-start-menu-shortcut.ps1',
        'winget-config.json'
    )
    
    foreach ($file in $filesToCopy) {
        $sourcePath = Join-Path $SourceDir $file
        $destPath = Join-Path $DestDir $file
        
        if (Test-Path -Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "✓ Copied: $file" -ForegroundColor Green
        }
        else {
            Write-Warning "File not found: $sourcePath"
        }
    }
}

function New-ScheduledTask {
    <#
        .SYNOPSIS
        Creates a Windows Task Scheduler job for automated updates.
    #>
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$Frequency,
        [string]$Time
    )
    
    $taskExists = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($taskExists -and -not $Force) {
        $response = Read-Host "Task '$TaskName' already exists. Overwrite? (Y/N)"
        if ($response -ne 'Y') {
            Write-Host "Skipped creating task" -ForegroundColor Yellow
            return
        }
    }
    
    if ($taskExists) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
    
    $action = New-ScheduledTaskAction `
        -Execute 'pwsh.exe' `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    
    $trigger = switch ($Frequency) {
        'Daily' { New-ScheduledTaskTrigger -Daily -At $Time }
        'Weekly' { New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At $Time }
        'Monthly' { New-ScheduledTaskTrigger -Monthly -Day 1 -At $Time }
    }
    
    $principal = New-ScheduledTaskPrincipal `
        -UserID "NT AUTHORITY\SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest
    
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable
    
    $task = New-ScheduledTask `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "Automated Windows Package Manager (Winget) Updates"
    
    Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null
    Write-Host "✓ Created scheduled task: $TaskName ($Frequency at $Time)" -ForegroundColor Green
}

function New-UninstallScript {
    <#
        .SYNOPSIS
        Creates an uninstall script for easy removal.
    #>
    param([string]$InstallDir, [string]$TaskName)
    
    $uninstallPath = Join-Path $InstallDir 'uninstall.ps1'
    $content = @"
<#
    .SYNOPSIS
    Uninstalls the Winget Updater suite.
#>

[CmdletBinding(SupportsShouldProcess)]
param()

if (-not (Test-Path 'C:\Program Files\WingetUpdater')) {
    Write-Error 'Winget Updater is not installed'
    exit 1
}

Write-Host 'Removing scheduled task...'
`$task = Get-ScheduledTask -TaskName '$TaskName' -ErrorAction SilentlyContinue
if (`$task) {
    Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false
    Write-Host '✓ Removed scheduled task'
}

Write-Host 'Removing Start Menu shortcut...'
`$shortcutPath = "`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Update Winget Packages.lnk"
if (Test-Path -Path `$shortcutPath) {
    Remove-Item -Path `$shortcutPath -Force
    Write-Host '✓ Removed shortcut'
}

Write-Host 'Removing installation directory...'
Remove-Item -Path 'C:\Program Files\WingetUpdater' -Recurse -Force
Write-Host '✓ Winget Updater uninstalled successfully'
"@
    
    Set-Content -Path $uninstallPath -Value $content -Force
    Write-Host "✓ Created uninstall script: $uninstallPath" -ForegroundColor Green
}

function New-ReadmeFile {
    <#
        .SYNOPSIS
        Creates a README file in the installation directory.
    #>
    param([string]$InstallDir, [string]$ScheduleInfo)
    
    $readmePath = Join-Path $InstallDir 'README.md'
    $content = @"
# Winget Package Manager Updater

Automated Windows Package Manager (Winget) update suite.

## Installation Location
$(if (Test-Path $InstallDir) { $InstallDir } else { 'Not installed' })

## Scheduled Updates
$ScheduleInfo

## Manual Execution

Run updates immediately:
\`\`\`powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$InstallDir\update-winget-packages.ps1"
\`\`\`

Or use the Start Menu shortcut: **Update Winget Packages**

## Create Start Menu Shortcut

If you didn't create one during installation:
\`\`\`powershell
& "$InstallDir\update-winget-packages-create-start-menu-shortcut.ps1"
\`\`\`

## Configuration

Edit \`winget-config.json\` to customize:
- Excluded packages
- Update behavior
- Logging settings

## Uninstall

\`\`\`powershell
& "$InstallDir\uninstall.ps1"
\`\`\`

## Logs

Check \`C:\Program Files\WingetUpdater\logs\` for execution logs.

## Support

For issues, visit: https://github.com/poslogica/generalscripts
"@
    
    Set-Content -Path $readmePath -Value $content -Force
    Write-Host "✓ Created README file" -ForegroundColor Green
}

# ===== Main Installation Logic =====

function Install-WingetUpdater {
    Write-Host "`n=== Winget Updater Installation ===" -ForegroundColor Cyan
    
    # Check admin privileges
    if (-not (Test-AdminPrivileges)) {
        Write-Error "This script requires administrator privileges. Please run as Administrator."
        exit 1
    }
    
    # Check winget availability
    if (-not (Test-WingetAvailable)) {
        Write-Error "Winget is not installed or not available. Please install Windows Package Manager first."
        Write-Host "Visit: https://learn.microsoft.com/en-us/windows/package-manager/winget/"
        exit 1
    }
    
    Write-Host "✓ Prerequisites verified" -ForegroundColor Green
    
    # Create installation directories
    Write-Host "`nCreating installation directories..." -ForegroundColor Cyan
    New-Directory -Path $InstallPath
    New-Directory -Path (Join-Path $InstallPath 'logs')
    
    # Determine source directory (script location or current directory)
    $sourceDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $sourceDir = Split-Path -Parent $sourceDir  # Go up one level to get patching dir
    
    # Copy script files
    Write-Host "`nCopying script files..." -ForegroundColor Cyan
    Copy-ScriptFiles -SourceDir $sourceDir -DestDir $InstallPath
    
    # Create scheduled task
    Write-Host "`nConfiguring scheduled task..." -ForegroundColor Cyan
    $mainScriptPath = Join-Path $InstallPath 'update-winget-packages.ps1'
    New-ScheduledTask -TaskName 'Update-Winget-Packages' `
        -ScriptPath $mainScriptPath `
        -Frequency $ScheduleFrequency `
        -Time $ScheduleTime
    
    # Create Start Menu shortcut
    if ($CreateStartMenuShortcut) {
        Write-Host "`nCreating Start Menu shortcut..." -ForegroundColor Cyan
        try {
            & (Join-Path $InstallPath 'update-winget-packages-create-start-menu-shortcut.ps1')
        }
        catch {
            Write-Warning "Could not create Start Menu shortcut: $_"
        }
    }
    
    # Create uninstall script
    Write-Host "`nCreating uninstall script..." -ForegroundColor Cyan
    New-UninstallScript -InstallDir $InstallPath -TaskName 'Update-Winget-Packages'
    
    # Create README
    Write-Host "`nGenerating documentation..." -ForegroundColor Cyan
    $scheduleInfo = "$ScheduleFrequency at $ScheduleTime"
    New-ReadmeFile -InstallDir $InstallPath -ScheduleInfo $scheduleInfo
    
    # Success message
    Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
    Write-Host "`nLocation: $InstallPath" -ForegroundColor Green
    Write-Host "Schedule: $ScheduleFrequency at $ScheduleTime" -ForegroundColor Green
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "1. Review configuration: $InstallPath\winget-config.json"
    Write-Host "2. Check logs: $InstallPath\logs"
    Write-Host "3. Test manually: powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$mainScriptPath`""
    Write-Host "4. Uninstall: & `"$InstallPath\uninstall.ps1`""
    Write-Host "`n"
}

# Run installation
try {
    Install-WingetUpdater
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}

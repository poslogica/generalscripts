#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
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
    How often to run updates: 'Daily', 'Weekly', or 'Monthly'. Defaults to 'Weekly'

    .PARAMETER ScheduleTime
    The time to run scheduled updates in HH:mm format (24-hour). Defaults to '02:00'

    .PARAMETER CreateStartMenuShortcut
    If $true, creates a Start Menu shortcut for manual execution. Defaults to $true

    .PARAMETER Force
    If $true, overwrites existing installation without prompting. Defaults to $false

    .EXAMPLE
    .\install-winget-updater.ps1

    .\install-winget-updater.ps1 -InstallPath 'C:\Tools\WingetUpdater' -ScheduleFrequency Weekly

    .\install-winget-updater.ps1 -ScheduleFrequency Daily -ScheduleTime '03:00' -Force

    .NOTES
    - Requires administrator privileges (enforced with #Requires)
    - Requires PowerShell 7+ (pwsh.exe) - NOT Windows PowerShell 5.1
    - Windows 10/11 or Windows Server 2019+
    - Winget must be installed and available
    - Scheduled task runs under SYSTEM account with highest privileges
    - Logs are stored in the 'logs' subdirectory of the installation path

    .LINK
    https://github.com/poslogica/generalscripts
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$InstallPath = 'C:\Program Files\WingetUpdater',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Daily', 'Weekly', 'Monthly')]
    [string]$ScheduleFrequency = 'Weekly',

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{2}:\d{2}$')]
    [string]$ScheduleTime = '02:00',

    [Parameter(Mandatory = $false)]
    [bool]$CreateStartMenuShortcut = $true,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Test winget availability
try {
    $null = winget --version
}
catch {
    Write-Error 'Winget is not installed or not available.'
    Write-Output 'Visit: https://learn.microsoft.com/en-us/windows/package-manager/winget/'
    exit 1
}

Write-Host "`n=== Winget Updater Installation ===" -ForegroundColor Cyan
Write-Host '✓ Prerequisites verified' -ForegroundColor Green

# Create directories
Write-Host "`nCreating installation directories..." -ForegroundColor Cyan
if ($PSCmdlet.ShouldProcess($InstallPath, 'Create directory')) {
    $null = New-Item -ItemType Directory -Path $InstallPath -Force
    $null = New-Item -ItemType Directory -Path (Join-Path $InstallPath 'logs') -Force
    Write-Host "✓ Created: $InstallPath" -ForegroundColor Green
}

# Find source directory (same directory as installer script)
$sourceDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

# Copy files
Write-Host "`nCopying script files..." -ForegroundColor Cyan
$filesToCopy = @(
    'update-winget-packages.ps1',
    'update-third-party-with-winget.ps1',
    'update-winget-packages-create-start-menu-shortcut.ps1',
    'update-winget-updater.ps1',
    'winget-config.json',
    'uninstall-winget-updater.ps1'
)

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $sourceDir $file
    if (Test-Path -Path $sourcePath) {
        if ($PSCmdlet.ShouldProcess($sourcePath, 'Copy file')) {
            Copy-Item -Path $sourcePath -Destination $InstallPath -Force
            Write-Host "✓ Copied: $file" -ForegroundColor Green
        }
    }
    else {
        Write-Warning "File not found: $sourcePath"
    }
}

# Create VERSION file from VERSION file in source or git tag
Write-Host "`nWriting version information..." -ForegroundColor Cyan
$versionFile = Join-Path $InstallPath 'VERSION'
$version = $null

# Try to read VERSION file from source directory
$sourceVersionFile = Join-Path $sourceDir 'VERSION'
if (Test-Path $sourceVersionFile) {
    $version = (Get-Content $sourceVersionFile -Raw).Trim()
}

# Fallback: try parent directory (for installer package structure)
if (-not $version) {
    $parentVersionFile = Join-Path (Split-Path $sourceDir -Parent) 'VERSION'
    if (Test-Path $parentVersionFile) {
        $version = (Get-Content $parentVersionFile -Raw).Trim()
    }
}

# Fallback: use date-based version
if (-not $version) {
    $version = "0.0.0-$(Get-Date -Format 'yyyyMMdd')"
    Write-Host "  Using fallback version: $version" -ForegroundColor Yellow
}

if ($PSCmdlet.ShouldProcess($versionFile, 'Write version')) {
    $version | Out-File -FilePath $versionFile -Encoding UTF8 -NoNewline
    Write-Host "✓ Version: $version" -ForegroundColor Green
}

# Create scheduled task
Write-Host "`nConfiguring scheduled task..." -ForegroundColor Cyan
if ($PSCmdlet.ShouldProcess('Update-Winget-Packages', 'Create task')) {
    $mainScriptPath = Join-Path $InstallPath 'update-winget-packages.ps1'
    $taskPath = '\Microsoft\Windows\Winget\'
    $taskExists = Get-ScheduledTask -TaskName 'Update-Winget-Packages' -TaskPath $taskPath -ErrorAction SilentlyContinue

    if ($taskExists -and -not $Force) {
        $response = Read-Host 'Task exists. Overwrite? (Y/N)'
        if ($response -ne 'Y') {
            Write-Host 'Skipped task creation' -ForegroundColor Yellow
        }
    }
    else {
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName 'Update-Winget-Packages' -TaskPath $taskPath -Confirm:$false
        }

        $action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$mainScriptPath`""
        $trigger = switch ($ScheduleFrequency) {
            'Daily' { New-ScheduledTaskTrigger -Daily -At $ScheduleTime }
            'Weekly' { New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At $ScheduleTime }
            'Monthly' { New-ScheduledTaskTrigger -Monthly -Day 1 -At $ScheduleTime }
        }

        $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Automated Windows Package Manager Updates'

        Register-ScheduledTask -TaskName 'Update-Winget-Packages' -TaskPath $taskPath -InputObject $task -Force | Out-Null
        Write-Host "✓ Created task: Update-Winget-Packages ($ScheduleFrequency at $ScheduleTime)" -ForegroundColor Green
    }
}

# Create Start Menu shortcut
if ($CreateStartMenuShortcut) {
    Write-Host "`nCreating Start Menu shortcut..." -ForegroundColor Cyan
    if ($PSCmdlet.ShouldProcess('Shortcut', 'Create')) {
        try {
            $shortcutScript = Join-Path $InstallPath 'update-winget-packages-create-start-menu-shortcut.ps1'
            if (Test-Path -Path $shortcutScript) {
                & $shortcutScript
            }
        }
        catch {
            Write-Warning "Shortcut creation failed: $_"
        }
    }
}

# Create uninstall script
Write-Host "`nCreating uninstall script..." -ForegroundColor Cyan
if ($PSCmdlet.ShouldProcess('uninstall.ps1', 'Create')) {
    $uninstallPath = Join-Path $InstallPath 'uninstall.ps1'
    $uninstallText = @'
#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
<#.SYNOPSIS Uninstalls the Winget Updater suite.#>

Write-Host 'Removing scheduled task...'
$task = Get-ScheduledTask -TaskName 'Update-Winget-Packages' -TaskPath '\Microsoft\Windows\Winget\' -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName 'Update-Winget-Packages' -TaskPath '\Microsoft\Windows\Winget\' -Confirm:$false
    Write-Host '✓ Removed task'
}

Write-Host 'Removing Start Menu shortcuts...'
$itAutoFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\IT Automation"
if (Test-Path -Path $itAutoFolder) {
    Remove-Item -Path $itAutoFolder -Recurse -Force
    Write-Host '✓ Removed IT Automation folder and all shortcuts'
}

Write-Host 'Removing installation directory...'
Remove-Item -Path 'C:\Program Files\WingetUpdater' -Recurse -Force
Write-Host '✓ Uninstalled successfully'
'@
    Set-Content -Path $uninstallPath -Value $uninstallText -Force -Encoding UTF8
    Write-Host "✓ Created: $uninstallPath" -ForegroundColor Green
}

# Create README
Write-Host "`nGenerating documentation..." -ForegroundColor Cyan
if ($PSCmdlet.ShouldProcess('README.md', 'Create')) {
    $readmePath = Join-Path $InstallPath 'README.md'
    $readmeText = @"
# Winget Package Manager Updater

Automated Windows Package Manager (Winget) update suite.

## Installation Location

$InstallPath

## Scheduled Updates

$ScheduleFrequency at $ScheduleTime

## Manual Execution

\`\`\`powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$InstallPath\update-winget-packages.ps1"
\`\`\`

Or use the Start Menu shortcut: **Update Winget Packages**

## Uninstall

\`\`\`powershell
& "$InstallPath\uninstall.ps1"
\`\`\`

## Support

https://github.com/poslogica/generalscripts
"@
    Set-Content -Path $readmePath -Value $readmeText -Force -Encoding UTF8
    Write-Host "✓ Created: $readmePath" -ForegroundColor Green
}

# Success
Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "`nLocation: $InstallPath" -ForegroundColor Green
Write-Host "Schedule: $ScheduleFrequency at $ScheduleTime" -ForegroundColor Green
Write-Host "`n📦 Auto-Update Feature:" -ForegroundColor Cyan
Write-Host "   This installation includes a self-update script that can check GitHub for newer versions."
Write-Host "   • To check for updates:  & `"$InstallPath\update-winget-updater.ps1`" -CheckOnly"
Write-Host "   • To disable auto-update: Edit winget-config.json and set AutoUpdate.Enabled = false"
Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Review: $InstallPath\winget-config.json"
Write-Host "2. Logs: $InstallPath\logs"
Write-Host "3. Test: powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $InstallPath 'update-winget-packages.ps1')`""
Write-Host "4. Uninstall: & `"$(Join-Path $InstallPath 'uninstall.ps1')`""
Write-Host ""

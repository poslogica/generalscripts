#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Uninstalls the Winget Package Manager Update Suite from the system.

    .DESCRIPTION
    This script removes all components installed by install-winget-updater.ps1:
    - Removes the scheduled task from Windows Task Scheduler
    - Removes the Start Menu shortcut (if present)
    - Deletes the installation directory and all files
    - Optionally preserves logs and configuration

    .PARAMETER InstallPath
    The installation directory to remove. Defaults to 'C:\Program Files\WingetUpdater'

    .PARAMETER KeepLogs
    If specified, preserves the logs directory by copying to a backup location.

    .PARAMETER KeepConfig
    If specified, preserves the winget-config.json by copying to a backup location.

    .PARAMETER BackupPath
    Directory to save preserved logs/config. Defaults to user's Documents folder.

    .PARAMETER Force
    Skip confirmation prompts.

    .EXAMPLE
    .\uninstall-winget-updater.ps1
    Uninstalls with confirmation prompt.

    .EXAMPLE
    .\uninstall-winget-updater.ps1 -Force
    Uninstalls without prompting.

    .EXAMPLE
    .\uninstall-winget-updater.ps1 -KeepLogs -KeepConfig
    Uninstalls but preserves logs and configuration to Documents folder.

    .EXAMPLE
    .\uninstall-winget-updater.ps1 -KeepLogs -BackupPath 'D:\Backups'
    Uninstalls and saves logs to custom backup location.

    .NOTES
    - Requires administrator privileges (enforced with #Requires)
    - Windows 10/11 or Windows Server 2019+
    - PowerShell 5.1+ required

    .LINK
    https://github.com/poslogica/generalscripts
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$InstallPath = 'C:\Program Files\WingetUpdater',

    [Parameter(Mandatory = $false)]
    [switch]$KeepLogs,

    [Parameter(Mandatory = $false)]
    [switch]$KeepConfig,

    [Parameter(Mandatory = $false)]
    [string]$BackupPath = '',

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# Configuration
# ============================================================================
$TaskName = 'Update-Winget-Packages'
$TaskPath = '\Microsoft\Windows\Winget\'
$ShortcutName = 'Update Winget Packages.lnk'
$StartMenuPath = [Environment]::GetFolderPath('CommonPrograms')

# Set default backup path if not specified
if ([string]::IsNullOrWhiteSpace($BackupPath)) {
    $BackupPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WingetUpdater-Backup'
}

# ============================================================================
# Helper Functions
# ============================================================================
function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )
    
    $color = switch ($Type) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }
    
    $prefix = switch ($Type) {
        'Info'    { '→' }
        'Success' { '✓' }
        'Warning' { '!' }
        'Error'   { '✗' }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

# ============================================================================
# Pre-flight Checks
# ============================================================================
Write-Host "`n=== Winget Updater Uninstaller ===" -ForegroundColor Cyan
Write-Host "Installation path: $InstallPath" -ForegroundColor Gray

# Check if installation exists
$installExists = Test-Path $InstallPath
$taskExists = $null -ne (Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue)
$shortcutPath = Join-Path $StartMenuPath $ShortcutName
$shortcutExists = Test-Path $shortcutPath

if (-not $installExists -and -not $taskExists -and -not $shortcutExists) {
    Write-Status "No Winget Updater installation found." 'Warning'
    Write-Host "  Checked:"
    Write-Host "    - Path: $InstallPath (not found)"
    Write-Host "    - Task: $TaskPath$TaskName (not found)"
    Write-Host "    - Shortcut: $shortcutPath (not found)"
    exit 0
}

# Show what will be removed
Write-Host "`nComponents to remove:" -ForegroundColor White
if ($installExists) { Write-Host "  • Installation directory: $InstallPath" }
if ($taskExists) { Write-Host "  • Scheduled task: $TaskPath$TaskName" }
if ($shortcutExists) { Write-Host "  • Start Menu shortcut: $ShortcutName" }

if ($KeepLogs -or $KeepConfig) {
    Write-Host "`nComponents to preserve (backup to $BackupPath):" -ForegroundColor White
    if ($KeepLogs) { Write-Host "  • Logs directory" }
    if ($KeepConfig) { Write-Host "  • Configuration file (winget-config.json)" }
}

# Confirmation prompt
if (-not $Force) {
    Write-Host ""
    $confirm = Read-Host "Proceed with uninstallation? [y/N]"
    if ($confirm -notmatch '^[Yy]') {
        Write-Status "Uninstallation cancelled." 'Warning'
        exit 0
    }
}

Write-Host ""

# ============================================================================
# Backup Phase (if requested)
# ============================================================================
if (($KeepLogs -or $KeepConfig) -and $installExists) {
    Write-Status "Creating backups..." 'Info'
    
    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }
    
    # Backup logs
    if ($KeepLogs) {
        $logsPath = Join-Path $InstallPath 'logs'
        if (Test-Path $logsPath) {
            $logsBackup = Join-Path $BackupPath 'logs'
            Copy-Item -Path $logsPath -Destination $logsBackup -Recurse -Force
            Write-Status "Logs backed up to: $logsBackup" 'Success'
        } else {
            Write-Status "No logs directory found to backup." 'Warning'
        }
    }
    
    # Backup config
    if ($KeepConfig) {
        $configPath = Join-Path $InstallPath 'winget-config.json'
        if (Test-Path $configPath) {
            $configBackup = Join-Path $BackupPath 'winget-config.json'
            Copy-Item -Path $configPath -Destination $configBackup -Force
            Write-Status "Config backed up to: $configBackup" 'Success'
        } else {
            Write-Status "No configuration file found to backup." 'Warning'
        }
    }
}

# ============================================================================
# Remove Scheduled Task
# ============================================================================
if ($taskExists) {
    Write-Status "Removing scheduled task..." 'Info'
    
    if ($PSCmdlet.ShouldProcess("$TaskPath$TaskName", "Remove scheduled task")) {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
            Write-Status "Scheduled task removed." 'Success'
        }
        catch {
            Write-Status "Failed to remove scheduled task: $_" 'Error'
        }
    }
}

# ============================================================================
# Remove Start Menu Shortcut
# ============================================================================
if ($shortcutExists) {
    Write-Status "Removing Start Menu shortcut..." 'Info'
    
    if ($PSCmdlet.ShouldProcess($shortcutPath, "Remove shortcut")) {
        try {
            Remove-Item -Path $shortcutPath -Force
            Write-Status "Start Menu shortcut removed." 'Success'
        }
        catch {
            Write-Status "Failed to remove shortcut: $_" 'Error'
        }
    }
}

# ============================================================================
# Remove Installation Directory
# ============================================================================
if ($installExists) {
    Write-Status "Removing installation directory..." 'Info'
    
    if ($PSCmdlet.ShouldProcess($InstallPath, "Remove directory")) {
        try {
            Remove-Item -Path $InstallPath -Recurse -Force
            Write-Status "Installation directory removed." 'Success'
        }
        catch {
            Write-Status "Failed to remove directory: $_" 'Error'
            Write-Host "  You may need to manually delete: $InstallPath" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# Cleanup Empty Task Folder (if applicable)
# ============================================================================
try {
    # Check if the Winget task folder is now empty and remove it
    $taskFolder = Get-ScheduledTask -TaskPath $TaskPath -ErrorAction SilentlyContinue
    if ($null -eq $taskFolder -or $taskFolder.Count -eq 0) {
        # Note: Can't easily remove empty task folders via PowerShell, this is just informational
        Write-Host ""
        Write-Host "Note: The task folder '$TaskPath' may remain in Task Scheduler (empty folders are harmless)." -ForegroundColor Gray
    }
}
catch {
    # Ignore errors checking task folder
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "=== Uninstallation Complete ===" -ForegroundColor Green

if ($KeepLogs -or $KeepConfig) {
    Write-Host ""
    Write-Host "Backup location: $BackupPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Winget Updater has been removed from the system." -ForegroundColor White

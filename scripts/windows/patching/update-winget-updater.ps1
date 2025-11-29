<#
.SYNOPSIS
    Self-update script for Winget Updater - checks GitHub releases for updates.

.DESCRIPTION
    This script checks the GitHub repository for newer releases and automatically
    updates the installed Winget Updater scripts if a newer version is available.
    
    It uses the GitHub API to check releases and downloads the latest installer
    package to perform the update.

.PARAMETER InstallPath
    Path where Winget Updater is installed.
    Default: C:\Program Files\WingetUpdater

.PARAMETER CheckOnly
    Only check for updates without installing them.

.PARAMETER Force
    Force update even if current version matches latest.

.PARAMETER PreRelease
    Include pre-release versions when checking for updates.

.EXAMPLE
    .\Update-WingetUpdater.ps1
    
    Check for updates and install if available.

.EXAMPLE
    .\Update-WingetUpdater.ps1 -CheckOnly
    
    Only check if updates are available without installing.

.EXAMPLE
    .\Update-WingetUpdater.ps1 -Force
    
    Force reinstall of the latest version.

.NOTES
    - Requires internet access to GitHub
    - Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7)
    - May require administrator privileges to update files in Program Files
    - GitHub API rate limits may apply.

.LINK
    https://github.com/poslogica/generalscripts
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$InstallPath = "$env:ProgramFiles\WingetUpdater",
    [switch]$CheckOnly,
    [switch]$Force,
    [switch]$PreRelease
)

$ErrorActionPreference = 'Stop'

# GitHub repository information
$GitHubOwner = 'poslogica'
$GitHubRepo = 'generalscripts'
$GitHubApiBase = "https://api.github.com/repos/$GitHubOwner/$GitHubRepo"

# Version file and config in install directory
$VersionFile = Join-Path $InstallPath 'VERSION'
$ConfigFile = Join-Path $InstallPath 'winget-config.json'

function Get-AutoUpdateConfig {
    <#
    .SYNOPSIS
        Reads auto-update settings from winget-config.json
    #>
    $defaults = @{
        Enabled = $true
        CheckOnRun = $false
        IncludePreRelease = $false
    }
    
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            if ($config.AutoUpdate) {
                if ($null -ne $config.AutoUpdate.Enabled) {
                    $defaults.Enabled = $config.AutoUpdate.Enabled
                }
                if ($null -ne $config.AutoUpdate.CheckOnRun) {
                    $defaults.CheckOnRun = $config.AutoUpdate.CheckOnRun
                }
                if ($null -ne $config.AutoUpdate.IncludePreRelease) {
                    $defaults.IncludePreRelease = $config.AutoUpdate.IncludePreRelease
                }
            }
        }
        catch {
            Write-Status "Warning: Could not read config file, using defaults" 'WARN'
        }
    }
    
    return $defaults
}

function Write-Status {
    param([string]$Message, [string]$Type = 'INFO')
    $color = switch ($Type) {
        'INFO'    { 'Cyan' }
        'SUCCESS' { 'Green' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        default   { 'White' }
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp][$Type] $Message" -ForegroundColor $color
}

function Get-InstalledVersion {
    if (Test-Path $VersionFile) {
        $version = (Get-Content $VersionFile -Raw).Trim()
        # Handle both "v1.0.0" and "1.0.0" formats
        return $version -replace '^v', ''
    }
    return $null
}

function Get-LatestGitHubRelease {
    param([switch]$IncludePreRelease)
    
    try {
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'WingetUpdater-AutoUpdate/1.0'
        }
        
        if ($IncludePreRelease) {
            # Get all releases and pick the first one
            $url = "$GitHubApiBase/releases"
            $releases = Invoke-RestMethod -Uri $url -Headers $headers -UseBasicParsing
            $release = $releases | Select-Object -First 1
        } else {
            # Get latest stable release
            $url = "$GitHubApiBase/releases/latest"
            $release = Invoke-RestMethod -Uri $url -Headers $headers -UseBasicParsing
        }
        
        return $release
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Status "No releases found in repository" 'WARN'
            return $null
        }
        throw
    }
}

function Compare-Versions {
    param([string]$Current, [string]$Latest)
    
    # Clean version strings
    $currentClean = $Current -replace '^v', ''
    $latestClean = $Latest -replace '^v', ''
    
    try {
        $currentVer = [version]$currentClean
        $latestVer = [version]$latestClean
        
        if ($latestVer -gt $currentVer) { return 1 }   # Update available
        if ($latestVer -eq $currentVer) { return 0 }   # Same version
        return -1                                        # Current is newer (dev build?)
    }
    catch {
        # Fall back to string comparison if version parsing fails
        if ($latestClean -ne $currentClean) { return 1 }
        return 0
    }
}

function Get-InstallerAsset {
    param($Release)
    
    # Look for the installer ZIP in release assets
    $asset = $Release.assets | Where-Object { 
        $_.name -match 'winget-updater-setup.*\.zip$' -or
        $_.name -match 'WingetUpdater.*\.zip$'
    } | Select-Object -First 1
    
    return $asset
}

function Install-Update {
    param($Release, $Asset)
    
    $tempDir = Join-Path $env:TEMP "WingetUpdater-Update-$(Get-Date -Format 'yyyyMMddHHmmss')"
    $zipPath = Join-Path $tempDir $Asset.name
    
    try {
        # Create temp directory
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        Write-Status "Downloading $($Asset.name)..."
        
        # Download the asset
        $headers = @{
            'Accept' = 'application/octet-stream'
            'User-Agent' = 'WingetUpdater-AutoUpdate/1.0'
        }
        
        # Use browser_download_url for direct download
        Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $zipPath -UseBasicParsing
        
        Write-Status "Extracting update package..."
        
        # Extract ZIP
        $extractPath = Join-Path $tempDir 'extracted'
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        
        # Find the installer script
        $installer = Get-ChildItem -Path $extractPath -Recurse -Filter 'install-winget-updater.ps1' | 
                     Select-Object -First 1
        
        if (-not $installer) {
            throw "Could not find install-winget-updater.ps1 in the update package"
        }
        
        Write-Status "Running installer..."
        
        # Run the installer with Force to overwrite
        $installArgs = @{
            FilePath = 'powershell.exe'
            ArgumentList = @(
                '-NoProfile',
                '-ExecutionPolicy', 'Bypass',
                '-File', $installer.FullName,
                '-InstallPath', $InstallPath,
                '-Force'
            )
            Wait = $true
            NoNewWindow = $true
            PassThru = $true
        }
        
        $process = Start-Process @installArgs
        
        if ($process.ExitCode -ne 0) {
            throw "Installer exited with code $($process.ExitCode)"
        }
        
        # Update version file
        $Release.tag_name | Out-File -FilePath $VersionFile -Encoding UTF8 -NoNewline
        
        Write-Status "Update completed successfully!" 'SUCCESS'
        return $true
    }
    catch {
        Write-Status "Update failed: $($_.Exception.Message)" 'ERROR'
        return $false
    }
    finally {
        # Cleanup temp directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# ============== Main Logic ==============

# Script version (updated with each release)
$ScriptVersion = '1.0.15'

Write-Status "Winget Updater - Auto-Update Check (Script v$ScriptVersion)"
Write-Status "Install Path: $InstallPath"

# Check if install directory exists
if (-not (Test-Path $InstallPath)) {
    Write-Status "Winget Updater is not installed at $InstallPath" 'ERROR'
    Write-Status "Run the installer first, or specify the correct -InstallPath" 'INFO'
    exit 1
}

# Check auto-update configuration
$autoUpdateConfig = Get-AutoUpdateConfig
if (-not $autoUpdateConfig.Enabled -and -not $Force) {
    Write-Status "Auto-update is disabled in configuration" 'INFO'
    Write-Status "To enable: Edit winget-config.json and set AutoUpdate.Enabled = true" 'INFO'
    Write-Status "To override: Run with -Force parameter" 'INFO'
    exit 0
}

# Use config for PreRelease if not explicitly set via parameter
if (-not $PSBoundParameters.ContainsKey('PreRelease') -and $autoUpdateConfig.IncludePreRelease) {
    $PreRelease = [switch]$true
}

# Get current installed version
$currentVersion = Get-InstalledVersion
if ($currentVersion) {
    Write-Status "Installed version: v$currentVersion"
} else {
    Write-Status "No version file found - assuming outdated installation" 'WARN'
    $currentVersion = '0.0.0'
}

# Check GitHub for latest release
Write-Status "Checking GitHub for updates..."
$latestRelease = Get-LatestGitHubRelease -IncludePreRelease:$PreRelease

if (-not $latestRelease) {
    Write-Status "Could not determine latest version" 'ERROR'
    exit 1
}

$latestVersion = $latestRelease.tag_name -replace '^v', ''
Write-Status "Latest release: v$latestVersion"

# Compare versions
$comparison = Compare-Versions -Current $currentVersion -Latest $latestVersion

if ($comparison -eq 0 -and -not $Force) {
    Write-Status "You are running the latest version!" 'SUCCESS'
    exit 0
}

if ($comparison -lt 0 -and -not $Force) {
    Write-Status "Installed version is newer than latest release (development build?)" 'WARN'
    exit 0
}

# Update is available (or forced)
if ($Force) {
    Write-Status "Force update requested" 'WARN'
} else {
    Write-Status "Update available: v$currentVersion -> v$latestVersion" 'INFO'
}

# Check-only mode
if ($CheckOnly) {
    Write-Status "Update available! Run without -CheckOnly to install." 'INFO'
    Write-Host ""
    Write-Host "Release Notes:" -ForegroundColor Cyan
    Write-Host $latestRelease.body
    exit 0
}

# Find the installer asset
$asset = Get-InstallerAsset -Release $latestRelease

if (-not $asset) {
    Write-Status "No installer package found in release assets" 'WARN'
    Write-Status "Release URL: $($latestRelease.html_url)" 'INFO'
    Write-Status "Please download and install manually" 'INFO'
    exit 1
}

Write-Status "Found update package: $($asset.name) ($([math]::Round($asset.size / 1KB, 1)) KB)"

# Confirm update
if (-not $PSCmdlet.ShouldProcess("Winget Updater v$latestVersion", "Install update")) {
    Write-Status "Update cancelled" 'WARN'
    exit 0
}

# Perform update
$success = Install-Update -Release $latestRelease -Asset $asset

if ($success) {
    exit 0
} else {
    exit 1
}

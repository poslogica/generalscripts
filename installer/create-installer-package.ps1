#!/usr/bin/env pwsh
<#
    .SYNOPSIS
    Creates a distribution ZIP package for the Winget Updater suite.

    .DESCRIPTION
    This script packages all necessary files into a distributable ZIP file
    that users can download and run to install the Winget Updater.

    .PARAMETER OutputPath
    The directory where the ZIP file will be created. Defaults to current directory.

    .PARAMETER OutputName
    The name of the ZIP file. Defaults to 'winget-updater-setup-v{version}.zip'

    .PARAMETER Version
    The version number to include in the filename. Defaults to reading from VERSION file.
    Format: MAJOR.MINOR.PATCH (e.g., 1.0.0)

    .EXAMPLE
    .\create-installer-package.ps1

    .\create-installer-package.ps1 -OutputPath 'C:\Releases'

    .\create-installer-package.ps1 -Version '1.0.0' -OutputPath 'C:\Releases'

    .NOTES
    Requires PowerShell 5.1+
    Version file location: installer/VERSION
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$OutputName = '',

    [Parameter(Mandatory = $false)]
    [string]$Version = ''
)

$ErrorActionPreference = 'Stop'

# Get directories
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerDir = $scriptDir
$repoRoot = Split-Path -Parent $installerDir
$patchingDir = Join-Path $repoRoot 'scripts\windows\patching'
$versionFile = Join-Path $installerDir 'VERSION'

if (-not (Test-Path $installerDir)) {
    Write-Error "Installer directory not found: $installerDir"
    exit 1
}

# Read version from file if not provided
if ([string]::IsNullOrWhiteSpace($Version)) {
    if (Test-Path $versionFile) {
        $versionContent = Get-Content -Path $versionFile -Raw
        $versionMatch = $versionContent | Select-String -Pattern '^\d+\.\d+\.\d+' -AllMatches
        if ($versionMatch.Matches) {
            $Version = $versionMatch.Matches[0].Value
        }
    }
}

# Default to 1.0.0 if still empty
if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = '1.0.0'
}

# Generate output filename with version if not specified
if ([string]::IsNullOrWhiteSpace($OutputName)) {
    $OutputName = "winget-updater-setup-v$Version.zip"
}

Write-Host "`n=== Creating Winget Updater Distribution Package ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host "Output: $OutputPath\$OutputName`n" -ForegroundColor Green

# Create temp working directory
$tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "winget-pkg-$((Get-Date).Ticks)") -Force
$packageDir = New-Item -ItemType Directory -Path (Join-Path $tempDir 'winget-updater') -Force

try {
    # Copy installer files
    Write-Host 'Packaging files...'
    $installerFiles = @('install-winget-updater.ps1', 'install-winget-updater.bat', 'INSTALL.md')
    foreach ($file in $installerFiles) {
        $source = Join-Path $installerDir $file
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $packageDir
            Write-Host "  ✓ Added: $file"
        }
        else {
            Write-Warning "  ! Missing: $file"
        }
    }

    # Copy script files
    $scriptFiles = @(
        'update-winget-packages.ps1',
        'update-winget-packages-create-start-menu-shortcut.ps1',
        'winget-config.json',
        'uninstall-winget-updater.ps1'
    )
    foreach ($file in $scriptFiles) {
        $source = Join-Path $patchingDir $file
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $packageDir
            Write-Host "  ✓ Added: $file"
        }
        else {
            Write-Warning "  ! Missing: $file"
        }
    }

    # Create quick start README
    $readmeText = @"
# Winget Updater - Quick Start

This package contains everything needed to install automated Winget updates.

## Installation

### Option 1: Batch File (Easiest)
1. Right-click **install-winget-updater.bat**
2. Select **Run as administrator**
3. Follow the prompts

### Option 2: PowerShell
1. Open PowerShell as Administrator
2. Navigate to this directory
3. Run: \`.\install-winget-updater.ps1\`

## Documentation

See **INSTALL.md** for detailed instructions.

## Requirements

- Windows 10/11 or Server 2019+
- Administrator privileges
- Winget must be installed

## Support

https://github.com/poslogica/generalscripts
"@
    Set-Content -Path (Join-Path $packageDir 'README.txt') -Value $readmeText
    Write-Host "  ✓ Added: README.txt"

    # Ensure output directory exists
    $null = New-Item -ItemType Directory -Path $OutputPath -Force

    # Create ZIP file
    $zipPath = Join-Path $OutputPath $OutputName
    if (Test-Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }

    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)

    $fileSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "`n✓ Package created successfully!" -ForegroundColor Green
    Write-Host "Location: $zipPath" -ForegroundColor Green
    Write-Host "Size: $($fileSize.ToString('F2')) MB" -ForegroundColor Green
    Write-Host "`nUsers can now download and extract this ZIP." -ForegroundColor Cyan
}
catch {
    Write-Error "Package creation failed: $_"
    exit 1
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

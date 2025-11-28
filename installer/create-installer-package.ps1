#!/usr/bin/env pwsh
<#
    .SYNOPSIS
    Creates a distribution ZIP package for the Winget Updater suite.

    .DESCRIPTION
    This script packages the necessary files into a distributable ZIP file
    that users can download and run to install the Winget Updater.

    .PARAMETER OutputPath
    The directory where the ZIP file will be created.
    Defaults to the current directory.

    .PARAMETER OutputName
    The name of the ZIP file to create.
    Defaults to 'winget-updater-setup.zip'

    .EXAMPLE
    .\create-installer-package.ps1

    .\create-installer-package.ps1 -OutputPath 'C:\Releases' -OutputName 'winget-updater-v1.0.zip'

    .NOTES
    Requires PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [string]$OutputPath = (Get-Location).Path,
    [string]$OutputName = 'winget-updater-setup.zip'
)

$ErrorActionPreference = 'Stop'

# Find the installer directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerDir = $scriptDir
$patchingDir = Split-Path -Parent $installerDir

# Find the patching scripts relative to repository root
$repoRoot = Split-Path -Parent $installerDir
$patchingScriptsDir = Join-Path $repoRoot 'scripts\windows\patching'

if (-not (Test-Path $installerDir)) {
    Write-Error "Installer directory not found: $installerDir"
    exit 1
}

Write-Host "=== Creating Winget Updater Distribution Package ===" -ForegroundColor Cyan
Write-Host "Output: $OutputPath\$OutputName`n" -ForegroundColor Green

# Create a temporary working directory
$tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "winget-updater-$((Get-Date).Ticks)") -Force
$packageDir = New-Item -ItemType Directory -Path (Join-Path $tempDir 'winget-updater') -Force

try {
    # Copy installer files
    Write-Host "Packaging files..."
    $filesToPackage = @(
        'install-winget-updater.ps1',
        'install-winget-updater.bat',
        'INSTALL.md'
    )
    
    foreach ($file in $filesToPackage) {
        $sourcePath = Join-Path $installerDir $file
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $packageDir
            Write-Host "  ✓ Added: $file"
        }
        else {
            Write-Warning "  ! File not found: $file"
        }
    }
    
    # Copy the patching scripts
    $scriptsToInclude = @(
        'update-winget-packages.ps1',
        'update-winget-packages-create-start-menu-shortcut.ps1',
        'winget-config.json'
    )
    
    foreach ($file in $scriptsToInclude) {
        $sourcePath = Join-Path $patchingScriptsDir $file
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $packageDir
            Write-Host "  ✓ Added: $file"
        }
        else {
            Write-Warning "  ! File not found: $file"
        }
    }
    
    # Create README in package
    $readmeContent = @"
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
3. Run: `.\install-winget-updater.ps1`

## Documentation

See **INSTALL.md** for:
- Detailed installation instructions
- Configuration options
- Troubleshooting guide
- Advanced usage

## Requirement

- Windows 10/11 or Server 2019+
- Administrator privileges
- Winget must be installed

## Support

Issues? Visit: https://github.com/poslogica/generalscripts

---

For detailed help, see INSTALL.md
"@
    Set-Content -Path (Join-Path $packageDir 'README.txt') -Value $readmeContent
    Write-Host "  ✓ Added: README.txt"
    
    # Ensure output path exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    # Create the ZIP file
    $zipPath = Join-Path $OutputPath $OutputName
    
    # Remove existing ZIP if it exists
    if (Test-Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }
    
    # Use native .NET compression
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    
    $fileSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "`n✓ Package created successfully!" -ForegroundColor Green
    Write-Host "Location: $zipPath" -ForegroundColor Green
    Write-Host "Size: $($fileSize.ToString('F2')) MB" -ForegroundColor Green
    Write-Host "`nUsers can now download and extract this ZIP to get started." -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to create package: $_"
    exit 1
}
finally {
    # Cleanup temporary directory
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

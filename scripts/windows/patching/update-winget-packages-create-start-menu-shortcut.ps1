<#
.SYNOPSIS
    Create Start Menu shortcuts for IT Automation tools

.DESCRIPTION
    This script creates a Start Menu folder called "IT Automation" and populates it with
    shortcuts for IT automation tools. The shortcuts are placed in the All Users Start Menu
    Programs folder and are accessible to all users.
    
    Current shortcuts created:
    - Update Winget Packages: Runs the winget package update script
    - Update Winget Packages (Diagnostics): Runs winget update with diagnostic output
    - Check for Updates: Checks for newer versions of the IT Automation tools
    - Documentation: Opens the project documentation (GitHub README) in default browser
    - View Logs: Opens the WingetUpdater logs folder
    
    Each shortcut is configured with:
    - PowerShell executable as the target application
    - Execution policy bypass for seamless execution
    - Script location as working directory
    - Appropriate Shell32 system icon for visual identification

.PARAMETER
    This script does not accept any parameters.

.EXAMPLE
    .\Update-WingetPackages-CreateStartMenuShortcut.ps1
    
    Creates the IT Automation Start Menu folder with all shortcuts.

.NOTES
    - Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7)
    - Windows 10/11 or Windows Server 2019+
    - Creates shortcuts in the All Users Start Menu (requires elevation)
    - Folder: "IT Automation"
    - Location: $env:ProgramData\Microsoft\Windows\Start Menu\Programs\IT Automation\
    - Uses WScript.Shell COM object for shortcut creation

.LINK
    https://github.com/poslogica/generalscripts
#>

# ----- COM Object Setup -----
# Create WScript.Shell COM object for Windows shortcut management
$ws = New-Object -ComObject WScript.Shell

# ----- Start Menu Folder Configuration -----
# Define path to All Users Start Menu Programs folder with IT Automation subfolder
$menuFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\IT Automation"

# Create the IT Automation folder if it doesn't exist
if (-not (Test-Path $menuFolder)) {
    New-Item -ItemType Directory -Path $menuFolder -Force | Out-Null
    Write-Output "Created folder: $menuFolder"
}

# ----- PowerShell Executable Configuration -----
# Specify the Windows PowerShell executable (System32 version, not Core)
$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# ----- Shortcut 1: Update Winget Packages -----
$script1 = Join-Path $PSScriptRoot 'update-winget-packages.ps1'
$lnk1Path = Join-Path $menuFolder 'Update Winget Packages.lnk'

$lnk1 = $ws.CreateShortcut($lnk1Path)
$lnk1.TargetPath = $ps
$lnk1.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script1`""
$lnk1.WorkingDirectory = $PSScriptRoot
$lnk1.IconLocation = "%SystemRoot%\System32\shell32.dll,167"
$lnk1.Description = "Update third-party software using Windows Package Manager (winget)"
$lnk1.Save()
Write-Output "Shortcut created: $lnk1Path"

# ----- Shortcut 1b: Update Winget Packages with Diagnostics -----
$lnk1bPath = Join-Path $menuFolder 'Update Winget Packages (Diagnostics).lnk'

$lnk1b = $ws.CreateShortcut($lnk1bPath)
$lnk1b.TargetPath = $ps
$lnk1b.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script1`" -Diagnostics"
$lnk1b.WorkingDirectory = $PSScriptRoot
$lnk1b.IconLocation = "%SystemRoot%\System32\shell32.dll,79"
$lnk1b.Description = "Update winget packages with diagnostic output (for troubleshooting)"
$lnk1b.Save()
Write-Output "Shortcut created: $lnk1bPath"

# ----- Shortcut 2: Check for Updates -----
$script2 = Join-Path $PSScriptRoot 'update-winget-updater.ps1'
if (Test-Path $script2) {
    $lnk2Path = Join-Path $menuFolder 'Check for Updater Updates.lnk'
    
    $lnk2 = $ws.CreateShortcut($lnk2Path)
    $lnk2.TargetPath = $ps
    $lnk2.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script2`" -CheckOnly -Wait"
    $lnk2.WorkingDirectory = $PSScriptRoot
    $lnk2.IconLocation = "%SystemRoot%\System32\shell32.dll,13"
    $lnk2.Description = "Check GitHub for newer versions of IT Automation tools"
    $lnk2.Save()
    Write-Output "Shortcut created: $lnk2Path"
}

# ----- Shortcut 3: Documentation / Help -----
# Create a URL shortcut (.url) that opens the GitHub README in the default browser
$urlPath = Join-Path $menuFolder 'Documentation.url'
$urlContent = @"
[InternetShortcut]
URL=https://github.com/poslogica/generalscripts#readme
IconIndex=0
IconFile=%SystemRoot%\System32\shell32.dll
"@
Set-Content -Path $urlPath -Value $urlContent -Encoding ASCII
Write-Output "URL shortcut created: $urlPath"

# ----- Shortcut 4: Logs Folder -----
# Create a shortcut to the logs directory for easy access to update logs
$logsFolder = "$env:ProgramData\WingetUpdater\logs"
if (-not (Test-Path $logsFolder)) {
    New-Item -ItemType Directory -Path $logsFolder -Force | Out-Null
}

$lnk4Path = Join-Path $menuFolder 'View Logs.lnk'
$lnk4 = $ws.CreateShortcut($lnk4Path)
$lnk4.TargetPath = $logsFolder
$lnk4.Description = "Open the WingetUpdater logs folder"
$lnk4.IconLocation = "%SystemRoot%\System32\shell32.dll,4"
$lnk4.Save()
Write-Output "Shortcut created: $lnk4Path"

Write-Output "IT Automation shortcuts created successfully!"


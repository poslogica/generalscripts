<#
.SYNOPSIS
    Create a Start Menu shortcut for the Update Winget Packages script

.DESCRIPTION
    This script creates a convenient Start Menu shortcut for the Update-WingetPackages.ps1 script.
    The shortcut is placed in the All Users Start Menu Programs folder and is accessible to all users.
    
    The shortcut is configured with:
    - PowerShell executable as the target application
    - Execution policy bypass for seamless execution
    - Script location as working directory
    - Shell32 system icon (update icon) for visual identification

.PARAMETER
    This script does not accept any parameters.

.EXAMPLE
    .\Update-WingetPackages-CreateStartMenuShortcut.ps1
    
    Creates a Start Menu shortcut for Update Winget Packages functionality.

.NOTES
    - Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7)
    - Windows 10/11 or Windows Server 2019+
    - Creates the shortcut in the All Users Start Menu (requires elevation)
    - Shortcut name: "Update Winget Packages.lnk"
    - Location: $env:ProgramData\Microsoft\Windows\Start Menu\Programs\
    - Icon: Shell32.dll icon index 167 (system update icon)
    - Uses WScript.Shell COM object for shortcut creation

.LINK
    https://github.com/poslogica/generalscripts
#>

# ----- COM Object Setup -----
# Create WScript.Shell COM object for Windows shortcut management
$ws = New-Object -ComObject WScript.Shell

# ----- Start Menu Shortcut Configuration -----
# Define path to All Users Start Menu Programs folder
# This makes the shortcut accessible to all users on the system
$lnkPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Update Winget Packages.lnk"

# ----- PowerShell Executable Configuration -----
# Specify the Windows PowerShell executable (System32 version, not Core)
$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# ----- Target Script Configuration -----
# Build path to the update-winget-packages.ps1 script in the same directory
$script = (Join-Path $PSScriptRoot 'update-winget-packages.ps1')

# ----- Shortcut Object Creation -----
# Create the shortcut object that will be configured and saved
$lnk = $ws.CreateShortcut($lnkPath)

# ----- Shortcut Properties Configuration -----
# Set the target executable (PowerShell)
$lnk.TargetPath = $ps

# Configure PowerShell arguments for seamless script execution:
# -NoProfile: Skip PowerShell profile loading for faster startup
# -ExecutionPolicy Bypass: Allow script execution without policy restrictions
# -File: Specify the script file to execute (quoted for path safety)
$lnk.Arguments  = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""

# Set the working directory to the script's directory
# This allows relative path operations within the script
$lnk.WorkingDirectory = $PSScriptRoot

# ----- Shortcut Icon Configuration -----
# Set the shortcut icon to Shell32.dll icon index 167 (system update icon)
# Format: "%SystemRoot%\System32\shell32.dll,167"
# Icon 167 displays an appropriate update/refresh symbol
$lnk.IconLocation = "%SystemRoot%\System32\shell32.dll,167"

# ----- Shortcut Persistence -----
# Save the configured shortcut to the file system
# Creates or overwrites the shortcut file at $lnkPath
$lnk.Save()

# ----- Status Confirmation -----
# Output confirmation message showing the created shortcut location
Write-Output "Shortcut created: $lnkPath"


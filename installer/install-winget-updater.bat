@echo off
REM Winget Updater Installation Wrapper
REM This batch file simplifies running the PowerShell installer
REM REQUIRES: PowerShell 7+ (pwsh.exe) - https://github.com/PowerShell/PowerShell/releases

setlocal enabledelayedexpansion

echo.
echo ======================================
echo Winget Updater Installation
echo ======================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: This installer requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Check for PowerShell 7 (pwsh.exe)
where pwsh.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: PowerShell 7 ^(pwsh.exe^) is required but not found!
    echo.
    echo This installer requires PowerShell 7+, not Windows PowerShell 5.1.
    echo.
    echo Download PowerShell 7 from:
    echo   https://github.com/PowerShell/PowerShell/releases
    echo.
    echo Or install via winget:
    echo   winget install Microsoft.PowerShell
    echo.
    pause
    exit /b 1
)

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell 7 installer
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-winget-updater.ps1"

if %errorlevel% equ 0 (
    echo.
    echo Installation completed successfully!
) else (
    echo.
    echo Installation failed. Check the output above for details.
)

pause

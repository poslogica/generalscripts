@echo off
REM Winget Updater Installation Wrapper
REM This batch file simplifies running the PowerShell installer

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

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_DIR%install-winget-updater.ps1'"

if %errorlevel% equ 0 (
    echo.
    echo Installation completed successfully!
) else (
    echo.
    echo Installation failed. Check the output above for details.
)

pause

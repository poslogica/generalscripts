@echo off
REM Winget Updater Installer - Batch Wrapper
REM This batch file handles PowerShell execution policy automatically
REM Allows non-technical users to run the installer without PowerShell commands

REM Get the directory where this batch file is located
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM Check if PowerShell is available
powershell -Command "exit 0" >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: PowerShell is not available or not in PATH
    echo.
    echo This installer requires PowerShell 7+ (pwsh.exe)
    echo.
    echo Solutions:
    echo 1. Install PowerShell 7+ from: https://github.com/PowerShell/PowerShell/releases
    echo 2. Or install from Windows Store: Search for "PowerShell"
    echo 3. Or via Winget: winget install Microsoft.PowerShell
    echo.
    pause
    exit /b 1
)

REM Run the PowerShell installer with execution policy bypass
REM This bypasses the execution policy only for this script execution
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0install-winget-updater.ps1" %*

REM Capture exit code
set EXIT_CODE=%errorlevel%

REM Keep window open to show results
if %EXIT_CODE% neq 0 (
    echo.
    echo Installation failed with exit code %EXIT_CODE%
    echo.
) else (
    echo.
    echo Installation completed successfully!
    echo.
)

pause
exit /b %EXIT_CODE%

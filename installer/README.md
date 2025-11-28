# Winget Updater Installer

This directory contains the installer and distribution package creation tools for the Winget Package Manager Updater suite.

## Files

- **`install-winget-updater.ps1`** - PowerShell installer script with full feature support
- **`install-winget-updater.bat`** - Batch wrapper for easy execution (right-click → Run as Administrator)
- **`create-installer-package.ps1`** - Script to generate distribution ZIP packages
- **`INSTALL.md`** - Comprehensive installation and usage guide

## Quick Start for Users

### Option 1: Download Pre-built Package

1. Download `winget-updater-setup.zip` from releases
2. Extract the ZIP file
3. Right-click `install-winget-updater.bat` → **Run as administrator**

### Option 2: PowerShell Installation

```powershell
# As Administrator
.\install-winget-updater.ps1
```

## For Developers/Maintainers

### Create Distribution Package

```powershell
# Create a new ZIP package
.\create-installer-package.ps1 -OutputPath "C:\Releases"

# With custom name
.\create-installer-package.ps1 -OutputPath "C:\Releases" -OutputName "winget-updater-v1.0.zip"
```

### Customize Installation

The installer supports several parameters:

```powershell
# Custom installation path and schedule
.\install-winget-updater.ps1 `
    -InstallPath 'C:\Tools\WingetUpdater' `
    -ScheduleFrequency Daily `
    -ScheduleTime '03:00' `
    -Force
```

See `INSTALL.md` for complete documentation and examples.

## Installation Features

✓ **Admin validation** - Ensures administrator privileges
✓ **Winget verification** - Checks for Windows Package Manager
✓ **Flexible scheduling** - Daily, Weekly, or Monthly automatic updates
✓ **Task Scheduler integration** - Runs as SYSTEM with highest privileges
✓ **Start Menu shortcut** - Easy access to manual execution
✓ **Uninstall script** - Clean removal of all components with optional backup
✓ **Logging** - Comprehensive logs in installation directory
✓ **Configuration** - Customizable via `winget-config.json`

## System Requirements

- **Windows**: 10/11 or Server 2019+
- **PowerShell**: 5.1+ (native on Windows; 7.x supported)
- **Winget**: Must be installed (included with modern Windows)
- **Administrator**: Required for installation

## Support

For issues, documentation, or feature requests:

- **Repository**: [GitHub - poslogica/generalscripts](https://github.com/poslogica/generalscripts)
- **Issues**: [GitHub Issues](https://github.com/poslogica/generalscripts/issues)

---

**Last Updated**: 2025-11-29  
**Version**: 1.1

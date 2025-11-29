# Winget Package Manager Updater - Installation Guide

## Quick Start

### Option 1: Batch File (Easiest)

1. Download `winget-updater-setup.zip`
2. Extract to a temporary location
3. Right-click `install-winget-updater.bat`
4. Select **Run as administrator**
5. Follow the prompts

### Option 2: PowerShell 7 Script

1. Extract the ZIP file
2. Open **PowerShell 7** (`pwsh`) as Administrator
3. Run:

```powershell
cd "path\to\extracted\files"
pwsh .\install-winget-updater.ps1
```

> ⚠️ **Do not use Windows PowerShell** (`powershell.exe`) - use `pwsh.exe`

### Option 3: PowerShell with Custom Settings

```powershell
.\install-winget-updater.ps1 `
    -InstallPath 'C:\Tools\WingetUpdater' `
    -ScheduleFrequency Daily `
    -ScheduleTime '03:00' `
    -Force
```

## Installation Parameters

### `-InstallPath`

Directory where the updater will be installed.

- **Default**: `C:\Program Files\WingetUpdater`
- **Example**: `-InstallPath 'C:\Tools\Winget'`

### `-ScheduleFrequency`

How often to run automatic updates.

- **Options**: `Daily`, `Weekly`, `Monthly`
- **Default**: `Weekly`
- **Example**: `-ScheduleFrequency Daily`

### `-ScheduleTime`

Time to run scheduled updates (24-hour format).

- **Default**: `02:00` (2 AM)
- **Format**: `HH:mm`
- **Example**: `-ScheduleTime '03:30'`

### `-CreateStartMenuShortcut`

Whether to create a Start Menu shortcut for manual execution.

- **Default**: `$true`
- **Example**: `-CreateStartMenuShortcut $false`

### `-PinToTaskbar`

Whether to pin the shortcut to the Windows taskbar.

- **Default**: `$false`
- **Example**: `-PinToTaskbar $true`
- **Note**: May not work on all Windows versions due to security restrictions

### `-Force`

Skip confirmation prompts and overwrite existing installation.

- **Default**: `$false`
- **Example**: `-Force`

## What Gets Installed

### Files

- `update-winget-packages.ps1` - Main update script
- `update-winget-packages-create-start-menu-shortcut.ps1` - Shortcut creation utility
- `winget-config.json` - Configuration file
- `uninstall-winget-updater.ps1` - Uninstall script
- `README.txt` - Quick start guide

### Features

✓ Automated Windows Package Manager (winget) updates
✓ Configurable schedule (Daily/Weekly/Monthly)
✓ Windows Task Scheduler integration
✓ Start Menu shortcut for manual execution
✓ Comprehensive logging
✓ Easy uninstall

### Default Location

```text
C:\Program Files\WingetUpdater\
├── update-winget-packages.ps1
├── update-winget-packages-create-start-menu-shortcut.ps1
├── winget-config.json
├── uninstall-winget-updater.ps1
└── logs\
```

## After Installation

### Manual Execution

Run updates immediately from the Start Menu or PowerShell:

```powershell
C:\Program Files\WingetUpdater\update-winget-packages.ps1
```

### Configuration

Edit the configuration file:

```text
C:\Program Files\WingetUpdater\winget-config.json
```

### View Logs

```text
C:\Program Files\WingetUpdater\logs\
```

### Uninstall

```powershell
# Basic uninstall
C:\Program Files\WingetUpdater\uninstall-winget-updater.ps1

# Uninstall but keep logs and config
C:\Program Files\WingetUpdater\uninstall-winget-updater.ps1 -KeepLogs -KeepConfig

# Silent uninstall
C:\Program Files\WingetUpdater\uninstall-winget-updater.ps1 -Force
```

Or manually:

1. Open Task Scheduler
2. Delete task: `Update-Winget-Packages`
3. Delete the folder: `C:\Program Files\WingetUpdater`
4. Delete Start Menu shortcut: `Update Winget Packages`

## Requirements

- **Windows**: 10/11 or Server 2019+
- **PowerShell 7+** (pwsh.exe): **Required** - [Download PowerShell 7](https://github.com/PowerShell/PowerShell/releases)
- **Winget**: Must be installed
- **Administrator**: Required for installation and some operations

> ⚠️ **Important**: This installer requires **PowerShell 7** (`pwsh.exe`), not Windows PowerShell (`powershell.exe`).
> Windows PowerShell 5.1 is NOT supported for the installer.

## Troubleshooting

### "Administrator privileges required"

Run the batch file or PowerShell as Administrator:

1. Right-click `install-winget-updater.bat` → **Run as administrator**
2. Or: Right-click PowerShell → **Run as administrator** → Navigate to folder → Run script

### "Winget not found"

Install Windows Package Manager:

1. Visit: [Windows Package Manager](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
2. Or: Install from Microsoft Store: "App Installer"

### Installation path access denied

- Try a different location (e.g., `C:\Tools\WingetUpdater`)
- Ensure the parent directory has write permissions
- Run as Administrator

### Scheduled task not running

1. Open Task Scheduler
2. Navigate to: `\Microsoft\Windows\Winget`
3. Right-click `Update-Winget-Packages` → **Run** to test
4. Check logs for errors

### Updates not applying

1. Verify winget is working: `winget upgrade`
2. Check logs: `C:\Program Files\WingetUpdater\logs\`
3. Review configuration: `winget-config.json`

## Support & Issues

For help or to report issues:

- **Repository**: [GitHub - poslogica/generalscripts](https://github.com/poslogica/generalscripts)
- **Issues**: [GitHub Issues](https://github.com/poslogica/generalscripts/issues)

## Advanced Usage

### Customize Schedule Frequency

After installation, modify the Task Scheduler job:

1. Open Task Scheduler
2. Find: `Update-Winget-Packages`
3. Right-click → **Properties** → **Triggers** tab
4. Modify the trigger settings

### Run at Different Time

Edit the scheduled task trigger in Task Scheduler or reinstall with different `-ScheduleTime`:

```powershell
.\install-winget-updater.ps1 -ScheduleTime '22:00' -Force
```

### Disable Auto-Start Menu Shortcut

```powershell
.\install-winget-updater.ps1 -CreateStartMenuShortcut $false
```

### Silent Installation

```powershell
.\install-winget-updater.ps1 -Force | Out-Null
```

## License

See repository for license information: [poslogica/generalscripts](https://github.com/poslogica/generalscripts)

---

**Version**: 1.1
**Last Updated**: 2025-11-29
**Tested On**: Windows 11, Windows Server 2022

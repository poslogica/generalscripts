# FAQ & Troubleshooting Guide

Answers to common questions and solutions for issues you might encounter.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Scheduled Task Issues](#scheduled-task-issues)
- [Auto-Update Issues](#auto-update-issues)
- [Start Menu Issues](#start-menu-issues)
- [General Questions](#general-questions)

## Installation Issues

### Q: "Winget is not installed or not available"

**Error Message:**
```
Winget is not installed or not available.
Visit: https://learn.microsoft.com/en-us/windows/package-manager/winget/
```

**Solutions:**

1. **Install Winget:**
   - Windows 11: Usually pre-installed. Go to Microsoft Store → "App Installer"
   - Windows 10: Download from Microsoft Store or GitHub
   - Windows Server: Download from GitHub releases

2. **Verify Installation:**
   ```powershell
   winget --version
   ```

3. **Update Winget:**
   ```powershell
   winget upgrade Microsoft.DesktopAppInstaller
   ```

---

### Q: "The term 'pwsh.exe' is not recognized"

**Error Message:**
```
The term 'pwsh.exe' is not recognized as the name of a cmdlet, function, script file, or executable program.
```

**Solutions:**

1. **Install PowerShell 7+:**
   - Download from: https://github.com/PowerShell/PowerShell/releases
   - Or via Winget: `winget install Microsoft.PowerShell`

2. **Use Windows PowerShell temporarily** (not recommended):
   ```powershell
   powershell.exe .\install-winget-updater.ps1
   ```

3. **Add PowerShell to PATH:**
   - Open Environment Variables (Win+X → Environment Variables)
   - Add `C:\Program Files\PowerShell\7` to PATH
   - Restart terminal

---

### Q: "Execution policy prevents script from running"

**Error Messages:**
```
File cannot be loaded because running scripts is disabled on this system.
```

OR

```
SecurityError: File ... cannot be loaded. The file ... is not digitally signed.
You cannot run this script on the current system.
```

**Solutions (Recommended Order):**

**Option 1: Use Batch Wrapper (Easiest - Recommended)**
- Use `install-winget-updater.bat` instead of PowerShell script
- Double-click and run—no commands needed
- Automatically handles execution policy bypass

**Option 2: Bypass Policy for This Script**
```powershell
powershell -ExecutionPolicy Bypass -File ".\install-winget-updater.ps1"
```
- Safest approach: bypasses policy only for this one execution
- No permanent system changes
- Works even with restrictive policies

**Option 3: Unblock Downloaded File**
```powershell
Unblock-File -Path ".\install-winget-updater.ps1"
```
Then run normally:
```powershell
.\install-winget-updater.ps1
```
- Removes "downloaded from internet" security flag
- Clean one-time fix

**Option 4: Change Execution Policy (Permanent)**
```powershell
# Set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or set for local machine (requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```
- Allows all local scripts to run
- More permissive approach

---

### Q: "Access denied" or "You do not have sufficient privileges"

**Error Message:**
```
Access denied. You do not have sufficient privileges to perform this operation.
```

**Solutions:**

1. **Run as Administrator:**
   - Right-click PowerShell → "Run as administrator"
   - Or use `#Requires -RunAsAdministrator` in script

2. **Check UAC (User Account Control):**
   - Settings → System → About → Advanced system settings
   - User Account Control Settings → Don't change UAC (keep default or higher)

---

## Scheduled Task Issues

### Q: "Task exists. Overwrite? (Y/N)" - How to skip this?

**Situation:** Installation interrupted, re-running installer prompts about existing task.

**Solution:**

Use the `-Force` parameter to skip prompts:
```powershell
.\install-winget-updater.ps1 -Force
```

---

### Q: "Scheduled task not running"

**Symptoms:** Task exists but doesn't execute at scheduled time.

**Troubleshooting Steps:**

1. **Verify Task Exists:**
   ```powershell
   Get-ScheduledTask -TaskName "Update-Winget-Packages" | Format-List
   ```

2. **Check Task Status:**
   ```powershell
   Get-ScheduledTask -TaskName "Update-Winget-Packages" | Select-Object TaskName, State
   # State should be "Ready"
   ```

3. **View Last Run Result:**
   ```powershell
   Get-ScheduledTaskInfo -TaskName "Update-Winget-Packages"
   ```

4. **Test Task Manually:**
   ```powershell
   Start-ScheduledTask -TaskName "Update-Winget-Packages"
   ```

5. **Enable SYSTEM Account Login:**
   - Task Scheduler → Update-Winget-Packages → Properties → General
   - Check: "Run with highest privileges"
   - Check: "Run whether user is logged in or not"

---

### Q: "Task still running from yesterday"

**Situation:** Update task takes too long and prevents next scheduled run.

**Solutions:**

1. **Stop the running task:**
   ```powershell
   Stop-ScheduledTask -TaskName "Update-Winget-Packages"
   ```

2. **Increase update timeout in script:**
   - Edit `update-winget-packages.ps1`
   - Check for package size limits or timeout settings

3. **Change schedule to less frequent:**
   ```powershell
   .\install-winget-updater.ps1 -ScheduleFrequency Monthly -Force
   ```

---

## Auto-Update Issues

### Q: "How do I disable auto-updates?"

**Answer:**

Edit the configuration file:
```powershell
# Location: C:\Program Files\WingetUpdater\winget-config.json

{
  "AutoUpdate": {
    "Enabled": false,          # Change to false
    "CheckOnRun": false,
    "IncludePreRelease": false
  }
}
```

Then restart for changes to take effect.

---

### Q: "Auto-update script failing with 'rate limit exceeded'"

**Error Message:**
```
GitHub API rate limit exceeded. Please try again later.
```

**Explanation:**
- GitHub allows 60 requests/hour without authentication
- Multiple machines checking simultaneously can hit this limit

**Solutions:**

1. **Stagger update times:**
   - Don't all run updates at 02:00 AM
   - Set different times on different machines

2. **Disable auto-update on some machines:**
   ```powershell
   # Edit winget-config.json
   "AutoUpdate": {
     "Enabled": false,
     "CheckOnRun": false
   }
   ```

3. **Check manually less frequently:**
   - Run the check script manually instead of automatically

---

### Q: "How do I force an immediate update check?"

**Answer:**

Run the update script manually:
```powershell
# Check for updates (no download)
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -CheckOnly

# Check and update if available
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1"

# Force update even if current version is latest
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -Force
```

---

## Start Menu Issues

### Q: "Start Menu shortcuts not appearing"

**Symptoms:** Installed successfully but can't find shortcuts in Start Menu.

**Solutions:**

1. **Clear Start Menu cache:**
   ```powershell
   Stop-Process -Name "StartMenuExperienceHost" -Force -ErrorAction SilentlyContinue
   Start-Sleep -Seconds 2
   Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Caches\*" -Force -ErrorAction SilentlyContinue
   Start-Process explorer.exe
   ```

2. **Wait 10-15 seconds** for Start Menu to refresh

3. **Restart your computer** if cache clear doesn't work

4. **Verify files exist:**
   ```powershell
   Get-ChildItem "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\IT Automation"
   ```

---

### Q: "Shortcuts open but say 'File not found'"

**Symptoms:** Shortcuts exist but clicking them shows error dialog.

**Solutions:**

1. **Verify script exists:**
   ```powershell
   Test-Path "C:\Program Files\WingetUpdater\update-winget-packages.ps1"
   ```

2. **Check shortcut properties:**
   - Right-click shortcut → Properties
   - Verify Target path is correct
   - Verify Start in (Working directory) is correct

3. **Recreate shortcuts:**
   ```powershell
   & "C:\Program Files\WingetUpdater\update-winget-packages-create-start-menu-shortcut.ps1"
   ```

---

## General Questions

### Q: "What does each script do?"

**Answer:**

| Script | Purpose |
|--------|---------|
| `update-winget-packages.ps1` | Main update runner - installs available updates |
| `update-third-party-with-winget.ps1` | Core update logic with config support |
| `update-winget-updater.ps1` | Auto-update feature - checks for newer installer version |
| `update-winget-packages-create-start-menu-shortcut.ps1` | Creates Start Menu folder and shortcuts |
| `install-winget-updater.ps1` | Installation script - sets up system |
| `uninstall-winget-updater.ps1` | Cleanup - removes all installed components |

---

### Q: "Can I customize which packages get updated?"

**Answer:** Yes, edit `winget-config.json`:

```json
{
  "IncludeOnlyIds": ["Microsoft.VisualStudioCode"],  // Only update these
  "ExcludeIds": ["Anaconda.*", "VirtualBox"],         // Skip these
  "ExcludeNames": ["Anaconda3*", "VirtualBox"],       // Skip by name
  "ExcludeSources": ["msstore"]                       // Skip this source
}
```

---

### Q: "Where are the logs stored?"

**Answer:**

```powershell
# Log directory
C:\ProgramData\WingetUpdater\logs\

# Log file naming
winget-YYYYMMDD-HHMMSS.log
# Example: winget-20251203-021530.log
```

View recent logs:
```powershell
Get-ChildItem "C:\ProgramData\WingetUpdater\logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 5
```

---

### Q: "How do I uninstall completely?"

**Answer:**

Run the uninstall script:
```powershell
# With default options (keeps logs and config)
& "C:\Program Files\WingetUpdater\uninstall-winget-updater.ps1"

# Remove logs and config too
& "C:\Program Files\WingetUpdater\uninstall-winget-updater.ps1" -Force
```

Or manually:
```powershell
# Remove scheduled task
Unregister-ScheduledTask -TaskName "Update-Winget-Packages" -Confirm:$false

# Remove Start Menu folder
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\IT Automation" -Recurse -Force

# Remove installation folder
Remove-Item "C:\Program Files\WingetUpdater" -Recurse -Force
```

---

### Q: "Can I run this on Windows Server?"

**Answer:** Yes, with requirements:

1. Windows Server 2019+ required
2. PowerShell 7+ must be installed
3. Winget must be installed (available via GitHub or App Store)
4. Administrator privileges required

---

### Q: "Is this safe to use in production?"

**Answer:**

**Yes, with precautions:**

- ✅ Comprehensive error handling
- ✅ 259 automated tests pass
- ✅ Supports WhatIf preview mode
- ✅ Maintains logs for audit trail
- ⚠️ Test in staging environment first
- ⚠️ Review configuration before deployment
- ⚠️ Monitor logs after first runs

---

## Still Have Issues?

### Get More Help

1. **Check script help:**
   ```powershell
   Get-Help "C:\Program Files\WingetUpdater\update-winget-packages.ps1" -Full
   ```

2. **View detailed logs:**
   ```powershell
   Get-Content "C:\ProgramData\WingetUpdater\logs\winget-*.log" | Select-Object -Last 50
   ```

3. **Run in diagnostic mode:**
   ```powershell
   & "C:\Program Files\WingetUpdater\update-winget-packages.ps1" -Diagnostics
   ```

4. **Check GitHub Issues:**
   - https://github.com/poslogica/generalscripts/issues

5. **Report a bug:**
   - Include log files and Windows version
   - Describe exact steps to reproduce
   - Provide error messages verbatim

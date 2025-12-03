# Auto-Update Feature Guide

Comprehensive documentation of the Winget Updater auto-update capability.

## Overview

The Winget Updater includes an **automatic update mechanism** that keeps your installation current with the latest features, bug fixes, and performance improvements. This guide explains how it works and how to configure it.

## Quick Start

### Default Behavior

By default, auto-updates are **enabled and running**:

- Checks for new versions **weekly** on Monday at 02:00 AM
- Downloads and installs updates **automatically**
- Does NOT include pre-release versions
- Requires no user interaction

### Disable Auto-Updates

Edit the configuration file to disable:

```powershell
# Location: C:\Program Files\WingetUpdater\winget-config.json

{
  "AutoUpdate": {
    "Enabled": false,          # ← Set to false
    "CheckOnRun": false,
    "IncludePreRelease": false
  }
}
```

Save and restart the scheduled task.

## How It Works

### Update Flow

```
1. Scheduled Task Triggers (Weekly)
          ↓
2. update-winget-updater.ps1 Runs
          ↓
3. Checks GitHub API
   (api.github.com/repos/poslogica/generalscripts/releases/latest)
          ↓
4. Compares VERSION File
   (Current installed version)
          ↓
5. Decision Point
   ├─ If newer available → Download & Install
   └─ If current → Exit (no action)
          ↓
6. Backup & Extraction
          ↓
7. Installation Complete
          ↓
8. Logs Result
```

### Version Checking

The update script:

1. **Reads current version** from `VERSION` file
2. **Queries GitHub API** for latest release tag
3. **Compares semantic versions** (e.g., 1.0.19 vs 1.0.20)
4. **Downloads if newer** (e.g., 1.0.20 > 1.0.19)

### Backup Strategy

Before updating:

1. Creates backup directory: `C:\Program Files\WingetUpdater.backup.TIMESTAMP`
2. Copies all current files there
3. Proceeds with installation
4. Keeps backup for 7 days (manual cleanup)

## Configuration Options

### winget-config.json Settings

```json
{
  "AutoUpdate": {
    "Enabled": true,
    "CheckOnRun": false,
    "IncludePreRelease": false
  }
}
```

#### Enabled

**Type:** Boolean  
**Default:** `true`  
**Options:**
- `true` - Auto-updates active (checks weekly, installs when available)
- `false` - Auto-updates disabled

**When disabled:**
- Weekly check still happens but doesn't install
- User must manually run `update-winget-updater.ps1 -Force` to update

---

#### CheckOnRun

**Type:** Boolean  
**Default:** `false`  
**Options:**
- `true` - Check for updates every time scripts run
- `false` - Only check on scheduled (weekly)

**Performance:** `true` adds 2-5 seconds to each run (API call to GitHub)

---

#### IncludePreRelease

**Type:** Boolean  
**Default:** `false`  
**Options:**
- `true` - Install pre-release/beta versions (v1.0.20-beta)
- `false` - Only stable releases (v1.0.20)

**Risk:** Pre-releases may be unstable. Not recommended for production.

## Manual Update Control

### Check for Updates Only

View what's available without installing:

```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -CheckOnly
```

**Output:**
```
Current version: 1.0.19
Latest available: 1.0.20
Status: Update available!
```

### Force Immediate Update

Install immediately, skip confirmation:

```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -Force
```

### Preview Update (WhatIf)

See what would happen without making changes:

```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -WhatIf
```

### Update with Pre-Release

Include beta/preview versions:

```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -PreRelease
```

### Update with Wait

Install and wait for user to press a key (interactive):

```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -Wait
```

## Viewing Update Status

### Check Scheduled Task

```powershell
# View task details
Get-ScheduledTask -TaskName "Update-Winget-Packages" | Format-List

# View last run results
Get-ScheduledTaskInfo -TaskName "Update-Winget-Packages"

# View next scheduled run
Get-ScheduledTask -TaskName "Update-Winget-Packages" | Select-Object -ExpandProperty Triggers
```

### Check Version Installed

```powershell
# Current version
Get-Content "C:\Program Files\WingetUpdater\VERSION"

# Output: 1.0.20
```

### View Update Logs

```powershell
# List recent logs
Get-ChildItem "C:\ProgramData\WingetUpdater\logs" -Filter "*update*" | Sort-Object LastWriteTime -Descending | Select-Object -First 5

# View latest log
Get-Content (Get-ChildItem "C:\ProgramData\WingetUpdater\logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

## Update Schedule

### Scheduled Execution

Default schedule:

| Setting | Value |
|---------|-------|
| **Day** | Every Monday |
| **Time** | 02:00 AM (2:00 AM) |
| **Frequency** | Weekly |
| **Account** | SYSTEM |
| **Elevation** | Highest privileges |

### Change Schedule

Reinstall with different schedule:

```powershell
.\install-winget-updater.ps1 `
    -ScheduleFrequency Daily `
    -ScheduleTime "03:00" `
    -Force
```

**Options:**
- **ScheduleFrequency:** `Daily`, `Weekly`, `Monthly`
- **ScheduleTime:** 24-hour format (HH:mm), e.g., "03:00", "14:30"

### Run Immediately

Start the scheduled task now:

```powershell
Start-ScheduledTask -TaskName "Update-Winget-Packages"

# Wait for it to finish
Start-Sleep -Seconds 30

# Check result
Get-ScheduledTaskInfo -TaskName "Update-Winget-Packages"
```

## Rate Limiting

### GitHub API Rate Limits

**Public Access:** 60 requests per hour per IP

**Impact:**
- Multiple machines checking simultaneously may hit limit
- Error: "API rate limit exceeded"

**Solutions:**

1. **Stagger check times:**
   ```powershell
   # Machine 1 - 02:00 AM
   .\install-winget-updater.ps1 -ScheduleTime "02:00"
   
   # Machine 2 - 02:15 AM
   .\install-winget-updater.ps1 -ScheduleTime "02:15"
   
   # Machine 3 - 02:30 AM
   .\install-winget-updater.ps1 -ScheduleTime "02:30"
   ```

2. **Disable CheckOnRun:**
   ```json
   {
     "AutoUpdate": {
       "Enabled": true,
       "CheckOnRun": false  // ← Don't check every run
     }
   }
   ```

3. **Disable auto-update on some machines:**
   ```json
   {
     "AutoUpdate": {
       "Enabled": false  // ← Only main server updates
     }
   }
   ```

## Troubleshooting

### Updates Not Running

**Check if auto-update is enabled:**
```powershell
Get-Content "C:\Program Files\WingetUpdater\winget-config.json" | ConvertFrom-Json | Select-Object -ExpandProperty AutoUpdate
```

**Verify scheduled task:**
```powershell
Get-ScheduledTask -TaskName "Update-Winget-Packages"
# Status should be "Ready"
```

**Test manually:**
```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -CheckOnly
```

---

### Rate Limit Errors

**Error Message:**
```
GitHub API rate limit exceeded. Please try again later.
```

**Solution:**
- Wait 1 hour for rate limit to reset
- Or stagger update times across machines
- Or disable CheckOnRun in config

---

### Update Fails Silently

**Check logs:**
```powershell
# View latest update attempt
Get-ChildItem "C:\ProgramData\WingetUpdater\logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

**Common reasons:**
- Network connectivity issues
- GitHub API unavailable
- File permission issues
- Disk space low

---

### Stuck on Old Version

**Force update immediately:**
```powershell
& "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -Force -Wait
```

**If that fails:**
```powershell
# Delete local version file to force update
Remove-Item "C:\Program Files\WingetUpdater\VERSION"

# Re-run installer
.\install-winget-updater.ps1 -Force
```

## Update Rollback

### Revert to Previous Version

If an update causes issues, revert using backup:

```powershell
# Find backup
Get-ChildItem "C:\Program Files\WingetUpdater.backup.*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Example: C:\Program Files\WingetUpdater.backup.20251203-021500

# Copy backup back (requires admin)
Copy-Item "C:\Program Files\WingetUpdater.backup.20251203-021500\*" -Destination "C:\Program Files\WingetUpdater" -Force -Recurse
```

## Best Practices

### For Production Environments

1. **Disable auto-update initially:**
   ```json
   "AutoUpdate": { "Enabled": false }
   ```

2. **Test updates in staging first:**
   - Run manual update check
   - Verify functionality
   - Then enable in production

3. **Stagger across servers:**
   - Don't all update at same time
   - Reduces API rate limit issues

4. **Monitor logs after enabling:**
   ```powershell
   Get-ChildItem "C:\ProgramData\WingetUpdater\logs" -Filter "*.log" | 
     Sort-Object LastWriteTime -Descending | 
     Select-Object -First 5 | 
     ForEach-Object { Write-Host "=== $($_.Name) ==="; Get-Content $_.FullName }
   ```

### For Development/Testing

1. **Enable all features:**
   ```json
   "AutoUpdate": {
     "Enabled": true,
     "CheckOnRun": true,
     "IncludePreRelease": true
   }
   ```

2. **Check frequently:**
   ```powershell
   & "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -CheckOnly -Wait
   ```

3. **Capture detailed output:**
   ```powershell
   & "C:\Program Files\WingetUpdater\update-winget-updater.ps1" -Verbose -Wait
   ```

## FAQ

**Q: Does auto-update require user interaction?**  
A: No. Updates download and install automatically without prompts.

**Q: Can I schedule updates for a specific time?**  
A: Yes, use `-ScheduleTime "HH:mm"` when installing.

**Q: What if an update fails?**  
A: Backup is kept for 7 days. Manual rollback available.

**Q: Is it safe to disable auto-update?**  
A: Yes. You can manually update anytime or re-enable auto-update later.

**Q: Will updates restart my system?**  
A: No. Only Winget package updates might require restarts (after installation completes).

**Q: Can I see what changed in an update?**  
A: Yes, check changelog: https://github.com/poslogica/generalscripts/blob/main/changelog.md

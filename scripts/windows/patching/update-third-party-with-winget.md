
# Update-ThirdPartyWithWinget

A PowerShell script to update third-party software using **winget**, driven by a JSON config. It’s resilient to noisy winget output, supports whitelists/blacklists, skips pinned apps, and can auto-retry scope (user/machine) when needed. A companion wrapper adds auto-elevation and logging.

---

## Features

- Update apps via `winget` with:
  - Include-only lists (`IncludeOnlyIds`, `IncludeOnlyNames`)
  - Excludes (`ExcludeIds`, `ExcludeNames`, `ExcludeSources`)
  - Skip pinned apps (when winget reports `IsPinned`)
- Robust discovery (tries JSON → sanitized JSON → table fallback)
- Smart upgrade flow:
  - Tries with **no scope** first
  - Falls back to `--scope machine` then `--scope user` if “not found”
- Flags: `-IncludeUnknown`, `-WhatIf`, `-LogPath`, `-StopOnError`, `-Diagnostics`
- Optional wrapper `Update-WingetPackages.ps1`:
  - Auto-elevates for machine scope
  - Timestamped log file in `./logs/`

---

## Requirements

- Windows 10/11 with **App Installer / winget**
- PowerShell **5.1+** (works in 7.x too)
- Network access to configured winget sources (e.g., `winget`, `msstore`)

Verify winget:

```powershell
winget --version
```

---

## Files

```txt

update-third-party-with-winget.ps1   # main updater
update-winget-packages.ps1         # optional wrapper (auto-elevate & logging)
winget-config.json                # config (you create/maintain this)
logs/                             # created by wrapper (timestamped logs)
```

---

## Configuration (`winget-config.json`)

Wildcards are supported in *Id* and *Name* lists (PowerShell `-like` semantics).

```json
{
  "IncludeOnlyIds":   [ "Git.Git", "Google.Chrome" ],   // optional
  "IncludeOnlyNames": [ "Git", "Google Chrome" ],       // optional

  "ExcludeIds":       [ "Anaconda.*", "Adobe.*" ],      // optional
  "ExcludeNames":     [ "Anaconda3 *", "NVIDIA *" ],    // optional

  "ExcludeSources":   [ "msstore" ]                     // optional, exact match (e.g., "winget", "msstore")
}
```

**Rules**
- If any `IncludeOnly*` list has entries, only matching apps are considered.
- Then exclusions are applied.
- `ExcludeSources` filters by the package’s source (exact string).
- Pinned apps (if winget reports as pinned) are skipped.

---

## Basic Usage (main script)

From the folder containing the script:

```powershell
# Default run (no explicit scope, auto-detect + retry)
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1
```

### Useful switches

```powershell
# Include packages with unknown installed version
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -IncludeUnknown

# Diagnostics: saves raw winget outputs next to the script
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -Diagnostics

# Log to a file
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -LogPath "C:\Logs\winget-upgrade.log"

# Dry run (no changes)
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -WhatIf

# Stop on first failure
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -StopOnError

# Force a scope (if you know it); Admin recommended for machine
powershell.exe -ExecutionPolicy Bypass -File .\update-third-party-with-winget.ps1 -Scope machine
```

> Tip: Leave **`-Scope` unset** and let the script auto-detect unless you specifically need one.

---

## Wrapper Usage (auto-elevate & logging)

The wrapper auto-elevates when `-Scope machine` is used and writes a timestamped log to `./logs/`.

```powershell
# Default: machine scope, include unknown, diagnostics, timestamped log
.\update-winget-packages.ps1

# User scope dry run
.\update-winget-packages.ps1 -Scope user -WhatIf

# Forward a flag to the main script after --
.\update-winget-packages.ps1 -- -StopOnError
```

Optional simple launcher (`.bat`):
```bat
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-winget-packages.ps1"
```

---

## Exit Codes

- `0` = success (all selected packages upgraded)
- `2` = completed with failures (some packages failed)
- `1` = setup/validation error (e.g., missing winget, bad JSON)

---

## Common Issues & Fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| “No installed package found matching input criteria.” | Scope mismatch (package installed as machine, running in user scope) | Leave `-Scope` unset to auto-detect; or run elevated with `-Scope machine`. |
| “No applicable upgrade found.” | Newer version exists but doesn’t apply to your system/arch | Check `winget upgrade --id <Id> --exact --verbose-logs`. |
| Installer exits with code (e.g., `1`) | Vendor installer failed under silent mode | Open the installer log path winget prints; may require interactive upgrade or custom overrides. |
| Greedy include/exclude matching | Wildcard patterns too broad | Tighten patterns in `winget-config.json`. |
| Winget output parsing errors | Winget wrote banners/progress; locale/format differences | Use `-Diagnostics` and share the saved `winget-*` files to refine parsing. |

---

## Manual Debugging

Test one package to see raw winget behavior:
```powershell
winget upgrade --id <PackageId> --exact --silent --disable-interactivity --include-unknown --verbose-logs
```
Check the printed installer log path if it fails.

Refresh sources:
```powershell
winget source update
```

List upgrades (table view):
```powershell
winget upgrade
```

---

## Versioning & Contributions

- Keep `.gitignore` updated to ignore logs/diagnostics (`winget-*.log`, `winget-upgrade-raw-*.txt`, etc.).
- Consider storing a **sample** `winget-config.json` in your repo and machine-specific overrides out of source control.

---

## Disclaimer

This script executes third-party installers via `winget` in **silent** mode. Behavior and exit codes are determined by each vendor’s package. Review change logs and test in a non-production environment when possible.

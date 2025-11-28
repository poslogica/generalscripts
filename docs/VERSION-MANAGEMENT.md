# Winget Updater Version Management

This document explains how versioning works for the Winget Updater installer.

## Overview

The Winget Updater uses **Semantic Versioning** (MAJOR.MINOR.PATCH) for all releases and built installer packages.

**Current Version:** 1.0.0

## Version File

**Location:** `installer/VERSION`

This file contains the current version number and is used by:

- `create-installer-package.ps1` - Reads version when building locally
- GitHub Actions workflow - Extracts version for releases and artifacts

## Version Format

Semantic Versioning (SemVer): `MAJOR.MINOR.PATCH`

### Examples

- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New feature (backwards compatible)
- `2.0.0` - Breaking changes

## ZIP Filename Convention

Installer packages include version in the filename:

```text
winget-updater-setup-v{version}.zip

Examples:
- winget-updater-setup-v1.0.0.zip
- winget-updater-setup-v1.0.1.zip
- winget-updater-setup-v1.1.0.zip
```

## GitHub Releases

Releases are tagged with the version number:

```text
Release Tag: v1.0.0
Asset Name: winget-updater-setup-v1.0.0.zip
Release Title: Winget Updater v1.0.0
```

## Artifacts

GitHub Actions artifacts include version in the name:

```text
Artifact Name: winget-updater-setup-v1.0.0
Contains: winget-updater-setup-v1.0.0.zip
```

## How to Update Version

### Step 1: Edit VERSION File

```bash
cd installer
edit VERSION  # or your editor
```

### Step 2: Update Version Number

Find the version line:

```text
1.0.0
```

Change to:

```text
1.0.1
```

### Step 3: Optionally Update Version History

Add entry to Version History section:

```markdown
- **1.0.1** - Bug fix release (2025-11-28)
  - Fixed issue with task scheduling
```

### Step 4: Commit and Push

```bash
git add installer/VERSION
git commit -m "Bump version to 1.0.1"
git push
```

GitHub Actions will automatically:

1. Build the installer with new version
2. Create artifact: `winget-updater-setup-v1.0.1.zip`
3. Create release tagged: `v1.0.1`

## Local Testing

### Build with Default Version

```powershell
cd installer
.\create-installer-package.ps1 -OutputPath "C:\Releases"
```

Creates: `winget-updater-setup-v1.0.0.zip`

### Build with Custom Version

```powershell
.\create-installer-package.ps1 -OutputPath "C:\Releases" -Version "1.0.1"
```

Creates: `winget-updater-setup-v1.0.1.zip`

### Build with Custom Filename

```powershell
.\create-installer-package.ps1 -OutputPath "C:\Releases" -OutputName "my-custom-name.zip"
```

Creates: `my-custom-name.zip`

## Version History

### 1.0.0 (2025-11-28)

**Features:**

- ✓ Automated Windows Package Manager (winget) updates
- ✓ Configurable scheduling (Daily/Weekly/Monthly)
- ✓ Windows Task Scheduler integration
- ✓ Start Menu shortcut for manual execution
- ✓ Comprehensive logging
- ✓ Easy uninstall

**Installation Methods:**

- Batch file wrapper (`install-winget-updater.bat`)
- PowerShell script (`install-winget-updater.ps1`)
- Automated GitHub Actions publishing

**Testing:**

- 195 Pester tests (100% passing)
- PSScriptAnalyzer validation
- Code coverage reporting

## Release Strategy

### When to Bump Version

#### PATCH (1.0.0 → 1.0.1)

- Bug fixes
- Minor improvements
- Documentation updates

#### MINOR (1.0.0 → 1.1.0)

- New features
- Backward compatible changes
- Performance improvements

#### MAJOR (1.0.0 → 2.0.0)

- Breaking changes
- Significant redesign
- Incompatible parameter changes

## For CI/CD Maintainers

### Workflow Integration

The GitHub Actions workflow automatically:

1. **Reads** `installer/VERSION`
2. **Extracts** version (first line matching `\d+\.\d+\.\d+`)
3. **Builds** ZIP with filename: `winget-updater-setup-v{version}.zip`
4. **Creates** artifact named: `winget-updater-setup-v{version}`
5. **Tags** release: `v{version}`

### Version Environment Variables

Available in GitHub Actions steps:

```text
env.ZIP_VERSION    # e.g., "1.0.0"
env.ZIP_NAME       # e.g., "winget-updater-setup-v1.0.0.zip"
env.ZIP_PATH       # Full path to ZIP file
```

### Release Notes Template

Release notes automatically include:

- Version number
- Build number
- Commit SHA
- GitHub user who triggered build
- Link to detailed docs

## User Download Links

Users download specific versions:

### From Releases Page

```text
https://github.com/poslogica/generalscripts/releases/download/v1.0.0/winget-updater-setup-v1.0.0.zip
```

### From Artifacts (Latest Build)

```text
GitHub → Actions → Latest Run → Artifacts
Download: winget-updater-setup-v1.0.0
```

## Multiple Versions

Multiple versions coexist on the Releases page:

```text
Release v1.0.0 → winget-updater-setup-v1.0.0.zip (Latest)
Release v1.0.1 → winget-updater-setup-v1.0.1.zip
Release v1.1.0 → winget-updater-setup-v1.1.0.zip
```

Users can download any version they need.

## Troubleshooting

### Version Not Detected

If the build shows version as "1.0.0" but you expected something else:

1. Check `installer/VERSION` file exists
2. Verify first line contains `MAJOR.MINOR.PATCH`
3. Ensure no extra whitespace or content before version

### ZIP Filename Wrong

If ZIP is named incorrectly:

1. Check `-Version` parameter was passed correctly
2. Verify `installer/VERSION` is readable
3. Confirm regex pattern matches version format

### Release Not Created

If release wasn't created:

1. Verify version hasn't been released before
2. Check push was to `main` branch
3. Review GitHub Actions logs for errors

---

**Last Updated:** 2025-11-28  
**Version File:** `installer/VERSION`  
**Builder Script:** `installer/create-installer-package.ps1`  
**Workflow:** `.github/workflows/publish-installer.yml`

# Winget Updater Version Management

This document explains how versioning works for the Winget Updater installer.

## Overview

The Winget Updater uses **Semantic Versioning** (MAJOR.MINOR.PATCH) for all releases and built installer packages.

**Version Source:** GitHub Release Tags (e.g., `v1.0.0`)

## How Versioning Works

Versions are **automatically determined** from GitHub release tags:

1. The workflow queries the latest GitHub release tag
2. Parses the version number (e.g., `v1.0.5` → `1.0.5`)
3. Increments the patch version (e.g., `1.0.5` → `1.0.6`)
4. Creates a new release with the incremented version

If no releases exist, versioning starts at `v0.0.1`.

## Version File (Reference Only)

**Location:** `installer/VERSION`

This file exists for **reference purposes only**. The actual version is derived from GitHub release tags, not this file.

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

### Automatic (Recommended)

Versions are automatically incremented when the workflow runs. Each successful build:

1. Gets the latest release tag from GitHub
2. Increments the patch version
3. Creates a new release with the new version

### Manual Version Bump

To manually set a specific version (e.g., for major/minor releases):

#### Option 1: Create a Release Manually

1. Go to GitHub → Releases → "Create a new release"
2. Enter your desired tag (e.g., `v2.0.0`)
3. The next automated build will increment from this version

#### Option 2: Use GitHub CLI

```bash
# Create a new release with a specific version
gh release create v2.0.0 --title "Winget Updater v2.0.0" --notes "Major release"
```

### Step 3: Commit and Push

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

1. **Queries** latest release tag via `gh release list`
2. **Parses** version from tag (e.g., `v1.0.5` → `1.0.5`)
3. **Increments** patch version (e.g., `1.0.5` → `1.0.6`)
4. **Builds** ZIP with filename: `winget-updater-setup-v{version}.zip`
5. **Creates** GitHub Release with tag: `v{version}`

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

### Version Not Incrementing

If the build shows the same version:

1. Check GitHub Releases page for existing releases
2. Verify the workflow has `contents: write` permission
3. Ensure `GITHUB_TOKEN` is available to the workflow

### Starting Fresh

To reset versioning:

1. Delete all existing releases on GitHub
2. Delete all tags: `git tag -l | xargs git tag -d && git push origin --delete $(git tag -l)`
3. Next build will start at `v0.0.1`

### ZIP Filename Wrong

If ZIP is named incorrectly:

1. Check the "Get Next Version from GitHub Releases" step output
2. Verify GitHub CLI (`gh`) is working in the workflow
3. Review workflow logs for version parsing errors

### Release Not Created

If release wasn't created:

1. Verify version hasn't been released before
2. Check push was to `main` branch
3. Review GitHub Actions logs for errors

---

**Last Updated:** 2025-11-29  
**Version Source:** GitHub Release Tags  
**Builder Script:** `installer/create-installer-package.ps1`  
**Workflow:** `.github/workflows/publish-installer.yml`

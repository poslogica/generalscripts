# GitHub Actions - Installer Distribution

This document explains how the Winget Updater installer is automatically built and published.

## Automated Publishing Workflow

The repository includes a GitHub Actions workflow that **automatically builds and publishes** the Winget Updater installer package.

**File:** `.github/workflows/publish-installer.yml`

## Workflow Features

### ✅ Automatic Builds

The workflow triggers automatically when:

- Code is pushed to `main` or `develop` branches
- Changes are made to:
  - `installer/` directory
  - `scripts/windows/patching/` directory
  - The workflow file itself

### ✅ Build Process

1. **Checkout code** from the repository
2. **Run package builder** (`create-installer-package.ps1`)
3. **Verify** ZIP package was created successfully
4. **Upload artifact** to GitHub Actions

### ✅ Artifact Publishing

- **Name:** `winget-updater-setup`
- **Content:** ZIP file with all installer components
- **Retention:** 90 days
- **Access:** Available in Actions run summary

### ✅ GitHub Release Creation (Main Branch Only)

When changes are pushed to `main`:

- **Creates a release** with tag: `installer-{build_number}`
- **Uploads ZIP** as release asset
- **Includes notes** with build info, features, and quick start guide
- **Available** on repository Releases page

## How Users Get the Installer

### Option 1: Download from Releases (Easiest)

1. Go to: **GitHub → Releases**
2. Find the latest **"Winget Updater Installer Build"** release
3. Download `winget-updater-setup.zip`
4. Extract and run!

### Option 2: Download from Actions Artifacts

1. Go to: **GitHub → Actions → "Build and Publish Winget Updater Installer"**
2. Select the latest successful run
3. Download `winget-updater-setup` artifact

### Option 3: Build Locally

```powershell
cd installer
.\create-installer-package.ps1 -OutputPath "C:\Releases"
```

## Workflow Triggers

### Automatic (Push Events)

```yaml
on:
  push:
    branches: [ main, develop ]
    paths:
      - 'installer/**'
      - 'scripts/windows/patching/**'
```

### Manual Trigger

Click **"Run workflow"** button in Actions tab to manually trigger a build.

## Artifact Details

### Available During Build

- **Name in UI:** `winget-updater-setup`
- **File inside:** `winget-updater-setup.zip`
- **Download:** Actions → Latest run → Artifacts

### Release Asset

- **Location:** Releases page
- **Name:** `winget-updater-setup.zip`
- **Format:** Direct download from release

## Build Information

Each release includes:

- **Build Number** - GitHub Actions run number
- **Commit SHA** - Git commit hash (first 7 chars)
- **Triggered By** - GitHub username of person who pushed code
- **Timestamp** - When the build ran (in GitHub)

## What's In the ZIP

```yaml
winget-updater-setup.zip
├── install-winget-updater.ps1
├── install-winget-updater.bat
├── INSTALL.md
├── README.txt
├── update-winget-packages.ps1
├── update-winget-packages-create-start-menu-shortcut.ps1
└── winget-config.json
```

## Workflow File Structure

```yaml
name: Build and Publish Winget Updater Installer

on:
  push: [main, develop branches + path filters]
  workflow_dispatch: [manual trigger]

jobs:
  build-installer:
    runs-on: windows-latest
    steps:
      1. Checkout code
      2. Build ZIP package
      3. Publish artifact
      4. Create release (main only)
```

## For Developers

### To Rebuild Manually

1. Go to **Actions tab**
2. Select **"Build and Publish Winget Updater Installer"**
3. Click **"Run workflow"**
4. Monitor the build progress

### To Modify the Workflow

Edit: `.github/workflows/publish-installer.yml`

Changes:

- Build configuration
- Artifact retention
- Release notes template
- Trigger conditions

## Release Naming Convention

Releases use the format: `installer-{build_number}`

Examples:

- `installer-1234`
- `installer-1235`
- `installer-1236`

Each build automatically increments the number.

## Retention Policies

- **Artifacts:** 90 days (configurable)
- **Releases:** Permanent (manual cleanup required)

## Troubleshooting

### Workflow Not Triggering

1. Verify paths match the trigger conditions
2. Check branch is `main` or `develop`
3. Confirm changes touch installer or patching files
4. Use `workflow_dispatch` to manually trigger

### Build Failures

1. Check **Actions tab** for run logs
2. Review error messages in **"Build Winget Updater ZIP package"** step
3. Verify `create-installer-package.ps1` is working locally
4. Ensure all required files exist in expected locations

### Artifact Not Found

1. Build must complete successfully
2. Check **Actions → Latest Run → Artifacts** section
3. Artifact available for 90 days after creation

### Release Not Created

1. Push must be to `main` branch
2. Event type must be `push` (not pull request)
3. Check release tag `installer-{number}` already exists

## Security

- **Secrets:** Uses default `GITHUB_TOKEN` (no extra configuration needed)
- **Permissions:** Workflow runs with minimal required permissions
- **Artifact Access:** Same as repository visibility (public/private)

## Future Enhancements

Possible improvements:

- Sign ZIP packages with certificate
- Add changelog automation
- Generate checksums/hashes
- Notify on build completion
- Deploy to external storage (S3, blob storage, etc.)
- Create pre-release versions

---

**Last Updated:** 2025-11-28  
**Workflow File:** `.github/workflows/publish-installer.yml`

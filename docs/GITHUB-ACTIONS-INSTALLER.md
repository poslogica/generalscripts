# GitHub Actions - Installer Distribution

This document explains how the Winget Updater installer is automatically built and published.

## Automated Publishing Workflow

The repository includes a GitHub Actions workflow that **automatically builds and publishes** the Winget Updater installer package.

**File:** `.github/workflows/publish-installer.yml`

## Workflow Features

### ✅ Automatic Builds

The workflow triggers automatically when:

- **PowerShell Script Validation** workflow completes successfully
- Manual trigger via "Run workflow" button

This ensures installers are only built after all tests pass.

### ✅ Build Process

1. **Checkout code** from the repository
2. **Get version** from latest GitHub release tag (auto-increment)
3. **Run package builder** (`create-installer-package.ps1`)
4. **Verify** ZIP package was created successfully
5. **Create GitHub Release** with the new version tag
6. **Upload artifact** to GitHub Actions

### ✅ Artifact Publishing

- **Name:** `winget-updater-setup-v{version}` (e.g., `winget-updater-setup-v1.0.5`)
- **Content:** ZIP file with all installer components
- **Retention:** 90 days
- **Access:** Available in Actions run summary

### ✅ GitHub Release Creation

Every successful build:

- **Creates a release** with semantic version tag (e.g., `v1.0.5`)
- **Auto-increments** patch version from previous release
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

### Automatic (After Validation)

```yaml
on:
  workflow_run:
    workflows: ["PowerShell Script Validation"]
    types:
      - completed
```

The installer workflow **only runs** after PowerShell validation succeeds.

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
├── uninstall-winget-updater.ps1
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

Releases use **semantic versioning** format: `v{MAJOR}.{MINOR}.{PATCH}`

Examples:

- `v1.0.0` - Initial release
- `v1.0.1` - First patch (auto-incremented)
- `v1.1.0` - Minor version bump
- `v2.0.0` - Major version bump

Patch versions are automatically incremented. Major/minor versions require manual release creation.

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

1. Check workflow has `contents: write` permission
2. Verify `GITHUB_TOKEN` is available
3. Check if release tag already exists (duplicate version)
4. Review "Create GitHub Release" step logs

## Workflow Orchestration Chain

This repository uses GitHub Actions workflows that are **chained together** for comprehensive automation:

### 1️⃣ PowerShell Script Validation (Trigger)

**File:** `.github/workflows/powershell-validation.yml`

- Runs when code is pushed to `main`/`develop`
- **Validates:**
  - PSScriptAnalyzer static code analysis
  - PowerShell syntax validation
  - Pester test suite (150+ tests)
  - Test results upload

**Status:** Must **succeed** for dependent workflows to run

### 2️⃣ Build and Publish Winget Updater Installer (Triggered)

**File:** `.github/workflows/publish-installer.yml`

- **Triggers after:** PowerShell Script Validation completes **successfully**
- Builds the installer ZIP package
- Publishes as GitHub Actions artifact (90-day retention)
- Creates GitHub Release (on `main` branch)

**Depends on:** PowerShell Script Validation success

### 3️⃣ Generate Change Logs (Triggered)

**File:** `.github/workflows/generate_change_logs.yml`

- **Triggers after:** PowerShell Script Validation completes **successfully**
- Fetches commit history from GitHub API
- Generates `changelog.txt` and `changelog.md`
- Commits and pushes updated changelogs to repository

**Depends on:** PowerShell Script Validation success

### Workflow Dependency Diagram

```text
Push to main
    ↓
PowerShell Script Validation
    ├─→ Passes ✅
    │   ├→ Build and Publish Installer
    │   └→ Generate Change Logs
    │
    └─→ Fails ❌
        └→ Dependent workflows don't run
```

### Key Points

- **Sequential on validation:** Both installer and changelog workflows wait for validation to complete
- **Independent execution:** Installer build and changelog generation run in parallel (not dependent on each other)
- **Failure handling:** If validation fails, dependent workflows are skipped
- **Manual override:** All workflows can be manually triggered via "Run workflow" button

## Security

- **Secrets:** Uses default `GITHUB_TOKEN` (no extra configuration needed)
- **Permissions:** Workflows run with minimal required permissions
- **Artifact Access:** Same as repository visibility (public/private)

## Future Enhancements

Possible improvements:

- Sign ZIP packages with certificate
- Generate checksums/hashes
- Notify on build completion
- Deploy to external storage (S3, blob storage, etc.)
- Create pre-release versions

---

**Last Updated:** 2025-11-29  
**Workflow File:** `.github/workflows/publish-installer.yml`

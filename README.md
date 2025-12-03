# IT Automation Scripts

> A collection of production-ready PowerShell scripts for IT automation, system administration, and Windows package management.

## Overview

This repository contains a collection of scripts designed to help IT professionals automate routine tasks. These scripts are written to save time, increase efficiency, and reduce the chances of human error when managing IT operations. All scripts are tested with comprehensive Pester test suites and code coverage analysis.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
- [Testing](#testing)
- [CI/CD Integration](#cicd-integration)
- [Documentation](#documentation)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

### Required

- **Windows 10/11** or **Windows Server 2019+**
- **PowerShell 7+** (pwsh.exe) - Required for installer; 5.1+ for main scripts
- **Winget** (Windows Package Manager) - for patching scripts
- Administrator privileges (for elevation-required tasks)

### Optional

- **Pester 5.7.1+** (for running tests locally)
- Any specific modules required by individual scripts (mentioned in script documentation)

## Installation

### Quick Start: Winget Updater Suite

For automated Windows Package Manager updates, the **Winget Updater** suite can be installed with a single command:

#### Option 1: Automated Installation (Recommended)

1. Download `winget-updater-setup.zip` from the [Releases](https://github.com/poslogica/generalscripts/releases)
2. Extract the ZIP file
3. Right-click `install-winget-updater.bat` → **Run as administrator**
4. Follow the installation prompts

**Note:** The installer is automatically built and published by GitHub Actions. Updates are available on the [Releases](https://github.com/poslogica/generalscripts/releases) page. See [docs/GITHUB-ACTIONS-INSTALLER.md](docs/GITHUB-ACTIONS-INSTALLER.md) for more details.

#### Option 2: PowerShell Installation

```powershell
# As Administrator (use PowerShell 7+, not Windows PowerShell)
pwsh -ExecutionPolicy Bypass -File ".\install-winget-updater.ps1" -ScheduleFrequency Weekly -ScheduleTime "02:00"
```

**Important:** The installer requires **PowerShell 7+** (pwsh.exe), not Windows PowerShell 5.1. If you don't have PowerShell 7 installed, use Option 1 (batch file) which handles this automatically.

#### Option 3: Clone and Explore

For manual script usage or development:

### Clone the Repository

```bash
git clone https://github.com/poslogica/generalscripts.git
cd generalscripts
```

### Review Documentation

Each script includes inline help and documentation. View help for any PowerShell script:

```powershell
Get-Help .\scripts\windows\patching\update-third-party-with-winget.ps1 -Full
```

## Usage

### PowerShell Scripts

All scripts in this repository are PowerShell scripts. Execute them as follows:

```powershell
# From the repository root
.\scripts\windows\patching\update-third-party-with-winget.ps1 -Verbose

# With specific parameters
.\scripts\windows\patching\update-third-party-with-winget.ps1 -ConfigPath "./winget-config.json" -WhatIf

# View available parameters
Get-Help .\scripts\windows\patching\update-third-party-with-winget.ps1
```

### Execution Policy

If you encounter execution policy errors, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Scripts Overview

### Windows Scripts

#### File Management

- **get-duplicate-files-with-progress.ps1** - Identifies duplicate files by hash with real-time progress tracking
  - Location: `scripts/windows/file/`
  - Usage: `./get-duplicate-files-with-progress.ps1 -Path "C:\target-directory"`

#### Patching & Updates

- **[update-third-party-with-winget.ps1](./scripts/windows/patching/update-third-party-with-winget.md)** - Modern approach using winget package manager
  - Location: `scripts/windows/patching/`
  - Recommended for current Windows environments
  - Supports JSON-based configuration and filtering
  - Usage: `./update-third-party-with-winget.ps1 -ConfigPath "winget-config.json"`

- **[update-third-party-with-winget-examples.ps1](./scripts/windows/patching/)** - Example implementations and scenarios
  - Reference and example usage for update-third-party-with-winget.ps1

- **[update-winget-packages.ps1](./scripts/windows/patching/)** - Wrapper script for winget package updates
  - Simplified interface for package updates

- **[update-winget-packages-create-start-menu-shortcut.ps1](./scripts/windows/patching/)** - Creates Start Menu shortcuts for winget packages
  - Utility for creating Windows Start Menu shortcuts

- **[update-winget-packages.bat](./scripts/windows/patching/)** - Batch file wrapper
  - Alternative batch file implementation for Windows Task Scheduler integration

#### Container Management

- **[Podman Resource Management](./scripts/windows/podman/resource.md)** - Documentation for Podman resource configuration
  - Location: `scripts/windows/podman/`

For detailed documentation on each script, please refer to the respective script files in the `/scripts` directory.

## Testing

This repository includes comprehensive test coverage using **Pester 5.7.1**. Tests validate script syntax, parameters, and functionality.

### Run Tests Locally

```powershell
# Run all tests
.\tests\windows\run-tests.ps1

# Run with verbose output
.\tests\windows\run-tests.ps1 -Verbose

# Disable coverage reporting
.\tests\windows\run-tests.ps1 -CoverageReport $false
```

### Test Results

- **Total Tests**: 254
- **Test Files**: 7
- **Coverage Format**: JaCoCo XML with per-file breakdown
- **CI/CD Integration**: Automated tests run on every push via GitHub Actions

### Current Test Coverage

- **Script Tests**:
  - `get-duplicate-files-with-progress.ps1`: 32 tests
  - `update-winget-packages.ps1`: 30 tests
  - `update-third-party-with-winget.ps1`: 42 tests
  - `update-winget-packages-create-start-menu-shortcut.ps1`: 46 tests

- **Installer Tests**:
  - `install-winget-updater.ps1`: 35 tests
  - `uninstall-winget-updater.ps1`: 35 tests
  - `create-installer-package.ps1`: 34 tests

**Total**: 254 tests

## CI/CD Integration

### GitHub Actions Workflow

This repository includes automated validation via `.github/workflows/powershell-validation.yml`:

- **PSScriptAnalyzer**: Static code analysis on every push
- **Syntax Validation**: Ensures all scripts have valid PowerShell syntax
- **Pester Tests**: Runs 254 comprehensive tests
- **Code Coverage**: Generates JaCoCo XML coverage reports
- **Artifacts**: Test results uploaded as GitHub artifacts for 30 days

**Status**: Tests run on `main` and `develop` branches, and on pull requests.

### Artifact Access

Download test results from GitHub Actions:

1. Go to the workflow run
2. Scroll to "Artifacts" section
3. Download `test-results` (NUnit XML)

- Always review script documentation and examples before execution
- Test scripts in a non-production environment first
- Keep scripts and configurations synchronized across your organization
- Monitor script logs for troubleshooting and auditing purposes

## CI/CD & Automation

This repository is configured for GitHub. Workflows and CI/CD pipelines can be added via `.github/workflows/` for automated testing and deployment.

## Documentation

Comprehensive documentation is available in the `/docs` directory:

### Key Documents

- **[FAQ-TROUBLESHOOTING.md](docs/FAQ-TROUBLESHOOTING.md)** - Frequently asked questions and solutions for common issues
  - Installation troubleshooting (execution policy, PowerShell, winget)
  - Scheduled task issues and verification
  - Auto-update configuration and issues
  - Start Menu shortcuts troubleshooting
  - General questions and best practices

- **[AUTO-UPDATE-GUIDE.md](docs/AUTO-UPDATE-GUIDE.md)** - Comprehensive guide to the auto-update feature
  - Quick start and configuration options
  - Manual control of updates
  - Schedule management and customization
  - GitHub API rate limiting details
  - Rollback procedures and troubleshooting

- **[GITHUB-ACTIONS-INSTALLER.md](docs/GITHUB-ACTIONS-INSTALLER.md)** - Complete guide to the automated installer build and publishing workflow
  - Explains workflow triggers and dependencies
  - Shows how to access built installers
  - Documents the workflow orchestration chain
  
- **[VERSION-MANAGEMENT.md](docs/VERSION-MANAGEMENT.md)** - Semantic versioning system documentation
  - Version file location and format
  - How versions are applied to releases
  - Release tagging conventions

## Changelog

All notable changes to this project are documented in the [changelog.md](changelog.md) file. This file is automatically generated from commit history and updated after each successful validation run.

**Note:** Changelog is generated automatically by GitHub Actions. For a detailed history of commits, see the [git commit log](https://github.com/poslogica/generalscripts/commits/main).

## Contributing

We welcome contributions to enhance the functionality and scope of these scripts.

### Contribution Process

1. **Fork** the repository

2. **Create a feature branch**:

   ```bash
   git checkout -b feature/description
   ```

3. **Make your changes** and ensure:
   - All tests pass locally: `./tests/windows/run-tests.ps1`
   - Scripts follow PSScriptAnalyzer best practices
   - Code is documented with help comments

4. **Commit with descriptive messages**:

   ```bash
   git commit -m "feat: description of changes"
   ```

5. **Push and submit a pull request**

### Code Quality Requirements

- ✅ PSScriptAnalyzer: 0 warnings
- ✅ All tests passing (254/254)
- ✅ Help documentation in script comments
- ✅ Parameter validation
- ✅ Error handling with try-catch

## License

This repository is licensed under the [MIT License](LICENSE).

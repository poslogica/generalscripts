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
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

### Required

- **Windows 10/11** or **Windows Server 2019+**
- **PowerShell 5.1+** (included with Windows; PowerShell 7.x also supported)
- **Winget** (Windows Package Manager) - for patching scripts
- Administrator privileges (for elevation-required tasks)

### Optional

- **Pester 5.7.1+** (for running tests locally)
- Any specific modules required by individual scripts (mentioned in script documentation)

## Installation

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

- **[patch-software-windows.ps1](./scripts/windows/patching/patch-software-windows.md)** - Legacy patching method *(deprecated)*
  - Maintained for backward compatibility

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

- **Total Tests**: 149
- **Test Files**: 4
- **Coverage Format**: JaCoCo XML with per-file breakdown
- **CI/CD Integration**: Automated tests run on every push via GitHub Actions

### Current Test Coverage

- **Test Breakdown**:
  - `get-duplicate-files-with-progress.ps1`: 32 tests
  - `update-winget-packages.ps1`: 30 tests
  - `update-third-party-with-winget.ps1`: 42 tests
  - `patch-software-windows.ps1`: 45 tests

## CI/CD Integration

### GitHub Actions Workflow

This repository includes automated validation via `.github/workflows/powershell-validation.yml`:

- **PSScriptAnalyzer**: Static code analysis on every push
- **Syntax Validation**: Ensures all scripts have valid PowerShell syntax
- **Pester Tests**: Runs 149 comprehensive tests
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

## Contributing

We welcome contributions to enhance the functionality and scope of these scripts.

### Contribution Process

1. **Fork** the repository
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/description
   ```
3. **Make your changes** and ensure:
   - All tests pass locally: `.\tests\windows\run-tests.ps1`
   - Scripts follow PSScriptAnalyzer best practices
   - Code is documented with help comments
4. **Commit with descriptive messages**:
   ```bash
   git commit -m "feat: description of changes"
   ```
5. **Push and submit a pull request**

### Code Quality Requirements

- ✅ PSScriptAnalyzer: 0 warnings
- ✅ All tests passing (149/149)
- ✅ Help documentation in script comments
- ✅ Parameter validation
- ✅ Error handling with try-catch

## License

This repository is licensed under the [MIT License](LICENSE).

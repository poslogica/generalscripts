# Contributing to generalscripts

Thank you for your interest in contributing! This document outlines guidelines for contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Commit Message Conventions](#commit-message-conventions)
- [Code Quality Standards](#code-quality-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)

## Getting Started

### Prerequisites

- Windows 10/11 or Windows Server 2019+
- PowerShell 7+ (pwsh.exe)
- Git
- Pester 5.7.1+

### Development Setup

1. Fork and clone the repository:

```powershell
git clone https://github.com/yourusername/generalscripts.git
cd generalscripts
```

1. Create a feature branch:

```powershell
git checkout -b feature/your-feature-name
```

1. Run tests locally:

```powershell
Invoke-Pester -Output Minimal
```

## Commit Message Conventions

This project uses **Conventional Commits** format. This enables automatic changelog generation, semantic versioning, and clear history.

### Format

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### Type (Required)

- **feat** - New feature
- **fix** - Bug fix
- **docs** - Documentation changes
- **perf** - Performance improvement
- **refactor** - Code refactoring (no functional change)
- **test** - Test additions or changes
- **chore** - Build, CI/CD, or dependencies

### Scope (Optional)

Specifies the area affected:

- installer
- updater
- shortcuts
- tests
- config
- docs

### Subject (Required)

- Use imperative mood ("add" not "added")
- Do not capitalize first letter
- No period at end
- Limit to 50 characters
- Be descriptive

Good examples:

- `feat: Add View Logs shortcut to IT Automation menu`
- `fix: Correct scheduled task path validation`
- `perf: Optimize large file hashing in tests`

### Body (Optional)

Explain what and why, not how. Wrap at 72 characters. Separate from subject with blank line.

Example:

```text
feat: Add Documentation URL shortcut to IT Automation menu

- Create .url file pointing to GitHub README
- Uses Windows Internet Shortcut format for browser integration
- Automatically creates IT Automation folder if missing
```

### Footer (Optional)

Use for issue references or breaking changes:

```
Closes #45
BREAKING CHANGE: description
```

## Code Quality Standards

### PowerShell Best Practices

- **PSScriptAnalyzer**: Zero warnings required

```powershell
Invoke-ScriptAnalyzer -Path scripts/ -Recurse
```

- **Help Documentation**: All scripts must include:

```powershell
<#
.SYNOPSIS
    Brief description

.DESCRIPTION
    Detailed description

.PARAMETER ParameterName
    Parameter description

.EXAMPLE
    .\Script.ps1 -Parameter value
    Usage example
#>
```

- **Error Handling**: Use `$ErrorActionPreference = 'Stop'` and try-catch blocks
- **Comments**: Explain why, not what
- **Naming**: PascalCase for functions, camelCase for variables

### Script Structure

```powershell
#!/usr/bin/env pwsh
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Description
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$Parameter1
)

$ErrorActionPreference = 'Stop'

# Implementation
```

## Testing Requirements

### Run Tests

```powershell
Invoke-Pester -Output Minimal
```

### Expected Results

- All 259 tests must pass
- No failing tests
- Execution time < 5 seconds

### Writing Tests

Use Pester 5 syntax. Place tests in `tests/windows/` matching script structure.

```powershell
Describe "ScriptName Tests" {
    Context "Parameter Validation" {
        It "Should validate parameter value" {
            # Test implementation
        }
    }
}
```

## Pull Request Process

1. Ensure all tests pass locally
2. Ensure no PSScriptAnalyzer warnings
3. Create PR with commit message convention as title
4. Fill in PR description with changes and testing details
5. Reference any related issues: `Closes #42`

Example PR title: `feat: Add View Logs shortcut to IT Automation menu`

## Versioning

This project uses **Semantic Versioning (MAJOR.MINOR.PATCH)**:

- MAJOR: Breaking changes
- MINOR: New features (feat commits)
- PATCH: Bug fixes (fix commits)

## Questions?

- Check existing issues: [GitHub Issues](https://github.com/poslogica/generalscripts/issues)
- Review recent commits: [Commits](https://github.com/poslogica/generalscripts/commits/main)
- See INSTALL.md for usage details

Thank you for contributing!

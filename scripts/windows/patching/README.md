# Windows Patching & Software Updates

## Overview

This directory contains PowerShell scripts for managing software updates and patching on Windows systems using the Windows Package Manager (winget).

## Scripts

### Active

- **[update-third-party-with-winget.ps1](./update-third-party-with-winget.md)** ✅ **Recommended**
  - Modern approach using winget
  - JSON-based configuration
  - Supports filtering, whitelisting, and blacklisting
  - Auto-retry scope logic
  - Comprehensive logging

- **[update-winget-packages.ps1](./update-winget-packages.ps1)**
  - Wrapper script with auto-elevation and logging
  - Simplified interface for basic package updates

### Legacy

- **[patch-software-windows.ps1](./patch-software-windows.md)** ⚠️ **Deprecated**
  - Legacy patching method
  - Maintained for backward compatibility only
  - **Recommendation**: Migrate to `update-third-party-with-winget.ps1`

## Configuration

See [winget-config.json](./winget-config.json) for configuration examples and [update-third-party-with-winget.md](./update-third-party-with-winget.md) for detailed setup instructions.

## Testing

Each script in this directory has comprehensive test coverage:

```powershell
# Run patching script tests
.\..\..\..\..\tests\windows\run-tests.ps1 -Verbose
```

- `update-winget-packages.ps1`: 30 tests
- `update-third-party-with-winget.ps1`: 42 tests
- `patch-software-windows.ps1`: 45 tests

## Documentation

- [Update-ThirdPartyWithWinget Documentation](./update-third-party-with-winget.md)
- [Patch-SoftwareWindows Documentation](./patch-software-windows.md)

# IT Automation Scripts

## Overview

This repository contains a collection of scripts designed to help IT professionals automate routine tasks. These scripts are written to save time, increase efficiency, and reduce the chances of human error when managing IT operations. They cover a wide range of tasks including system administration, network management, cloud operations, and more.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Scripts Overview](#scripts-overview)
5. [Contributing](#contributing)
6. [License](#license)

## Prerequisites

Before using these scripts, make sure you have the following tools installed:

- [Python 3.x](https://www.python.org/downloads/)
- [Bash](https://www.gnu.org/software/bash/)
- [Powershell](https://docs.microsoft.com/en-us/powershell/)
- Any specific modules required by individual scripts (mentioned in each script's comments or documentation)

## Installation

To get started with these automation scripts:

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/poslogica/generalscripts.git
   ```

2. Navigate to the directory:

   ```bash
   cd generalscripts
   ```

3. Review the README file of each script to understand specific installation steps if required.

## Usage

1. Review the specific usage instructions provided in the comments section of each script.  
2. Make sure to give the appropriate permissions to execute the scripts:

   ```bash
   chmod +x script-name.sh
   ```

3. Execute the script based on its type:
   - **For Python scripts:**

     ```bash
     python3 script-name.py
     ```

   - **For Bash scripts:**

     ```bash
     ./script-name.sh
     ```

   - **For PowerShell scripts (on Windows):**

     ```powershell
     ./script-name.ps1
     ```

4. Many scripts are configurable via command-line arguments. Run the script with the `--help` flag to see the available options:

   ```bash
   python3 script-name.py --help
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

## Best Practices

- Always review script documentation and examples before execution
- Test scripts in a non-production environment first
- Keep scripts and configurations synchronized across your organization
- Monitor script logs for troubleshooting and auditing purposes

## CI/CD & Automation

This repository is configured for GitHub. Workflows and CI/CD pipelines can be added via `.github/workflows/` for automated testing and deployment.

## Contributing

We welcome contributions to enhance the functionality and scope of these scripts. To contribute:

1. Fork the repository.
2. Create a new branch:

   ```bash
   git checkout -b feature-branch-name
   ```

3. Make your changes and commit:

   ```bash
   git commit -m "Description of changes"
   ```

4. Push to your fork and submit a pull request.

## License

This repository is licensed under the [MIT License](LICENSE).

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
   git clone https://bitbucket.org/your-username/your-repository-name.git
   ```

2. Navigate to the directory:

   ```bash
   cd your-repository-name
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

Below is a list of some common scripts included in this repository:

1. **Windows Third-Party Software Patching Script [patch_software_windows](./scripts/windows/patching/patch_software_windows.md)**  
   Automates the process of updating third-party software on computers running the Windows operating system

For detailed documentation on each script, please refer to the respective script files in the `/scripts` directory.

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
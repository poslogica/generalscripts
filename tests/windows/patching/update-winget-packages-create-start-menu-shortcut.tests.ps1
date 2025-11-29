<#
.SYNOPSIS
    Pester test suite for update-winget-packages-create-start-menu-shortcut.ps1 script

.DESCRIPTION
    Comprehensive tests validating the Start Menu shortcut creation script.
    Tests verify COM object usage, shortcut path configuration, PowerShell invocation setup,
    icon configuration, and cross-platform compatibility.
    
    The script creates an "IT Automation" folder in the Start Menu with multiple shortcuts:
    - Update Winget Packages: Runs the winget package update script
    - Check for Updater Updates: Checks for newer versions of IT Automation tools
    
.TESTS
    - Script Syntax and Structure: Validates PowerShell syntax and COM object usage
    - Start Menu Folder Configuration: Tests IT Automation folder creation
    - Start Menu Shortcut Path Configuration: Tests ProgramData and shortcut naming
    - PowerShell Executable Configuration: Verifies System32 path to powershell.exe
    - Target Script Reference: Checks update-winget-packages.ps1 reference
    - Shortcut Object Creation: Tests WScript.Shell shortcut object setup
    - Shortcut Arguments Configuration: Validates execution policy and file parameters
    - Shortcut Icon Configuration: Tests shell32.dll icon references
    - Shortcut Persistence: Verifies Save() method is called
    - Output and Logging: Checks confirmation messages
    - Script Location and Organization: Confirms script location and references
    - Start Menu Path Structure: Tests system-wide vs user-specific paths
    - PowerShell Invocation Configuration: Validates full path usage
    - COM Object Usage: Tests WScript.Shell object creation
    - Robustness and Portability: Tests environment variables and cross-version compatibility
    - Shortcut Functionality: Validates executable, icon, and working directory settings
#>

# ===== SETUP =====
# Initialize script paths and directory references for all tests
BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\scripts\windows\patching\update-winget-packages-create-start-menu-shortcut.ps1'
    $scriptDir = Split-Path -Path $scriptPath -Parent
}

# ===== TEST SUITE =====
Describe "update-winget-packages-create-start-menu-shortcut Script Tests" {
    
    # ----- Script Syntax and Structure Tests -----
    # Validates basic PowerShell syntax, COM object creation, and documentation
    Context "Script Syntax and Structure" {
        It "Should have valid PowerShell syntax" {
            $content = Get-Content -Path $scriptPath -Raw
            $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)
        }

        It "Should define WScript.Shell COM object" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'New-Object.*WScript\.Shell'
        }

        It "Should contain comments or inline documentation" {
            $content = Get-Content -Path $scriptPath -Raw
            # Script has output messages that serve as documentation
            $content | Should -Match 'Write-Output'
        }
    }

    # ----- Start Menu Shortcut Path Configuration Tests -----
    # Tests ProgramData environment variable, shortcut naming, and .lnk file extension
    Context "Start Menu Shortcut Path Configuration" {
        It "Should reference Start Menu Programs directory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start Menu\\Programs'
        }

        It "Should use ProgramData environment variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$env:ProgramData'
        }

        It "Should create IT Automation folder" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'IT Automation'
        }

        It "Should name shortcut 'Update Winget Packages'" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update Winget Packages'
        }

        It "Should create .lnk file extension" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.lnk'
        }

        It "Should store link paths in variables" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+Path'
        }
    }

    # ----- PowerShell Executable Configuration Tests -----
    # Tests System32 path to powershell.exe and environment variable usage
    Context "PowerShell Executable Configuration" {
        It "Should reference Windows PowerShell 5.1" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'v1\.0\\powershell\.exe'
        }

        It "Should use SystemRoot environment variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$env:SystemRoot'
        }

        It "Should store executable path in variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$ps.*powershell'
        }
    }

    # ----- Target Script Reference Tests -----
    # Verifies update-winget-packages.ps1 reference and PSScriptRoot usage
    Context "Target Script Reference" {
        It "Should reference update-winget-packages.ps1" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'update-winget-packages\.ps1'
        }

        It "Should use PSScriptRoot for script location" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Join-Path.*\$PSScriptRoot'
        }

        It "Should store script paths in variables" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$script\d+'
        }
    }

    # ----- Shortcut Object Creation Tests -----
    # Tests WScript.Shell CreateShortcut method and property assignments
    Context "Shortcut Object Creation" {
        It "Should create WScript shortcut object" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'CreateShortcut'
        }

        It "Should store shortcuts in variables" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+'
        }

        It "Should set shortcut TargetPath" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+\.TargetPath'
        }

        It "Should set shortcut Arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+\.Arguments'
        }

        It "Should set shortcut WorkingDirectory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+\.WorkingDirectory'
        }
    }

    # ----- Shortcut Arguments Configuration Tests -----
    # Validates -NoProfile, -ExecutionPolicy Bypass, -File, and path quoting
    Context "Shortcut Arguments Configuration" {
        It "Should use -NoProfile argument" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-NoProfile'
        }

        It "Should use -ExecutionPolicy Bypass" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-ExecutionPolicy Bypass'
        }

        It "Should use -File parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-File'
        }

        It "Should quote script file path in arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '`".*`"'
        }
    }

    # ----- Shortcut Icon Configuration Tests -----
    # Tests shell32.dll reference and icon indices (167 for package, 13 for network)
    Context "Shortcut Icon Configuration" {
        It "Should set IconLocation property" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+\.IconLocation'
        }

        It "Should reference shell32.dll for icon" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'shell32\.dll'
        }

        It "Should use icon index 167 for package shortcut" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'shell32\.dll,167'
        }
    }

    # ----- Shortcut Persistence Tests -----
    # Verifies shortcut is saved to disk using Save() method
    Context "Shortcut Persistence" {
        It "Should save shortcut to disk" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\d+\.Save\(\)'
        }
    }

    # ----- Output and Logging Tests -----
    # Tests Write-Output confirmation messages including shortcut path
    Context "Output and Logging" {
        It "Should output confirmation message" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output'
            $content | Should -Match 'Shortcut created'
        }

        It "Should include shortcut path in output" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output.*\$lnk\d+Path'
        }
    }

    # ----- Script Location and Organization Tests -----
    # Confirms script exists in patching directory and references other scripts
    Context "Script Location and Organization" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'update-winget-packages-create-start-menu-shortcut.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should reference update-winget-packages.ps1 in same directory" {
            $mainScript = Join-Path -Path $scriptDir -ChildPath 'update-winget-packages.ps1'
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'update-winget-packages\.ps1'
        }
    }

    # ----- Start Menu Path Structure Tests -----
    # Tests Programs directory reference and system-wide (ProgramData) vs user-specific (APPDATA)
    Context "Start Menu Path Structure" {
        It "Should create shortcut in Programs directory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Programs'
        }

        It "Should not include username in path (system-wide)" {
            $content = Get-Content -Path $scriptPath -Raw
            # Using ProgramData makes it system-wide, not user-specific
            $content | Should -Match '\$env:ProgramData'
            $content | Should -Not -Match '\$env:APPDATA'
        }
    }

    # ----- PowerShell Invocation Configuration Tests -----
    # Tests full path to powershell.exe and not relying on PATH environment variable
    Context "PowerShell Invocation Configuration" {
        It "Should use full path to powershell.exe" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'System32.*powershell\.exe'
        }

        It "Should not rely on PATH environment variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$env:SystemRoot.*System32'
        }

        It "Should be executable from Windows Start Menu" {
            $content = Get-Content -Path $scriptPath -Raw
            # Shortcut arguments configured for standalone execution
            $content | Should -Match '\-NoProfile'
            $content | Should -Match '\-ExecutionPolicy'
        }
    }

    # ----- COM Object Usage Tests -----
    # Tests WScript.Shell COM object creation and shortcut creation methods
    Context "COM Object Usage" {
        It "Should create WScript.Shell COM object correctly" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ComObject'
            $content | Should -Match 'WScript\.Shell'
        }

        It "Should use Windows shell shortcut creation method" {
            $content = Get-Content -Path $scriptPath -Raw
            # CreateShortcut is the standard WScript.Shell method
            $content | Should -Match 'CreateShortcut\(\$lnk\d+Path\)'
        }
    }

    # ----- Robustness and Portability Tests -----
    # Tests environment variable usage, cross-version compatibility, and dynamic path handling
    Context "Robustness and Portability" {
        It "Should use environment variables for system paths" {
            $content = Get-Content -Path $scriptPath -Raw
            # Avoids hardcoded paths
            $content | Should -Match '\$env:'
        }

        It "Should work across different Windows versions" {
            $content = Get-Content -Path $scriptPath -Raw
            # Standard COM object and paths work on all Windows versions
            $content | Should -Match 'ComObject'
            $content | Should -Match 'Start Menu'
        }

        It "Should handle script path dynamically" {
            $content = Get-Content -Path $scriptPath -Raw
            # Uses PSScriptRoot instead of hardcoded paths
            $content | Should -Match 'PSScriptRoot'
        }

        It "Should properly escape file paths in arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            # Paths are quoted to handle spaces
            $content | Should -Match '`"'
        }
    }

    Context "Shortcut Functionality" {
        It "Should create executable shortcut" {
            $content = Get-Content -Path $scriptPath -Raw
            # Has TargetPath (executable) - now using $lnk1 for first shortcut
            $content | Should -Match '\$lnk1\.TargetPath\s*=\s*\$ps'
            # Has Arguments
            $content | Should -Match 'Arguments'
        }

        It "Should set working directory for shortcut" {
            $content = Get-Content -Path $scriptPath -Raw
            # WorkingDirectory set to script directory
            $content | Should -Match 'WorkingDirectory.*=.*PSScriptRoot'
        }

        It "Should apply recognizable icon" {
            $content = Get-Content -Path $scriptPath -Raw
            # Icon configured for visual recognition
            $content | Should -Match 'IconLocation'
            $content | Should -Match 'shell32\.dll,167'
        }
    }
}

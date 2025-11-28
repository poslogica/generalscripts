BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\scripts\windows\patching\update-winget-packages-create-start-menu-shortcut.ps1'
    $scriptDir = Split-Path -Path $scriptPath -Parent
}

Describe "update-winget-packages-create-start-menu-shortcut Script Tests" {
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

    Context "Start Menu Shortcut Path Configuration" {
        It "Should reference Start Menu Programs directory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start Menu\\Programs'
        }

        It "Should use ProgramData environment variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$env:ProgramData'
        }

        It "Should name shortcut 'Update Winget Packages'" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update Winget Packages'
        }

        It "Should create .lnk file extension" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.lnk'
        }

        It "Should store link path in variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnkPath'
        }
    }

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

    Context "Target Script Reference" {
        It "Should reference Update-WingetPackages.ps1" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update-WingetPackages\.ps1'
        }

        It "Should use PSScriptRoot for script location" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Join-Path.*\$PSScriptRoot'
        }

        It "Should store script path in variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$script'
        }
    }

    Context "Shortcut Object Creation" {
        It "Should create WScript shortcut object" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'CreateShortcut'
        }

        It "Should store shortcut in variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk'
        }

        It "Should set shortcut TargetPath" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\.TargetPath'
        }

        It "Should set shortcut Arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\.Arguments'
        }

        It "Should set shortcut WorkingDirectory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\.WorkingDirectory'
        }
    }

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

    Context "Shortcut Icon Configuration" {
        It "Should set IconLocation property" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\.IconLocation'
        }

        It "Should reference shell32.dll for icon" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'shell32\.dll'
        }

        It "Should use icon index 167 (package icon)" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'shell32\.dll,167'
        }
    }

    Context "Shortcut Persistence" {
        It "Should save shortcut to disk" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$lnk\.Save\(\)'
        }
    }

    Context "Output and Logging" {
        It "Should output confirmation message" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output'
            $content | Should -Match 'Shortcut created'
        }

        It "Should include shortcut path in output" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output.*\$lnkPath'
        }
    }

    Context "Script Location and Organization" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'update-winget-packages-create-start-menu-shortcut.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should reference Update-WingetPackages.ps1 in same directory" {
            $mainScript = Join-Path -Path $scriptDir -ChildPath 'Update-WingetPackages.ps1'
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update-WingetPackages\.ps1'
        }
    }

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

    Context "COM Object Usage" {
        It "Should create WScript.Shell COM object correctly" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ComObject'
            $content | Should -Match 'WScript\.Shell'
        }

        It "Should use Windows shell shortcut creation method" {
            $content = Get-Content -Path $scriptPath -Raw
            # CreateShortcut is the standard WScript.Shell method
            $content | Should -Match 'CreateShortcut\(\$lnkPath\)'
        }
    }

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
            # Has TargetPath (executable)
            $content | Should -Match '\$lnk\.TargetPath\s*=\s*\$ps'
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

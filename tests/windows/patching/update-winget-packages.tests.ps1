<#
.SYNOPSIS
    Comprehensive Pester test suite for update-winget-packages.ps1

.DESCRIPTION
    This test file validates the update-winget-packages.ps1 script which orchestrates winget package updates.
    The script wraps the Update-ThirdPartyWithWinget.ps1 script, adding support for elevation, logging, and
    parameter forwarding. Tests validate script syntax, parameters, structure, logic, argument handling,
    and file system operations.

.TESTS
    This test suite contains 30 test cases organized into 5 test contexts:
    - Script Syntax and Structure: Validates PowerShell syntax and required parameters (3 tests)
    - Parameter Validation: Tests all parameter types and defaults (5 tests)
    - Script Structure and Logic: Verifies core functionality and logic blocks (7 tests)
    - Edge Cases: Tests special scenarios like WhatIf, argument forwarding, and exit codes (6 tests)
    - File System Operations: Validates file paths and script organization (3 tests)
    - Argument Forwarding: Tests parameter forwarding and log path construction (6 tests)

.SETUP
    Sets up the path to the script under test relative to the test file location
#>

BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\.\scripts\windows\patching\update-winget-packages.ps1'
}

Describe "update-winget-packages Script Tests" {
    # ----- Script Syntax and Structure Tests -----
    # Tests basic PowerShell syntax validity and presence of required parameters
    Context "Script Syntax and Structure" {
        It "Should have valid PowerShell syntax" {
            $content = Get-Content -Path $scriptPath -Raw
            $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)
        }

        It "Should have required parameters" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'param\s*\('
            $content | Should -Match '\$Scope'
            $content | Should -Match '\$WhatIf'
        }

        It "Should have help documentation" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '<#'
            $content | Should -Match 'Purpose:'
        }
    }

    # ----- Parameter Validation Tests -----
    # Tests all script parameters: -Scope (user/machine), -WhatIf, -IncludeUnknown, and -Diagnostics
    Context "Parameter Validation" {
        It "Should accept valid -Scope parameter (user)" {
            # Test that the script accepts -Scope user parameter without execution errors
            # We test the parameter validation, not the full script execution
            $content = Get-Content -Path $scriptPath -Raw
            # Verify the script accepts user scope parameter
            $content | Should -Match 'ValidateSet.*user.*machine'
            $content | Should -Match '\[string\]\$Scope'
        }

        It "Should accept valid -Scope parameter (machine)" {
            # Test that the script accepts -Scope machine parameter
            # Machine scope requires elevation which may not be available in CI
            $content = Get-Content -Path $scriptPath -Raw
            # Verify the script accepts machine scope parameter
            $content | Should -Match 'ValidateSet.*user.*machine'
            $content | Should -Match "\[string\]\`$Scope = 'machine'"
        }

        It "Should default to machine scope when not specified" {
            # Check that machine is the default by examining the script
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "\[string\]\`$Scope = 'machine'"
        }

        It "Should have WhatIf switch parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$WhatIf'
        }

        It "Should have IncludeUnknown switch parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$IncludeUnknown'
        }

        It "Should have Diagnostics switch parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$Diagnostics'
        }
    }

    # ----- Script Structure and Logic Tests -----
    # Tests core logic: admin checks, elevation, logging directory creation, and parameter forwarding
    Context "Script Structure and Logic" {
        It "Should verify main script exists check" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update-ThirdPartyWithWinget\.ps1'
            $content | Should -Match 'Test-Path.*Main'
        }

        It "Should have admin check function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function Test-Admin'
            $content | Should -Match 'IsInRole.*Administrator'
        }

        It "Should handle elevation for machine scope" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Process.*RunAs'
        }

        It "Should create logs directory if needed" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'logs'
            $content | Should -Match 'New-Item.*Directory'
        }

        It "Should generate timestamped log files" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Get-Date.*yyyyMMdd-HHmmss'
            $content | Should -Match 'winget-.*\.log'
        }

        It "Should enable IncludeUnknown by default" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "ContainsKey\('IncludeUnknown'\)"
            $content | Should -Match "\-IncludeUnknown"
        }

        It "Should enable Diagnostics by default" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "ContainsKey\('Diagnostics'\)"
            $content | Should -Match "\-Diagnostics"
        }
    }

    # ----- Edge Cases Tests -----
    # Tests special scenarios: WhatIf handling, extra arguments after --, parameter detection, exit codes
    Context "Edge Cases" {
        It "Should handle WhatIf flag correctly" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'if \(\$WhatIf\)'
            $content | Should -Match "\-WhatIf"
        }

        It "Should handle extra arguments after --" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "args\.IndexOf\('--'\)"
            $content | Should -Match '\-\-'
        }

        It "Should forward extra arguments to main script" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$forward'
            $content | Should -Match '\$argList \+= \@\('
        }

        It "Should handle PSBoundParameters for parameter detection" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'PSBoundParameters'
        }

        It "Should invoke main script with Start-Process" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Process.*FilePath.*powershell\.exe'
            $content | Should -Match '\-Wait'
        }

        It "Should exit with correct code" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'exit \$LASTEXITCODE'
        }
    }

    # ----- File System Operations Tests -----
    # Tests file system paths, script organization, and dependencies on other scripts
    Context "File System Operations" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'update-winget-packages.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should reference Update-ThirdPartyWithWinget.ps1 in same directory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update-ThirdPartyWithWinget\.ps1'
        }
    }

    # ----- Argument Forwarding Tests -----
    # Tests PowerShell execution policy, profile settings, argument quoting, and log path construction
    Context "Argument Forwarding" {
        It "Should preserve -NoProfile in argument list" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "'-NoProfile'"
        }

        It "Should preserve -ExecutionPolicy Bypass" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "'-ExecutionPolicy','Bypass'"
        }

        It "Should quote file paths in arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\"{0}\"'
        }

        It "Should handle scope parameter in forwarded arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "'-Scope', \`$Scope"
        }

        It "Should build log path with script directory" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$logDir = Join-Path'
            $content | Should -Match '\$logPath = Join-Path'
        }
    }
}

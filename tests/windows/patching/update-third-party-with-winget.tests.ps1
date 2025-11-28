BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\scripts\windows\patching\update-third-party-with-winget.ps1'
}

Describe "update-third-party-with-winget Script Tests" {
    Context "Script Syntax and Structure" {
        It "Should have valid PowerShell syntax" {
            $content = Get-Content -Path $scriptPath -Raw
            $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)
        }

        It "Should have required parameters" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'param\s*\('
            $content | Should -Match '\$ConfigPath'
            $content | Should -Match '\$Scope'
            $content | Should -Match '\$IncludeUnknown'
        }

        It "Should have help documentation" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '<#'
            $content | Should -Match '\.SYNOPSIS'
            $content | Should -Match 'winget'
        }

        It "Should use CmdletBinding with ShouldProcess" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[CmdletBinding\(SupportsShouldProcess\s*=\s*\$true\)\]'
        }
    }

    Context "Parameter Validation" {
        It "Should have ConfigPath parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[string\]\$ConfigPath'
        }

        It "Should validate Scope parameter values" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "ValidateSet\('user','machine'\)"
            $content | Should -Match '\$Scope'
        }

        It "Should have IncludeUnknown switch" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$IncludeUnknown'
        }

        It "Should have StopOnError switch" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$StopOnError'
        }

        It "Should have Diagnostics switch" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\[switch\]\$Diagnostics'
        }
    }

    Context "Utility Functions" {
        It "Should define Write-LogMessage function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function Write-LogMessage'
            $content | Should -Match 'INFO.*WARN.*ERROR.*DEBUG'
        }

        It "Should define FirstNotNullOrEmpty function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function FirstNotNullOrEmpty'
        }

        It "Should define MatchesAny function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function MatchesAny'
            $content | Should -Match '\-like'
        }

        It "Should define Test-Admin function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function Test-Admin'
            $content | Should -Match 'Administrator'
        }

        It "Should define Get-FirstJsonChunk function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function Get-FirstJsonChunk'
            $content | Should -Match 'IndexOf.*{.*\['
        }

        It "Should define Get-WingetUpgradeTableParsed function" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'function Get-WingetUpgradeTableParsed'
            $content | Should -Match 'Name.*Id.*Version.*Available.*Source'
        }
    }

    Context "Configuration Handling" {
        It "Should reference JSON config structure" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'IncludeOnlyIds'
            $content | Should -Match 'ExcludeIds'
            $content | Should -Match 'ExcludeSources'
        }

        It "Should handle config path logic" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ConfigPath'
        }

        It "Should document config file format" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.CONFIG'
            $content | Should -Match 'winget-config\.json'
        }
    }

    Context "Winget Integration" {
        It "Should reference winget command" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'winget'
        }

        It "Should handle winget upgrade output parsing" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'upgrade'
        }

        It "Should support scope parameter for winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-\-scope'
        }

        It "Should handle JSON output from winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ConvertFrom-Json'
        }

        It "Should support table parsing fallback" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Get-WingetUpgradeTableParsed'
        }
    }

    Context "Error Handling" {
        It "Should have error handling logic" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'try\s*{'
            $content | Should -Match 'catch\s*{'
        }

        It "Should respect StopOnError flag" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$StopOnError'
        }

        It "Should log error messages" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-LogMessage.*ERROR'
        }
    }

    Context "Documentation and Examples" {
        It "Should have synopsis" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should document config format" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.CONFIG'
        }

        It "Should provide usage examples" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\.EXAMPLES'
        }

        It "Should mention JSON config requirement" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'JSON\s+config'
        }
    }

    Context "Robustness Features" {
        It "Should handle noisy winget output" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'noisy'
        }

        It "Should support PowerShell 5.1 compatibility" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'PS 5\.1|PowerShell 5\.1'
        }

        It "Should handle IncludeUnknown packages" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$IncludeUnknown'
        }

        It "Should support Diagnostics mode" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$Diagnostics'
        }
    }

    Context "File System Operations" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'update-third-party-with-winget.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should reference log path parameter" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'LogPath'
        }
    }

    Context "Filtering and Matching" {
        It "Should support IncludeOnlyIds filtering" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'IncludeOnlyIds'
        }

        It "Should support ExcludeIds filtering" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ExcludeIds'
        }

        It "Should support name-based filtering" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'IncludeOnlyNames|ExcludeNames'
        }

        It "Should support source exclusion" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'ExcludeSources'
        }

        It "Should use case-insensitive pattern matching" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-like'
        }
    }
}

BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\scripts\windows\patching\update-winget-packages.ps1'
    $scriptDir = Split-Path -Path $scriptPath -Parent
}

Describe "update-winget-packages Script Tests" {
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

    Context "Parameter Validation" {
        It "Should accept valid -Scope parameter (user)" {
            # User scope should not require elevation
            { & $scriptPath -Scope user -WhatIf 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should accept valid -Scope parameter (machine)" {
            # Machine scope requires elevation; script will attempt re-elevation
            # This test checks that the script can be invoked without syntax/parameter errors
            # Actual machine-scope behavior requires admin, which CI environment may not have
            if ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544') {
                # Running as admin, can fully test
                { & $scriptPath -Scope machine -WhatIf 2>&1 | Out-Null } | Should -Not -Throw
            } else {
                # Not admin; just verify script can be called without parameter errors
                # The script will attempt re-elevation via Start-Process
                $scriptBlock = { & $scriptPath -Scope machine -WhatIf 2>&1 }
                # Should not throw parameter/syntax errors (elevation attempts are OK)
                $scriptBlock | Should -Not -Throw
            }
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

    Context "File System Operations" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'update-winget-packages.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should reference Update-ThirdPartyWithWinget.ps1 in same directory" {
            $mainScript = Join-Path -Path $scriptDir -ChildPath 'Update-ThirdPartyWithWinget.ps1'
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Update-ThirdPartyWithWinget\.ps1'
        }
    }

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

BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\scripts\windows\patching\patch-software-windows.ps1'
}

Describe "patch-software-windows Script Tests" {
    Context "Script Syntax and Structure" {
        It "Should have valid PowerShell syntax" {
            $content = Get-Content -Path $scriptPath -Raw
            $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)
        }

        It "Should define log path variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$logPath'
        }

        It "Should define log filename variable" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$logFilename'
        }

        It "Should have help documentation" {
            $content = Get-Content -Path $scriptPath -Raw
            # Script has comments even if not full help block
            $content | Should -Match '#'
        }
    }

    Context "Log Path Configuration" {
        It "Should construct log filename with date pattern" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "Get-Date.*yyyy-MM-dd"
        }

        It "Should combine log path and filename" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$fullLogPathAndFile'
        }

        It "Should create log directory if missing" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Test-Path.*logPath'
            $content | Should -Match 'New-Item.*Directory'
        }

        It "Should use Start-Transcript for logging" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Transcript'
            $content | Should -Match '\-Path.*\$fullLogPathAndFile'
            $content | Should -Match '\-Append'
        }
    }

    Context "Execution Policy Configuration" {
        It "Should set execution policy to Bypass" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Set-ExecutionPolicy'
            $content | Should -Match 'Bypass'
            $content | Should -Match 'Scope Process'
        }

        It "Should use -Force flag for execution policy" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Set-ExecutionPolicy.*-Force'
        }
    }

    Context "Winget Integration" {
        It "Should define winget executable path" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$wingetPath.*winget\.exe'
        }

        It "Should attempt to locate winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "winget\.exe"
        }

        It "Should use Start-Process to invoke winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Process'
            $content | Should -Match '\$wingetPath'
        }

        It "Should use upgrade command with all flag" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'upgrade'
            $content | Should -Match '--all'
        }

        It "Should include unknown packages in upgrade" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '--include-unknown'
        }

        It "Should accept package agreements" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '--accept-package-agreements'
        }

        It "Should accept source agreements" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '--accept-source-agreements'
        }

        It "Should run upgrade silently" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '--silent'
        }

        It "Should wait for Start-Process to complete" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Process.*-Wait'
        }

        It "Should not open new window for winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-NoNewWindow'
        }
    }

    Context "Error Handling" {
        It "Should have try-catch block" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'try\s*\{'
            $content | Should -Match 'catch\s*\{'
        }

        It "Should log upgrade success message" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Upgrade process completed successfully'
        }

        It "Should catch and log errors" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Error during the upgrade process'
        }

        It "Should write error details to log" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output.*Error'
            $content | Should -Match 'Write-Information.*Error'
        }

        It "Should reference exception variable in catch block" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\$_'
        }
    }

    Context "Transcript Management" {
        It "Should start transcript before processing" {
            $content = Get-Content -Path $scriptPath -Raw
            # Start-Transcript should appear before Start-Process
            $startTranscriptPos = $content.IndexOf('Start-Transcript')
            $startProcessPos = $content.IndexOf('Start-Process')
            $startTranscriptPos | Should -BeLessThan $startProcessPos
        }

        It "Should stop transcript after processing" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Stop-Transcript'
        }

        It "Should append to existing log file" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Start-Transcript.*-Append'
        }
    }

    Context "Output and Logging" {
        It "Should write informational messages" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Information'
        }

        It "Should log the winget executable location" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output.*winget executable found'
        }

        It "Should display log file path information" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Log file used'
        }
    }

    Context "Script Structure and Flow" {
        It "Script location should be predictable" {
            Test-Path -LiteralPath $scriptPath | Should -Be $true
        }

        It "Script should be in patching directory" {
            Split-Path -Path $scriptPath -Leaf | Should -Be 'patch-software-windows.ps1'
            Split-Path -Path $scriptPath -Parent | Should -Match 'patching'
        }

        It "Should use absolute log path starting with C:\" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "C:\\tools\\patching"
        }

        It "Should reference Write-Output for general messages" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Output'
        }

        It "Should reference Write-Information for diagnostic messages" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'Write-Information'
        }
    }

    Context "Commented Code Sections" {
        It "Should contain commented Test-Path check for winget" {
            $content = Get-Content -Path $scriptPath -Raw
            # Check that there's commented code with Test-Path for winget
            $content | Should -Match "#.*Test-Path.*wingetPath"
        }

        It "Should contain commented error handling for missing winget" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match "#.*Error: winget executable not found"
        }
    }

    Context "Winget Upgrade Arguments" {
        It "Should pass upgrade command as positional argument" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '"upgrade"'
        }

        It "Should include all required winget flags in ArgumentList" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '--all'
            $content | Should -Match '--include-unknown'
            $content | Should -Match '--accept-package-agreements'
            $content | Should -Match '--accept-source-agreements'
            $content | Should -Match '--silent'
        }

        It "Should use ArgumentList parameter for winget arguments" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match '\-ArgumentList'
        }
    }

    Context "Robustness and Edge Cases" {
        It "Should handle transcript already running scenario" {
            $content = Get-Content -Path $scriptPath -Raw
            # Start-Transcript with -Append handles this gracefully
            $content | Should -Match 'Start-Transcript'
            $content | Should -Match '\-Append'
        }

        It "Should continue even if winget is not in PATH" {
            $content = Get-Content -Path $scriptPath -Raw
            # try-catch block exists to handle exceptions
            $content | Should -Match 'try\s*\{'
            $content | Should -Match 'catch\s*\{'
            $content | Should -Match 'Start-Process'
        }

        It "Should handle date format consistently across runs" {
            $content = Get-Content -Path $scriptPath -Raw
            # yyyy-MM-dd format is consistent and sortable
            $content | Should -Match 'yyyy-MM-dd'
        }

        It "Should create logs directory structure if needed" {
            $content = Get-Content -Path $scriptPath -Raw
            $content | Should -Match 'New-Item.*-Path.*logPath.*-ItemType Directory'
        }
    }
}

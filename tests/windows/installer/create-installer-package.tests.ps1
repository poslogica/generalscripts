#Requires -Modules Pester
<#
.SYNOPSIS
    Pester tests for create-installer-package.ps1

.DESCRIPTION
    Tests parameter validation, script structure, and mocked functionality
    for the installer package creation script.

.NOTES
    These tests validate script structure and logic without creating actual packages.
#>

BeforeAll {
    # Path to the script under test
    $script:ScriptPath = Join-Path $PSScriptRoot '..\..\..\installer\create-installer-package.ps1'
    
    # Verify script exists
    if (-not (Test-Path $script:ScriptPath)) {
        throw "Script not found: $script:ScriptPath"
    }
    
    # Get script content for analysis
    $script:ScriptContent = Get-Content -Path $script:ScriptPath -Raw
    
    # Parse AST for detailed analysis
    $script:ScriptAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $script:ScriptPath,
        [ref]$null,
        [ref]$null
    )
}

Describe 'create-installer-package.ps1' {
    
    Context 'Script File Validation' {
        
        It 'Script file should exist' {
            Test-Path $script:ScriptPath | Should -BeTrue
        }
        
        It 'Script should have valid PowerShell syntax' {
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile(
                $script:ScriptPath,
                [ref]$null,
                [ref]$errors
            )
            $errors.Count | Should -Be 0
        }
        
        It 'Script should have comment-based help' {
            $script:ScriptContent | Should -Match '\.SYNOPSIS'
            $script:ScriptContent | Should -Match '\.DESCRIPTION'
        }
    }
    
    Context 'Parameter Definitions' {
        
        BeforeAll {
            # Extract parameters from AST
            $script:Parameters = $script:ScriptAst.ParamBlock.Parameters
        }
        
        It 'Should have OutputPath parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'OutputPath' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have OutputName parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'OutputName' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have Version parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Version' }
            $param | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Script Structure' {
        
        It 'Should set ErrorActionPreference to Stop' {
            $script:ScriptContent | Should -Match "\`$ErrorActionPreference\s*=\s*['""]Stop['""]"
        }
        
        It 'Should define script directory variable' {
            $script:ScriptContent | Should -Match '\$scriptDir|\$installerDir'
        }
        
        It 'Should reference VERSION file' {
            $script:ScriptContent | Should -Match 'VERSION'
        }
        
        It 'Should have default version fallback' {
            $script:ScriptContent | Should -Match "1\.0\.0"
        }
    }
    
    Context 'Files to Package' {
        
        It 'Should include install-winget-updater.ps1' {
            $script:ScriptContent | Should -Match 'install-winget-updater\.ps1'
        }
        
        It 'Should include install-winget-updater.bat' {
            $script:ScriptContent | Should -Match 'install-winget-updater\.bat'
        }
        
        It 'Should include INSTALL.md' {
            $script:ScriptContent | Should -Match 'INSTALL\.md'
        }
        
        It 'Should include uninstall-winget-updater.ps1' {
            $script:ScriptContent | Should -Match 'uninstall-winget-updater\.ps1'
        }
        
        It 'Should include update-winget-packages.ps1' {
            $script:ScriptContent | Should -Match 'update-winget-packages\.ps1'
        }
        
        It 'Should include update-winget-packages-create-start-menu-shortcut.ps1' {
            $script:ScriptContent | Should -Match 'update-winget-packages-create-start-menu-shortcut\.ps1'
        }
        
        It 'Should include winget-config.json' {
            $script:ScriptContent | Should -Match 'winget-config\.json'
        }
    }
    
    Context 'ZIP Creation' {
        
        It 'Should create temporary directory' {
            $script:ScriptContent | Should -Match 'New-Item.*Directory.*temp'
        }
        
        It 'Should use System.IO.Compression for ZIP creation' {
            $script:ScriptContent | Should -Match 'System\.IO\.Compression'
        }
        
        It 'Should create ZIP file' {
            $script:ScriptContent | Should -Match 'CreateFromDirectory|\.zip'
        }
        
        It 'Should clean up temporary directory' {
            $script:ScriptContent | Should -Match 'Remove-Item.*tempDir.*-Recurse'
        }
        
        It 'Should use try-finally for cleanup' {
            $script:ScriptContent | Should -Match 'try'
            $script:ScriptContent | Should -Match 'finally'
        }
    }
    
    Context 'Version Handling' {
        
        It 'Should read version from VERSION file if exists' {
            $script:ScriptContent | Should -Match 'Get-Content.*VERSION'
        }
        
        It 'Should support custom version parameter' {
            $script:ScriptContent | Should -Match '\$Version'
        }
        
        It 'Should include version in ZIP filename' {
            $script:ScriptContent | Should -Match 'winget-updater-setup-v'
        }
    }
    
    Context 'Output and Feedback' {
        
        It 'Should display progress messages' {
            $script:ScriptContent | Should -Match 'Write-Host'
        }
        
        It 'Should show version being built' {
            $script:ScriptContent | Should -Match 'Version.*\$Version'
        }
        
        It 'Should confirm files added' {
            $script:ScriptContent | Should -Match 'Added'
        }
        
        It 'Should show success message' {
            $script:ScriptContent | Should -Match 'success|created'
        }
        
        It 'Should display file size' {
            $script:ScriptContent | Should -Match 'Size|MB'
        }
        
        It 'Should warn about missing files' {
            $script:ScriptContent | Should -Match 'Write-Warning|Missing'
        }
    }
    
    Context 'Error Handling' {
        
        It 'Should check if installer directory exists' {
            $script:ScriptContent | Should -Match 'Test-Path.*installerDir'
        }
        
        It 'Should handle errors with Write-Error' {
            $script:ScriptContent | Should -Match 'Write-Error'
        }
        
        It 'Should exit with error code on failure' {
            $script:ScriptContent | Should -Match 'exit 1'
        }
        
        It 'Should use catch block for error handling' {
            $script:ScriptContent | Should -Match 'catch'
        }
    }
    
    Context 'README Generation' {
        
        It 'Should create README.txt in package' {
            $script:ScriptContent | Should -Match 'README\.txt'
        }
        
        It 'Should include quick start instructions' {
            $script:ScriptContent | Should -Match 'Quick Start|Installation'
        }
        
        It 'Should include requirements in README' {
            $script:ScriptContent | Should -Match 'Requirements|Windows'
        }
    }
}

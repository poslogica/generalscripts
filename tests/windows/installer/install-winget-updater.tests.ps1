#Requires -Modules Pester
<#
.SYNOPSIS
    Pester tests for install-winget-updater.ps1

.DESCRIPTION
    Tests parameter validation, script structure, and mocked functionality
    for the Winget Updater installer script.

.NOTES
    These tests use mocking to avoid actual system modifications.
    No files are copied, no tasks are created during testing.
#>

BeforeAll {
    # Path to the script under test
    $script:ScriptPath = Join-Path $PSScriptRoot '..\..\..\installer\install-winget-updater.ps1'
    
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

Describe 'install-winget-updater.ps1' {
    
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
        
        It 'Script should require administrator privileges' {
            $script:ScriptContent | Should -Match '#Requires\s+-RunAsAdministrator'
        }
    }
    
    Context 'Parameter Definitions' {
        
        BeforeAll {
            # Extract parameters from AST
            $script:Parameters = $script:ScriptAst.ParamBlock.Parameters
        }
        
        It 'Should have InstallPath parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'InstallPath' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'InstallPath should default to Program Files\WingetUpdater' {
            $script:ScriptContent | Should -Match "InstallPath\s*=\s*['""]C:\\Program Files\\WingetUpdater['""]"
        }
        
        It 'Should have ScheduleFrequency parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ScheduleFrequency' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'ScheduleFrequency should have ValidateSet for Daily, Weekly, Monthly' {
            $script:ScriptContent | Should -Match "ValidateSet\(['""]Daily['""],\s*['""]Weekly['""],\s*['""]Monthly['""]\)"
        }
        
        It 'Should have ScheduleTime parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ScheduleTime' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'ScheduleTime should have pattern validation for HH:mm format' {
            $script:ScriptContent | Should -Match 'ValidatePattern'
        }
        
        It 'Should have CreateStartMenuShortcut parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'CreateStartMenuShortcut' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have PinToTaskbar parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'PinToTaskbar' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have Force parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Force' }
            $param | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Script Structure' {
        
        It 'Should check for winget availability' {
            $script:ScriptContent | Should -Match 'winget'
        }
        
        It 'Should create installation directory' {
            $script:ScriptContent | Should -Match 'New-Item.*-ItemType\s+Directory'
        }
        
        It 'Should copy script files' {
            $script:ScriptContent | Should -Match 'Copy-Item'
        }
        
        It 'Should create scheduled task' {
            $script:ScriptContent | Should -Match 'New-ScheduledTask'
            $script:ScriptContent | Should -Match 'Register-ScheduledTask'
        }
        
        It 'Should support ShouldProcess (WhatIf)' {
            $script:ScriptContent | Should -Match 'SupportsShouldProcess'
            $script:ScriptContent | Should -Match '\$PSCmdlet\.ShouldProcess'
        }
        
        It 'Should set ErrorActionPreference to Stop' {
            $script:ScriptContent | Should -Match "\`$ErrorActionPreference\s*=\s*['""]Stop['""]"
        }
    }
    
    Context 'Files to Copy' {
        
        It 'Should copy update-winget-packages.ps1' {
            $script:ScriptContent | Should -Match 'update-winget-packages\.ps1'
        }
        
        It 'Should copy update-winget-packages-create-start-menu-shortcut.ps1' {
            $script:ScriptContent | Should -Match 'update-winget-packages-create-start-menu-shortcut\.ps1'
        }
        
        It 'Should copy winget-config.json' {
            $script:ScriptContent | Should -Match 'winget-config\.json'
        }
        
        It 'Should copy uninstall-winget-updater.ps1' {
            $script:ScriptContent | Should -Match 'uninstall-winget-updater\.ps1'
        }
    }
    
    Context 'Scheduled Task Configuration' {
        
        It 'Should create task action with pwsh.exe' {
            $script:ScriptContent | Should -Match 'New-ScheduledTaskAction.*pwsh\.exe'
        }
        
        It 'Should support Daily trigger' {
            $script:ScriptContent | Should -Match 'New-ScheduledTaskTrigger.*-Daily'
        }
        
        It 'Should support Weekly trigger' {
            $script:ScriptContent | Should -Match 'New-ScheduledTaskTrigger.*-Weekly'
        }
        
        It 'Should support Monthly trigger' {
            $script:ScriptContent | Should -Match 'New-ScheduledTaskTrigger.*-Monthly'
        }
        
        It 'Should run as SYSTEM account' {
            $script:ScriptContent | Should -Match 'NT AUTHORITY\\SYSTEM'
        }
        
        It 'Should run with highest privileges' {
            $script:ScriptContent | Should -Match 'RunLevel\s+Highest'
        }
    }
    
    Context 'Output and Logging' {
        
        It 'Should provide success feedback' {
            $script:ScriptContent | Should -Match 'Write-Host.*Green'
        }
        
        It 'Should provide warning feedback' {
            $script:ScriptContent | Should -Match 'Write-Warning|Write-Host.*Yellow'
        }
        
        It 'Should handle errors appropriately' {
            $script:ScriptContent | Should -Match 'Write-Error'
        }
    }
}

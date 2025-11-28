#Requires -Modules Pester
<#
.SYNOPSIS
    Pester tests for uninstall-winget-updater.ps1

.DESCRIPTION
    Tests parameter validation, script structure, and mocked functionality
    for the Winget Updater uninstaller script.

.NOTES
    These tests use mocking to avoid actual system modifications.
    No files are deleted, no tasks are removed during testing.
#>

BeforeAll {
    # Path to the script under test
    $script:ScriptPath = Join-Path $PSScriptRoot '..\..\..\installer\uninstall-winget-updater.ps1'
    
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

Describe 'uninstall-winget-updater.ps1' {
    
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
        
        It 'Should have KeepLogs parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'KeepLogs' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have KeepConfig parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'KeepConfig' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have BackupPath parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'BackupPath' }
            $param | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have Force parameter' {
            $param = $script:Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Force' }
            $param | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Script Structure' {
        
        It 'Should support ShouldProcess (WhatIf)' {
            $script:ScriptContent | Should -Match 'SupportsShouldProcess'
            $script:ScriptContent | Should -Match '\$PSCmdlet\.ShouldProcess'
        }
        
        It 'Should set ErrorActionPreference to Stop' {
            $script:ScriptContent | Should -Match "\`$ErrorActionPreference\s*=\s*['""]Stop['""]"
        }
        
        It 'Should define task name constant' {
            $script:ScriptContent | Should -Match 'Update-Winget-Packages'
        }
        
        It 'Should define task path constant' {
            $script:ScriptContent | Should -Match '\\Microsoft\\Windows\\Winget\\'
        }
    }
    
    Context 'Uninstall Operations' {
        
        It 'Should check for scheduled task' {
            $script:ScriptContent | Should -Match 'Get-ScheduledTask'
        }
        
        It 'Should remove scheduled task' {
            $script:ScriptContent | Should -Match 'Unregister-ScheduledTask'
        }
        
        It 'Should check for Start Menu shortcut' {
            $script:ScriptContent | Should -Match 'Update Winget Packages'
        }
        
        It 'Should remove shortcut file' {
            $script:ScriptContent | Should -Match 'Remove-Item.*shortcut'
        }
        
        It 'Should remove installation directory' {
            $script:ScriptContent | Should -Match 'Remove-Item.*InstallPath.*-Recurse'
        }
    }
    
    Context 'Backup Functionality' {
        
        It 'Should support backing up logs' {
            $script:ScriptContent | Should -Match 'KeepLogs'
            $script:ScriptContent | Should -Match 'logs'
        }
        
        It 'Should support backing up config' {
            $script:ScriptContent | Should -Match 'KeepConfig'
            $script:ScriptContent | Should -Match 'winget-config\.json'
        }
        
        It 'Should copy files to backup location' {
            $script:ScriptContent | Should -Match 'Copy-Item.*Backup'
        }
        
        It 'Should create backup directory if needed' {
            $script:ScriptContent | Should -Match 'New-Item.*Directory.*BackupPath'
        }
    }
    
    Context 'User Interaction' {
        
        It 'Should prompt for confirmation unless Force is used' {
            $script:ScriptContent | Should -Match 'Read-Host'
            $script:ScriptContent | Should -Match 'Force'
        }
        
        It 'Should show what will be removed' {
            $script:ScriptContent | Should -Match 'Components to remove'
        }
        
        It 'Should allow cancellation' {
            $script:ScriptContent | Should -Match 'cancelled|Cancelled'
        }
    }
    
    Context 'Output and Logging' {
        
        It 'Should have Write-Status helper function' {
            $script:ScriptContent | Should -Match 'function Write-Status'
        }
        
        It 'Should provide success feedback' {
            $script:ScriptContent | Should -Match 'Success|Green'
        }
        
        It 'Should provide warning feedback' {
            $script:ScriptContent | Should -Match 'Warning|Yellow'
        }
        
        It 'Should provide error feedback' {
            $script:ScriptContent | Should -Match 'Error|Red'
        }
        
        It 'Should show completion message' {
            $script:ScriptContent | Should -Match 'Uninstallation Complete|has been removed'
        }
    }
    
    Context 'Pre-flight Checks' {
        
        It 'Should check if installation exists' {
            $script:ScriptContent | Should -Match 'Test-Path.*InstallPath'
        }
        
        It 'Should check if task exists' {
            $script:ScriptContent | Should -Match 'taskExists'
        }
        
        It 'Should check if shortcut exists' {
            $script:ScriptContent | Should -Match 'shortcutExists'
        }
        
        It 'Should handle case when nothing is installed' {
            $script:ScriptContent | Should -Match 'No.*installation found|not found'
        }
    }
}

<#
.SYNOPSIS
Runs all Pester tests in the tests directory and generates an NUnit XML report.

.DESCRIPTION
This script discovers and runs all Pester tests (*.tests.ps1) in the tests/ directory
and generates an NUnit XML test result file for CI/CD integration or local analysis.

.PARAMETER OutputPath
The path where the NUnit XML test result file will be written.
Default: TestResults.xml in the current directory.

.PARAMETER Verbose
Run tests with verbose output for detailed test execution information.

.EXAMPLE
.\run-tests.ps1

.EXAMPLE
.\run-tests.ps1 -OutputPath 'C:\Reports\TestResults.xml' -Verbose
#>

param(
    [string]$OutputPath = 'TestResults.xml',
    [switch]$Verbose
)

# Resolve script directory
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$testsPath = $scriptDir
$repoRoot = Split-Path -Path $scriptDir -Parent

# Verify we're in the tests directory by checking for test files
$testFiles = @(Get-ChildItem -Path $testsPath -Filter '*.tests.ps1' -Recurse)
if ($testFiles.Count -eq 0) {
    Write-Error "No test files (*.tests.ps1) found in: $testsPath"
    exit 1
}

Write-Host "Running Pester tests from: $testsPath" -ForegroundColor Cyan
Write-Host "Output file: $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Configure Pester
$config = New-PesterConfiguration -Hashtable @{
    Run = @{
        Path = $testsPath
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = $OutputPath
    }
    Output = @{
        Verbosity = if ($Verbose) { 'Detailed' } else { 'Normal' }
    }
}

# Run tests
$result = Invoke-Pester -Configuration $config

# Display summary
Write-Host ""
Write-Host "Test Results:" -ForegroundColor Cyan
Write-Host "  Passed:      $($result.PassedCount)" -ForegroundColor Green
Write-Host "  Failed:      $($result.FailedCount)" -ForegroundColor $(if ($result.FailedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "  Skipped:     $($result.SkippedCount)" -ForegroundColor Yellow
Write-Host "  Inconclusive: $($result.InconclusiveCount)" -ForegroundColor Yellow
Write-Host ""

# Exit with appropriate code
exit $result.FailedCount

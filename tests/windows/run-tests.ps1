<#
.SYNOPSIS
Runs all Pester tests in the tests directory and generates an NUnit XML report with code coverage.

.DESCRIPTION
This script discovers and runs all Pester tests (*.tests.ps1) in the tests/ directory
and generates an NUnit XML test result file and code coverage report for CI/CD integration.

.PARAMETER OutputPath
The path where the NUnit XML test result file will be written.
Default: TestResults.xml in the current directory.

.PARAMETER CoverageReport
Generate and display code coverage report for production scripts.
Default: $true

.PARAMETER Verbose
Run tests with verbose output for detailed test execution information.

.EXAMPLE
.\run-tests.ps1

.EXAMPLE
.\run-tests.ps1 -OutputPath 'C:\Reports\TestResults.xml' -Verbose

.EXAMPLE
.\run-tests.ps1 -CoverageReport $false
#>

param(
    [string]$OutputPath = 'TestResults.xml',
    [bool]$CoverageReport = $true,
    [switch]$Verbose
)

# Resolve script directory
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$testsPath = Split-Path -Path $scriptDir -Parent  # Go up to tests/ directory
$repoRoot = Split-Path -Path $testsPath -Parent   # Go up to repository root
$scriptsPath = Join-Path -Path $repoRoot -ChildPath 'scripts'

# Verify we're in the tests directory by checking for test files
$testFiles = @(Get-ChildItem -Path $testsPath -Filter '*.tests.ps1' -Recurse)
if ($testFiles.Count -eq 0) {
    Write-Error "No test files (*.tests.ps1) found in: $testsPath"
    exit 1
}

# Get production scripts for coverage analysis
$productionScripts = @(Get-ChildItem -Path $scriptsPath -Filter '*.ps1' -Recurse | Where-Object { $_.Name -notlike '*.tests.ps1' })
if ($productionScripts.Count -eq 0) {
    Write-Warning "No production scripts found in: $scriptsPath"
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
    CodeCoverage = @{
        Enabled = $CoverageReport -and ($productionScripts.Count -gt 0)
        Path = if ($CoverageReport -and ($productionScripts.Count -gt 0)) { $productionScripts.FullName } else { @() }
        OutputFormat = 'JaCoCo'
        OutputPath = 'CodeCoverage.xml'
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

# Display code coverage if enabled
if ($CoverageReport -and $result.CodeCoverage) {
    Write-Host "Code Coverage:" -ForegroundColor Cyan
    
    $totalCommandsAnalyzed = $result.CodeCoverage.NumberOfCommandsAnalyzed
    $totalCommandsExecuted = $result.CodeCoverage.NumberOfCommandsExecuted
    
    if ($totalCommandsAnalyzed -gt 0) {
        $coveragePercent = [math]::Round(($totalCommandsExecuted / $totalCommandsAnalyzed) * 100, 2)
        $coverageColor = if ($coveragePercent -ge 80) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' }
        
        Write-Host "  Overall Coverage: $coveragePercent%" -ForegroundColor $coverageColor
        Write-Host "  Commands Executed: $totalCommandsExecuted / $totalCommandsAnalyzed"
        
        # Show per-file coverage
        Write-Host ""
        Write-Host "  Coverage by File:" -ForegroundColor Gray
        $result.CodeCoverage | Group-Object -Property File | ForEach-Object {
            $file = Split-Path -Path $_.Name -Leaf
            $analyzed = ($_.Group | Measure-Object -Property NumberOfCommandsAnalyzed -Sum).Sum
            $executed = ($_.Group | Measure-Object -Property NumberOfCommandsExecuted -Sum).Sum
            
            if ($analyzed -gt 0) {
                $fileCoverage = [math]::Round(($executed / $analyzed) * 100, 2)
                Write-Host "    $file : $fileCoverage% ($executed / $analyzed)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
}

# Exit with appropriate code
exit $result.FailedCount

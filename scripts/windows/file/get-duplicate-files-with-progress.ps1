<#
.SYNOPSIS
    Identifies and reports duplicate files in a directory tree using file hash comparison.

.DESCRIPTION
    This script recursively scans a specified directory, computes SHA256 hashes for all files,
    and identifies duplicates by comparing their hash values. Results are written to a text file
    with organized output showing hash values and file paths for all duplicates.

.PARAMETER Path
    The root directory to scan for duplicate files. Defaults to current directory (.).

.EXAMPLE
    .\get-duplicate-files-with-progress.ps1
    Scans current directory and reports duplicates.

.EXAMPLE
    .\get-duplicate-files-with-progress.ps1 -Path "C:\Users\Documents"
    Scans the Documents folder and all subdirectories for duplicate files.

.NOTES
    - Output file is created in the script directory as 'duplicate_files_with_progress.txt'
    - Uses -LiteralPath to safely handle special characters in paths
    - Continues processing even if some files cannot be hashed
    - Progress bar shows real-time hashing progress
#>
param (
    [string]$Path = "."
)

# Resolve the scan path safely
try {
    $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
} catch {
    Write-Error "❌ The path '$Path' is invalid or does not exist."
    exit 1
}

# Output file in same directory as script
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "duplicate_files_with_progress.txt"

# Get all files under the resolved path
$files = Get-ChildItem -LiteralPath $resolvedPath -Recurse -File -ErrorAction SilentlyContinue
$total = $files.Count

if ($total -eq 0) {
    Write-Warning "No files found in '$resolvedPath'"
    exit 0
}

$counter = 0
$hashList = @()

foreach ($file in $files) {
    $counter++
    Write-Progress -Activity "Hashing files..." -Status "Processing $($file.Name)" -PercentComplete (($counter / $total) * 100)

    try {
        $hash = Get-FileHash -LiteralPath $file.FullName -ErrorAction Stop
        $hashList += @{
            Hash = $hash.Hash
            Path = $file.FullName
            Size = $file.Length
        }
    } catch {
        Write-Warning "⚠️ Failed to hash $($file.FullName): $_"
    }
}

# Group by hash and find duplicates
$duplicates = $hashList |
    Group-Object { $_.Hash } |
    Where-Object { $_.Count -gt 1 } |
    Sort-Object { $_.Group[0].Size } -Descending

# Calculate statistics
$totalDuplicates = $duplicates.Count
$totalWastedSpace = 0

foreach ($group in $duplicates) {
    $fileSize = $group.Group[0].Size
    # Space wasted = file size * (count - 1), since one is the "original"
    $totalWastedSpace += ($fileSize * ($group.Count - 1))
}

# Clear previous output if exists
Remove-Item $outputFile -ErrorAction SilentlyContinue

# Write header to file
$header = @"
================================================================================
DUPLICATE FILES REPORT
================================================================================
Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Scan Location: $resolvedPath
Total Files Scanned: $total
Total Duplicate Groups: $totalDuplicates
Total Wasted Space: $('{0:N2}' -f ($totalWastedSpace/1MB)) MB
================================================================================

"@
Add-Content $outputFile $header

# Write output to file
foreach ($group in $duplicates) {
    $fileSize = $group.Group[0].Size
    $wastedSpace = $fileSize * ($group.Count - 1)
    
    Add-Content $outputFile ""
    Add-Content $outputFile "=== Duplicates for hash: $($group.Name) ==="
    Add-Content $outputFile "File Size: $('{0:N2}' -f ($fileSize/1KB)) KB"
    Add-Content $outputFile "Wasted Space (if duplicates deleted): $('{0:N2}' -f ($wastedSpace/1MB)) MB"
    Add-Content $outputFile "Number of Copies: $($group.Count)"
    Add-Content $outputFile ""
    
    foreach ($file in $group.Group | Sort-Object Path) {
        Add-Content $outputFile "  $($file.Path)"
    }
}

# Write footer with summary
$footer = @"

================================================================================
END OF REPORT
================================================================================
"@
Add-Content $outputFile $footer

Write-Host "`n✅ Duplicate scan complete!" -ForegroundColor Green
Write-Host "Report: $outputFile" -ForegroundColor Green
Write-Host "Summary: Found $totalDuplicates duplicate groups with $('{0:N2}' -f ($totalWastedSpace/1MB)) MB of wasted space" -ForegroundColor Cyan
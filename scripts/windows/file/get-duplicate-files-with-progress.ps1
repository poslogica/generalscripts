param (
    [string]$Path = "."
)

# Resolve the scan path safely
try {
    $resolvedPath = (Resolve-Path -LiteralPath  $Path -ErrorAction Stop).ProviderPath
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
        $hash = Get-FileHash -LiteralPath  $file.FullName -ErrorAction Stop
        $hashList += $hash
    } catch {
        Write-Warning "⚠️ Failed to hash $($file.FullName): $_"
    }
}

# Group by hash and find duplicates
$duplicates = $hashList |
    Group-Object Hash |
    Where-Object { $_.Count -gt 1 }

# Clear previous output if exists
Remove-Item $outputFile -ErrorAction SilentlyContinue

# Write output to file
foreach ($group in $duplicates) {
    Add-Content $outputFile "`n=== Duplicates for hash: $($group.Name) ==="
    foreach ($file in $group.Group) {
        Add-Content $outputFile $file.Path
    }
}

Write-Host "`n✅ Done. Duplicate files written to: $outputFile"

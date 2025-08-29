<# 
.SYNOPSIS
    Upgrade 3rd-party software with winget, using an external JSON config for exclusions.

.DESCRIPTION
    Reads exclusions from a JSON config file (ExcludeIds, ExcludeNames).
    Upgrades all other packages via `winget upgrade`.

.PARAMETER ConfigPath
    Path to JSON configuration file. Default: ./winget-config.json

.EXAMPLE
    .\Update-ThirdPartyWithWinget.ps1
    (Uses winget-config.json in the same folder)

.EXAMPLE
    .\Update-ThirdPartyWithWinget.ps1 -ConfigPath "C:\Config\winget-config.json"
#>

param(
    [string]$ConfigPath = ".\winget-config.json"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$ts][$Level] $Message"
}

# Load Config
if (!(Test-Path $ConfigPath)) {
    Write-Log "Config file not found at $ConfigPath. Creating a sample config..." "WARN"
    @"
{
  "ExcludeIds": [ "Google.Chrome", "Adobe.*" ],
  "ExcludeNames": [ "NVIDIA *" ]
}
"@ | Set-Content $ConfigPath -Encoding UTF8
    Write-Log "Edit $ConfigPath and re-run the script." "INFO"
    exit
}

try {
    $config = Get-Content $ConfigPath | ConvertFrom-Json
} catch {
    Write-Log "Invalid JSON in $ConfigPath: $($_.Exception.Message)" "ERROR"
    exit 1
}

$ExcludeIds   = $config.ExcludeIds
$ExcludeNames = $config.ExcludeNames

function MatchesAny {
    param($text, $patterns)
    foreach ($p in $patterns) {
        if ($text -like $p) { return $true }
    }
    return $false
}

# Ensure winget is available
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Log "winget not found. Install from Microsoft Store." "ERROR"
    exit 1
}

# Get list of upgradable apps
Write-Log "Checking for updates..."
$raw = winget upgrade --accept-source-agreements --output json 2>$null
$data = $raw | ConvertFrom-Json
$packages = if ($data.Upgrades) { $data.Upgrades } else { $data }

if (-not $packages -or $packages.Count -eq 0) {
    Write-Log "No updates available." "INFO"
    exit
}

# Filter out exclusions
$toUpgrade = foreach ($pkg in $packages) {
    $id = $pkg.Id ?? $pkg.PackageIdentifier
    $name = $pkg.Name ?? $pkg.PackageName

    if ((MatchesAny $id $ExcludeIds) -or (MatchesAny $name $ExcludeNames)) {
        Write-Log "Skipping $name ($id)" "INFO"
        continue
    }
    [PSCustomObject]@{ Id = $id; Name = $name; Version = $pkg.Version; Available = $pkg.Available }
}

if (-not $toUpgrade) {
    Write-Log "All packages are excluded. Nothing to update." "INFO"
    exit
}

# Upgrade packages
foreach ($pkg in $toUpgrade) {
    Write-Log "Upgrading $($pkg.Name) ($($pkg.Id)) from $($pkg.Version) to $($pkg.Available)..."
    winget upgrade --id $pkg.Id --silent --accept-source-agreements --accept-package-agreements
}

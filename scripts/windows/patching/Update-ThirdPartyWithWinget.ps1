<#
.SYNOPSIS
  Upgrade 3rd-party software with winget, using an external JSON config for exclusions.
  Robust across noisy winget output (JSON first, table fallback). PS 5.1 compatible.

.DESCRIPTION
  Reads exclusions from a JSON config file with:
    {
      "ExcludeIds":   [ "Google.Chrome", "Adobe.*" ],
      "ExcludeNames": [ "NVIDIA *" ]
    }
  Then discovers upgradable apps and upgrades anything not excluded.

.PARAMETER ConfigPath
  Optional path to JSON config. Default: "<script folder>\winget-config.json"

.PARAMETER LogPath
  Optional file path to append logs.

.PARAMETER Scope
  user | machine. Default: user. "machine" usually requires elevation.

.PARAMETER IncludeUnknown
  Consider packages with unknown versions (passes --include-unknown on discovery/upgrade).

.PARAMETER WhatIf
  Preview actions without making changes.

.PARAMETER StopOnError
  Stop on first package failure (default is continue).

.PARAMETER Diagnostics
  Saves raw/sanitized winget outputs next to the script for troubleshooting.

.EXAMPLES
  .\Update-ThirdPartyWithWinget.ps1
  .\Update-ThirdPartyWithWinget.ps1 -ConfigPath 'C:\cfg\winget-config.json' -LogPath 'C:\Logs\winget-upgrades.log'
  .\Update-ThirdPartyWithWinget.ps1 -Scope machine -IncludeUnknown -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ConfigPath,
    [string]$LogPath,
    [ValidateSet('user','machine')]
    [string]$Scope = 'user',
    [switch]$IncludeUnknown,
    [switch]$StopOnError,
    [switch]$Diagnostics
)

# ---------------- Utilities ----------------
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO'
    )
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$ts][$Level] $Message"
    Write-Host $line
    if ($LogPath) {
        try {
            $dir = Split-Path -Path $LogPath -Parent
            if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
        } catch {
            Write-Host "[$ts][WARN] Failed to write log: $($_.Exception.Message)"
        }
    }
}

function FirstNotNullOrEmpty {
    param([Parameter(ValueFromRemainingArguments=$true)] $Values)
    foreach ($v in $Values) {
        if ($null -ne $v -and ($v -isnot [string] -or -not [string]::IsNullOrWhiteSpace($v))) { return $v }
    }
    return $null
}

function MatchesAny {
    param([string]$Text, [string[]]$Patterns)
    if (-not $Text -or -not $Patterns) { return $false }
    foreach ($p in $Patterns) { if ($Text -like $p) { return $true } }
    return $false
}

function Test-Admin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p  = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

# Extract the first JSON object/array substring from noisy text
function Get-FirstJsonChunk {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    $firstObj = $Text.IndexOf('{'); $firstArr = $Text.IndexOf('[')
    if ($firstObj -eq -1 -and $firstArr -eq -1) { return $null }
    if ($firstObj -eq -1) { $start = $firstArr }
    elseif ($firstArr -eq -1) { $start = $firstObj }
    else { $start = [Math]::Min($firstObj,$firstArr) }
    $substr = $Text.Substring($start)
    $endObj = $substr.LastIndexOf('}'); $endArr = $substr.LastIndexOf(']')
    $end = [Math]::Max($endObj,$endArr)
    if ($end -lt 0) { return $null }
    return $substr.Substring(0, $end + 1).Trim()
}

# Parse table output of `winget upgrade` using header column indexes
function Parse-WingetUpgradeTable {
    param([string[]]$Lines)

    if (-not $Lines -or $Lines.Count -eq 0) { return @() }

    # Find header containing required columns
    $headerIndex = -1
    for ($i=0; $i -lt $Lines.Count; $i++) {
        $l = $Lines[$i]
        if ($l -match '\bName\b' -and $l -match '\bId\b' -and $l -match '\bVersion\b' -and $l -match '\bAvailable\b' -and $l -match '\bSource\b') {
            $headerIndex = $i; break
        }
    }
    if ($headerIndex -lt 0) { return @() }

    $header = $Lines[$headerIndex]
    $idxName      = $header.IndexOf('Name')
    $idxId        = $header.IndexOf('Id')
    $idxVersion   = $header.IndexOf('Version')
    $idxAvailable = $header.IndexOf('Available')
    $idxSource    = $header.IndexOf('Source')
    if (@($idxName,$idxId,$idxVersion,$idxAvailable,$idxSource) -contains -1) { return @() }

    function Slice([string]$line, [int]$start, [int]$nextStart) {
        if ($start -lt 0 -or $start -ge $line.Length) { return '' }
        if ($nextStart -le $start -or $nextStart -gt $line.Length) { $nextStart = $line.Length }
        return $line.Substring($start, $nextStart - $start).Trim()
    }

    $startIndex = $headerIndex + 1
    if ($startIndex -lt $Lines.Count -and $Lines[$startIndex] -match '^-{3,}') { $startIndex++ }

    $result = @()
    for ($j=$startIndex; $j -lt $Lines.Count; $j++) {
        $line = $Lines[$j]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^\s*No packages have available updates') { break }

        $name      = Slice $line $idxName      $idxId
        $id        = Slice $line $idxId        $idxVersion
        $version   = Slice $line $idxVersion   $idxAvailable
        $available = Slice $line $idxAvailable $idxSource
        $source    = Slice $line $idxSource    ($line.Length)

        if (-not $id) { continue }
        if ($version -eq '-')   { $version = $null }
        if ($available -eq '-') { $available = $null }

        $result += [PSCustomObject]@{
            Id        = $id
            Name      = $name
            Version   = $version
            Available = $available
            Source    = $source
        }
    }
    return $result
}

# Run winget and return upgrades (array of objects).
# 1) Try:   winget list --upgrade-available --output json
# 2) Try:   winget upgrade --output json (sanitize)
# 3) Parse: winget upgrade (table)
function Get-WingetUpgrades {
    param([switch]$IncludeUnknown, [string]$DiagPath)

    # Attempt 1: cleaner JSON
    $argsList = @('list','--upgrade-available','--accept-source-agreements','--disable-interactivity','--output','json')
    $rawList  = & winget @argsList 2>&1
    $rawListText = ($rawList | Out-String)

    if ($DiagPath) {
        $p0 = Join-Path $DiagPath 'winget-list-upgrade-raw.json.txt'
        $rawListText | Out-File -LiteralPath $p0 -Encoding UTF8
    }

    try {
        $parsed = $rawListText | ConvertFrom-Json
        if ($parsed) { return $parsed }
    } catch { }

    # Attempt 2: upgrade JSON (sanitize if needed)
    $argsUpgJson = @('upgrade','--accept-source-agreements','--disable-interactivity','--output','json')
    if ($IncludeUnknown) { $argsUpgJson += '--include-unknown' }

    $raw = & winget @argsUpgJson 2>&1
    $rawText = ($raw | Out-String)
    if ($DiagPath) {
        $p1 = Join-Path $DiagPath 'winget-upgrade-raw-json.txt'
        $rawText | Out-File -LiteralPath $p1 -Encoding UTF8
    }

    try {
        $parsed = $rawText | ConvertFrom-Json
        if ($parsed) { return $parsed }
    } catch { }

    $json = Get-FirstJsonChunk -Text $rawText
    if ($json) {
        if ($DiagPath) {
            $p2 = Join-Path $DiagPath 'winget-upgrade-sanitized.json'
            $json | Out-File -LiteralPath $p2 -Encoding UTF8
        }
        try {
            $parsed = $json | ConvertFrom-Json
            if ($parsed) { return $parsed }
        } catch { }
    }

    # Attempt 3: table parsing
    $argsUpgTbl = @('upgrade','--accept-source-agreements','--disable-interactivity')
    if ($IncludeUnknown) { $argsUpgTbl += '--include-unknown' }

    $rawTbl  = & winget @argsUpgTbl 2>&1
    $tblText = ($rawTbl | Out-String)
    if ($DiagPath) {
        $p3 = Join-Path $DiagPath 'winget-upgrade-raw-table.txt'
        $tblText | Out-File -LiteralPath $p3 -Encoding UTF8
    }

    $lines = $tblText -split '\r?\n'
    $parsedTable = Parse-WingetUpgradeTable -Lines $lines
    if ($parsedTable -and $parsedTable.Count -gt 0) { return $parsedTable }

    throw "Failed to parse winget output (JSON and table fallback)."
}

# ---------------- Bootstrap ----------------
# Resolve script directory ($PSScriptRoot may be empty in some contexts)
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot }
elseif ($MyInvocation.MyCommand.Path) { Split-Path -LiteralPath $MyInvocation.MyCommand.Path -Parent }
else { (Get-Location).Path }

# Default config path if not provided
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path -Path $ScriptDir -ChildPath 'winget-config.json'
}

# Improve odds of clean UTF-8 text (some hosts need this)
try {
    $global:OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch { }

# Pre-flight checks
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Log "winget is not installed or not in PATH. Install 'App Installer' from Microsoft Store." 'ERROR'
    exit 1
}

if ($Scope -eq 'machine' -and -not (Test-Admin)) {
    Write-Log "Machine scope requested, but shell is not elevated. Some upgrades may fail." 'WARN'
}

# Load/create config
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Log "Config not found at ${ConfigPath}. Creating a sample config..." 'WARN'
    @"
{
  "ExcludeIds":   [ "Google.Chrome", "Adobe.*" ],
  "ExcludeNames": [ "NVIDIA *" ]
}
"@ | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
    Write-Log "Edit ${ConfigPath} and re-run the script." 'INFO'
    exit 0
}

try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-Log "Invalid JSON in ${ConfigPath}: $($_.Exception.Message)" 'ERROR'
    exit 1
}

[string[]]$ExcludeIds   = @()
[string[]]$ExcludeNames = @()
if ($config.PSObject.Properties.Name -contains 'ExcludeIds')   { $ExcludeIds   = @($config.ExcludeIds)   | Where-Object { $_ } }
if ($config.PSObject.Properties.Name -contains 'ExcludeNames') { $ExcludeNames = @($config.ExcludeNames) | Where-Object { $_ } }

# ---------------- Discover ----------------
Write-Log "Querying upgradable packages..."
$diagPath = if ($Diagnostics) { $ScriptDir } else { $null }

try {
    $data = Get-WingetUpgrades -IncludeUnknown:$IncludeUnknown -DiagPath $diagPath
} catch {
    Write-Log $_.Exception.Message 'ERROR'
    if ($Diagnostics) { Write-Log "Diagnostics saved to: $ScriptDir (files starting with winget-*)" 'INFO' }
    exit 1
}

# Normalize across shapes
$packages = @()
if ($data -is [System.Array]) {
    $packages = $data
} elseif ($data.PSObject.Properties.Name -contains 'Upgrades') {
    $packages = $data.Upgrades
} elseif ($data.PSObject.Properties.Name -contains 'Installed') {
    $packages = $data.Installed
} else {
    $packages = @($data)
}

if (-not $packages -or $packages.Count -eq 0) {
    Write-Log "No updates available." 'INFO'
    exit 0
}

# ---------------- Filter ----------------
$toUpgrade = foreach ($pkg in $packages) {
    $id   = FirstNotNullOrEmpty $pkg.Id $pkg.PackageIdentifier ($pkg.Package.Id)
    $name = FirstNotNullOrEmpty $pkg.Name $pkg.PackageName     ($pkg.Package.Name)
    if (-not $id -and -not $name) { continue }

    if (MatchesAny -Text $id -Patterns $ExcludeIds -or MatchesAny -Text $name -Patterns $ExcludeNames) {
        Write-Log "Skipping $name ($id)" 'INFO'
        continue
    }

    [PSCustomObject]@{
        Id        = $id
        Name      = $name
        Version   = FirstNotNullOrEmpty $pkg.Version $pkg.Installed $pkg.InstalledVersion
        Available = FirstNotNullOrEmpty $pkg.Available $pkg.AvailableVersion
        Source    = FirstNotNullOrEmpty $pkg.Source $pkg.Repository
    }
}

if (-not $toUpgrade -or $toUpgrade.Count -eq 0) {
    Write-Log "All upgradable packages are excluded. Nothing to update." 'INFO'
    exit 0
}

Write-Log "Packages queued for upgrade ($($toUpgrade.Count)):" 'INFO'
$toUpgrade | ForEach-Object { Write-Log " - $($_.Name) [$($_.Id)] $($_.Version) -> $($_.Available)" 'INFO' }

# ---------------- Upgrade ----------------
$fail = @()
foreach ($pkg in $toUpgrade) {
    $args = @(
        'upgrade','--id', $pkg.Id,
        '--accept-source-agreements','--accept-package-agreements',
        '--silent','--disable-interactivity'
    )
    if ($Scope) { $args += @('--scope', $Scope) }
    if ($IncludeUnknown) { $args += '--include-unknown' }

    $label = "$($pkg.Name) [$($pkg.Id)]"
    if ($PSCmdlet.ShouldProcess($label, "Upgrade to $($pkg.Available)")) {
        Write-Log "Upgrading $label ..." 'INFO'
        try {
            $p = Start-Process -FilePath (Get-Command winget).Source -ArgumentList $args -PassThru -Wait -NoNewWindow
            if ($p.ExitCode -ne 0) {
                $msg = "Failed ($($p.ExitCode)): $label"
                Write-Log $msg 'ERROR'
                $fail += $label
                if ($StopOnError) { break }
            } else {
                Write-Log "Success: $label" 'INFO'
            }
        } catch {
            Write-Log "Error upgrading $label : $($_.Exception.Message)" 'ERROR'
            $fail += $label
            if ($StopOnError) { break }
        }
    } else {
        Write-Log "WhatIf: would upgrade $label" 'INFO'
    }
}

if ($fail.Count -gt 0) {
    Write-Log "Completed with failures ($($fail.Count))." 'WARN'
    if ($Diagnostics) { Write-Log "See diagnostics in $ScriptDir if needed." 'INFO' }
    exit 2
} else {
    Write-Log "All selected packages upgraded successfully." 'INFO'
    exit 0
}

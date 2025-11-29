<#
.SYNOPSIS
  Upgrade 3rd-party software with winget, driven by an external JSON config.
  Robust across noisy winget output (JSON first, sanitized JSON, table fallback). PS 5.1 compatible.

.CONFIG (winget-config.json example)
{
  "IncludeOnlyIds":   [ "Git.Git", "Google.Chrome" ],
  "IncludeOnlyNames": [ "Git", "Google Chrome" ],
  "ExcludeIds":       [ "Anaconda.*", "Adobe.*" ],
  "ExcludeNames":     [ "Anaconda3 *", "NVIDIA *" ],
  "ExcludeSources":   [ "msstore" ]
}

.EXAMPLES
  .\Update-ThirdPartyWithWinget.ps1
  .\Update-ThirdPartyWithWinget.ps1 -IncludeUnknown -Diagnostics
  .\Update-ThirdPartyWithWinget.ps1 -LogPath "C:\Logs\winget-upgrades.log"

.NOTES
  - Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7)
  - Windows 10/11 or Windows Server 2019+
  - Winget must be installed and available

.LINK
  https://github.com/poslogica/generalscripts
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ConfigPath,
    [ValidateSet('user','machine')]
    [string]$Scope,                  # NOTE: no default; we won't pass --scope unless specified
    [string]$LogPath,                # Path to log file for output
    [switch]$IncludeUnknown,
    [switch]$StopOnError,
    [switch]$Diagnostics
)

# ---------------- Utilities ----------------
# Script-level variable to hold log file path
$script:LogFile = $null

function Write-LogMessage {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO'
    )
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$ts][$Level] $Message"
    Write-Output $line
    
    # Also write to log file if specified
    if ($script:LogFile) {
        try {
            $line | Out-File -LiteralPath $script:LogFile -Append -Encoding UTF8
        } catch {
            # Silently ignore log file errors to not break execution
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
    param(
        [Parameter(Mandatory)][string]$Text,
        [string[]]$Patterns
    )
    if (-not $Text -or -not $Patterns) { return $false }
    foreach ($p in $Patterns) {
        if ($Text -like $p) { return $true }  # -like is case-insensitive
    }
    return $false
}

function Test-Admin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p  = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

# Extract first JSON object/array from noisy text
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
function Get-WingetUpgradeTableParsed {
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

        # Stop when footnote/summary appears
        if ($line -match 'package\(s\)\s+have version numbers') { break }
        if ($line -match 'No packages have available updates') { break }

        $name      = Slice $line $idxName      $idxId
        $id        = Slice $line $idxId        $idxVersion
        $version   = Slice $line $idxVersion   $idxAvailable
        $available = Slice $line $idxAvailable $idxSource
        $source    = Slice $line $idxSource    ($line.Length)

        # Basic sanity: id should look like an identifier (no spaces)
        if (-not $id -or $id -match '\s') { continue }

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
# 1) Try:   winget upgrade --output json (newer winget v1.4+)
# 2) Try:   winget list --upgrade-available --output json
# 3) Parse: winget upgrade (table fallback for older winget versions)
function Get-WingetUpgradeList {
    param([switch]$IncludeUnknown, [string]$DiagPath)

    # Check winget version to decide strategy
    $wingetVersion = $null
    try {
        $versionOutput = & winget --version 2>&1
        if ($versionOutput -match 'v?(\d+)\.(\d+)') {
            $wingetVersion = [version]"$($Matches[1]).$($Matches[2]).0"
        }
    } catch { }
    
    $supportsJson = $wingetVersion -and $wingetVersion -ge [version]"1.4.0"
    
    if ($supportsJson) {
        # Attempt 1: cleaner JSON from list command
        $argsList = @('list','--upgrade-available','--accept-source-agreements','--disable-interactivity','--output','json')
        $rawList  = & winget @argsList 2>&1
        $rawListText = ($rawList | Out-String)
        if ($DiagPath) { $rawListText | Out-File -LiteralPath (Join-Path $DiagPath 'winget-list-upgrade-raw.json.txt') -Encoding UTF8 }

        try {
            $parsed = $rawListText | ConvertFrom-Json
            if ($parsed) { return $parsed }
        } catch {
            Write-LogMessage "Failed to parse initial JSON list: $($_.Exception.Message)" 'DEBUG'
        }

        # Attempt 2: upgrade JSON (sanitize if needed)
        $argsUpgJson = @('upgrade','--accept-source-agreements','--disable-interactivity','--output','json')
        if ($IncludeUnknown) { $argsUpgJson += '--include-unknown' }

        $raw = & winget @argsUpgJson 2>&1
        $rawText = ($raw | Out-String)
        if ($DiagPath) { $rawText | Out-File -LiteralPath (Join-Path $DiagPath 'winget-upgrade-raw-json.txt') -Encoding UTF8 }

        try {
            $parsed = $rawText | ConvertFrom-Json
            if ($parsed) { return $parsed }
        } catch {
            Write-LogMessage "Failed to parse upgrade JSON: $($_.Exception.Message)" 'DEBUG'
        }

        $json = Get-FirstJsonChunk -Text $rawText
        if ($json) {
            if ($DiagPath) { $json | Out-File -LiteralPath (Join-Path $DiagPath 'winget-upgrade-sanitized.json') -Encoding UTF8 }
            try {
                $parsed = $json | ConvertFrom-Json
                if ($parsed) { return $parsed }
            } catch {
                Write-LogMessage "Failed to parse sanitized JSON: $($_.Exception.Message)" 'DEBUG'
            }
        }
    } else {
        Write-LogMessage "Winget version $wingetVersion does not support JSON output, using table parsing" 'DEBUG'
    }

    # Attempt 3: table parsing (fallback for older winget or when JSON fails)
    $argsUpgTbl = @('upgrade','--accept-source-agreements','--disable-interactivity')
    if ($IncludeUnknown) { $argsUpgTbl += '--include-unknown' }

    $rawTbl  = & winget @argsUpgTbl 2>&1
    $tblText = ($rawTbl | Out-String)
    if ($DiagPath) { $tblText | Out-File -LiteralPath (Join-Path $DiagPath 'winget-upgrade-raw-table.txt') -Encoding UTF8 }

    # Check for "No packages have available updates" message
    if ($tblText -match 'No (installed )?packages? (have|found)' -or $tblText -match 'No applicable upgrade found') {
        Write-LogMessage "No packages have available updates." 'INFO'
        return @()
    }

    $lines = $tblText -split '\r?\n'
    $parsedTable = Get-WingetUpgradeTableParsed -Lines $lines
    if ($null -ne $parsedTable) { return $parsedTable }

    # If we get here with no parseable output, show diagnostic info
    Write-LogMessage "Could not parse winget output. Raw output:" 'WARN'
    Write-LogMessage $tblText 'DEBUG'
    throw "Failed to parse winget output (JSON and table fallback). Run with -Diagnostics for more info."
}

# ---------------- Bootstrap ----------------
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot }
elseif ($MyInvocation.MyCommand.Path) { Split-Path -LiteralPath $MyInvocation.MyCommand.Path -Parent }
else { (Get-Location).Path }

# Initialize log file if LogPath is specified
if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $script:LogFile = $LogPath
    # Ensure log directory exists
    $logDir = Split-Path -LiteralPath $LogPath -Parent
    if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Write-LogMessage "Logging to: $LogPath" 'INFO'
}

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path -Path $ScriptDir -ChildPath 'winget-config.json'
}

try {
    $global:OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch {
    Write-LogMessage "Warning: Could not set output encoding" 'DEBUG'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-LogMessage "winget is not installed or not in PATH. Install 'App Installer' from Microsoft Store." 'ERROR'
    exit 1
}

if ($Scope -eq 'machine' -and -not (Test-Admin)) {
    Write-LogMessage "Machine scope requested, but shell is not elevated. Some upgrades may fail." 'WARN'
}

# ---------------- Load/create config ----------------
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-LogMessage "Config not found at ${ConfigPath}. Creating a sample config..." 'WARN'
    @"
{
  "IncludeOnlyIds":   [],
  "IncludeOnlyNames": [],
  "ExcludeIds":       [ "Anaconda.*" ],
  "ExcludeNames":     [ "Anaconda3 *" ],
  "ExcludeSources":   [ "msstore" ]
}
"@ | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
    Write-LogMessage "Edit ${ConfigPath} and re-run the script." 'INFO'
    exit 0
}

try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-LogMessage "Invalid JSON in ${ConfigPath}: $($_.Exception.Message)" 'ERROR'
    exit 1
}

[string[]]$IncludeOnlyIds    = @()
[string[]]$IncludeOnlyNames  = @()
[string[]]$ExcludeIds        = @()
[string[]]$ExcludeNames      = @()
[string[]]$ExcludeSources    = @()

if ($config.PSObject.Properties.Name -contains 'IncludeOnlyIds')    { $IncludeOnlyIds    = @($config.IncludeOnlyIds)    | Where-Object { $_ } }
if ($config.PSObject.Properties.Name -contains 'IncludeOnlyNames')  { $IncludeOnlyNames  = @($config.IncludeOnlyNames)  | Where-Object { $_ } }
if ($config.PSObject.Properties.Name -contains 'ExcludeIds')        { $ExcludeIds        = @($config.ExcludeIds)        | Where-Object { $_ } }
if ($config.PSObject.Properties.Name -contains 'ExcludeNames')      { $ExcludeNames      = @($config.ExcludeNames)      | Where-Object { $_ } }
if ($config.PSObject.Properties.Name -contains 'ExcludeSources')    { $ExcludeSources    = @($config.ExcludeSources)    | Where-Object { $_ } }

# ---------------- Discover ----------------
Write-LogMessage "Querying upgradable packages..."
$diagPath = if ($Diagnostics) { $ScriptDir } else { $null }

try {
    $data = Get-WingetUpgradeList -IncludeUnknown:$IncludeUnknown -DiagPath $diagPath
} catch {
    Write-LogMessage $_.Exception.Message 'ERROR'
    if ($Diagnostics) { Write-LogMessage ("Diagnostics saved to: {0} (files starting with winget-*)" -f $ScriptDir) 'INFO' }
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
    Write-LogMessage "No updates available." 'INFO'
    exit 0
}

# ---------------- Filter ----------------
$whitelistActive = ($IncludeOnlyIds.Count -gt 0 -or $IncludeOnlyNames.Count -gt 0)

$toUpgrade = foreach ($pkg in $packages) {
    $id     = FirstNotNullOrEmpty $pkg.Id $pkg.PackageIdentifier ($pkg.Package.Id)
    $name   = FirstNotNullOrEmpty $pkg.Name $pkg.PackageName     ($pkg.Package.Name)
    $source = FirstNotNullOrEmpty $pkg.Source $pkg.Repository
    $pinned = FirstNotNullOrEmpty $pkg.IsPinned

    if (-not $id -and -not $name) { continue }

    # Whitelist gate (only these); wildcards allowed
    if ($whitelistActive) {
        $inWhite = ($IncludeOnlyIds -and (MatchesAny -Text $id -Patterns $IncludeOnlyIds)) -or
                   ($IncludeOnlyNames -and (MatchesAny -Text $name -Patterns $IncludeOnlyNames))
        if (-not $inWhite) { continue }
    }

    # Skip pinned, if field present
    if ($pinned -eq $true) {
        Write-LogMessage "Skipping pinned: $name ($id)" 'INFO'
        continue
    }

    # Source exclusions (exact match)
    if ($ExcludeSources -and $source -and ($ExcludeSources -contains $source)) {
        Write-LogMessage "Skipping by source '$source': $name ($id)" 'INFO'
        continue
    }

    # Standard exclusions (wildcards)
    if ( (MatchesAny -Text $id -Patterns $ExcludeIds) -or (MatchesAny -Text $name -Patterns $ExcludeNames) ) {
        Write-LogMessage "Skipping by pattern: $name ($id)" 'INFO'
        continue
    }

    [PSCustomObject]@{
        Id        = $id
        Name      = $name
        Version   = FirstNotNullOrEmpty $pkg.Version $pkg.Installed $pkg.InstalledVersion
        Available = FirstNotNullOrEmpty $pkg.Available $pkg.AvailableVersion
        Source    = $source
    }
}

if (-not $toUpgrade -or $toUpgrade.Count -eq 0) {
    if ($whitelistActive) {
        Write-LogMessage "No packages matched the whitelist. Nothing to update." 'INFO'
    } else {
        Write-LogMessage "All upgradable packages are excluded. Nothing to update." 'INFO'
    }
    exit 0
}

Write-LogMessage ("Packages queued for upgrade ({0}):" -f $toUpgrade.Count) 'INFO'
$toUpgrade | ForEach-Object { Write-LogMessage (" - {0} [{1}] {2} -> {3} (src: {4})" -f $_.Name,$_.Id,$_.Version,$_.Available,$_.Source) 'INFO' }

# ---------------- Upgrade (smart scope fallback) ----------------
$fail = @()

function Invoke-WingetUpgrade {
    param(
        [Parameter(Mandatory)]$Pkg,
        [string]$ScopeTry  # '', 'user', or 'machine'
    )
    $upgradeArgs = @(
        'upgrade','--id', $Pkg.Id,
        '--accept-source-agreements','--accept-package-agreements',
        '--silent','--disable-interactivity','--exact'
    )
    if ($IncludeUnknown) { $upgradeArgs += '--include-unknown' }
    if ($ScopeTry) { $upgradeArgs += @('--scope', $ScopeTry) }

    $p = Start-Process -FilePath (Get-Command winget).Source -ArgumentList $upgradeArgs -PassThru -Wait -NoNewWindow
    return $p.ExitCode
}

foreach ($pkg in $toUpgrade) {
    $label = "$($pkg.Name) [$($pkg.Id)]"
    if (-not $PSCmdlet.ShouldProcess($label, "Upgrade to $($pkg.Available)")) {
        Write-Log "WhatIf: would upgrade $label" 'INFO'
        continue
    }

    Write-Log "Upgrading $label ..." 'INFO'

    # Try 1: no scope (let winget figure it out)
    $exit = Invoke-WingetUpgrade -Pkg $pkg -ScopeTry ''

    # Common “not found”/scope mismatch codes: -1978335212, sometimes 259
    if ($exit -eq -1978335212 -or $exit -eq 259) {
        if ($Scope) {
            Write-Log ("Retrying with --scope {0}: {1}" -f $Scope, $label) 'DEBUG'
            $exit = Invoke-WingetUpgrade -Pkg $pkg -ScopeTry $Scope
        } else {
            Write-Log ("Retrying with --scope {0}: {1}" -f 'machine', $label) 'DEBUG'
            $exit = Invoke-WingetUpgrade -Pkg $pkg -ScopeTry 'machine'
            if ($exit -eq -1978335212 -or $exit -eq 259) {
                Write-Log ("Retrying with --scope {0}: {1}" -f 'user', $label) 'DEBUG'
                $exit = Invoke-WingetUpgrade -Pkg $pkg -ScopeTry 'user'
            }
        }
    }

    if ($exit -ne 0) {
        Write-Log ("Failed ({0}): {1}" -f $exit, $label) 'ERROR'
        $fail += $label
        if ($StopOnError) { break }
    } else {
        Write-Log "Success: $label" 'INFO'
    }
}

if ($fail.Count -gt 0) {
    Write-LogMessage ("Completed with failures ({0})." -f $fail.Count) 'WARN'
    if ($Diagnostics) { Write-LogMessage ("See diagnostics in {0} if needed." -f $ScriptDir) 'INFO' }
    exit 2
} else {
    Write-LogMessage "All selected packages upgraded successfully." 'INFO'
    exit 0
}

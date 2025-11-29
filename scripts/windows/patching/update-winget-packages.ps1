<#
.SYNOPSIS
    Wrapper script that elevates if needed, then calls Update-ThirdPartyWithWinget.ps1

.DESCRIPTION
    This script provides a convenient wrapper around Update-ThirdPartyWithWinget.ps1 with
    automatic elevation for machine-scope updates and sensible defaults enabled.
    
    Defaults: -IncludeUnknown -Diagnostics -LogPath "<scriptdir>\logs\winget-YYYYMMDD-HHMMSS.log"

.PARAMETER Scope
    Installation scope for winget updates. 'machine' (default) or 'user'.
    Machine scope requires administrator privileges (auto-elevates if needed).

.PARAMETER WhatIf
    Shows what would be done without making changes.

.PARAMETER IncludeUnknown
    Include packages with unknown versions. Enabled by default in this wrapper.

.PARAMETER Diagnostics
    Enable diagnostic output. Enabled by default in this wrapper.

.EXAMPLE
    .\Update-WingetPackages.ps1
    
    Run with defaults (machine scope, auto-elevate, include unknown, diagnostics on)

.EXAMPLE
    .\Update-WingetPackages.ps1 -Scope user -WhatIf
    
    Preview user-scope updates without making changes

.EXAMPLE
    .\Update-WingetPackages.ps1 -Scope machine -- -StopOnError
    
    Run machine-scope updates with StopOnError passed to the main script

.NOTES
    - Requires PowerShell 5.1+ (Windows PowerShell or PowerShell 7)
    - Windows 10/11 or Windows Server 2019+
    - Winget must be installed and available
    - Requires administrator privileges for machine scope (auto-elevates)

.LINK
    https://github.com/poslogica/generalscripts
#>

param(
  [ValidateSet('user','machine')]
  [string]$Scope = 'machine',      # default to machine (most apps are machine-scope)
  [switch]$WhatIf,
  [switch]$IncludeUnknown,         # if omitted, wrapper sets it true by default
  [switch]$Diagnostics             # if omitted, wrapper sets it true by default
)

# --- Robust script folder resolution (PS 5.1 safe) ---
# Prefer $PSScriptRoot; fall back to MyInvocation; finally to current dir
$ThisScriptPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path }
                  elseif ($PSCommandPath) { $PSCommandPath }
                  else { $null }

$Here = if ($PSScriptRoot) { $PSScriptRoot }
        elseif ($ThisScriptPath) { Split-Path -Path $ThisScriptPath -Parent }
        else { (Get-Location).Path }

# --- Resolve main script next to the wrapper ---
$Main = Join-Path $Here 'Update-ThirdPartyWithWinget.ps1'
if (!(Test-Path -LiteralPath $Main)) {
  Write-Error ("Cannot find main script at: {0}" -f $Main)
  exit 1
}

# --- Auto-elevate if needed for machine scope ---
function Test-Admin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

if ($Scope -eq 'machine' -and -not (Test-Admin)) {
  $argList = @(
    '-NoProfile',
    '-ExecutionPolicy','Bypass',
    '-File', ('"{0}"' -f $ThisScriptPath),
    '-Scope', $Scope
  )
  if ($WhatIf)         { $argList += '-WhatIf' }
  if ($IncludeUnknown) { $argList += '-IncludeUnknown' }
  if ($Diagnostics)    { $argList += '-Diagnostics' }

  # Forward any extras after -- to the re-run
  $index = $args.IndexOf('--')
  if ($index -ge 0 -and $index -lt ($args.Count - 1)) {
    $forward = $args[($index + 1)..($args.Count - 1)]
    $argList += @('--')
    $argList += $forward
  }

  Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs | Out-Null
  exit 0
}

# --- Build defaulted arguments for the main script ---
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDir = Join-Path $Here 'logs'
if (!(Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logPath = Join-Path $logDir ("winget-{0}.log" -f $ts)

$call = @(
  '-NoProfile','-ExecutionPolicy','Bypass',
  '-File', ('"{0}"' -f $Main),
  '-LogPath', ('"{0}"' -f $logPath)
)

# Respect chosen scope. If user changes to -Scope user, we pass it through.
if ($Scope) { $call += @('-Scope', $Scope) }

# Defaults: enable IncludeUnknown & Diagnostics unless caller explicitly passed the switches (PSBoundParameters check)
if ($PSBoundParameters.ContainsKey('IncludeUnknown')) {
  if ($IncludeUnknown) { $call += '-IncludeUnknown' }
} else {
  $call += '-IncludeUnknown'
}
if ($PSBoundParameters.ContainsKey('Diagnostics')) {
  if ($Diagnostics) { $call += '-Diagnostics' }
} else {
  $call += '-Diagnostics'
}

if ($WhatIf) { $call += '-WhatIf' }

# Forward any extra args after a literal --
$index = $args.IndexOf('--')
if ($index -ge 0 -and $index -lt ($args.Count - 1)) {
  $forward = $args[($index + 1)..($args.Count - 1)]
  $call += @('--')
  $call += $forward
}

# --- Invoke main script ---
Start-Process -FilePath 'powershell.exe' -ArgumentList $call -Wait -NoNewWindow
exit $LASTEXITCODE

#Run normally (updates all, respects config file)
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1

#Run with diagnostic logging
#Saves raw winget outputs (JSON/table) next to the script for troubleshooting.
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -Diagnostics

#Include unknown versions
#Updates packages even if their installed version is unknown:
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -IncludeUnknown

#Stop on first error (instead of continuing with remaining packages)
powershell.exe -ExecutionPolicy Bypass -File .\.Update-ThirdPartyWithWinget.ps1 -StopOnError

#Force machine-scope installs (requires admin)
Start-Process powershell.exe -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -Scope machine'

#Combine multiple options

#Run diagnostics, include unknown versions, and stop on first error:
powershell.exe -ExecutionPolicy Bypass -File .\.Update-ThirdPartyWithWinget.ps1 -Diagnostics -IncludeUnknown -StopOnError
#Run normally (updates all, respects config file)
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1

#Run with diagnostic logging
#Saves raw winget outputs (JSON/table) next to the script for troubleshooting.
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -Diagnostics

#Include unknown versions
#Updates packages even if their installed version is unknown:
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -IncludeUnknown

#Save logs to a custom file
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -LogPath "C:\Logs\winget-upgrade.log"

#Force machine-scope installs (requires admin)
Start-Process powershell.exe -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -Scope machine'

#Test mode (no actual installs)
#Use -WhatIf to simulate updates:
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1 -WhatIf
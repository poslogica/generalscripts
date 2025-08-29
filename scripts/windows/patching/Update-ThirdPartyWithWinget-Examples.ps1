# Basic upgrade (user scope)
.\Update-ThirdPartyWithWinget.ps1

# Exclude by Id and Name, run as machine scope (recommended: elevated shell)
#.\Update-ThirdPartyWithWinget.ps1 -ExcludeIds "Google.Chrome","Adobe.*" -ExcludeNames "NVIDIA *" -Scope machine
.\Update-ThirdPartyWithWinget.ps1
powershell.exe -ExecutionPolicy Bypass -File .\Update-ThirdPartyWithWinget.ps1


# Dry-run with logging
.\Update-ThirdPartyWithWinget.ps1 -WhatIf -LogPath "$env:ProgramData\winget-upgrades.log"

# Stop on first error
.\Update-ThirdPartyWithWinget.ps1 -StopOnError

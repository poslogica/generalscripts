$ws = New-Object -ComObject WScript.Shell
$lnkPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Update Winget Packages.lnk"
$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$script = (Join-Path $PSScriptRoot 'Update-WingetPackages.ps1')
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $ps
$lnk.Arguments  = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$lnk.WorkingDirectory = $PSScriptRoot
$lnk.IconLocation = "%SystemRoot%\System32\shell32.dll,167"
$lnk.Save()
Write-Output "Shortcut created: $lnkPath"

$logPath = "C:\tools\patching\logs\"
$logFilename = "winget-$(Get-Date -f yyyy-MM-dd).log"
$fullLogPathAndFile = "$logPath$logFilename"

# Ensure the log directory exists
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
}

Write-Information "Log file used : $fullLogPathAndFile"
Start-Transcript -Path $fullLogPathAndFile -Append

# Bypass execution policy for the script process
Set-ExecutionPolicy Bypass -Scope Process -Force

# Construct the winget.exe path based on the specified version
$wingetPath = "winget.exe"

# Check if winget executable exists
# if (-not (Test-Path $wingetPath)) {
#     Write-Host "Error: winget executable not found at $wingetPath" -ForegroundColor Red
#     Stop-Transcript
#     Exit
# }

Write-Output "winget executable found at $wingetPath"

# Try to perform the upgrade and capture any errors
try {
    # Start the upgrade process for all applications, including unknown ones, silently
    Start-Process -NoNewWindow -FilePath $wingetPath -ArgumentList "upgrade", "--all", "--include-unknown", "--accept-package-agreements", "--accept-source-agreements", "--silent" -Wait

    Write-Output "Upgrade process completed successfully."
} catch {
    # Log any exceptions that occur
    Write-Output "Error during the upgrade process: $_"
    Write-Information "Error: $_"
}

# End the transcript and clean up
Stop-Transcript

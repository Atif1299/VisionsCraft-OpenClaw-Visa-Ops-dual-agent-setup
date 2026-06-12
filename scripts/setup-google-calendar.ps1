# One-time Google Calendar setup for OpenClaw consultation booking
$binDir = "$env:USERPROFILE\.openclaw\bin"
$gog = "$binDir\gog.exe"

Write-Host "=== VisionsCraft Calendar Setup ===" -ForegroundColor Cyan

if (-not (Test-Path $gog)) {
    Write-Host "Installing gog CLI..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    $zip = "$env:TEMP\gogcli_win.zip"
    Invoke-WebRequest -Uri "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_windows_amd64.zip" -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $binDir -Force
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    Write-Host "Added $binDir to user PATH (restart terminal after this)." -ForegroundColor Green
}

$env:Path = "$binDir;" + $env:Path
& $gog --version

$credPath = "$env:USERPROFILE\.openclaw\google-oauth-client.json"
if (-not (Test-Path $credPath)) {
    Write-Host ""
    Write-Host "NEXT: Create OAuth Desktop client in Google Cloud Console" -ForegroundColor Yellow
    Write-Host "  https://console.cloud.google.com/apis/credentials?project=aqueous-scout-474818-q9"
    Write-Host "  Enable Calendar API, download JSON, save as:" -ForegroundColor Yellow
    Write-Host "  $credPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Yellow
    Write-Host "  gog auth credentials `"$credPath`"" -ForegroundColor White
    Write-Host "  gog auth add ranaatif1299@gmail.com --services calendar,gmail" -ForegroundColor White
    exit 0
}

& $gog auth credentials $credPath
& $gog auth add ranaatif1299@gmail.com --services calendar,gmail
& $gog auth list

Write-Host ""
Write-Host "Done. Restart gateway: .\start-gateway.ps1" -ForegroundColor Green

# Start OpenClaw Gateway (VisionsCraft WhatsApp Lead Agent)
# Requires OpenClaw >= 2026.6.6 on Node >= 22.19 (nvm use 22.19.0)
$nvmNode = "C:\nvm4w\nodejs"
if (Test-Path $nvmNode) {
    $env:Path = "$nvmNode;$env:USERPROFILE\.openclaw\bin;" + $env:Path
} else {
    $env:Path = "$env:USERPROFILE\.openclaw\bin;" + $env:Path
}
$env:GOG_ACCOUNT = "ranaatif1299@gmail.com"

Write-Host "OpenClaw: $(openclaw --version 2>&1)" -ForegroundColor DarkGray
Write-Host "Node: $(node --version 2>&1)" -ForegroundColor DarkGray
Write-Host "Starting OpenClaw Gateway on port 18789..." -ForegroundColor Cyan
openclaw gateway --port 18789

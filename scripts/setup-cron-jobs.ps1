# Register OpenClaw cron jobs for Ops agent (run after gateway is up)
$ErrorActionPreference = "Stop"
$phone = "+923234065995"
$tz = "Asia/Karachi"

$configPath = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
if (Test-Path $configPath) {
    $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($cfg.gateway.auth.token) {
        $env:OPENCLAW_GATEWAY_TOKEN = $cfg.gateway.auth.token
    }
}

Write-Host "Creating daily founder brief (9:00 AM PKT)..." -ForegroundColor Cyan
openclaw cron add `
  --name "Daily founder brief" `
  --cron "0 9 * * *" `
  --tz $tz `
  --agent ops `
  --session isolated `
  --message "Run founder-briefing skill: read prospects/prospects.jsonl, leads/leads.jsonl, today's calendar via gog. Summarize for Muhammad in under 15 lines." `
  --announce `
  --channel whatsapp `
  --to $phone

Write-Host "Creating weekly B2B research (Monday 10:00 AM PKT)..." -ForegroundColor Cyan
openclaw cron add `
  --name "Weekly B2B research" `
  --cron "0 10 * * 1" `
  --tz $tz `
  --agent ops `
  --session isolated `
  --message "Run b2b-research skill: find 5 new B2B prospects matching knowledge/icp.md. Append to prospects/prospects.jsonl. Send numbered summary." `
  --announce `
  --channel whatsapp `
  --to $phone

Write-Host "Cron jobs registered. List with: openclaw cron list" -ForegroundColor Green

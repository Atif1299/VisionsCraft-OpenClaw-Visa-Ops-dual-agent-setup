# Google Calendar booking for WhatsApp consultations

When a lead books a call, OpenClaw can create a Google Calendar event and email invites to **you** and the **lead**.

## One-time setup (required)

### 1. gog CLI (already installed)

Location: `C:\Users\dell\.openclaw\bin\gog.exe`

Add to your user PATH (run once in PowerShell):

```powershell
$bin = "$env:USERPROFILE\.openclaw\bin"
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$bin", "User")
```

Restart terminal and gateway after this.

### 2. Google Cloud OAuth client

1. Open https://console.cloud.google.com/apis/credentials?project=aqueous-scout-474818-q9
2. **Create credentials** → **OAuth client ID** → **Desktop app**
3. Enable **Google Calendar API** for the project
4. Download JSON → save as `C:\Users\dell\.openclaw\google-oauth-client.json`

### 3. Authorize gog

```powershell
$env:Path = "$env:USERPROFILE\.openclaw\bin;" + $env:Path
gog auth credentials "$env:USERPROFILE\.openclaw\google-oauth-client.json"
gog auth add ranaatif1299@gmail.com --services calendar,gmail
gog auth list
```

A browser window opens — sign in with **ranaatif1299@gmail.com** and allow Calendar access.

### 4. Test booking

```powershell
.\scripts\book-consultation.ps1 `
  -Name "Test Lead" `
  -Email "your-test-email@gmail.com" `
  -From "2026-06-03T16:00:00+05:00" `
  -To "2026-06-03T16:30:00+05:00" `
  -Notes "Test from setup"
```

Check both inboxes for the Google Calendar invite.

### 5. Restart OpenClaw gateway

```powershell
openclaw gateway stop
.\start-gateway.ps1
```

Send `/reset` in WhatsApp or use a new test number so the agent loads updated `AGENTS.md`.

## What the agent does on WhatsApp

1. Asks for **name**, **email**, and **preferred time**
2. Runs `gog calendar create` with `--send-updates all`
3. Confirms: "Calendar invites sent — please check your email"

## Manual booking script

```powershell
cd "C:\Users\dell\OneDrive\Desktop\Openclaw Setup"
.\scripts\book-consultation.ps1 -Name "Atif" -Email "lead@example.com" -From "..." -To "..."
```

## Calendar operations (create / update / delete / conflicts)

The WhatsApp agent uses these scripts via `exec`:

| Script | Purpose |
|--------|---------|
| `scripts/book-consultation.ps1` | Create event + check conflicts |
| `scripts/calendar-update-event.ps1` | Update description, time, title |
| `scripts/calendar-delete-event.ps1` | Cancel event |
| `scripts/calendar-check-slot.ps1` | Check if slot is free |

Skill file: `workspace/skills/calendar-ops/SKILL.md`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `gog: command not found` | Add `~\.openclaw\bin` to PATH; restart gateway |
| `No tokens stored` | Run `gog auth add` (step 3) |
| Agent doesn't book | Lead must give **email**; check `openclaw skills list` shows gog **ready** |
| No invite email | Use `--send-updates all` on create |

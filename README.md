# VisionsCraft OpenClaw

Production setup for **VisionsCraft** — a dual-agent WhatsApp growth system on [OpenClaw](https://docs.openclaw.ai/).

| Agent | Workspace | Who messages | Role |
|-------|-----------|--------------|------|
| **Visa** | `workspace/` | Everyone except founder phones | Public inbound leads, booking, qualification |
| **Ops** | `workspace-ops/` | Founder phones only | B2B research, briefings, outreach drafts |

Shared company knowledge lives in `knowledge/` (ICP, case studies, pricing policy, templates).

---

## Requirements

- **Windows** (local gateway; GCP migration deferred — see [GCP-MIGRATION.md](./GCP-MIGRATION.md))
- **Node.js 22.19+** — `nvm install 22.19.0` then `nvm use 22.19.0`
- **OpenClaw 2026.6.6+** — `npm install -g openclaw@latest`
- **OpenAI API key** in `~/.openclaw/.env` (not in this repo)
- **Google Calendar** via `gog` — [CALENDAR-SETUP.md](./CALENDAR-SETUP.md)

---

## Quick start (new machine)

1. Clone this repo.
2. Copy [openclaw.example.json](./openclaw.example.json) → `~/.openclaw/openclaw.json` and set paths to your user.
3. Add `OPENAI_API_KEY` to `~/.openclaw/.env`.
4. Link WhatsApp and calendar per [SETUP.md](./SETUP.md).
5. Deploy workspaces to live OpenClaw state:

```powershell
cd "path\to\Openclaw Setup"
powershell -ExecutionPolicy Bypass -File .\scripts\sync-workspaces.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\cleanup-live-workspace.ps1
```

6. Start the gateway:

```text
start-gateway.bat
```

7. Register cron (once, gateway running):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-cron-jobs.ps1
openclaw cron list
```

---

## Start gateway (daily)

**Always use** (cmd or double-click):

```text
start-gateway.bat
```

Or:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-gateway.ps1
```

- Keep the process running during business hours (or use the scheduled task).
- **One gateway only** — use `start-gateway.bat` **or** [install-gateway-task.ps1](./scripts/install-gateway-task.ps1), not both.
- If you see “gateway already running”, an instance is already up.

Optional auto-start at Windows logon:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-gateway-task.ps1
```

---

## Health check

```powershell
openclaw gateway status
openclaw channels status
openclaw agents list --bindings
openclaw cron list
```

Dashboard: http://127.0.0.1:18789/

---

## WhatsApp routing

| Sender phone | Agent | Expected tone |
|--------------|-------|---------------|
| `+923234065995`, `+923121365995` | **Ops** | Internal growth assistant |
| Any other number | **Visa** | Public lead / VisionsCraft consultant |

**Important:** Only **founder phones** belong in `bindings` → Ops. Any other number (friends, leads, testers) must **not** be listed there or they will get Ops instead of Visa.

Test after config changes:

1. Founder phone → “what’s today” → Ops brief tone  
2. Other phone → “hi” → Visa (warm, VisionsCraft-aware)  
3. Use **session reset** in dashboard if an old conversation still uses outdated replies

Bindings template: [openclaw.example.json](./openclaw.example.json)

---

## After editing this repo

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-workspaces.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\cleanup-live-workspace.ps1
```

Then restart gateway or reset affected WhatsApp sessions.

---

## Repo layout

```
Openclaw Setup/
├── workspace/              # Visa — SOUL, AGENTS, skills, calendar scripts
├── workspace-ops/          # Ops — SOUL, AGENTS, b2b-research, briefing
├── knowledge/              # Shared ICP, case studies, offer, templates
├── scripts/                # sync, cron, backup, calendar helpers
├── openclaw.example.json   # Config template (copy to ~/.openclaw/)
├── SETUP.md                # Full setup guide
├── VALIDATION.md           # Phases 1–4 test report
└── start-gateway.bat       # Gateway launcher
```

---

## Data files (live only — gitignored)

| Path | Purpose |
|------|---------|
| `~/.openclaw/workspace/leads/leads.jsonl` | Inbound leads |
| `~/.openclaw/workspace/bookings.jsonl` | Calendar booking IDs |
| `~/.openclaw/workspace-ops/prospects/prospects.jsonl` | B2B targets |
| `~/.openclaw/openclaw.json` | Live config + gateway auth |
| `~/.openclaw/.env` | API keys |

`sync-workspaces.ps1` copies `leads.jsonl` from Visa → Ops on each sync.

---

## Automation

| Job | Schedule | Agent |
|-----|----------|-------|
| Daily founder brief | 9:00 AM PKT | Ops |
| Weekly B2B research | Mon 10:00 AM PKT | Ops |

Web search: **`parallel-free`** (no API key). See [SETUP.md](./SETUP.md) for cron pairing issues.

---

## Push to GitHub

This folder is **source config**, not the live OpenClaw runtime. Safe to publish if secrets stay out.

**Never commit:** `~/.openclaw/openclaw.json` (has gateway token/password), `.env`, WhatsApp creds, `leads.jsonl`, `bookings.jsonl`, `prospects.jsonl`. See [.gitignore](./.gitignore).

First-time push:

```powershell
cd "path\to\Openclaw Setup"
git init
git add .
git status   # confirm no secrets or PII
git commit -m "VisionsCraft OpenClaw: Visa + Ops dual-agent setup"
git branch -M main
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git push -u origin main
```

Replace `YOUR_USER/YOUR_REPO` with your GitHub repo. Use a **private** repo if you prefer (phone numbers in docs are semi-public).

---

## Current status (2026-06-12)

**Working (verified):**

- Gateway running, probe OK  
- WhatsApp linked  
- Dual-agent routing (2 founder phones → Ops, everyone else → Visa)  
- Cron: 2 jobs registered  
- Sync / cleanup scripts  
- B2B research + lead sync  
- Phases 1–4 — see [VALIDATION.md](./VALIDATION.md)

**Good enough to stop for now, but manually verify when you can:**

- Live WhatsApp tone after latest `SOUL.md` updates (reset old sessions first)  
- End-to-end calendar booking from a test lead  
- Cron actually delivers at 9 AM / Monday 10 AM (first run observation)  
- Gateway stays up on your laptop (offline messages may need a new ping — see [SETUP.md](./SETUP.md) troubleshooting)

**Deferred (not blocking push):**

- Phase 5: website alignment, outbound rhythm, Upwork floor  
- GCP migration  
- Gateway token rotation (`openclaw doctor --generate-gateway-token`)  
- Plugin version drift warning — run `openclaw gateway status --deep` if needed

---

## Docs

| Doc | Purpose |
|-----|---------|
| [SETUP.md](./SETUP.md) | Full install & troubleshooting |
| [VALIDATION.md](./VALIDATION.md) | Phase 1–4 pass report |
| [CALENDAR-SETUP.md](./CALENDAR-SETUP.md) | Google Calendar / gog |
| [CRON-SETUP.md](./CRON-SETUP.md) | Cron & pairing |
| [GCP-MIGRATION.md](./GCP-MIGRATION.md) | Future cloud hosting |

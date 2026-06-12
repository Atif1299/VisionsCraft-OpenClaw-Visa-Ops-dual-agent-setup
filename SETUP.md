# VisionsCraft OpenClaw — Setup Guide

OpenClaw runs **two agents** on one WhatsApp business number:

| Agent | Workspace | Audience |
|-------|-----------|----------|
| **Visa** | `workspace/` → `~/.openclaw/workspace` | Public inbound leads |
| **Ops** | `workspace-ops/` → `~/.openclaw/workspace-ops` | Muhammad (founder phones) |

Shared company knowledge: `knowledge/` (synced to both workspaces).

---

## 1. Prerequisites

- Node.js **22.19+** (`nvm install 22.19.0` then `nvm use 22.19.0`)
- OpenClaw **2026.6.6+** (`npm install -g openclaw@latest`)
- OpenAI API key in `~/.openclaw/.env`
- Google Calendar (`gog`) — [CALENDAR-SETUP.md](./CALENDAR-SETUP.md)
- Web search: **free** — `tools.web.search.provider: parallel-free` (no API key; see README)

---

## 2. First-time / refresh deploy

```powershell
cd "C:\Users\dell\OneDrive\Desktop\Openclaw Setup"
powershell -ExecutionPolicy Bypass -File .\scripts\sync-workspaces.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\cleanup-live-workspace.ps1
```

Live config: `C:\Users\dell\.openclaw\openclaw.json` (multi-agent `visa` + `ops` + bindings).

---

## 3. Start gateway

```text
start-gateway.bat
```

Health:

```powershell
openclaw gateway status
openclaw channels status
openclaw agents list --bindings
```

---

## 4. Workspace layout (repo)

```
Openclaw Setup/
├── workspace/              # Visa (public)
│   ├── SOUL.md, AGENTS.md, faq.md
│   ├── skills/             # calendar, pricing, lead-logging, ...
│   ├── calendar/           # script wrappers
│   └── leads/leads.jsonl
├── workspace-ops/          # Ops (internal)
│   ├── SOUL.md, AGENTS.md, HEARTBEAT.md
│   ├── skills/             # b2b-research, outreach, briefing
│   └── prospects/prospects.jsonl
├── knowledge/              # ICP, case studies, templates
└── scripts/
    ├── sync-workspaces.ps1
    ├── setup-cron-jobs.ps1
    ├── install-gateway-task.ps1
    └── backup-openclaw.ps1
```

---

## 5. Skills

**Visa:** consultation-booking, calendar-ops, pricing-scoping, case-study-matcher, lead-logging

**Ops:** b2b-research, outreach-drafter, founder-briefing

---

## 6. Automation

**Heartbeat (Ops):** every 30m — checks in [workspace-ops/HEARTBEAT.md](./workspace-ops/HEARTBEAT.md)

**Cron:** run once:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-cron-jobs.ps1
```

Requires gateway running 24/7 on laptop (or GCP later). See [CRON-SETUP.md](./CRON-SETUP.md) if CLI reports pairing errors.

---

## 7. Test routing

1. From **your phone** → WhatsApp business number → ask "find 3 ed-tech prospects" → **Ops**
2. From **another phone** → "hi" → **Visa** intro
3. Book test consultation → calendar scripts + RSVP reminder in reply

---

## 8. Backup

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\backup-openclaw.ps1
```

Run weekly; output under `openclaw-backup/`.

---

## 9. Troubleshooting

| Issue | Fix |
|-------|-----|
| Gateway exits instantly from cmd | Use `start-gateway.bat` not raw `.ps1` |
| "Gateway already running" | One instance only; `openclaw gateway stop` then one start |
| Wrong agent answers | `openclaw agents list --bindings`; verify phone E.164 |
| Calendar not updating | `exec` exit 0 required; use `calendar\lookup-booking.ps1` |
| B2B research empty | Check `openclaw config get tools.web.search` (provider: `parallel-free`); gateway must be running |
| Cron silent / empty list | Gateway up; run `setup-cron-jobs.ps1`; `openclaw cron list` should show 2 jobs |
| Message sent while internet was off — no reply until they text again | Gateway must stay running; when Wi‑Fi returns run `openclaw channels status`. WhatsApp replays some backlog on reconnect, but messages older than ~1 min from before reconnect may be skipped by OpenClaw — sender may need one new message to trigger a reply. Keep laptop awake + gateway window open for best catch-up. |
| CLI pairing / scope errors | Approve in dashboard or run `openclaw devices approve --latest` with gateway token |
| Calendar scripts fail | Check `calendar-config.json` scriptsDir points to `~\.openclaw\workspace\scripts` after sync |

---

## 10. GCP migration

Deferred. See [GCP-MIGRATION.md](./GCP-MIGRATION.md).

---

## Links

- [OpenClaw docs](https://docs.openclaw.ai/)
- [Multi-agent routing](https://docs.openclaw.ai/concepts/multi-agent)
- [Automation / cron](https://docs.openclaw.ai/automation/cron-jobs)
- [VisionsCraft site](https://visionscraft-web-823333525467.europe-west1.run.app/)

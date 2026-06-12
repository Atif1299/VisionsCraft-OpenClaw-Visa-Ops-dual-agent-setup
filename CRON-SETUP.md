# Cron jobs (Ops agent)

Register after gateway is running and CLI can connect:

```powershell
openclaw gateway status
powershell -ExecutionPolicy Bypass -File .\scripts\setup-cron-jobs.ps1
openclaw cron list
```

If you see `pairing required`, open the dashboard http://127.0.0.1:18789/ or ensure gateway token matches config.

## Jobs created by setup-cron-jobs.ps1

| Name | Schedule | Timezone | Agent |
|------|----------|----------|-------|
| Daily founder brief | `0 9 * * *` | Asia/Karachi | ops |
| Weekly B2B research | `0 10 * * 1` | Asia/Karachi | ops |

Delivery: WhatsApp announce to +923234065995

## Manual add (if script fails)

```powershell
openclaw cron add --name "Daily founder brief" --cron "0 9 * * *" --tz Asia/Karachi --agent ops --session isolated --message "Run founder-briefing skill." --announce --channel whatsapp --to +923234065995
```

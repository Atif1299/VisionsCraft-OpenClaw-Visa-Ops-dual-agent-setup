---
name: founder-briefing
description: Daily summary for Muhammad — calendar, leads, prospects, stale follow-ups. Used by cron and on-demand.
---

# Founder briefing

## When to use

Morning brief, "what's today", cron daily 9 AM PKT job.

## Steps

1. **Calendar:** list today's consults (gog, organizer ranaatif1299@gmail.com, Asia/Karachi):
   ```powershell
   gog calendar events primary --account ranaatif1299@gmail.com --from "TODAY_START_ISO+05:00" --to "TODAY_END_ISO+05:00"
   ```
2. **Leads:** read `leads/leads.jsonl` (synced from Visa inbound):
   - Count by `status` and `band` (L/XL = priority)
   - Flag `new` or `qualified` older than **48h** (stale follow-up)
3. **Prospects:** count `prospects/prospects.jsonl` with `status: new`.
4. Format under 15 lines:
   - Consultations today
   - Hot leads (L/XL) + stale leads
   - New prospects
   - One suggested action (from `knowledge/offer.md` if drafting scope)

If nothing actionable, output `NO_REPLY` for cron or `HEARTBEAT_OK` for heartbeat context.

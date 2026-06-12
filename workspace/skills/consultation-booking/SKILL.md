---
name: consultation-booking
description: Create a Google Calendar consultation event with email invites for VisionsCraft leads. Use when a WhatsApp lead confirms a consultation (name + email + date/time).
---

# Consultation booking (Google Calendar)

Read **`calendar-config.json`** for organizer email, timezone, and `scriptsDir`.

## When to use

Lead agreed to a consultation and you have:
- **Name**
- **Email** (required — ask if missing)
- **Date/time** — interpret in timezone from config

## Steps

1. Confirm details back to the lead in one short message.
2. Run lookup — if active booking exists, reschedule with `calendar-update-event.ps1` instead of creating again:

```powershell
powershell -File "{scriptsDir}\lookup-booking.ps1" -Email "lead@example.com"
```

3. Compute `--from` and `--to` in ISO 8601 with config offset (default **30 minutes**).
4. Book:

```powershell
powershell -File "{scriptsDir}\book-consultation.ps1" -Name "..." -Email "..." -From "ISO" -To "ISO" -Notes "..." -Phone "+92..."
```

5. Script writes **`bookings.jsonl`** automatically. Also append **`leads/leads.jsonl`** with `"status":"booked"`.
6. Tell the lead: calendar invite sent to their email.

## Calendly alternative

If they prefer picking a slot: send `calendlyUrl` from `calendar-config.json`.

## If booking script fails

Do not claim the invite was sent. Say the team will follow up from info@visionscraft.com.

## Do not

- Book without an email
- Hardcode event IDs or single-lead names in replies
- Create a second event when lookup shows an active booking (exit 3)

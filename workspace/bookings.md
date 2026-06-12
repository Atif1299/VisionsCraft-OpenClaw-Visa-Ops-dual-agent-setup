# Consultation bookings (multi-lead)

**Do not hardcode lead names or event IDs in this file.**

## Source of truth

- **`bookings.jsonl`** — one JSON object per line (`eventId`, `email`, `phone`, `name`, `from`, `to`, `status`, `createdAt`)
- **`calendar-config.json`** — organizer email, timezone, Calendly URL, scripts path

## Before update / cancel / reschedule

1. Get the lead's **email** (preferred) or WhatsApp **phone** from the conversation.
2. Run lookup (replace email):

```powershell
powershell -File "{scriptsDir}\lookup-booking.ps1" -Email "lead@example.com"
```

3. Use the printed `EVENT_ID` with `calendar-update-event.ps1` or `calendar-delete-event.ps1`.
4. If `NOT_FOUND`, either book new (`book-consultation.ps1`) or list calendar events for that email.

## After a new booking

`book-consultation.ps1` appends an `active` row to `bookings.jsonl` automatically.

## Calendly (optional self-serve)

Share `calendar-config.json` → `calendlyUrl` when the lead prefers picking a slot themselves.

---
name: calendar-ops
description: Create, update, delete, and check conflicts for VisionsCraft Google Calendar consultations via gog CLI. Use for any booking, reschedule, cancel, or calendar change request.
---

# Calendar operations (gog)

Read **`calendar-config.json`** in the workspace for `organizerEmail`, `calendarId`, `timezone`, `utcOffset`, `calendlyUrl`, and `scriptsDir`.

## Before any change

1. Run **lookup** for this lead (email preferred):

```powershell
powershell -File "{scriptsDir}\lookup-booking.ps1" -Email "lead@example.com"
```

2. Use the returned `EVENT_ID` for updates/deletes. If `NOT_FOUND`, create with `book-consultation.ps1` (do not invent an event id).
3. If updating an existing booking, use **update** — never create a duplicate for the same email.
4. Use the **current year** in ISO dates with offset from config (e.g. `+05:00`).
5. If `exec` fails (non-zero exit), tell the user it failed — do not say updated.

## Check if a slot is free

```powershell
powershell -File "{scriptsDir}\calendar-check-slot.ps1" -From "2026-06-03T10:00:00+05:00" -To "2026-06-03T10:30:00+05:00"
```

Or: `gog calendar conflicts --account {organizerEmail} --from ISO --to ISO --cal primary`

If busy: suggest 2–3 alternative slots.

## Create new consultation

Only when lookup returns `NOT_FOUND`.

```powershell
powershell -File "{scriptsDir}\book-consultation.ps1" -Name "..." -Email "..." -From "ISO" -To "ISO" -Notes "..." -Phone "+92..."
```

Exit code 2 = conflict. Exit code 3 = already has active booking — update instead.

## Update existing event

By email (script resolves event id):

```powershell
powershell -File "{scriptsDir}\calendar-update-event.ps1" -Email "lead@example.com" -Description "new notes" -NotifyAttendees
```

Or with explicit id from lookup output:

```powershell
powershell -File "{scriptsDir}\calendar-update-event.ps1" -EventId "EVENT_ID" -From "ISO" -To "ISO" -NotifyAttendees
```

## Delete / cancel

```powershell
powershell -File "{scriptsDir}\calendar-delete-event.ps1" -Email "lead@example.com" -NotifyAttendees
```

## List upcoming events (fallback)

```powershell
gog calendar events primary --account {organizerEmail} --from "START_ISO" --to "END_ISO"
```

## Rules

- **exec only** — never `sessions_spawn` for calendar
- Confirm on WhatsApp only after exec succeeds
- Same lead changes topic → update existing event, do not create a new one
- Self-serve booking → share `calendlyUrl` from config when appropriate

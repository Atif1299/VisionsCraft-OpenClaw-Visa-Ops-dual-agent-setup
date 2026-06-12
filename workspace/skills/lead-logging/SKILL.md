# Lead logging



Schema: see `knowledge/leads-schema.md`.



## When to log



After you have at least **name** and **need** from the conversation.



## Before logging



1. Run **lead-scoring** skill → get `band` (S|M|L|XL) and `score` (cold|warm|hot).

2. Then append to `leads/leads.jsonl`.



## How



Append one JSON line to `leads/leads.jsonl`:



```json

{"name":"...","email":"...","phone":"...","need":"...","industry":"...","status":"new","source":"whatsapp","band":"L","score":"hot","createdAt":"ISO","updatedAt":"ISO"}

```



Use `exec` to append (PowerShell):



```powershell

$line = '{"name":"...","need":"...","band":"L","score":"warm","status":"new","source":"whatsapp","createdAt":"' + (Get-Date).ToUniversalTime().ToString('o') + '","updatedAt":"' + (Get-Date).ToUniversalTime().ToString('o') + '"}'

Add-Content -Path "leads\leads.jsonl" -Value $line -Encoding utf8

```



Run from workspace cwd.



## Status updates



- `qualified` — scoping done, interested in call

- `booked` — calendar event created

- Append new line with updated status if easier than editing



## Hot leads (L/XL + hot/warm)



Offer Calendly after logging. Mention Muhammad for XL retainers.


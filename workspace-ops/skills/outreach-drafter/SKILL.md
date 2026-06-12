---
name: outreach-drafter
description: Draft cold email or LinkedIn message for a prospect using knowledge/outreach-templates.md. Draft only — never send.
---

# Outreach drafter

## When to use

Muhammad asks to draft outreach for a company or prospect row.

## Steps

1. Read prospect from `prospects/prospects.jsonl` (match company name or url).
2. Read `knowledge/outreach-templates.md` and relevant case study.
3. Output draft in chat — email subject + body OR LinkedIn note.
4. Say: "Review and send yourself — I won't send automatically."

## Do not

- Send email, LinkedIn, or WhatsApp to prospects
- Include pricing numbers

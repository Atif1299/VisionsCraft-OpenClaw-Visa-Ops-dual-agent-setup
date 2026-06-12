---
name: b2b-research
description: Find B2B prospects matching knowledge/icp.md using web_search and web_fetch; append to prospects/prospects.jsonl.
---

# B2B research

## When to use

Muhammad asks to find companies, prospects, targets, or weekly research cron runs.

## Steps

1. Read `knowledge/icp.md` — **Tier 1 first** (SaaS, production RAG, automation, voice).
2. Read `knowledge/positioning.md` and `knowledge/stack.md` for search keywords.
3. Use `web_search` (provider: **parallel-free**, no API key) — prioritize these query patterns:
   - "SaaS startup AI agent integration"
   - "SaaS company RAG knowledge base"
   - "n8n automation agency client"
   - "AI voice agent booking startup"
   - "Series A SaaS support automation"
   - UK/US/EU remote SaaS founders hiring AI engineer
   - Secondary only: "ed-tech Pakistan", "e-commerce Lahore"
4. Use `web_fetch` on promising homepages — look for: agent/RAG hiring, "AI in product", burned-by-chatbot signals.
5. Append each prospect to `prospects/prospects.jsonl` (schema: `knowledge/prospects-schema.md`):
   - company, url, industry, score (1–5), status: `new`, notes, createdAt
   - Score 5 = SaaS + agent/RAG pain + US/UK/EU; Score 3 = generic chatbot ask; Score 1 = <$300 commodity
6. Reply with numbered summary (company, url, one-line why fit, suggested case study file).

## Do not

- Contact companies automatically
- Add duplicates (same url) — skip if already in file
- Default to Pakistan ed-tech when ICP says SaaS first

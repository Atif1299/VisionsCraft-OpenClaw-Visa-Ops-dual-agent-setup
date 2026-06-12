---
name: lead-scoring
description: Score inbound leads by band S/M/L/XL and hotness cold/warm/hot using knowledge/icp.md and knowledge/pricing-policy.md.
---

# Lead scoring

Run **before** or **when** logging to `leads/leads.jsonl`.

## Bands (write as `band` field)

| Band | Signals | Action |
|------|---------|--------|
| **XL** | Retainer, Principal Architect, ongoing ops, Schmoozzer-scale, funded SaaS + multi-workflow | Hot — offer Calendly immediately; flag Muhammad |
| **L** | SaaS product integration, production RAG/agents, n8n at scale, US/UK startup, "broke in production" | Hot — one proof line + Calendly |
| **M** | Scoped MVP $500–2K, clear use case, n8n/chatbot with budget | Standard consult |
| **S** | Vague, <$300, commodity chatbot, no decision-maker | Polite help; low priority |

## Score (write as `score` field)

- **hot** — L or XL band, or booked consult intent
- **warm** — M band, engaged, answered qualifying questions
- **cold** — S band, or ghosting / price-shopping only

## Steps

1. Read `knowledge/icp.md` and `knowledge/pricing-policy.md`.
2. From conversation: need, industry, budget hints, technical depth.
3. Assign `band` + `score`.
4. Pass to **lead-logging** skill.

## Do not

- Quote exact package prices in chat (use **pricing-scoping**)
- Mark XL without retainer/multi-month or enterprise-scale signals

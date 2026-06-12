# leads.jsonl schema (one JSON object per line)



```json

{

  "id": "uuid-or-timestamp",

  "name": "Lead Name",

  "email": "lead@example.com",

  "phone": "+92...",

  "company": "optional",

  "need": "short description",

  "industry": "education|ecommerce|saas|other",

  "status": "new|qualified|booked|closed|lost",

  "source": "whatsapp",

  "band": "S|M|L|XL",

  "score": "cold|warm|hot",

  "createdAt": "ISO-8601",

  "updatedAt": "ISO-8601",

  "notes": "optional"

}

```



**band** — internal deal size (see `knowledge/pricing-policy.md`, **lead-scoring** skill).  

**score** — engagement temperature.



Visa appends via **lead-scoring** then **lead-logging** after capturing name + need (+ email when available).


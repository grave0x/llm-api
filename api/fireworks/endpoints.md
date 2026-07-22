# Fireworks AI API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `fireworks.ai` | Marketing / SPA |

All paths return SPA catch-all (200). Well-known API: `https://api.fireworks.ai/v1` (OpenAI-compatible):
```bash
curl -X POST "https://api.fireworks.ai/v1/chat/completions" \
  -H "Authorization: Bearer <fw_api_key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"accounts/fireworks/models/mixtral-8x7b-instruct","messages":[{"role":"user","content":"Hello"}]}'
```

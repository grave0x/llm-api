# Mistral AI API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `chat.mistral.ai` | Le Chat (403 without auth) |
| `console.mistral.ai` | La Plateforme console (307 redirect) |

## console.mistral.ai API

| Path | Status | Notes |
|------|--------|-------|
| `/api/v1` | **401** | Live API endpoint (needs auth) |
| `/api/v2` | **401** | Live API endpoint v2 (needs auth) |
| `/metrics` | **403** | Blocked |

Well-known API: `https://api.mistral.ai/v1` (OpenAI-compatible):
```bash
curl -X POST "https://api.mistral.ai/v1/chat/completions" \
  -H "Authorization: Bearer <mistral_api_key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral-large-latest","messages":[{"role":"user","content":"Hello"}]}'
```

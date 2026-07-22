# Together AI API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `api.together.xyz` | API backend |

## API

Base URL: `https://api.together.xyz`

| Path | Method | Status | Purpose |
|------|--------|--------|---------|
| `/` | GET | 307 | Redirect |
| `/v1/models` | GET | 401 | List models (needs API key) |
| `/v1/chat/completions` | GET | 404 | — |
| `/v1/chat/completions` | POST | **401** | **Chat completions endpoint exists** |
| `/v1/completions` | POST | **405** | **Completions endpoint exists** |
| `/v1/images` | GET | 404 | — |

The `/v1/chat/completions` and `/v1/completions` endpoints exist and return 401/405 — they expect an API key.

```bash
curl -X POST "https://api.together.xyz/v1/chat/completions" \
  -H "Authorization: Bearer <together_api_key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"mistralai/Mixtral-8x7B-Instruct-v0.1","messages":[{"role":"user","content":"Hello"}]}'
```

## Infrastructure

- **Auth**: Bearer token
- **Models**: 100+ open models (Mistral, Llama, Mixtral, etc.)

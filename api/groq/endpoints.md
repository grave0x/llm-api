# Groq API endpoints (LPU inference)

## Sites

| Domain | Purpose |
|--------|---------|
| `groq.com` | Marketing site |
| `console.groq.com` | API console |
| `chat.groq.com` | Chat interface |
| `community.groq.com` | Community forum |
| `api.groq.com` | API backend |
| `appgen.groqlabs.com` | App generation (GroqLabs) |

## API

Base URL: `https://api.groq.com`

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | API root |
| `/openai/v1` | 404* | OpenAI-compatible API (referenced in page HTML) |

*The path `https://api.groq.com/openai/v1` was found in groq.com page source as `\"https://api.groq.com/openai/v1\\\"` — likely the real API endpoint behind a different hostname or requiring specific headers.

Known public endpoint:
```bash
# OpenAI-compatible chat completions
curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
  -H "Authorization: Bearer <groq_api_key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"mixtral-8x7b-32768","messages":[{"role":"user","content":"Hello"}]}'
```

## Infrastructure

- **Auth**: API key (Bearer token)
- **Models**: Mixtral, Llama, Gemma (fast LPU inference)

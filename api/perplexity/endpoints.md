# Perplexity AI API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `perplexity.ai` | Main search SPA |
| `frontend-cdn.perplexity.ai` | Static assets / fonts |
| `pplx-next-static-public.perplexity.ai` | Next.js SPA bundles |
| `edge.perplexity.ai` | Edge functions / image serving |

## Infrastructure

- **Framework**: Next.js SPA
- **CDN**: `frontend-cdn.perplexity.ai`, `pplx-next-static-public.perplexity.ai`
- **Edge**: `edge.perplexity.ai` (image serving `/image`)
- **Auth**: Session cookies

Well-known API: `https://api.perplexity.ai` (OpenAI-compatible):
```bash
curl -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer <pplx_api_key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar-pro","messages":[{"role":"user","content":"Hello"}]}'
```

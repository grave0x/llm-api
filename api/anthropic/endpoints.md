# Anthropic / Claude API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `claude.ai` | Claude chat SPA (403 without auth) |
| `console.anthropic.com` | API console |
| `assets-proxy.anthropic.com` | Static assets / JS bundles |

## claude.ai

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 403 | Login required |
| `/api` | 200 | SPA catch-all (real API behind auth) |

## console.anthropic.com

| Path | Method | Status | Purpose |
|------|--------|--------|---------|
| `/` | GET | 200 | Console dashboard |
| `/v1/complete` | GET | **405** | **Text completion endpoint exists** |
| `/v1/messages` | GET | **405** | **Messages API endpoint exists** |
| `/v1/chat` | GET | 404 | No such path |
| `/docs` | GET | 200 | Documentation |

The `/v1/complete` and `/v1/messages` endpoints return 405 (Method Not Allowed) on GET — they accept POST with API key auth:

```bash
curl -X POST "https://console.anthropic.com/v1/messages" \
  -H "x-api-key: <key>" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":1024,"messages":[{"role":"user","content":"Hello"}]}'
```

## Infrastructure

- **CDN**: `assets-proxy.anthropic.com` (hash-versioned JS bundles)
- **Auth**: `x-api-key` header, session cookies
- **Official API**: `api.anthropic.com/v1/messages` (well-known)

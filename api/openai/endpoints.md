# OpenAI / ChatGPT API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `chatgpt.com` | ChatGPT SPA |
| `platform.openai.com` | API console |
| `api.oaistatsig.com` | Statsig feature flags (found in HTML) |

## chatgpt.com

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | Main chat SPA |
| `/api` | 200 | SPA catch-all |
| `/v1` | 200 | SPA catch-all |
| `/backend-api` | 200 | SPA catch-all (real API path) |
| `/backend-anon` | 403 | Anonymous backend (needs auth) |
| `/admin` | — | Internal (found in JS) |
| `/am` | — | Internal (found in JS) |

## platform.openai.com

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | Dashboard |
| `/api` | 403 | API (needs login) |
| `/api/docs` | 403 | API docs (needs login) |
| `/v1` | 200 | SPA catch-all |

## chatgpt.com/graphql

| Method | Status | Purpose |
|--------|--------|---------|
| GET | **405** | GraphQL endpoint exists, Method Not Allowed on GET |
| POST | **405** | Also returns 405 — expects specific query format |

The endpoint is live but rejects unauthenticated requests without proper cookies/Bearer token.

```bash
# Would need auth headers
curl -X POST "https://chatgpt.com/graphql" \
  -H "Authorization: Bearer <session_token>" \
  -H "Content-Type: application/json" \
  -d '{"query":"query { __typename }"}'
```

## Infrastructure

- **CDN**: `cdn.openai.com`
- **Auth**: Session cookies, Bearer token for API
- **Official API**: `api.openai.com/v1` (well-known)
- **GraphQL**: `/graphql` (live, requires auth)

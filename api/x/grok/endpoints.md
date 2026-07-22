<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

# X.com / Grok API endpoints

Discovered by probing the live site and scanning React SPA JS bundle. Site is React SPA served from `abs.twimg.com`. Grok (xAI) chat interface lives at `x.com/i/grok`. Backend API at `grok-api.gcp.mouseion.dev`.

## Subdomains

| Domain | Purpose |
|--------|---------|
| `x.com` | Main SPA |
| `api.x.com` | Legacy X API (410 Gone) |
| `grok.x.com` | Grok subdomain — observed POST to `/2/grok/add_response.json` |
| `chat-ws.x.com` | Chat WebSocket endpoint (`wss://chat-ws.x.com/ws`) |
| `grok-api.gcp.mouseion.dev` | **Grok API backend** (302 redirects, needs auth) |
| `abs.twimg.com` | Static assets, JS bundles |
| `pbs.twimg.com` | Media/images CDN |
| `video.twimg.com` | Video CDN |

## X Frontend API (`x.com/i/api/`)

X web client API lives under `/i/api/` (403 without auth). Requires:
- `auth_token` cookie (httponly)
- `ct0` cookie (CSRF token)
- `Authorization: Bearer AAAA...` header (hardcoded web client token)

| Path | Method | Purpose |
|------|--------|---------|
| `/i/api/graphql` | POST | GraphQL API (requires auth) |
| `/i/api/1.1/*` | Various | Legacy REST API (deprecated) |
| `/i/api/2/*` | Various | v2 API |

## Grok Chat Interface (`x.com/i/grok`)

| Path | Method | Purpose |
|------|--------|---------|
| `/i/grok` | GET | Grok chat SPA |
| `/i/grok/prompt` | POST | **Grok prompt completion API** (401 without auth) |
| `/i/grok?text={query}` | GET | Grok search (OpenSearch plugin) |

### OpenSearch plugin

`/os-grok.xml` registers Grok as a browser search engine:
```xml
<Url type="text/html" method="get" template="https://x.com/i/grok?text={searchTerms}"/>
```

## Grok API Backend

Base URL: `https://grok-api.gcp.mouseion.dev`

All paths return 302 redirect. Actual endpoints likely under `/v1/`:

| Path | Method | Purpose |
|------|--------|---------|
| `/v1/chat/completions` | POST | Chat completions |
| `/v1/grok` | ??? | Grok-specific endpoint |

## Grok X.com Subdomain (`grok.x.com`)

Observed in live proxy capture — this subdomain serves real API traffic, not just redirects.

| Path | Method | Purpose |
|------|--------|---------|
| `/2/grok/add_response.json` | POST | Add Grok response to conversation |

## X.com Chat WebSocket (`chat-ws.x.com`)

| Endpoint | Purpose |
|----------|---------|
| `wss://chat-ws.x.com/ws` | Chat WebSocket (grok.com internal) |

## GraphQL Operations (from JS bundle)

| Operation | Purpose |
|-----------|---------|
| `GrokAnalyze` | Analyze content via Grok |
| `GrokCom` | Grok compose/chat |
| `GrokDrawer` | Grok drawer UI |
| `GrokImagineMedia` | Grok image generation |
| `GROK_SHARE` | Share Grok conversation |
| `GrokTranslatedBio` | Translate bio via Grok |

## Authentication

```bash
CT0="<csrf_token>"
AUTH_TOKEN="<auth_token>"
BEARER="AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA"

curl -X POST "https://x.com/i/grok/prompt" \
  -H "Authorization: Bearer ${BEARER}" \
  -H "X-Csrf-Token: ${CT0}" \
  -H "Content-Type: application/json" \
  -H "Cookie: auth_token=${AUTH_TOKEN}; ct0=${CT0}" \
  -d '{}'
```

Returns 401 without valid session.

## Feature flags (from JS bundle)

| Flag | Description |
|------|-------------|
| `grokAnnotationsEnabled` | Grok annotation on tweets |
| `grokFadeInAnimationV2Enabled` | Fade-in animation |
| `grokMediaId` | Grok media identifier |
| `grokShareId` | Grok share identifier |
| `grokTranslation` | Grok translation feature |

## Official xAI API (`api.x.ai`)

xAI provides an OpenAI-compatible REST API at `https://api.x.ai`. Documented at:

- **Docs**: https://docs.x.ai/developers/rest-api-reference
- **Base URL**: `https://api.x.ai`
- **Auth**: `Authorization: Bearer <xai-api-key>`

Covered endpoints: Chat Completions, Images, Videos, Voice, Models, Files, Batches. OpenAI-compatible schema. This is the official API — separate from the grok.com / X.com web frontend APIs documented here.

API key from [console.x.ai](https://console.x.ai). Separate rate limits from grok.com subscriptions.

### List models

```bash
curl -s "https://api.x.ai/v1/models" \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json"
```

Response:
```json
{
  "data": [
    {"id": "grok-beta", "object": "model", ...},
    {"id": "grok-2-latest", "object": "model", ...},
    {"id": "grok-2-vision-latest", "object": "model", ...}
  ]
}
```

### Chat completions (OpenAI-compatible)

```bash
curl -s "https://api.x.ai/v1/chat/completions" \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-beta",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": true
  }'
```

### Coding harness integration

| Harness | Setup |
|---------|-------|
| **OpenCode** | Built-in provider: `/connect` → xAI → Manually enter API key |
| **Cursor** | Add OpenAI-compatible provider with base URL `https://api.x.ai/v1` |
| **Claude Code** | Via `ANTHROPIC_BASE_URL` redirect proxy (needs translation layer) |
| **Grok Build CLI** | Not compatible — uses grok.com session auth, not API keys |

## Infrastructure

- **Framework**: React SPA
- **CDN**: `abs.twimg.com` for JS bundles (`main.bcd2a32a.js`)
- **Auth**: `auth_token` (httponly), `ct0` (CSRF), `_twitter_sess` (session)
- **Web client Bearer token**: `AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA`

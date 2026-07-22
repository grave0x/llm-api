<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

## Gemini API endpoints (gemini.google.com)

Discovered by probing the live site and scanning Google's BOQ SPA JS bundle. Site is Google's BOQ (Business Operation Query) framework SPA served from `gemini.gstatic.com`. Backend is reached via `clients6.google.com` subdomains using SAPISID-based auth.

### Subdomains

| Domain | Purpose |
|--------|---------|
| `gemini.google.com` | Main SPA |
| `geminiweb-pa.clients6.google.com` | Primary API backend (accepts SAPISID auth, returns 400 without correct request body) |
| `waa-pa.clients6.google.com` | WebSocket / real-time API |
| `ogads-pa.clients6.google.com` | OAuth / ads integration |
| `push.clients6.google.com/upload/` | File upload (returns 405 on GET, expects POST) |
| `generativelanguage.googleapis.com` | Google AI / Gemini model API (requires API key or OAuth) |
| `content.googleapis.com` | Google content API |
| `gemini.gstatic.com` | Static assets / JS bundles |
| `notebooklm.google.com` | NotebookLM integration |
| `one.google.com/ai` | Google One AI Premium subscription |

### Internal config (from page `WIZ_global_data`)

| Key | Value | Meaning |
|-----|-------|---------|
| `GK6dn` | `https://geminiweb-pa.clients6.google.com` | API base URL |
| `Im6cmf` | `/_/BardChatUi` | BOQ RPC endpoint path |
| `JNl6me` | `/punctual/prod/assistant-bard` | Backend Punctual RPC service name |
| `MUE6Ne` | `assistant-bard-web-server` | Web server identity |
| `KnDnFf` | `feeds/nrij2vo2gajxiu` | Pub/Sub push feed |
| `VVlN6d` | `AIzaSy<REDACTED_public_page_key>` | Google API key (from public page JS, rate-limited externally) |
| `cfb2h` | `boq_assistant-bard-web-server_20260715.03_p0` | Build version |
| `b5W2zf` | `default_BardChatUi` | Default module |
| `FdrFJe` | `5175523449103825249` | Session identifier |

### Page routes (SPA, all catch to `_worker`)

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | Main chat |
| `/app` | 200 | App page |
| `/app/download` | 200 | Download mobile app |
| `/chat` | 200 | Chat interface |
| `/images` | 200 | Generated images |
| `/settings` | 404 | (not a page) |

### Gemini API (`generativelanguage.googleapis.com/v1beta`)

Standard Gemini model API documented at `https://ai.google.dev`. Requires either a valid API key or OAuth token.

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1beta/models` | GET | List available models (blocked for this API key) |
| `/v1beta/models/gemini-2.0-flash:generateContent` | POST | Generate content |
| `/v1beta/models/gemini-2.0-flash:streamGenerateContent` | POST | Stream generate content |
| `/v1beta/cachedContents` | GET/POST | Cached content management |
| `/v1beta/tunedModels` | GET/POST | Fine-tuned models |

#### Generate content

```bash
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=<YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts":[{"text": "Explain quantum computing"}]}]
  }'
```

Note: The API key from the frontend (`VVlN6d`) is rate-limited/blocked for external use (`API_KEY_SERVICE_BLOCKED`). Use your own API key or OAuth from the [Google AI Studio](https://aistudio.google.com).

### RPC backend (`clients6.google.com`)

The Gemini SPA communicates with the backend via SAPISID-authenticated RPC calls. The endpoint accepts requests but requires the correct Google-internal RPC format.

#### Authentication (SAPISID hash)

Google web apps authenticate API calls using a SAPISID-based hash header:

```bash
SAPISID="<your_sapisid_cookie>"
TIMESTAMP=$(date +%s)
HASH=$(echo -n "${TIMESTAMP} ${SAPISID}" | openssl sha1 | cut -d' ' -f2)
AUTH="SAPISIDHASH ${TIMESTAMP}_${HASH}"

curl -X POST "https://geminiweb-pa.clients6.google.com/v1beta/models/gemini-2.0-flash:generateContent" \
  -H "Authorization: $AUTH" \
  -H "Content-Type: application/json" \
  -H "Cookie: COMPASS=<compass_token>" \
  -d '{"contents":[{"parts":[{"text":"hello"}]}]}'
```

Returns `400` with our request format — the endpoint accepts connections but expects Google's internal serialization format (Proto3 or Punctual RPC framing).

### WebSocket endpoints

| Endpoint | Purpose |
|----------|---------|
| `wss://waa-pa.clients6.google.com` | Real-time / push channel |

### Upload endpoint

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `https://push.clients6.google.com/upload/` | POST | File/media upload (returns 405 on GET) |

### Infrastructure notes

- **BOQ framework**: Google's internal web framework (Business Operation Query)
- **JS bundles**: Served from `gemini.gstatic.com/_/mss/boq-bard-web/`
- **Auth**: SAPISID-based hashed auth header, Google OAuth cookies (__Secure-1PSID, etc.)
- **Backend RPC**: Punctual protocol (Google's internal RPC), service path `/punctual/prod/assistant-bard`
- **Pub/Sub push**: Feed channel `feeds/nrij2vo2gajxiu` for real-time updates
- **Google One**: Subscription/settings at `one.google.com/ai`
- **Analytics**: Google Tag Manager (`GTM-KKRLL9S`)
- **CDN**: `lh3.googleusercontent.com` for user images, `gemini.gstatic.com` for app assets
- **Known API keys**: `AIzaSy<REDACTED>` (primary, from public page JS), 5+ others embedded in page

---

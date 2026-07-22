<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

## grok.com web frontend API endpoints

Discovered by probing the live site and scanning Next.js JS bundles. Site is Next.js SPA served via Cloudflare Worker (`_worker`). All pages catch to SPA, real API is under `/rest/*` (POST-based), `/auth/*`, `/api/*`, `/files/*`, `/imagine/*`.

### Public page routes (SPA, GET from `_worker`)

| Path | Purpose |
|------|---------|
| `/` | Home / chat |
| `/chat` | Chat page |
| `/c` | Conversations list |
| `/c/{id}` | Specific conversation |
| `/imagine` | Image generation |
| `/project` | Projects |
| `/tasks` | Tasks/background jobs |
| `/plans` | Subscription plans |
| `/highlights` | Grok highlights |
| `/supergrok/imagine` | SuperGrok imagine |

### REST API endpoints (`/rest/*` — POST-based, JSON in/out)

Observed HTTP methods: `POST` for reads (query-style), sub-resources may vary. All require authentication via `sso` + `sso-rw` cookies.

#### Authentication

```bash
COOKIES="sso=<jwt>; sso-rw=<jwt>; x-userid=<uuid>"
```

#### List workspaces

```bash
curl -s "https://grok.com/rest/workspaces" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json"
```

Response (empty array when none):
```json
{"workspaces": []}
```

#### Create workspace

```bash
curl -s -X POST "https://grok.com/rest/workspaces" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"name":"My Project","isPublic":false}'
```

Response:
```json
{
  "workspaceId": "fe539ecb-8056-4efe-bc80-bbd5c0f10068",
  "name": "My Project",
  "createTime": "2026-07-16T13:00:46Z",
  "lastUseTime": "2026-07-16T13:00:46Z",
  "isPublic": false,
  "accessLevel": "ACCESS_LEVEL_ADMIN",
  "kind": "WORKSPACE_KIND_UNSPECIFIED"
}
```

#### List available models

```bash
curl -s -X POST "https://grok.com/rest/models" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{}' | jq '.models[].modelId'
```

Response (model IDs only):
```
"grok-4-auto"
"grok-3"
"grok-4"
"grok-420"
"grok-4-1-thinking-1129"
"grok-3-mini-companion"
"grok-4-1-non-thinking-companion"
"imagine-agent-mode"
```

Each model includes `modelMode` (e.g. `MODEL_MODE_AUTO`, `MODEL_MODE_FAST`, `MODEL_MODE_EXPERT`), a `promptingBackend` ("CHAT"), and `tags` for feature toggles.

#### List installed skills

```bash
curl -s "https://grok.com/rest/skills" \
  -X POST \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{}' | jq '.skills[].name'
```

Response:
```
"docx"
"pdf"
"pptx"
"skill-creator"
"xlsx"
```

#### Get subscription info

```bash
curl -s "https://grok.com/rest/subscriptions" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json"
```

Response:
```json
{
  "subscriptions": [
    {
      "stripe": {
        "subscriptionId": "sub_...",
        "productId": "prod_...",
        "currentPeriodEnd": "2026-07-21T10:16:28Z",
        "cancelAtPeriodEnd": false,
        "subscriptionType": "MONTHLY"
      },
      "tier": "SUBSCRIPTION_TIER_GROK_PRO",
      "status": "SUBSCRIPTION_STATUS_ACTIVE",
      "billingInterval": "BILLING_INTERVAL_MONTHLY"
    }
  ]
}
```

#### Get tasks + usage quotas

```bash
curl -s "https://grok.com/rest/tasks" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json"
```

Response:
```json
{
  "tasks": [],
  "unreadResults": [],
  "unreadCounts": [],
  "taskUsage": {
    "frequentUsage": 0,
    "frequentLimit": 10,
    "occasionalUsage": 0,
    "occasionalLimit": 30
  }
}
```

#### Get inactive tasks

```bash
curl -s "https://grok.com/rest/tasks/inactive" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json"
```

Response:
```json
{"taskIds": []}
```

#### List workspace assets

```bash
curl -s "https://grok.com/rest/assets" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json"
```

Response (empty array):
```json
[]
```

### Auth endpoints (`/auth/*` — from JS bundles)

| Path | Purpose |
|------|---------|
| `/auth/api-keys/` | API key management |
| `/auth/consumer-subscriptions` | Consumer subscription plans |
| `/auth/create-email-validation-code` | Email validation code |
| `/auth/create-x-integration-user` | X (Twitter) integration user creation |
| `/auth/exchange-grok-cli-code/` | CLI auth code exchange |
| `/auth/management-keys/validation` | Management key validation |
| `/auth/oauth2/code-redeemed` | OAuth2 code redemption callback |
| `/auth/send-form-acknowledgment-email` | Form acknowledgment email |
| `/auth/send-grok-business-self-serve-email` | Grok Business self-serve email |
| `/auth/team/` | Team CRUD |
| `/auth/team-and-role/` | Team + role info |
| `/auth/teams` | List teams |
| `/auth/teams-with-active-subscription` | Teams with active subs |
| `/auth/teams/x-developer-assign-credits` | X developer credits |
| `/auth/verify-email-validation-code` | Verify email code |

### MCP / tool API endpoints (from JS bundles)

| Path | Purpose |
|------|---------|
| `/api/mcp-app/call-tool` | Execute MCP app tool |
| `/api/mcp-app/list-resources` | List MCP app resources |
| `/api/mcp-app/list-resource-templates` | List MCP resource templates |
| `/api/mcp-app/read-resource` | Read MCP resource |
| `/api/oauth-connectors` | OAuth connector management |

These follow the [Model Context Protocol](https://spec.modelcontextprotocol.io) format. The MCP sandbox at `mcp-sandbox.grokusercontent.com` proxies via iframe + `postMessage`:

```javascript
// Client-side MCP app bridge
const iframe = document.querySelector('iframe');
iframe.contentWindow.postMessage({
  jsonrpc: '2.0',
  method: 'tools/call',
  params: { name: 'my_tool', arguments: { ... } }
}, '*');
```

### General API endpoints (`/api/*` — from JS bundles)

| Path | Purpose |
|------|---------|
| `/api/auth/session` | Get current auth session status |
| `/api/feedback` | Submit user feedback |
| `/api/last-logged-in` | Track last login |
| `/api/sso/select-candidates` | SSO account selection |
| `/api/log_metric` | Client-side metric logging |
| `/api/verify-turnstile` | Cloudflare Turnstile CAPTCHA verification |
| `/api/otlp/traces` | OpenTelemetry trace export |

### Other misc endpoints (not under `/api/`)

| Path | Method | Purpose |
|------|--------|---------|
| `/http/upload-file-v2/direct` | POST | Multipart direct file upload |
| `/monitoring` | POST | Sentry error reporting / monitoring |

#### Submit feedback

```bash
curl -X POST "https://grok.com/api/feedback" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -d '{"type":"general","message":"Great response!","rating":5}'
```

#### Log client metric

```bash
curl -X POST "https://grok.com/api/log_metric" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -d '{"name":"page_view","value":1,"tags":{"page":"chat"}}'
```

#### Export OpenTelemetry traces

```bash
curl -X POST "https://grok.com/api/otlp/traces" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/x-protobuf" \
  --data-binary @traces.protobuf
```

### File system endpoints (from JS bundles)

| Path | Purpose |
|------|---------|
| `/files/content` | Read file content |
| `/files/mkdir` | Create directory |
| `/files/move` | Move/rename file |
| `/files/upload` | Upload file |
| `/fs/read_file` | Read file (FS abstraction) |

#### Upload a file

```bash
curl -X POST "https://grok.com/files/upload" \
  -H "Cookie: $COOKIES" \
  -F "file=@document.pdf" \
  -F "path=uploads/"
```

#### Read file content

```bash
curl "https://grok.com/files/content?path=uploads/document.pdf" \
  -H "Cookie: $COOKIES"
```

### Image/Imagine endpoints (from JS bundles)

| Path | Purpose |
|------|---------|
| `/imagine/post/` | Create/upload imagine post |
| `/imagine/saved/` | Saved imagine posts |
| `/imagine/templates/` | Imagine templates |
| `/imagine/download` | Download imagine asset |

### Media & Canvas endpoints (from session capture)

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/media/folder/bulk-add` | POST | Bulk add to folder |
| `/rest/media/folder/bulk-remove` | POST | Bulk remove from folder |
| `/rest/media/segment` | POST | Media segment |
| `/rest/media/canvas/get` | POST | Get canvas node by id (`{"id":"..."}`) |
| `/rest/media/canvas/list` | POST | List all canvases (`{}`) |
| `/rest/media/canvas/node/update` | POST | Update canvas node (position, prompt, metadata) |
| `/rest/media/conversation/get` | POST | Get media for conversation (`{"canvasId":"..."}`) |
| `/rest/media/imagine/quota_info` | POST | Get imagine generation quota (`{}`) |
| `/rest/media/pipeline/template/list` | POST | List pipeline templates (filter by `PIPELINE_TEMPLATE_LIST_FILTER_MY_TEMPLATES`) |
| `/rest/media/post/list` | POST | List media posts (liked/saved, paginated) |
| `/rest/media/search/status` | POST | Check media search status |

The canvas API is the node-based image editor. Canvas node updates carry `position`, `prompt`, and `metadata.assetType`.

### Connector endpoints

#### v1 (thumbnail)

| Path | Purpose |
|------|---------|
| `/connectors/v1/thumbnail` | Connector thumbnail image |

#### v2 (connector management)

Discovered from session capture. These replace the legacy `/rest/connectors/list` (which returns 501).

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/connectors/list-v2` | POST | List installed connectors (req: `{"refreshToken":true,"checkWatchChannelValidity":true}`) |
| `/rest/connectors/list-available-v2` | POST | List available connectors to install (`{}`) |
| `/rest/oauth/auth-url` | POST | Get OAuth URL for connector auth |

OAuth URL request:
```json
{
  "redirectUrl": "https://grok.com/connectors-oauth-exchange-code/",
  "connectorId": "connector_{uuid}",
  "scope": "CONNECTOR_SCOPE_USER",
  "scopeId": "{uuid}"
}
```

Callback flow: `/connectors-oauth-exchange-code` (GET, renders callback handler) → redirect → `/connectors-oauth-success` (GET, renders success page)

These are SPA page routes rendered by the Cloudflare Worker, not REST endpoints.

### App Chat (Build workspace chat) endpoints

These are the primary chat API used by Grok Build workspaces. They live under `/rest/app-chat/` and complement the legacy `/rest/conversations` endpoints used by the main grok.com chat.

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/app-chat/conversations` | GET | List app-chat conversations |
| `/rest/app-chat/conversations-many` | GET | Batch fetch multiple conversations |
| `/rest/app-chat/conversations/new` | POST | **Create new conversation (main chat endpoint)** |
| `/rest/app-chat/conversations/{id}/load-responses` | POST | Load specific response(s) by IDs |
| `/rest/app-chat/conversations/{id}/response-node` | GET | Get single response node |
| `/rest/app-chat/conversations/{id}/responses` | GET | List all responses in conversation |
| `/rest/app-chat/conversations_v2/{id}` | GET | v2 conversation detail |
| `/rest/app-chat/upload-file` | POST | Upload file attachment to conversation |
| `/rest/conversations/files/list` | GET | List attached files (`{"files":[],"path":"/"}`) |

#### Create conversation (`/rest/app-chat/conversations/new`)

Full request body observed in session:
```json
{
  "temporary": true,
  "message": "User message text",
  "fileAttachments": ["{uuid}"],
  "imageAttachments": [],
  "disableSearch": false,
  "enableImageGeneration": true,
  "returnImageBytes": false,
  "returnRawGrokInXaiRequest": false,
  "enableImageStreaming": true,
  "imageGenerationCount": 2,
  "forceConcise": false,
  "enableSideBySide": true,
  "sendFinalMetadata": true,
  "disableTextFollowUps": false,
  "responseMetadata": {},
  "disableMemory": false,
  "forceSideBySide": false,
  "isAsyncChat": false,
  "disableSelfHarmShortCircuit": false,
  "collectionIds": [],
  "disabledConnectorIds": [],
  "deviceEnvInfo": {
    "darkModeEnabled": true,
    "devicePixelRatio": 1.09,
    "screenWidth": 1760,
    "screenHeight": 990,
    "viewportWidth": 1315,
    "viewportHeight": 851
  },
  "modeId": "auto"
}
```

Load responses request:
```json
{"responseIds": ["{uuid}", "{uuid}", ...]}
```

### Modes, Products & Rate Limits

Discovered from session capture. These define available chat modes, product plans, and per-model rate limits.

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/modes` | POST | List available chat modes (`{"locale":"en"}`) |
| `/rest/products` | GET | List subscription product plans and pricing |
| `/rest/rate-limits` | POST | Check rate limits per model (`{"requestKind":"DEFAULT","modelName":"grok-4-auto"}`) |
| `/rest/models/imagine/overrides` | POST | Get imagine model overrides (`{}` → `{"modelMapOverrides":[]}`) |

### Automations

Grok Build workflow automations.

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/automations` | GET / POST | List/create automations (`{"automations":[]}`) |
| `/rest/automations/catalog` | GET | Browse available automation catalog |

### Suggestions

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/suggestions/profile` | GET | Get user suggestion profile (`{}`) |

### User settings & skills

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/user-settings` | GET | Fetch user preferences/settings |
| `/rest/user-skills` | GET / POST | List/manage user-installed skills |
| `/rest/skills` | POST | List available skills |
| `/rest/notifications/list` | GET | List user notifications (`{"notifications":[]}`) |

### System prompts

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/system-prompt/list` | POST | List system prompt assets (`{"pageSize":100}` → `{"assets":[]}`) |

### gRPC-Web endpoints

Grok Build uses gRPC-Web (not REST) for billing and credits. Endpoint is `POST` to `grok.com/{package}.{Service}/{Method}` with gRPC-Web content-type (`application/grpc-web+proto`).

| Path | Method | Purpose |
|------|--------|---------|
| `/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig` | POST | Get Grok Build credits config |

Response (gRPC-Web framed, protobuf):
```
grpc-status: 0
```

### Dev/debug endpoints

| Path | Purpose |
|------|---------|
| `/dev/auth-preview` | Auth preview |
| `/dev/gateway-chat` | Gateway chat test |
| `/settings/integrations/github` | GitHub integration settings |
| `/settings/integrations/github/callback` | GitHub OAuth callback |

### WebSocket gateways

| Endpoint | Purpose |
|----------|---------|
| `wss://grok.com/ws/gw/` | Gateway WebSocket (cloud sandbox) |
| `wss://grok.com/ws/mgw/` | MGW WebSocket (new gateway variant) |
| `wss://code.grok.com/ws/code-agent` | Relay WebSocket (local agent) |

Handshake requires WebSocket upgrade and auth cookies. The gateway expects JSON-RPC frames. Heartbeat: `{"jsonrpc":"2.0","method":"ping","id":"hb"}`.

### External subdomains (discovered)

| Domain | Purpose |
|--------|---------|
| `https://mcp-sandbox.grokusercontent.com` | MCP app sandbox proxy (iframe+postMessage bridge) |
| `https://assets.grokusercontent.com` | User-generated content (404 root, subpath-based) |
| `https://assets.grok.com` | Static assets |
| `https://cdn.grok.com` | Next.js CDN |
| `https://imagine-public.x.ai/imagine-public` | Public imagine images |
| `wss://chat-ws.x.com/ws` | Chat WebSocket (grok.com internal) |
| `https://grok.x.com/2/grok/add_response.json` | Grok response endpoint on X.com subdomain |

### Known models (from `/rest/models`)

| Model ID | Mode |
|----------|------|
| `grok-4-auto` | Auto |
| `grok-3` | Fast |
| `grok-4` | Expert |
| `grok-420` | Internal/testing |
| `grok-4-1-thinking-1129` | Thinking |
| `grok-3-mini-companion` | Companion (hidden) |
| `grok-4-1-non-thinking-companion` | Companion (hidden) |
| `imagine-agent-mode` | Imagine Agent |

### Installed skills (from `/rest/skills`)

docx, pdf, pptx, skill-creator, xlsx

### Infrastructure notes

- **Next.js** SPA served via Cloudflare Worker (`_worker` route)
- **Stripe** for payments (cookies: `__stripe_mid`, `__stripe_sid`)
- **Sentry** error tracking (DSN: `o4508179396558848.ingest.us.sentry.io`)
- **Cloudflare Turnstile** for bot protection
- **K8s internal**: `http://prod-grok-backend:9000` referenced in config
- **User auth cookies**: `sso` (JWT), `sso-rw`, `x-userid`, `grok_device_id`

---

<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

## Grok Build API endpoints

Discovered from `grok-build-gravemod` (xai-grok Rust workspace at `/home/grave/Projects/Personal/grok-build-gravemod`). No literal `api/grok/build/` path exists — the "build" namespace spans tool protocol, backend URLs, gRPC, JSON-RPC, and agent configs.

### Backend endpoint URLs (`GrokBuildEndpoints` struct)

| Field | URL | Env-var override |
|-------|-----|-----------------|
| `cli_chat_proxy_base_url` | `https://cli-chat-proxy.grok.com/v1` | `GROK_PRODUCTION_CLI_CHAT_PROXY_BASE_URL` |
| `asset_server_url` | `https://assets.grok.com` | `GROK_PRODUCTION_ASSET_SERVER_URL` |
| `relay_ws_url` | `wss://code.grok.com/ws/code-agent` | `GROK_PRODUCTION_WS_URL` |
| `gateway_ws_url` | `wss://grok.com/ws/gw/` | `GROK_PRODUCTION_GATEWAY_WS_URL` |
| `ws_origin` | `https://grok.com` | `GROK_PRODUCTION_WS_ORIGIN` |

Only Production env exists. Dev/staging flags are no-ops.

#### Authentication

The CLI chat proxy requires a `session_id` in the JSON-RPC envelope. Storage endpoints require an `Authorization: Bearer <token>` header set by the workspace server after hub registration. The token is opaque — obtained during CLI auth exchange (`/auth/exchange-grok-cli-code/` on grok.com).

#### Usage: CLI Chat Proxy — OpenAI-compatible chat completion

```bash
curl -X POST "https://cli-chat-proxy.grok.com/v1/chat/completions" \
  -H "Authorization: Bearer <session_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-4",
    "messages": [
      {"role": "user", "content": "Hello, what is Rust?"}
    ],
    "stream": true
  }'
```

Response (SSE, streamed):
```
data: {"id":"...","object":"chat.completion.chunk","choices":[{"delta":{"role":"assistant"},"index":0}]}
data: {"id":"...","object":"chat.completion.chunk","choices":[{"delta":{"content":"Rust"},"index":0}]}
...
data: [DONE]
```

#### Usage: Anthropic Messages API format

```bash
curl -X POST "https://cli-chat-proxy.grok.com/v1/messages" \
  -H "Authorization: Bearer <session_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-4",
    "max_tokens": 4096,
    "messages": [
      {"role": "user", "content": "Explain monads"}
    ],
    "stream": true
  }'
```

Response (SSE, Anthropic-style):
```
data: {"type":"message_start","message":{"id":"...","content":[],"role":"assistant"}}
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Monads..."}}
...
data: {"type":"message_stop"}
```

### Storage API — upload flow

#### Step 1: Get pre-signed GCS upload URL

```bash
curl -s "https://cli-chat-proxy.grok.com/v1/storage/signed-upload-url" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "content_type": "application/json",
    "path": "session_id/turn_3/metadata.json"
  }'
```

Response:
```json
{
  "signed_url": "https://storage.googleapis.com/...?X-Goog-Signature=...",
  "bucket": "grok-user-data",
  "path": "session_id/turn_3/metadata.json",
  "content_type": "application/json",
  "expires_in_secs": 3600
}
```

#### Step 2: Upload directly to GCS

```bash
curl -X PUT "$SIGNED_URL" \
  -H "Content-Type: application/json" \
  -d '{"schema_version":"v1.23","session_id":"...","turn_number":3,"model":"grok-4","host_os":"linux"}'
```

#### Step 3: Confirm upload to proxy

```bash
curl -X POST "https://cli-chat-proxy.grok.com/v1/storage" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"path":"session_id/turn_3/metadata.json"}'
```

### Workspace connector management (REST on grok.com)

Connectors (e.g. GitHub, Gmail, Google Calendar) are managed via workspace-scoped REST endpoints on `grok.com`:

| Path | Method | Purpose |
|------|--------|---------|
| `/rest/workspaces/{id}/connectors` | GET | List connectors for workspace |
| `/rest/workspaces/{id}/connectors` | POST | Add connector to workspace |
| `/rest/workspaces/{id}/connectors/{connector_id}` | DELETE | Remove a connector |
| `/rest/workspaces/{id}/permissions` | GET | List workspace permissions |
| `/rest/workspaces/{id}/assets` | POST | Manage workspace assets |
| `/rest/workspaces/shared` | GET | List workspaces shared with user |

### gRPC-Web billing endpoint

Grok Build billing uses gRPC-Web (protobuf over HTTP POST) rather than JSON REST. Observed in live session capture.

**Endpoint:** `POST https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig`

**Content-Type:** `application/grpc-web+proto`

**Response (protobuf, gRPC-Web framed):**
```
grpc-status: 0
```

The request body is an empty protobuf message (5 bytes: `0x00 0x00 0x00 0x00 0x00` — gRPC-Web frame header). Response contains credits configuration as serialized protobuf.

### App Chat conversation endpoints

The Build workspace chat uses `/rest/app-chat/` endpoints (documented in [`api/grok/web/endpoints.md`](../web/endpoints.md)). The primary chat creation endpoint accepts a `modeId` field — valid values come from `/rest/modes`.

| Mode | Source |
|------|--------|
| `auto` | Default auto mode |
| `fast` | Fast response mode |
| `expert` | Expert/deep reasoning mode |


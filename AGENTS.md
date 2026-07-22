# AGENTS.md

## State

Empty repo — initialized with `git init`, no commits yet.

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

#### Batch upload (base64+zstd compressed)

```bash
curl -X POST "https://cli-chat-proxy.grok.com/v1/storage/batch_upload_json" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -H "Content-Encoding: zstd" \
  -d '{
    "files": [
      {"path": "session/turn_1/output.txt", "content_type": "text/plain", "data": "<base64_encoded>"}
    ]
  }'
```

Check if paths exist:

```bash
curl -s "https://cli-chat-proxy.grok.com/v1/storage/exists?paths=session/turn_1/output.txt" \
  -H "Authorization: Bearer <token>"
```

### WebSocket hub connection

```
wss://computer-hub.grok.com/v1/tools
```

Default `--hub-url`. JSON-RPC over WebSocket using `xai-tool-protocol` frames. The workspace server connects here to register tool handlers. Protocol uses request/response envelopes with `session_id` routing.

#### Tool Protocol JSON-RPC frame format

```json
{
  "jsonrpc": "2.0",
  "id": "req-001",
  "method": "tool.call",
  "session_id": "<uuid>",
  "params": {
    "tool_call_id": "<uuid>",
    "tool_id": "GrokBuild:bash",
    "arguments": {"command": "ls -la"},
    "deadline_ms": 30000,
    "cwd": "/home/user/project"
  }
}
```

Response:
```json
{
  "jsonrpc": "2.0",
  "id": "req-001",
  "result": {
    "tool_call_id": "<uuid>",
    "output": {
      "content": "{\"exit_code\":0,\"stdout\":\"total 12\\ndrwxr-xr-x ...\",\"stderr\":\"\"}",
      "content_type": "application/json"
    }
  }
}
```

#### Connecting with websocat

```bash
websocat wss://computer-hub.grok.com/v1/tools \
  -H "Cookie: sso=<jwt>" \
  -H "User-Agent: Mozilla/5.0"
```

### gRPC `GrokToolsService` (proto: `xai.grok.tools.v1`)

| RPC | I/O | Description |
|-----|-----|-------------|
| `ExecuteTool` | `ExecuteToolRequest` → `ExecuteToolResponse` | Execute a single tool call |
| `ExecuteToolStream` | `ExecuteToolRequest` → stream `ToolStreamChunk` | Chunked unary (true streaming planned) |
| `ListTools` | `ListToolsRequest` → `ListToolsResponse` | List all tools with schemas |
| `GetToolInfo` | `GetToolInfoRequest` → `ToolInfo` | Details on specific tool |
| `FinalizeToolConfig` | `FinalizeToolServerConfigRequest` → `FinalizeToolServerConfigResponse` | Finalize config, enable calls |
| `GetToolState` | `GetToolStateRequest` → `GetToolStateResponse` | Serialized tool params+state snapshot |

Tool IDs on wire: `"GrokBuild:<tool_name>"` (e.g. `"GrokBuild:bash"`). Namespace field: `"GrokBuild"`.

#### gRPC tool execution (using grpcurl)

```bash
grpcurl -plaintext -d '{
  "tool_id": "GrokBuild:read_file",
  "arguments": {"file_path": "/etc/hostname"},
  "deadline_ms": 10000
}' localhost:50051 xai.grok.tools.v1.GrokToolsService/ExecuteTool
```

Response:
```json
{
  "result": {
    "tool_call_id": "...",
    "output": {
      "content": "{\"content\":\"my-hostname\\n\"}",
      "content_type": "application/json"
    }
  }
}
```

#### List all available tools with schemas

```bash
grpcurl -plaintext localhost:50051 xai.grok.tools.v1.GrokToolsService/ListTools
```

### `GrokBuild` tool namespace (~27 tools)

All registered under `ToolNamespace::GrokBuild`, source under `xai-grok-tools/src/implementations/grok_build/`.

| Tool name | ID | File |
|-----------|----|------|
| `ask_user_question` | `GrokBuild:ask_user_question` | `ask_user_question/mod.rs` |
| `bash` / `run_terminal_cmd` | `GrokBuild:run_terminal_cmd` | `bash/mod.rs` |
| `deploy_app` | `GrokBuild:deploy_app` | `deploy_app_stub.rs` |
| `enter_plan_mode` | `GrokBuild:enter_plan_mode` | `enter_plan_mode/mod.rs` |
| `exit_plan_mode` | `GrokBuild:exit_plan_mode` | `exit_plan_mode/mod.rs` |
| `grep` | `GrokBuild:grep` | `grep/mod.rs` |
| `image_edit` | `GrokBuild:image_edit` | `image_edit/mod.rs` |
| `image_gen` | `GrokBuild:image_gen` | `image_gen/mod.rs` |
| `kill_task` | `GrokBuild:kill_task` | `kill_task/mod.rs` |
| `list_dir` | `GrokBuild:list_dir` | `list_dir/mod.rs` |
| `lsp` | `GrokBuild:lsp` | `lsp/mod.rs` |
| `monitor` | `GrokBuild:monitor` | `monitor/tool.rs` |
| `read_file` | `GrokBuild:read_file` | `read_file/mod.rs` |
| `scheduler_create` | `GrokBuild:scheduler_create` | `scheduler/create.rs` |
| `scheduler_delete` | `GrokBuild:scheduler_delete` | `scheduler/delete.rs` |
| `scheduler_list` | `GrokBuild:scheduler_list` | `scheduler/list.rs` |
| `search_replace` | `GrokBuild:search_replace` | `search_replace/mod.rs` |
| `task` | `GrokBuild:task` | `task/mod.rs` |
| `task_output` | `GrokBuild:task_output` | `task_output/mod.rs` |
| `wait_tasks` | `GrokBuild:wait_tasks` | `task_output/wait_tasks.rs` |
| `todo_write` | `GrokBuild:todo_write` | `todo/mod.rs` |
| `update_goal` | `GrokBuild:update_goal` | `update_goal/mod.rs` |
| `imagine_video` / `video_gen` | `GrokBuild:imagine_video` | `video_gen/mod.rs` |
| `image_to_video` | `GrokBuild:image_to_video` | `video_gen/mod.rs` |
| `reference_to_video` | `GrokBuild:reference_to_video` | `video_gen/mod.rs` |
| `web_fetch` | `GrokBuild:web_fetch` | `web_fetch/mod.rs` |
| `web_search` | `GrokBuild:web_search` | `web_search/mod.rs` |

#### Example: Calling a tool via JSON-RPC

Each tool accepts typed `arguments` and returns structured JSON in `output.content`.

**Bash tool:**
```json
{"command": "ls -la", "timeout_ms": 15000, "cwd": "/home/user"}
```
Response: `{"exit_code": 0, "stdout": "...", "stderr": ""}`

**Read file:**
```json
{"file_path": "src/main.rs", "limit": 2000, "offset": 0}
```
Response: `{"content": "fn main() {\n...", "truncated": false}`

**Grep:**
```json
{"pattern": "TODO", "path": "src/", "include": "*.rs"}
```
Response: `{"matches": [{"path": "src/main.rs", "line": 42, "content": "// TODO: fix"}]}`

**Web search:**
```json
{"query": "latest Rust version 2025"}
```
Response: `{"results": [{"title": "...", "url": "...", "snippet": "..."}]}`

**Image gen:**
```json
{"prompt": "A cat wearing a hat", "aspect_ratio": "16:9"}
```
Response: `{"images": [{"url": "https://assets.grok.com/...", "revised_prompt": "..."}]}`

### Workspace JSON-RPC methods (dispatched via `workspace_rpc` tool)

| Method string | Purpose |
|--------------|---------|
| `workspace.worktree_db_rebuild` | Rebuild worktree database index |
| `workspace.worktree_db_path` | Get worktree DB path |
| `workspace.worktree_db_stats` | Get worktree DB statistics |

#### Example:

```json
{
  "jsonrpc": "2.0",
  "id": "1",
  "method": "workspace.worktree_db_stats",
  "params": {}
}
```

Response:
```json
{
  "jsonrpc": "2.0",
  "id": "1",
  "result": {
    "file_count": 1523,
    "index_size_bytes": 4194304,
    "last_rebuilt": "2026-07-16T10:00:00Z"
  }
}
```

### In-sandbox diagnostics HTTP (axum, unix socket or localhost:6016)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/ready` | Health check (200=Connected, 503=otherwise) |
| GET | `/statusz` | Debug status + OS info |
| GET | `/logs?tail_bytes=N` | Daemon log tail (max 256KB) |

#### Example:

```bash
# Via Unix socket
curl --unix-socket /tmp/workspace-server.sock http://localhost/ready

# Via TCP
curl http://localhost:6016/ready
curl http://localhost:6016/statusz
curl "http://localhost:6016/logs?tail_bytes=10240"
```

### Pre-built agent profiles

| Profile | Toolset |
|---------|---------|
| `GrokBuild` | 17 core tools (bash, read, grep, replace, task, etc.) |
| `GrokBuildConcise` | Concise bash/read/replace variants |
| `GrokBuildPlan` | Core + `enter_plan_mode`, `exit_plan_mode`, `ask_user_question` |
| `GrokBuildPlanNoSubagents` | Plan profile minus task/subagent tools |
| `GrokBuildAskUser` | Core + `ask_user_question` |
| `GrokBuildOrchestrator` | Full set + web_search, web_fetch, image_gen, video_gen, scheduler, plan tools |
| `GrokBuildHashline` | Dynamic hashline tools + bash, list_dir, web_search, etc. |

Profiles select tools at agent startup. Override with the `--agent` flag on the Grok CLI.

---

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
| `/api/feedback` | Submit user feedback |
| `/api/last-logged-in` | Track last login |
| `/api/sso/select-candidates` | SSO account selection |
| `/api/log_metric` | Client-side metric logging |
| `/api/verify-turnstile` | Cloudflare Turnstile CAPTCHA verification |
| `/api/otlp/traces` | OpenTelemetry trace export |

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

### Media REST endpoints

| Path | Purpose |
|------|---------|
| `/rest/media/folder/bulk-add` | Bulk add to folder |
| `/rest/media/folder/bulk-remove` | Bulk remove from folder |
| `/rest/media/segment` | Media segment |

### Connector endpoints

| Path | Purpose |
|------|---------|
| `/connectors/v1/thumbnail` | Connector thumbnail image |
| `/rest/connectors/list` | List connectors (501, not yet active) |

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

## DeepSeek API endpoints (deepseek.com / chat.deepseek.com)

Discovered by probing live site and scanning React SPA JS bundles. Site is React SPA served from `fe-static.deepseek.com`. Real API is under `/api/v0/*` (POST-based). API subdomain at `api.deepseek.com`.

### Subdomains

| Domain | Purpose |
|--------|---------|
| `chat.deepseek.com` | Main chat SPA |
| `api.deepseek.com` | API gateway (returns 401 without auth) |
| `deepseek.com` | Marketing site |
| `fe-static.deepseek.com` | Static assets, JS bundles |
| `cdn.deepseek.com` | Images, policies |
| `api-docs.deepseek.com` | API documentation |

### Authentication

DeepSeek APIs use either:
- **Session cookie** (`ds_session_id`) for the web chat API
- **API key** (`Authorization: Bearer <key>`) for `api.deepseek.com`
- **Proof-of-work challenge** for abuse prevention (free tier)

The web API uses `POST` for all requests. Some endpoints require a `session_id` in the request body.

```bash
COOKIE="aws-waf-token=<value>; ds_session_id=<value>"
```

### Chat API endpoints (`/api/v0/chat/*`)

#### Chat completion (main LLM call)

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/completion" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "session_id": "<session_uuid>",
    "messages": [{"role": "user", "content": "What is the speed of light?"}],
    "model": "deepseek-chat",
    "stream": true
  }'
```

The streaming response uses SSE:
```
data: {"code":0,"msg":"","data":{"id":"...","choices":[{"delta":{"role":"assistant"},"index":0}]}}
data: {"code":0,"msg":"","data":{"id":"...","choices":[{"delta":{"content":"The speed"},"index":0}]}}
...
data: [DONE]
```

Non-streaming response:
```json
{
  "code": 0,
  "msg": "",
  "data": {
    "id": "chatcmpl-...",
    "choices": [{
      "index": 0,
      "message": {"role": "assistant", "content": "The speed of light in vacuum is 299,792,458 m/s."},
      "finish_reason": "stop"
    }],
    "usage": {"prompt_tokens": 8, "completion_tokens": 18, "total_tokens": 26}
  }
}
```

#### Proof-of-work challenge (anti-abuse for free tier)

Before chatting, free-tier clients may need to solve a PoW challenge:

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/create_pow_challenge" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{}'
```

Response:
```json
{
  "code": 0,
  "msg": "",
  "data": {
    "algorithm": "sha256",
    "difficulty": 4,
    "prefix": "0000abc123...",
    "expires_at": 1784208000
  }
}
```

Solve the challenge (find a nonce where `sha256(prefix + nonce)` starts with `difficulty` zeros), then include the solution in the next chat request:

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/completion" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "<session_uuid>",
    "messages": [{"role": "user", "content": "Hello"}],
    "pow_nonce": "<solved_nonce>",
    "pow_prefix": "0000abc123..."
  }'
```

#### Continue generation

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/continue" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"session_id": "<uuid>", "message_id": "<msg_uuid>"}'
```

#### Edit message

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/edit_message" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "<uuid>",
    "message_id": "<msg_uuid>",
    "content": "Revised question here..."
  }'
```

#### Regenerate last response

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/regenerate" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>"}'
```

#### Fetch chat history

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/history_messages" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "limit": 50}'
```

#### Submit message feedback

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/message_feedback" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "<uuid>",
    "message_id": "<msg_uuid>",
    "rating": 1,
    "tags": ["helpful", "accurate"]
  }'
```

#### Stop active stream

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/stop_stream" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>"}'
```

#### Resume interrupted stream

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/resume_stream" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>"}'
```

### Chat session endpoints (`/api/v0/chat_session/*`)

#### Create new session

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/create" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"title": "My New Chat"}'
```

Response:
```json
{
  "code": 0,
  "msg": "",
  "data": {"session_id": "<uuid>", "title": "My New Chat", "create_time": 1784206000}
}
```

#### List sessions (paginated)

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/fetch_page" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"page": 1, "page_size": 20}'
```

Response:
```json
{
  "code": 0,
  "msg": "",
  "data": {
    "sessions": [
      {"session_id": "<uuid>", "title": "Chat about Rust", "create_time": 1784206000}
    ],
    "total": 1
  }
}
```

#### Delete session

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/delete" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>"}'
```

#### Delete all sessions

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/delete_all" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{}'
```

#### Update title / pin

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/update_title" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "title": "Renamed Chat"}'

curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/update_pinned" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "pinned": true}'
```

### User/auth endpoints (`/api/v0/users/*`)

#### Get current user info

```bash
curl -s "https://chat.deepseek.com/api/v0/users" \
  -H "Cookie: $COOKIE" \
  -H "Accept: application/json"
```

Response (requires valid session):
```json
{
  "code": 0,
  "msg": "",
  "data": {"user": {"id": "<uuid>", "email": "user@example.com", "is_guest": false}}
}
```

#### Create email verification code

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/users/create_email_verification_code" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "scenario": "register"}'
```

#### Create SMS verification code

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/users/create_sms_verification_code" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"mobile": "+8613800000000", "area_code": "+86", "scenario": "login"}'
```

#### Get/update user settings

```bash
curl -s "https://chat.deepseek.com/api/v0/users/settings" \
  -H "Cookie: $COOKIE" \
  -H "Accept: application/json"

curl -s -X POST "https://chat.deepseek.com/api/v0/users/update_settings" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"theme": "dark", "language": "en"}'
```

#### Create guest challenge

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/users/create_guest_challenge" \
  -H "Content-Type: application/json" \
  -d '{"captcha_token": "<turnstile_token>"}'
```

This is used for anonymous/guest access, returning a temporary session.

#### Logout all sessions

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/users/logout_all_sessions" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### File endpoints (`/api/v0/file/*`)

#### Upload a file

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/file/upload_file" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@document.pdf" \
  -F "session_id=<uuid>"
```

Response:
```json
{
  "code": 0,
  "msg": "",
  "data": {"file_id": "<uuid>", "name": "document.pdf", "size": 1024000}
}
```

#### List uploaded files

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/file/fetch_files" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"page": 1, "page_size": 20}'
```

#### Fork a file processing task

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/file/fork_file_task" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"file_id": "<uuid>", "task_type": "ocr"}'
```

### Share endpoints (`/api/v0/share/*`)

#### Create share link

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/share/create" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "expires_in_days": 7}'
```

#### Get shared content

```bash
curl -s "https://chat.deepseek.com/api/v0/share/content?share_id=<uuid>" \
  -H "Cookie: $COOKIE" \
  -H "Accept: application/json"
```

#### Fork shared conversation

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/share/fork" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"share_id": "<uuid>"}'
```

#### List shares

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/share/list" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Note: returns 422 without `session_id` or `user_id` params.

#### Delete share

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/share/delete" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"share_id": "<uuid>"}'
```

### Index/context endpoints (`/api/v0/index/*`)

#### Prepare context (indexing)

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/index/prepare" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "text": "Long document to index..."}'
```

#### Query context index

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/index/query" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "<uuid>", "query": "What does the document say about X?"}'
```

### Client endpoints (`/api/v0/client/*`)

#### Get/set client settings

```bash
curl -s "https://chat.deepseek.com/api/v0/client/settings" \
  -H "Cookie: $COOKIE" \
  -H "Accept: application/json"

curl -s -X POST "https://chat.deepseek.com/api/v0/client/settings" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"key": "theme", "value": "dark"}'
```

#### Report client telemetry

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/client/settings/report" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"event": "app_start", "properties": {"version": "1.0.0"}}'
```

#### Submit client trace/span

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/client/span" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"name": "render", "start_time": 1000, "end_time": 1200, "tags": {"component": "ChatList"}}'
```

#### WeChat JS SDK signature

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/client/wechat_js_sdk_signature" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://chat.deepseek.com/share/abc"}'
```

### Export endpoints

#### Download chat history

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/download_export_history" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"format": "json"}' -o chat_history.json
```

#### Export all data

```bash
curl -s -X POST "https://chat.deepseek.com/api/v0/export_all" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### OpenAI-compatible API (`api.deepseek.com`)

#### Chat completions

```bash
curl -s "https://api.deepseek.com/v1/chat/completions" \
  -H "Authorization: Bearer <deepseek_api_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello!"}
    ],
    "temperature": 0.7,
    "stream": false
  }'
```

Response (standard OpenAI format):
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1784206000,
  "model": "deepseek-chat",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "Hello! How can I help you today?"},
    "finish_reason": "stop"
  }],
  "usage": {"prompt_tokens": 12, "completion_tokens": 9, "total_tokens": 21}
}
```

Without a valid API key, returns HTTP 401.

### Auth flow paths (server-side routes, not API endpoints)

| Path | Purpose |
|------|---------|
| `/sign_in` | Email/password login |
| `/sign_up` | Sign up |
| `/register` | Register |
| `/register_by_mobile` | Register by SMS |
| `/logout` | Logout |
| `/forgot_password` | Password reset |
| `/oauth/apple/login` | Apple OAuth login |
| `/oauth/google/authorize` | Google OAuth authorize |
| `/oauth/wechat/callback` | WeChat OAuth callback |
| `/oauth/wechat/bind` | Bind WeChat account |
| `/oauth/wechat/unbind` | Unbind WeChat |

These are server-rendered HTML pages or redirect endpoints, not JSON APIs.

### WebSocket

```bash
websocat wss://chat.deepseek.com/ws \
  -H "Cookie: $COOKIE"
```

Returns 200 on upgrade, expects WebSocket frames. Protocol unknown — likely custom or Socket.IO based.

### Infrastructure notes

- **AWS WAF** for DDoS/bot protection (cookie: `aws-waf-token`)
- **Volcengine/ByteDance** APM: `apmplus.volces.com` (aid: 675113)
- **Volcengine analytics**: `gator.volces.com`, `lf3-data.volccdn.com`
- **Turnstile/Shumei** captcha for bot protection
- **Auth cookies**: `ds_session_id` (session), `smidV2` (device ID)
- **Static build**: commit `fdc5c9033` in JS meta tag

---

## Example applications

### Python: List Grok models via REST API

```python
import requests

cookies = {
    "sso": "<jwt>",
    "sso-rw": "<jwt>",
    "x-userid": "<uuid>",
}

# List models
resp = requests.post(
    "https://grok.com/rest/models",
    cookies=cookies,
    json={},
    headers={"Accept": "application/json"},
)
models = resp.json()["models"]
for m in models:
    print(f"{m['modelId']:40s} {m['modelMode']}")
```

### Python: DeepSeek chat completion

```python
import requests

cookies = {
    "aws-waf-token": "<token>",
    "ds_session_id": "<session>",
}

session_id = "<uuid>"  # from chat_session/create

resp = requests.post(
    "https://chat.deepseek.com/api/v0/chat/completion",
    cookies=cookies,
    json={
        "session_id": session_id,
        "messages": [{"role": "user", "content": "Write a haiku about Rust"}],
        "stream": False,
    },
    headers={"Accept": "application/json"},
)
data = resp.json()
if data["code"] == 0:
    print(data["data"]["choices"][0]["message"]["content"])
```

### Node.js: DeepSeek SSE streaming chat

```javascript
const response = await fetch("https://chat.deepseek.com/api/v0/chat/completion", {
  method: "POST",
  headers: {
    "Cookie": "aws-waf-token=...; ds_session_id=...",
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    session_id: "<uuid>",
    messages: [{ role: "user", content: "Tell me a joke" }],
    stream: true,
  }),
});

const reader = response.body.getReader();
const decoder = new TextDecoder();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  const text = decoder.decode(value);
  for (const line of text.split("\n")) {
    if (line.startsWith("data: ") && line !== "data: [DONE]") {
      const json = JSON.parse(line.slice(6));
      const content = json.data?.choices?.[0]?.delta?.content;
      if (content) process.stdout.write(content);
    }
  }
}
```

### Bash: Full Grok workspace lifecycle

```bash
COOKIES="sso=<jwt>; sso-rw=<jwt>; x-userid=<uuid>"

# 1. List workspaces
curl -s "https://grok.com/rest/workspaces" -H "Cookie: $COOKIES" -H "Accept: application/json"

# 2. Create workspace
WORKSPACE=$(curl -s -X POST "https://grok.com/rest/workspaces" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"name":"API Demo"}' | jq -r '.workspaceId')
echo "Created workspace: $WORKSPACE"

# 3. Check subscription
curl -s "https://grok.com/rest/subscriptions" \
  -H "Cookie: $COOKIES" \
  -H "Accept: application/json" | jq '.subscriptions[].tier'

# 4. List available models
curl -s -X POST "https://grok.com/rest/models" \
  -H "Cookie: $COOKIES" \
  -H "Content-Type: application/json" \
  -d '{}' | jq '[.models[].modelId]'
```

### Bash: DeepSeek conversation flow

```bash
COOKIE="aws-waf-token=<token>; ds_session_id=<session>"

# 1. Create a new session
SESSION=$(curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/create" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d '{"title":"API Test"}' | jq -r '.data.session_id')
echo "Session: $SESSION"

# 2. Send a message
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/completion" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"session_id\": \"$SESSION\", \"messages\": [{\"role\": \"user\", \"content\": \"Hello!\"}], \"stream\": false}" | jq '.data.choices[0].message.content'

# 3. Fetch history
curl -s -X POST "https://chat.deepseek.com/api/v0/chat/history_messages" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d "{\"session_id\": \"$SESSION\", \"limit\": 10}" | jq

# 4. Rename session
curl -s -X POST "https://chat.deepseek.com/api/v0/chat_session/update_title" \
  -H "Cookie: $COOKIE" \
  -H "Content-Type: application/json" \
  -d "{\"session_id\": \"$SESSION\", \"title\": \"Renamed Chat\"}"
```

---

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
| `VVlN6d` | `AIzaSyD6n9asBjvx1yBHfhFhfw_kpS9Faq0BZHM` | Google API key |
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
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyD6n9asBjvx1yBHfhFhfw_kpS9Faq0BZHM" \
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
- **Known API keys**: `AIzaSyD6n9asBjvx1yBHfhFhfw_kpS9Faq0BZHM` (primary), 5+ others embedded in page

---

## Z.ai API endpoints (chat.z.ai — GLM / Zhipu AI)

Discovered by probing live site and scanning Svelte SPA JS bundle. Site is Svelte SPA served from `z-cdn.chatglm.cn`. Backend API at `api.z.ai`. Powered by GLM models (Zhipu AI / 智谱AI, GLM-5.2).

### Subdomains & CDN

| Domain | Purpose |
|--------|---------|
| `chat.z.ai` | Main chat SPA |
| `api.z.ai` | API backend (returns 301 redirect on root) |
| `z-cdn.chatglm.cn` | Static assets, JS bundles |
| `sdata.chatglm.cn` | Analytics pixel |
| `zai-test-api.chatglm.site` | Test API server (returns 503) |
| `dev.bigmodel.cn` | GLM coding development |
| `zcode.z.ai` | Z code resources (307 redirect) |

### Authentication

Uses JWT Bearer token in `Authorization` header or `token` cookie:

```bash
JWT="eyJ...<jwt_token>"

# Cookie auth
curl -H "Cookie: token=${JWT}"

# Bearer auth
curl -H "Authorization: Bearer ${JWT}"
```

The JWT encodes `{id, email}` using ES256 algorithm.

### API endpoints

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/v1/chat/completions` | Chat completion (405 without proper body) |
| POST | `/v1/chat` | Chat endpoint |
| POST | `/v1/models` | List models |
| POST | `/v1/user` | User info |
| POST | `/v1/auth` | Authentication |
| POST | `/v1/conversations` | Conversations |
| POST | `/v1/messages` | Messages |
| POST | `/v1/images` | Image generation |
| POST | `/v1/audio` | Audio processing |
| POST | `/v1/files` | File management |
| POST | `/v1/config` | Configuration |
| POST | `/graphql` | GraphQL endpoint |
| POST | `/rest/chat` | REST chat |
| POST | `/rest/models` | REST models |
| POST | `/rest/user` | REST user |

All `/v1/*` and `/rest/*` endpoints return **405** (Method Not Allowed) with empty `{}` body — they expect specific request formats.

### Convert endpoints (SSE-streaming)

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/convert/pdf/stream` | Convert to PDF (SSE) |
| POST | `/convert/ppt/stream` | Convert to PPT (SSE) |
| POST | `/convert/magic-design-image/stream` | Convert to image (SSE) |

These return `text/event-stream` with progress updates:
```json
{"status": "processing", "message": "..."}
{"status": "completed", "url": "...", "filename": "..."}
{"status": "failed", "message": "..."}
```

### Storage endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/v1/storage/pfs/messages/{id}/files/download` | Download message file |
| GET | `/storage/pfs/chats/{id}/files` | Chat file storage |
| POST | `/storage/versions/{id}/downloads/register` | Register version download |

### PPT template endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET/POST | `/ppt-template/user/template/{id}` | User template CRUD |
| POST | `/ppt-template/user/template/update/{id}` | Update template |

### Admin endpoints (from JS bundle)

| Path | Purpose |
|------|---------|
| `/admin/chats` | Admin chat management |
| `/admin/clients` | Client management |
| `/admin/consents` | Consent management |
| `/admin/functions` | Function management |
| `/admin/gallery` | Gallery management |
| `/admin/icons` | Icon management |
| `/admin/oauth` | OAuth admin |
| `/admin/settings` | Admin settings |
| `/admin/users` | User management |
| `/admin/scenario-tests` | Scenario testing |

### Auth/OAuth endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `/auth/oauth/authorize` | OAuth authorization |
| `/auth/verify` | Email verification |
| `/auth/verify_email` | Email verification |
| `/auth/reset-password` | Password reset |
| `/auth/webdev-auth-success` | WebDev auth success callback |
| `/auth/webdev-auth-failed` | WebDev auth failure callback |
| `/api/oauth/authorize` | API OAuth authorize |
| `/api/oauth` | OAuth management |

### WebSocket

| Endpoint | Purpose |
|----------|---------|
| `wss://api.z.ai/ws` | Real-time chat (inferred from SPA pattern) |

### Infrastructure notes

- **Framework**: Svelte SPA
- **CDN**: `z-cdn.chatglm.cn` (Alibaba Cloud CDN)
- **Analytics**: Google Analytics (`G-Z8QTHYBHP3`), Alibaba Cloud SLS
- **WAF**: Alibaba Cloud WAF (`acw_tc` cookie)
- **Models**: GLM-5.2, GLM-4.6, GLM-4.5, GLM-4.1V
- **OpenAI compatible**: `https://api.openai.com/v1` appears in JS (proxy/fallback support)
- **OpenWebUI**: References to `openwebui.com` for community UI
- **Subscription**: `z.ai/subscribe` and `chatglm.site/subscribe`

---

## Perchance API endpoints (perchance.org)

Discovered by probing live site and scanning generator pages. Platform is for creating random generators with inline JS bundles. Backend at `perchance.org/api/`.

### Subdomains

| Domain | Purpose |
|--------|---------|
| `perchance.org` | Main site (redirects to SPA) |
| `ads.perchance.org` | Ad server (returns 200) |
| `comments-plugin.perchance.org` | Comments plugin |
| `image-generation.perchance.org` | Image generation plugin |
| `text-generation.perchance.org` | Text generation plugin |
| `null.perchance.org` | Utility/development domain |
| `user.uploads.perchance.dev` | User file uploads |
| `user.uploads.dev` | User file uploads (shared) |
| `aigc.uploads.dev` | AI-generated content uploads |
| `{hash}.perchance.org` | Per-generator content CDN |

### Generator-specific subdomains

Each generator gets a unique hash subdomain:
```
https://a257cd3ebbfff8e014d264b056e5727d.perchance.org/welcome
```

### API endpoints (under `perchance.org/api/`)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/getCommunityData` | Community posts/forum data |
| GET | `/api/getDynamicMetaData?__generatorName=` | Generator meta data (JSON) |
| GET | `/api/getGeneratorScreenshot?generatorName=` | Generator screenshot (JPEG) |
| GET | `/api/count` | Page counter |
| GET | `/api/getGeneratorDiffPatches` | Generator diff patches |
| POST | `/api/save` | Save generator (needs auth) |
| POST | `/api/login` | Login (returns `captcha-needed`) |
| GET | `/api/alc?__cacheBust=` | Analytics/counter (cache-busted) |
| GET | `/api/iusb?v=` | User stats (cache-busted) |
| GET | `/api/cv?generatorName=` | Version check |
| GET | `/api/clearCacheIfGeneratorOrImportsHaveBeenUpdated?generatorName=` | Cache clearing |
| GET | `/api/get` | Get generator data |
| POST | `/api/set` | Set generator data |
| POST | `/api/change` | Change resource |
| POST | `/api/check` | Check/validate resource |
| POST | `/api/delete` | Delete resource |
| POST | `/api/duplicate` | Duplicate generator |
| POST | `/api/request` | Request action |
| POST | `/api/reset` | Reset generator |
| POST | `/api/aiHelper` | AI helper endpoint |
| POST | `/api/getGeneratorsAndDependencies` | List generators + deps |
| POST | `/api/verify` | Verify resource |
| POST | `/api/requestPasswordResetCode` | Request password reset code |

### Plugin subdomain endpoints

| Domain | Path | Purpose |
|--------|------|---------|
| `image-generation.perchance.org` | `/api/imageTags?url=` | Fetch image tags from URL |
| `text-generation.perchance.org` | `/` | Text generation plugin |
| `comments-plugin.perchance.org` | `/embed/{folderName}` | Comments embed iframe |

### Image generation (text-to-image plugin)

**Architecture**: The image gen runs in-browser via WebGPU/WASM, not a server endpoint. The plugin at `perchance.org/text-to-image-plugin` loads HuggingFace `@huggingface/transformers@3.3.3` and ONNX models directly in the browser.

**How it works**:
1. Generators embed `<iframe src="https://perchance.org/text-to-image-plugin">` 
2. Communication is via `postMessage` between iframe and parent
3. AI models load from HuggingFace via `AutoModel.from_pretrained()`
4. Images are generated client-side and stored at `generated-images.perchance.org/image/{hash}.jpeg`
5. Background removal uses `briaai/RMBG-1.4` via transformers.js

**Usage from a Perchance generator**:
```javascript
// Simple API within Perchance generator code
let result = await image({ prompt: "a cute mouse" });

// With options
let result = await image({ 
  prompt: "a beautiful landscape",
  negativePrompt: "blurry, low quality",
  guidanceScale: 7,    // default 7, range 1-30
  seed: 12345
});

// Gallery mode shows generated images in a grid
galleryOptions
  gallery = true
  galleryOptions
    gallery = true
```

**Parameters**: `prompt`, `negativePrompt`, `guidanceScale` (1-30, default 7), `seed`, `width`, `height`, `model_id`

**Generated images** are hosted at `https://generated-images.perchance.org/image/{hash}.jpeg`.

### AI text generation (text-generation plugin)

**Architecture**: Same iframe/postMessage pattern. Plugin at `text-generation.perchance.org`.

**Usage from a Perchance generator**:
```javascript
let result = await aiText({ prompt: "Write a poem about AI" });
```

### Generator pages (user-specified)

All at `https://perchance.org/{name}`:

| Page | Purpose |
|------|---------|
| `/multi-gallery` | Multi-gallery generator |
| `/step-prompt-lab` | Step prompt lab |
| `/nightmare-image-gen` | Nightmare image generation |
| `/simple-image-generator-text2image` | Text-to-image generator |
| `/infinitynikkirandomizer` | Randomizer |
| `/kainat-s-vibe-coder` | AI vibe coder |
| `/furry-concept-board` | Furry concept art |
| `/furpost` | Furry posting |
| `/mysecret` | Secret generator |
| `/acc-character-generator` | Character generator |
| `/artscapes-v3` | Art generation v3 |
| `/ai-chat` | AI chat |
| `/ai-coding-helper-feedback` | AI coding feedback |

### Authentication

```bash
# Login returns captcha challenge
curl -X POST https://perchance.org/api/login -H "Content-Type: application/json" -d '{}'
# Response: {"status":"captcha-needed"}
```

### Infrastructure notes

- **Framework**: Custom generator engine (inline HTML/JS per page)
- **JS bundles**: Served from `/lib/*.bundle.min.js?v=hash`
- **Analytics**: Google Analytics (`G-YJWJRNESS5`)
- **CDN**: Cloudflare (JS challenge cookies present)
- **File uploads**: `user.uploads.perchance.dev`
- **Ads**: `ads.perchance.org`
- **Plugins**: Isolated subdomains for image gen, text gen, comments
- **Test worker**: `test-7944.u8.workers.dev` (Cloudflare Worker)

## Tooling

- **rapiscan** — Rust API scanner at `~/Projects/Personal/rapiscm/target/release/rapiscm`
  - Usage: `rapiscm url --paths "/api,/v1" --output md "https://target.com"`
  - Scans paths for live endpoints, reports status codes + security headers
  - Supports custom headers, auth, rate-limiting, concurrency control

## Before work

- Confirm project language/framework with user before scaffolding
- Use `pytest` / `vitest` / `cargo test` etc matching the chosen stack once files exist

## Conventions (apply once project has content)

- Match existing toolchain and lint config, don't guess
- Keep `AGENTS.md` updated when adding build/test/deploy commands, framework quirks, or monorepo boundaries

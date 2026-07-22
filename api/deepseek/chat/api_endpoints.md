<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

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

### Official DeepSeek API (`api.deepseek.com`)

Official docs: `https://api-docs.deepseek.com` (Docusaurus). API base URLs:
- OpenAI: `https://api.deepseek.com`
- Anthropic: `https://api.deepseek.com/anthropic`

#### Models

| Model ID | Status |
|----------|--------|
| `deepseek-v4-flash` | Flagship (replaces deepseek-chat) |
| `deepseek-v4-pro` | Pro model |
| `deepseek-chat` | Deprecating 2026/07/24 |
| `deepseek-reasoner` | Deprecating 2026/07/24 |

#### List models

```bash
curl -s "https://api.deepseek.com/models" \
  -H "Authorization: Bearer <deepseek_api_key>"
```
```json
{"object":"list","data":[{"id":"deepseek-v4-flash","object":"model","owned_by":"deepseek"},{"id":"deepseek-v4-pro","object":"model","owned_by":"deepseek"}]}
```

#### Chat completions (OpenAI format)

```bash
curl -s "https://api.deepseek.com/chat/completions" \
  -H "Authorization: Bearer <deepseek_api_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v4-pro",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello!"}
    ],
    "thinking": {"type": "enabled"},
    "reasoning_effort": "high",
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

#### Anthropic-compatible endpoint

```bash
curl -X POST "https://api.deepseek.com/anthropic/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: <deepseek_api_key>" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "deepseek-v4-flash",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 2048
  }'
```

#### Additional API features

| Feature | Doc Path |
|---------|----------|
| Thinking mode | `/guides/thinking_mode` |
| Multi-round conversation | `/guides/multi_round_chat` |
| Chat prefix completion (Beta) | `/guides/chat_prefix_completion` |
| FIM completion (Beta) | `/guides/fim_completion` |
| JSON output | `/guides/json_mode` |
| Tool calls | `/guides/tool_calls` |
| Context caching | `/guides/kv_cache` |

#### Platform

API key management: `https://platform.deepseek.com/api_keys` (403 without auth)

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

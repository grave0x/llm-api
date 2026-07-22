<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

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

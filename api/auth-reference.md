# Auth reference — cookies, tokens, and crafting valid sessions

## x.ai / Grok (CLI + web)

### OIDC Provider: `https://auth.x.ai`

| Endpoint | URL |
|----------|-----|
| Authorization | `https://auth.x.ai/oauth2/authorize` |
| Token | `https://auth.x.ai/oauth2/token` |
| Device code | `https://auth.x.ai/oauth2/device/code` |
| Userinfo | `https://auth.x.ai/oauth2/userinfo` |
| Revoke | `https://auth.x.ai/oauth2/revoke` |
| JWKS | `https://auth.x.ai/.well-known/jwks.json` |

### Scopes

```
openid profile email offline_access
grok-cli:access api:access
conversations:read conversations:write
workspaces:read workspaces:write
team:read org:read
grok-plugins:access
```

### CLI client ID

`b1a00492-073a-47ea-816f-4c329264a828`

### Auth file location

`~/.grok/auth.json` — JSON map of `scope_key → AuthEntry`:

```json
{
  "<issuer>::<client_id>": {
    "key": "<JWT_access_token>",
    "auth_mode": "oidc",
    "refresh_token": "<opaque_refresh_token>",
    "user_id": "<uuid>",
    "email": "...",
    "principal_type": "User",
    "principal_id": "<uuid>",
    "team_id": "<uuid>",
    "oidc_issuer": "https://auth.x.ai",
    "oidc_client_id": "b1a00492-073a-47ea-816f-4c329264a828",
    "expires_at": "<ISO_timestamp>"
  }
}
```

### JWT access token

ES256-signed, kid `oauth2-production-2026-02-19`:
```json
{
  "iss": "https://auth.x.ai",
  "sub": "<user_uuid>",
  "aud": "b1a00492-073a-47ea-816f-4c329264a828",
  "scope": "openid profile email offline_access grok-cli:access api:access conversations:read conversations:write",
  "principal_type": "User",
  "principal_id": "<uuid>",
  "client_id": "b1a00492-073a-47ea-816f-4c329264a828",
  "tier": 1,
  "team_id": "<uuid>",
  "exp": <timestamp>,
  "iat": <timestamp>,
  "jti": "<uuid>"
}
```

### Crafting a session

**Device code flow (CLI)**:
```bash
# Step 1: Get device code
curl -X POST "https://auth.x.ai/oauth2/device/code" \
  -d "client_id=b1a00492-073a-47ea-816f-4c329264a828&scope=openid%20profile%20email%20offline_access%20grok-cli:access"

# Step 2: User visits URL, enters code
# Step 3: Poll for token
curl -X POST "https://auth.x.ai/oauth2/token" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code&device_code=<code>&client_id=b1a00492-073a-47ea-816f-4c329264a828"
```

**Refresh flow**:
```bash
curl -X POST "https://auth.x.ai/oauth2/token" \
  -d "grant_type=refresh_token&refresh_token=<token>&client_id=b1a00492-073a-47ea-816f-4c329264a828"
```

### grok.com web cookies

| Cookie | Type | Description |
|--------|------|-------------|
| `sso` | JWT (HS256) | Web session: `{"session_id": "<uuid>"}` |
| `sso-rw` | JWT (HS256) | Read-write session (same payload) |
| `x-userid` | UUID | User identifier |

### Token exchange (legacy, disabled)

`POST /auth/exchange-grok-cli-code/` returns:
```json
{"code":12,"message":"Legacy CLI token exchange is disabled. Use OAuth2 login instead (grok login)."}
```

---

## X.com / Grok on X

### Cookies

| Cookie | Type | Description |
|--------|------|-------------|
| `auth_token` | Opaque | X authentication token |
| `ct0` | Opaque | CSRF token (required for API calls) |
| `_twitter_sess` | Serialized | Rails session |
| `twid` | `u%3D<user_id>` | Twitter user ID |

### Web client Bearer token

```
AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA
```

### API auth pattern

```bash
curl -H "Authorization: Bearer <web_client_bearer>" \
  -H "X-Csrf-Token: ${CT0}" \
  -H "Cookie: auth_token=${AUTH_TOKEN}; ct0=${CT0}"
```

### Crafting a session

Session can be obtained by:
1. Logging in via browser, capturing `auth_token` + `ct0` from cookies
2. These expire — `auth_token` is long-lived, `ct0` regenerates periodically

---

## DeepSeek

### Cookies

| Cookie | Type | Description |
|--------|------|-------------|
| `ds_session_id` | Opaque | Session identifier |
| `aws-waf-token` | Opaque | AWS WAF challenge token |
| `smidV2` | Opaque | Device fingerprint |

### Guest flow

```bash
# Create guest challenge (no auth required)
curl -X POST "https://chat.deepseek.com/api/v0/users/create_guest_challenge" \
  -H "Content-Type: application/json" \
  -d '{"captcha_token": "<turnstile_token>"}'
# Returns a temporary session
```

### API key auth

```bash
curl -H "Authorization: Bearer <deepseek_api_key>" "https://api.deepseek.com/..."
```

Keys obtained at `https://platform.deepseek.com/api_keys`

---

## Gemini (Google)

### Cookies

| Cookie | Type | Description |
|--------|------|-------------|
| `__Secure-1PSID` | Google OAuth | Primary Google auth cookie |
| `COMPASS` | Gemini-specific | Gemini session token |
| `SAPISID` | Hash | For SAPISID-based API auth |

### SAPISID auth

```bash
SAPISID="<sapisid_cookie>"
TIMESTAMP=$(date +%s)
HASH=$(echo -n "${TIMESTAMP} ${SAPISID}" | openssl sha1 | cut -d' ' -f2)
AUTH="SAPISIDHASH ${TIMESTAMP}_${HASH}"

curl -H "Authorization: ${AUTH}" "https://geminiweb-pa.clients6.google.com/..."
```

### Known API keys (rate-limited, blocked for external)

```
<REDACTED_public_page_key>  (primary, from gemini.google.com JS bundle)
<REDACTED_public_page_key>
<REDACTED_public_page_key>
<REDACTED_public_page_key>
```

---

## Z.ai (GLM/Zhipu)

### Auth

JWT Bearer token (ES256 signed), encodes `{id, email}`:

```bash
# Cookie auth
curl -H "Cookie: token=${JWT}"

# Bearer auth
curl -H "Authorization: Bearer ${JWT}"
```

### JWT payload
```json
{"id": "<uuid>", "email": "<email>"}
```

---

## Perchance

### Session

Stored in `localStorage["app-storage"].user`:
```json
{
  "email": "...",
  "sessionToken": "..."
}
```

### Upload auth

Passed via URL hash fragment:
```
https://upload.perchance.org/embed#{email, sessionToken}
```

### Login

```bash
curl -X POST "https://perchance.org/api/login" -H "Content-Type: application/json" -d '{}'
# Response: {"status":"captcha-needed"}
```

Requires Turnstile challenge completion to get a real session.

---

## Token crafting summary

| Provider | Auth type | Token source | Expiry |
|----------|-----------|-------------|--------|
| x.ai (Grok) | OIDC (ES256 JWT) | `auth.x.ai/oauth2/token` | ~1 hour (refreshable) |
| x.ai (Grok web) | JWT (HS256) + session | `sso` cookie | Session |
| X.com | Bearer + cookies | Login | Varies |
| DeepSeek | Session cookie / API key | Login / platform | Varies |
| Gemini | Google OAuth + SAPISID hash | Google login | Varies |
| Z.ai | JWT (ES256) | Login | Session |
| Perchance | localStorage + Turnstile | Login + captcha | Session |

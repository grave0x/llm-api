# Stability AI API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `stability.ai` | Marketing site |
| `platform.stability.ai` | API console / docs |

## platform.stability.ai

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | Console SPA |
| `/v1` | 200 | SPA catch-all |
| `/v1/generation` | 200 | SPA catch-all |
| `/api` | 200 | SPA catch-all |

All paths return 200 (SPA catch-all). Real API is at `api.stability.ai` (well-known):

```bash
curl -X POST "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image" \
  -H "Authorization: Bearer <key>" \
  -H "Content-Type: application/json" \
  -d '{"text_prompts":[{"text":"a cat"}],"cfg_scale":7,"height":1024,"width":1024}'
```

## Infrastructure

- **Auth**: Bearer token
- **Models**: Stable Diffusion XL, SD3, Core

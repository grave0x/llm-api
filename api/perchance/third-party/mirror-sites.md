# Third-Party Perchance Mirror Sites

Unofficial sites that proxy or imitate Perchance.org functionality.

## perchanceai.app

| Aspect | Detail |
|--------|--------|
| URL | `https://www.perchanceai.app` |
| Status | 200 (main page), 500 (API) |
| Framework | Yii PHP framework (revealed via error page) |
| API | `/api` returns 500 - `Database Exception - yii\db\Exception` |
| Purpose | AI image generator frontend, multi-language (en/es/ja/zh/pt/de/fr/vi/id) |
| Note | Uses `perchance` in domain name but is NOT affiliated with official Perchance.org |

## perchanceaigenerator.com

| Aspect | Detail |
|--------|--------|
| URL | `https://www.perchanceaigenerator.com` |
| API | `/api/` blocked (robots.txt Disallow), returns 308 redirect |
| Framework | Static site (Next.js SSG detected via `_next/` in robots.txt) |
| Pages | `/ai-image-editor` (200), `/solutions/image-to-video` (200), `/image-to-video` |
| Hidden API | No API endpoints found in HTML (static content, no fetch/ajax calls) |

## perchance-ai.org

| Aspect | Detail |
|--------|--------|
| URL | `https://perchance-ai.org` |
| Status | 200, simple landing page |
| API | No API endpoints found |
| Note | Minimal site, no discoverable functionality |

## perchanceai.cc

| Aspect | Detail |
|--------|--------|
| URL | `https://perchanceai.cc` |
| Status | 403 (Cloudflare challenge) |
| Note | Protected by Cloudflare, content unknown |

## New subdomains discovered

| Domain | Response | Type |
|--------|----------|------|
| `upload.perchance.org` | Root 404, `/embed` 200 | File upload iframe embed |
| `null.perchance.org` | Root 404, `/upload` 200, `/debug` 200, `/test` 200 | Developer/test domain |
| `generated-images.perchance.org` | Root 400 | Generated image hosting (path-based) |
| `user.uploads.dev` | Root 400, `/file/{hash}.{ext}` 200 | User file storage |
| `aigc.uploads.dev` | Root 400, `/image/{hash}.jpeg` 200 | AI-generated content storage |

The `upload.perchance.org/embed` endpoint accepts session auth via URL hash:
```javascript
{email: user.email, sessionToken: user.sessionToken}
```
File expiry options: never, 1hr, 1day, 1week, 1month, 3months, 1year.

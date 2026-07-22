<!-- Doc generated from AGENTS.md. Edit source there, not here. -->

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

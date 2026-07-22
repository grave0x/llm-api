# Hugging Face API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `huggingface.co` | Hub SPA + API |

## Public paths

| Path | Status | Purpose |
|------|--------|---------|
| `/` | 200 | Hub home |
| `/models` | 200 | Model catalog |
| `/datasets` | 200 | Dataset catalog |
| `/api/models` | 200 | Models API (public) |
| `/v1` | 200 | SPA catch-all |
| `/api/inference` | **401** | **Inference API exists (needs token)** |

## API

Well-known endpoints:
```bash
# Inference API
curl -X POST "https://api-inference.huggingface.co/models/<model>" \
  -H "Authorization: Bearer <hf_token>" \
  -d '{"inputs":"Hello world"}'

# Hub API (public)
curl -s "https://huggingface.co/api/models?search=gpt" | jq

# Datasets API
curl -s "https://huggingface.co/api/datasets"
```

## Infrastructure

- **Auth**: Bearer token for inference
- **Well-known API subdomain**: `api-inference.huggingface.co`
- **Models**: 1M+ public models

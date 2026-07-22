# Replicate API endpoints

## Sites

| Domain | Purpose |
|--------|---------|
| `replicate.com` | Marketing / SPA |
| `api.replicate.com` | API backend |

## API (from OpenAPI spec at `/openapi.json`)

Base URL: `https://api.replicate.com`

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/v1` | 401 — API root (needs auth) |
| GET | `/openapi.json` | 200 — Full OpenAPI spec (26 endpoints) |

### 26 documented endpoints (from OpenAPI spec)

```
/account
/collections
/collections/{collection_slug}
/deployments
/deployments/{deployment_owner}/{deployment_name}
/deployments/{deployment_owner}/{deployment_name}/predictions
/files
/files/{file_id}
/files/{file_id}/download
/hardware
/models
/models/{model_owner}/{model_name}
/models/{model_owner}/{model_name}/examples
/models/{model_owner}/{model_name}/predictions
/models/{model_owner}/{model_name}/readme
/models/{model_owner}/{model_name}/versions
/models/{model_owner}/{model_name}/versions/{version_id}
/models/{model_owner}/{model_name}/versions/{version_id}/trainings
/predictions
/predictions/{prediction_id}
/trainings
/trainings/{training_id}
/webhooks
/webhooks/{webhook_id}/test
```

```bash
# Get the full spec
curl -s "https://api.replicate.com/openapi.json" | jq '.paths | keys'

# Auth required for most endpoints
curl -X POST "https://api.replicate.com/v1/predictions" \
  -H "Authorization: Bearer <key>" \
  -H "Content-Type: application/json" \
  -d '{"version":"...","input":{"prompt":"..."}}'
```

## Infrastructure

- **Auth**: Bearer token
- **Spec**: Full OpenAPI 3.0 at `/openapi.json`
- **Models**: Community-hosted ML models

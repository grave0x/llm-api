[2026-07-16T15:50:06Z INFO  rapiscm::scan::url] discovered 0 API links from HTTP fetch
[2026-07-16T15:50:06Z INFO  rapiscm::scan::url] scanning 15 endpoints from URL mode
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 1/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 2/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 3/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 4/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 5/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 6/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 7/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 8/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 9/15
[2026-07-16T15:50:06Z INFO  rapiscm::scan::runner] queued 10/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/api (953.882469ms)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] queued 11/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/api-docs (958.069955ms)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] queued 12/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/ping (998.666333ms)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] queued 13/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/graphql (1.010922375s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] queued 14/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/metrics (1.024946965s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] queued 15/15
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/api/v2 (1.026058007s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/health (1.036745337s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/rest (1.077957584s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/api/v1 (1.088463077s)
[2026-07-16T15:50:07Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/openapi.json (1.117471467s)
[2026-07-16T15:50:08Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/swagger.json (987.17319ms)
[2026-07-16T15:50:08Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/v1 (965.256234ms)
[2026-07-16T15:50:08Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/v2 (965.881498ms)
[2026-07-16T15:50:08Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/status (1.058233645s)
[2026-07-16T15:50:08Z INFO  rapiscm::scan::runner] 403 GET https://chat.mistral.ai/v3 (996.165371ms)
# Scan Summary

- **Total endpoints:** 15
- **Successful (2xx/3xx):** 0
- **Errors:** 0
- **Checks passed:** 60
- **Checks failed:** 0
- **Warnings:** 30


## Results

| Method | URL | Status | Time | Checks |
|--------|-----|--------|------|--------|
| GET | https://chat.mistral.ai/api | 403 | 953ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/api-docs | 403 | 958ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/api/v1 | 403 | 1.088s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/api/v2 | 403 | 1.026s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/graphql | 403 | 1.010s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/health | 403 | 1.036s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/metrics | 403 | 1.024s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/openapi.json | 403 | 1.117s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/ping | 403 | 998ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/rest | 403 | 1.077s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/status | 403 | 1.058s | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/swagger.json | 403 | 987ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/v1 | 403 | 965ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/v2 | 403 | 965ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://chat.mistral.ai/v3 | 403 | 996ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✓ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |


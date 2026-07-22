[2026-07-16T15:50:03Z INFO  rapiscm::scan::url] discovered 0 API links from HTTP fetch
[2026-07-16T15:50:03Z INFO  rapiscm::scan::url] scanning 15 endpoints from URL mode
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 1/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 2/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 3/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 4/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 5/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 6/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 7/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 8/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 9/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 10/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/api (144.048413ms)
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 11/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/ping (144.456155ms)
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 12/15
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/health (145.019496ms)
[2026-07-16T15:50:03Z INFO  rapiscm::scan::runner] queued 13/15
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/api/v1 (157.691957ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] queued 14/15
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/graphql (158.33172ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/rest (158.2201ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] queued 15/15
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/api/v2 (158.154307ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/openapi.json (158.310656ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/api-docs (158.360781ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/metrics (158.207284ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/status (38.707189ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/swagger.json (38.427337ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/v1 (38.672329ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/v3 (41.134319ms)
[2026-07-16T15:50:04Z INFO  rapiscm::scan::runner] 301 GET https://console.anthropic.com/v2 (41.266322ms)
# Scan Summary

- **Total endpoints:** 15
- **Successful (2xx/3xx):** 15
- **Errors:** 0
- **Checks passed:** 0
- **Checks failed:** 45
- **Warnings:** 45


## Results

| Method | URL | Status | Time | Checks |
|--------|-----|--------|------|--------|
| GET | https://console.anthropic.com/api | 301 | 144ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/api-docs | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/api/v1 | 301 | 157ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/api/v2 | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/graphql | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/health | 301 | 145ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/metrics | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/openapi.json | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/ping | 301 | 144ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/rest | 301 | 158ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/status | 301 | 38ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/swagger.json | 301 | 38ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/v1 | 301 | 38ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/v2 | 301 | 41ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |
| GET | https://console.anthropic.com/v3 | 301 | 41ms | ✗ CSP<br>✗ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body |


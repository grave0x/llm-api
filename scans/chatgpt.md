[2026-07-16T15:49:57Z INFO  rapiscm::scan::url] discovered 0 API links from HTTP fetch
[2026-07-16T15:49:57Z INFO  rapiscm::scan::url] scanning 15 endpoints from URL mode
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 1/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 2/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 3/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 4/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 5/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 6/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 7/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 8/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 9/15
[2026-07-16T15:49:57Z INFO  rapiscm::scan::runner] queued 10/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 405 GET https://chatgpt.com/graphql (418.657965ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] queued 11/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 302 GET https://chatgpt.com/status (40.513525ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] queued 12/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 302 GET https://chatgpt.com/health (491.395712ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] queued 13/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/rest (230.627365ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] queued 14/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/api-docs (312.778788ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] queued 15/15
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/api (328.239271ms)
[2026-07-16T15:49:58Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/v2 (259.433428ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/v3 (219.901264ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/ping (681.992371ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/openapi.json (698.698872ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 404 GET https://chatgpt.com/api/v1 (724.485237ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/swagger.json (636.090752ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/v1 (675.547449ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 200 GET https://chatgpt.com/metrics (738.646272ms)
[2026-07-16T15:49:59Z INFO  rapiscm::scan::runner] 404 GET https://chatgpt.com/api/v2 (720.88946ms)
# Scan Summary

- **Total endpoints:** 15
- **Successful (2xx/3xx):** 12
- **Errors:** 0
- **Checks passed:** 56
- **Checks failed:** 3
- **Warnings:** 43


## Results

| Method | URL | Status | Time | Checks |
|--------|-----|--------|------|--------|
| GET | https://chatgpt.com/api | 200 | 328ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/api-docs | 200 | 312ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/api/v1 | 404 | 724ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/api/v2 | 404 | 720ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/graphql | 405 | 418ms | ✗ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control |
| GET | https://chatgpt.com/health | 302 | 491ms | ✗ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✓ CORS |
| GET | https://chatgpt.com/metrics | 200 | 738ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/openapi.json | 200 | 698ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/ping | 200 | 681ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/rest | 200 | 230ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/status | 302 | 40ms | ✗ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/swagger.json | 200 | 636ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/v1 | 200 | 675ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/v2 | 200 | 259ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |
| GET | https://chatgpt.com/v3 | 200 | 219ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✗ Response Body<br>✓ CORS |


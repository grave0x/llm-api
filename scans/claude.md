[2026-07-16T15:50:01Z INFO  rapiscm::scan::url] discovered 0 API links from HTTP fetch
[2026-07-16T15:50:01Z INFO  rapiscm::scan::url] scanning 15 endpoints from URL mode
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 1/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 2/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 3/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 4/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 5/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 6/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 7/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 8/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 9/15
[2026-07-16T15:50:01Z INFO  rapiscm::scan::runner] queued 10/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/api-docs (175.733914ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] queued 11/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/api (175.640343ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] queued 12/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/rest (176.001161ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/metrics (178.470405ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] queued 13/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] queued 14/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/graphql (182.932359ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] queued 15/15
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/ping (194.738826ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/openapi.json (186.705561ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/health (186.399178ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/status (55.932881ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/v2 (51.10774ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/v1 (51.015885ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/swagger.json (53.441079ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 200 GET https://claude.ai/v3 (57.379982ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 404 GET https://claude.ai/api/v1 (402.991876ms)
[2026-07-16T15:50:02Z INFO  rapiscm::scan::runner] 404 GET https://claude.ai/api/v2 (415.527873ms)
# Scan Summary

- **Total endpoints:** 15
- **Successful (2xx/3xx):** 13
- **Errors:** 0
- **Checks passed:** 56
- **Checks failed:** 4
- **Warnings:** 30


## Results

| Method | URL | Status | Time | Checks |
|--------|-----|--------|------|--------|
| GET | https://claude.ai/api | 200 | 175ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/api-docs | 200 | 175ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/api/v1 | 404 | 402ms | ✗ CSP<br>✓ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✓ Response Body |
| GET | https://claude.ai/api/v2 | 404 | 415ms | ✗ CSP<br>✓ HSTS<br>✗ X-Content-Type-Options<br>✗ X-Frame-Options<br>✗ Cache-Control<br>✓ Response Body |
| GET | https://claude.ai/graphql | 200 | 182ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/health | 200 | 186ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/metrics | 200 | 178ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/openapi.json | 200 | 186ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/ping | 200 | 194ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/rest | 200 | 176ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/status | 200 | 55ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/swagger.json | 200 | 53ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/v1 | 200 | 51ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/v2 | 200 | 51ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |
| GET | https://claude.ai/v3 | 200 | 57ms | ✓ CSP<br>✓ HSTS<br>✓ X-Content-Type-Options<br>✗ X-Frame-Options<br>✓ Cache-Control<br>✗ Response Body |


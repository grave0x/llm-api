# API documentation index

```
api/
├── openai/              # ChatGPT, platform.openai.com
├── anthropic/           # claude.ai, console.anthropic.com (v1/complete, v1/messages)
├── deepseek/
│   └── chat/            # DeepSeek chat API, sessions, files, shares, export
├── mistral/             # chat.mistral.ai, console.mistral.ai
├── grok/
│   ├── build/           # Grok Build tool protocol, backend URLs, gRPC, agent profiles
│   └── web/             # grok.com web frontend REST/Auth/File/Imagine endpoints
├── gemini/
│   └── web/             # Gemini BOQ SPA, generativelanguage API, RPC backend
├── z-ai/
│   └── chat/            # Z.ai (GLM/Zhipu) API, convert, storage, admin
├── groq/                # api.groq.com, chat.groq.com, LPU inference
├── together/             # Together AI multi-model API
├── fireworks/            # Fireworks AI fast inference
├── replicate/            # Replicate model hosting
├── stability/            # Stability AI + platform.stability.ai
├── perplexity/           # Perplexity AI search
├── huggingface/          # Hub API + inference
├── perchance/
│   ├── generators/       # Perchance.org generator platform API & plugin system
│   └── third-party/      # Unofficial Perchance mirror/proxy sites
└── x/
    └── grok/             # X.com Grok chat API, GraphQL ops, auth patterns
```

All docs sourced from live site probing, JS bundle analysis, and rapiscan (Rust API scanner at `~/Projects/Personal/rapiscm/target/release/rapiscm`).

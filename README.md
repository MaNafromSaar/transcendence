# keepITlocal.ai — Local AI ERP Stack

> A self-hosted, AI-powered ERP system for small businesses and freelancers.
> Built with Docker, PostgreSQL, Ollama, n8n, and more — runs entirely on local hardware.

---

## Quick Start

```bash
# 1. Clone and configure
git clone <repo-url> && cd Server
cp .env.example .env    # Edit with your credentials

# 2. Start the stack
docker compose up -d

# 3. Pull the AI model
docker compose exec ollama ollama pull mistral:7b-instruct-q4_0

# 4. Verify
docker compose ps
```

### Access Services

| Service | URL | Purpose |
|---------|-----|---------|
| **n8n** | http://localhost:5678 | Workflow automation |
| **Open-WebUI** | http://localhost:8088 | Chat with AI |
| **pgAdmin** | http://localhost:8085 | Database management |
| **Metabase** | http://localhost:3000 | Analytics dashboards |
| **llama_wrapper** | http://localhost:8087 | AI API proxy |

> Credentials are configured in your `.env` file. See `.env.example` for required variables.

---

## Stack Overview

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL 16 | 5432 | Main database (CRM, ERP, email data, pgvector) |
| n8n | 5678 | Workflow automation engine |
| Ollama | 11434 | Local LLM (mistral:7b-instruct-q4_0, CPU-friendly) |
| Open-WebUI | 8088 | ChatGPT-like interface |
| Metabase | 3000 | Business intelligence dashboards |
| pgAdmin | 8085 | Database GUI |
| llama_wrapper | 8087 | Stable FastAPI proxy for Ollama |
| embedding_service | 8082 | Sentence-transformers for RAG |
| vector_service | 8081 | pgvector REST API |
| NGINX | 80/443 | Reverse proxy with TLS & auth |

---

## Documentation

| Document | Description |
|----------|-------------|
| [MASTER_DOCUMENTATION.md](MASTER_DOCUMENTATION.md) | Full project overview, architecture, team roles, module roadmap |
| [PROJECT_TRACKER.md](PROJECT_TRACKER.md) | Sprint planning, meeting log, issue/decision tracking |
| [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | Common commands cheatsheet |
| [docs/README_AI.md](docs/README_AI.md) | AI/Ollama setup & model management |
| [docs/SECURITY.md](docs/SECURITY.md) | Security implementation details |
| [docs/CRM_IMPLEMENTATION_GUIDE.md](docs/CRM_IMPLEMENTATION_GUIDE.md) | CRM module setup |
| [docs/ACCESS_GUIDE.md](docs/ACCESS_GUIDE.md) | Service access & credentials guide |
| [docs/METABASE_QUICK_START.md](docs/METABASE_QUICK_START.md) | Dashboard setup |

---

## Common Commands

```bash
# Service management
docker compose ps                          # Status
docker compose logs <service> --tail 100   # Logs
docker compose restart <service>           # Restart

# Database
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB

# AI
docker compose exec ollama ollama list     # List models
curl -X POST http://localhost:8087/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello!","model":"mistral:7b-instruct-q4_0","max_tokens":100}'
```

---

## Project Structure

```
Server/
├── README.md                  # This file — quick start
├── MASTER_DOCUMENTATION.md    # Team reference & architecture
├── PROJECT_TRACKER.md         # Sprints, meetings, decisions
├── docker-compose.yml         # Service stack
├── .env.example               # Environment template
├── .gitignore
│
├── docs/                      # Detailed documentation
├── ai/                        # FastAPI wrapper for Ollama
├── crm_forms/                 # CRM HTML forms
├── db/                        # SQL schemas & migrations
├── embedding_service/         # Text embedding service
├── vector_service/            # pgvector REST service
├── models/                    # Local model files
├── n8n/                       # n8n config
├── n8n_workflows/             # Exported workflows & guides
└── nginx/                     # Reverse proxy config
```

---

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes and test locally
3. Submit a pull request with description
4. Get at least 1 review before merging

See [MASTER_DOCUMENTATION.md](MASTER_DOCUMENTATION.md) for full contribution guidelines and team workflow.

---

**keepITlocal.ai** | February 2026 | Local-first AI for business

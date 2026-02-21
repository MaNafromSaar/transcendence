# keepITlocal.ai — Master Documentation

> **A locally deployable AI-powered ERP for small businesses and freelancers**
> Team project (4–5 members) | Started: February 2026

---

## 1. Vision & Goals

**keepITlocal.ai** transforms a proven AI server stack into a **fully fledged, self-hosted ERP system** aimed at German small businesses and freelancers. The core principle: **the heavy lifting runs offline** on local hardware — no cloud dependency, full data sovereignty (DSGVO-compliant).

### What we are building
- **CRM**: Contact management, client history, communication tracking
- **Invoicing & Accounting**: Quotes, invoices, payment tracking
- **Project Management**: Task boards, time tracking, resource planning
- **AI Email Processor**: Automatic classification, contact extraction, meeting detection
- **RAG Knowledge Base**: Upload documents → vector search → AI-powered Q&A
- **Dashboards & Analytics**: Business KPIs via Metabase
- **Workflow Automation**: n8n-driven pipelines for repetitive tasks
- **Outbound Services** (optional, paid): AI phone agents, external API integrations

### Target Hardware (current proof of concept)
- **32 GB CPU RAM**, **2 GB VRAM** — scales up when dedicated hardware is available
- All AI inference via **Ollama** with quantized models (CPU-friendly)

---

## 2. Team Roles

Defined per transcendence subject requirements (§II.1.1).Some roles are combined.

### Product Owner (PO) — Matthias Naumann
- Defines product vision and prioritizes features
- Maintains the product backlog
- Validates completed work
- Communicates with stakeholders (clients, evaluators, peers)

### Project Manager (PM) / Scrum Master — Matthias Naumann
- Organizes team meetings and planning sessions
- Tracks progress and deadlines (see [PROJECT_TRACKER.md](PROJECT_TRACKER.md))
- Ensures team communication
- Manages risks and blockers

### Technical Lead / Architect — Lewin Sorg
- Defines technical architecture
- Makes technology stack decisions
- Ensures code quality and best practices
- Reviews critical code changes

### Developers — All team members
- Write code for assigned features
- Participate in code reviews
- Test their implementations
- Document their work

---

## 3. Technical Stack

| Service | Image / Tech | Port | Purpose |
|---------|-------------|------|---------|
| **PostgreSQL** 16 | `postgres:16` | 5432 | Main database (CRM, ERP, email data) |
| **n8n** | `n8nio/n8n` | 5678 | Workflow automation engine |
| **Ollama** | `ollama/ollama` | 11434 | Local LLM inference (mistral:7b-instruct-q4_0) |
| **Open-WebUI** | `ghcr.io/open-webui` | 8088 | Chat interface for AI |
| **Metabase** | `metabase/metabase` | 3000 | Analytics dashboards |
| **pgAdmin** | `dpage/pgadmin4` | 8085 | Database GUI |
| **llama_wrapper** | Custom FastAPI | 8087 | Stable HTTP proxy for Ollama |
| **embedding_service** | Custom (sentence-transformers) | 8082 | Text embeddings for RAG |
| **vector_service** | Custom (pgvector) | 8081 | Vector storage & similarity search |
| **NGINX** | `nginx` | 80/443 | Reverse proxy, TLS, auth |

All services run via `docker compose` and bind to `127.0.0.1` (localhost only).

---

## 4. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                     NGINX (reverse proxy)            │
│              TLS termination + Basic Auth             │
└────────┬──────────┬──────────┬──────────┬───────────┘
         │          │          │          │
    ┌────▼───┐ ┌───▼────┐ ┌──▼───┐ ┌───▼─────┐
    │  n8n   │ │Metabase│ │WebUI │ │pgAdmin  │
    │Workflow│ │BI Dash │ │ Chat │ │DB Admin │
    └───┬────┘ └───┬────┘ └──┬───┘ └───┬─────┘
        │          │         │         │
   ┌────▼──────────▼─────────▼─────────▼────┐
   │            PostgreSQL 16                │
   │   (CRM + ERP + pgvector extensions)     │
   └────────────────┬───────────────────────┘
                    │
        ┌───────────▼───────────┐
        │    Ollama (LLM)       │
        │    llama_wrapper      │
        │    embedding_service  │
        │    vector_service     │
        └───────────────────────┘
```

---

## 5. Project Management Practices

Per transcendence subject recommendations (§II.1.2):

### Communication
- **Daily async standup**: Post in team channel (what you did / what's next / blockers)
- **Weekly sync**: 30 min video call (Tuesday or Wednesday)
- **Sprint review**: 1h at end of each 2-week sprint

### Task Tracking
- **Primary**: [PROJECT_TRACKER.md](PROJECT_TRACKER.md) — sprints, issues, decisions
- **GitHub Issues**: Linked to feature branches and PRs
- **n8n Automation**: Leverage the stack itself for reminders, status updates, scheduling

### Git Workflow
- `main` branch: always deployable
- `feature/<name>`: one branch per task
- Pull requests required with at least 1 reviewer
- Commit format: `type(scope): description`

---

## 6. Module Roadmap

Inspired by transcendence subject module categories, adapted for ERP:

### Mandatory Core
- [x] Docker Compose orchestration
- [x] PostgreSQL database with schema
- [x] n8n workflow engine
- [x] Ollama local AI inference
- [x] Email AI processor
- [ ] Web frontend (choose framework)
- [ ] User authentication & management

### Web & Accessibility (transcendence §IV.1–IV.2)
- [ ] Responsive web frontend
- [ ] Multi-language support (DE / EN / FR)
- [ ] Accessibility compliance (WCAG)
- [ ] Browser compatibility

### User Management (transcendence §IV.3)
- [ ] User registration & login
- [ ] Role-based access control (Admin / Manager / User)
- [ ] Profile management
- [ ] Activity logging

### AI & Knowledge Base (transcendence §IV.4)
- [ ] RAG pipeline: document ingestion → embeddings → pgvector
- [ ] Knowledge base chat (query documents via AI)
- [ ] AI-powered document summarization
- [ ] Smart contact extraction from emails
- [ ] AI meeting scheduler suggestions

### Cybersecurity (transcendence §IV.5)
- [ ] HTTPS/TLS on all endpoints
- [ ] Input validation & SQL injection prevention
- [ ] DSGVO compliance documentation
- [ ] Rate limiting & brute force protection
- [ ] Secrets management (no hardcoded credentials)

### DevOps (transcendence §IV.7)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Automated testing
- [ ] Monitoring & health checks
- [ ] Backup strategy for database
- [ ] Deployment documentation

### Data & Analytics (transcendence §IV.8)
- [ ] Metabase dashboards for CRM KPIs
- [ ] Revenue tracking & forecasting
- [ ] Client activity reports
- [ ] Email processing statistics

### ERP Modules (project-specific)
- [ ] Contact & client management (CRM)
- [ ] Invoice generation & tracking
- [ ] Quote/offer management
- [ ] Project & task board
- [ ] Time tracking
- [ ] Expense tracking
- [ ] Calendar integration

---

## 7. File Structure

```
Server/
├── README.md                    # Quick start & overview
├── MASTER_DOCUMENTATION.md      # This file — team reference
├── PROJECT_TRACKER.md           # Sprints, meetings, decisions
├── docker-compose.yml           # Full service stack
├── .env.example                 # Environment variable template
├── .gitignore                   # Protects secrets & volumes
│
├── docs/                        # Detailed documentation
│   ├── ACCESS_GUIDE.md
│   ├── CRM_IMPLEMENTATION_GUIDE.md
│   ├── FILE_STRUCTURE.md
│   ├── METABASE_DASHBOARDS.md
│   ├── METABASE_QUICK_START.md
│   ├── QUICK_REFERENCE.md
│   ├── README_AI.md
│   └── SECURITY.md
│
├── ai/                          # FastAPI wrapper for Ollama
├── ai_model/                    # Model configs
├── crm_forms/                   # CRM HTML forms
├── db/                          # SQL schemas, migrations, test data
├── embedding_service/           # Sentence-transformers service
├── models/                      # Local model files
├── n8n/                         # n8n configuration
├── n8n_workflows/               # Exported n8n workflows + guides
├── nginx/                       # NGINX config, certs, htpasswd
├── traefik/                     # Traefik config (optional, unused)
└── vector_service/              # pgvector REST service
```

---

## 8. Getting Started

### Prerequisites
- Docker & Docker Compose
- 32 GB RAM (minimum for comfortable CPU inference)
- Linux recommended (tested on Ubuntu / WSL2)

### Setup
```bash
# Clone the repository
git clone <repo-url> && cd Server

# Create your environment file
cp .env.example .env
# Edit .env with your credentials

# Start the stack
docker compose up -d

# Pull the AI model
docker compose exec ollama ollama pull mistral:7b-instruct-q4_0

# Verify services
docker compose ps
```

### Access Services
| Service | URL |
|---------|-----|
| n8n | http://localhost:5678 |
| Open-WebUI | http://localhost:8088 |
| pgAdmin | http://localhost:8085 |
| Metabase | http://localhost:3000 |
| llama_wrapper API | http://localhost:8087 |

---

## 9. Contribution Guidelines

1. **Branch** from `main`: `git checkout -b feature/your-feature`
2. **Implement** your changes with clear commits
3. **Test** locally: `docker compose up -d && docker compose ps`
4. **Document** what you changed (update relevant docs)
5. **Pull request**: Describe what, why, and how to test
6. **Review**: At least 1 team member must approve
7. **Merge** into `main` after approval

See [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) for common commands.

---

## 10. Contact & Support

- **Product Owner / PM**: Matthias Naumann
- **Tracker**: [PROJECT_TRACKER.md](PROJECT_TRACKER.md)
- **Detailed docs**: [docs/](docs/) folder
- **Stack issues**: Check `docker compose logs <service>`

---

**Last Updated**: February 21, 2026 | **keepITlocal.ai**

**Last Updated**: February 21, 2026
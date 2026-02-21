# keepITlocal.ai — Project Tracker

> **Project**: Local AI ERP Stack for Small Businesses & Freelancers
> **Started**: February 2026 | **Team Size**: 4–5 | **Method**: Agile / Scrum-lite

---

## Team Roster & Roles

| Name | Role(s) | Focus Areas |
|------|---------|-------------|
| Matthias Naumann | **Project Manager** | Vision, roadmap, task delegation, meetings, hardware setup |
| Lewin Sorg | **Technical Lead / Architect** | Architecture decisions, code review, stack choices |
| Daniel Springer | **Product Owner / Compliance Officer** | Guardrails, validation, comparative review |
| Silvestri | **Developer / UX feedback / DB Design** | Feature implementation, testing |
| Taulant | **Developer / Frontend designer** | Dashboards, GUI, analytics |

> All roles documented per transcendence subject requirements (§II.1.1).
> With 4 members some roles are combined. With 5, they can be split.

---

## Sprint Overview

### Sprint 0 — Project Bootstrap (Feb 21 – Feb 28, 2026)

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 0.1 | Define project vision & goals | PM | ✅ Done | See [MASTER_DOCUMENTATION.md](MASTER_DOCUMENTATION.md) |
| 0.2 | Assign team roles | PM | ✅ Done | See above |
| 0.3 | Sanitize credentials for GitHub | PM | ✅ Done | .env.example with placeholders |
| 0.4 | Organize documentation into docs/ | PM | ✅ Done | 8 files moved |
| 0.5 | Create MASTER_DOCUMENTATION.md | PM | ✅ Done | Team-facing overview |
| 0.6 | Create PROJECT_TRACKER.md | PM | ✅ Done | This file |
| 0.7 | Initialize GitHub repository | PM | 🔲 Todo | |
| 0.8 | Verify docker compose up locally | Team | 🔲 Todo | Full stack smoke test |
| 0.9 | Team onboarding meeting | PM | 🔲 Todo | Schedule for week 1 |

### Sprint 1 — Core Stack & Local Validation (Mar 1 – Mar 14, 2026)

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 1.1 | Validate all Docker services start locally | DevOps | 🔲 Todo | |
| 1.2 | Test n8n email processor workflow | Dev | 🔲 Todo | With local Ollama |
| 1.3 | Test CRM schema + forms | Dev | 🔲 Todo | PostgreSQL + pgAdmin |
| 1.4 | Test Metabase dashboards | Data | 🔲 Todo | |
| 1.5 | Benchmark Ollama model performance | AI/Dev | 🔲 Todo | CPU-only, 32GB RAM |
| 1.6 | Set up GitHub Issues for task tracking | PM | 🔲 Todo | |
| 1.7 | Define coding standards & PR workflow | Tech Lead | 🔲 Todo | |

### Sprint 2 — ERP Foundation (Mar 15 – Mar 28, 2026)

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 2.1 | Design ERP module architecture | Tech Lead | 🔲 Todo | Contacts, invoices, projects |
| 2.2 | Implement RAG pipeline (pgvector + embeddings) | Dev | 🔲 Todo | |
| 2.3 | Build knowledge base ingestion workflow | Dev | 🔲 Todo | n8n + embedding_service |
| 2.4 | Create ERP database schema | Data/Dev | 🔲 Todo | |
| 2.5 | Web frontend — choose framework | Tech Lead | 🔲 Todo | |
| 2.6 | Security audit of local deployment | DevOps | 🔲 Todo | |

### Sprint 3 — AI Features & UX (Mar 29 – Apr 11, 2026)

| # | Task | Assignee | Status | Notes |
|---|------|----------|--------|-------|
| 3.1 | AI-powered document summarization | Dev/AI | 🔲 Todo | |
| 3.2 | Smart contact extraction from emails | Dev/AI | 🔲 Todo | Extend existing workflow |
| 3.3 | Chat interface for knowledge base queries | Dev | 🔲 Todo | Open-WebUI or custom |
| 3.4 | Multi-language support (DE/EN/FR) | Dev | 🔲 Todo | |
| 3.5 | Dashboard for ERP KPIs | Data | 🔲 Todo | Metabase |

---

## Meetings

| Date | Type | Attendees | Agenda | Minutes |
|------|------|-----------|--------|---------|
| TBD (Week 1) | Kickoff | All | Roles, vision, Sprint 1 planning | — |
| | Weekly Standup | All | Progress, blockers, next steps | — |
| | Sprint Review | All | Demo completed work, retrospective | — |

### Meeting Cadence
- **Daily async standup**: Post in team channel — what you did, what's next, any blockers
- **Bi-weekly sync** (30 min): Tuesday and Friday, video call
- **Sprint review** (1h): End of each 2-week sprint
- **Planning session** (1h): Start of each sprint

---

## Milestones

| Milestone | Target Date | Description |
|-----------|-------------|-------------|
| M0: Project Bootstrap | Feb 28, 2026 | Repo live, team onboarded, stack running locally |
| M1: Core Validated | Mar 14, 2026 | All existing services tested & working locally |
| M2: ERP Foundation | Mar 28, 2026 | Basic ERP modules + RAG pipeline operational |
| M3: AI-Enhanced ERP | Apr 11, 2026 | AI features integrated, knowledge base working |
| M4: MVP Ready | Apr 30, 2026 | Usable by first test client / internal use |
| M5: Production | TBD | Deployed on dedicated hardware, client-ready |

---

## Issue Log

| # | Date | Issue | Severity | Owner | Status | Resolution |
|---|------|-------|----------|-------|--------|------------|
| — | — | — | — | — | — | — |

> Track blockers, bugs, and technical debt here. Move to GitHub Issues once repo is set up.

---

## Decision Log

| # | Date | Decision | Rationale | Decided By |
|---|------|----------|-----------|------------|
| D1 | 2026-02-21 | Preparing documentation of state | Onboarding of team members and  | PM |
| D2 | 2026-02-21 | Deploy locally (32GB RAM, CPU-only) | No server available; proof of concept first | PM |
| D3 | 2026-02-21 | Keep Ollama with mistral:7b-instruct-q4_0 | Fits in 32GB RAM CPU-only; good German support (for 42 purposes English support more realistic) | PM |
| D4 | 2026-02-21 | Use n8n for workflow automation + management tasks | Already in stack; can automate PM tasks too | PM |
| D5 | 2026-02-21 | Target: Local ERP for SMBs & freelancers | Market gap for privacy-first, AI-enhanced, self-hosted ERP | PM |

---

## Workflow & Conventions

### Git Workflow
- **Main branch**: `main` — always deployable
- **Feature branches**: `feature/<name>` — one per task
- **Pull requests**: Required for merge into main; at least 1 review
- **Commit format**: `type(scope): description` (e.g., `feat(crm): add invoice module`)

### Task States
- 🔲 Todo — Not started
- 🔄 In Progress — Actively being worked on
- 🔍 In Review — PR submitted, awaiting review
- ✅ Done — Merged and verified
- ❌ Blocked — Cannot proceed, see issue log

---

**Last Updated**: February 21, 2026

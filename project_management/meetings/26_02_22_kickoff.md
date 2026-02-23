# Kickoff Meeting — "transcendence" (keepITlocal.ai ERP)

**Date:** 2026-02-22
**Time:** 17:00–19:00 CET
**Owner:** @mnaumann
**Participants:** @mnaumann, @lsorg, @dspringer, @silndoj
**Related Module:** Core | Infrastructure

---

## 🎯 Objectives

* Align on project vision, scope, and team structure
* Define timeframe, sprint cadence, and milestones
* Assign initial tasks for Sprint 1
* Decide on tooling for communication, documentation, and project management

---

## 🧠 Key Decisions

* **Communication channel:** Discord
* **Meeting cadence:** 2× per week — Tuesday 18h (30 min, progress check & adjustments), Friday 18h (1h, week review & next-sprint planning)
* **Documentation platform:** GitHub + Markdown files in the repo (no external tools for now; leverage GitHub's built-in features)
* **Team size:** Staying at 4 members (Taulant unavailable). Roles combined where needed (PM + coordination, Tech Lead + Dev). A 5th member only if an exceptional fit is found.
* **Project duration:** Feb 2026 – Apr 2026 (3 months), final review April 15, 2026
* **Deadline context:** Lewin's blackhole is 85+ days out — comfortable margin
* **Sprint structure:**
  * Sprint 0 (Feb 21): Project setup, documentation, local validation ✅ (done)
  * Sprint 1 (Feb 22 – Mar 14): Core stack testing, ERP feature ideation, architecture definition, research
  * Sprint 2 (Mar 15 – Mar 28): ERP foundation and RAG pipeline
  * Sprint 3 (Mar 29 – Apr 11): AI features and UX improvements

---

## ✅ Action Items

* [ ] **Set up fake user company for testing & demos**
  * Owner: @mnaumann
  * Module: Core
  * Priority: High
  * Due: 2026-02-28
  * Notes: Include contacts, invoices, projects, and sample knowledge-base documents

* [ ] **Set up project tracker & calendar with sprint breakdown**
  * Owner: @mnaumann
  * Module: Core
  * Priority: High
  * Due: 2026-02-28
  * Notes: Research what GitHub offers for project management (Projects, Issues, Milestones)

* [ ] **Research deployment with/without GPU support & hardware requirements**
  * Owner: @mnaumann
  * Module: Infrastructure | AI
  * Priority: Medium
  * Due: 2026-02-28
  * Notes: Coordinate with Daniel on AMD/Mac Studio findings

* [ ] **Review current codebase & documentation for gaps**
  * Owner: @lsorg
  * Module: Core | Infrastructure
  * Priority: High
  * Due: 2026-02-28
  * Notes: Identify blockers, missing pieces, or areas needing improvement

* [ ] **Run and extensively test the current stack**
  * Owner: @lsorg
  * Module: Infrastructure
  * Priority: High
  * Due: 2026-02-28
  * Notes: Document any issues found for Sprint 1 backlog

* [ ] **Contact bocal re: compliance requirements**
  * Owner: @dspringer
  * Module: Core
  * Priority: High
  * Due: 2026-02-24
  * Notes: Understand what standards the project must meet

* [ ] **Research knowledge base & RAG implementations**
  * Owner: @dspringer
  * Module: AI
  * Priority: Medium
  * Due: 2026-02-28
  * Notes: How to best integrate RAG into the stack (ingestion, retrieval, model serving)

* [ ] **Audit remaining module requirements**
  * Owner: @dspringer
  * Module: Core
  * Priority: Medium
  * Due: 2026-02-28
  * Notes: How many modules still needed to fulfill subject? What can be meaningfully integrated?

* [ ] **Check GPU support on AMD / Mac Studio architecture**
  * Owner: @dspringer
  * Module: AI | Infrastructure
  * Priority: Low
  * Due: 2026-02-28
  * Notes: Is GPU acceleration meaningful for our target hardware?

* [ ] **Set up n8n workflows (email processor & knowledge-base ingestion)**
  * Owner: @silndoj
  * Module: AI | Core
  * Priority: High
  * Due: 2026-02-28
  * Notes: Test with the local Ollama instance. Silvestri already has n8n experience — workflow creator & tester

* [ ] **Research ERP features & dashboard design**
  * Owner: @silvestri
  * Module: Core
  * Priority: Medium
  * Due: 2026-02-28
  * Notes: Survey existing ERPs, gather feature ideas, sketch dashboard concepts

---

## ❓ Open Questions

* Which project management / calendar tool to adopt? (Notion, GitHub Projects, Trello, Proton.me calendar — needs research)
* Dedicated project email addresses or personal emails with PM on CC?
* GPU support: is it worth pursuing given the target hardware?
* What is the minimum set of ERP modules needed to satisfy the subject requirements?

---

## 📌 Parking Lot

* Sales slogan: _"Empower your business with AI-driven insights and automation — all on your local hardware! What others pay thousands a year for, you can run on your own machine."_
* Daniel as "Compliance Master" — potential formal role if compliance scope grows
* Daniel building up a knowledge base — could become a dedicated module/demo asset
* Consider european provider for both email and calendar (privacy-first, aligns with local-first ethos)

---

## 🔗 References

* Stack repo: `Server/` (keepITlocal.ai — 9 services, Docker Compose)
* Next meeting: **Tuesday, Feb 24, 2026, 18:00 CET** (30 min progress check)

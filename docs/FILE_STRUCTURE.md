# keepITlocal Server - File Structure

## 📂 Essential Files

### Configuration
- **docker-compose.yml** - Main Docker orchestration (PostgreSQL, n8n, Metabase, pgAdmin, Ollama, Open-WebUI, nginx)
- **.env** - Environment variables (passwords, database credentials)
- **.env.example** - Template for environment variables

### Documentation
- **ACCESS_GUIDE.md** - 🌟 **START HERE** - Complete access instructions, credentials, troubleshooting
- **SECURITY.md** - Security architecture, hardening steps, maintenance procedures
- **CRM_IMPLEMENTATION_GUIDE.md** - CRM setup walkthrough, email integration, roadmap
- **METABASE_DASHBOARDS.md** - Dashboard designs with 40+ SQL queries
- **METABASE_QUICK_START.md** - Metabase setup guide
- **README.md** - Project overview
- **README_AI.md** - AI services documentation
- **QUICK_REFERENCE.md** - Quick command reference

### Scripts
- **deploy_security.sh** - Deploy security config (nginx, certs, htpasswd) to server
- **secure_server.sh** - Full server hardening (UFW, fail2ban, SSH keys) - run on server
- **harden_local.sh** - Initial Local server setup

## 📁 Directories

### nginx/
- **nginx.conf** - Reverse proxy config (HTTPS, Basic Auth, rate limiting)
- **certs/** - SSL certificates (fullchain.pem, privkey.pem)
- **.htpasswd** - HTTP Basic Auth credentials

### db/
- **crm_schema.sql** - Complete CRM database schema (8 tables, 5 views)
- **crm_test_data.sql** - Test data (10 customers, 7 projects, €9,034 pipeline)
- **apply_crm_schema.sh** - Migration script

### crm_forms/
- **kunde_verwaltung.html** - Customer management web form (needs n8n webhooks)

### n8n/
- Empty (n8n data stored in Docker volume)

### n8n_workflows/
- Workflow JSON exports (if any)

### ai/
- **Dockerfile** - llama_wrapper service
- **llama_server.py** - API wrapper for Ollama

### embedding_service/
- **Dockerfile** - Text embedding service
- **embedding_server.py** - Sentence transformers API

### vector_service/
- **Dockerfile** - Vector search service
- **vector_server.py** - PostgreSQL pgvector API

### traefik/
- Not used (nginx reverse proxy instead)

## 🗑️ Removed Files

The following obsolete files have been cleaned up:
- README_OLD.md
- README_hardening.md
- README_n8n.md
- WORKFLOW_DOCUMENTATION.md
- STACK_DOCUMENTATION.md
- database_access_guide.txt
- nginx.conf (duplicate, use nginx/nginx.conf)
- docker-compose.production.yml (backup)
- view_email_results.sh
- showcase_email_ai_de.html
- AI_RAG_plan.md

## 🚀 Quick Start

1. **Read ACCESS_GUIDE.md first** - Contains all credentials and access methods
2. Access Metabase: https://localhost/metabase/
3. Access pgAdmin: https://localhost/pgadmin/
4. For n8n/Open-WebUI: Create SSH tunnel (see ACCESS_GUIDE.md)

## 📊 CRM Database

**Location**: PostgreSQL container (server-db-1)  
**Database**: mydb  
**User**: ${POSTGRES_USER}  
**Schema**: db/crm_schema.sql  
**Test Data**: db/crm_test_data.sql

**Tables**: kunden, projekte, interaktionen, angebote, angebote_positionen, rechnungen, aufgaben, produkte  
**Views**: v_active_projects, v_kunden_overview, v_projekt_pipeline, v_umsatz_overview, v_aufgaben_dashboard, v_sales_funnel

## 🔐 Security

**Status**: Production-ready with multi-layer security
- All services localhost-only (127.0.0.1)
- HTTPS with SSL/TLS (self-signed, upgrade to Let's Encrypt for production)
- HTTP Basic Auth (nginx layer)
- Service-level authentication (Metabase, n8n, pgAdmin)
- Rate limiting & security headers
- fail2ban monitoring
- UFW firewall (ports 22, 80, 443)

See **SECURITY.md** for complete security documentation.

## 📝 Notes

- This server is designed as a **DSGVO-compliant showcase** for German SMBs
- Demonstrates "local AI" with Ollama/Mistral (no data sent to external APIs)
- Self-hosted CRM with €0 subscription costs vs €600-2000/year for commercial solutions
- All services running in Docker for portability
- Multi-language support (German primary, English docs)

---

**Last Updated**: November 16, 2025  
**Server**: localhost (Local Machine)  
**Status**: Production-ready, CRM test data loaded, security hardened

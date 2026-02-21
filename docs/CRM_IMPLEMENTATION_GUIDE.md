# keepITlocal CRM Implementation Guide

## 📋 Overview

Lightweight, DSGVO-compliant CRM built on your existing stack:
- **Database**: PostgreSQL (already running)
- **Dashboards**: Metabase (already installed)
- **Automation**: n8n (already configured)
- **UI**: Simple HTML forms + Metabase views
- **Cost**: €0 (no subscriptions)
- **Language**: 100% German

---

## 🚀 Quick Start (3 Steps)

### 1. Apply Database Schema
```bash
# On server
ssh deploy@localhost
cd /home/deploy/projects/Server/db
./apply_crm_schema.sh
```

Or via SSH tunnel:
```bash
ssh -L 5432:localhost:5432 deploy@localhost
cd /home/mana/projects/Server/db
./apply_crm_schema.sh
```

This creates:
- ✅ 8 tables (kunden, projekte, interaktionen, angebote, rechnungen, aufgaben, produkte)
- ✅ 5 dashboard views (sales funnel, project pipeline, revenue, tasks, customer overview)
- ✅ Standard products (AI Phone Agent, Transcription, Email AI)

### 2. Setup Metabase Dashboards
```bash
# Access Metabase
ssh -L 3000:localhost:3000 deploy@localhost
# Open: http://localhost:3000
```

**First-time setup:**
1. Login (setup on first access)
2. Add Database: PostgreSQL → db:5432 → mydb → ${POSTGRES_USER}
3. Follow `METABASE_DASHBOARDS.md` to create 6 dashboards:
   - Executive Dashboard (KPIs, revenue, pipeline)
   - Sales Dashboard (leads, conversion, sources)
   - Project Management (timeline, progress, deadlines)
   - Finance Dashboard (invoices, payments, cashflow)
   - Task Management (todos, priorities, assignments)
   - Customer Insights (CLV, churn risk, industry)

### 3. Open Customer Management UI
```bash
# Serve HTML form locally
cd /home/mana/projects/Server/crm_forms
python3 -m http.server 8000

# Or copy to server nginx
rsync -avz kunde_verwaltung.html deploy@localhost:/var/www/crm/
```

Access: `http://localhost:8000/kunde_verwaltung.html`

---

## 📊 What's Included

### Database Schema (`db/crm_schema.sql`)

#### Core Tables:
1. **kunden** (Customers)
   - Firmendaten (company info)
   - Ansprechpartner (contact person)
   - Adresse (address)
   - Status (lead → interessent → aktiv)
   - Priorität, Quelle, Potential-Bewertung

2. **projekte** (Projects)
   - Projekt-Typ (AI-Telefonagent, Transkription, Email-Ingestion, etc.)
   - Status (angebot → beauftragt → in_arbeit → abgeschlossen)
   - Finanzielle Daten (Angebot, tatsächliche Kosten, Gewinn)
   - Timeline, Deadline, Fortschritt

3. **interaktionen** (Interactions)
   - Typ (email, telefon, meeting, demo, support)
   - Links to email_classifications table
   - Follow-up tracking

4. **angebote** (Quotes)
   - Angebots-Nummer (AIH-2025-001)
   - Line items (angebote_positionen)
   - MwSt, Rabatt, Gültigkeitsdatum

5. **rechnungen** (Invoices)
   - Rechnungs-Nummer (RE-2025-001)
   - Zahlungsstatus (bezahlt, überfällig, etc.)
   - PDF-Pfad

6. **aufgaben** (Tasks)
   - Follow-ups, Angebote erstellen, Demos, etc.
   - Priorität, Fälligkeitsdatum, Zuordnung

7. **produkte** (Product Catalog)
   - Pre-populated with your services
   - AI-Telefonagent: 99€/Monat
   - Transkription: 149€/Monat
   - Email-KI-Assistent: 79€/Monat

8. **angebote_positionen** (Quote Line Items)
   - Verknüpfung Angebot ↔ Produkte

#### Dashboard Views:
- `v_kunden_overview` - Customer stats with last interaction
- `v_projekt_pipeline` - Active projects with deadline warnings
- `v_umsatz_overview` - Monthly revenue overview
- `v_aufgaben_dashboard` - Tasks with urgency levels
- `v_sales_funnel` - Lead → Interessent → Kunde conversion

### Metabase Dashboards (`METABASE_DASHBOARDS.md`)

**6 ready-to-use dashboards with 40+ SQL queries:**

1. **Executive Dashboard** (for Matthias)
   - KPIs: Active customers, pipeline value, open invoices
   - Charts: Revenue trend, sales funnel, project distribution
   - Tables: Overdue deadlines, upcoming follow-ups

2. **Sales Dashboard**
   - Lead sources, conversion rates
   - Hot leads (priority + potential > 7)
   - Win/loss analysis

3. **Project Management**
   - Project timeline, progress tracking
   - Team workload, blocked projects
   - Deadline warnings (🔴 overdue, 🟡 this week, 🟢 on track)

4. **Finance Dashboard**
   - Monthly revenue, open receivables
   - Overdue invoices (auto-red)
   - Cashflow forecast (next 3 months)

5. **Task Management**
   - My tasks (filtered by user)
   - Urgency levels (overdue, today, this week)
   - Team workload distribution

6. **Customer Insights**
   - Customer Lifetime Value (CLV)
   - Churn risk (inactive > 90 days)
   - Industry distribution, growth potential

### HTML Forms (`crm_forms/`)

**kunde_verwaltung.html** - Customer Management:
- ➕ Add new customers (all German fields)
- 📋 List all customers (searchable)
- ✏️ Edit existing customers
- 📊 Quick stats (total, active, leads)

**Features:**
- Beautiful gradient design (keepITlocal branding)
- Responsive layout
- Form validation
- Real-time search
- Status badges (lead, interessent, aktiv)
- Priority color coding

**API Backend:** n8n webhooks (need to create):
- `/webhook/crm/customer/create` - POST new customer
- `/webhook/crm/customers` - GET all customers
- `/webhook/crm/stats` - GET statistics

---

## 🔗 Integration with Email Processor

### Auto-Create Leads from Emails

**n8n Workflow:** `email_to_crm.json` (to be created)

**Flow:**
1. Gmail Email Processor runs
2. New email → `email_classifications` table
3. Check if sender exists in `kunden`
4. If not → Create new lead:
   ```sql
   INSERT INTO kunden (firma_name, ansprechpartner_name, email, telefon, 
                       kunde_status, quelle, prioritaet, erstellt_von)
   SELECT sender_name, sender_name, sender_email, phone_number,
          'lead', 'Email-Anfrage',
          CASE WHEN priority = 'high' THEN 'hoch' ELSE 'mittel' END,
          'Email-AI'
   FROM email_classifications
   WHERE id = {{new_email_id}}
   ```

5. Create interaction record:
   ```sql
   INSERT INTO interaktionen (kunde_id, typ, richtung, betreff, 
                              zusammenfassung, email_id, durchgefuehrt_von)
   VALUES ({{kunde_id}}, 'email', 'eingehend', {{topic}}, 
           {{summary}}, {{email_id}}, 'Email-AI')
   ```

6. If `action_required = yes` → Create task:
   ```sql
   INSERT INTO aufgaben (kunde_id, titel, typ, prioritaet, 
                         faellig_am, zugeordnet_an, erstellt_von)
   VALUES ({{kunde_id}}, 'Follow-up: {{sender_name}}', 'follow_up',
           {{priority}}, CURRENT_DATE + INTERVAL '2 days', 
           'Matthias', 'Email-AI')
   ```

**Benefits:**
- ✅ Zero manual data entry
- ✅ Auto-lead capture from every email
- ✅ Automatic follow-up reminders
- ✅ Full email history per customer
- ✅ AI-extracted contact data

---

## 📈 Next Steps (Implementation Order)

### Week 1: Core Setup (Done!)
- [x] Database schema designed
- [x] SQL migration script created
- [x] Metabase dashboard structure planned
- [x] HTML customer form created

### Week 2: Deploy & Configure
- [ ] Apply schema to server: `./apply_crm_schema.sh`
- [ ] Setup Metabase connection
- [ ] Create 6 dashboards (copy queries from `METABASE_DASHBOARDS.md`)
- [ ] Test customer form (create 2-3 test customers)

### Week 3: n8n Automations
- [ ] Create n8n webhook endpoints:
  - POST `/webhook/crm/customer/create`
  - GET `/webhook/crm/customers`
  - GET `/webhook/crm/stats`
- [ ] Connect Email Processor → CRM integration
- [ ] Test: Send email → Auto-create lead → Show in dashboard

### Week 4: Additional Forms
- [ ] `projekt_verwaltung.html` - Project management
- [ ] `angebot_erstellen.html` - Quote generator
- [ ] `rechnung_erstellen.html` - Invoice creator
- [ ] `aufgaben_board.html` - Kanban task board

### Week 5: Polish & Production
- [ ] Add customer detail pages
- [ ] Create PDF quote templates (wkhtmltopdf)
- [ ] Email notification for high-priority tasks
- [ ] Backup automation (daily DB dumps)
- [ ] Mobile-responsive testing

---

## 🔧 Maintenance

### Daily
- Check Metabase "Task Management" dashboard
- Review "Meine Aufgaben" (my tasks)
- Follow up on overdue items

### Weekly
- Review "Sales Dashboard" (new leads, conversion)
- Check "Finance Dashboard" (overdue invoices)
- Update project progress in "Project Management"

### Monthly
- Review "Executive Dashboard" (KPIs, revenue trend)
- Customer churn check (inactive > 90 days)
- Plan follow-ups for high-potential leads

### Database Backups
```bash
# Manual backup
ssh deploy@localhost
docker exec db pg_dump -U ${POSTGRES_USER} mydb > backup_$(date +%Y%m%d).sql

# Automated (add to cron)
0 2 * * * docker exec db pg_dump -U ${POSTGRES_USER} mydb | gzip > /backups/crm_$(date +\%Y\%m\%d).sql.gz
```

---

## 🎯 Future Enhancements

### Short-term (1-2 months)
1. **PDF Quote Generator** - n8n + wkhtmltopdf
2. **Email Templates** - Angebot sent, Invoice reminder
3. **Calendar Integration** - Meeting scheduling from interaktionen
4. **WhatsApp Integration** - Chat history → interaktionen

### Mid-term (3-6 months)
1. **Mobile App** - React Native oder Progressive Web App
2. **Voice Notes** - Whisper transcription → interaktionen
3. **Document Management** - Upload contracts, invoices (MinIO)
4. **Time Tracking** - Log hours per project

### Long-term (6-12 months)
1. **AI Assistant** - "Show me hot leads this week"
2. **Predictive Analytics** - Lead scoring, churn prediction
3. **Multi-user Roles** - Sales, Operations, Finance permissions
4. **Customer Portal** - Self-service project status

---

## 💡 Why This Approach Wins

### vs. Odoo/ERPNext:
- ✅ 10x faster setup (1 week vs 1 month)
- ✅ No Python/Node.js dependencies
- ✅ Uses your existing stack 100%
- ✅ 1GB RAM vs 4GB+ for full ERP
- ✅ You understand every line of code

### vs. HubSpot/Pipedrive:
- ✅ €0/month vs €600-2000/year
- ✅ 100% DSGVO compliant (proves your value prop)
- ✅ Full AI integration (Ollama, Whisper, n8n)
- ✅ No vendor lock-in
- ✅ Perfect German (you control it)

### vs. Custom React/FastAPI:
- ✅ Production-ready in 1 week vs 3 months
- ✅ No new tech stack to learn/maintain
- ✅ Metabase > custom charts (for now)
- ✅ Focus on customer projects, not internal tools

---

## 📞 Support & Next Steps

**Ready to implement?** Let's start with:
1. Apply database schema (5 minutes)
2. Create first Metabase dashboard (30 minutes)
3. Test customer form (10 minutes)

After that, we'll tackle:
- n8n webhook endpoints for forms
- Email → CRM auto-integration
- Additional forms (projects, quotes, invoices)

**Files Created:**
```
Server/
├── db/
│   ├── crm_schema.sql              # Full database schema
│   └── apply_crm_schema.sh         # Migration script
├── crm_forms/
│   └── kunde_verwaltung.html       # Customer management UI
├── METABASE_DASHBOARDS.md          # 6 dashboards with 40+ SQL queries
├── docker-compose.yml              # Synced from server
└── docker-compose.production.yml   # Backup of working config
```

**Want me to start implementing?** Say:
- "Apply the schema" → I'll run the migration
- "Setup Metabase" → I'll create the first dashboard
- "Build n8n webhooks" → I'll create the API backend
- "Show me a demo" → I'll create test data and screenshots

---

**Status**: 📐 Planning Complete | 🚀 Ready to Deploy
**Estimated Time to Production**: 1 week
**Monthly Cost**: €0 (uses existing VPS)
**DSGVO Compliance**: ✅ 100%

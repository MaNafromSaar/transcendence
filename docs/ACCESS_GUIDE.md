# keepITlocal Server Access Guide

**Server**: localhost (Local Machine)  
**Updated**: November 16, 2025

## 🔐 Authentication Layers

### Layer 1: SSH Access
```bash
ssh deploy@localhost
```
**Password**: (your SSH password)

### Layer 2: HTTP Basic Auth
**Username**: keepitlocal  
**Password**: <BASIC_AUTH_PASSWORD>  
Required for all HTTPS web services.

### Layer 3: Service-Level Authentication
Each service has its own login credentials (see below).

## 🌐 Web Services (HTTPS)

### Metabase CRM Dashboard
**URL**: https://localhost/metabase/  
**Login**: matthias.naumann@keepitlocal.ai / <METABASE_PASSWORD>  
**Purpose**: CRM analytics, customer insights, project pipeline

**Quick Start**:
1. Browser prompts for Basic Auth → Enter: keepitlocal / <BASIC_AUTH_PASSWORD>
2. Metabase login → Enter email/password above
3. Database already connected to CRM (mydb)
4. Test data loaded: 10 customers, 7 projects, €9,034 pipeline

### pgAdmin Database Manager
**URL**: https://localhost/pgadmin/  
**Login**: matthias.naumann@keepITlocal.ai / <PGADMIN_PASSWORD>  
**Purpose**: PostgreSQL database administration

**Setup Database Connection**:
1. Right-click "Servers" → Register → Server
2. General tab: Name = "keepITlocal CRM"
3. Connection tab:
   - Host: db
   - Port: 5432
   - Database: mydb
   - Username: ${POSTGRES_USER}
   - Password: <POSTGRES_PASSWORD>
4. Save

## 🔌 SSH Tunnel Access (for n8n & Open-WebUI)

These services don't support subpath mounting, so use SSH tunnels:

```bash
ssh -L 5678:localhost:5678 -L 8088:localhost:8088 deploy@localhost -N
```

Keep this terminal running in background.

### n8n Workflow Automation
**URL**: http://localhost:5678 (via tunnel)  
**Login**: admin / <N8N_PASSWORD>  
**Purpose**: Workflow automation, webhooks, integrations

### Open-WebUI (Chat Interface)
**URL**: http://localhost:8088 (via tunnel)  
**Purpose**: ChatGPT-like interface for Ollama/Mistral AI

**No login required** (WEBUI_AUTH=false)

## 🤖 AI Services

### Ollama (Mistral 7B)
**Model**: mistral:7b-instruct-q4_0  
**Access via CLI**:
```bash
ssh deploy@localhost
docker exec -it server-ollama-1 ollama run mistral:7b-instruct-q4_0
```

**Example**:
```bash
docker exec server-ollama-1 ollama run mistral:7b-instruct-q4_0 "Explain DSGVO in 2 sentences"
```

## 📊 CRM Database

### Connection Details
**Host**: db (internal) / localhost (via tunnel)  
**Port**: 5432  
**Database**: mydb  
**User**: ${POSTGRES_USER}  
**Password**: <POSTGRES_PASSWORD>

### Tables
- `kunden` - Customers (10 test records)
- `projekte` - Projects (7 active/quoted)
- `interaktionen` - Customer interactions (8 records)
- `angebote` - Quotes (5 records, €9,034 pipeline)
- `angebote_positionen` - Quote line items
- `rechnungen` - Invoices (5 records, €7,787 paid)
- `aufgaben` - Tasks (9 records, 2 overdue)
- `produkte` - Service catalog (6 products)

### Views
- `v_active_projects` - Current projects with customer names
- `v_kunden_overview` - Customer stats with last interaction
- `v_projekt_pipeline` - Project pipeline with deadline warnings
- `v_umsatz_overview` - Monthly revenue overview
- `v_aufgaben_dashboard` - Task urgency dashboard
- `v_sales_funnel` - Sales conversion funnel

### Test Data Highlights
- **Bäckerei Müller**: Hot lead from Email-AI (proves concept!)
- **Steuerberatung Wagner**: €4,500 mega opportunity
- **Zentrum Naturmedizin**: €8,950 Swiss VIP customer
- **Pipeline Value**: €9,034.60
- **Open Receivables**: €4,707
- **MRR**: €327
- **Customer Lifetime Value**: €2,200

## 🔒 Security Status

### Network Security
✅ All services bound to localhost (127.0.0.1)  
✅ Direct port access blocked  
✅ UFW firewall configured (ports 22, 80, 443 only)

### Transport Security
✅ SSL/TLS encryption (TLSv1.2+)  
✅ HTTP → HTTPS redirect  
✅ Security headers (XSS, clickjacking protection)

### Authentication
✅ SSH key-based (password auth disabled via secure_server.sh)  
✅ HTTP Basic Auth (nginx layer)  
✅ Service-level logins (Metabase, n8n, pgAdmin)  
✅ Rate limiting (10-20 req/s, DDoS protection)

### Monitoring
✅ Access logs: /var/log/nginx/access.log  
✅ Error logs: /var/log/nginx/error.log  
✅ fail2ban: Auto-bans after 3 failed attempts  
✅ Health endpoint: http://localhost/health (no auth)

## 🛠️ Maintenance Commands

### Docker Services
```bash
# View running containers
ssh deploy@localhost 'docker ps'

# View logs
ssh deploy@localhost 'docker logs server-metabase-1'
ssh deploy@localhost 'docker logs server-n8n-1'
ssh deploy@localhost 'docker logs server-nginx-1'

# Restart service
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart metabase'

# Restart all
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart'
```

### Database Access
```bash
# Direct psql access
ssh deploy@localhost 'docker exec -it server-db-1 psql -U ${POSTGRES_USER} -d mydb'

# Run SQL query
ssh deploy@localhost 'docker exec server-db-1 psql -U ${POSTGRES_USER} -d mydb -c "SELECT COUNT(*) FROM kunden;"'

# Backup database
ssh deploy@localhost 'docker exec server-db-1 pg_dump -U ${POSTGRES_USER} mydb > backup_$(date +%Y%m%d).sql'
```

### Update Services
```bash
# Pull latest images
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose pull'

# Restart with new images
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose up -d'
```

## 📁 File Locations

### On Server
- **Docker compose**: /home/deploy/projects/Server/docker-compose.yml
- **Environment**: /home/deploy/projects/Server/.env
- **Nginx config**: /home/deploy/projects/Server/nginx/nginx.conf
- **SSL certs**: /home/deploy/projects/Server/nginx/certs/
- **Basic Auth**: /home/deploy/projects/Server/nginx/.htpasswd
- **CRM schema**: /home/deploy/projects/Server/db/crm_schema.sql
- **Test data**: /home/deploy/projects/Server/db/crm_test_data.sql

### Docker Volumes
- **PostgreSQL data**: server_db_data
- **n8n data**: server_n8n_data
- **Ollama models**: server_ollama_models
- **Open-WebUI data**: server_open_webui_data
- **Nginx logs**: server_nginx_logs

## 🚨 Troubleshooting

### Cannot Access Services
```bash
# Check if containers are running
ssh deploy@localhost 'docker ps'

# Check nginx logs
ssh deploy@localhost 'docker logs server-nginx-1 2>&1 | tail -20'

# Test Basic Auth
curl -u keepitlocal:<BASIC_AUTH_PASSWORD> https://localhost/health -k

# Restart nginx
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart nginx'
```

### SSH Tunnel Not Working
```bash
# Kill existing tunnels
pkill -f "ssh.*localhost.*-L"

# Create fresh tunnel
ssh -L 5678:localhost:5678 -L 8088:localhost:8088 deploy@localhost -N

# In new terminal, test
curl http://localhost:5678
curl http://localhost:8088
```

### Browser Shows Old/Cached Content
1. Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
2. Clear cache for site
3. Try incognito/private window
4. Check browser console (F12) for errors

### Database Connection Failed
```bash
# Check PostgreSQL is running
ssh deploy@localhost 'docker exec server-db-1 pg_isready -U ${POSTGRES_USER}'

# Test connection
ssh deploy@localhost 'docker exec server-db-1 psql -U ${POSTGRES_USER} -d mydb -c "SELECT 1;"'

# Restart database
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart db'
```

## 📞 Support

For issues or questions:
1. Check logs: `docker logs server-[service]-1`
2. Review SECURITY.md for advanced troubleshooting
3. Verify all credentials in .env file
4. Test with curl before blaming browser

## 🎯 Next Steps

### Tomorrow: Metabase Dashboards
1. Create interactive project dashboard with drill-downs
2. Build monthly cashflow visualization (last 3 months)
3. Add customer detail views
4. Setup sales funnel analytics

### Future Enhancements
- Let's Encrypt SSL (replace self-signed)
- 2FA for nginx (Authelia integration)
- Automated backups (daily PostgreSQL dumps)
- Monitoring dashboard (Grafana + Prometheus)
- Email alerts for overdue tasks/invoices
- WhatsApp integration for customer interactions

---

**Security Reminder**: This server demonstrates DSGVO-compliant, multi-layer security architecture. It serves as a showcase for German SMBs concerned about data privacy and AI security.

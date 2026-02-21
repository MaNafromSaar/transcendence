# 🚀 Metabase Quick Setup Guide

## ✅ What's Done

- ✅ CRM schema applied (8 tables, 5 views)
- ✅ Test data loaded (10 customers, 7 projects, 8 interactions, 5 quotes, 5 invoices, 9 tasks)
- ✅ SSH tunnel active (port 3000)

**Key Metrics from Database:**
- Pipeline Value: **€9,034.60**
- Open Receivables: **€4,707.00**
- MRR: **€327.00/month**
- Customer Lifetime Value: **€2,200.00**

---

## 🎯 Access Metabase NOW

### Open in Browser:
```
http://localhost:3000
```

---

## 📝 First-Time Setup (if not configured)

### Step 1: Welcome Screen
- Language: **Deutsch** (or English)
- Click: **Let's get started**

### Step 2: Create Admin Account
```
Email:    matthias.naumann@keepITlocal.ai
Password: [choose secure password]
Name:     Matthias Naumann
```

### Step 3: Add Database Connection
```
Database Type:   PostgreSQL
Name:            keepITlocal CRM
Host:            db  (or localhost if tunnel)
Port:            5432
Database name:   mydb
Username:        ${POSTGRES_USER}
Password:        <POSTGRES_PASSWORD>
```

Click **Connect database**

### Step 4: Data preferences
- Skip usage data collection (or allow if you want)

**Done!** Metabase is ready.

---

## 🎨 Create Your First Dashboard (Executive)

### Method 1: Quick Start (Use Existing Views)

1. Click **"New"** → **"Dashboard"**
2. Name: **"Executive Dashboard"**
3. Description: **"Geschäftsführungs-Überblick"**
4. Click **"Create"**

### Add First Card: Active Customers

5. Click **"+"** (Add a question)
6. Choose: **"Simple question"**
7. Pick data: **"Kunden"** table
8. Summarize: **Count of rows**
9. Filter: `kunde_status` = `aktiv`
10. Visualize → **Number** (big number display)
11. Save → Name: **"Aktive Kunden"**
12. Add to dashboard

### Add Second Card: Pipeline Value

13. New question → **"SQL query"**
14. Paste:
```sql
SELECT SUM(brutto_betrag) as pipeline_wert 
FROM angebote 
WHERE status IN ('gesendet', 'entwurf') 
  AND gueltig_bis >= CURRENT_DATE;
```
15. Visualize → **Number**
16. Format: Currency (€)
17. Save → Name: **"Pipeline Wert"**
18. Add to dashboard

### Add Third Card: Umsatz Trend

19. New question → **SQL query**
20. Paste:
```sql
SELECT 
    DATE_TRUNC('month', rechnungsdatum) as monat,
    SUM(brutto_betrag) as umsatz
FROM rechnungen
WHERE status IN ('bezahlt', 'teilweise_bezahlt')
    AND rechnungsdatum >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', rechnungsdatum)
ORDER BY monat;
```
21. Visualize → **Line chart**
22. X-axis: `monat`
23. Y-axis: `umsatz` (Currency format)
24. Save → Name: **"Umsatz 12 Monate"**
25. Add to dashboard

### Add Fourth Card: Sales Funnel

26. New question → **SQL query**
27. Paste:
```sql
SELECT * FROM v_sales_funnel;
```
28. Visualize → **Funnel** (or Bar chart)
29. Save → Name: **"Sales Funnel"**
30. Add to dashboard

### Add Fifth Card: Überfällige Tasks

31. New question → **SQL query**
32. Paste:
```sql
SELECT 
    titel,
    kunde,
    faellig_am,
    prioritaet,
    dringlichkeit
FROM v_aufgaben_dashboard
WHERE dringlichkeit = 'Überfällig'
ORDER BY faellig_am;
```
33. Visualize → **Table**
34. Save → Name: **"Überfällige Tasks"**
35. Add to dashboard

---

## 🎯 Method 2: Super Quick (Copy-Paste All Queries)

Click **"New"** → **"SQL Query"** for each:

### 1. KPI: Leads
```sql
SELECT COUNT(*) as leads 
FROM kunden 
WHERE kunde_status IN ('lead', 'interessent');
```
**Display**: Number | Save as: "Leads & Interessenten"

### 2. KPI: Offene Forderungen
```sql
SELECT SUM(offener_betrag) as offen 
FROM rechnungen 
WHERE status IN ('gesendet', 'teilweise_bezahlt', 'ueberfaellig');
```
**Display**: Number (€) | Save as: "Offene Forderungen"

### 3. Chart: Projekt Status
```sql
SELECT 
    status,
    COUNT(*) as anzahl
FROM projekte
WHERE status NOT IN ('abgelehnt')
GROUP BY status
ORDER BY anzahl DESC;
```
**Display**: Donut/Pie Chart | Save as: "Projekt Status"

### 4. Table: Hot Leads
```sql
SELECT 
    firma_name,
    ansprechpartner_name,
    email,
    telefon,
    potential_bewertung,
    prioritaet
FROM v_kunden_overview
WHERE kunde_status IN ('lead', 'interessent')
    AND (prioritaet IN ('hoch', 'kritisch') OR potential_bewertung >= 8)
ORDER BY potential_bewertung DESC, prioritaet;
```
**Display**: Table | Save as: "Heiße Leads"

### 5. Table: Nächste Termine
```sql
SELECT 
    kunde,
    titel,
    typ,
    faellig_am,
    prioritaet
FROM v_aufgaben_dashboard
WHERE faellig_am <= CURRENT_DATE + INTERVAL '7 days'
    AND status NOT IN ('erledigt', 'abgebrochen')
ORDER BY faellig_am, prioritaet;
```
**Display**: Table | Save as: "Nächste Tasks (7 Tage)"

### 6. Chart: Revenue by Month
```sql
SELECT 
    TO_CHAR(DATE_TRUNC('month', rechnungsdatum), 'Mon YYYY') as monat,
    SUM(bereits_bezahlt) as bezahlt,
    SUM(offener_betrag) as offen
FROM rechnungen
WHERE rechnungsdatum >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', rechnungsdatum)
ORDER BY DATE_TRUNC('month', rechnungsdatum);
```
**Display**: Stacked Bar Chart | Save as: "Umsatz 6 Monate"

---

## 🎨 Dashboard Layout Tips

### Arrange Cards:
1. **Top Row**: 4 KPI numbers (Leads, Aktiv, Pipeline, Forderungen)
2. **Second Row**: 2 Charts (Umsatz Trend, Projekt Status)
3. **Third Row**: 1 Funnel (Sales Funnel)
4. **Bottom**: 2 Tables (Hot Leads, Überfällige Tasks)

### Styling:
- Use **full width** for charts
- **1/4 width** for KPI numbers
- **Colors**: Green for positive KPIs, Red for overdue/urgent

---

## 📊 What You'll See (with Test Data)

### KPIs on Dashboard:
- **Aktive Kunden**: 3
- **Leads & Interessenten**: 6
- **Pipeline Wert**: €9,034.60
- **Offene Forderungen**: €4,707.00
- **Überfällige Tasks**: 2 🔴

### Hot Leads Showing:
1. **Steuerberatung Wagner** (Potential: 10, Kritisch) - €4,498 deal
2. **Bäckerei Müller** (Potential: 8, Hoch) - Email-AI lead
3. **Dr. Schmidt** (Potential: 9, Hoch) - Demo done

### Umsatz Trend:
- September: €2,980
- October: €4,807
- November: €228 (+ €4,479 expected Dec)

### Projects:
- 3 Angebot (€13,162)
- 2 In Arbeit (€9,278)
- 1 Abgeschlossen (€2,980)

---

## 🚀 Next Dashboards to Create

After Executive Dashboard works:

1. **Sales Dashboard** (30 min)
   - Lead sources
   - Conversion rates
   - Win/loss analysis

2. **Finance Dashboard** (20 min)
   - Monthly revenue
   - Overdue invoices
   - Cashflow forecast

3. **Project Dashboard** (25 min)
   - Project timeline
   - Team workload
   - Deadline warnings

**All queries are in:** `METABASE_DASHBOARDS.md`

---

## 💡 Tips

### Filters:
- Add date range filter to dashboard
- Add "Zugeordnet an" filter for multi-user view
- Add status filters (kunde_status, projekt_status)

### Auto-Refresh:
- Dashboard Settings → Auto Refresh → **5 minutes**
- Perfect for live monitoring

### Sharing:
- Dashboard Settings → Sharing → Get public link
- Or: Export to PDF for client presentations

---

## 🎯 Your First Tasks in Dashboard

Once you see the data:

1. ✅ Verify: 10 customers showing
2. ✅ Check: Steuerberatung Wagner as top lead
3. ✅ See: Bäckerei Müller from Email-AI
4. ✅ Notice: Kanzlei Hoffmann invoice overdue (€228)
5. ✅ Confirm: Zentrum Naturmedizin big project (€8,950)

---

## 🔧 Troubleshooting

### Can't connect to database?
- Check SSH tunnel is active: `ps aux | grep ssh`
- Use **db** as hostname (Docker internal)
- Or **localhost** with port forward

### No tables showing?
- Refresh database metadata: Settings → Admin → Databases → Sync
- Wait 30 seconds, refresh page

### Queries return no data?
- Check SQL in query console first
- Verify table names (lowercase: `kunden`, not `Kunden`)

---

**Ready?** Open http://localhost:3000 now! 🚀

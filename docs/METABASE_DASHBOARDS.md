# Metabase Dashboard Setup für keepITlocal CRM

## 📊 Dashboard-Struktur

### 1. **Executive Dashboard** (Geschäftsführung)
*Zielgruppe: Matthias (Inhaber), Überblick über gesamtes Business*

**Widgets:**
- **KPIs (Zahlen oben)**
  - Aktive Kunden (kunde_status = 'aktiv')
  - Leads + Interessenten (Conversion-Pipeline)
  - Offene Angebote (status = 'gesendet')
  - Offener Umsatz (Rechnungen unbezahlt)
  - Tasks überfällig (rot markiert)

- **Charts:**
  - Umsatz nach Monat (Balkendiagramm, letzte 12 Monate)
  - Sales Funnel (Trichter: Lead → Interessent → Aktiv)
  - Projekt-Status Verteilung (Donut: angebot, in_arbeit, abgeschlossen)
  - Top 5 Kunden nach Umsatz (Horizontal Bar)
  - Angebote-Annahmerate (Win Rate % pro Monat)

- **Tabellen:**
  - Überfällige Deadlines (Projekte + Aufgaben)
  - Nächste Follow-ups (diese Woche)

**SQL Queries:**

```sql
-- KPI: Aktive Kunden
SELECT COUNT(*) as aktive_kunden 
FROM kunden WHERE kunde_status = 'aktiv';

-- KPI: Pipeline Value (Wert aller offenen Angebote)
SELECT SUM(brutto_betrag) as pipeline_wert 
FROM angebote 
WHERE status = 'gesendet' AND gueltig_bis >= CURRENT_DATE;

-- KPI: Offene Forderungen
SELECT SUM(offener_betrag) as offen 
FROM rechnungen 
WHERE status IN ('gesendet', 'teilweise_bezahlt', 'ueberfaellig');

-- Chart: Umsatz letzte 12 Monate
SELECT 
    DATE_TRUNC('month', rechnungsdatum) as monat,
    SUM(brutto_betrag) as umsatz
FROM rechnungen
WHERE status IN ('bezahlt', 'teilweise_bezahlt')
    AND rechnungsdatum >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', rechnungsdatum)
ORDER BY monat;

-- Chart: Sales Funnel
SELECT * FROM v_sales_funnel;

-- Table: Überfällige Projekte
SELECT 
    projekt_name,
    kunde,
    deadline,
    deadline_status,
    fortschritt_prozent,
    zugeordnet_an
FROM v_projekt_pipeline
WHERE deadline_status = 'Überfällig'
ORDER BY deadline;
```

---

### 2. **Sales Dashboard** (Vertrieb)
*Zielgruppe: Verkaufsaktivitäten, Lead-Management*

**Widgets:**
- **KPIs:**
  - Neue Leads diese Woche
  - Conversion Rate (Lead → Aktiv)
  - Durchschnittliche Deal-Größe
  - Angebots-Quote (Angebote gesendet / gewonnen)

- **Charts:**
  - Lead-Quellen (Pie Chart: Website, Empfehlung, Social Media)
  - Angebotsstatus Übersicht (Stacked Bar)
  - Gewinn/Verlust Analyse (Win/Loss Ratio)
  - Branche-Verteilung der Kunden

- **Tabellen:**
  - Offene Angebote (sortiert nach gültig_bis)
  - Heiße Leads (priorität = 'hoch', potential > 7)
  - Interaktionen letzte 7 Tage

**SQL Queries:**

```sql
-- Neue Leads diese Woche
SELECT COUNT(*) as neue_leads
FROM kunden
WHERE kunde_status = 'lead'
    AND erstellt_am >= CURRENT_DATE - INTERVAL '7 days';

-- Conversion Rate
SELECT 
    kunde_status,
    COUNT(*) as anzahl,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as prozent
FROM kunden
WHERE kunde_status IN ('lead', 'interessent', 'aktiv')
GROUP BY kunde_status;

-- Lead-Quellen
SELECT 
    COALESCE(quelle, 'Unbekannt') as quelle,
    COUNT(*) as anzahl
FROM kunden
WHERE kunde_status IN ('lead', 'interessent')
GROUP BY quelle
ORDER BY anzahl DESC;

-- Heiße Leads
SELECT 
    firma_name,
    ansprechpartner_name,
    email,
    telefon,
    potential_bewertung,
    quelle,
    letzte_interaktion,
    naechstes_follow_up
FROM v_kunden_overview
WHERE kunde_status IN ('lead', 'interessent')
    AND (prioritaet = 'hoch' OR potential_bewertung >= 7)
ORDER BY potential_bewertung DESC, letzte_interaktion DESC;
```

---

### 3. **Project Management Dashboard**
*Zielgruppe: Projektverantwortliche, tägliche Arbeit*

**Widgets:**
- **KPIs:**
  - Projekte in Arbeit
  - Projekte im Plan (deadline > heute + 7 Tage)
  - Projekte gefährdet (deadline < 7 Tage)
  - Durchschnittliche Projektdauer

- **Charts:**
  - Projekt-Timeline (Gantt-ähnlich)
  - Fortschritt nach Projekt (Progress Bar)
  - Projekt-Typ Verteilung
  - Team-Auslastung (zugeordnet_an)

- **Tabellen:**
  - Meine Projekte (zugeordnet_an = current_user)
  - Blockierte Projekte (blockaden IS NOT NULL)
  - Projekte ohne Deadline (deadline IS NULL)

**SQL Queries:**

```sql
-- Projekte nach Status
SELECT 
    status,
    COUNT(*) as anzahl,
    SUM(angebot_summe) as wert
FROM projekte
GROUP BY status
ORDER BY 
    CASE status
        WHEN 'in_arbeit' THEN 1
        WHEN 'beauftragt' THEN 2
        WHEN 'review' THEN 3
        WHEN 'angebot' THEN 4
        ELSE 5
    END;

-- Projekt-Fortschritt Detail
SELECT 
    p.projekt_name,
    k.firma_name as kunde,
    p.projekt_typ,
    p.fortschritt_prozent,
    p.deadline,
    p.zugeordnet_an,
    p.naechste_schritte,
    CASE 
        WHEN p.deadline < CURRENT_DATE THEN '🔴 Überfällig'
        WHEN p.deadline <= CURRENT_DATE + INTERVAL '7 days' THEN '🟡 Diese Woche'
        ELSE '🟢 Im Plan'
    END as status_symbol
FROM projekte p
JOIN kunden k ON p.kunde_id = k.id
WHERE p.status IN ('in_arbeit', 'beauftragt', 'review')
ORDER BY p.deadline NULLS LAST;

-- Team-Auslastung
SELECT 
    zugeordnet_an as mitarbeiter,
    COUNT(*) as anzahl_projekte,
    COUNT(CASE WHEN status = 'in_arbeit' THEN 1 END) as aktiv,
    SUM(CASE WHEN status = 'in_arbeit' THEN 100 - fortschritt_prozent ELSE 0 END) as restarbeit_prozent
FROM projekte
WHERE status IN ('in_arbeit', 'beauftragt', 'review')
    AND zugeordnet_an IS NOT NULL
GROUP BY zugeordnet_an
ORDER BY anzahl_projekte DESC;
```

---

### 4. **Finance Dashboard** (Buchhaltung)
*Zielgruppe: Finanzen, Rechnungen, Zahlungseingänge*

**Widgets:**
- **KPIs:**
  - Umsatz dieser Monat
  - Offene Forderungen gesamt
  - Überfällige Rechnungen (Anzahl + Betrag)
  - Durchschnittliche Zahlungsdauer (Tage)

- **Charts:**
  - Umsatz vs. Budget (Line Chart, Ziel einzeichnen)
  - Rechnungsstatus Verteilung (Pie)
  - Cashflow Prognose (nächste 3 Monate)
  - Umsatz nach Produkt-Typ

- **Tabellen:**
  - Überfällige Rechnungen (rot markiert)
  - Rechnungen diese Woche fällig
  - Top 5 zahlende Kunden

**SQL Queries:**

```sql
-- Umsatz dieser Monat
SELECT 
    SUM(bereits_bezahlt) as umsatz_monat
FROM rechnungen
WHERE DATE_TRUNC('month', rechnungsdatum) = DATE_TRUNC('month', CURRENT_DATE)
    AND status != 'storniert';

-- Überfällige Rechnungen
SELECT 
    r.rechnungs_nummer,
    k.firma_name as kunde,
    r.brutto_betrag,
    r.offener_betrag,
    r.faellig_am,
    CURRENT_DATE - r.faellig_am as tage_ueberfaellig
FROM rechnungen r
JOIN kunden k ON r.kunde_id = k.id
WHERE r.status IN ('gesendet', 'ueberfaellig', 'teilweise_bezahlt')
    AND r.faellig_am < CURRENT_DATE
    AND r.offener_betrag > 0
ORDER BY r.faellig_am;

-- Umsatz nach Produkt-Typ (über Projekte)
SELECT 
    projekt_typ,
    COUNT(*) as anzahl_projekte,
    SUM(tatsaechliche_kosten) as umsatz_gesamt
FROM projekte
WHERE status = 'abgeschlossen'
    AND tatsaechliche_kosten IS NOT NULL
GROUP BY projekt_typ
ORDER BY umsatz_gesamt DESC;

-- Cashflow Prognose (erwartete Zahlungen)
SELECT 
    DATE_TRUNC('month', faellig_am) as monat,
    SUM(offener_betrag) as erwartete_zahlungen,
    COUNT(*) as anzahl_rechnungen
FROM rechnungen
WHERE status IN ('gesendet', 'teilweise_bezahlt')
    AND faellig_am >= CURRENT_DATE
    AND faellig_am <= CURRENT_DATE + INTERVAL '3 months'
GROUP BY DATE_TRUNC('month', faellig_am)
ORDER BY monat;
```

---

### 5. **Task Management Dashboard**
*Zielgruppe: Alle Mitarbeiter, tägliche Todos*

**Widgets:**
- **KPIs:**
  - Offene Aufgaben gesamt
  - Meine Aufgaben heute
  - Überfällige Tasks
  - Abschlussrate diese Woche

- **Charts:**
  - Aufgaben nach Typ (Bar Chart)
  - Aufgaben nach Priorität (Pie)
  - Team-Workload (zugeordnet_an)

- **Tabellen:**
  - Meine Aufgaben (zugeordnet_an = current_user)
  - Heute fällig
  - Diese Woche fällig
  - Überfällig (rot)

**SQL Queries:**

```sql
-- Meine Aufgaben
SELECT 
    titel,
    typ,
    prioritaet,
    faellig_am,
    kunde,
    projekt_name,
    dringlichkeit
FROM v_aufgaben_dashboard
WHERE zugeordnet_an = '{{current_user}}'  -- Metabase Variable
ORDER BY 
    CASE prioritaet
        WHEN 'kritisch' THEN 1
        WHEN 'hoch' THEN 2
        WHEN 'mittel' THEN 3
        ELSE 4
    END,
    faellig_am NULLS LAST;

-- Aufgaben nach Dringlichkeit
SELECT 
    dringlichkeit,
    COUNT(*) as anzahl,
    STRING_AGG(titel, ', ' LIMIT 3) as beispiele
FROM v_aufgaben_dashboard
GROUP BY dringlichkeit
ORDER BY 
    CASE dringlichkeit
        WHEN 'Überfällig' THEN 1
        WHEN 'Heute' THEN 2
        WHEN 'Diese Woche' THEN 3
        ELSE 4
    END;

-- Team Workload
SELECT 
    zugeordnet_an,
    COUNT(*) as offene_aufgaben,
    COUNT(CASE WHEN dringlichkeit IN ('Überfällig', 'Heute') THEN 1 END) as dringend,
    AVG(geschaetzter_aufwand_stunden) as avg_aufwand_h
FROM v_aufgaben_dashboard
GROUP BY zugeordnet_an
ORDER BY dringend DESC, offene_aufgaben DESC;
```

---

### 6. **Customer Insights Dashboard**
*Zielgruppe: Kundenverständnis, Strategie*

**Widgets:**
- **KPIs:**
  - Customer Lifetime Value (CLV)
  - Durchschnittlicher Projektwert
  - Repeat-Customer Rate
  - Churn-Risiko (inaktiv seit > 90 Tage)

- **Charts:**
  - Branchenverteilung (Pie)
  - Firmengröße (Mitarbeiter-Bereiche)
  - Bundesland-Verteilung (Map wenn möglich)
  - Kundenakquise über Zeit

- **Tabellen:**
  - Top 10 Kunden (nach Umsatz)
  - Gefährdete Kunden (lange keine Interaktion)
  - Wachstumspotential (potential_bewertung hoch)

**SQL Queries:**

```sql
-- Customer Lifetime Value
SELECT 
    k.firma_name,
    COUNT(DISTINCT p.id) as anzahl_projekte,
    SUM(p.tatsaechliche_kosten) as gesamtumsatz,
    MAX(i.interaktion_datum) as letzte_interaktion,
    CURRENT_DATE - MAX(i.interaktion_datum)::date as tage_seit_letzter_interaktion
FROM kunden k
LEFT JOIN projekte p ON k.id = p.kunde_id AND p.status = 'abgeschlossen'
LEFT JOIN interaktionen i ON k.id = i.kunde_id
WHERE k.kunde_status = 'aktiv'
GROUP BY k.id, k.firma_name
ORDER BY gesamtumsatz DESC NULLS LAST;

-- Branchenverteilung
SELECT 
    COALESCE(branche, 'Keine Angabe') as branche,
    COUNT(*) as anzahl_kunden,
    COUNT(CASE WHEN kunde_status = 'aktiv' THEN 1 END) as aktiv
FROM kunden
GROUP BY branche
ORDER BY anzahl_kunden DESC
LIMIT 10;

-- Churn-Risiko
SELECT 
    k.firma_name,
    k.ansprechpartner_name,
    k.email,
    k.telefon,
    k.zugeordnet_an,
    MAX(i.interaktion_datum) as letzte_interaktion,
    CURRENT_DATE - MAX(i.interaktion_datum)::date as tage_inaktiv
FROM kunden k
LEFT JOIN interaktionen i ON k.id = i.kunde_id
WHERE k.kunde_status = 'aktiv'
GROUP BY k.id, k.firma_name, k.ansprechpartner_name, k.email, k.telefon, k.zugeordnet_an
HAVING MAX(i.interaktion_datum) < CURRENT_DATE - INTERVAL '90 days'
    OR MAX(i.interaktion_datum) IS NULL
ORDER BY tage_inaktiv DESC NULLS FIRST;
```

---

## 🎨 Metabase Setup Schritte

### 1. Datenbank verbinden
```
Admin → Add Database
- Type: PostgreSQL
- Host: db (Docker internal)
- Port: 5432
- Database: mydb
- User: ${POSTGRES_USER}
- Password: <POSTGRES_PASSWORD>
```

### 2. Dashboard erstellen
```
+ New → Dashboard
Name: "Executive Dashboard"
Description: "Geschäftsführungs-Überblick"
```

### 3. Fragen hinzufügen
```
+ New → SQL Query
- Select Database: mydb
- Paste SQL query
- Visualize → Choose chart type
- Add to Dashboard
```

### 4. Filter einrichten
```
Dashboard Settings → Add Filter
- Date Range: erstellt_am, interaktion_datum
- User: zugeordnet_an (für "Meine Ansichten")
- Status: kunde_status, projekt_status
```

### 5. Auto-Refresh
```
Dashboard Settings → Auto Refresh
- Set to 5 minutes for real-time feeling
```

---

## 🔗 Integration mit Email-Processor

**Automatische Lead-Erfassung aus Emails:**

```sql
-- n8n Workflow fügt Interaktion hinzu, wenn neue Email kommt
INSERT INTO interaktionen (
    kunde_id, 
    typ, 
    richtung, 
    betreff, 
    zusammenfassung, 
    email_id,
    durchgefuehrt_von,
    ergebnis
)
SELECT 
    (SELECT id FROM kunden WHERE email = ec.sender_email LIMIT 1),
    'email',
    'eingehend',
    ec.topic,
    ec.summary,
    ec.id,
    'Email-AI',
    CASE 
        WHEN ec.email_type = 'request' THEN 'Anfrage eingegangen'
        WHEN ec.email_type = 'order' THEN 'Bestellung eingegangen'
        ELSE 'Email verarbeitet'
    END
FROM email_classifications ec
WHERE ec.id = {{new_email_id}};

-- Falls Kunde noch nicht existiert, erstelle Lead
INSERT INTO kunden (
    firma_name,
    ansprechpartner_name,
    email,
    telefon,
    kunde_status,
    quelle,
    prioritaet,
    erstellt_von
)
SELECT 
    COALESCE(sender_name, 'Unbekannt'),
    sender_name,
    sender_email,
    phone_number,
    'lead',
    'Email-Anfrage',
    CASE 
        WHEN action_required = 'yes' AND priority = 'high' THEN 'hoch'
        WHEN priority = 'high' THEN 'mittel'
        ELSE 'niedrig'
    END,
    'Email-AI'
FROM email_classifications
WHERE id = {{new_email_id}}
    AND NOT EXISTS (SELECT 1 FROM kunden WHERE email = sender_email)
ON CONFLICT (email) DO NOTHING;
```

---

## 📱 Zugriffsberechtigungen (später mit mehr Mitarbeitern)

```
Matthias (Geschäftsführer): Alle Dashboards
Mitarbeiter A: Sales + Tasks
Mitarbeiter B: Projects + Tasks
Buchhaltung: Finance + Customers (read-only)
```

Metabase Groups:
- Admin (alle Rechte)
- Sales (Kunden, Angebote, Leads)
- Operations (Projekte, Aufgaben)
- Finance (Rechnungen, Umsatz)

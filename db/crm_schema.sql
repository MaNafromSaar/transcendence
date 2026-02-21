-- ============================================================================
-- keepITlocal CRM Schema - German Business Automation Agency
-- ============================================================================
-- Purpose: Lightweight CRM for 1-5 person automation/AI consultancy
-- Products: AI Phone Agents, Transcription, Email Ingestion
-- Target: German small businesses (DSGVO-compliant)
-- ============================================================================

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- KUNDEN (Customers/Contacts)
-- ============================================================================
CREATE TABLE kunden (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    
    -- Firmendaten
    firma_name VARCHAR(255) NOT NULL,
    firma_typ VARCHAR(50) CHECK (firma_typ IN ('GmbH', 'UG', 'AG', 'Einzelunternehmen', 'Freiberufler', 'Verein', 'Sonstiges')),
    branche VARCHAR(100),
    mitarbeiter_anzahl INTEGER,
    website VARCHAR(255),
    
    -- Hauptansprechpartner
    ansprechpartner_name VARCHAR(255),
    ansprechpartner_position VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    telefon VARCHAR(50),
    mobil VARCHAR(50),
    
    -- Adresse
    strasse VARCHAR(255),
    plz VARCHAR(10),
    ort VARCHAR(100),
    bundesland VARCHAR(50),
    land VARCHAR(50) DEFAULT 'Deutschland',
    
    -- Status & Klassifizierung
    kunde_status VARCHAR(50) DEFAULT 'lead' CHECK (kunde_status IN ('lead', 'interessent', 'aktiv', 'inaktiv', 'verloren')),
    prioritaet VARCHAR(20) DEFAULT 'mittel' CHECK (prioritaet IN ('niedrig', 'mittel', 'hoch', 'kritisch')),
    quelle VARCHAR(100), -- wie haben sie uns gefunden?
    
    -- Umsatz & Potential
    jahresumsatz_geschaetzt DECIMAL(12,2),
    potential_bewertung INTEGER CHECK (potential_bewertung BETWEEN 1 AND 10),
    
    -- Notizen & Tags
    notizen TEXT,
    tags VARCHAR(255), -- comma-separated: "dsgvo-sensibel,handwerk,5-10-mitarbeiter"
    
    -- Metadata
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    erstellt_von VARCHAR(100),
    zugeordnet_an VARCHAR(100) -- Verantwortlicher Mitarbeiter
);

-- Index für häufige Abfragen
CREATE INDEX idx_kunden_status ON kunden(kunde_status);
CREATE INDEX idx_kunden_email ON kunden(email);
CREATE INDEX idx_kunden_firma ON kunden(firma_name);
CREATE INDEX idx_kunden_zugeordnet ON kunden(zugeordnet_an);

-- Trigger für aktualisiert_am
CREATE OR REPLACE FUNCTION update_aktualisiert_am()
RETURNS TRIGGER AS $$
BEGIN
    NEW.aktualisiert_am = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_kunden_aktualisiert
BEFORE UPDATE ON kunden
FOR EACH ROW EXECUTE FUNCTION update_aktualisiert_am();

-- ============================================================================
-- PRODUKTE (Services/Products Catalog)
-- ============================================================================
CREATE TABLE produkte (
    id SERIAL PRIMARY KEY,
    produkt_name VARCHAR(255) NOT NULL,
    produkt_typ VARCHAR(100) CHECK (produkt_typ IN ('AI-Telefonagent', 'Transkription', 'Email-Ingestion', 'Beratung', 'Custom-Entwicklung', 'Schulung')),
    beschreibung TEXT,
    preis_basis DECIMAL(10,2), -- Basispreis
    preis_einheit VARCHAR(50) DEFAULT 'Monat' CHECK (preis_einheit IN ('Einmalig', 'Monat', 'Jahr', 'Stunde', 'Pro Anruf', 'Pro Email')),
    setup_gebuehr DECIMAL(10,2) DEFAULT 0.00,
    aktiv BOOLEAN DEFAULT true,
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Standard-Produkte einfügen
INSERT INTO produkte (produkt_name, produkt_typ, beschreibung, preis_basis, preis_einheit, setup_gebuehr) VALUES
('AI-Telefonagent Basis', 'AI-Telefonagent', 'Automatische Anrufbearbeitung via Make.com + ElevenLabs, bis 100 Anrufe/Monat', 99.00, 'Monat', 299.00),
('AI-Telefonagent Professional', 'AI-Telefonagent', 'Erweiterte Funktionen, bis 500 Anrufe/Monat, Custom Voice Training', 249.00, 'Monat', 499.00),
('Lokale Transkription', 'Transkription', 'Whisper-basierte lokale Transkription, DSGVO-konform, unbegrenzte Stunden', 149.00, 'Monat', 199.00),
('Email-KI-Assistent', 'Email-Ingestion', 'Automatische Email-Klassifizierung, Kontaktextraktion, CRM-Integration', 79.00, 'Monat', 149.00),
('AI-Beratung', 'Beratung', 'Strategieberatung zu KI-Implementierung, DSGVO-Compliance', 120.00, 'Stunde', 0.00),
('Custom AI-Entwicklung', 'Custom-Entwicklung', 'Individuelle AI-Lösungen nach Kundenwunsch', 95.00, 'Stunde', 0.00);

-- ============================================================================
-- PROJEKTE (Customer Projects)
-- ============================================================================
CREATE TABLE projekte (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    kunde_id INTEGER NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
    
    -- Projektdaten
    projekt_name VARCHAR(255) NOT NULL,
    projekt_typ VARCHAR(100) CHECK (projekt_typ IN ('AI-Telefonagent', 'Transkription', 'Email-Ingestion', 'Beratung', 'Custom-Entwicklung', 'Schulung')),
    beschreibung TEXT,
    
    -- Status & Timeline
    status VARCHAR(50) DEFAULT 'angebot' CHECK (status IN ('angebot', 'verhandlung', 'beauftragt', 'in_arbeit', 'review', 'abgeschlossen', 'abgelehnt', 'pausiert')),
    prioritaet VARCHAR(20) DEFAULT 'mittel' CHECK (prioritaet IN ('niedrig', 'mittel', 'hoch', 'kritisch')),
    start_datum DATE,
    end_datum DATE,
    deadline DATE,
    
    -- Finanzielle Daten
    angebot_summe DECIMAL(12,2),
    tatsaechliche_kosten DECIMAL(12,2),
    gewinn_marge DECIMAL(5,2), -- Prozent
    zahlungs_status VARCHAR(50) DEFAULT 'ausstehend' CHECK (zahlungs_status IN ('ausstehend', 'teilweise', 'vollstaendig', 'ueberfaellig')),
    
    -- Team & Verantwortlichkeiten
    zugeordnet_an VARCHAR(100), -- Hauptverantwortlicher
    mitarbeiter TEXT, -- comma-separated list
    
    -- Fortschritt
    fortschritt_prozent INTEGER DEFAULT 0 CHECK (fortschritt_prozent BETWEEN 0 AND 100),
    naechste_schritte TEXT,
    blockaden TEXT,
    
    -- Notizen
    notizen TEXT,
    technische_details TEXT,
    
    -- Metadata
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    abgeschlossen_am TIMESTAMP
);

CREATE INDEX idx_projekte_kunde ON projekte(kunde_id);
CREATE INDEX idx_projekte_status ON projekte(status);
CREATE INDEX idx_projekte_zugeordnet ON projekte(zugeordnet_an);
CREATE INDEX idx_projekte_deadline ON projekte(deadline);

CREATE TRIGGER trigger_projekte_aktualisiert
BEFORE UPDATE ON projekte
FOR EACH ROW EXECUTE FUNCTION update_aktualisiert_am();

-- ============================================================================
-- INTERAKTIONEN (Customer Interactions)
-- ============================================================================
CREATE TABLE interaktionen (
    id SERIAL PRIMARY KEY,
    kunde_id INTEGER NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
    projekt_id INTEGER REFERENCES projekte(id) ON DELETE SET NULL,
    
    -- Art der Interaktion
    typ VARCHAR(50) NOT NULL CHECK (typ IN ('email', 'telefon', 'meeting', 'notiz', 'demo', 'support', 'angebot_gesendet', 'vertrag_unterzeichnet')),
    richtung VARCHAR(20) CHECK (richtung IN ('eingehend', 'ausgehend', 'intern')),
    
    -- Inhalt
    betreff VARCHAR(500),
    zusammenfassung TEXT NOT NULL,
    details TEXT,
    email_id INTEGER REFERENCES email_classifications(id), -- Link zur Email-Tabelle
    
    -- Ergebnis & Follow-up
    ergebnis VARCHAR(100), -- z.B. "Interesse bestätigt", "Termin vereinbart"
    naechste_aktion VARCHAR(255),
    naechstes_follow_up DATE,
    
    -- Metadata
    durchgefuehrt_von VARCHAR(100),
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    interaktion_datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interaktionen_kunde ON interaktionen(kunde_id);
CREATE INDEX idx_interaktionen_projekt ON interaktionen(projekt_id);
CREATE INDEX idx_interaktionen_typ ON interaktionen(typ);
CREATE INDEX idx_interaktionen_datum ON interaktionen(interaktion_datum);
CREATE INDEX idx_interaktionen_follow_up ON interaktionen(naechstes_follow_up);

-- ============================================================================
-- ANGEBOTE (Quotes/Proposals)
-- ============================================================================
CREATE TABLE angebote (
    id SERIAL PRIMARY KEY,
    angebots_nummer VARCHAR(50) UNIQUE NOT NULL, -- z.B. "AIH-2025-001"
    kunde_id INTEGER NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
    projekt_id INTEGER REFERENCES projekte(id) ON DELETE SET NULL,
    
    -- Angebotsdaten
    titel VARCHAR(255) NOT NULL,
    beschreibung TEXT,
    status VARCHAR(50) DEFAULT 'entwurf' CHECK (status IN ('entwurf', 'gesendet', 'angenommen', 'abgelehnt', 'abgelaufen', 'ueberarbeitung')),
    
    -- Finanzielle Details
    gesamt_betrag DECIMAL(12,2) NOT NULL,
    rabatt_prozent DECIMAL(5,2) DEFAULT 0.00,
    rabatt_betrag DECIMAL(12,2) DEFAULT 0.00,
    netto_betrag DECIMAL(12,2),
    mwst_satz DECIMAL(5,2) DEFAULT 19.00, -- Deutschland Standard
    mwst_betrag DECIMAL(12,2),
    brutto_betrag DECIMAL(12,2) NOT NULL,
    
    -- Timeline
    gueltig_bis DATE,
    gesendet_am DATE,
    angenommen_am DATE,
    abgelehnt_am DATE,
    
    -- Zahlungsbedingungen
    zahlungsbedingungen TEXT DEFAULT '14 Tage netto',
    lieferzeit VARCHAR(100),
    
    -- Notizen
    interne_notizen TEXT,
    kundennotizen TEXT,
    
    -- Metadata
    erstellt_von VARCHAR(100),
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_angebote_nummer ON angebote(angebots_nummer);
CREATE INDEX idx_angebote_kunde ON angebote(kunde_id);
CREATE INDEX idx_angebote_status ON angebote(status);
CREATE INDEX idx_angebote_gueltig ON angebote(gueltig_bis);

CREATE TRIGGER trigger_angebote_aktualisiert
BEFORE UPDATE ON angebote
FOR EACH ROW EXECUTE FUNCTION update_aktualisiert_am();

-- ============================================================================
-- ANGEBOTE_POSITIONEN (Quote Line Items)
-- ============================================================================
CREATE TABLE angebote_positionen (
    id SERIAL PRIMARY KEY,
    angebot_id INTEGER NOT NULL REFERENCES angebote(id) ON DELETE CASCADE,
    produkt_id INTEGER REFERENCES produkte(id) ON DELETE SET NULL,
    
    position_nr INTEGER NOT NULL,
    beschreibung TEXT NOT NULL,
    menge DECIMAL(10,2) DEFAULT 1.00,
    einheit VARCHAR(50) DEFAULT 'Stück',
    einzelpreis DECIMAL(12,2) NOT NULL,
    gesamt_preis DECIMAL(12,2) NOT NULL,
    
    -- Optionale Produktdetails
    produkt_typ VARCHAR(100),
    laufzeit_monate INTEGER, -- für Abonnements
    
    UNIQUE(angebot_id, position_nr)
);

CREATE INDEX idx_angebote_positionen_angebot ON angebote_positionen(angebot_id);

-- ============================================================================
-- RECHNUNGEN (Invoices)
-- ============================================================================
CREATE TABLE rechnungen (
    id SERIAL PRIMARY KEY,
    rechnungs_nummer VARCHAR(50) UNIQUE NOT NULL, -- z.B. "RE-2025-001"
    kunde_id INTEGER NOT NULL REFERENCES kunden(id) ON DELETE RESTRICT,
    projekt_id INTEGER REFERENCES projekte(id) ON DELETE SET NULL,
    angebot_id INTEGER REFERENCES angebote(id) ON DELETE SET NULL,
    
    -- Rechnungsdaten
    titel VARCHAR(255) NOT NULL,
    beschreibung TEXT,
    status VARCHAR(50) DEFAULT 'entwurf' CHECK (status IN ('entwurf', 'gesendet', 'bezahlt', 'teilweise_bezahlt', 'ueberfaellig', 'storniert')),
    
    -- Finanzielle Details
    netto_betrag DECIMAL(12,2) NOT NULL,
    mwst_satz DECIMAL(5,2) DEFAULT 19.00,
    mwst_betrag DECIMAL(12,2) NOT NULL,
    brutto_betrag DECIMAL(12,2) NOT NULL,
    bereits_bezahlt DECIMAL(12,2) DEFAULT 0.00,
    offener_betrag DECIMAL(12,2),
    
    -- Daten
    rechnungsdatum DATE NOT NULL DEFAULT CURRENT_DATE,
    leistungsdatum DATE,
    faellig_am DATE NOT NULL,
    bezahlt_am DATE,
    mahnung_am DATE,
    
    -- Zahlungsdetails
    zahlungsart VARCHAR(50), -- Überweisung, PayPal, etc.
    zahlungsreferenz VARCHAR(100),
    
    -- Notizen
    notizen TEXT,
    
    -- Metadata
    erstellt_von VARCHAR(100),
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pdf_pfad VARCHAR(500) -- Pfad zur generierten PDF
);

CREATE INDEX idx_rechnungen_nummer ON rechnungen(rechnungs_nummer);
CREATE INDEX idx_rechnungen_kunde ON rechnungen(kunde_id);
CREATE INDEX idx_rechnungen_status ON rechnungen(status);
CREATE INDEX idx_rechnungen_faellig ON rechnungen(faellig_am);

CREATE TRIGGER trigger_rechnungen_aktualisiert
BEFORE UPDATE ON rechnungen
FOR EACH ROW EXECUTE FUNCTION update_aktualisiert_am();

-- ============================================================================
-- AUFGABEN (Tasks/Todos)
-- ============================================================================
CREATE TABLE aufgaben (
    id SERIAL PRIMARY KEY,
    kunde_id INTEGER REFERENCES kunden(id) ON DELETE CASCADE,
    projekt_id INTEGER REFERENCES projekte(id) ON DELETE CASCADE,
    
    -- Aufgabendaten
    titel VARCHAR(255) NOT NULL,
    beschreibung TEXT,
    typ VARCHAR(50) CHECK (typ IN ('follow_up', 'angebot_erstellen', 'demo_vorbereiten', 'entwicklung', 'support', 'dokumentation', 'rechnung_senden', 'sonstiges')),
    
    -- Status & Priorität
    status VARCHAR(50) DEFAULT 'offen' CHECK (status IN ('offen', 'in_arbeit', 'wartend', 'erledigt', 'abgebrochen')),
    prioritaet VARCHAR(20) DEFAULT 'mittel' CHECK (prioritaet IN ('niedrig', 'mittel', 'hoch', 'kritisch')),
    
    -- Zeitplanung
    faellig_am DATE,
    erledigt_am TIMESTAMP,
    erinnerung_am TIMESTAMP,
    geschaetzter_aufwand_stunden DECIMAL(5,2),
    tatsaechlicher_aufwand_stunden DECIMAL(5,2),
    
    -- Zuordnung
    zugeordnet_an VARCHAR(100) NOT NULL,
    erstellt_von VARCHAR(100),
    
    -- Notizen
    notizen TEXT,
    
    -- Metadata
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_aufgaben_status ON aufgaben(status);
CREATE INDEX idx_aufgaben_zugeordnet ON aufgaben(zugeordnet_an);
CREATE INDEX idx_aufgaben_faellig ON aufgaben(faellig_am);
CREATE INDEX idx_aufgaben_kunde ON aufgaben(kunde_id);
CREATE INDEX idx_aufgaben_projekt ON aufgaben(projekt_id);

CREATE TRIGGER trigger_aufgaben_aktualisiert
BEFORE UPDATE ON aufgaben
FOR EACH ROW EXECUTE FUNCTION update_aktualisiert_am();

-- ============================================================================
-- VIEWS - Übersichtsansichten für Metabase Dashboards
-- ============================================================================

-- View: Aktive Kunden mit letzter Interaktion
CREATE OR REPLACE VIEW v_kunden_overview AS
SELECT 
    k.id,
    k.firma_name,
    k.ansprechpartner_name,
    k.email,
    k.telefon,
    k.kunde_status,
    k.prioritaet,
    k.quelle,
    k.potential_bewertung,
    k.zugeordnet_an,
    COUNT(DISTINCT p.id) as anzahl_projekte,
    COUNT(DISTINCT CASE WHEN p.status IN ('in_arbeit', 'beauftragt') THEN p.id END) as aktive_projekte,
    SUM(CASE WHEN p.status = 'abgeschlossen' THEN p.tatsaechliche_kosten ELSE 0 END) as umsatz_gesamt,
    MAX(i.interaktion_datum) as letzte_interaktion,
    MIN(CASE WHEN i.naechstes_follow_up >= CURRENT_DATE THEN i.naechstes_follow_up END) as naechstes_follow_up,
    k.erstellt_am,
    k.aktualisiert_am
FROM kunden k
LEFT JOIN projekte p ON k.id = p.kunde_id
LEFT JOIN interaktionen i ON k.id = i.kunde_id
GROUP BY k.id;

-- View: Projekt-Pipeline
CREATE OR REPLACE VIEW v_projekt_pipeline AS
SELECT 
    p.id,
    p.projekt_name,
    k.firma_name as kunde,
    k.ansprechpartner_name,
    p.projekt_typ,
    p.status,
    p.prioritaet,
    p.angebot_summe,
    p.tatsaechliche_kosten,
    p.fortschritt_prozent,
    p.start_datum,
    p.deadline,
    p.zugeordnet_an,
    CASE 
        WHEN p.deadline < CURRENT_DATE AND p.status NOT IN ('abgeschlossen', 'abgelehnt') THEN 'Überfällig'
        WHEN p.deadline <= CURRENT_DATE + INTERVAL '7 days' AND p.status NOT IN ('abgeschlossen', 'abgelehnt') THEN 'Diese Woche'
        ELSE 'Normal'
    END as deadline_status,
    p.erstellt_am,
    p.aktualisiert_am
FROM projekte p
JOIN kunden k ON p.kunde_id = k.id
WHERE p.status NOT IN ('abgeschlossen', 'abgelehnt');

-- View: Umsatz-Übersicht
CREATE OR REPLACE VIEW v_umsatz_overview AS
SELECT 
    DATE_TRUNC('month', r.rechnungsdatum) as monat,
    COUNT(*) as anzahl_rechnungen,
    SUM(r.brutto_betrag) as umsatz_brutto,
    SUM(r.bereits_bezahlt) as bereits_bezahlt,
    SUM(r.offener_betrag) as offen,
    COUNT(CASE WHEN r.status = 'ueberfaellig' THEN 1 END) as anzahl_ueberfaellig,
    SUM(CASE WHEN r.status = 'ueberfaellig' THEN r.offener_betrag ELSE 0 END) as betrag_ueberfaellig
FROM rechnungen r
WHERE r.status != 'storniert'
GROUP BY DATE_TRUNC('month', r.rechnungsdatum)
ORDER BY monat DESC;

-- View: Aufgaben-Dashboard
CREATE OR REPLACE VIEW v_aufgaben_dashboard AS
SELECT 
    a.id,
    a.titel,
    a.typ,
    a.status,
    a.prioritaet,
    a.faellig_am,
    a.zugeordnet_an,
    k.firma_name as kunde,
    p.projekt_name,
    CASE 
        WHEN a.faellig_am < CURRENT_DATE AND a.status NOT IN ('erledigt', 'abgebrochen') THEN 'Überfällig'
        WHEN a.faellig_am = CURRENT_DATE AND a.status NOT IN ('erledigt', 'abgebrochen') THEN 'Heute'
        WHEN a.faellig_am <= CURRENT_DATE + INTERVAL '7 days' AND a.status NOT IN ('erledigt', 'abgebrochen') THEN 'Diese Woche'
        ELSE 'Später'
    END as dringlichkeit,
    a.erstellt_am,
    a.aktualisiert_am
FROM aufgaben a
LEFT JOIN kunden k ON a.kunde_id = k.id
LEFT JOIN projekte p ON a.projekt_id = p.id
WHERE a.status NOT IN ('erledigt', 'abgebrochen');

-- View: Sales Funnel
CREATE OR REPLACE VIEW v_sales_funnel AS
SELECT 
    k.kunde_status,
    COUNT(*) as anzahl,
    SUM(COALESCE(k.potential_bewertung, 0)) as gesamt_potential,
    COUNT(CASE WHEN k.prioritaet = 'hoch' THEN 1 END) as anzahl_hoch_prio,
    STRING_AGG(k.firma_name, ', ' ORDER BY k.potential_bewertung DESC) as firmen
FROM kunden k
WHERE k.kunde_status IN ('lead', 'interessent', 'aktiv')
GROUP BY k.kunde_status
ORDER BY 
    CASE k.kunde_status
        WHEN 'lead' THEN 1
        WHEN 'interessent' THEN 2
        WHEN 'aktiv' THEN 3
    END;

-- ============================================================================
-- Kommentare für Metabase
-- ============================================================================
COMMENT ON TABLE kunden IS 'Kundenstammdaten - Firmen und Ansprechpartner';
COMMENT ON TABLE projekte IS 'Kundenprojekte - von Angebot bis Abschluss';
COMMENT ON TABLE interaktionen IS 'Alle Kontaktpunkte mit Kunden (Emails, Anrufe, Meetings)';
COMMENT ON TABLE angebote IS 'Verkaufsangebote und Proposals';
COMMENT ON TABLE rechnungen IS 'Rechnungen und Zahlungsüberwachung';
COMMENT ON TABLE aufgaben IS 'Interne Aufgaben und Follow-ups';
COMMENT ON TABLE produkte IS 'Produkt- und Service-Katalog';

COMMENT ON VIEW v_kunden_overview IS 'Dashboard: Kundenübersicht mit Projekten und Interaktionen';
COMMENT ON VIEW v_projekt_pipeline IS 'Dashboard: Aktive Projekte mit Deadline-Warnung';
COMMENT ON VIEW v_umsatz_overview IS 'Dashboard: Monatliche Umsatzübersicht';
COMMENT ON VIEW v_aufgaben_dashboard IS 'Dashboard: Aufgaben mit Dringlichkeit';
COMMENT ON VIEW v_sales_funnel IS 'Dashboard: Verkaufstrichter Lead → Interessent → Kunde';

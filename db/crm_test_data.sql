-- ============================================================================
-- keepITlocal CRM Test Data
-- ============================================================================
-- Realistic German business data for testing dashboards and forms
-- Run after applying crm_schema.sql
-- ============================================================================

-- Disable triggers temporarily for bulk insert
SET session_replication_role = 'replica';

-- ============================================================================
-- Test Customers (varied statuses, industries, priorities)
-- ============================================================================

INSERT INTO kunden (
    firma_name, firma_typ, branche, mitarbeiter_anzahl, website,
    ansprechpartner_name, ansprechpartner_position, email, telefon, mobil,
    strasse, plz, ort, bundesland, land,
    kunde_status, prioritaet, quelle, jahresumsatz_geschaetzt, potential_bewertung,
    notizen, tags, erstellt_von, zugeordnet_an, erstellt_am
) VALUES
-- Lead 1: Hot lead from email processor
('Bäckerei Müller GmbH', 'GmbH', 'Handwerk', 8, 'https://baeckerei-mueller.de',
 'Franz Müller', 'Geschäftsführer', 'f.mueller@baeckerei-mueller.de', '+49 89 12345678', '+49 171 1234567',
 'Hauptstraße 15', '80331', 'München', 'Bayern', 'Deutschland',
 'lead', 'hoch', 'Email-Anfrage', 500000.00, 8,
 'Interesse an AI-Telefonagent für Bestellannahme. Sehr DSGVO-sensibel, lokale Lösung wichtig.',
 'handwerk,dsgvo-sensibel,muenchen', 'Email-AI', 'Matthias', CURRENT_DATE - INTERVAL '2 days'),

-- Lead 2: Cold lead from website
('TechStart Solutions UG', 'UG', 'IT-Dienstleistungen', 3, 'https://techstart-solutions.de',
 'Lisa Weber', 'CTO', 'l.weber@techstart.de', '+49 30 98765432', NULL,
 'Berliner Allee 42', '10117', 'Berlin', 'Berlin', 'Deutschland',
 'lead', 'mittel', 'Website-Kontaktformular', 200000.00, 5,
 'Hat Kontaktformular ausgefüllt, noch keine Antwort. Interesse an Transkription für Kundengespräche.',
 'it,berlin,startup', 'Website-Form', 'Matthias', CURRENT_DATE - INTERVAL '5 days'),

-- Interessent 1: Demo geplant
('Hausarztpraxis Dr. Schmidt', 'Einzelunternehmen', 'Medizin', 5, NULL,
 'Dr. med. Sarah Schmidt', 'Inhaberin', 's.schmidt@praxis-schmidt.de', '+49 221 556677', '+49 160 5566778',
 'Kölner Straße 88', '50667', 'Köln', 'Nordrhein-Westfalen', 'Deutschland',
 'interessent', 'hoch', 'Empfehlung', 300000.00, 9,
 'Demo für AI-Telefonagent nächste Woche vereinbart. Hohe Anrufvolumen, 3 Sprechstundenhilfen entlasten.',
 'medizin,dsgvo-kritisch,koeln', 'Empfehlung', 'Matthias', CURRENT_DATE - INTERVAL '10 days'),

-- Interessent 2: Angebot gesendet
('AutoWerkstatt Schneider', 'Einzelunternehmen', 'KFZ-Gewerbe', 12, 'https://autowerkstatt-schneider.de',
 'Thomas Schneider', 'Inhaber', 't.schneider@autowerkstatt-schneider.de', '+49 711 334455', NULL,
 'Industriestraße 23', '70565', 'Stuttgart', 'Baden-Württemberg', 'Deutschland',
 'interessent', 'mittel', 'Google Ads', 800000.00, 7,
 'Angebot für Email-KI + Telefon-Agent gesendet. Wartet auf Budget-Freigabe.',
 'handwerk,stuttgart,automotive', 'Google Ads', 'Matthias', CURRENT_DATE - INTERVAL '15 days'),

-- Aktiver Kunde 1: Zahlt bereits
('Rechtsanwaltskanzlei Hoffmann & Partner', 'Freiberufler', 'Recht', 15, 'https://kanzlei-hoffmann.de',
 'RA Martin Hoffmann', 'Partner', 'm.hoffmann@kanzlei-hoffmann.de', '+49 69 778899', '+49 172 7788990',
 'Mainzer Landstraße 100', '60327', 'Frankfurt am Main', 'Hessen', 'Deutschland',
 'aktiv', 'hoch', 'Messe', 1500000.00, 10,
 'Produktiv seit 2 Monaten. Transkription + Email-KI. Sehr zufrieden, denkt über Telefon-Agent nach.',
 'recht,frankfurt,vip-kunde', 'Messe Frankfurt', 'Matthias', CURRENT_DATE - INTERVAL '60 days'),

-- Aktiver Kunde 2: Kleinerer Kunde
('Naturheilpraxis Bergmann', 'Freiberufler', 'Medizin', 2, NULL,
 'Sabine Bergmann', 'Heilpraktikerin', 's.bergmann@naturheil-bergmann.de', '+49 40 223344', NULL,
 'Eppendorfer Weg 55', '20259', 'Hamburg', 'Hamburg', 'Deutschland',
 'aktiv', 'niedrig', 'Empfehlung', 80000.00, 4,
 'Nutzt Email-KI seit 3 Wochen. Bezahlt pünktlich. Kleiner Kunde, aber gute Referenz.',
 'medizin,hamburg,kleinunternehmen', 'Empfehlung', 'Matthias', CURRENT_DATE - INTERVAL '25 days'),

-- Lead 3: Größeres Potential
('Steuerberatung Wagner & Co. GmbH', 'GmbH', 'Steuerberatung', 25, 'https://steuerberatung-wagner.de',
 'Andrea Wagner', 'Geschäftsführerin', 'a.wagner@stb-wagner.de', '+49 89 445566', '+49 170 4455667',
 'Leopoldstraße 150', '80804', 'München', 'Bayern', 'Deutschland',
 'lead', 'kritisch', 'LinkedIn', 2000000.00, 10,
 'Großkanzlei mit 25 Mitarbeitern. Interesse an vollständiger Digitalisierung. Budget vorhanden, Entscheider erreicht.',
 'steuerberatung,muenchen,enterprise,hot-lead', 'LinkedIn', 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Interessent 3: Zögerlich
('Elektro Meier GmbH', 'GmbH', 'Handwerk', 18, 'https://elektro-meier.de',
 'Hans Meier', 'Prokurist', 'h.meier@elektro-meier.de', '+49 911 667788', NULL,
 'Nürnberger Straße 45', '90403', 'Nürnberg', 'Bayern', 'Deutschland',
 'interessent', 'niedrig', 'Telefonakquise', 1200000.00, 3,
 'Skepsis gegenüber KI. Will klassisches Telefon behalten. Follow-up in 3 Monaten.',
 'handwerk,nuernberg,skeptisch', 'Telefonakquise', 'Matthias', CURRENT_DATE - INTERVAL '40 days'),

-- Aktiver Kunde 3: VIP
('Zentrum für Naturmedizin', 'GmbH', 'Medizin', 35, 'https://zentrum-naturmedizin.ch',
 'Dr. Michael Stark', 'Geschäftsführer', 'm.stark@znm.ch', '+41 44 1234567', NULL,
 'Bahnhofstraße 88', '8001', 'Zürich', NULL, 'Schweiz',
 'aktiv', 'kritisch', 'Direktansprache', 3500000.00, 10,
 'Schweizer Großkunde. Alle 3 Produkte im Einsatz. Monatlicher Umsatz 500€+. Wichtigste Referenz.',
 'medizin,schweiz,vip-kunde,referenzkunde', 'Direktansprache', 'Matthias', CURRENT_DATE - INTERVAL '90 days'),

-- Inaktiver Kunde: Churn-Risiko
('Immobilien Schmidt GmbH', 'GmbH', 'Immobilien', 7, 'https://immobilien-schmidt.de',
 'Peter Schmidt', 'Geschäftsführer', 'p.schmidt@immo-schmidt.de', '+49 89 998877', NULL,
 'Maximilianstraße 12', '80539', 'München', 'Bayern', 'Deutschland',
 'inaktiv', 'niedrig', 'Google Ads', 600000.00, 2,
 'Hatte Email-KI 2 Monate, dann gekündigt. Grund: Zu wenig Anpassung an Immobilien-Fachbegriffe.',
 'immobilien,muenchen,churn', 'Google Ads', 'Matthias', CURRENT_DATE - INTERVAL '120 days');

-- ============================================================================
-- Projekte für Kunden
-- ============================================================================

INSERT INTO projekte (
    kunde_id, projekt_name, projekt_typ, beschreibung, status, prioritaet,
    start_datum, end_datum, deadline, angebot_summe, tatsaechliche_kosten,
    gewinn_marge, zahlungs_status, zugeordnet_an, fortschritt_prozent,
    naechste_schritte, notizen, erstellt_am
) VALUES
-- Projekt 1: Aktiver Kunde - Abgeschlossen
(5, 'Email-KI & Transkription Setup Kanzlei Hoffmann', 'Email-Ingestion', 
 'Vollständige Implementierung Email-KI + Whisper Transkription für Mandantengespräche. Schulung Team.',
 'abgeschlossen', 'hoch', '2025-09-15', '2025-10-30', '2025-10-30',
 2980.00, 2200.00, 26.17, 'vollstaendig', 'Matthias', 100,
 NULL, 'Sehr erfolgreicher Rollout. Kunde hochzufrieden. Upsell-Potential für Telefon-Agent.',
 CURRENT_DATE - INTERVAL '60 days'),

-- Projekt 2: Interessent - Angebot gesendet
(3, 'AI-Telefonagent Demo & Pilot Praxis Schmidt', 'AI-Telefonagent',
 'Demo-Setup für 2 Wochen, dann Pilot mit 100 Anrufen/Monat. Custom Voice Training für medizinische Terminvereinbarung.',
 'angebot', 'hoch', NULL, NULL, '2025-11-30',
 1497.00, NULL, NULL, 'ausstehend', 'Matthias', 10,
 'Demo nächste Woche vorbereiten. Custom Prompts für Arztpraxis. DSGVO-Dokumentation bereitstellen.',
 'Wichtiger Lead. Wenn erfolgreich, Empfehlungen an andere Ärzte möglich.',
 CURRENT_DATE - INTERVAL '10 days'),

-- Projekt 3: Aktiver Kunde - In Arbeit
(9, 'Enterprise-Paket: Alle Lösungen Zentrum Naturmedizin', 'Custom-Entwicklung',
 'Full-Stack: AI-Telefonagent (5 Sprachen), Transkription (Therapiegespräche), Email-KI, Custom CRM-Integration.',
 'in_arbeit', 'kritisch', '2025-10-01', NULL, '2025-12-15',
 8950.00, 4200.00, 53.07, 'teilweise', 'Matthias', 65,
 'Phase 3: CRM-Integration abschließen. Phase 4: Schulung Team (20 Personen). Go-Live Mitte Dezember.',
 'Größtes Projekt. Strategisch wichtig für Schweiz-Expansion. Wöchentliche Status-Calls.',
 CURRENT_DATE - INTERVAL '45 days'),

-- Projekt 4: Lead - Angebot wird erstellt
(1, 'AI-Telefonagent Bäckerei Müller', 'AI-Telefonagent',
 'Automatische Bestellannahme via Telefon. Integration in bestehendes Warenwirtschaftssystem.',
 'angebot', 'hoch', NULL, NULL, '2025-11-20',
 1247.00, NULL, NULL, 'ausstehend', 'Matthias', 5,
 'Angebot finalisieren. Technische Details Warenwirtschafts-Integration klären. Termin für Demo vereinbaren.',
 'Hot Lead aus Email-Processor. Schnell reagieren!',
 CURRENT_DATE - INTERVAL '2 days'),

-- Projekt 5: Interessent - Verhandlung
(4, 'Kombi-Paket AutoWerkstatt Schneider', 'Custom-Entwicklung',
 'Email-KI für Kundenanfragen + AI-Telefonagent für Terminvereinbarung. Setup-Gebühr reduziert als Bundle.',
 'verhandlung', 'mittel', NULL, NULL, '2025-12-01',
 2196.00, NULL, NULL, 'ausstehend', 'Matthias', 15,
 'Warten auf Budget-Freigabe vom Inhaber. Follow-up in 3 Tagen. Rabatt anbieten wenn nötig.',
 'Gutes Upsell-Potential. Große Werkstatt, viele Anrufe.',
 CURRENT_DATE - INTERVAL '15 days'),

-- Projekt 6: Aktiver Kunde - In Arbeit
(6, 'Email-KI Naturheilpraxis Bergmann', 'Email-Ingestion',
 'Email-Klassifizierung für Terminanfragen und Patientenanliegen. DSGVO-konform, lokal gehostet.',
 'in_arbeit', 'niedrig', '2025-10-20', NULL, '2025-11-25',
 328.00, 180.00, 45.12, 'vollstaendig', 'Matthias', 90,
 'Feintuning der Klassifizierungs-Keywords. Go-Live nächste Woche. Schulung Frau Bergmann.',
 'Kleines Projekt, aber gute Referenz für Heilpraktiker-Netzwerk.',
 CURRENT_DATE - INTERVAL '25 days'),

-- Projekt 7: Lead - Neues Projekt
(7, 'Digitalisierungs-Strategie Steuerberatung Wagner', 'Beratung',
 'Strategieberatung für vollständige AI-Integration. Analyse bestehender Prozesse, Roadmap erstellen.',
 'angebot', 'kritisch', NULL, NULL, '2025-11-22',
 4500.00, NULL, NULL, 'ausstehend', 'Matthias', 0,
 'Erstgespräch morgen. Beratungskonzept ausarbeiten. Langfristiges Potential 20k+ pro Jahr.',
 'MEGA-OPPORTUNITY! Große Kanzlei, Budget vorhanden, echtes Interesse. Top-Priorität!',
 CURRENT_DATE - INTERVAL '1 day');

-- ============================================================================
-- Interaktionen (Email, Calls, Meetings)
-- ============================================================================

INSERT INTO interaktionen (
    kunde_id, projekt_id, typ, richtung, betreff, zusammenfassung, details,
    ergebnis, naechste_aktion, naechstes_follow_up, durchgefuehrt_von, interaktion_datum
) VALUES
-- Bäckerei Müller - Email kam rein
(1, 1, 'email', 'eingehend', 'Anfrage AI-Telefonagent',
 'Herr Müller interessiert an automatischer Bestellannahme. Betont lokale Lösung wegen DSGVO.',
 'Email über Gmail-Processor erfasst. Phone: +49 89 12345678. Terminvorschläge: Mittwoch 14:00-16:00 oder Donnerstag 10:00-12:00.',
 'Lead erstellt, Angebot in Vorbereitung', 'Demo-Termin vereinbaren', CURRENT_DATE + INTERVAL '2 days',
 'Email-AI', CURRENT_DATE - INTERVAL '2 days'),

-- Bäckerei Müller - Rückruf
(1, 1, 'telefon', 'ausgehend', NULL,
 'Rückruf bei Herrn Müller. Demo-Termin für Donnerstag 10:00 vereinbart.',
 'Sehr interessiert, will schnelle Lösung. Budget ca. 1500€ Setup + 100€/Monat okay. Konkurrent hat Cloud-Lösung angeboten, aber DSGVO-Bedenken.',
 'Demo-Termin steht', 'Demo vorbereiten, technische Details Warenwirtschaft klären', CURRENT_DATE + INTERVAL '3 days',
 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Dr. Schmidt - Meeting
(3, 2, 'meeting', 'ausgehend', 'Demo-Termin AI-Telefonagent',
 'Demo durchgeführt. Frau Dr. Schmidt sehr begeistert von lokaler Lösung und deutscher Sprachqualität.',
 '60 Min Demo in Praxis. Team anwesend (3 Sprechstundenhilfen). Live-Test mit 5 Beispiel-Anrufen. Alle Fragen zu DSGVO beantwortet.',
 'Demo erfolgreich, Angebot gewünscht', 'Angebot erstellen mit Custom Voice Training', CURRENT_DATE + INTERVAL '5 days',
 'Matthias', CURRENT_DATE - INTERVAL '3 days'),

-- Zentrum Naturmedizin - Projekt-Update
(9, 3, 'meeting', 'ausgehend', 'Wöchentliches Status-Meeting',
 'Phase 2 (Transkription) abgeschlossen. Phase 3 (CRM-Integration) 65% fertig. Go-Live weiter für Mitte Dezember geplant.',
 'Video-Call mit Dr. Stark und IT-Team. Transkription läuft stabil (>95% Genauigkeit Deutsch+Schweizerdeutsch). CRM-API-Integration in Testing.',
 'Auf Track für Dezember Go-Live', 'Phase 3 abschließen, Schulungsunterlagen vorbereiten', CURRENT_DATE + INTERVAL '7 days',
 'Matthias', CURRENT_DATE - INTERVAL '2 days'),

-- Kanzlei Hoffmann - Check-in Call
(5, NULL, 'telefon', 'ausgehend', NULL,
 'Monatlicher Check-in. Alles läuft stabil. Team sehr zufrieden mit Transkription. Interesse an AI-Telefonagent bestätigt.',
 'Email-KI klassifiziert >200 Emails/Woche korrekt. Transkription spart 10h/Woche. Anfrage für Telefon-Agent für Mandanten-Erstgespräche.',
 'Upsell-Opportunity identifiziert', 'Angebot für Telefon-Agent erstellen', CURRENT_DATE + INTERVAL '10 days',
 'Matthias', CURRENT_DATE - INTERVAL '5 days'),

-- AutoWerkstatt Schneider - Follow-up
(4, 5, 'email', 'ausgehend', 'Follow-up Angebot Kombi-Paket',
 'Follow-up Email zum Angebot von vor 2 Wochen. Nachfrage ob Fragen bestehen.',
 'Höfliche Nachfrage. Angebot gültig bis 30.11. Optional: 10% Rabatt bei Beauftragung bis Montag.',
 'Warte auf Antwort', 'Telefonisch nachfassen wenn keine Antwort', CURRENT_DATE + INTERVAL '3 days',
 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Steuerberatung Wagner - Erstkontakt
(7, 7, 'telefon', 'eingehend', NULL,
 'Frau Wagner via LinkedIn erreicht. 20min Gespräch über AI-Potentiale in Steuerkanzlei.',
 'Interesse an Gesamtlösung: Email-KI, Transkription (Mandantengespräche), Telefon-Agent (Terminvereinbarung). Budget: "bis 10k kein Problem".',
 'Erstgespräch Montag vereinbart', 'Beratungskonzept ausarbeiten, Branchen-Cases vorbereiten', CURRENT_DATE + INTERVAL '2 days',
 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Naturheilpraxis - Support
(6, 6, 'email', 'eingehend', 'Frage zu Email-Klassifizierung',
 'Frau Bergmann fragt warum bestimmte Emails als "support" statt "appointment" klassifiziert werden.',
 'Email-Text enthielt "Frage zu Behandlung" → wurde als support klassifiziert. Erklärt Logik, Keywords angepasst.',
 'Problem gelöst, Keywords optimiert', 'Monitoring ob neue Klassifizierung besser funktioniert', CURRENT_DATE + INTERVAL '7 days',
 'Matthias', CURRENT_DATE - INTERVAL '4 days');

-- ============================================================================
-- Angebote
-- ============================================================================

INSERT INTO angebote (
    angebots_nummer, kunde_id, projekt_id, titel, beschreibung, status,
    gesamt_betrag, rabatt_prozent, rabatt_betrag, netto_betrag, mwst_satz, mwst_betrag, brutto_betrag,
    gueltig_bis, gesendet_am, zahlungsbedingungen, lieferzeit, erstellt_von, erstellt_am
) VALUES
-- Angebot 1: Bäckerei Müller (in Arbeit)
('AIH-2025-001', 1, 1, 'AI-Telefonagent für Bäckerei Müller',
 'Automatische Bestellannahme via Telefon, Integration Warenwirtschaftssystem, Custom Voice Training, 100 Anrufe/Monat inklusive.',
 'entwurf', 1048.00, 0, 0, 1048.00, 19.00, 199.12, 1247.12,
 CURRENT_DATE + INTERVAL '14 days', NULL, '14 Tage netto', '2 Wochen nach Auftragseingang',
 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Angebot 2: Dr. Schmidt (gesendet, wartet auf Antwort)
('AIH-2025-002', 3, 2, 'AI-Telefonagent Professional - Hausarztpraxis Dr. Schmidt',
 'AI-Telefonagent Professional mit Custom Voice Training, 500 Anrufe/Monat, spezialisiert auf medizinische Terminvereinbarung.',
 'gesendet', 1258.00, 5.00, 62.90, 1195.10, 19.00, 227.07, 1422.17,
 CURRENT_DATE + INTERVAL '10 days', CURRENT_DATE - INTERVAL '2 days', '14 Tage netto', '3 Wochen nach Auftragseingang',
 'Matthias', CURRENT_DATE - INTERVAL '3 days'),

-- Angebot 3: AutoWerkstatt Schneider (gesendet, in Verhandlung)
('AIH-2025-003', 4, 5, 'Kombi-Paket: Email-KI + Telefon-Agent',
 'Email-KI-Assistent + AI-Telefonagent Basis. Bundle-Rabatt 15% auf Setup-Gebühren.',
 'gesendet', 1846.00, 15.00, 277.00, 1569.00, 19.00, 298.11, 1867.11,
 CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE - INTERVAL '12 days', '14 Tage netto', '4 Wochen nach Auftragseingang',
 'Matthias', CURRENT_DATE - INTERVAL '15 days'),

-- Angebot 4: Steuerberatung Wagner (wird vorbereitet)
('AIH-2025-004', 7, 7, 'Digitalisierungs-Beratung + Enterprise-Setup',
 'Phase 1: Strategieberatung (16h). Phase 2: Vollständige AI-Integration (Email, Telefon, Transkription).',
 'entwurf', 3780.00, 0, 0, 3780.00, 19.00, 718.20, 4498.20,
 CURRENT_DATE + INTERVAL '21 days', NULL, '50% Anzahlung, Rest 14 Tage netto', 'Phase 1: 2 Wochen, Phase 2: 8 Wochen',
 'Matthias', CURRENT_DATE - INTERVAL '1 day'),

-- Angebot 5: Kanzlei Hoffmann Upsell (angenommen!)
('AIH-2025-005', 5, NULL, 'AI-Telefonagent für Mandanten-Erstgespräche',
 'Telefon-Agent für Erstgespräch-Koordination, Custom Voice, Integration in bestehendes System.',
 'angenommen', 1048.00, 10.00, 104.80, 943.20, 19.00, 179.21, 1122.41,
 CURRENT_DATE + INTERVAL '30 days', CURRENT_DATE - INTERVAL '10 days', '14 Tage netto', '3 Wochen',
 'Matthias', CURRENT_DATE - INTERVAL '12 days');

-- Angebots-Positionen für die Angebote
INSERT INTO angebote_positionen (
    angebot_id, produkt_id, position_nr, beschreibung, menge, einheit,
    einzelpreis, gesamt_preis, produkt_typ, laufzeit_monate
) VALUES
-- Angebot 1: Bäckerei Müller
(1, 1, 1, 'AI-Telefonagent Basis Setup-Gebühr', 1, 'Einmalig', 299.00, 299.00, 'AI-Telefonagent', NULL),
(1, 1, 2, 'AI-Telefonagent Basis Monatsgebühr (3 Monate prepaid)', 3, 'Monat', 99.00, 297.00, 'AI-Telefonagent', 3),
(1, NULL, 3, 'Warenwirtschafts-Integration (Custom)', 1, 'Einmalig', 250.00, 250.00, 'Custom-Entwicklung', NULL),
(1, NULL, 4, 'Schulung & Dokumentation', 1, 'Einmalig', 202.00, 202.00, 'Schulung', NULL),

-- Angebot 2: Dr. Schmidt
(2, 2, 1, 'AI-Telefonagent Professional Setup-Gebühr (5% Rabatt)', 1, 'Einmalig', 474.05, 474.05, 'AI-Telefonagent', NULL),
(2, 2, 2, 'AI-Telefonagent Professional Monatsgebühr (3 Monate)', 3, 'Monat', 249.00, 747.00, 'AI-Telefonagent', 3),
(2, NULL, 3, 'DSGVO-Dokumentation Medizinbereich', 1, 'Einmalig', 95.00, 95.00, 'Dokumentation', NULL);

-- ============================================================================
-- Rechnungen
-- ============================================================================

INSERT INTO rechnungen (
    rechnungs_nummer, kunde_id, projekt_id, angebot_id, titel, beschreibung, status,
    netto_betrag, mwst_satz, mwst_betrag, brutto_betrag, bereits_bezahlt, offener_betrag,
    rechnungsdatum, leistungsdatum, faellig_am, bezahlt_am, zahlungsart, erstellt_von
) VALUES
-- Rechnung 1: Kanzlei Hoffmann - Bezahlt
('RE-2025-001', 5, 1, NULL, 'Email-KI & Transkription Setup',
 'Setup-Gebühr Email-KI-Assistent + Lokale Transkription inkl. Schulung Team (15 Personen).',
 'bezahlt', 2504.20, 19.00, 475.80, 2980.00, 2980.00, 0.00,
 '2025-09-20', '2025-09-20', '2025-10-04', '2025-09-28', 'Überweisung', 'Matthias'),

-- Rechnung 2: Zentrum Naturmedizin - Teilzahlung (50% Anzahlung)
('RE-2025-002', 9, 3, NULL, 'Enterprise-Paket Anzahlung (50%)',
 'Anzahlung für Enterprise-Paket: AI-Telefonagent + Transkription + Email-KI + CRM-Integration.',
 'teilweise_bezahlt', 3763.87, 19.00, 715.13, 4479.00, 4479.00, 0.00,
 '2025-10-01', '2025-10-01', '2025-10-15', '2025-10-08', 'Überweisung', 'Matthias'),

-- Rechnung 3: Naturheilpraxis - Bezahlt
('RE-2025-003', 6, 6, NULL, 'Email-KI-Assistent Setup',
 'Setup-Gebühr Email-KI-Assistent inkl. DSGVO-konforme Konfiguration.',
 'bezahlt', 275.63, 19.00, 52.37, 328.00, 328.00, 0.00,
 '2025-10-25', '2025-10-25', '2025-11-08', '2025-11-05', 'PayPal', 'Matthias'),

-- Rechnung 4: Zentrum Naturmedizin - Offen (Restbetrag)
('RE-2025-004', 9, 3, NULL, 'Enterprise-Paket Restbetrag (50%)',
 'Restbetrag für Enterprise-Paket nach Go-Live. Fällig nach Abnahme Ende Dezember.',
 'gesendet', 3763.87, 19.00, 715.13, 4479.00, 0.00, 4479.00,
 '2025-11-15', NULL, '2025-12-31', NULL, NULL, 'Matthias'),

-- Rechnung 5: Kanzlei Hoffmann - Monatliche Gebühr (überfällig!)
('RE-2025-005', 5, NULL, NULL, 'Monatliche Gebühr November 2025',
 'Email-KI-Assistent: 79€/Monat + Transkription: 149€/Monat',
 'ueberfaellig', 191.60, 19.00, 36.40, 228.00, 0.00, 228.00,
 '2025-11-01', '2025-11-01', '2025-11-08', NULL, NULL, 'Matthias');

-- ============================================================================
-- Aufgaben (Tasks)
-- ============================================================================

INSERT INTO aufgaben (
    kunde_id, projekt_id, titel, beschreibung, typ, status, prioritaet,
    faellig_am, erinnerung_am, geschaetzter_aufwand_stunden, zugeordnet_an, erstellt_von
) VALUES
-- Überfällige Aufgaben
(5, NULL, 'Mahnung RE-2025-005 senden',
 'Rechnung RE-2025-005 für Kanzlei Hoffmann ist seit 8 Tagen überfällig. Freundliche Mahnung per Email senden.',
 'rechnung_senden', 'offen', 'hoch', CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE - INTERVAL '2 days', 0.5,
 'Matthias', 'System'),

(4, 5, 'Follow-up Angebot AutoWerkstatt Schneider',
 'Angebot vor 15 Tagen gesendet, keine Antwort. Telefonisch nachfassen ob Fragen bestehen.',
 'follow_up', 'offen', 'mittel', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE - INTERVAL '1 day', 0.5,
 'Matthias', 'Matthias'),

-- Heute fällig
(1, 1, 'Demo-Vorbereitung Bäckerei Müller',
 'Demo für Donnerstag vorbereiten: Custom Prompts für Backwaren-Bestellung, Test-Szenarien, DSGVO-Dokumentation.',
 'demo_vorbereiten', 'in_arbeit', 'hoch', CURRENT_DATE, CURRENT_DATE - INTERVAL '2 hours', 3.0,
 'Matthias', 'Matthias'),

(7, 7, 'Erstgespräch Steuerberatung Wagner',
 'Erstgespräch Montag 10:00. Beratungskonzept fertigstellen, Branchen-Cases vorbereiten (Steuerberatung).',
 'angebot_erstellen', 'in_arbeit', 'kritisch', CURRENT_DATE, CURRENT_DATE - INTERVAL '1 hour', 4.0,
 'Matthias', 'Matthias'),

-- Diese Woche
(9, 3, 'CRM-Integration Phase 3 abschließen',
 'API-Endpoints für Zentrum Naturmedizin CRM fertigstellen. Testing mit echten Daten. Deployment Staging.',
 'entwicklung', 'in_arbeit', 'kritisch', CURRENT_DATE + INTERVAL '3 days', CURRENT_DATE + INTERVAL '2 days', 12.0,
 'Matthias', 'Matthias'),

(3, 2, 'Angebot finalisieren Dr. Schmidt',
 'Nach erfolgreicher Demo: Angebot finalisieren mit individuellen Anpassungen. DSGVO-Dokumentation anhängen.',
 'angebot_erstellen', 'offen', 'hoch', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '4 days', 2.0,
 'Matthias', 'Matthias'),

(6, 6, 'Go-Live Email-KI Naturheilpraxis',
 'Finale Tests, Schulung Frau Bergmann (30 Min), Go-Live Email-KI. Monitoring erste 2 Tage.',
 'entwicklung', 'offen', 'mittel', CURRENT_DATE + INTERVAL '6 days', CURRENT_DATE + INTERVAL '5 days', 2.5,
 'Matthias', 'Matthias'),

-- Nächste Woche+
(5, NULL, 'Upsell-Angebot Telefon-Agent vorbereiten',
 'Angebot für AI-Telefonagent an Kanzlei Hoffmann. Fokus: Mandanten-Erstgespräche automatisieren.',
 'angebot_erstellen', 'offen', 'mittel', CURRENT_DATE + INTERVAL '10 days', CURRENT_DATE + INTERVAL '9 days', 2.0,
 'Matthias', 'Matthias'),

(2, NULL, 'Follow-up TechStart Solutions',
 'Lead von Website-Formular. Cold Lead, Follow-up in 2 Wochen ob Interesse noch besteht.',
 'follow_up', 'offen', 'niedrig', CURRENT_DATE + INTERVAL '14 days', CURRENT_DATE + INTERVAL '13 days', 0.5,
 'Matthias', 'Matthias');

-- Re-enable triggers
SET session_replication_role = 'origin';

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Show summary
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Test Data Import Complete!';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Kunden: % (Leads: %, Interessenten: %, Aktiv: %)', 
        (SELECT COUNT(*) FROM kunden),
        (SELECT COUNT(*) FROM kunden WHERE kunde_status = 'lead'),
        (SELECT COUNT(*) FROM kunden WHERE kunde_status = 'interessent'),
        (SELECT COUNT(*) FROM kunden WHERE kunde_status = 'aktiv');
    RAISE NOTICE 'Projekte: % (Angebot: %, In Arbeit: %, Abgeschlossen: %)',
        (SELECT COUNT(*) FROM projekte),
        (SELECT COUNT(*) FROM projekte WHERE status = 'angebot'),
        (SELECT COUNT(*) FROM projekte WHERE status = 'in_arbeit'),
        (SELECT COUNT(*) FROM projekte WHERE status = 'abgeschlossen');
    RAISE NOTICE 'Interaktionen: %', (SELECT COUNT(*) FROM interaktionen);
    RAISE NOTICE 'Angebote: % (Entwurf: %, Gesendet: %, Angenommen: %)',
        (SELECT COUNT(*) FROM angebote),
        (SELECT COUNT(*) FROM angebote WHERE status = 'entwurf'),
        (SELECT COUNT(*) FROM angebote WHERE status = 'gesendet'),
        (SELECT COUNT(*) FROM angebote WHERE status = 'angenommen');
    RAISE NOTICE 'Rechnungen: % (Bezahlt: %, Offen: %, Überfällig: %)',
        (SELECT COUNT(*) FROM rechnungen),
        (SELECT COUNT(*) FROM rechnungen WHERE status = 'bezahlt'),
        (SELECT COUNT(*) FROM rechnungen WHERE offener_betrag > 0 AND status != 'ueberfaellig'),
        (SELECT COUNT(*) FROM rechnungen WHERE status = 'ueberfaellig');
    RAISE NOTICE 'Aufgaben: % (Offen: %, Überfällig: %, Heute: %)',
        (SELECT COUNT(*) FROM aufgaben WHERE status != 'erledigt'),
        (SELECT COUNT(*) FROM aufgaben WHERE status = 'offen'),
        (SELECT COUNT(*) FROM aufgaben WHERE faellig_am < CURRENT_DATE AND status != 'erledigt'),
        (SELECT COUNT(*) FROM aufgaben WHERE faellig_am = CURRENT_DATE AND status != 'erledigt');
    RAISE NOTICE '============================================';
END $$;

-- Show key metrics for Metabase testing
SELECT 
    'Pipeline Value' as metric,
    TO_CHAR(SUM(brutto_betrag), '9,999.99€') as wert
FROM angebote 
WHERE status IN ('gesendet', 'entwurf') AND gueltig_bis >= CURRENT_DATE

UNION ALL

SELECT 
    'Offene Forderungen',
    TO_CHAR(SUM(offener_betrag), '9,999.99€')
FROM rechnungen 
WHERE status IN ('gesendet', 'teilweise_bezahlt', 'ueberfaellig')

UNION ALL

SELECT 
    'Monatlicher Recurring Revenue (MRR)',
    TO_CHAR(
        (SELECT COUNT(*) FROM kunden WHERE kunde_status = 'aktiv') * 
        ((79.00 + 149.00 + 99.00) / 3.0), 
        '9,999.99€'
    )

UNION ALL

SELECT 
    'Customer Lifetime Value (Avg)',
    TO_CHAR(
        (SELECT AVG(gesamtumsatz) FROM (
            SELECT SUM(tatsaechliche_kosten) as gesamtumsatz
            FROM projekte 
            WHERE status = 'abgeschlossen'
            GROUP BY kunde_id
        ) sub),
        '9,999.99€'
    );

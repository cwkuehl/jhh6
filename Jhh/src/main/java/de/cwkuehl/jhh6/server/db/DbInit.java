package de.cwkuehl.jhh6.server.db;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Vector;

import de.cwkuehl.jhh6.api.dto.HpBehandlung;
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistung;
import de.cwkuehl.jhh6.api.dto.HpBehandlungUpdate;
import de.cwkuehl.jhh6.api.dto.Zeinstellung;
import de.cwkuehl.jhh6.api.dto.ZeinstellungKey;
import de.cwkuehl.jhh6.api.dto.ZeinstellungUpdate;
import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.MeldungException;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.api.service.IReplikationService;
import de.cwkuehl.jhh6.api.service.ServiceDaten;
import de.cwkuehl.jhh6.server.base.DbContext;
import de.cwkuehl.jhh6.server.rep.IHpBehandlungLeistungRep;
import de.cwkuehl.jhh6.server.rep.IHpBehandlungRep;
import de.cwkuehl.jhh6.server.rep.IZeinstellungRep;

public class DbInit {

    /**
     * Datenbank-Anpassungen werden vorgenommen.
     * @param daten Context-Daten mit Mandantennummer.
     * @param dbart Datenbankart.
     * @param zeinstellungDao Repository für Einstellungen.
     * @param behandlungRep Repository für Behandlungen.
     */
    public final void machEs(ServiceDaten daten, DatenbankArt dbart, IZeinstellungRep zeinstellungDao,
            IHpBehandlungRep behandlungRep, IHpBehandlungLeistungRep behleistRep, IReplikationService replService) {

        int version = 0;
        if (version != 0 && dbart.equals(DatenbankArt.HSQLDB)) {
            BufferedReader f = null;
            try {
                try {
                    f = new BufferedReader(new FileReader("WebHH_HSQLDB.sql"));
                    StringBuffer sb = new StringBuffer();
                    String zeile = null;
                    while ((zeile = f.readLine()) != null) {
                        if (!Global.nes(zeile) && !zeile.startsWith("--")) {
                            if (sb.length() > 0) {
                                sb.append("\r\n");
                            }
                            sb.append(zeile);
                            if (zeile.endsWith(";")) {
                                zeinstellungDao.execute(daten, sb.toString());
                                sb.setLength(0);
                            }
                        }
                    }
                } finally {
                    if (f != null) {
                        f.close();
                    }
                }
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
            // zeinstellungDao.execute("SET PASSWORD xxx;");
            // zeinstellungDao.execute("SHUTDOWN SCRIPT;");
            // zeinstellungDao.execute("SET SSET FILES SCRIPT FORMAT COMPRESSED;");
        }

        // Aktuelle Datenbank-Struktur-Version lesen
        boolean weiter = true;
        ZeinstellungKey zeinstellungKey = new ZeinstellungKey(Constant.EINST_DB_VERSION);
        Zeinstellung zeinstellung = zeinstellungDao.get(daten, zeinstellungKey);
        if (zeinstellung != null) {
            version = Global.strInt(zeinstellung.getWert());
        }
        if (version < 26) {
            throw new MeldungException(Meldungen.M1017());
        }
        int versionAlt = version;
        while (weiter) {
            if (version <= 26) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "VM_Abrechnung";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Haus_Uid", "D_REPL_ID", false);
                dba.createTab1("Wohnung_Uid", "D_REPL_ID", true);
                dba.createTab1("Mieter_Uid", "D_REPL_ID", true);
                dba.createTab1("Datum_Von", "D_DATE", false);
                dba.createTab1("Datum_Bis", "D_DATE", false);
                dba.createTab1("Schluessel", "D_STRING_10", false);
                dba.createTab1("Beschreibung", "D_STRING_255", true);
                dba.createTab1("Betrag", "D_GELDBETRAG", false);
                dba.createTab1("Reihenfolge", "D_STRING_10", false);
                dba.createTab1("Status", "D_STRING_01", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                dba.createTab3(mout, tabelle, "Schluessel", false,
                        "Mandant_Nr, Haus_Uid, Wohnung_Uid, Mieter_Uid, Datum_Von, Datum_Bis, Schluessel");
                execute(daten, zeinstellungDao, mout);
                version = 27;
            } else if (version <= 27) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "VM_Abrechnung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Haus_Uid", "D_REPL_ID", false);
                dba.addTab1("Wohnung_Uid", "D_REPL_ID", true);
                dba.addTab1("Mieter_Uid", "D_REPL_ID", true);
                dba.addTab1("Datum_Von", "D_DATE", false);
                dba.addTab1("Datum_Bis", "D_DATE", false);
                dba.addTab1("Schluessel", "D_STRING_10", false);
                dba.addTab1("Beschreibung", "D_STRING_255", true);
                dba.addTab1a("Wert", "D_STRING_255", true, "NULL");
                dba.addTab1("Betrag", "D_GELDBETRAG", false);
                dba.addTab1a("Datum", "D_DATETIME", true, "NULL");
                dba.addTab1("Reihenfolge", "D_STRING_10", false);
                dba.addTab1("Status", "D_STRING_01", false);
                dba.addTab1a("Funktion", "D_STRING_10", true, "NULL");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                dba.createTab3(mout, tabelle, "Schluessel", false,
                        "Mandant_Nr, Haus_Uid, Wohnung_Uid, Mieter_Uid, Datum_Von, Datum_Bis, Schluessel");
                execute(daten, zeinstellungDao, mout);
                version = 28;
            } else if (version <= 28) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Behandlung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                // dba.addTab1("Nr", "D_INTEGER", false);
                dba.addTab1a("Patient_Uid", "D_REPL_ID", false, "Patient_Nr");
                dba.addTab1("Datum", "D_DATE", false);
                dba.addTab1("Dauer", "D_INTEGER", false);
                dba.addTab1("Beschreibung", "D_STRING_50", false);
                dba.addTab1("Diagnose", "D_STRING_50", true);
                dba.addTab1("Betrag", "D_GELDBETRAG", false);
                dba.addTab1a("Leistung_Uid", "D_REPL_ID", false, "Leistung_Nr");
                dba.addTab1a("Rechnung_Uid", "D_REPL_ID", true, "Rechnung_Nr");
                dba.addTab1a("Status_Uid", "D_REPL_ID", false, "Status_Nr");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "HP_Leistung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                // dba.addTab1("Nr", "D_INTEGER", false);
                dba.addTab1("Ziffer", "D_STRING_10", false);
                dba.addTab1("Ziffer_Alt", "D_STRING_10", false);
                dba.addTab1("Beschreibung_Fett", "D_STRING_100", false);
                dba.addTab1("Beschreibung", "D_MEMO", false);
                dba.addTab1("Faktor", "D_GELDBETRAG", false);
                dba.addTab1("Festbetrag", "D_GELDBETRAG", false);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "HP_Patient";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                // dba.addTab1("Nr", "D_INTEGER", false);
                dba.addTab1("Name1", "D_STRING_50", false);
                dba.addTab1("Vorname", "D_STRING_50", true);
                dba.addTab1("Geschlecht", "D_STRING_01", false);
                dba.addTab1("Geburt", "D_DATE", true);
                dba.addTab1("Adresse1", "D_STRING_50", true);
                dba.addTab1("Adresse2", "D_STRING_50", true);
                dba.addTab1("Adresse3", "D_STRING_50", true);
                dba.addTab1a("Rechnung_Patient_Uid", "D_REPL_ID", true, "Rechnung_Patient_Nr");
                dba.addTab1("Status", "D_STRING_10", true);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "HP_Rechnung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                // dba.addTab1("Nr", "D_INTEGER", false);
                dba.addTab1("Rechnungsnummer", "D_STRING_20", false);
                dba.addTab1("Datum", "D_DATE", false);
                dba.addTab1a("Patient_Uid", "D_REPL_ID", false, "Patient_Nr");
                dba.addTab1("Betrag", "D_GELDBETRAG", false);
                dba.addTab1("Diagnose", "D_STRING_50", false);
                dba.addTab1a("Status_Uid", "D_REPL_ID", false, "Status_Nr");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "HP_Status";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                // dba.addTab1("Nr", "D_INTEGER", false);
                dba.addTab1("Status", "D_STRING_10", false);
                dba.addTab1("Beschreibung", "D_STRING_40", false);
                dba.addTab1("Sortierung", "D_INTEGER", false);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                execute(daten, zeinstellungDao, mout);
                version = 29;
            } else if (version <= 29) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Behandlung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Patient_Uid", "D_REPL_ID", false);
                dba.addTab1("Datum", "D_DATE", false);
                dba.addTab1("Dauer", "D_INTEGER", false);
                dba.addTab1("Beschreibung", "D_STRING_50", false);
                dba.addTab1("Diagnose", "D_STRING_50", true);
                dba.addTab1("Betrag", "D_GELDBETRAG", false);
                dba.addTab1("Leistung_Uid", "D_REPL_ID", false);
                dba.addTab1("Rechnung_Uid", "D_REPL_ID", true);
                dba.addTab1("Status_Uid", "D_REPL_ID", false);
                dba.addTab1a("Mittel", "D_STRING_50", true, "NULL");
                dba.addTab1a("Potenz", "D_STRING_10", true, "NULL");
                dba.addTab1a("Dosierung", "D_STRING_100", true, "NULL");
                dba.addTab1a("Verordnung", "D_STRING_255", true, "NULL");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                tabelle = "HP_Status";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Status", "D_STRING_10", false);
                dba.addTab1("Beschreibung", "D_STRING_40", false);
                dba.addTab1("Sortierung", "D_INTEGER", false);
                dba.addTab1a("Standard", "D_INTEGER", false, "0");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 30;
            } else if (version <= 30) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Leistung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Ziffer", "D_STRING_10", false);
                dba.addTab1("Ziffer_Alt", "D_STRING_10", false);
                dba.addTab1("Beschreibung_Fett", "D_STRING_100", false);
                dba.addTab1("Beschreibung", "D_MEMO", false);
                dba.addTab1("Faktor", "D_GELDBETRAG", false);
                dba.addTab1("Festbetrag", "D_GELDBETRAG", false);
                dba.addTab1a("Fragen", "D_MEMO", true, "NULL");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 31;
            } else if (version <= 31) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Symptom";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Behandlung_Uid", "D_REPL_ID", false);
                dba.createTab1("Auftreten", "D_DATETIME", true);
                dba.createTab1("Beschreibung", "D_STRING_255", false);
                dba.createTab1("Symptom_Uid", "D_REPL_ID", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 32;
            } else if (version <= 32) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Anamnese";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Patient_Uid", "D_REPL_ID", false);
                dba.createTab1("Datum", "D_DATETIME", true);
                dba.createTab1("Dauer", "D_INTEGER", false);
                dba.createTab1("Leistung_Uid", "D_REPL_ID", false);
                dba.createTab1("Behandlung_Uid", "D_REPL_ID", true);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                tabelle = "HP_Symptom_Anamnese";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Symptom_Uid", "D_REPL_ID", false);
                dba.createTab1("Anamnese_Uid", "D_REPL_ID", false);
                dba.createTab1("Auftreten", "D_DATETIME", true);
                dba.createTab1("Aenderung", "D_GELDBETRAG", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                dba.createTab3(mout, tabelle, "XRKHP_Symptom_Anamnese", true, "Mandant_Nr, Symptom_Uid, Anamnese_Uid");
                execute(daten, zeinstellungDao, mout);
                version = 33;
            } else if (version <= 33) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "SB_Ereignis";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Person_Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1a("Familie_Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Typ", "D_STRING_04", false);
                dba.addTab1("Tag1", "D_INTEGER", false);
                dba.addTab1("Monat1", "D_INTEGER", false);
                dba.addTab1("Jahr1", "D_INTEGER", false);
                dba.addTab1("Tag2", "D_INTEGER", false);
                dba.addTab1("Monat2", "D_INTEGER", false);
                dba.addTab1("Jahr2", "D_INTEGER", false);
                dba.addTab1("Datum_Typ", "D_STRING_04", false);
                dba.addTab1("Ort", "D_STRING_120", true);
                dba.addTab1("Bemerkung", "D_MEMO", true);
                dba.addTab1a("Quelle_Uid", "D_REPL_ID", true, "Quellen_Nr");
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1a("Replikation_Uid", "D_REPL_ID", true, "Nr_Typ");
                dba.addTab2(mout, tabelle, "Mandant_Nr, Person_Uid, Familie_Uid, Typ, Tag1, Monat1, Jahr1",
                        "Mandant_Nr, Nr_Typ, Nr, Typ, Tag1, Monat1, Jahr1");
                dba.createTab3(mout, tabelle, "XRKSB_Ereignis", false, "Replikation_Uid, Mandant_Nr");
                mout.add("UPDATE SB_Ereignis SET Familie_Uid='' WHERE Replikation_Uid='INDI'");
                mout.add("UPDATE SB_Ereignis SET Person_Uid='' WHERE Replikation_Uid='FAM'");
                mout.add("UPDATE SB_Ereignis SET Replikation_Uid=NULL");
                tabelle = "SB_Familie";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1a("Mann_Uid", "D_REPL_ID", true, "Mann_Nr");
                dba.addTab1a("Frau_Uid", "D_REPL_ID", true, "Frau_Nr");
                dba.addTab1("Status1", "D_INTEGER", false);
                dba.addTab1("Status2", "D_INTEGER", false);
                dba.addTab1("Status3", "D_INTEGER", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                mout.add("UPDATE SB_Familie SET Mann_Uid=NULL WHERE Mann_Uid='0'");
                mout.add("UPDATE SB_Familie SET Frau_Uid=NULL WHERE Frau_Uid='0'");
                tabelle = "SB_Kind";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Familie_Uid", "D_REPL_ID", false, "Familien_Nr");
                dba.addTab1a("Kind_Uid", "D_REPL_ID", false, "Kind_Nr");
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1a("Replikation_Uid", "D_REPL_ID", true, "NULL");
                dba.addTab2(mout, tabelle, "Mandant_Nr, Familie_Uid, Kind_Uid", "Mandant_Nr, Familien_Nr, Kind_Nr");
                dba.createTab3(mout, tabelle, "XRKSB_Kind", false, "Replikation_Uid, Mandant_Nr");
                tabelle = "SB_Person";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Name", "D_STRING_50", false);
                dba.addTab1("Vorname", "D_STRING_50", true);
                dba.addTab1("Geburtsname", "D_STRING_50", true);
                dba.addTab1("Geschlecht", "D_STRING_01", true);
                dba.addTab1("Titel", "D_STRING_50", true);
                dba.addTab1("Konfession", "D_STRING_20", true);
                dba.addTab1("Bemerkung", "D_STRING_255", true);
                dba.addTab1a("Quelle_Uid", "D_REPL_ID", true, "Quellen_Nr");
                dba.addTab1("Status1", "D_INTEGER", false);
                dba.addTab1("Status2", "D_INTEGER", false);
                dba.addTab1("Status3", "D_INTEGER", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "SB_Quelle";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Beschreibung", "D_STRING_255", false);
                dba.addTab1("Zitat", "D_MEMO", true);
                dba.addTab1("Bemerkung", "D_MEMO", true);
                dba.addTab1("Autor", "D_STRING_255", false);
                dba.addTab1("Status1", "D_INTEGER", false);
                dba.addTab1("Status2", "D_INTEGER", false);
                dba.addTab1("Status3", "D_INTEGER", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                execute(daten, zeinstellungDao, mout);
                version = 34;
            } else if (version <= 34) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "MA_Einstellung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Schluessel", "D_STRING_50", false);
                dba.addTab1a("Wert", "D_MEMO", true, "Wert");
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Schluessel", "Mandant_Nr, Schluessel");
                mout.add("DELETE FROM MA_Einstellung WHERE Schluessel like 'HP_BRIEFENDE%'");
                execute(daten, zeinstellungDao, mout);
                version = 35;
            } else if (version <= 35) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "FZ_Buch";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1a("Autor_Uid", "D_REPL_ID", false, "Autor_Nr");
                dba.addTab1a("Serie_Uid", "D_REPL_ID", false, "Serie_Nr");
                dba.addTab1("Seriennummer", "D_INTEGER", false);
                dba.addTab1("Titel", "D_STRING_100", false);
                dba.addTab1("Seiten", "D_INTEGER", false);
                dba.addTab1("Sprache_Nr", "D_INTEGER", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "FZ_Buchstatus";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Buch_Uid", "D_REPL_ID", false, "Buch_Nr");
                dba.addTab1("Ist_Besitz", "D_SWITCH", false);
                dba.addTab1("Lesedatum", "D_DATE", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1a("Replikation_Uid", "D_REPL_ID", true, "NULL");
                dba.addTab2(mout, tabelle, "Mandant_Nr, Buch_Uid", "Mandant_Nr, Buch_Nr");
                dba.createTab3(mout, tabelle, "XRKFZ_Buchstatus", false, "Replikation_Uid, Mandant_Nr");
                tabelle = "FZ_Buchautor";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Name", "D_STRING_50", false);
                dba.addTab1("Vorname", "D_STRING_50", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "FZ_Buchserie";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Name", "D_STRING_100", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                execute(daten, zeinstellungDao, mout);
                version = 36;
            } else if (version <= 36) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "FZ_Lektion";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Uid", "D_REPL_ID", false, "Nr");
                dba.addTab1("Bezeichnung", "D_STRING_50", false);
                dba.addTab1("Stichwort", "D_STRING_50", false);
                dba.addTab1("Inhalt1", "D_STRING_50", false);
                dba.addTab1("Inhalt2", "D_STRING_50", false);
                dba.addTab1("Inhalt3", "D_STRING_50", false);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Nr");
                tabelle = "FZ_Lektioninhalt";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Lektion_Uid", "D_REPL_ID", false, "Lektion_Nr");
                dba.addTab1("Lfd_Nr", "D_INTEGER", false);
                dba.addTab1("Stichwort", "D_STRING_255", false);
                dba.addTab1("Inhalt1", "D_MEMO", false);
                dba.addTab1("Inhalt2", "D_MEMO", true);
                dba.addTab1("Inhalt3", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1a("Replikation_Uid", "D_REPL_ID", true, "NULL");
                dba.addTab2(mout, tabelle, "Mandant_Nr, Lektion_Uid, Lfd_Nr", "Mandant_Nr, Lektion_Nr, Lfd_Nr");
                dba.createTab3(mout, tabelle, "XRKFZ_Lektioninhalt", false, "Replikation_Uid, Mandant_Nr");
                tabelle = "FZ_Lektionstand";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1a("Lektion_Uid", "D_REPL_ID", false, "Lektion_Nr");
                dba.addTab1("Stand", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Lektion_Uid", "Mandant_Nr, Lektion_Nr");
                execute(daten, zeinstellungDao, mout);
                version = 37;
            } else if (version <= 37) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "MA_Parameter";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Schluessel", "D_STRING_50", false);
                dba.createTab1("Wert", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab1("Replikation_Uid", "D_REPL_ID", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Schluessel");
                dba.createTab3(mout, tabelle, "XRKMA_Parameter", false, "Replikation_Uid, Mandant_Nr");
                mout.add(
                        "INSERT INTO MA_Parameter(Mandant_Nr,Schluessel,Wert,Angelegt_Von,Angelegt_Am,Geaendert_Von,Geaendert_Am,Replikation_Uid)"
                                + " SELECT Mandant_Nr,Schluessel,Wert,Angelegt_Von,Angelegt_Am,Geaendert_Von,Geaendert_Am,NULL FROM MA_Einstellung WHERE Schluessel like 'HP_%'");
                mout.add("DELETE FROM MA_Einstellung WHERE Schluessel like 'HP_%'");
                execute(daten, zeinstellungDao, mout);
                version = 38;
            } else if (version <= 38) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "MO_Messdiener";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Name", "D_STRING_50", false);
                dba.createTab1("Vorname", "D_STRING_50", true);
                dba.createTab1("Von", "D_DATE", false);
                dba.createTab1("Bis", "D_DATE", true);
                dba.createTab1("Adresse1", "D_STRING_50", true);
                dba.createTab1("Adresse2", "D_STRING_50", true);
                dba.createTab1("Adresse3", "D_STRING_50", true);
                dba.createTab1("Email", "D_STRING_40", true);
                dba.createTab1("Email2", "D_STRING_40", true);
                dba.createTab1("Telefon", "D_STRING_40", true);
                dba.createTab1("Telefon2", "D_STRING_40", true);
                dba.createTab1("Verfuegbarkeit", "D_MEMO", true);
                dba.createTab1("Dienste", "D_MEMO", true);
                dba.createTab1("Messdiener_Uid", "D_REPL_ID", true);
                dba.createTab1("Status", "D_STRING_10", true);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                tabelle = "MO_Gottesdienst";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Termin", "D_DATETIME", false);
                dba.createTab1("Name", "D_STRING_50", false);
                dba.createTab1("Ort", "D_STRING_50", false);
                dba.createTab1("Profil_Uid", "D_REPL_ID", true);
                dba.createTab1("Status", "D_STRING_10", true);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                tabelle = "MO_Profil";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Name", "D_STRING_50", false);
                dba.createTab1("Alle", "D_INTEGER", false);
                dba.createTab1("Dienste", "D_MEMO", true);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                tabelle = "MO_Einteilung";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Gottesdienst_Uid", "D_REPL_ID", false);
                dba.createTab1("Messdiener_Uid", "D_REPL_ID", false);
                dba.createTab1("Termin", "D_DATETIME", false);
                dba.createTab1("Dienst", "D_STRING_50", false);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 39;
            } else if (version <= 39) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Fragenkatalog";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Name", "D_STRING_50", false);
                dba.createTab1("Fragen", "D_MEMO", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 40;
            } else if (version <= 40) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "FZ_Buchstatus";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Buch_Uid", "D_REPL_ID", false);
                dba.addTab1("Ist_Besitz", "D_SWITCH", false);
                dba.addTab1("Lesedatum", "D_DATE", true);
                dba.addTab1a("Hoerdatum", "D_DATE", true, "NULL");
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1("Replikation_Uid", "D_REPL_ID", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Buch_Uid", "Mandant_Nr, Buch_Nr");
                dba.createTab3(mout, tabelle, "XRKFZ_Buchstatus", false, "Replikation_Uid, Mandant_Nr");
                execute(daten, zeinstellungDao, mout);
                version = 41;
            } else if (version <= 41) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "Byte_Daten";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Typ", "D_STRING_20", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Lfd_Nr", "D_INTEGER", false);
                dba.createTab1("Metadaten", "D_MEMO", true);
                dba.createTab1("Bytes", "D_BLOB", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Typ, Uid, Lfd_Nr");
                execute(daten, zeinstellungDao, mout);
                version = 42;
            } else if (version <= 42) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "WP_Wertpapier";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Bezeichnung", "D_STRING_50", false);
                dba.createTab1("Kuerzel", "D_STRING_10", false);
                dba.createTab1("Parameter", "D_MEMO", true);
                dba.createTab1("Datenquelle", "D_STRING_35", false);
                dba.createTab1("Status", "D_STRING_10", false);
                dba.createTab1("Relation_Uid", "D_REPL_ID", true);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                tabelle = "WP_Konfiguration";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Bezeichnung", "D_STRING_50", false);
                dba.createTab1("Parameter", "D_MEMO", false);
                dba.createTab1("Status", "D_STRING_10", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 43;
            } else if (version <= 43) {
                Vector<String> mout = new Vector<String>();
                mout.add(
                        "DELETE FROM MA_Einstellung WHERE Schluessel IN ('TEST_PRODUKTION', 'GEBURTSTAGSLISTE', 'GEBURTSTAGSTAGE'"
                                + ", 'ANWENDUNGS_TITEL', 'MANDANT_INIT', 'MANDANT_VERSION', 'STARTDIALOGE')");
                execute(daten, zeinstellungDao, mout);
                version = 44;
            } else if (version <= 44) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "HP_Behandlung";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Patient_Uid", "D_REPL_ID", false);
                dba.addTab1("Datum", "D_DATE", false);
                dba.addTab1("Dauer", "D_GELDBETRAG", false);
                dba.addTab1("Beschreibung", "D_STRING_50", false);
                dba.addTab1("Diagnose", "D_STRING_50", true);
                dba.addTab1("Betrag", "D_GELDBETRAG", false);
                dba.addTab1("Leistung_Uid", "D_REPL_ID", false);
                dba.addTab1("Rechnung_Uid", "D_REPL_ID", true);
                dba.addTab1("Status_Uid", "D_REPL_ID", false);
                dba.addTab1("Mittel", "D_STRING_50", true);
                dba.addTab1("Potenz", "D_STRING_10", true);
                dba.addTab1("Dosierung", "D_STRING_100", true);
                dba.addTab1("Verordnung", "D_STRING_255", true);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");

                tabelle = "HP_Behandlung_Leistung";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Behandlung_Uid", "D_REPL_ID", false);
                dba.createTab1("Leistung_Uid", "D_REPL_ID", false);
                dba.createTab1("Dauer", "D_GELDBETRAG", false);
                dba.createTab1("Parameter", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                dba.createTab3(mout, tabelle, "XRKHP_Behandlung_Leistung", false,
                        "Mandant_Nr, Behandlung_Uid, Leistung_Uid");

                tabelle = "HP_Leistungsgruppe";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Bezeichnung", "D_STRING_50", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                dba.createTab3(mout, tabelle, "XRKHP_Leistungsgruppe", false, "Mandant_Nr, Bezeichnung, Uid");
                execute(daten, zeinstellungDao, mout);

                int mandantNr = daten.getMandantNr();
                Connection con = ((DbContext) daten.getContext()).getCon();
                PreparedStatement stmt = null;
                ResultSet rs = null;
                String sql = "SELECT Mandant_Nr, Uid, Leistung_Uid, Dauer"
                        + " FROM HP_Behandlung ORDER BY Mandant_Nr, Uid";
                try {
                    stmt = con.prepareStatement(sql);
                    rs = stmt.executeQuery();
                    while (rs.next()) {
                        int mn = rs.getInt(1);
                        String buid = rs.getString(2);
                        String luid = rs.getString(3);
                        double d = rs.getDouble(4);
                        daten.setMandantNr(mn);
                        List<HpBehandlungLeistung> l = behleistRep.getBehandlungLeistungListe(daten, buid, luid);
                        if (l.size() <= 0) {
                            HpBehandlungLeistung b = new HpBehandlungLeistung();
                            b.setMandantNr(mn);
                            b.setUid(Global.getUID());
                            b.setBehandlungUid(buid);
                            b.setLeistungUid(luid);
                            b.setDauer(d);
                            b.machAngelegt(daten.getJetzt(), daten.getBenutzerId());
                            behleistRep.insert(daten, b);
                        }
                    }
                } catch (SQLException ex) {
                    throw new RuntimeException(ex);
                } finally {
                    daten.setMandantNr(mandantNr);
                    if (stmt != null) {
                        try {
                            stmt.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (rs != null) {
                        try {
                            rs.close();
                        } catch (SQLException e) {
                        }
                    }
                }

                sql = "SELECT Mandant_Nr, Patient_Uid, Datum, Notiz"
                        + " FROM HP_Anamnese ORDER BY Mandant_Nr, Patient_Uid, Datum";
                stmt = null;
                rs = null;
                try {
                    stmt = con.prepareStatement(sql);
                    rs = stmt.executeQuery();
                    while (rs.next()) {
                        int mn = rs.getInt(1);
                        String puid = rs.getString(2);
                        Date d = rs.getDate(3);
                        String n = rs.getString(4);
                        daten.setMandantNr(mn);
                        HpBehandlung b = behandlungRep.getNaechsteBehandlung(daten, puid, d.toLocalDate());
                        if (b == null) {
                            b = new HpBehandlung();
                            b.setUid(Global.getUID());
                            b.setMandantNr(mn);
                            b.setPatientUid(puid);
                            b.setDatum(d.toLocalDate());
                            b.setBeschreibung("");
                            b.setLeistungUid("");
                            b.setStatusUid("");
                            b.setNotiz(d.toLocalDate().toString() + " Anamnese:" + Constant.CRLF + n);
                            b.machAngelegt(daten.getJetzt(), daten.getBenutzerId());
                            behandlungRep.insert(daten, b);
                        } else {
                            HpBehandlungUpdate u = new HpBehandlungUpdate(b);
                            u.setNotiz(d.toLocalDate().toString() + " Anamnese:" + Constant.CRLF + n + Constant.CRLF + u
                                    .getNotiz());
                            u.machGeaendert(daten.getJetzt(), daten.getBenutzerId());
                            behandlungRep.update(daten, u);
                        }
                    }
                } catch (SQLException ex) {
                    throw new RuntimeException(ex);
                } finally {
                    daten.setMandantNr(mandantNr);
                    if (stmt != null) {
                        try {
                            stmt.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (rs != null) {
                        try {
                            rs.close();
                        } catch (SQLException e) {
                        }
                    }
                }
                mout.clear();
                mout.add("DELETE FROM HP_Anamnese");
                mout.add("DELETE FROM HP_Symptom");
                mout.add("DELETE FROM HP_Symptom_Anamnese");
                mout.add("DELETE FROM HP_Fragenkatalog");
                execute(daten, zeinstellungDao, mout);
                version = 45;
            } else if (version <= 45) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "WP_Anlage";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Wertpapier_Uid", "D_REPL_ID", false);
                dba.createTab1("Bezeichnung", "D_STRING_50", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                tabelle = "WP_Buchung";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Uid", "D_REPL_ID", false);
                dba.createTab1("Wertpapier_Uid", "D_REPL_ID", false);
                dba.createTab1("Anlage_Uid", "D_REPL_ID", false);
                dba.createTab1("Datum", "D_DATE", false);
                dba.createTab1("Zahlungsbetrag", "D_GELDBETRAG", false);
                dba.createTab1("Rabattbetrag", "D_GELDBETRAG", false);
                dba.createTab1("Anteile", "D_GELDBETRAG2", false);
                dba.createTab1("Zinsen", "D_GELDBETRAG", false);
                dba.createTab1("BText", "D_STRING_100", false);
                dba.createTab1("Notiz", "D_MEMO", true);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                tabelle = "WP_Stand";
                dba.createTab0();
                dba.createTab1("Mandant_Nr", "D_INTEGER", false);
                dba.createTab1("Wertpapier_Uid", "D_REPL_ID", false);
                dba.createTab1("Datum", "D_DATE", false);
                dba.createTab1("Stueckpreis", "D_GELDBETRAG", false);
                dba.createTab1("Angelegt_Von", "D_STRING_20", true);
                dba.createTab1("Angelegt_Am", "D_DATETIME", true);
                dba.createTab1("Geaendert_Von", "D_STRING_20", true);
                dba.createTab1("Geaendert_Am", "D_DATETIME", true);
                dba.createTab2(mout, tabelle, "Mandant_Nr, Wertpapier_Uid, Datum");
                execute(daten, zeinstellungDao, mout);
                version = 46;
            } else if (version <= 46) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "WP_Anlage";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Wertpapier_Uid", "D_REPL_ID", false);
                dba.addTab1("Bezeichnung", "D_STRING_50", false);
                dba.addTab1a("Parameter", "D_MEMO", true, "NULL");
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 47;
            } else if (version <= 47) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "VM_Mieter";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Wohnung_Uid", "D_REPL_ID", false);
                dba.addTab1("Name", "D_STRING_40", false);
                dba.addTab1("Vorname", "D_STRING_40", true);
                dba.addTab1("Anrede", "D_STRING_40", true);
                dba.addTab1("EinzugDatum", "D_DATE", true);
                dba.addTab1("AuszugDatum", "D_DATE", true);
                dba.addTab1a("Wohnung_Qm", "D_GELDBETRAG", false, "0");
                dba.addTab1a("Wohnung_Grundmiete", "D_GELDBETRAG", false, "0");
                dba.addTab1a("Wohnung_Kaution", "D_GELDBETRAG", false, "0");
                dba.addTab1a("Wohnung_Antenne", "D_GELDBETRAG", false, "0");
                dba.addTab1("Status", "D_INTEGER", false);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 48;
            } else if (version <= 48) {
                if (dbart.equals(DatenbankArt.HSQLDB)) {
                    Vector<String> mout = new Vector<String>();
                    List<String> tabliste = replService.getAlleTabellen(daten).getErgebnis();
                    for (String t : tabliste) {
                        // mout.add(Global.format("SET TABLE {0} TYPE MEMORY", t));
                        mout.add(Global.format("SET TABLE {0} TYPE CACHED", t));
                    }
                    execute(daten, zeinstellungDao, mout);
                }
                version = 49;
            } else if (version <= 49) {
                Vector<String> mout = new Vector<String>();
                mout.add("DROP TABLE HP_Anamnese");
                mout.add("DROP TABLE HP_Symptom");
                mout.add("DROP TABLE HP_Symptom_Anamnese");
                mout.add("DROP TABLE HP_Fragenkatalog");
                execute(daten, zeinstellungDao, mout);
                version = 50;
            } else if (version <= 50) {
                Vector<String> mout = new Vector<String>();
                mout.add(
                        "DELETE FROM HP_Behandlung_Leistung a WHERE NOT EXISTS (SELECT * FROM HP_Behandlung WHERE UID=a.Behandlung_UID)"
                                + " AND NOT EXISTS (SELECT * FROM HP_Leistungsgruppe WHERE UID=a.Behandlung_UID)");
                execute(daten, zeinstellungDao, mout);
                version = 51;
            } else if (version <= 51) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                // Codierung und Sortierung anpassen
                tabelle = "WP_Anlage";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Wertpapier_Uid", "D_REPL_ID", false);
                dba.addTab1("Bezeichnung", "D_STRING_50", false);
                dba.addTab1("Parameter", "D_MEMO", true);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 52;
            } else if (version <= 52) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "SB_Ereignis";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Person_Uid", "D_REPL_ID", false);
                dba.addTab1("Familie_Uid", "D_REPL_ID", false);
                dba.addTab1("Typ", "D_STRING_04", false);
                dba.addTab1("Tag1", "D_INTEGER", false);
                dba.addTab1("Monat1", "D_INTEGER", false);
                dba.addTab1("Jahr1", "D_INTEGER", false);
                dba.addTab1("Tag2", "D_INTEGER", false);
                dba.addTab1("Monat2", "D_INTEGER", false);
                dba.addTab1("Jahr2", "D_INTEGER", false);
                dba.addTab1("Datum_Typ", "D_STRING_04", false);
                dba.addTab1("Ort", "D_STRING_120", true);
                dba.addTab1("Bemerkung", "D_MEMO", true);
                dba.addTab1("Quelle_Uid", "D_REPL_ID", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab1("Replikation_Uid", "D_REPL_ID", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Person_Uid, Familie_Uid, Typ, Tag1, Monat1, Jahr1",
                        "Mandant_Nr, Nr_Typ, Nr, Typ, Tag1, Monat1, Jahr1");
                dba.createTab3(mout, tabelle, "XRKSB_Ereignis", false, "Replikation_Uid, Mandant_Nr");
                execute(daten, zeinstellungDao, mout);
                version = 53;
            } else if (version <= 53) {
                DbAnpassung dba = new DbAnpassung(dbart);
                Vector<String> mout = new Vector<String>();
                String tabelle = null;

                tabelle = "WP_Wertpapier";
                dba.addTab0();
                dba.addTab1("Mandant_Nr", "D_INTEGER", false);
                dba.addTab1("Uid", "D_REPL_ID", false);
                dba.addTab1("Bezeichnung", "D_STRING_50", false);
                dba.addTab1("Kuerzel", "D_STRING_20", false);
                dba.addTab1("Parameter", "D_MEMO", true);
                dba.addTab1("Datenquelle", "D_STRING_35", false);
                dba.addTab1("Status", "D_STRING_10", false);
                dba.addTab1("Relation_Uid", "D_REPL_ID", true);
                dba.addTab1("Notiz", "D_MEMO", true);
                dba.addTab1("Angelegt_Von", "D_STRING_20", true);
                dba.addTab1("Angelegt_Am", "D_DATETIME", true);
                dba.addTab1("Geaendert_Von", "D_STRING_20", true);
                dba.addTab1("Geaendert_Am", "D_DATETIME", true);
                dba.addTab2(mout, tabelle, "Mandant_Nr, Uid", "Mandant_Nr, Uid");
                execute(daten, zeinstellungDao, mout);
                version = 54;
            }
            if (version > versionAlt) {
                // log.error("Version " + version);
                ZeinstellungUpdate zU = new ZeinstellungUpdate(zeinstellung);
                zU.setWert(Global.intStr(version));
                zU.machGeaendert(daten.getJetzt(), daten.getBenutzerId());
                zeinstellungDao.update(daten, zU);
                versionAlt = version;
                // für nächstes Update
                zeinstellung.setWert(Global.intStr(version));
                zeinstellung.machGeaendert(daten.getJetzt(), daten.getBenutzerId());
            } else {
                weiter = false;
            }
            // if (einzeln) {
            // weiter = false;
            // }
        }
    }

    private void execute(ServiceDaten daten, IZeinstellungRep zeinstellungDao, Vector<String> mout) {

        for (String strSql : mout) {
            try {
                // System.out.println(strSql);
                zeinstellungDao.execute(daten, strSql);
            } catch (Exception ex) {
                if (!strSql.startsWith("DROP")) {
                    throw new RuntimeException(ex.getMessage());
                }
            }
        }
    }
}

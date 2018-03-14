package de.cwkuehl.jhh6.server.db;

import static de.cwkuehl.jhh6.api.global.Global.appendKomma;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;

import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;

public class DbAnpassung {

    /** String für Pause bei Jet-Engine. */
    public static String            JET_PAUSE         = "--pause";
    // /** Maximale Version einer Spalte in einer Tabelle. */
    // public static final int MAX_VERSION_BIS = 99;
    //
    // private static Logger log = Logger
    // .getLogger(DbAnpassung.class);
    // /** Datenbankart für aktuelle Datenbank. */
    // private DatenbankArt miDB = DatenbankArt.JET;

    /** Datenbankart für Skripterzeugung. */
    private DatenbankArt            miDBZiel          = DatenbankArt.JET;

    /** Liste für Spaltendefinition beim CREATE TABLE-Befehl. */
    private Vector<String>          mcFeldC           = null;
    /** Liste für Spaltenname. */
    private Vector<String>          mcFeld            = null;
    /** Liste für Spaltentyp. */
    private Vector<String>          mcTyp             = null;
    /** Liste für Merker, ob Spalte NULL sein darf. */
    private Vector<String>          mcNull            = null;
    /** Liste für Default-Wert der Spalte. */
    private Vector<String>          mcDef             = null;
    /** Liste für Merker, ob Spalte neu in der Tabelle ist. */
    private Vector<String>          mcNeu             = null;
    /** Alle benutzten Spaltentypen werden hier vorgehalten. */
    private HashMap<String, String> mhtTyp            = null;
    /** Benutzer- oder Schema-Name für das Anlegen von Tabellen. */
    private String                  mstrConBenutzer   = "";

    /** Besondere Spaltennamen werden am Anfang maskiert. */
    private static final String     JET_SQL_ANFANG    = "[";
    /** Besondere Spaltennamen werden am Ende maskiert. */
    private static final String     JET_SQL_ENDE      = "]";
    /** Besondere Spaltennamen werden maskiert. */
    private static final String     MYSQL_SQL_RAHMEN  = "`";
    /** Besondere Spaltennamen werden maskiert. */
    private static final String     HSQLDB_SQL_RAHMEN = "\"";

    /**
     * Standard-Konstruktor mit Initialisierung.
     */
    public DbAnpassung(DatenbankArt iDB) {
        this.miDBZiel = iDB;
    }

    // /**
    // * Anlegen oder Ändern einer Tabellen-Struktur in der Datenbank.
    // * @param strTab Tabellenname.
    // * @param bNeu True, wenn Tabelle auf jeden Fall angelegt und der Eintrag
    // in
    // * zTabelle nicht geändert werden soll.
    // * @param strBenutzer Benutzername.
    // * @param bSkript true, wenn Anpassungen als Skript-Zeilen geliefert
    // werden
    // * sollen.
    // * @return true wenn alles OK; sonst false.
    // * @throws JhhException falls keine Spalten definiert wurden.
    // */
    // private boolean makeTable(final String strTab, final boolean bNeu,
    // final String strBenutzer, final boolean bSkript) throws JhhException {
    // boolean bMakeTable = true;
    // if (false) {
    // createTab0();
    // createTab1("Hallo", "D_INTEGER", false);
    // createTab1("x", "D_STRING_50", false);
    // bMakeTable = createTab2(strTab, "Hallo");
    // } else if (true) {
    // // Struktur aus Tabellen lesen
    // int iTabNr = 0, iIndNr = 0, iVersion = 0, iVon = 0, iBis = 0;
    // boolean bAnpassen = false, bCreate = true, bSpalte = false;
    // String strPK, strPKAlt, strSpalte;
    // Ztabelle ztabelleSuche = new Ztabelle();
    // Ztabelle ztabelle = null;
    // Ztabelle[] ztabellen = null;
    //
    // ztabelleSuche.setName(strTab);
    // ztabellen = ztabelleDao.getListeSuche(ztabelleSuche);
    // if (Global.arrayLaenge(ztabellen) > 0) {
    // ztabelle = ztabellen[0];
    // iTabNr = ztabelle.getTabellenNr();
    // iVersion = ztabelle.getVersion() + 1;
    // }
    // if (iTabNr <= 0) {
    // throw new JhhException("Tabellenstruktur für " + Global.hk(strTab)
    // + " nicht gefunden!");
    // }
    // iVon = allgemeinDao.lookupInt(0, "MAX(Version_Von)", "zSpalte",
    // "Tabellen_Nr=" + iTabNr);
    // if (iVon >= iVersion) {
    // bAnpassen = true;
    // } else {
    // iBis = allgemeinDao.lookupInt(0, "MAX(Version_Bis)", "zSpalte",
    // "Tabellen_Nr=" + iTabNr + " AND Version_Bis<" + MAX_VERSION_BIS);
    // if (iBis >= iVersion) {
    // bAnpassen = true;
    // }
    // }
    // if (bNeu) {
    // iVersion = iBis;
    // if (iVersion < iVon) {
    // iVersion = iVon;
    // }
    // }
    // if (bNeu || iVon >= iVersion || iBis >= iVersion) {
    // bAnpassen = true;
    // }
    // if (bAnpassen) {
    // if (!bNeu
    // && allgemeinDao.lookupInt(0, "Count(*)", strTab, "", true) > 0) {
    // bCreate = false;
    // }
    // Zspalte zspalteSuche = new Zspalte();
    // Zspalte[] zspalten = null;
    //
    // zspalteSuche.setTabellenNr(iTabNr);
    // zspalteSuche.setVersionVon(iVersion);
    // zspalteSuche.setVersionBis(iVersion - 1);
    // zspalten = zspalteDao.getListeSuche(zspalteSuche);
    // if (bCreate) {
    // createTab0();
    // } else {
    // addTab0();
    // }
    // for (int i = 0; zspalten != null && i < zspalten.length; i++) {
    // bSpalte = true;
    // iBis = zspalten[i].getVersionBis();
    // if (iBis > iVersion && !Global.nes(zspalten[i].getName())
    // && !Global.nes(zspalten[i].getTyp())) {
    // if (bCreate) {
    // createTab1(zspalten[i].getName(), zspalten[i].getTyp(),
    // zspalten[i].getIstNull());
    // } else {
    // iVon = zspalten[i].getVersionVon();
    // if (iVon < iVersion) {
    // // Spalte ist schon in früherer Version vorhanden
    // addTab1(zspalten[i].getName(), zspalten[i].getTyp(),
    // zspalten[i].getIstNull());
    // } else if (iVon == iVersion) {
    // // Spalte ist erstmals dabei
    // addTab1a(zspalten[i].getName(), zspalten[i].getTyp(),
    // zspalten[i].getIstNull(), zspalten[i].getWert());
    // }
    // }
    // }
    // }
    // if (!bSpalte) {
    // throw new JhhException("Keine Spalten für " + Global.hk(strTab)
    // + " gefunden!");
    // }
    // strPK = "";
    // strPKAlt = "";
    // iIndNr = allgemeinDao.lookupInt(0, "Index_Nr", "zIndex", "Tabellen_Nr="
    // + iTabNr + " AND Ist_Primaer<>0");
    // if (iIndNr > 0) {
    // zspalteSuche.setTabellenNr(iTabNr);
    // zspalteSuche.setSpaltenNr(iIndNr);
    // zspalteSuche.setVersionVon(iVersion);
    // zspalteSuche.setVersionBis(iVersion + 1);
    // zspalten = zspalteDao.getListeIndex(zspalteSuche);
    // for (int i = 0; zspalten != null && i < zspalten.length; i++) {
    // iVon = zspalten[i].getVersionVon();
    // iBis = zspalten[i].getVersionBis();
    // strSpalte = zspalten[i].getName();
    // if (iVon < iVersion) {
    // // Spalte ist schon in früherer Version vorhanden.
    // if (!Global.nes(strPKAlt)) {
    // strPKAlt += ",";
    // }
    // strPKAlt += strSpalte;
    // }
    // if (iBis > iVersion) {
    // // Spalte ist noch immer dabei.
    // if (!Global.nes(strPK)) {
    // strPK += ",";
    // }
    // strPK += strSpalte;
    // }
    // }
    // }
    // if (bCreate) {
    // bMakeTable = createTab2(strTab, strPK);
    // } else {
    // bMakeTable = addTab2(strTab, strPK, strPKAlt);
    // }
    // if (bMakeTable && !bSkript && !bNeu) {
    // ZtabelleKey ztabelleKey = new ZtabelleKey();
    // Ztabelle ztabelle2 = null;
    // ztabelleKey.setTabellenNr(iTabNr);
    // ztabelle2 = ztabelleDao.get(ztabelleKey);
    // if (ztabelle2 == null) {
    // bMakeTable = false;
    // throw new JhhException("zTabelle-Datensatz fehlt!");
    // } else {
    // ztabelle2.setVersion(iVersion);
    // ztabelle2.machGeaendert(Global.holeAktZeit(), strBenutzer);
    // ztabelleDao.update(ztabelle2);
    // }
    // }
    // }
    // }
    // return bMakeTable;
    // }

    /**
     * Interne Initialisierung für CreateTab-Funktionen.
     */
    public void createTab0() {
        mcFeldC = init(mcFeldC);
    }

    /**
     * Definition einer Spalte für CREATE TABLE-Befehl.
     * @param strFeld Spaltenname.
     * @param strTyp Spaltentyp wird für aktuelle Datenbank übersetzt.
     * @param bNull True, wenn Spalte NULL sein darf.
     */
    public void createTab1(final String strFeld, final String strTyp, final boolean bNull) {

        String strNull = getNull(bNull);
        if ("TIMESTAMP".equals(strTyp) && miDBZiel == DatenbankArt.SQL65 && "".equals(strNull)) {
            strNull = "NULL";
        }
        mcFeldC.add(Global.anhaengen(Global.anhaengen(getColumn(miDBZiel, strFeld), " ", dbTyp(strTyp)), " ", strNull));
    }

    /**
     * Erzeugt eine Tabelle in der Datenbank mittels CREATE TABLE-Befehl mit Primärschlüssel.
     * @param strTabelle Tabellenname.
     * @param strIndex String mit Komma-getrennten Spaltenname des Primärindex.
     * @return True, wenn alles OK.
     */
    public boolean createTab2(Vector<String> mout, final String strTabelle, final String strIndex) {

        StringBuffer str1 = new StringBuffer();
        String strSql = null;
        String strF = null;
        boolean bTabCreate2 = false;
        boolean replId = false;
        boolean bMandantNr = false;

        for (Iterator<String> i = mcFeldC.iterator(); i.hasNext();) {
            strF = Global.objStr(i.next());
            if (str1.length() > 0) {
                str1.append(",");
            }
            str1.append(strF);
            if (strF.startsWith("Replikation_UID")) {
                replId = true;
            }
            if (strF.startsWith("Mandant_Nr")) {
                bMandantNr = true;
            }
        }
        execute(mout, dropTab(miDBZiel, strTabelle));
        String strPraefix = Global.iif(miDBZiel == DatenbankArt.JET || miDBZiel == DatenbankArt.MYSQL
                || miDBZiel == DatenbankArt.HSQLDB, "", mstrConBenutzer + ".");
        String strEnde = "";
        if (miDBZiel == DatenbankArt.MYSQL || miDBZiel == DatenbankArt.HSQLDB || miDBZiel == DatenbankArt.ORACLE) {
            strEnde = ";";
        } else if (miDBZiel == DatenbankArt.SQL70) {
            strEnde = Constant.CRLF + "GO";
        }
        if (miDBZiel == DatenbankArt.JET || miDBZiel == DatenbankArt.SQL70) {
            strSql = Global.format("CREATE TABLE {0} ({1}{2}){3}", strTabelle, str1, Global.iif(Global.nes(strIndex),
                    "", ", CONSTRAINT XPK" + strTabelle + " PRIMARY KEY (" + strIndex + ")"), strEnde);
        } else if (miDBZiel == DatenbankArt.SQL65) {
            strSql = Global.format("CREATE TABLE {0} ({1}){2}", strTabelle, str1, strEnde);
            if (!Global.nes(strIndex)) {
                execute(mout, strSql);
                strSql = Global.format("CREATE UNIQUE CLUSTERED INDEX XPK{0} ON {1}{0} ({2}){3}", strTabelle,
                        strPraefix, strIndex, strEnde);
            }
        } else if (miDBZiel == DatenbankArt.ORACLE) {
            strSql = Global.format("CREATE TABLE {0} (" + Constant.CRLF + "{1}" + Constant.CRLF + "){2}",
                    strTabelle, str1, strEnde);
            if (!Global.nes(strIndex)) {
                execute(mout, strSql);
                strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF
                        + " ADD (CONSTRAINT XPK{0} PRIMARY KEY ({1})){2}", strTabelle, strIndex, strEnde);
            }
        } else if (miDBZiel == DatenbankArt.MYSQL) {
            strSql = Global.format("CREATE TABLE {0} (" + Constant.CRLF + "{1}" + Constant.CRLF
                    + ") ENGINE=INNODB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci{2}", strTabelle, str1, strEnde);
            if (!Global.nes(strIndex)) {
                execute(mout, strSql);
                strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF
                        + " ADD (CONSTRAINT XPK{0} PRIMARY KEY ({1})){2}", strTabelle, strIndex, strEnde);
            }
        } else if (miDBZiel == DatenbankArt.HSQLDB) {
            strSql = Global.format("CREATE CACHED TABLE {0} (" + Constant.CRLF + "{1}" + Constant.CRLF + "){2}",
                    strTabelle, str1, strEnde);
            if (!Global.nes(strIndex)) {
                execute(mout, strSql);
                strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF
                        + " ADD CONSTRAINT XPK{0} PRIMARY KEY ({1}){2}", strTabelle, strIndex, strEnde);
            }
        } else {
            strSql = Global.format("CREATE TABLE {0} ({1}){2}{3}", strTabelle, str1, Global.iif(
                    miDBZiel == DatenbankArt.INFORMIX, " lock mode row", ""), strEnde);
            if (!Global.nes(strIndex)) {
                execute(mout, strSql);
                strSql = Global.format("CREATE UNIQUE INDEX XPK{0} ON {1}{0} ({2}){3}", strTabelle, strPraefix,
                        strIndex, strEnde);
            }
        }
        execute(mout, strSql);
        // Index über Replikation_UID erstellen
        if (replId) {
            String strReplIndex = "Replikation_UID";
            if (bMandantNr) {
                strReplIndex += ", Mandant_Nr";
            }
            strSql = Global.format("CREATE INDEX XRK{0} ON {1}{0} ({2}){3}", strTabelle, strPraefix, strReplIndex,
                    strEnde);
            execute(mout, strSql);
        }
        bTabCreate2 = true;
        return bTabCreate2;
    }

    /**
     * Erzeugt einen weiteren Index zu einer Tabelle.
     * @param strTabelle Tabellenname.
     * @param strIndex Name des neuen Index.
     * @param strSpalten String mit Komma-getrennten Spaltennamen des Index.
     * @return True, wenn alles OK.
     */
    public boolean createTab3(Vector<String> mout, final String strTabelle, final String strIndex,
            final boolean unique, final String strSpalten) {

        String strSql = null;
        boolean bTabCreate3 = false;

        // String strPraefix = Global.iif(miDBZiel == DatenbankArt.JET
        // || miDBZiel == DatenbankArt.MYSQL, "", mstrConBenutzer
        // + ".");
        String strEnde = "";
        if (miDBZiel == DatenbankArt.MYSQL || miDBZiel == DatenbankArt.HSQLDB || miDBZiel == DatenbankArt.ORACLE) {
            strEnde = ";";
        } else if (miDBZiel == DatenbankArt.SQL70) {
            strEnde = Constant.CRLF + "GO";
        }
        if (miDBZiel == DatenbankArt.JET) {
            if (unique) {
                // Jet unterstützt nur Unique-Constraints
                strSql = Global.format("ALTER TABLE {0} ADD CONSTRAINT {1}{2} ({3}){4}", strTabelle, strIndex,
                        " UNIQUE", strSpalten, strEnde);
            }
        } else if (miDBZiel == DatenbankArt.SQL70) {
            // strSql = Global.format(
            // "CREATE TABLE {0} ({1}{2}){3}",
            // strTabelle,
            // str1,
            // Global.iif(Global.nes(strIndex), "", ", CONSTRAINT XPK"
            // + strTabelle + " PRIMARY KEY (" + strIndex
            // + ")"), strEnde);
        } else if (miDBZiel == DatenbankArt.SQL65) {
            // execute(mout, strSql);
            // strSql = Global
            // .format("CREATE UNIQUE CLUSTERED INDEX XPK{0} ON {1}{0} ({2}){3}",
            // strTabelle, strPraefix, strIndex, strEnde);
        } else if (miDBZiel == DatenbankArt.ORACLE) {
            // execute(mout, strSql);
            // strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF
            // + " ADD (CONSTRAINT XPK{0} PRIMARY KEY ({1})){2}",
            // strTabelle, strIndex, strEnde);
        } else if (miDBZiel == DatenbankArt.MYSQL) {
            strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF + " ADD {1} {2}({3}){4}", strTabelle,
                    unique ? "UNIQUE" : "INDEX", strIndex, strSpalten, strEnde);
            // ALTER TABLE `JHH2`.`VM_Buchung_2` ADD INDEX `Schluessel` (
            // `Mandant_Nr` , `Schluessel` )
            // ALTER TABLE `JHH2`.`VM_Buchung_2` ADD UNIQUE `Schluessel` (
            // `Mandant_Nr` , `Schluessel` )
        } else if (miDBZiel == DatenbankArt.HSQLDB) {
            if (unique) {
                strSql = Global.format("ALTER TABLE {0}" + Constant.CRLF + " ADD CONSTRAINT {1} UNIQUE ({2}){3}",
                        strTabelle, strIndex, strSpalten, strEnde);
            }
        } else {
            // strSql = Global.format(
            // "CREATE UNIQUE INDEX XPK{0} ON {1}{0} ({2}){3}",
            // strTabelle, strPraefix, strIndex, strEnde);
        }
        if (!Global.nes(strSql)) {
            execute(mout, strSql);
        }
        bTabCreate3 = true;
        return bTabCreate3;
    }

    /**
     * Interne Initialisierung für AddTab-Funktionen.
     */
    public void addTab0() {

        mcFeld = init(mcFeld);
        mcTyp = init(mcTyp);
        mcNull = init(mcNull);
        mcDef = init(mcDef);
        mcNeu = init(mcNeu);
    }

    /**
     * Spaltendefinition für bestehende Spalte hinzufügen.
     * @param strFeld Spaltenname.
     * @param strTyp Spaltentyp wird für aktuelle Datenbank übersetzt.
     * @param bNull True, wenn Spalte NULL sein darf.
     */
    public void addTab1(final String strFeld, final String strTyp, final boolean bNull) {

        String strNull = getNull(bNull);
        mcFeld.add(getColumn(miDBZiel, strFeld));
        mcTyp.add(strTyp);
        mcNull.add(strNull);
        mcDef.add("");
        mcNeu.add("0");
    }

    /**
     * Spaltendefinition für neue Spalte hinzufügen.
     * @param strFeld Spaltenname.
     * @param strTyp Spaltentyp wird für aktuelle Datenbank übersetzt.
     * @param bNull True, wenn Spalte NULL sein darf.
     * @param strDef Default-Wert für Datenüberleitung.
     */
    public void addTab1a(final String strFeld, final String strTyp, final boolean bNull, final String strDef) {

        String strNull = getNull(bNull);
        if ("CInt".equals(strDef)) {
            // alte Spalten mit Transformation
            String strTrans = holeSqlCInt(strFeld, miDBZiel);
            mcFeld.add(strFeld);
            mcTyp.add(strTyp);
            mcNull.add(strNull);
            mcDef.add(strTrans);
            mcNeu.add("2");
        } else {
            mcFeld.add(strFeld);
            mcTyp.add(strTyp);
            mcNull.add(strNull);
            mcDef.add(strDef);
            mcNeu.add("1");
        }
    }

    /**
     * Hinzufügen von Spalten in eine Tabelle, die schon in der Datenbank besteht. Dabei bleiben mit folgendem Vorgehen
     * alle Datensätze erhalten: Create TMP_Tab, Kopieren, Create Tab, Kopieren.
     * @param strTabelle Tabellenname.
     * @param strIndex String mit Komma-getrennten Spaltenname des Primärindex.
     * @param strIndexAlt String mit Komma-getrennten Spaltenname des alten Primärindex.
     * @return True, wenn alles OK.
     */
    public boolean addTab2(Vector<String> mout, final String strTabelle, final String strIndex, final String strIndexAlt) {

        String strSql, strPraefix;
        StringBuffer str2 = new StringBuffer(); // alte und neue Spalten
        StringBuffer str3 = new StringBuffer(); // alte Spalten und neue Werte
        int i = 0;
        Vector<String> cFeldTyp = null;
        boolean bTabAdd2 = false;
        // boolean bNeu = true;
        cFeldTyp = init(cFeldTyp);
        strPraefix = Global.iif(
                miDBZiel == DatenbankArt.JET || miDBZiel == DatenbankArt.MYSQL || miDBZiel == DatenbankArt.HSQLDB, "",
                mstrConBenutzer + ".").toString();
        // Temporäre Tabelle erzeugen
        createTab0();
        for (i = 0; i < mcFeld.size(); i++) {
            createTab1(Global.objStr(mcFeld.get(i)), Global.objStr(mcTyp.get(i)), !"NOT NULL".equals(mcNull.get(i)));
        }
        createTab2(mout, tmp(strTabelle), strIndex);
        if (miDBZiel == DatenbankArt.JET) {
            execute(mout, JET_PAUSE);
        }
        for (i = 0; i < mcFeld.size(); i++) {
            if (Global.strLng(mcNeu.get(i)) == 0) {
                appendKomma(str2);
                str2.append(mcFeld.get(i));
                appendKomma(str3);
                str3.append(mcFeld.get(i));
            } else if (Global.strLng(mcNeu.get(i)) == 1) {
                if (!(("NULL".equals(mcDef.get(i)) && miDBZiel == DatenbankArt.INFORMIX) || ("TIMESTAMP".equals(mcTyp
                        .get(i)) && miDBZiel == DatenbankArt.SQL65))) {
                    appendKomma(str2);
                    str2.append(mcFeld.get(i));
                    appendKomma(str3);
                    str3.append(mcDef.get(i));
                }
            } else {
                appendKomma(str2);
                str2.append(mcFeld.get(i));
                appendKomma(str3);
                str3.append(mcDef.get(i));
            }
        }
        if (true) { // bKopieren
            // Temporäre Tabelle aus Tabelle füllen
            strSql = Global.format("INSERT INTO {0}{1} ({2}) SELECT {3} FROM {0}{4}{5}", strPraefix, tmp(strTabelle),
                    str2, str3, strTabelle, Global.iif(miDBZiel == DatenbankArt.JET, " ORDER BY " + strIndexAlt, ""));
            execute(mout, strSql);
        }
        // Tabelle neu erzeugen
        createTab0();
        for (i = 0; i < mcFeld.size(); i++) {
            // if (Global.strLng(mcNeu.get(i)) == 0
            // || (Global.strLng(mcNeu.get(i)) != 0 && bNeu)) {
            createTab1(Global.objStr(mcFeld.get(i)), Global.objStr(mcTyp.get(i)), !"NOT NULL".equals(mcNull.get(i)));
            // }
        }
        createTab2(mout, strTabelle, strIndex);
        if (miDBZiel == DatenbankArt.JET) {
            execute(mout, JET_PAUSE);
        }
        if (true) { // bKopieren
            // Temporäre Tabelle in Tabelle kopieren
            strSql = Global.format("INSERT INTO {0}{1} ({2}) SELECT {3} FROM {0}{4}", strPraefix, strTabelle, str2,
                    str2, tmp(strTabelle));
            execute(mout, strSql);
        }
        // Temporäre Tabelle löschen
        execute(mout, dropTab(miDBZiel, tmp(strTabelle)));
        bTabAdd2 = true;
        return bTabAdd2;
    }

    /**
     * Neuanlegen oder Leeren eines Vectors.
     * @param columns Zu leerender Vector.
     * @return Evtl. neu angelegter Vector.
     */
    private Vector<String> init(final Vector<String> columns) {

        Vector<String> col = columns;
        if (col == null) {
            col = new Vector<String>();
        }
        col.clear();
        return col;
    }

    /**
     * Liefert NULL-Definition für CREATE TABLE-Befehl.
     * @param bNull True, wenn Spalte NULL sein darf.
     * @return "" oder "NOT NULL".
     */
    private String getNull(final boolean bNull) {

        if (!bNull) {
            return "NOT NULL";
        }
        return "";
    }

    /**
     * Übersetzung eines Spaltentyps vom SQL Server in andere Datenbanken.
     * @param strTyp Spaltentyp vom SQL Server.
     * @return Spaltentyp in aktueller Ziel-Datenbank.
     */
    private String dbTyp(final String strTyp) {

        String strDBTyp = null;
        if (miDBZiel == DatenbankArt.SQL65 || miDBZiel == DatenbankArt.SQL70) {
            strDBTyp = strTyp;
        } else {
            if (mhtTyp == null) {
                mhtTyp = new HashMap<String, String>();
                String db = DatenbankArt.JET.symbol() + "#";
                mhtTyp.put(db + "D_DATE", "date");
                mhtTyp.put(db + "D_DATETIME", "datetime");
                mhtTyp.put(db + "D_GELDBETRAG", "currency");
                mhtTyp.put(db + "D_GELDBETRAG2", "double");
                mhtTyp.put(db + "D_INTEGER", "int");
                mhtTyp.put(db + "D_LONG", "long");
                mhtTyp.put(db + "D_MEMO", "memo");
                mhtTyp.put(db + "D_BLOB", "xxx");
                mhtTyp.put(db + "D_REPL_ID", "varchar(35)");
                mhtTyp.put(db + "D_STRING_01", "varchar(1)");
                mhtTyp.put(db + "D_STRING_02", "varchar(2)");
                mhtTyp.put(db + "D_STRING_03", "varchar(3)");
                mhtTyp.put(db + "D_STRING_04", "varchar(4)");
                mhtTyp.put(db + "D_STRING_05", "varchar(5)");
                mhtTyp.put(db + "D_STRING_10", "varchar(10)");
                mhtTyp.put(db + "D_STRING_20", "varchar(20)");
                mhtTyp.put(db + "D_STRING_35", "varchar(35)");
                mhtTyp.put(db + "D_STRING_40", "varchar(40)");
                mhtTyp.put(db + "D_STRING_50", "varchar(50)");
                mhtTyp.put(db + "D_STRING_100", "varchar(100)");
                mhtTyp.put(db + "D_STRING_120", "varchar(120)");
                mhtTyp.put(db + "D_STRING_255", "varchar(255)");
                mhtTyp.put(db + "D_SWITCH", "bit");
                db = DatenbankArt.MYSQL.symbol() + "#";
                mhtTyp.put(db + "D_DATE", "date");
                mhtTyp.put(db + "D_DATETIME", "datetime");
                mhtTyp.put(db + "D_GELDBETRAG", "double(21,4)");
                mhtTyp.put(db + "D_GELDBETRAG2", "double(21,6)");
                mhtTyp.put(db + "D_INTEGER", "int");
                mhtTyp.put(db + "D_LONG", "bigint");
                mhtTyp.put(db + "D_MEMO", "longtext");
                mhtTyp.put(db + "D_BLOB", "longblob");
                mhtTyp.put(db + "D_REPL_ID", "varchar(35)");
                mhtTyp.put(db + "D_STRING_01", "varchar(1)");
                mhtTyp.put(db + "D_STRING_02", "varchar(2)");
                mhtTyp.put(db + "D_STRING_03", "varchar(3)");
                mhtTyp.put(db + "D_STRING_04", "varchar(4)");
                mhtTyp.put(db + "D_STRING_05", "varchar(5)");
                mhtTyp.put(db + "D_STRING_10", "varchar(10)");
                mhtTyp.put(db + "D_STRING_20", "varchar(20)");
                mhtTyp.put(db + "D_STRING_35", "varchar(35)");
                mhtTyp.put(db + "D_STRING_40", "varchar(40)");
                mhtTyp.put(db + "D_STRING_50", "varchar(50)");
                mhtTyp.put(db + "D_STRING_100", "varchar(100)");
                mhtTyp.put(db + "D_STRING_120", "varchar(120)");
                mhtTyp.put(db + "D_STRING_255", "varchar(255)");
                mhtTyp.put(db + "D_SWITCH", "bit");
                db = DatenbankArt.HSQLDB.symbol() + "#";
                mhtTyp.put(db + "D_DATE", "date");
                mhtTyp.put(db + "D_DATETIME", "datetime");
                mhtTyp.put(db + "D_GELDBETRAG", "decimal(21,4)");
                mhtTyp.put(db + "D_GELDBETRAG2", "decimal(21,6)");
                mhtTyp.put(db + "D_INTEGER", "int");
                mhtTyp.put(db + "D_LONG", "bigint");
                mhtTyp.put(db + "D_MEMO", "varchar(1M)"); // clob // COLLATE SQL_TEXT_UCC
                mhtTyp.put(db + "D_BLOB", "blob");
                mhtTyp.put(db + "D_REPL_ID", "varchar(35)");
                mhtTyp.put(db + "D_STRING_01", "varchar(1) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_02", "varchar(2) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_03", "varchar(3) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_04", "varchar(4) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_05", "varchar(5) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_10", "varchar(10) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_20", "varchar(20) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_35", "varchar(35) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_40", "varchar(40) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_50", "varchar(50) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_100", "varchar(100) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_120", "varchar(120) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_STRING_255", "varchar(255) COLLATE SQL_TEXT_UCC");
                mhtTyp.put(db + "D_SWITCH", "boolean");
            }
            strDBTyp = mhtTyp.get(miDBZiel.symbol() + "#" + strTyp);
        }
        if (Global.nes(strDBTyp)) {
            strDBTyp = "Data type " + strTyp + " is missing.";
        }
        return strDBTyp;
    }

    /**
     * Liefert Tabellenname für temporäre Tabelle.
     * @param strTab Tabellenname.
     * @return Tabellenname für temporäre Tabelle.
     */
    private String tmp(final String strTab) {
        return "TMP_" + strTab;
    }

    /**
     * Ausführung eines SQL-Befehls oder Schreiben des Befehls in ein Skript.
     * @param strSql SQL-Befehl.
     */
    private void execute(Vector<String> mout, final String strSql) {
        mout.add(strSql + Constant.CRLF);
    }

    // /**
    // * Erzeugt ein Datenbank-Skript mit INSERT-Befehlen, die den aktuellen
    // Inhalt
    // * der Tabelle widerspiegeln.
    // * @param mdb Datenbank-Instanz.
    // * @param strTab Tabellenname.
    // * @param strW WHERE-Klausel.
    // * @param revision Sollen die Revisionsspalten (letzte 4 Spalten:
    // * Angelegt_Von, ...) ausgegeben werden?.
    // * @return true.
    // * @throws JhhException in unerwarteten Fehlerfalle.
    // */
    // private boolean machSkriptTabelle(final IRemoteDb mdb, final String
    // strTab,
    // final String strW, boolean revision) throws JhhException {
    // IJdbcLeser r = null;
    // String strSql = null;
    // String strTyp = "";
    // String strEnde = Constant.CRLF;
    // StringBuffer str1 = new StringBuffer(), str2 = new StringBuffer();
    // int i = 0, anz = 0;
    // Object wert = null;
    // String strO = null;
    //
    // strO = RemoteDb.getPkOrder(zspalteDao, ztabelleDao, strTab);
    // r = JdbcFactory.getInstance().getLeserOrder(mdb, 0, "*", strTab, strW,
    // strO);
    // try {
    // if (miDBZiel == DatenbankArt.MYSQL) {
    // strEnde = ";" + Constant.CRLF;
    // } else if (miDBZiel == DatenbankArt.SQL70) {
    // strEnde = Constant.CRLF + "GO" + Constant.CRLF;
    // }
    // anz = r.getAnzahlSpalten();
    // if (!revision && anz > 4) {
    // anz -= 4;
    // }
    // while (r.read()) {
    // str1.setLength(0);
    // str2.setLength(0);
    // for (i = 0; i < anz; i++) {
    // appendKommaLeer(str1);
    // str1.append(DaoBase.getColumn(miDBZiel, r.getName(i + 1)));
    // appendKommaLeer(str2);
    // wert = r.get(i + 1);
    // if (wert == null) {
    // str2.append("NULL");
    // } else {
    // strTyp = wert.getClass().getName();
    // if (strTyp.equals("java.lang.Integer")
    // || strTyp.equals("java.lang.Long")
    // || strTyp.equals("java.lang.Double")
    // || strTyp.equals("java.math.BigDecimal")) {
    // // BigDecimal: Jet, Tabelle FZ_Fahrradstand
    // str2.append(wert);
    // // } else if (strTyp.equals("L")) {
    // // str2.append(wert); // 15.01.10 WK: unbekanter Typ L
    // } else if (strTyp.equals("java.sql.Date")
    // || strTyp.equals("java.sql.Timestamp")) {
    // str2.append(DaoBase.getSqlDatumZeitString(miDBZiel, (Global
    // .objDat(wert, true))));
    // } else if (strTyp.equals("java.lang.String")) {
    // str2.append(Global.hk(wert));
    // } else if (strTyp.equals("[B")) {
    // str2.append(Global.iif(Global.objBool(wert), "1", "0"));
    // } else if (strTyp.equals("java.lang.Boolean")) {
    // // Tabelle FZ_Buchstatus
    // str2
    // .append(Global.iif(((Boolean) wert).booleanValue(), "1", "0"));
    // } else {
    // throw new JhhException("machSkriptTabelle: Data type " + strTyp + " is missing.");
    // }
    // }
    // }
    // strSql = Global.format("INSERT INTO {0}({1}) VALUES ({2}){3}", strTab,
    // str1, str2, strEnde);
    // if (miDB != miDBZiel && strTab.equals("zEinstellung")) {
    // String suche = Global.hk(Constant.EINST_DATENBANK) + ", "
    // + Global.hk(miDB.symbol());
    // if (strSql.indexOf(suche) >= 0) {
    // strSql = strSql.replace(suche, Global.hk(Constant.EINST_DATENBANK) +
    // ", "
    // + Global.hk(miDBZiel.symbol()));
    // }
    // }
    // mout.add(strSql);
    // }
    // } finally {
    // r.close();
    // }
    // return true;
    // }
    //
    // /**
    // * Vollzieht die Datenbank-Anpassungen gemäß den Tabellen-Definitionen.
    // Falls
    // * ein Dateiname angegeben wird, wird nur ein Skript mit den notwendigen
    // * SQL-Befehlen erzeugt.
    // * @param bAuchBenutzerTabellen True, wenn alle Tabellen genommen werden
    // * sollen; False, wenn nur die internen Tabellen beginnend mit z
    // * genommen werden.
    // * @param bNeu True, wenn Tabellen auf jeden Fall angelegt und der Eintrag
    // in
    // * zTabelle nicht geändert werden soll.
    // * @param bSkript true, wenn Anpassungen als Skript-Zeilen geliefert
    // werden
    // * sollen.
    // * @param dbArt Datenbankart als String.
    // * @param DbName Datenbankname.
    // * @param strBenutzer Benutzername.
    // * @return String-Array mit Skript-Zeilen oder null.
    // * @throws JhhException in unerwarteten Fehlerfalle.
    // */
    // public String[] makeDatabase(final boolean bAuchBenutzerTabellen,
    // final boolean bNeu, final boolean bSkript, final String dbArt,
    // final String DbName, final String strBenutzer) throws JhhException {
    // Ztabelle tabVo = new Ztabelle();
    // Ztabelle[] liste = null;
    //
    // try {
    // miDBZiel = DatenbankArt.KEINE;
    // if (mhtTyp != null) {
    // mhtTyp.clear();
    // }
    // if (bSkript) {
    // if (Global.excelNes(DbName)) {
    // throw new JhhException("Der Datenbank-Name darf nicht leer sein!");
    // }
    // if (!Global.excelNes(dbArt)) {
    // miDBZiel = DatenbankArt.wertVon(dbArt);
    // }
    // }
    // if (miDBZiel == DatenbankArt.KEINE) {
    // miDBZiel = allgemeinDao.getDbArt();
    // }
    // if (bSkript) {
    // // Skript für andere Datenbank
    // // miDBZiel = mdb.holeDBTyp();
    // // miDBZiel = DatenbankArt.JET;
    // // miDBZiel = DatenbankArt.ORACLE;
    // // miDBZiel = DatenbankArt.MYSQL;
    // // miDBZiel = DatenbankArt.SQL70;
    // mout = new Vector<String>();
    // mout.add("-- Datenbank-System: " + miDBZiel.symbol() + Constant.CRLF);
    // if (miDBZiel == DatenbankArt.MYSQL) {
    // mout.add("CREATE DATABASE IF NOT EXISTS " + DbName + ";"
    // + Constant.CRLF);
    // mout.add("USE " + DbName + ";" + Constant.CRLF);
    // } else if (miDBZiel == DatenbankArt.SQL70) {
    // mout.add("USE " + DbName + Constant.CRLF);
    // mout.add("GO" + Constant.CRLF);
    // Ztyp[] typen = ztypDao.getListe();
    // String btyp = null;
    // for (int i = 0; typen != null && i < typen.length; i++) {
    // btyp = null;
    // if (typen[i].getTypName().startsWith("D_STRING_")) {
    // btyp = "'nvarchar(" + typen[i].getTypName().substring(9) + ")'";
    // } else if (typen[i].getTypName().startsWith("D_INTEGER")) {
    // btyp = "int";
    // } else if (typen[i].getTypName().startsWith("D_LONG")) {
    // btyp = "bigint";
    // } else if (typen[i].getTypName().startsWith("D_DATE")) {
    // btyp = "datetime";
    // } else if (typen[i].getTypName().startsWith("D_GELDBETRAG")) {
    // btyp = "money";
    // } else if (typen[i].getTypName().startsWith("D_SWITCH")) {
    // btyp = "bit";
    // } else if (typen[i].getTypName().startsWith("D_REPL_ID")) {
    // btyp = "'nvarchar(35)'"; // "uniqueidentifier";
    // } else if (typen[i].getTypName().startsWith("D_MEMO")) {
    // btyp = "ntext";
    // }
    // if (!Global.nes(btyp)) {
    // mout.add("EXEC sp_droptype " + typen[i].getTypName()
    // + Constant.CRLF);
    // mout.add("GO" + Constant.CRLF);
    // mout.add("EXEC sp_addtype " + typen[i].getTypName() + ", " + btyp
    // + ", 'NULL'" + Constant.CRLF);
    // mout.add("GO" + Constant.CRLF);
    // }
    // // EXEC sp_addtype birthday, datetime, 'NULL';
    // }
    // }
    // } else {
    // mout = null;
    // }
    // if (!bAuchBenutzerTabellen) {
    // // strSql = "Art<=1";
    // tabVo.setArt(1);
    // }
    // liste = ztabelleDao.getListeSuche(tabVo);
    // for (int i = 0; liste != null && i < liste.length; i++) {
    // if (!makeTable(liste[i].getName(), bNeu, strBenutzer, bSkript)) {
    // throw new JhhException("Fehler bei makeTable " + liste[i].getName()
    // + "!");
    // }
    // }
    // if (bSkript && miDBZiel == DatenbankArt.MYSQL) {
    // mout.add("--REVOKE ALL PRIVILEGES ON " + DbName + ".* FROM WebHH1;"
    // + Constant.CRLF);
    // mout.add("GRANT ALL PRIVILEGES ON " + DbName + ".*"
    // + " TO WebHH1 IDENTIFIED BY 'wk1111'" + " WITH GRANT OPTION;"
    // + Constant.CRLF);
    // mout.add("FLUSH PRIVILEGES;" + Constant.CRLF);
    // }
    // } catch (Exception ex) {
    // log.error("makeDatabase", ex);
    // throw Global.getJhhException("makeDatabase", ex);
    // } finally {}
    // if (bSkript) {
    // return mout.toArray(new String[mout.size()]);
    // }
    // return null;
    // }
    //
    // /**
    // * Erzeugen eines Datenbank-Skripts.
    // * @param strTab Tabellenname, wenn nur der Inhalt dieser Tabelle erzeugt
    // * wird.
    // * @param strW WHERE-Klausel.
    // * @param bAuchBenutzerTabellen True, wenn alle Tabellen genommen werden
    // * sollen; False, wenn nur die internen Tabellen beginnend mit z
    // * genommen werden.
    // * @param dbArt Datenbankart als String.
    // * @param revision Sollen die Revisionsspalten (letzte 4 Spalten:
    // * Angelegt_Von, ...) ausgegeben werden?.
    // * @return Skript-Zeilen als String-Array.
    // * @throws JhhException in unerwarteten Fehlerfalle.
    // */
    // public String[] machSkript(final String strTab, final String strW,
    // final boolean bAuchBenutzerTabellen, final String dbArt, boolean
    // revision)
    // throws JhhException {
    // Ztabelle tabVo = new Ztabelle();
    // Ztabelle[] liste = null;
    // String strT = "unbekannt";
    // IRemoteDb mdb = null;
    //
    // try {
    // miDBZiel = DatenbankArt.KEINE;
    // if (!Global.excelNes(dbArt)) {
    // miDBZiel = DatenbankArt.wertVon(dbArt);
    // }
    // // Skript für andere Datenbank
    // // miDBZiel = mdb.holeDBTyp();
    // // miDBZiel = DatenbankArt.JET;
    // // miDBZiel = Constant.DBL_ORACLE;
    // // miDBZiel = Constant.DBL_MYSQL;
    // // miDBZiel = DatenbankArt.SQL70;
    // mout = new Vector<String>();
    // if (miDBZiel == DatenbankArt.KEINE) {
    // miDBZiel = allgemeinDao.getDbArt();
    // }
    // mdb = new RemoteDb(allgemeinDao.getDataSource());
    // if (!Global.nes(strTab)) {
    // // strO = FactoryVo.holeOrder(strTab);
    // strT = strTab;
    // machSkriptTabelle(mdb, strTab, strW, revision);
    // } else {
    // if (!bAuchBenutzerTabellen) {
    // // strSql = "Art<=1";
    // tabVo.setArt(1);
    // }
    // liste = ztabelleDao.getListeSuche(tabVo);
    // for (int i = 0; liste != null && i < liste.length; i++) {
    // strT = liste[i].getName();
    // if (false) {
    // int anz = allgemeinDao.countMandantTabelle(0, strT);
    // mout.add("Tabelle " + strT + ": " + anz + " Datensätze"
    // + Constant.CRLF);
    // } else {
    // machSkriptTabelle(mdb, strT, "", revision);
    // }
    // }
    // }
    // } catch (Exception ex) {
    // log.error("machSkript", ex);
    // throw Global.getJhhException("DbAnpassung.machSkript (Tabelle " + strT
    // + ")", ex);
    // }
    // return mout.toArray(new String[mout.size()]);
    // }

    /**
     * Liefert DROP TABLE-Befehl für eine Tabelle.
     * @param miDBZiel DatenbankArt.
     * @param strTabelle Tabellenname.
     * @return DROP TABLE-Befehlt für eine Tabelle.
     */
    public static String dropTab(final DatenbankArt miDBZiel, final String strTabelle) {

        StringBuffer strSql = new StringBuffer("DROP TABLE ");
        if (miDBZiel == DatenbankArt.MYSQL) {
            strSql.append("IF EXISTS ");
        }
        strSql.append(strTabelle);
        if (miDBZiel == DatenbankArt.HSQLDB) {
            strSql.append(" IF EXISTS");
        }
        if (miDBZiel == DatenbankArt.ORACLE) {
            strSql.append(" CASCADE CONSTRAINTS");
        }
        if (miDBZiel == DatenbankArt.MYSQL || miDBZiel == DatenbankArt.HSQLDB) {
            strSql.append(";");
        } else if (miDBZiel == DatenbankArt.SQL70) {
            strSql.append(Constant.CRLF).append("GO");
        }
        return strSql.toString();
    }

    /**
     * Liefert Spaltenname für SQL-Befehl. Besondere Spaltennamen werden bei Jet-Engine in eckige Klammern eingerahmt.
     * @param dbArt DatenbankArt.
     * @param strColumn Spaltenname.
     * @return Evtl. angepasster Spaltenname.
     */
    private static String getColumn(final DatenbankArt dbArt, final String strColumn) {

        if (strColumn == null) {
            return null;
        }
        String strFeld = strColumn;
        if (strFeld.equalsIgnoreCase(DatenbankArt.JET.symbol())) {
            if (dbArt == DatenbankArt.MYSQL) {
                strFeld = MYSQL_SQL_RAHMEN + strFeld + MYSQL_SQL_RAHMEN;
            } else if (dbArt == DatenbankArt.HSQLDB) {
                strFeld = HSQLDB_SQL_RAHMEN + strFeld + HSQLDB_SQL_RAHMEN;
            } else {
                strFeld = JET_SQL_ANFANG + strFeld + JET_SQL_ENDE;
            }
        }
        return strFeld;
    }

    /**
     * Liefert Konvertierungsfunktion nach Datenbankart.
     * @param strFeld Zu konvertierender Wert.
     * @param miDB Datenbankart.
     * @return Wert mit Konvertierungsfunktion als String.
     */
    private static String holeSqlCInt(final String strFeld, final DatenbankArt miDB) {

        String strTrans = null;
        if (miDB == DatenbankArt.JET) {
            strTrans = "CInt(" + strFeld + ")";
        } else if (miDB == DatenbankArt.SQL65) {
            strTrans = "CONVERT(INT," + strFeld + ")";
        } else if (miDB == DatenbankArt.SQL70) {
            strTrans = "CONVERT(INT," + strFeld + ")";
        } else if (miDB == DatenbankArt.ORACLE) {
            strTrans = "TO_NUMBER(" + strFeld + ")";
        } else if (miDB == DatenbankArt.INFORMIX) {
            strTrans = "" + strFeld + ""; // automatische Konvertierung
        } else if (miDB == DatenbankArt.MYSQL) {
            strTrans = "CONVERT(" + strFeld + ",SIGNED)";
        } else if (miDB == DatenbankArt.HSQLDB) {
            strTrans = "CAST(" + strFeld + " AS INTEGER)";
        } else {
            strTrans = "Fehler";
        }
        return strTrans;
    }

}

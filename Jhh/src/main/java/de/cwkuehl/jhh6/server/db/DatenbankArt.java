/*
 * Erstellt am 02.08.2006 Version 1.0
 */
package de.cwkuehl.jhh6.server.db;

/**
 * Aufzählung von Datenbankarten.
 * @author Wolfgang
 */
public enum DatenbankArt {

    /** Keine Art. */
    KEINE(0, "Keine"),
    /** Jet-Engine. */
    JET(DatenbankArt.DBL_JET, DatenbankArt.DBA_JET),
    /** SQL Server 6.5. */
    SQL65(DatenbankArt.DBL_SQLSERVER, DatenbankArt.DBA_SQL65),
    /** SQL Server ab 7.0. */
    SQL70(DatenbankArt.DBL_SQLSERVER70, DatenbankArt.DBA_SQL70),
    /** Oracle. */
    ORACLE(DatenbankArt.DBL_ORACLE, DatenbankArt.DBA_ORACLE),
    /** Informix. */
    INFORMIX(DatenbankArt.DBL_INFORMIX, DatenbankArt.DBA_INFORMIX),
    /** AS/400. */
    AS400(DatenbankArt.DBL_AS400, DatenbankArt.DBA_AS400),
    /** MySQL. */
    MYSQL(DatenbankArt.DBL_MYSQL, DatenbankArt.DBA_MYSQL),
    /** HSQLDB. */
    HSQLDB(DatenbankArt.DBL_HSQLDB, DatenbankArt.DBA_HSQLDB);

    /** Wert als String. */
    private final int           wert;
    /** Symbol für Darstellung. */
    private final String        symbol;

    /** Datenbankart: Jet-Engine. */
    private static final int    DBL_JET         = 1;
    /** Datenbankart: Jet-Engine. */
    private static final String DBA_JET         = "Jet-Engine";
    /** Datenbankart: SQL Server 6.5. */
    private static final int    DBL_SQLSERVER   = 2;
    /** Datenbankart: SQL Server 6.5. */
    private static final String DBA_SQL65       = "SQL-Server";
    /** Datenbankart: Oracle. */
    private static final int    DBL_ORACLE      = 3;
    /** Datenbankart: Oracle. */
    private static final String DBA_ORACLE      = "ORACLE";
    /** Datenbankart: DB2/400. */
    private static final int    DBL_AS400       = 4;
    /** Datenbankart: DB2/400. */
    private static final String DBA_AS400       = "DB2_400";
    /** Datenbankart: Informix. */
    private static final int    DBL_INFORMIX    = 5;
    /** Datenbankart: Informix. */
    private static final String DBA_INFORMIX    = "Informix";
    /** Datenbankart: SQL Server 7.0. */
    private static final int    DBL_SQLSERVER70 = 6;
    /** Datenbankart: SQL Server 7.0. */
    private static final String DBA_SQL70       = "SQL-Server7";
    /** Datenbankart: MySQL. */
    private static final int    DBL_MYSQL       = 7;
    /** Datenbankart: MySQL. */
    private static final String DBA_MYSQL       = "MySQL";
    /** Datenbankart: HSQLDB. */
    private static final int    DBL_HSQLDB      = 8;
    /** Datenbankart: HSQLDB. */
    private static final String DBA_HSQLDB      = "HSQLDB";

    /**
     * Konstruktor mit Initialisierung.
     * @param pWert int-Wert.
     * @param pSymbol String-Wert.
     */
    private DatenbankArt(final int pWert, final String pSymbol) {
        wert = pWert;
        symbol = pSymbol;
    }

    /**
     * Liefert den int-Wert der Datenbankart.
     * @return int-Wert.
     */
    public int wert() {
        return wert;
    }

    /**
     * Liefert das String-Symbol der Datenbankart.
     * @return String-Symbol.
     */
    public String symbol() {
        return symbol;
    }

    /**
     * Liefert DatenbankArt zu passendem String-Symbol.
     * @param pSymbol String-Wert.
     * @return DatenbankArt zu passendem String-Symbol.
     */
    public static DatenbankArt wertVon(final String pSymbol) {
        for (DatenbankArt dbArt : DatenbankArt.values()) {
            if (dbArt.symbol.equalsIgnoreCase(pSymbol)) {
                return dbArt;
            }
        }
        return KEINE;
    }
}

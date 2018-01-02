package de.cwkuehl.jhh6.api.global

/**
 * Zentrale Klasse für Konstanten wird nicht instanziiert.
 * <p>
 * Erstellt am 17.08.2004.
 */
class Constant {
	/**
	 * Der Standard-Konstruktor sollte nicht aufgerufen werden, da diese Klasse nur aus statischen Elementen besteht.
	 */
	private new() {
		throw new RuntimeException("Die Klasse Konstanten kann nicht instanziiert werden.")
	}

	/** Messdiener-Parameter für Namen der Messen. */
	public static final String MO_NAME = "MO_NAME"
	/** Messdiener-Parameter für Namen der Ort. */
	public static final String MO_ORT = "MO_ORT"
	/** Messdiener-Parameter für Namen der Dienste. */
	public static final String MO_DIENSTE = "MO_DIENSTE"
	/** Messdiener-Parameter für Anfangszeiten der Messen. */
	public static final String MO_VERFUEGBAR = "MO_VERFUEGBAR"
	/** Messdiener-Parameter für Jahr der Flambogrenze. */
	public static final String MO_FLAMBO_GRENZE = "MO_FLAMBO_GRENZE"

	/** Zahl 100.0 als Konstante. */
	public static final double ZAHL_100_0 = 100.0
	/** Zahl 10000.0 als Konstante. */
	public static final double ZAHL_10000_0 = 10000.0
	/** Zahl 1000000.0 als Konstante. */
	public static final double ZAHL_1000000_0 = 1000000.0

	/** Zeit in Millisekunden für Änderungsintervall. */
	public static final int AEND_ZEIT = 60000
	/** Faktor für EURO-DM-Umrechnung. */
	public static final double EUROFAKTOR = 1.95583

	/** Zeilenumbruch bei Windows. */
	public static final String CRLF = "\r\n"
	/** Zeilenumbruch bei Linux. */
	public static final String LF = "\n"

	/** Einstellung: DB_INIT. */
	public static final String EINST_DB_INIT = "DB_INIT"
	/** Einstellung: DB_VERSION. */
	public static final String EINST_DB_VERSION = "DB_VERSION"
	/** Einstellung: DATENBANK. */
	public static final String EINST_DATENBANK = "DATENBANK"
	/** Mandant-Einstellung: REPLIKATION_UID. */
	public static final String EINST_MA_REPLIKATION_UID = "REPLIKATION_UID"
	/** Mandant-Einstellung: REPLIKATION_BEGINN. */
	public static final String EINST_MA_REPLIKATION_BEGINN = "REPLIKATION_BEGINN"
	/** Mandant-Einstellung: OHNE_ANMELDUNG. */
	public static final String EINST_MA_OHNE_ANMELDUNG = "OHNE_ANMELDUNG"
	/** Mandant-Einstellung: EXAMPLES. */
	public static final String EINST_MA_EXAMPLES = "EXAMPLES"

	/** kleinster Autowert. */
	public static final int AW_MIN = 1
	/** kleinster Autowert mit 0. */
	public static final int AW_MIN0 = 0

	/** Kleinste Perioden-Nummer. */
	public static final int MIN_PERIODE = 0
	/** Erste zu vergebende Perioden-Nummer. */
	public static final int START_PERIODE = 10000
	/** Größte Perioden-Nummer. */
	public static final int MAX_PERIODE = 99999

	/** Periodennummer, unter der die berechnete Periode gespeichert wird. */
	public static final int PN_BERECHNET = -1

	/** Kontoart: Aktivkonto. */
	public static final String ARTK_AKTIVKONTO = "AK"
	/** Kontoart: Passivkonto. */
	public static final String ARTK_PASSIVKONTO = "PK"
	/** Kontoart: Aufwandskonto. */
	public static final String ARTK_AUFWANDSKONTO = "AW"
	/** Kontoart: Ertragskonto. */
	public static final String ARTK_ERTRAGSKONTO = "ER"

	/** Kennzeichen Konto: Eigenkapital. */
	public static final String KZK_EK = "E"
	/** Kennzeichen Konto: Gewinn oder Verlust. */
	public static final String KZK_GV = "G"
	/** Kennzeichen Buchung: Aktiv. */
	public static final String KZB_AKTIV = "A"
	/** Kennzeichen Buchung: Storniert. */
	public static final String KZB_STORNO = "S"

	/** Kennzeichen Bilanz: Eröffnungbilanz. */
	public static final String KZBI_EROEFFNUNG = "EB"
	/** Kennzeichen Bilanz: Schlussbilanz. */
	public static final String KZBI_SCHLUSS = "SB"
	/** Kennzeichen Bilanz: Gewinn- und Verlust-Rechnung. */
	public static final String KZBI_GV = "GV"
	/** Kennzeichen Bilanz: Einzelnes Konto. */
	public static final String KZBI_KONTO = "KO"
	/** Kennzeichen Bilanz: Plan für Folgejahr. */
	public static final String KZBI_PLAN = "PL"

	/** Soll-Haben-Kennzeichen in Bilanz: Aktiv, linke Seite. */
	public static final String KZSH_A = "A"
	/** Soll-Haben-Kennzeichen in Bilanz: Passiv, rechte Seite. */
	public static final String KZSH_P = "P"

	/** Suche am Anfang. */
	public static final int TB_ANFANG = 1
	/** Suche rückwärts. */
	public static final int TB_ZURUECK = 2
	/** Suche vorwärts. */
	public static final int TB_VOR = 3
	/** Suche am Ende. */
	public static final int TB_ENDE = 4

	/** Jahr für Monatsbestimmung. */
	public static final int JAHR_MONAT = 2000
}

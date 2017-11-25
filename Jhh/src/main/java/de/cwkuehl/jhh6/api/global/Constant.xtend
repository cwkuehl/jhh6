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

}

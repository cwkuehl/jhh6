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

	/** Faktor für EURO-DM-Umrechnung. */
	public static final double EUROFAKTOR = 1.95583

	/** Zeilenumbruch bei Windows. */
	public static final String CRLF = "\r\n"
}

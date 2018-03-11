package de.cwkuehl.jhh6.api.enums

import de.cwkuehl.jhh6.api.message.Meldungen

/** 
 * GEDCOM-Kürzel für Ereignisse. 
 */
final class GedcomEreignis implements Comparable<GedcomEreignis> {

	/** 
	 * Der Standard-Konstruktor sollte nicht aufgerufen werden.
	 */
	private new() {
		wert = null
		symbol = null
		nr = 0
		throw new RuntimeException(Meldungen::M1000(typeof(GedcomEreignis).name))
	}

	/** 
	 * Liste mit allen Ereignissen. 
	 */
	static GedcomEreignis[] enums = #[new GedcomEreignis("", "", 0), new GedcomEreignis("BIRT", "*", 1),
		new GedcomEreignis("CHR", "~", 2), new GedcomEreignis("DEAT", "+", 3), new GedcomEreignis("BURI", "b", 4),
		new GedcomEreignis("MARR", "h", 5)]

	/** 
	 * Liefert Ereignis Geburt.
	 * @return Ereignis Geburt.
	 */
	def static GedcomEreignis eGEBURT() {
		return enums.get(1)
	}

	/** 
	 * Liefert Ereignis Taufe.
	 * @return Ereignis Taufe.
	 */
	def static GedcomEreignis eTAUFE() {
		return enums.get(2)
	}

	/** 
	 * Liefert Ereignis Tod.
	 * @return Ereignis Tod.
	 */
	def static GedcomEreignis eTOD() {
		return enums.get(3)
	}

	/** 
	 * Liefert Ereignis Begräbnis.
	 * @return Ereignis Begräbnis.
	 */
	def static GedcomEreignis eBEGRAEBNIS() {
		return enums.get(4)
	}

	/** 
	 * Liefert Ereignis Heirat.
	 * @return Ereignis Heirat.
	 */
	def static GedcomEreignis eHEIRAT() {
		return enums.get(5)
	}

	/** 
	 * Liefert unbekanntes Ereignis.
	 * @return unbekanntes Ereignis.
	 */
	def static GedcomEreignis eUNBEKANNT() {
		return enums.get(0)
	}

	/** 
	 * Wert als String. 
	 */
	final String wert
	/** 
	 * Symbol für Darstellung. 
	 */
	final String symbol
	/** 
	 * Reihenfolge-Nr. 
	 */
	final int nr

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param pWert Wert für GEDCOM-Schnittstelle.
	 * @param pSymbol Symbol für Darstellung.
	 * @param pNr Nummer für Sortierung.
	 */
	private new(String pWert, String pSymbol, int pNr) {
		wert = pWert
		symbol = pSymbol
		nr = pNr
	}

	/** 
	 * Liefert den String-Wert des Ereignisses.
	 * @return String-Wert.
	 */
	def String wert() {
		return wert
	}

	/** 
	 * Liefert ein GedcomEreignis anhand des internen String-Werts.
	 * @param pWert Gesuchtes Ereignis als String.
	 * @return GedcomEreignis oder UNBEKANNT, falls der String kein bekanntes
	 * Ereignis beschreibt.
	 */
	def static GedcomEreignis wertVon(String pWert) {

		for (GedcomEreignis e : enums) {
			if (e.wert().equals(pWert)) {
				return e
			}
		}
		return eUNBEKANNT()
	}

	/** 
	 * Liefert das Symbol eines Ereignisses anhand des String-Werts.
	 * @param pWert String-Wert.
	 * @return Symbol oder pWert, falls Ereignis nicht bekannt ist.
	 */
	def static String symbolVon(String pWert) {

		for (var i = 0; i < enums.length; i++) {
			if ({
				val _rdIndx_enums = i
				enums.get(_rdIndx_enums)
			}.wert.equals(pWert)) {
				return {
					val _rdIndx_enums = i
					enums.get(_rdIndx_enums)
				}.symbol
			}
		}
		return pWert
	}

	override int compareTo(GedcomEreignis o) {

		if (nr < o.nr) {
			return -1
		} else if (nr > o.nr) {
			return 1
		}
		return 0
	}
}

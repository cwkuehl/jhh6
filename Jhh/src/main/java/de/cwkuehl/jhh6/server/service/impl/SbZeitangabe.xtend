package de.cwkuehl.jhh6.server.service.impl

import java.util.regex.Matcher
import java.util.regex.Pattern
import de.cwkuehl.jhh6.api.global.Global

/** 
 * Diese Klasse bewerkstelligt die Datumskonvertierungen für Zeitangaben in der Ahnenforschung, die aus bis zu zwei
 * Datumsangaben bestehen.
 */
final class SbZeitangabe {

	/** 
	 * 1. Datumsangabe. 
	 */
	SbDatum datum1 = null
	/** 
	 * 2. Datumsangabe. 
	 */
	SbDatum datum2 = null
	/** 
	 * Der Datumstyp gibt an, in welcher Beziehung die beiden Datumsangaben stehen: EXAC, ABT, BET, BEF, AFT oder OR.
	 */
	String datumTyp = null

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		datum1 = new SbDatum()
		datum2 = new SbDatum()
		datumTyp = ""
	}

	/** 
	 * Konstruktur mit Initialisierung der Zeitangabe.
	 * @param sdatum1 1. Datumsangabe.
	 * @param sdatum2 2. Datumsangabe.
	 * @param sdatumTyp Datumstyp
	 */
	new(SbDatum sdatum1, SbDatum sdatum2, String sdatumTyp) {

		datum1 = sdatum1
		if (datum1 === null) {
			datum1 = new SbDatum()
		}
		datum2 = sdatum2
		if (datum2 === null) {
			datum2 = new SbDatum()
		}
		datumTyp = sdatumTyp
		if (datumTyp === null) {
			datumTyp = ""
		}
	}

	/** 
	 * Initialisierung aller internen Variablen.
	 */
	def void init() {
		datum1.init()
		datum2.init()
		datumTyp = ""
	}

	/** 
	 * Konvertiert interne Zeitangaben in String.
	 * @return Zeitangaben als String.
	 */
	def String deparse() {
		return deparse(false)
	}

	/** 
	 * Konvertiert interne Zeitangaben in String.
	 * @param gedcom Bei true werden Datumsangaben im GEDCOM-Format dargestellt.
	 * @return Zeitangaben als String.
	 */
	def String deparse(boolean gedcom) {

		var String datum = ""
		var String dat1 = datum1.deparse(gedcom)
		var String dat2 = datum2.deparse(gedcom)
		if (gedcom) {
			if (datumTyp.equals("EXAC")) {
				datum = datum1.deparse(gedcom)
			} else if (datumTyp.equals("ABT") || datumTyp.equals("AFT") || datumTyp.equals("BEF")) {
				datum = '''«datumTyp» «dat1»'''
			} else if (datumTyp.equals("BET")) {
				datum = '''BET «dat1» AND «dat2»'''
			} else {
				// if (datumTyp.equals("OR")) {
				datum = Global.anhaengen(dat1, " OR ", dat2)
			}
		} else {
			if (datumTyp.equals("EXAC")) {
				datum = dat1
			} else if (datumTyp.equals("ABT")) {
				datum = '''um «dat1»'''
			} else if (datumTyp.equals("AFT")) {
				datum = '''nach «dat1»'''
			} else if (datumTyp.equals("BEF")) {
				datum = '''vor «dat1»'''
			} else if (datumTyp.equals("BET")) {
				datum = '''«dat1» - «dat2»'''
			} else if (datumTyp.equals("OR")) {
				datum = '''«dat1» oder «dat2»'''
			} else {
				datum = Global.anhaengen(dat1, ", ", dat2)
			}
		}
		return datum
	}

	static Pattern monat1 = Pattern.compile("((\\d) +)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)( +(\\d))")
	static Pattern monat2 = Pattern.compile("(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)( +(\\d))")
	static String[] monate = #["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

	def int getMonat(String monat) {

		for (var int i = 0; i < monate.length; i++) {
			if ({
				val _rdIndx_monate = i
				monate.get(_rdIndx_monate)
			}.equals(monat)) {
				return i + 1
			}
		}
		return -1
	}

	def boolean parse(String parseDatum, boolean gedcom) {

		var String datum = parseDatum
		if (gedcom) {
			// [JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC] ersetzen durch
			// Monatsnummer
			var boolean weiter = true
			var Matcher m = null
			while (weiter) {
				m = monat1.matcher(datum)
				if (m.find()) {
					datum = datum.replace(m.group(1) + m.group(3) +
						m.group(4), '''«m.group(2)».«getMonat(m.group(3))».«m.group(5)»''')
				} else {
					weiter = false
				}
			}
			weiter = true
			while (weiter) {
				m = monat2.matcher(datum)
				if (m.find()) {
					datum = datum.replace(m.group(1) + m.group(2), '''«getMonat(m.group(1))».«m.group(3)»''')
				} else {
					weiter = false
				}
			}
		}
		return parse(datum)
	}

	/** 
	 * Setzt die interne Zeitangabe an Hand des übergebenen Strings.
	 * @param datumString Datum als String.
	 * @return true, wenn unbekannter Text gefunden wird.
	 */
	def boolean parse(String datumString) {

		var boolean mitText = false
		var String hinten = ""
		var String mitte = ""
		var String vorn = ""
		var String datum = datumString
		init()
		if (!Global.nes(datum)) {
			var Matcher m = null
			if (datum.matches("[^\\d\\.]+")) {
				mitText = true
			}
			m = Pattern.compile("^(.*?)([^\\d\\.]*)$").matcher(datum)
			m.find()
			datum = m.group(1)
			hinten = m.group(2)
			datum = datum2.parse(datum)
			datumTyp = "EXAC"
			m = Pattern.compile("^(.*?)([^\\d\\.]*)$").matcher(datum)
			m.find()
			datum = m.group(1)
			mitte = m.group(2)
			vorn = datum1.parse(datum)
		}
		var boolean b1 = !datum1.isLeer()
		var boolean b2 = !datum2.isLeer()
		vorn = vorn.replace(" ", "")
		// Leerzeichen entfernen
		mitte = mitte.replace(" ", "").toLowerCase()
		// Leerzeichen entfernen
		hinten = hinten.replace(" ", "")
		// Leerzeichen entfernen
		if (b1 === b2) {
			if (b1) {
				if (mitte.matches("\\/|\\-|bis|and")) {
					// zwischen zwei
					// Zeitpunkten
					datumTyp = "BET"
				} else if (mitte.matches("oder|or")) {
					// zwei Zeitpunkte
					datumTyp = "OR"
				} else {
					mitText = true // printf "unbekannte Mitte: '$mitte' bei '$kopie'\n";
				}
			} else {
				datumTyp = ""
			}
		} else {
			if (mitte.length() > 0) {
				if (mitte.matches("um|about|abt")) {
					datumTyp = "ABT" // ungefähres Datum
				} else if (mitte.matches("nach|frühestens|after|aft")) {
					datumTyp = "AFT" // nach einem Zeitpunkt
				} else if (mitte.matches("vor|before|bef")) {
					datumTyp = "BEF" // vor einem Zeitpunkt
				} else {
					mitText = true // printf "unbekanntes Vorne: '$mitte' bei '$kopie'\n";
				}
			}
			if (hinten.length() > 0) {
				if (hinten.matches("\\?")) {
					// ungefähres Datum
					datumTyp = "ABT"
				} else {
					mitText = true // printf "unbekanntes Hinten: '$hinten' bei '$kopie'\n";
				}
			}
			if (b2) {
				datum1.set(datum2)
				datum2.init()
			}
		}
		return mitText
	}

	def SbDatum getDatum1() {
		return datum1
	}

	def SbDatum getDatum2() {
		return datum2
	}

	def String getDatumTyp() {
		return datumTyp
	}
}

package de.cwkuehl.jhh6.server.service.impl

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale
import java.util.regex.Matcher
import java.util.regex.Pattern
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global

/** 
 * Diese Klasse bewerkstelligt die Datumskonvertierungen für Datumsangaben in der Ahnenforschung.
 * @author Wolfgang
 */
class SbDatum {

	/** 
	 * Tag im Monat (1-31). 
	 */
	int tag = 0
	/** 
	 * Monat (1-12). 
	 */
	int monat = 0
	/** 
	 * Jahreszahl (1-99999). 
	 */
	int jahr = 0

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		init
	}

	/** 
	 * Konstruktur mit konkreter Datumsbelegung.
	 * @param stag 0 oder Tag.
	 * @param smonat 0 oder Monat.
	 * @param sjahr 0 oder Jahr.
	 */
	new(int stag, int smonat, int sjahr) {

		tag = stag
		if (tag < 0) {
			tag = 0
		}
		monat = smonat
		if (monat < 0) {
			monat = 0
		}
		jahr = sjahr
	}

	/** 
	 * Initialisierung des Datums.
	 */
	def void init() {
		tag = 0
		monat = 0
		jahr = 0
	}

	/** 
	 * Übernehmen eines anderen Datum.
	 * @param datum Anderes Datum.
	 */
	def void set(SbDatum datum) {
		tag = datum.tag
		monat = datum.monat
		jahr = datum.jahr
	}

	/** 
	 * Übernehmen eines anderen Datum.
	 * @param datum Anderes Datum.
	 */
	def void set(LocalDate datum) {
		tag = datum.dayOfMonth
		monat = datum.monthValue
		jahr = datum.year
	}

	/** 
	 * Trenner zwischen kurzem und langem Jahr. 
	 */
	static final int JAHR_KURZ = 10000

	/** 
	 * Liefert das interne Datum als String. Falls gedcom gesetzt ist, wird folgendes Format benutzt DD MMM YYYY; Sonst
	 * DD.MM.YYYY.
	 * @param gedcom true, wenn Datum in GEDCOM-Datei benötigt wird.
	 * @return Datum als String.
	 */
	def String deparse(boolean gedcom) {

		var datum = new StringBuffer
		var trenner = "."
		if (gedcom) {
			trenner = " "
		}
		if (tag !== 0) {
			datum.append(Global.fixiereString(Global.intStr(tag), 2, false, "0"))
		}
		if (monat !== 0) {
			if (datum.length > 0) {
				datum.append(trenner)
			}
			if (gedcom) {
				datum.append(LocalDate.of(Constant.JAHR_MONAT, monat, 1).format(mf2).toUpperCase)
			} else {
				datum.append(Global.fixiereString(Global.intStr(monat), 2, false, "0"))
			}
		}
		if (jahr !== 0) {
			if (datum.length > 0) {
				datum.append(trenner)
			}
			if (jahr < JAHR_KURZ) {
				datum.append(Global.fixiereString(Global.intStr(jahr), 4, false, "0"))
			} else {
				datum.append(Global.fixiereString(Global.intStr(jahr), 5, false, "0"))
			}
		}
		return datum.toString
	}

	/** 
	 * Parst das übergebene Datum und speichert es in den internen Daten.
	 * @param parseDatum Zu parsendes Datum.
	 * @return Nicht analysierter Teil-String des Datums.
	 */
	def String parse(String parseDatum) {

		var datum = parseDatum
		init
		if (datum !== null) /* !Global.nes(datum) */ {
			var Matcher m
			// alles außer Ziffern und Punkten am Ende entfernen
			m = Pattern.compile("(.+?)[^\\d\\.]*$").matcher(datum)
			if (m.find) {
				datum = m.group(1)
				m = Pattern.compile("(.*?)([\\d]+)$").matcher(datum)
				if (m.find) {
					// letzte Zahl ist Jahr
					datum = m.group(1)
					jahr = Global.strInt(m.group(2))
					m = Pattern.compile("(.*?)([\\d]+)\\.$").matcher(datum)
					if (m.find) {
						// letzte Zahl mit Punkt ist Monat
						datum = m.group(1)
						monat = Global.strInt(m.group(2))
						m = Pattern.compile("(.*?)([\\d]+)\\.$").matcher(datum)
						if (m.find) {
							// letzte Zahl mit Punkt ist Tag
							datum = m.group(1)
							tag = Global.strInt(m.group(2))
						}
					}
				}
			}
		}
		return datum
	}

	/** 
	 * Formatter für GEDCOM-Datum. 
	 */
	static DateTimeFormatter mf1 = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.ENGLISH)
	/** 
	 * Formatter für GEDCOM-Monat. 
	 */
	static DateTimeFormatter mf2 = DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH)

	/** 
	 * Konvertierung von Date in String mit GEDCOM-Datum.
	 * @param datum Datum.
	 * @return String mit GEDCOM-Datum.
	 */
	def static String gcdatum(LocalDateTime datum) {
		return if(datum === null) "" else datum.format(mf1)
	}

	def int getJahr() {
		return jahr
	}

	def int getMonat() {
		return monat
	}

	def int getTag() {
		return tag
	}

	def boolean isLeer() {
		return tag <= 0 && monat <= 0 && jahr === 0
	}

	def LocalDate getDate(boolean anfang) {

		var t = tag
		var m = monat
		var j = jahr
		if (m <= 0) {
			m = if(anfang) 1 else 12
			t = 0
		}
		if (t <= 0) {
			var d = LocalDate.of(j, m, 1)
			if (anfang) {
				return d
			} else {
				return d.withDayOfMonth(d.lengthOfMonth)
			}
		}
		return LocalDate.of(j, m, t)
	}
}

package de.cwkuehl.jhh6.server.fop.impl

import java.math.BigDecimal
import java.time.LocalDate
import java.util.Calendar
import java.util.Date
import java.util.GregorianCalendar
import java.util.HashMap
import java.util.List
import de.cwkuehl.jhh6.api.global.Global

// import org.apache.commons.lang3.time.FastDateFormat;
/** 
 * Diese Klasse stellt statische Funktionen für die Dokumenten-Erzeugung zur Verfügung.
 */
class FoUtils {

	// private static Log log = LogFactory.getLog(FoUtils.class);
	// private static FastDateFormat datumFormat = FastDateFormat.getInstance("dd.MM.yyyy");
	// private static FastDateFormat datumTagFormat = FastDateFormat.getInstance("dd.");
	// private static FastDateFormat datumTagMonatFormat = FastDateFormat.getInstance("dd.MM.");
	/** 
	 * Die double-Werte werden in BigDecimal umgewandelt, auf 2 Nachkkommastellen gerundet und dann verglichen. <br>
	 * @param db1 1. double-Wert.
	 * @param db2 2. double-Wert.
	 * @return 0: double-Werte gleich; 1: db1 größer db2; -1: db1 kleiner db2
	 */
	def static int compDouble(double db1, double db2) {

		val BigDecimal bd1 = new BigDecimal(db1)
		val BigDecimal bd2 = new BigDecimal(db2)
		val BigDecimal bd1r = bd1.setScale(2, BigDecimal.ROUND_HALF_UP)
		val BigDecimal bd2r = bd2.setScale(2, BigDecimal.ROUND_HALF_UP)
		val int cmp = bd1r.compareTo(bd2r)
		if (cmp < 0) {
			return -1
		} else if (cmp > 0) {
			return 1
		}
		return 0
	}

	/** 
	 * Ist der String null oder leer?
	 * @param str String
	 * @return Ist der String null oder leer?
	 */
	def static boolean nes0(String str) {

		if (str === null || "".equals(str)) {
			return true
		}
		return false
	}

	/** 
	 * Ist der String null, leer oder nur aus Leerzeichen?
	 * @param str String
	 * @return Ist der String null, leer oder nur aus Leerzeichen?
	 */
	def static boolean nesTrim(String str) {

		if (str === null || "".equals(str) || "".equals(str.trim)) {
			return true
		}
		return false
	}

	/** 
	 * Liefert Datum zu Tag, Monat und Jahr.
	 * @param tag Tag.
	 * @param monat Monat.
	 * @param jahr Jahr.
	 * @return Datum.
	 */
	def static Date getDatum(int tag, int monat, int jahr) {

		var Calendar cal = getCalendar(null)
		cal.set(Calendar.DAY_OF_MONTH, tag)
		cal.set(Calendar.MONTH, monat - 1)
		cal.set(Calendar.YEAR, jahr)
		cal.set(Calendar.HOUR_OF_DAY, 0)
		cal.set(Calendar.MINUTE, 0)
		cal.set(Calendar.SECOND, 0)
		cal.set(Calendar.MILLISECOND, 0)
		return new Date(cal.getTimeInMillis)
	}

	/** 
	 * Liefert Tag im Monat.
	 * @param datum Datum.
	 * @return Tag im Monat.
	 */
	def static int getTag(Date datum) {
		var Calendar cal = getCalendar(datum)
		return cal.get(Calendar.DAY_OF_MONTH)
	}

	/** 
	 * Liefert Monatsletzten.
	 * @param monat Monat.
	 * @param jahr Jahr.
	 * @return Monatsletztent.
	 */
	def static int getMonatsletzten(int monat, int jahr) {
		var Calendar cal = getCalendar(getDatum(1, monat, jahr))
		return cal.getActualMaximum(Calendar.DAY_OF_MONTH)
	}

	/** 
	 * Liefert Monat ab 1.
	 * @param datum Datum.
	 * @return Monat ab 1.
	 */
	def static int getMonat(Date datum) {
		var Calendar cal = getCalendar(datum)
		return cal.get(Calendar.MONTH) + 1
	}

	/** 
	 * Liefert Datum in der Form TT.
	 * @param datum Datum.
	 * @return Datum in der Form TT.
	 */
	def static String getDatumTag(Date datum) {

		if (datum === null) {
			return null
		}
		return "" // datumTagFormat.format(datum);
	}

	/** 
	 * Liefert Datum in der Form TT.MM.
	 * @param datum Datum.
	 * @return Datum in der Form TT.MM.
	 */
	def static String getDatumTagMonat(Date datum) {

		if (datum === null) {
			return null
		}
		return "" // datumTagMonatFormat.format(datum);
	}

	/** 
	 * Liefert Datum in der Form TT.MM.JJJJ.
	 * @param datum Datum.
	 * @return Datum in der Form TT.MM.JJJJ.
	 */
	def static String getDatum(LocalDate datum) {

		if (datum === null) {
			return null
		}
		return Global.dateString(datum)
	}

	/** 
	 * Liefert den String oder Leerstring, wenn null.
	 * @param str String.
	 * @return String oder Leerstring, wenn null.
	 */
	def static String nn(String str) {

		if (str === null) {
			return ""
		}
		return str
	}

	/** 
	 * Hinzufügen von Monaten zu einem Datum.
	 * @param datum Datum.
	 * @param anzahl Anzahl der Monate
	 * @param ultimo Soll der Monatsletzte erhalten bleiben?
	 * @return Datum mit addierten Monaten.
	 */
	def static Date addMonate(Date datum, int anzahl, boolean ultimo) {

		var Calendar calendar = getCalendar(datum)
		calendar.set(Calendar.HOUR_OF_DAY, 0)
		calendar.set(Calendar.MINUTE, 0)
		calendar.set(Calendar.SECOND, 0)
		calendar.set(Calendar.MILLISECOND, 0)
		addMonateIntern(calendar, anzahl, ultimo, calendar.get(Calendar.DAY_OF_MONTH))
		return new Date(calendar.getTimeInMillis)
	}

	/** 
	 * Hinzufügen von Tagen zu einem Datum.
	 * @param datum Datum.
	 * @param anzahl Anzahl der Monate
	 * @return Datum mit addierten Tagen.
	 */
	def static Date addTage(Date datum, int anzahl) {

		var Calendar calendar = getCalendar(datum)
		calendar.set(Calendar.HOUR_OF_DAY, 0)
		calendar.set(Calendar.MINUTE, 0)
		calendar.set(Calendar.SECOND, 0)
		calendar.set(Calendar.MILLISECOND, 0)
		calendar.add(Calendar.DAY_OF_MONTH, anzahl)
		return new Date(calendar.getTimeInMillis)
	}

	def private static Calendar getCalendar(Date datum) {

		var Calendar calendar = new GregorianCalendar
		if (datum !== null) {
			calendar.setTime(datum)
		}
		return calendar
	}

	def private static void addMonateIntern(Calendar calendar, int monate, boolean fultimo, int tag) {

		var ultimo = fultimo
		if (ultimo) {
			if(calendar.get(Calendar.DAY_OF_MONTH) < calendar.getActualMaximum(Calendar.DAY_OF_MONTH)) ultimo = false
		}
		calendar.add(Calendar.MONTH, monate)
		if (ultimo) {
			calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
		} else if (calendar.get(Calendar.DAY_OF_MONTH) < tag) {
			if (calendar.getActualMaximum(Calendar.DAY_OF_MONTH) < tag) {
				calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
			} else {
				calendar.set(Calendar.DAY_OF_MONTH, tag)
			}
		}
	}

	/** 
	 * Liefert die Anzahl der Listeneinträge, 0 wenn null.
	 * @param liste Liste kann null sein.
	 * @return Anzahl der Listeneinträge.
	 */
	def static int size(List<?> liste) {

		if (liste === null) {
			return 0
		}
		return liste.size
	}

	/** 
	 * Liefert die Anzahl der Listeneinträge, 0 wenn null.
	 * @param liste Liste kann null sein.
	 * @return Anzahl der Listeneinträge.
	 */
	def static int size(HashMap<?, ?> liste) {

		if (liste === null) {
			return 0
		}
		return liste.size
	}

	/** 
	 * Vergleich zweier String. Leerstring und null werden gleich behandelt.
	 * @param str1
	 * @param str2
	 * @return Sind die Strings gleich?
	 */
	def static boolean equals(String str1, String str2) {

		if (nes0(str1) !== nes0(str2)) {
			return false
		}
		if (!nes0(str1) && !str1.equals(str2)) {
			return false
		}
		return true
	}

	/** 
	 * Zusammensetzen von Strings aus sb, filler und text. Der filler wird nur eingefügt, wenn sb und text nicht leer
	 * sind.
	 * @param sb StringBuffer.
	 * @param filler wird an sb angehängt, wenn sb und text nicht leer sind.
	 * @param text wird an sb angehängt.
	 */
	def static void append(StringBuffer sb, String filler, String text) {

		if (sb === null) {
			return;
		}
		if (!nes0(text)) {
			if (sb.length > 0 && !nes0(filler)) {
				sb.append(filler)
			}
			sb.append(text)
		}
	}

	/** 
	 * Zusammensetzen von Strings aus sb, filler und text. Der filler wird nur eingefügt, wenn sb und text nicht leer
	 * sind.
	 * @param sb StringBuffer.
	 * @param filler wird an sb angehängt, wenn sb und text nicht leer sind.
	 * @param datum wird an sb angehängt.
	 */
	def static void append(StringBuffer sb, String filler, LocalDate datum) {

		if (datum !== null) {
			append(sb, filler, getDatum(datum))
		}
	}

	/** 
	 * Liefert Darstellung als römische Zahl.
	 * @param j Zahl.
	 * @return Darstellung als römische Zahl.
	 */
	def static String getRoman(int j) {

		var i = j
		var StringBuffer sb = new StringBuffer
		if (i < 0) {
			sb.append("-")
			i = -i
		} else if (i === 0) {
			sb.append("nihil")
		}
		while (i >= 1000) {
			sb.append("M")
			i -= 1000
		}
		while (i >= 500) {
			sb.append("D")
			i -= 500
		}
		while (i >= 100) {
			sb.append("C")
			i -= 100
		}
		while (i >= 50) {
			sb.append("L")
			i -= 50
		}
		while (i >= 10) {
			sb.append("X")
			i -= 10
		}
		while (i >= 5) {
			sb.append("V")
			i -= 5
		}
		while (i >= 1) {
			sb.append("I")
			i -= 1
		}
		var String str = sb.toString
		// Subtraktionsregel
		str = str.replace("DCCCC", "CM")
		str = str.replace("CCCC", "CD")
		str = str.replace("LXXXX", "XC")
		str = str.replace("XXXX", "XL")
		str = str.replace("VIIII", "IX")
		str = str.replace("IIII", "IV")
		return str
	}
}

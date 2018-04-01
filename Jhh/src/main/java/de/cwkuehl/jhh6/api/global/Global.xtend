package de.cwkuehl.jhh6.api.global

import de.cwkuehl.jhh6.api.message.Meldungen
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.io.UnsupportedEncodingException
import java.math.BigDecimal
import java.math.RoundingMode
import java.nio.charset.Charset
import java.rmi.server.UID
import java.security.SecureRandom
import java.text.MessageFormat
import java.text.NumberFormat
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.ArrayList
import java.util.Base64
import java.util.List
import java.util.Locale
import java.util.ResourceBundle
import java.util.jar.Attributes
import java.util.jar.JarFile
import java.util.regex.Pattern

/**
 * Globale Klasse mit allgemeinen Funktionen.<br>
 * Erstellt am 15.08.2004.
 */
class Global {

	private static final SecureRandom random = new SecureRandom
	private static ResourceBundle bundle = null

	/**
	 * Der Standard-Konstruktor sollte nicht aufgerufen werden, da diese Klasse nur aus statischen Elementen besteht.
	 */
	private new() {
		throw new RuntimeException(Meldungen::M1000(typeof(Global).name))
	}

	/**
	 * Diese Funktion macht nichts und wird gebraucht, damit Checkstyle nicht leere Blocks bemängelt.
	 * @return 0.
	 */
	def public static int machNichts() {
		return 0
	}

	/**
	 * Liefert die Array-Größe.
	 * @param array Zu behandelndes Array.
	 * @return Array-Größe.
	 */
	def public static int arrayLaenge(Object[] array) {

		if (array === null) {
			return 0
		}
		return array.length
	}

	// Konvertierungs-Funktionen
	/**
	 * Konvertierung eines String in int. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter int-Wert.
	 */
	def public static int strInt(String str) {
		return strInt(str, Locale.^default)
	}

	/**
	 * Konvertierung eines String in int. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter int-Wert.
	 */
	def public static int strInt(String str, Locale l) {

		var i = 0
		if (!nes(str)) {
			try {
				i = NumberFormat.getNumberInstance(l).parse(str).intValue
			} catch (Exception ex) {
				machNichts
			}
		}
		return i
	}

	/**
	 * Konvertierung eines String in int. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter int-Wert.
	 */
	def public static int objInt(Object str) {
		return if(str === null) 0 else strInt(str.toString)
	}

	/**
	 * Konvertierung eines String in double. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter int-Wert.
	 */
	def public static double objDbl(Object str) {
		return if (str === null)
			0.0
		else if (str instanceof BigDecimal)
			strDbl(str.toString, Locale.ENGLISH)
		else
			strDbl(str.toString)
	}

	/**
	 * Konvertiert einen int-Wert in einen String.
	 * @param i int-Wert.
	 * @return Wert als String.
	 */
	def public static String intStr(int i) {

		var str = Integer.toString(i)
		return str
	}

	/**
	 * Konvertiert einen int-Wert in einen String ohne Punkt oder Komma. Bei 0 wird leerer String geliefert.
	 * @param i int-Wert.
	 * @return Wert als String.
	 */
	def public static String intStrFormat(int i) {

		if (i == 0) {
			return ""
		}
		return intStr(i)
	}

	/**
	 * Konvertierung eines String in long. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter long-Wert.
	 */
	def public static long strLng(String str) {
		return strLng(str, Locale.^default)
	}

	/**
	 * Konvertierung eines String in long. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter long-Wert.
	 */
	def public static long strLng(String str, Locale lc) {

		var l = 0l
		if (!nes(str)) {
			try {
				l = NumberFormat.getNumberInstance(lc).parse(str).longValue
			} catch (Exception ex3) {
				machNichts
			}
		}
		return l
	}

	/**
	 * Konvertiert einen long-Wert in einen String ohne Punkt oder Komma.
	 * @param l long-Wert.
	 * @return Wert als String.
	 */
	def public static String lngStr(long l) {

		var str = Long.toString(l)
		return str
	}

	/**
	 * Konvertierung eines Strings in double. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter double-Wert.
	 */
	def public static double strDbl(String str) {
		return strDbl(str, Locale.^default)
	}

	/**
	 * Konvertierung eines Strings in double. Eine Exception wird abgefangen und 0 als Ergebnis geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertierter double-Wert.
	 */
	def public static double strDbl(String str, Locale l) {

		var d = 0.0
		if (!nes(str)) {
			try {
				d = NumberFormat.getNumberInstance(l).parse(str).doubleValue
			} catch (Exception ex) {
				return 0
			}
		}
		return d
	}

	/**
	 * Konvertierung von double nach String. Standardmäßig werden 2 Nachkommastellen ausgegeben. Wenn es 3 oder 4
	 * Nachkommastellen gibt, werden 4 Nachkommastellen ausgegeben.
	 * <p>
	 * Erstellungsdatum: 13.07.2004
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 2 oder 4 Nachkommastellen.
	 */
	def public static String dblStr(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d)) {
			return d.toString
		}
		var str = ""
		if (hat3Oder4Nachkommastellen(d)) {
			str = MessageFormat.format("{0,number,#,##0.0000}", d)
		} else {
			str = MessageFormat.format("{0,number,#,##0.00}", d)
		}
		return str
	}

	/**
	 * Konvertierung von double nach String mit 2 Nachkommastellen. Keine Zahl oder unendlich liefert einen leeren
	 * String.
	 * <p>
	 * Erstellungsdatum: 10.05.2015.
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 2 Nachkommastellen oder leer.
	 */
	def public static String dblStr2(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d)) {
			return ''
		}
		var str = format("{0,number,#,##0.00}", d)
		return str
	}

	/**
	 * Konvertierung von double nach String mit 2 Nachkommastellen. 0, keine Zahl oder unendlich liefert einen leeren
	 * String.
	 * <p>
	 * Erstellungsdatum: 10.05.2015.
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 2 Nachkommastellen oder leer.
	 */
	def public static String dblStr2l(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d) || d == 0) {
			return ''
		}
		var str = format("{0,number,#,##0.00}", d)
		return str
	}

	/**
	 * Konvertierung von double nach String mit 4 Nachkommastellen. 0, keine Zahl oder unendlich liefert einen leeren
	 * String.
	 * <p>
	 * Erstellungsdatum: 10.05.2015
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 4 Nachkommastellen oder leer.
	 */
	def public static String dblStr4l(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d) || d == 0) {
			return ''
		}
		var str = format("{0,number,#,##0.0000}", d)
		return str
	}

	/**
	 * Konvertierung von double nach String mit 5 Nachkommastellen. 0, keine Zahl oder unendlich liefert einen leeren
	 * String.
	 * <p>
	 * Erstellungsdatum: 16.09.2016
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 4 Nachkommastellen oder leer.
	 */
	def public static String dblStr5l(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d) || d == 0) {
			return ''
		}
		var str = format("{0,number,#,##0.00000}", d)
		return str
	}

	/**
	 * Konvertierung von double nach String mit 5 Nachkommastellen. 0, keine Zahl oder unendlich liefert einen leeren
	 * String.
	 * <p>
	 * Erstellungsdatum: 17.09.2016
	 * @param d Double-Wert zum Konvertieren.
	 * @return String mit 4 Nachkommastellen oder leer.
	 */
	def public static String dblStr6l(double d) {

		if (Double.isNaN(d) || Double.isInfinite(d) || d == 0) {
			return ''
		}
		var str = format("{0,number,#,##0.000000}", d)
		return str
	}

	/**
	 * Konvertierung von double nach String. Standardmäßig werden 2 Nachkommastellen ausgegeben. Wenn es 3, 4 oder 5
	 * echte Nachkommastellen gibt, werden auch so viele Nachkommastellen ausgegeben. Keine Zahl oder unendlich liefert
	 * einen leeren String.
	 * <p>
	 * Erstellungsdatum: 13.07.2004
	 * @param d Double-Wert zum Konvertieren.
	 * @param nullLeer Wenn true, wird 0,00 als leerer String geliefert.
	 * @return String mit 2, 3, 4 oder 5 Nachkommastellen.
	 */
	def public static String dblStrFormat(double d, boolean nullLeer) {

		var str = ""
		if (Double.isNaN(d) || Double.isInfinite(d) || (nullLeer && d == 0)) {
			return str
		}
		switch (hatXNachkommastellen(d)) {
			case 3:
				str = format("{0,number,#,##0.000}", d)
			case 4:
				str = format("{0,number,#,##0.0000}", d)
			case 5:
				str = format("{0,number,#,##0.00000}", d)
			default:
				str = format("{0,number,#,##0.00}", d)
		}
		return str
	}

	/**
	 * Liefert die Anzahl der Nachkommastellen, maximal 5.
	 * <p>
	 * Erstellungsdatum: 09.11.2004
	 * @param d Zu prüfender Double-Wert.
	 * @return Anzahl der Nachkommastellen, maximal 5.
	 */
	def public static int hatXNachkommastellen(double d) {

		if (d < -1e11 || d > 1e11) {
			// Nachkommastellen wegen Genauigkeit von double nicht mehr
			// feststellbar
			return 0
		}
		var anzNk = 0
		var diff = Math.abs(d)
		diff -= Math.floor(diff)
		var nk = Math.rint(diff * PRUEFEN_5_STELLEN) as int
		if (nk <= 0) {
			return anzNk
		}
		var faktor = PRUEFEN_4_STELLEN
		while (nk > 0) {
			anzNk++
			nk = nk - nk / faktor * faktor
			faktor /= PRUEFEN_1_STELLE
		}
		return anzNk
	}

	/** Faktor zum Prüfen auf 1 Nachkomma-Stelle. */
	private static final int PRUEFEN_1_STELLE = 10
	/** Faktor zum Prüfen auf 4 Nachkomma-Stellen. */
	private static final int PRUEFEN_4_STELLEN = 10000
	/** Faktor zum Prüfen auf 5 Nachkomma-Stellen. */
	private static final double PRUEFEN_5_STELLEN = 100000d

	/** Rundungs-Summand für 2 Nachkomma-Stellen. */
	private static final double RUNDEN_2_STELLEN = 0.005

	/** Rundungs-Summand für 4 Nachkomma-Stellen. */
	private static final double RUNDEN_4_STELLEN = 0.00005

	/**
	 * Ein double-Wert wird in BigDecimal umgewandelt, auf 2 Stellen gerundet. <br>
	 * @param db double-Wert.
	 * @return gerundeter Double-Wert.
	 */
	def public static double round(double db) {

		var bd = new BigDecimal(db)
		var bdr = bd.setScale(2, RoundingMode.HALF_UP)
		return bdr.doubleValue
	}

	/**
	 * Prüft, ob der Wert 3 oder 4 Nachkommastellen hat.
	 * <p>
	 * Erstellungsdatum: 13.07.2004
	 * @param d zu prüfender Double-Wert.
	 * @return Prüfergebnis.
	 */
	def private static boolean hat3Oder4Nachkommastellen(double d) {

		if (d < -1e12 || d > 1e12) {
			// Nachkommastellen wegen Genauigkeit von double nicht mehr feststellbar
			return false
		}
		var diff = Math.abs(d) * Constant.ZAHL_100_0
		diff -= Math.floor(diff + RUNDEN_2_STELLEN)
		return ( diff > RUNDEN_2_STELLEN)
	}

	/**
	 * Konvertierung eines Object in boolean. Falls eine Exception auftriff, wird sie abgefangen und false geliefert.
	 * @param o Beliebiges Object.
	 * @return Konvertierter boolean-Wert.
	 */
	def public static boolean objBool(Object o) {

		var b = false
		if (o !== null) {
			try {
				if (o instanceof Boolean) {
					b = o.booleanValue
				} else if (o instanceof String) {
					val str = o.toString
					if (str.length > 0) {
						if (str.equals("wahr")) {
							b = true
						} else if (str.equals("true")) {
							b = true
						} else if (strInt(str) != 0) {
							b = true
						} else if (str.charAt(0) == 1) {
							// 29.12.06 WK: MySQL-Typ BIT
							b = true
						}
					}
				} else if (o instanceof byte[]) {
					// 05.10.07 WK: MySQL-Typ BIT
					if (o.length > 0 && o.get(0) != 0) {
						b = true
					}
				} else {
					var str = o.toString
					if (strInt(str) != 0) {
						b = true
					}
				}
			} catch (Exception e) {
				machNichts
			}
		}
		return b
	}

	/**
	 * Konvertierung eines boolean-Wertes in String. Falls eine Exception auftriff, wird sie abgefangen und ein leerer
	 * String geliefert.
	 * @param b Beliebiger boolean-Wert.
	 * @return Konvertierter String.
	 */
	def public static String boolStr(boolean b) {

		if (b) {
			return "true"
		}
		return "false"
	}

	/**
	 * Konvertierung eines Object in end-getrimmten String. Falls eine Exception auftritt, wird sie abgefangen und ein
	 * leerer String geliefert.
	 * @param o Beliebiges Object.
	 * @return Konvertierter String.
	 */
	def public static String objStr(Object o) {

		var str = ""
		if (o !== null) {
			try {
				str = o.toString // .trim
				var len = str.length
				if (len > 0) {
					var arr = str.toCharArray
					while ((0 < len) && (arr.get(len - 1) <= ' ')) {
						len--
					}
					if (len < str.length) {
						str = str.substring(0, len)
					}
				}
			} catch (Exception e) {
				str = ""
			}
		}
		return str
	}

	/**
	 * Konvertierung aller Daten in formatierte Strings.
	 * @param objFormat zu formatierende Daten.
	 * @return Formatierter String.
	 */
	def public static String formatString(Object objFormat) {

		if (objFormat === null) {
			return null
		}
		var String str
		if (objFormat instanceof Double) {
			str = format("{0,number,0.00}", objFormat)
		} else if (objFormat instanceof Boolean) {
			if (objFormat.booleanValue) {
				str = "wahr"
			} else {
				str = "falsch"
			}
		} else if (objFormat instanceof LocalDateTime) {
			str = dateTimeStringForm(objFormat)
		} else if (objFormat instanceof LocalDate) {
			str = dateTimeStringForm(objFormat.atStartOfDay)
		} else {
			str = objFormat.toString
		}
		return str
	}

	// Betrags-Funktionen
	/**
	 * Rundet einen Double-Wert auf 2 Nachkommastellen.
	 * <p>
	 * Erstellungsdatum: 13.07.2004
	 * @param d zu rundender Double-Wert.
	 * @return gerundeter Wert.
	 */
	def public static double rundeBetrag(double d) {
		return Math.round(d * Constant.ZAHL_100_0) / Constant.ZAHL_100_0
	}

	/**
	 * Rundet einen Double-Wert auf 4 Nachkommastellen.
	 * <p>
	 * Erstellungsdatum: 01.05.2012
	 * @param d zu rundender Double-Wert.
	 * @return gerundeter Wert.
	 */
	def public static double rundeBetrag4(double d) {
		return Math.round(d * Constant.ZAHL_10000_0) / Constant.ZAHL_10000_0
	}

	/**
	 * Rundet einen Double-Wert auf 6 Nachkommastellen.
	 * <p>
	 * Erstellungsdatum: 17.09.2016
	 * @param d zu rundender Double-Wert.
	 * @return gerundeter Wert.
	 */
	def public static double rundeBetrag6(double d) {
		return Math.round(d * Constant.ZAHL_1000000_0) / Constant.ZAHL_1000000_0
	}

	/**
	 * Rundet einen Double-Wert auf 4 Nachkommastellen.
	 * <p>
	 * Erstellungsdatum: 01.05.2012
	 * @param d zu rundender Double-Wert.
	 * @return gerundeter Wert.
	 */
	def public static byte[] clone(byte[] b) {

		if (b === null) {
			return null
		}
		var l = b.length
		var a = newByteArrayOfSize(l)
		System.arraycopy(b, 0, a, 0, l)
		return a
	}

	// String-Funktionen
	/**
	 * Prüfen, ob String null oder leer ist.
	 * @param str Zu prüfender String.
	 * @return Ist String null oder leer?
	 */
	def public static boolean nes(String str) {
		return str === null || str.length <= 0
	}

	/**
	 * Prüfen, ob String für like leer ist.
	 * @param str Zu prüfender String.
	 * @return Ist String null oder leer oder besteht nur aus %-Zeichen?
	 */
	def public static boolean nesLike(String str) {
		return str === null || str.length <= 0 || str.matches("%+")
	}

	/** Liefert leeren String, wenn null; sonst den String */
	def public static String nn(String s) {
		if(s === null) "" else s
	}

	/**
	 * Liefert str oder null, falls nes(str).
	 * @param str Zu prüfender String.
	 * @return str oder null.
	 */
	def public static String nesString(String str) {

		if (nes(str)) {
			return null
		}
		return str
	}

	/**
	 * Prüfen, ob String null, 'null' oder getrimt ein leerer String ist.
	 * @param str Zu prüfendes Objekt.
	 * @return Ist String null, 'null' oder getrimt leer?
	 */
	def public static boolean excelNes(String str) {
		if (str === null) {
			return true
		}
		var s = str.trim
		return s.length <= 0 || s == 'null'
	}

	/**
	 * if-then-else-Konstruktion als Funktion. Es wird entweder objTrue oder objFalse zurückgeliefert.
	 * @param b True, wenn objTrue benötigt wird; sonst objFalse.
	 * @param objTrue Wert für True-Fall.
	 * @param objFalse Wert für False-Fall.
	 * @return objTrue oder objFalse.
	 */
	def public static String iif(boolean b, String objTrue, String objFalse) {

		if (b) {
			return objTrue
		}
		return objFalse
	}

	// Vergleichs-Funktionen
	/**
	 * Vergleich zweier Double-Werte auf 2 Nachkommastellen liefert<br>
	 * -1, falls d1 < d2;<br>
	 * 0, falls d1 = d2 und<br>
	 * 1, falls d1 > d2.
	 * <p>
	 * Erstellungsdatum: 13.07.2004
	 * @param d1 Erster Double-Wert.
	 * @param d2 Zweiter Double-Wert.
	 * @return -1, 0 oder +1.
	 */
	def public static int compDouble(double d1, double d2) {

		if (d1 < d2 - RUNDEN_2_STELLEN) {
			return -1
		} else if (d1 > d2 + RUNDEN_2_STELLEN) {
			return 1
		} else {
			return 0
		}
	}

	/**
	 * Vergleich zweier Double-Werte auf 4 Nachkommastellen liefert<br>
	 * -1, falls d1 < d2;<br>
	 * 0, falls d1 = d2 und<br>
	 * 1, falls d1 > d2.
	 * <p>
	 * Erstellungsdatum: 14.04.2013
	 * @param d1 Erster Double-Wert.
	 * @param d2 Zweiter Double-Wert.
	 * @return -1, 0 oder +1.
	 */
	def public static int compDouble4(double d1, double d2) {

		if (d1 < d2 - RUNDEN_4_STELLEN) {
			return -1
		} else if (d1 > d2 + RUNDEN_4_STELLEN) {
			return 1
		} else {
			return 0
		}
	}

	/**
	 * Vergleich zweier Strings liefert<br>
	 * 0, falls s1 = s2 und<br>
	 * 1, falls s1 != s2.<br>
	 * Dabei wird nicht zwischen leerem String und null unterschieden.
	 * <p>
	 * Erstellungsdatum: 31.12.2007
	 * @param s1 Erster String-Wert.
	 * @param s2 Zweiter String-Wert.
	 * @return 0 oder +1.
	 */
	def public static int compString(String s1, String s2) {

		if (nes(s1) != nes(s2)) {
			return 1
		}
		if (!nes(s1) && !s1.equals(s2)) {
			return 1
		}
		return 0
	}

	/**
	 * Vergleich zweier Strings liefert<br>
	 * <0, falls s1 < s2 und<br>
	 * =0, falls s1 = s2 und<br>
	 * >0, falls s1 > s2.<br>
	 * Dabei wird nicht zwischen leerem String und null unterschieden.
	 * <p>
	 * Erstellungsdatum: 31.12.2007
	 * @param s1 Erster String-Wert.
	 * @param s2 Zweiter String-Wert.
	 * @return -1, 0 oder +1.
	 */
	def public static int compString2(String s1, String s2) {

		if (nes(s1) && nes(s2)) {
			return 0
		}
		if (nes(s1)) {
			return -1
		}
		if (nes(s2)) {
			return 1
		}
		return s1.compareTo(s2)
	}

	/**
	 * Prüft, ob eine Zahl im Intervall von zwei Zahlen (einschließlich) liegt.
	 * @return Liegt die Zahl im Intervall?.
	 */
	def public static boolean in(int i, int von, int bis) {

		if (von <= i && i <= bis) {
			return true
		}
		return false
	}

	/**
	 * Liefert einen String, der mit MessageFormat und Parameter zusammengesetzt wird.
	 * @param pattern Muster-String.
	 * @param objs beliebig viele Parameter.
	 * @return Zusammengesetzter String.
	 */
	def public static String format(String pattern, Object... objs) {

		if (pattern === null) {
			return null
		}
		return MessageFormat.format(pattern, objs)
	}

	/**
	 * Zusammenbau eines String. Das Objekt wird immer zu dem StringBuffer hinzugefügt. Der Füll-String wirden vor dem
	 * Objekt eingefügt, wenn StringBuffer und Objekt nicht leere Strings darstellen.
	 * <p>
	 * <b>Beispiele </b>:<br>
	 * strB.append("Name"); anhaengen(strB, ", ", "Vorname"); <br>
	 * liefert: strB = "Name, Vorname";<br>
	 * strB.append("Name"); anhaengen(strB, ", ", "");<br>
	 * liefert: strB = "Name";<br>
	 * @param strB StringBuffer zum Anhängen.
	 * @param filler Erster Füll-String.
	 * @param obj String, der immer angehängt wird.
	 * @return Gleichen StringBuffer.
	 */
	def public static StringBuffer anhaengen(StringBuffer strB, String filler, String obj) {

		if (strB !== null) {
			var strObj = objStr(obj)
			if (strB.length > 0 && strObj.length > 0) {
				if (!nes(filler)) {
					strB.append(filler)
				}
			}
			strB.append(strObj)
		}
		return strB
	}

	/**
	 * Zusammenbau eines Strings. Das Objekt wird immer zu dem StringBuffer hinzugefügt. Die Füll-Strings werden vor und
	 * hinter dem Objekt eingefügt, wenn StringBuffer und Objekt nicht leere Strings darstellen.
	 * <p>
	 * <b>Beispiele </b>:<br>
	 * strB = "Name"; anhaengen(strB, ", ", "Vorname", "");<br>
	 * liefert: strB = "Name, Vorname";<br>
	 * strB = "Name"; anhaengen(strB, ", ", "", "");<br>
	 * liefert: strB = "Name";<br>
	 * strB = "Name"; anhaengen(strB, " (", "Titel", ")");<br>
	 * liefert: strB = "Name (Vorname)";<br>
	 * @param strB StringBuffer zum Anhängen.
	 * @param filler1 Erster Füll-String.
	 * @param obj Objekt, das immer angehängt wird.
	 * @param filler2 Zweiter Füll-String.
	 * @return Gleichen StringBuffer.
	 */
	def public static StringBuffer anhaengen(StringBuffer strB, String filler1, String obj, String filler2) {

		if (strB !== null) {
			var strObj = objStr(obj)
			if (strB.length > 0 && strObj.length > 0) {
				if (!nes(filler1)) {
					strB.append(filler1)
				}
				strB.append(strObj)
				if (!nes(filler2)) {
					strB.append(filler2)
				}
			} else {
				strB.append(strObj)
			}
		}
		return strB
	}

	/**
	 * Zusammenbau eines String aus zwei Objekten. Nur wenn beide Objekte nicht leere Strings darstellen, wird der
	 * Füll-String dazwischen eingefügt.
	 * <p>
	 * @param objB Erstes Objekt.
	 * @param filler Erster Füll-String.
	 * @param obj Zweites Objekt.
	 * @return Zusammengesetzter String.
	 */
	def public static String anhaengen(String objB, String filler, String obj) {

		var strObjB = objStr(objB)
		var strObj = objStr(obj)
		if (strObjB.length > 0 && strObj.length > 0) {
			if (!nes(filler)) {
				strObjB += filler
			}
		}
		strObjB += strObj
		return strObjB
	}

	/**
	 * Liefert einen String von bestimmter Länge. Es wird rechts abgeschnitten. Aufgefüllt werden kann von beiden
	 * Seiten.
	 * @param strT Zu bearbeitender String.
	 * @param laenge Vorgegebene Länge.
	 * @param rechtsAuffuellen True, wenn rechts aufgefüllt wird; sonst links.
	 * @param strFuellen String, mit dem aufgefüllt werden soll.
	 * @return String der angeforderten Länge.
	 */
	def public static String fixiereString(String strT, int laenge, boolean rechtsAuffuellen, String strFuellen) {

		var str = strT
		var strFuellung = strFuellen
		var l = laenge

		if (l < 0) {
			l = 0
		}
		if (str !== null && str.length < l) {
			var strB = new StringBuffer(str)
			if (nes(strFuellung)) {
				strFuellung = " "
			}
			while (strB.length < l) {
				if (rechtsAuffuellen) {
					strB.append(strFuellung)
				} else {
					if (strB.length + strFuellung.length > l) {
						strB.insert(0, strFuellung.substring(0, l - strFuellung.length + 1))
					} else {
						strB.insert(0, strFuellung)
					}
				}
			}
			str = strB.toString
		}
		if (str !== null && str.length > l) {
			str = str.substring(0, l)
		}
		return str
	}

	/**
	 * Anhängen eines Kommas an einen StringBuffer, falls dieser nicht leer ist.
	 * @param strB StringBuffer.
	 * @return Gleiche StringBuffer-Instanz.
	 */
	def public static StringBuffer appendKomma(StringBuffer strB) {

		if (strB !== null && strB.length > 0) {
			strB.append(",")
		}
		return strB
	}

	/**
	 * Sucht einen String-Ausschnitt zwischen anfang und ende.
	 * @param str Zu durchsuchender String.
	 * @param anfang Zu suchender Anfangsstring.
	 * @param ende Zu suchender Endestring.
	 * @param endevorhanden Muss der Endestring vorhanden sein?
	 * @return String-Ausschnitt zwischen anfang und ende.
	 */
	def public static String stringAusschnitt(String str, String anfang, String ende, boolean endevorhanden) {

		if (nes(str)) {
			return null
		}
		var re = new StringBuilder
		if (!nes(anfang)) {
			re.append(".*").append(Pattern.quote(anfang))
		}
		re.append("(.*)") // Mittelteil gesucht
		if (!nes(ende)) {
			if (!endevorhanden) {
				re.append("(")
			}
			re.append(Pattern.quote(ende))
			if (!endevorhanden) {
				re.append(")?")
			}
		}
		re.append(".*") // Ende egal
		var p = Pattern.compile(re.toString, Pattern.CASE_INSENSITIVE)
		var m = p.matcher(str)
		if (m.find) {
			var s = m.group(1)
			return s
		}
		return null
	}

	// Datum-Funktionen
	/**
	 * Liefert letzten Werktag (nicht Samstag und Sonntag), der am Datum oder davor liegt.
	 * @param d Betroffenes Datum.
	 * @return Datums-String.
	 */
	def public static LocalDate werktag(LocalDate d) {

		var d0 = d
		if (d0 === null) {
			d0 = LocalDate::now
		}
		while (d0.dayOfWeek == DayOfWeek.SATURDAY || d0.dayOfWeek == DayOfWeek.SUNDAY) {
			d0 = d0.minusDays(1)
		}
		return d0
	}

	/**
	 * Liefert nächsten Sonntag, der am Datum oder danach liegt.
	 * @param d Betroffenes Datum.
	 * @return Datums-String.
	 */
	def public static LocalDate sonntag(LocalDate d) {

		var d0 = d
		if (d0 === null) {
			d0 = LocalDate::now
		}
		while (d0.dayOfWeek != DayOfWeek.SUNDAY) {
			d0 = d0.plusDays(1)
		}
		return d0
	}

	/**
	 * Liefert Datum im Format dd.MM.yyyy.
	 * @param d Zu konvertierendes Datum.
	 * @return Datums-String.
	 */
	def public static String dateString(LocalDate d) {

		if (d === null) {
			return ""
		}
		var str = d.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"))
		return str
	}

	/**
	 * Liefert Datum im Format yyyy-MM-dd.
	 * @param d Zu konvertierendes Datum.
	 * @return Datums-String.
	 */
	def public static String dateString0(LocalDate d) {

		if (d === null) {
			return ""
		}
		var str = d.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
		return str
	}

	/**
	 * Liefert Datum im Format dd.MM.yyyy HH:mm:ss.
	 * @param d Zu konvertierendes Datum mit Uhrzeit.
	 * @return Datums-String.
	 */
	def public static String dateTimeString(LocalDateTime d) {

		if (d === null) {
			return ""
		}
		var str = d.format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss"))
		return str
	}

	/**
	 * Liefert Datum im Format dd.MM.yyyy HH:mm:ss, dd.MM.yyyy HH:mm oder dd.MM.yyyy, je nachdem, ob es eine Uhrzeit
	 * ungleich 00:00:00 gibt oder nicht. Falls das Datum null ist oder gleich dem 0-Datum, wird ein leerer String
	 * geliefert.
	 * @param d Zu konvertierendes Datum mit Uhrzeit.
	 * @return Datums-String.
	 */
	def public static String dateTimeStringForm(LocalDateTime d) {

		if (d === null) {
			return ""
		}
		var str = ""
		if (d.hour == 0 && d.minute == 0 && d.second == 0) {
			str = d.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"))
		} else if (d.second == 0) {
			str = d.format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm"))
		} else {
			str = d.format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss"))
		}
		return str
	}

	/**
	 * Liefert einen möglichst kurzen String mit Zeitraum.
	 * @param von Anfangsdatum.
	 * @param bis Enddatum.
	 * @param monate Soll die Anzahl der Monate in Klammern angefügt werden.
	 * @return Zeitraum als String.
	 */
	def public static String getPeriodeString(LocalDate von, LocalDate bis, boolean monate) {

		var sb = new StringBuilder

		if (von !== null && bis !== null) {
			if (von.dayOfMonth != 1 || bis.dayOfMonth != bis.lengthOfMonth) {
				if (von.year == bis.year) {
					sb.append(von.format(DateTimeFormatter.ofPattern("dd.MM.-")))
					sb.append(bis.format(DateTimeFormatter.ofPattern("dd.MM.yyyy")))
				} else {
					sb.append(von.format(DateTimeFormatter.ofPattern("dd.MM.yyyy-")))
					sb.append(bis.format(DateTimeFormatter.ofPattern("dd.MM.yyyy")))
				}
			} else if (von.year == bis.year) {
				if (von.monthValue == bis.monthValue) {
					sb.append(von.format(DateTimeFormatter.ofPattern("MMMM yyyy")))
				} else if (von.monthValue == 1 && bis.monthValue == 12) {
					sb.append(von.format(DateTimeFormatter.ofPattern("yyyy")))
				} else {
					sb.append(von.format(DateTimeFormatter.ofPattern("MMMM-")))
					sb.append(bis.format(DateTimeFormatter.ofPattern("MMMM yyyy")))
				}
			} else {
				sb.append(von.format(DateTimeFormatter.ofPattern("MMMM yyyy-")))
				sb.append(bis.format(DateTimeFormatter.ofPattern("MMMM yyyy")))
			}
			if (monate) {
				var mon = Global.monatsDifferenz(von, bis)
				sb.append(" (").append(mon).append(" Monat")
				if (mon != 1) {
					sb.append("e")
				}
				sb.append(")")
			}
		} else if (von !== null) {
			sb.append(von.format(DateTimeFormatter.ofPattern("dd.MM.yyyy")))
		}
		return sb.toString
	}

	/**
	 * Konvertierung eines Strings in LocalDateTime. Falls eine Exception auftritt, wird sie abgefangen und null geliefert.
	 * @param obj Beliebiger String.
	 * @return Konvertiertes LocalDateTime.
	 */
	def public static LocalDateTime objDat(String obj) {

		var LocalDateTime d
		if (obj !== null) {
			var str = objStr(obj)
			try {
				d = LocalDateTime.parse(str, DateTimeFormatter.ofPattern("d.M.y HH:mm:ss"))
			} catch (Exception ex) {
				machNichts
			}
			if (d === null) {
				try {
					// parst auch 1.2.2004
					var d2 = LocalDate.parse(str, DateTimeFormatter.ofPattern("d.M.y"))
					d = d2.atStartOfDay
				} catch (Exception exc) {
					machNichts
				}
			}
		}
		return d
	}

	/**
	 * Konvertierung eines Strings in LocalDateTime. Falls eine Exception auftritt, wird sie abgefangen und null geliefert.
	 * @param str Beliebiger String.
	 * @return Konvertiertes LocalDateTime.
	 */
	def public static LocalDateTime strdat(String str) {

		var LocalDateTime d
		if (str !== null) {
			try {
				d = LocalDateTime.parse(str, DateTimeFormatter.ofPattern("y-M-d HH:mm:ss"))
			} catch (Exception ex) {
				machNichts
			}
			if (d === null) {
				try {
					// parst auch 2004-2-1
					var d2 = LocalDate.parse(str, DateTimeFormatter.ofPattern("y-M-d"))
					d = d2.atStartOfDay
				} catch (Exception exc) {
					machNichts
				}
			}
			if (d === null) {
				d = objDat(str)
			}
		}
		return d
	}

	/**
	 * Konvertierung eines Strings in LocalDate. Falls eine Exception auftritt, wird sie abgefangen und null geliefert.
	 * @param obj Beliebiger String.
	 * @return Konvertiertes LocalDate.
	 */
	def public static LocalDate objDat2(String obj) {

		var LocalDate d
		if (obj !== null) {
			var str = objStr(obj)
			try {
				// parst auch 1.2.2004
				d = LocalDate.parse(str, DateTimeFormatter.ofPattern("d.M.yy"))
			} catch (Exception exc) {
				machNichts
			}
		}
		return d
	}

	/**
	 * Liefert den Wochentag als langen Text, z.B. Samstag.
	 * @param d Datum.
	 * @return Wochentag als Text.
	 */
	def public static String holeWochentag(LocalDate d) {

		if (d === null) {
			return ""
		}
		var str = d.format(DateTimeFormatter.ofPattern("EEEE"))
		return str
	}

	/**
	 * Liefert die Anzahl der Monate zwischen zwei Datumswerten.
	 * @param von 1. Datum.
	 * @param bis 2. Datum.
	 * @return Anzahl der Monate zwischen zwei Datumswerten.
	 */
	def public static int monatsDifferenz(LocalDate von, LocalDate bis) {

		if ((von === null) != (bis === null)) {
			return -1
		}
		if (von === null || von.equals(bis)) {
			return 0
		}
		var m = 0
		m = 12 * von.year + von.monthValue
		var b = bis.plusDays(1)
		m -= 12 * b.year + b.monthValue
		if (m < 0) {
			m = -m
		}
		return m
	}

	// Verschlüsselungs-Funktionen
	/**
	 * Verschlüsseln eines Strings.
	 * @param s
	 * @return Verschlüsselter String.
	 */
	def public static String encryptString(String s) {

		if (nes(s)) {
			return s
		}
		var bytes = s.getBytes(Charset.forName("UTF-8"))
		// Methode 1: XOR und Base64
		bytes = xorMessage(bytes, getXorKeybytes)
		if (bytes !== null) {
			var str = Base64.encoder.encodeToString(bytes)
			return "1;" + str
		}
		return null
	}

	/**
	 * Entschlüsseln eines Strings.
	 * @param s
	 * @return Entschlüsselter String.
	 */
	def public static String decryptString(String s) {

		if (nes(s)) {
			return s
		}
		if (s.startsWith("1;")) {
			// Methode 1: XOR und Base64
			try {
				var bytes = Base64.decoder.decode(s.substring(2))
				bytes = xorMessage(bytes, xorKeybytes)
				var str = new String(bytes, "UTF-8")
				return str
			} catch (UnsupportedEncodingException e) {
			}
		}
		return s
	}

	val private static String XorKey = "W. Kühl"
	var private static byte[] XorKeybytes = null

	def private static byte[] getXorKeybytes() {

		if (XorKeybytes === null) {
			XorKeybytes = XorKey.getBytes(Charset.forName("UTF-8"))
		}
		return XorKeybytes
	}

	def public static byte[] xorMessage(byte[] message, byte[] key) {

		if (message === null || message.length <= 0 || key === null || key.length <= 0) {
			return null
		}

		var ml = message.length
		var kl = key.length
		for (i : 0 ..< ml) {
			// message.set(i, (message.get(i) ^ key.get(i % kl)))
			message.set(i, (message.get(i).bitwiseXor(key.get(i % kl))) as byte)
		}
		return message
	}

	// Datei-Funktionen
	/**
	 * Liefert Dateiinhalt als Bytes.
	 * @param datei Dateiname inkl. Pfad darf nicht leer sein.
	 * @return Dateiinhalt als Bytes.
	 * @throws Exception im unerwarteten Fehlerfalle.
	 */
	def public static byte[] leseBytes(String datei) throws Exception {

		if (nes(datei)) {
			throw new Exception(Meldungen::M1012)
		}
		var file = new File(datei)
		return leseBytes(file, new FileInputStream(file), Integer.MAX_VALUE)
	}

	/**
	 * Liefert Dateiinhalt als Bytes.
	 * @param file Datei als File.
	 * @param is Datei als InputStream.
	 * @param max Maximale Länge der Datei.
	 * @return Dateiinhalt als Bytes.
	 * @throws Exception im unerwarteten Fehlerfalle.
	 */
	def public static byte[] leseBytes(File file, InputStream is, int max) throws Exception {

		if (file === null || is === null) {
			throw new Exception(Meldungen::M1012)
		}
		var byte[] bytes

		try {
			// Get the size of the file
			var length = file.length
			if (length > max) {
				throw new Exception(Meldungen::M1014(file.name))
			}

			// Byte-Array anlegen
			bytes = newByteArrayOfSize(length.intValue)

			// Bytes lesen
			var offset = 0
			var numRead = 0
			while (numRead >= 0 && offset < bytes.length) {
				numRead = is.read(bytes, offset, bytes.length - offset)
				if (numRead >= 0) {
					offset += numRead
				}
			}
			// Alles gelesen?
			if (offset < bytes.length) {
				throw new IOException(Meldungen::M1015(file.name))
			}
		} finally {
			// Close the input stream and return bytes
			is.close
		}
		return bytes
	}

	// CSV-Funktionen
	/**
	 * Kodierung eines Vektor von Strings in einen String, die eine Zeile von komma-separierten Feldern mit Zeilenende.
	 * @param felder Vektor von Strings
	 * @return Zeile von komma-separierten Feldern mit Zeilenende.
	 */
	def public static String encodeCSV(List<String> felder) {

		if (felder !== null && felder.size > 0) {
			var csv = new StringBuffer
			for (f : felder) {
				if (csv.length > 0) {
					csv.append(";")
				}
				csv.append("\"")
				if (f === null) {
					csv.append("null")
				} else {
					csv.append(f.replace("\"", "\"\""))
				}
				csv.append("\"")
			}
			csv.append(Constant.CRLF)
			return csv.toString
		}
		return null
	}

	/**
	 * Liefert das i-te Zeichen eines Strings oder 0, wenn String keine i Zeichen hat.
	 * @param str String darf nicht null sein.
	 * @param i Nummer des Zeichens beginnend mit 0.
	 * @return Liefert das i-te Zeichen eines Strings oder 0, wenn String keine i Zeichen hat.
	 */
	def private static char holZeichen(String str, int i) {

		if (i < str.length) {
			return str.charAt(i)
		}
		return 0 as char
	}

	/** Anfangszustand. */
	private static final int Z_ANFANG = 0
	/** Zeichenkette mit ". */
	private static final int Z_ZK_ANFANG = 10
	/** Zeichenketten-Ende oder erstes doppeltes ". */
	private static final int Z_ZK_ENDE = 20
	// /** Feldende. */
	// private static final int Z_FELD_ENDE = 30
	/** Zeichenketten ohne ". */
	private static final int Z_ZEICHENKETTE = 50
	/** Zeilenende-Anfang. */
	private static final int Z_ENDE_ANFANG = 90
	/** Zeilenende-Ende. */
	private static final int Z_ENDE_ENDE = 95

	/**
	 * Dekodierung einer CSV-Datei-Zeile als String in einen Vektor von Strings.
	 * @param csv CSV-Datei-Zeile als String.
	 * @return Vektor von Strings.
	 * @throws Exception bei einem Parse-Fehler.
	 */
	def public static List<String> decodeCSV(String csv) throws Exception {

		if (csv === null || csv.length <= 0) {
			return null
		}

		var felder = new ArrayList<String>
		var zustand = Z_ANFANG
		var i = 0
		var char zeichen
		val char anf = '"'
		val char semi = ';'
		val char komma = ','
		val char cr = '\r'
		val char lf = '\n'
		var ende = false
		var feld = new StringBuffer
		do {
			zeichen = holZeichen(csv, i)
			switch (zustand) {
				case Z_ANFANG: // Anfangszustand
					if (zeichen == 0) {
						i--
						zustand = Z_ENDE_ENDE // Zeilenende-Ende
					} else if (zeichen == anf) {
						zustand = Z_ZK_ANFANG
					} else if (zeichen == semi || zeichen == komma) {
						felder.add(feld.toString)
						feld.setLength(0)
					} else if (zeichen == cr || zeichen == lf) {
						zustand = Z_ENDE_ANFANG // Zeilenende-Anfang
					} else {
						zustand = Z_ZEICHENKETTE // normale Zeichenkette ohne "
						i--
					}
				case Z_ZK_ANFANG: // Zeichenkette mit "
					if (zeichen == 0) {
						// Zeichenkette nicht zu Ende: Parse-Error
						// i--
						zustand = Z_ENDE_ENDE // Zeilenende-Ende
					} else if (zeichen == anf) {
						zustand = Z_ZK_ENDE
					} else {
						feld.append(zeichen)
					}
				case Z_ZK_ENDE: // Zeichenketten-Ende oder erstes doppeltes "
					if (zeichen == 0) {
						i--
						zustand = Z_ENDE_ENDE // Zeilenende-Ende
					} else if (zeichen == anf) {
						feld.append(zeichen)
						zustand = Z_ZK_ANFANG
					} else if (zeichen == semi || zeichen == komma) {
						zustand = Z_ANFANG
						felder.add(feld.toString)
						feld.setLength(0)
					} else if (zeichen == cr || zeichen == lf) {
						i--
						zustand = Z_ENDE_ANFANG // Zeilenende-Anfang
					} else {
						throw new Exception(Meldungen::M1019(i, csv))
					}
				// case Z_FELD_ENDE: // Feldende
				// i--
				// zustand = Z_ANFANG
				// felder.add(feld.toString)
				// feld.setLength(0)
				// break
				case Z_ZEICHENKETTE: // Zeichenketten ohne "
					if (zeichen == 0) {
						i--
						zustand = Z_ENDE_ENDE // Zeilenende-Ende
					} else if (zeichen == semi || zeichen == komma) {
						zustand = Z_ANFANG
						felder.add(feld.toString)
						feld.setLength(0)
					} else {
						feld.append(zeichen)
					}
				case Z_ENDE_ANFANG: // Zeilenende-Anfang
					if (!(zeichen == cr || zeichen == lf)) {
						i--
						zustand = Z_ENDE_ENDE
					}
				case Z_ENDE_ENDE: // Zeilenende-Ende
				{
					ende = true
					felder.add(feld.toString)
					feld.setLength(0)
				}
			// default:
			// machNichts
			}
			if (!ende) {
				i++
				if (i > csv.length) {
					throw new Exception(Meldungen::M1020(csv))
				}
			}
		} while (!ende)
		return felder
	}

	// Sonstige Funktionen
	/**
	 * Liefert UID. Ein führendes Minuszeichen wird am Ende angehängt, z.B. 297f9764:141887cfc37:-8000-.
	 * @return Liefert UID.
	 */
	def public static String getUID() {

		var uid = new UID().toString
		if (uid.startsWith("-")) {
			// Wegen Jet-Engine-Sortierung wird Minuszeichen ans Ende gehängt.
			uid = uid.substring(1) + "-"
		}
		return uid
	}

	/**
	 * Liefert eine neue Zufallszahl.
	 * @return eine neue Zufallszahl.
	 */
	def public static long getNextRandom() {

		var l = random.nextLong
		return Math.abs(l)
	}

	/**
	 * Liefert einen Dateinamen mit aktuellem Datum und Zufallszahl.
	 * @param name Name am Anfang.
	 * @param datum Soll das aktuelle Datum eingefügt werden?
	 * @param zufall Soll eine Zufallszahl eingefügt werden?
	 * @param endung Dateiendung ohne Punkt.
	 * @return Dateiname.
	 */
	def public static String getDateiname(String name, boolean datum, boolean zufall, String endung) {

		var sb = new StringBuffer

		if (!nes(name)) {
			sb.append(name)
		}
		if (datum) {
			sb.append("_").append(LocalDate::now.format(DateTimeFormatter.ofPattern("yyyyMMdd")))
		}
		if (zufall) {
			sb.append("_").append(getNextRandom)
		}
		if (!nes(endung)) {
			sb.append(".").append(endung)
		}
		return sb.toString
	}

	/**
	 * Liefert die Eigenschaft aus einer Manifest-Datei. Falls die Datei nicht gelesen werden kann oder die Eigenschaft
	 * nicht vorhanden ist, wird der String 'Unbekannt' geliefert.
	 * @param clazz Klasse zum Lesen über getResourceAsStream.
	 * @param strManifest Name der Manifest-Datei inkl. Pfad.
	 * @param key Schlüssel der Eigenschaft.
	 * @return Eigenschaft als String.
	 */
	def public static String getManifestProperty(Class<?> clazz, String strManifest, String key) {

		var str = "Unbekannt"
		try {
			var url = clazz.protectionDomain.codeSource.location
			str += " " + url.path
			var file = new File(url.path)
			var JarFile jar
			try {
				jar = new JarFile(file)
				var manifest = jar.manifest
				str += " " + manifest.toString
				var attributes = manifest.mainAttributes
				str += " " + getAttributes(attributes)
				if (attributes.getValue(key) !== null) {
					str = attributes.getValue(key)
					return str
				}
			} finally {
				if (jar !== null) {
					jar.close
				}
			}
		} catch (Exception e) {
			Global.machNichts
		}
		return str
	}

	def private static String getAttributes(Attributes attributes) {

		var sb = new StringBuffer
		for (i : attributes.keySet) {
			var k = i.toString
			if (sb.length > 0) {
				sb.append("; ")
			}
			sb.append(k).append("=").append(attributes.getValue(k))
		}
		return sb.toString
	}

	/**
	 * Liefert die List-Größe.
	 * @param array Zu behandelnde List.
	 * @return List-Größe.
	 */
	def public static int listLaenge(List<?> list) {

		if (list === null) {
			return 0
		}
		return list.size
	}

	def public static String getExceptionText(Throwable ex) {

		var String str
		if (ex === null) {
			str = Meldungen::M1016
		} else {
			str = ex.message
			if (Global.nes(str)) {
				// ex.printStackTrace
				str = ex.toString
			}
		}
		return str
	}

	/**
	 * Umrechnung eines Euro-Betrages in DM.
	 * @param euro Betrag in Euro.
	 * @return Konvertierter Betrag in DM.
	 */
	def public static double konvDM(double euro) {

		return Math.round(euro * Constant.EUROFAKTOR * Constant.ZAHL_100_0) / Constant.ZAHL_100_0
	}

	/**
	 * Umrechnung eines DM-Betrages in Euro.
	 * @param dm Betrag in DM.
	 * @return Konvertierter Betrag in Euro.
	 */
	def public static double konvEURO(double dm) {

		return Math.round(dm / Constant.EUROFAKTOR * Constant.ZAHL_100_0) / Constant.ZAHL_100_0
	}

	/**
	 * if-then-else-Konstruktion als Funktion. Es wird entweder objTrue oder objFalse zurückgeliefert.
	 * @param b True, wenn objTrue benötigt wird; sonst objFalse.
	 * @param objTrue Wert für True-Fall.
	 * @param objFalse Wert für False-Fall.
	 * @return objTrue oder objFalse.
	 */
	def public static double iif(boolean b, double objTrue, double objFalse) {

		if (b) {
			return objTrue
		}
		return objFalse
	}

	/**
	 * Prüft, ob ein String komplett aus einer Zahl besteht. Vorzeichen, Punkt, Komma, Nachkommastellen sind möglich.
	 * @param str Zu prüfender String.
	 * @return true, wenn String einer Zahl entspricht.
	 */
	def public static boolean isNumeric(String str) {

		if (nes(str)) {
			return false
		}
		return str.matches("^[\\-+]?\\d+([\\.,]\\d+)?$")
	}

	/**
	 * Zusammensetzen eines Ahnennamens aus Ahnen-Nummer, Geburtsnamen und Vornamen.
	 * @param uid Ahnen-Nummer.
	 * @param strG Geburtsname.
	 * @param strV Vorname.
	 * @param nameFett Soll der Name fett geschrieben werden?
	 * @param xref Soll der Name fett geschrieben werden?
	 * @return Zusammengesetzter Ahnenname.
	 */
	def public static String ahnString(String uid, String strG, String strV, boolean nameFett, boolean xref) {

		if (Global.nes(uid)) {
			return ""
		}
		var sb = new StringBuffer
		if (nameFett) {
			sb.append("<b>")
		}
		if (!nes(strG)) {
			sb.append(strG)
			if (!nes(strV)) {
				sb.append(", ")
			}
		}
		if (!nes(strV)) {
			sb.append(strV)
		}
		if (nameFett) {
			sb.append("</b>")
		}
		sb.append(" (")
		sb.append(if(xref) toXref(uid) else uid)
		sb.append(")")
		return sb.toString
	}

	/**
	 * Liefert XREF aus Uid. Dabei wird Doppelpunkt durch Semikolon ersetzt.
	 * @param uid Uid aus Programm.
	 * @return xref.
	 */
	def public static String toXref(String uid) {

		if (nes(uid)) {
			return null
		}
		return uid.replace(':', ';')
	}

	/**
	 * Liefert Uid aus XREF. Dabei wird Semikolon durch Doppelpunkt ersetzt.
	 * @param xref XREF aus Gedcom-Schnittstelle.
	 * @return Uid.
	 */
	def public static String toUid(String xref) {

		if (nes(xref)) {
			return null
		}
		return xref.replace(';', ':')
	}

	/**
	 * Vergleicht zwei int-Werte mit Hilfe eines Operators.
	 * @param variable Linker int-Wert bei Vergleich.
	 * @param operator String mit <, <=, =, > oder >=; null entspricht =.
	 * @param wert Rechter int-Wert bei Vergleich.
	 * @return True, wenn Vergleich stimmt; sonst false.
	 */
	def public static boolean vergleicheInt(int variable, String operator, int wert) {

		var rc = false
		if (operator === null || operator.equals("=")) {
			rc = variable == wert
		} else if (operator.equals("<=")) {
			rc = variable <= wert
		} else if (operator.equals("<")) {
			rc = variable < wert
		} else if (operator.equals(">=")) {
			rc = variable >= wert
		} else if (operator.equals(">")) {
			rc = variable > wert
		}
		return rc
	}

	/**
	 * Prüft, ob das Programm mit JNLP Web Start läuft.
	 * @return Läuft das Programm mit JNLP Web Start?
	 */
	def public static boolean isWebStart() {
		return System.getProperty("jnlpx.home") !== null
	}

	/** Nummer für Betriebssystem. */
	private static int betriebssystem = 0

	/** Betriebssystem-Bezeichnung. */
	private static String osName = null

	/**
	 * Liefert die Betriebssystem-Bezeichnung.
	 * @return die Betriebssystem-Bezeichnung.
	 */
	def public static String getOsName() {

		if (nes(osName)) {
			osName = System.getProperty("os.name").toLowerCase
		}
		return osName
	}

	/**
	 * Setzen der Betriebssystem-Bezeichnung.
	 * @param osName Neue Betriebssystem-Bezeichnung.
	 */
	def public static void setOsName(String osName) {

		Global.osName = osName
		if (!nes(osName)) {
			Global.osName = Global.osName.toLowerCase
		}
		betriebssystem = 0
	}

	/**
	 * Liefert das Betriebssystem als Zahl: 1: Windows; 2: Linux.
	 * @return Liefert das Betriebssystem als Zahl.
	 */
	def private static int getBetriebssystem() {

		if (betriebssystem == 0) {
			if (getOsName.equals("linux")) {
				betriebssystem = 2
			} else {
				betriebssystem = 1
			}
		}
		return betriebssystem
	}

	/**
	 * Liefert True, wenn Betriebssystem Windows ist.
	 * @return Liefert True, wenn Betriebssystem Windows ist.
	 */
	def public static boolean istWindows() {
		return getBetriebssystem == 1
	}

	/**
	 * Liefert True, wenn Betriebssystem Linux ist.
	 * @return Liefert True, wenn Betriebssystem Linux ist.
	 */
	def public static boolean istLinux() {
		return getBetriebssystem == 2
	}

	def public static ResourceBundle getBundle() {

		if (bundle === null) {
			bundle = ResourceBundle.getBundle("dialog.Jhh6")
		}
		return bundle
	}

	/**
	 * Liefert lokalisierte String-Resource aus Bundle dialog.Jhh6.
	 * Unterstriche werden entfernt.
	 */
	def public static String g(String s) {
		return g0(s, true)
	}

	/**
	 * Liefert lokalisierte String-Resource aus Bundle dialog.Jhh6.
	 */
	def public static String g0(String s) {
		return g0(s, false)
	}

	/**
	 * Liefert lokalisierte String-Resource aus Bundle dialog.Jhh6.
	 * Unterstriche können entfernt werden.
	 */
	def public static String g0(String s, boolean no_) {

		var w = getBundle.getString(s)
		if (no_ && !Global.nes(w)) {
			w = w.replace("_", "")
		}
		return w
	}

	/** Hat das Resource-Bundle den Schlüssel? */
	def public static boolean hasg(String key) {
		return getBundle.containsKey(key)
	}
}

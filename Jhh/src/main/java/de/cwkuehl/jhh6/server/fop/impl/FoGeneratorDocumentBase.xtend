package de.cwkuehl.jhh6.server.fop.impl

import de.cwkuehl.jhh6.api.message.Meldungen
import java.io.IOException
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.ArrayList
import java.util.Base64
import java.util.Locale
import javax.xml.transform.Source
import de.cwkuehl.jhh6.api.global.Global

/** 
 * Mit dieser Klasse wird ein FO-Dokument im XML-Format erzeugt.
 */
class FoGeneratorDocumentBase {

	// private static Log log = LogFactory.getLog(FoGeneratorDocumentBase.class);
	/** 
	 * Namespace URI für XSL-FO. 
	 */
	protected static String foNS = "http://www.w3.org/1999/XSL/Format"
	FoGeneratorDocumentStream fds = null
	static String FONTNAME = "Helvetica"
	String multiName = null
	boolean resetPageNumber = false

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		fds = new FoGeneratorDocumentStream
	}

	/** 
	 * Das Löschen des Streams sollte zu Beginn eines Dokuments gemacht werden.
	 */
	def void clear() {
		fds.clear
	}

	/** 
	 * Anhängen von Attributen.
	 * @param attrNameValue Name und Wert der Attribute.
	 * @throws IOException
	 */
	def private void appendAttribute(String... attrNameValue) throws IOException {

		if (attrNameValue !== null) {
			var anzahl = attrNameValue.length / 2
			for (var i = 0; i < anzahl; i++) {
				if (attrNameValue.get(i + i) !== null) {
					fds.append(getAttribut(attrNameValue.get(i + i), attrNameValue.get(i + i + 1)))
				}
			}
		}
	}

	/** 
	 * Liefert Attribut-Array für Font-Eigenschaften, die nicht null sind.
	 * @param fontname font-family null heißt Helvetica (Arial fast identisch)
	 * @param size Größe in Point (pt)
	 * @param weight Gewicht (normal oder bold)
	 * @param style Stil (normal oder italic)
	 * @param lineheight Zeilenabstand in Point (pt) kann 0 sein, dann size+1.
	 * @return Attribut-Array für Font-Eigenschaften oder null.
	 */
	def private String[] getFontArray(String fontname, int size, String weight, String style, int lineheight) {

		var array = new ArrayList<String>
		if (fontname !== null) {
			array.add("font-family")
			array.add(fontname)
		}
		if (size > 0) {
			array.add("font-size")
			array.add(String.format("%dpt", size))
			if (lineheight <= 0) {
				array.add("line-height")
				array.add(String.format("%dpt", size + 1))
			}
		}
		if (weight !== null) {
			array.add("font-weight")
			array.add(weight)
		}
		if (style !== null) {
			array.add("font-style")
			array.add(style)
		}
		if (lineheight > 0) {
			array.add("line-height")
			array.add(String.format("%dpt", lineheight))
		}
		if (array.size <= 0) {
			return null
		}
		return array.toArray(newArrayOfSize(array.size))
	}

	/** 
	 * Start eines Tags mit Font-Eigenschaften und Attributen.
	 * @param name Name des Tags.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param fontname font-family null heißt Helvetica (Arial fast identisch)
	 * @param size Größe in Point (pt), <=0 heißt 11
	 * @param weight Gewicht (normal bzw. null, bold)
	 * @param style Stil (normal bzw. null, italic)
	 * @param attrNameValue Name und Wert der Attribute.
	 * @return FoGeneratorDocumentStream, damit mit append weiter gemacht werden kann.
	 */
	def FoGeneratorDocumentStream startTag(String name, String text, boolean endTag, String fontname, int size,
		String weight, String style, String... attrNameValue) throws IOException {

		fds.append("<").append(name)
		appendAttribute(getFontArray(fontname, size, weight, style, 0))
		appendAttribute(attrNameValue)
		if (endTag) {
			if (text === null) {
				fds.append("/>")
			} else {
				fds.append(">")
				fds.append(getCdata(text))
				endTag(name)
			}
		} else {
			fds.append(">")
			if (text !== null) {
				fds.append(getCdata(text))
			}
		}
		return fds
	}

	/** 
	 * Start eines Tags mit Font-Eigenschaften und Attributen.
	 * @param name Name des Tags.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param fontNameValue Name und Wert der Font-Attribute kann null sein.
	 * @param attrNameValue Name und Wert der Attribute.
	 * @return FoGeneratorDocumentStream, damit mit append weiter gemacht werden kann.
	 */
	def private FoGeneratorDocumentStream startTag(String name, String text, boolean endTag, String[] fontNameValue,
		String... attrNameValue) throws IOException {

		fds.append("<").append(name)
		appendAttribute(fontNameValue)
		appendAttribute(attrNameValue)
		if (endTag) {
			if (text === null) {
				fds.append("/>")
			} else {
				fds.append(">")
				fds.append(getCdata(text))
				endTag(name)
			}
		} else {
			fds.append(">")
			if (text !== null) {
				fds.append(getCdata(text))
			}
		}
		return fds
	}

	/** 
	 * Start eines Tags mit Attributen.
	 * @param name Name des Tags.
	 * @param attrNameValue Name und Wert der Attribute.
	 * @return FoGeneratorDocumentStream, damit mit append weiter gemacht werden kann.
	 * @throws IOException
	 */
	def FoGeneratorDocumentStream startTag(String name, String... attrNameValue) throws IOException {
		return startTag(name, false, attrNameValue)
	}

	/** 
	 * Start eines Tags mit Attributen.
	 * @param name Name des Tags.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param attrNameValue Name und Wert der Attribute.
	 * @return FoGeneratorDocumentStream, damit mit append weiter gemacht werden kann.
	 * @throws IOException
	 */
	def FoGeneratorDocumentStream startTag(String name, boolean endTag, String... attrNameValue) throws IOException {

		if (name !== null) {
			fds.append("<").append(name)
			appendAttribute(attrNameValue)
			if (endTag) {
				fds.append("/>").appendCrLf
			} else {
				fds.append(">")
			}
		}
		return fds
	}

	/** 
	 * Ende eines Tags mit Zeilenumbruch.
	 * @param name Name des Tags.
	 * @return FoGeneratorDocumentStream, damit mit append weiter gemacht werden kann.
	 * @throws IOException
	 */
	def FoGeneratorDocumentStream endTag(String name) throws IOException {

		if (name !== null) {
			fds.append("</").append(name).append(">").appendCrLf
		}
		return fds
	}

	/** 
	 * Start-Tags des FO-Dokuments.
	 * @param fontname Fontname kann null sein, z.B. Times.
	 * @param size Standard-Zeichensatz-Größe in Point (pt)
	 * @param lineheight Standard-Zeilenhöhe in Point (pt)
	 * @param top Oberer Rand, z.B. 27.5mm
	 * @throws IOException
	 */
	def void startFo(String fontname, int size, int lineheight, String top, boolean seitennummer) throws IOException {

		clear
		fds.append("<?xml version=\"1.0\" encoding=\"").appendCharsetName.append("\"?>").appendCrLf
		startTag("fo:root", "xmlns:fo", foNS)
		startTag("fo:layout-master-set").appendCrLf
		startTag("fo:simple-page-master", "master-name", getMultiName("simpleA4"), // , "page-height", "29.7cm", "page-width", "21cm"
		"margin-bottom", "20mm", "margin-left", "27mm", "margin-right", "14.5mm", "margin-top", top).appendCrLf
		startTag("fo:region-body", true)
		if (seitennummer) {
			startTag("fo:region-before", true, "region-name", getMultiName("header"), "extent", "10mm")
		}
		endTag("fo:simple-page-master")
		endTag("fo:layout-master-set")
		var array = new ArrayList<String>
		array.add("master-reference")
		array.add(getMultiName("simpleA4"))
		if (resetPageNumber) {
			array.add("initial-page-number")
			array.add("1")
			array.add("force-page-count")
			array.add("no-force")
		}
		startTag("fo:page-sequence", array.toArray(newArrayOfSize(array.size))).appendCrLf
		if (seitennummer) {
			startTag("fo:static-content", "flow-name", getMultiName("header")).appendCrLf
			startBlock(null, false, "text-align-last", "justify")
			startTag("fo:leader", true, "leader-pattern", "space")
			startTag("fo:inline", Meldungen::M1058, false, null, 0, null, null)
			startTag("fo:page-number", true)
			endTag("fo:inline")
			endBlock
			endTag("fo:static-content")
		}
		startFlow(fontname, size, lineheight)
	}

	/** 
	 * Start-Tags des FO-Dokuments ohne Flow. Es können fo:static-content für header-first, header-rest, footer-first
	 * und footer-rest definiert werden.
	 * @param top Oberer Rand, z.B. 27.5mm
	 * @param bottom Unterer Rand, z.B. 20mm
	 * @param left Linker Rand, z.B. 27mm
	 * @param right Rechter Rand, z.B. 14.5mm
	 * @throws IOException
	 */
	def void startFo2Master(String topf, String bottomf, String leftf, String rightf, String headerFirstExtent,
		String headerRestExtent, String footerFirstExtent, String footerRestExtent) throws IOException {

		var top = topf
		var bottom = bottomf
		var left = leftf
		var right = rightf
		if (FoUtils.nesTrim(top)) {
			top = "27.5mm"
		}
		if (FoUtils.nesTrim(bottom)) {
			bottom = "20mm"
		}
		if (FoUtils.nesTrim(left)) {
			left = "27mm"
		}
		if (FoUtils.nesTrim(right)) {
			right = "14.5mm"
		}
		clear
		fds.append("<?xml version=\"1.0\" encoding=\"").appendCharsetName.append("\"?>").appendCrLf
		startTag("fo:root", "xmlns:fo", foNS)
		startTag("fo:layout-master-set").appendCrLf
		startTag("fo:simple-page-master", "master-name", getMultiName("first"), "margin-bottom", bottom, "margin-left",
			left, "margin-right", right, "margin-top", top).appendCrLf
		startTag("fo:region-body", true, "margin-top", headerFirstExtent, "margin-bottom", footerFirstExtent)
		startTag("fo:region-before", true, "region-name", getMultiName("header-first"), "extent", headerFirstExtent)
		startTag("fo:region-after", true, "region-name", getMultiName("footer-first"), "extent", footerFirstExtent)
		endTag("fo:simple-page-master")
		startTag("fo:simple-page-master", "master-name", getMultiName("rest"), "margin-bottom", bottom, "margin-left",
			left, "margin-right", right, "margin-top", top).appendCrLf
		startTag("fo:region-body", true, "margin-top", headerRestExtent, "margin-bottom", footerRestExtent)
		startTag("fo:region-before", true, "region-name", getMultiName("header-rest"), "extent", headerRestExtent)
		startTag("fo:region-after", true, "region-name", getMultiName("footer-rest"), "extent", footerRestExtent)
		endTag("fo:simple-page-master")
		startTag("fo:page-sequence-master", "master-name", getMultiName("document"))
		startTag("fo:repeatable-page-master-alternatives")
		startTag("fo:conditional-page-master-reference", true, "page-position", "first", "master-reference",
			getMultiName("first"))
		startTag("fo:conditional-page-master-reference", true, "page-position", "rest", "master-reference",
			getMultiName("rest"))
		endTag("fo:repeatable-page-master-alternatives")
		endTag("fo:page-sequence-master")
		endTag("fo:layout-master-set")
		var array = new ArrayList<String>
		array.add("master-reference")
		array.add(getMultiName("document"))
		if (resetPageNumber) {
			array.add("initial-page-number")
			array.add("1")
			array.add("force-page-count")
			array.add("no-force")
		}
		startTag("fo:page-sequence", array.toArray(newArrayOfSize(array.size))).appendCrLf
	}

	/** 
	 * Start-Tags des FO-Dokuments ohne Flow. Es können fo:static-content für header und footer definiert werden. Die
	 * Höhe beträgt standardmäßig 297-27.5-20=249.5mm. Die Breite beträgt standardmäßig 210-27-14.5=168.5mm.
	 * @param top Oberer Rand, z.B. 27.5mm
	 * @param bottom Unterer Rand, z.B. 20mm
	 * @param left Linker Rand, z.B. 27mm
	 * @param right Rechter Rand, z.B. 14.5mm
	 * @param columns Anzahl der Spalten im Rumpf, z.B. 1
	 * @param gap Abstand zwischen Spalten im Rumpf, z.B. "5mm"
	 * @throws IOException
	 */
	def void startFo1Master(String topf, String bottomf, String leftf, String rightf, String headerExtent,
		String footerExtent, int columns, String gap) throws IOException {

		var top = topf
		var bottom = bottomf
		var left = leftf
		var right = rightf
		if (FoUtils.nesTrim(top)) {
			top = "27.5mm"
		}
		if (FoUtils.nesTrim(bottom)) {
			bottom = "20mm"
		}
		if (FoUtils.nesTrim(left)) {
			left = "27mm"
		}
		if (FoUtils.nesTrim(right)) {
			right = "14.5mm"
		}
		clear
		fds.append("<?xml version=\"1.0\" encoding=\"").appendCharsetName.append("\"?>").appendCrLf
		startTag("fo:root", "xmlns:fo", foNS)
		startTag("fo:layout-master-set").appendCrLf
		startTag("fo:simple-page-master", "master-name", getMultiName("hfmaster"), "margin-bottom", bottom,
			"margin-left", left, "margin-right", right, "margin-top", top).appendCrLf
		var array = new ArrayList<String>
		array.add("margin-top")
		array.add(headerExtent)
		array.add("margin-bottom")
		array.add(footerExtent)
		if (columns > 1 && gap !== null) {
			array.add("column-count")
			array.add(Integer.toString(columns))
			array.add("column-gap")
			array.add(gap)
		}
		startTag("fo:region-body", true, array.toArray(newArrayOfSize(array.size)))
		startTag("fo:region-before", true, "region-name", getMultiName("header"), "extent", headerExtent)
		startTag("fo:region-after", true, "region-name", getMultiName("footer"), "extent", footerExtent)
		endTag("fo:simple-page-master")
		endTag("fo:layout-master-set")
		array = new ArrayList<String>
		array.add("master-reference")
		array.add(getMultiName("hfmaster"))
		if (resetPageNumber) {
			array.add("initial-page-number")
			array.add("1")
			array.add("force-page-count")
			array.add("no-force")
		}
		startTag("fo:page-sequence", array.toArray(newArrayOfSize(array.size))).appendCrLf
	}

	/** 
	 * Ende-Tags des FO-Dokuments.
	 * @throws IOException
	 */
	def void endFo() throws IOException {

		endTag("fo:flow")
		endTag("fo:page-sequence")
		endTag("fo:root")
	}

	/** 
	 * Start fo:flow Tag des FO-Dokuments.
	 * @param ffontname Fontname kann null sein, z.B. Times.
	 * @param size Standard-Zeichensatz-Größe in Point (pt)
	 * @param lineheight Standard-Zeilenhöhe in Point (pt)
	 * @throws IOException
	 */
	def void startFlow(String ffontname, int size, int lineheight) throws IOException {

		var fontname = ffontname
		if (fontname === null) {
			fontname = FONTNAME
		}
		// Standard-Schrift
		startTag("fo:flow", null, false, getFontArray(fontname, size, "normal", "normal", lineheight), "flow-name",
			"xsl-region-body").appendCrLf
	}

	/** 
	 * Start fo:block Tag mit Font-Eigenschaften.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param attrNameValue Name und Wert der Attribute.
	 */
	def void startBlock(String text, String... attrNameValue) throws IOException {
		startTag("fo:block", text, false, null, attrNameValue)
	}

	/** 
	 * Start fo:block Tag mit Font-Eigenschaften.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param attrNameValue Name und Wert der Attribute.
	 */
	def void startBlock(String text, boolean endTag, String... attrNameValue) throws IOException {
		startTag("fo:block", text, endTag, null, attrNameValue)
	}

	/** 
	 * Start fo:block Tag mit Font-Eigenschaften.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param fontname font-family null heißt Helvetica (Arial fast identisch)
	 * @param size Größe in Point (pt), <=0 heißt 11
	 * @param weight Gewicht (normal bzw. null, bold)
	 * @param style Stil (normal bzw. null, italic)
	 * @param attrNameValue Name und Wert der Attribute.
	 */
	def void startBlock(String text, boolean endTag, String fontname, int size, String weight, String style,
		String... attrNameValue) throws IOException {
		startTag("fo:block", text, endTag, getFontArray(fontname, size, weight, style, 0), attrNameValue)
	}

	/** 
	 * Start fo:block Tag mit oder ohne Fett-Schrift und möglichen Zeilenumbrüchen.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param endTag Wird das Tag direkt geschlossen?
	 * @param fett Soll fett ausgegeben werden?
	 */
	def void startBlockFett(String text, boolean endTag, boolean fett) throws IOException {

		if (fett) {
			startBlock(text, endTag, null, 0, "bold", null, "linefeed-treatment", "preserve")
		} else {
			startBlock(text, endTag, "linefeed-treatment", "preserve")
		}
	}

	/** 
	 * Start und Ende für fo:inline Tag.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param attrNameValue Name und Wert der Attribute.
	 */
	def void inline(String text, String... attrNameValue) throws IOException {
		startTag("fo:inline", text, true, null, attrNameValue)
	}

	/** 
	 * Start und Ende für fo:inline Tag mit Font-Eigenschaften.
	 * @param text Anzuzeigender Text kann null sein.
	 * @param fontname font-family null heißt Helvetica (Arial fast identisch)
	 * @param size Größe in Point (pt), <=0 heißt 11
	 * @param weight Gewicht (normal bzw. null, bold)
	 * @param style Stil (normal bzw. null, italic)
	 * @param attrNameValue Name und Wert der Attribute.
	 */
	def void inline(String text, String fontname, int size, String weight, String style,
		String... attrNameValue) throws IOException {
		startTag("fo:inline", text, true, getFontArray(fontname, size, weight, style, 0), attrNameValue)
	}

	/** 
	 * Ende fo:block Tag.
	 * @throws IOException
	 */
	def void endBlock() throws IOException {
		endTag("fo:block")
	}

	/** 
	 * Start und Ende für fo:table Tag mit Spaltenbreiten.
	 * @param startTableBody Soll das Tag fo:table-body begonnen werden? Bei false kann vorher noch der Table-Header
	 * definiert werden?
	 * @param columnWidth Spaltenbreiten, z.B. 13mm.
	 */
	def void startTable(boolean startTableBody, String... columnWidth) throws IOException {

		startTag("fo:table", "table-layout", "fixed", "width", "100%", "border-collapse", "separate")
		if (columnWidth !== null) {
			var anzahl = columnWidth.length
			for (var i = 0; i < anzahl; i++) {
				startTag("fo:table-column", true, "column-width", {
					val _rdIndx_columnWidth = i
					columnWidth.get(_rdIndx_columnWidth)
				})
			}
		}
		if (startTableBody) {
			startTag("fo:table-body")
		}
	}

	/** 
	 * Start und Ende für fo:table Tag mit Rändern und Spaltenbreiten.
	 * @param startTableBody Soll das Tag fo:table-body begonnen werden? Bei false kann vorher noch der Table-Header
	 * definiert werden?
	 * @param columnWidth Spaltenbreiten, z.B. 13mm.
	 */
	def void startTableBorder(boolean startTableBody, String... columnWidth) throws IOException {

		startTag("fo:table", "table-layout", "fixed", "width", "100%", "border-width", "0.1mm")
		// , "margin", "2mm 2mm 2mm 2mm"); //, "border-style", "solid");
		if (columnWidth !== null) {
			var anzahl = columnWidth.length
			for (var i = 0; i < anzahl; i++) {
				startTag("fo:table-column", true, "column-width", {
					val _rdIndx_columnWidth = i
					columnWidth.get(_rdIndx_columnWidth)
				})
			}
		}
		if (startTableBody) {
			startTag("fo:table-body")
		}
	}

	/** 
	 * Ende fo:table Tag.
	 * @throws IOException
	 */
	def void endTable() throws IOException {
		endTag("fo:table-body")
		endTag("fo:table")
	}

	/** 
	 * Der Text wird mit '<![CDATA[' und ']]>' umrahmt, so dass das Ergebnis in eine XML-Datei geschrieben werden kann.
	 * @param text beliebiger Text.
	 * @return CDATA-Text.
	 */
	def String getCdata(String text) {

		if (FoUtils.nes0(text)) {
			return ""
		}
		if (text.startsWith("<![CDATA[")) {
			return filterCdata(text)
		}
		return filterCdata('''<![CDATA[«text»]]>''')
	}

	/** 
	 * Filtern von CDATA-Text: keine 0-Zeichen.
	 * @param text beliebiger CDATA-Text.
	 * @return gefilterter CDATA-Text.
	 */
	def private String filterCdata(String text) {

		if (FoUtils.nes0(text)) {
			return ""
		}
		var l = text.length
		var sb = new StringBuilder
		for (var i = 0; i < l; i++) {
			var c = text.charAt(i)
			if(!(c === 0 || c === 2 || c === 19 || c === 24)) sb.append(c)
		}
		return sb.toString
	}

	/** 
	 * Liefert den String ' name="value"'.
	 * @param name Attribut-Name.
	 * @param value Attribut-Wert.
	 * @return String ' name="value"'.
	 */
	def String getAttribut(String name, String value) {
		return ''' «name»="«value»"'''
	}

	/** 
	 * Hinzufügen einer Leerzeile.
	 * @param size Zeilenhöhe in pt.
	 * @throws IOException
	 */
	def void addNewLine(int size) throws IOException {
		addNewLine(size, 1)
	}

	/** 
	 * Hinzufügen mehrerer Leerzeilen.
	 * @param size Zeilenhöhe in pt.
	 * @param fanzahl Anzahl der Leerzeilen.
	 * @throws IOException
	 */
	def void addNewLine(int size, int fanzahl) throws IOException {

		var anzahl = fanzahl
		var sb = new StringBuffer
		while (anzahl > 0) {
			anzahl--
			sb.append(FoGeneratorDocumentStream.CR)
		}
		if (size <= 0) {
			startBlock(sb.toString, "linefeed-treatment", "preserve")
			endBlock
		} else {
			// startBlock(sb.toString, true, null, size, null, null,
			// "linefeed-treatment", "preserve");
			startBlock(sb.toString, true, "line-height", String.format("%dpt", size), "linefeed-treatment", "preserve")
		}
	}

	/** 
	 * Hinzufügen einer Zelle mit einer Leerzeile.
	 * @throws IOException
	 */
	def void addEmptyCell() throws IOException {

		startTag("fo:table-cell")
		addNewLine(0)
		endTag("fo:table-cell")
	}

	/** 
	 * Start und Ende für external-graphic Tag mit Font-Eigenschaften, z.B. <fo:external-graphic
	 * src="url('data:image/jpeg;base64,<DATA>')" content-height="scale-to-fit" height="75"/>
	 * @param bytes Byte-Array enthält Bild
	 * @throws IOException
	 */
	def void externalGraphic(byte[] bytes, String height) throws IOException {

		if (bytes === null) {
			return;
		}
		var sb = new StringBuffer
		sb.append("url('data:image/jpeg;base64,")
		sb.append(Base64.encoder.encodeToString(bytes))
		sb.append("')")
		startTag("fo:external-graphic", true, "src", sb.toString, "content-height", "scale-to-fit", "height", height,
			"margin-top", "0mm")
	}

	/** 
	 * Start und Ende für instream-svg-Grafik, z.B. <fo:instream-foreign-object> <svg:svg width="20pt" height="20pt">
	 * <svg:g style="fill:red; stroke:#000000"> <svg:rect x="0" y="0" width="15" height="15"/> <svg:rect x="5" y="5"
	 * width="15" height="15"/> </svg:g> </svg:svg> </fo:instream-foreign-object>
	 * @param xml svg-Grafik als xml-String
	 * @throws IOException
	 */
	def void svg(String xml) throws IOException {

		if (xml === null) {
			return;
		}
		startBlock(null, false)
		startTag("fo:instream-foreign-object", false)
		fds.append(xml)
		endTag("fo:instream-foreign-object")
		endBlock
	}

	/** 
	 * Schreibt das XML-Dokument als Datei.
	 * @param dateiname
	 * @throws JhhFopException
	 */
	def void writeDocument(String dateiname) throws JhhFopException {
		fds.writeDocument(dateiname)
	}

	/** 
	 * Liefert StreamSource.
	 * @return StreamSource.
	 */
	def Source getSource() {
		return fds.source
	}

	/** 
	 * Liefert Betrag im Format #.##0,00 Währung.
	 * @param fbetrag Betrag.
	 * @param waehrung Währung kann null sein.
	 * @param ohneVorzeichen Soll der Betrag ohne Vorzeichen ausgegeben werden?
	 * @return Betrag im Format #.##0,00 Währung.
	 */
	def String getBetrag(double fbetrag, String waehrung, boolean ohneVorzeichen) {

		var betrag = fbetrag
		var df = new DecimalFormat("#,##0.00", new DecimalFormatSymbols(Locale.GERMAN))
		if (ohneVorzeichen || Global.compDouble4(betrag, 0) == 0) {
			betrag = Math.abs(betrag)
		}
		var str = df.format(betrag)
		if (!FoUtils.nesTrim(waehrung)) {
			str += ''' «waehrung»'''
		}
		return str
	}

	/** 
	 * Liefert Prozentsatz im Format 0,##%.
	 * @param prozentsatz Prozentsatz.
	 * @return Prozentsatz im Format 0,##%.
	 */
	def String getProzentsatz(double prozentsatz) {

		var df = new DecimalFormat("0.##%", new DecimalFormatSymbols(Locale.GERMAN))
		var str = df.format(prozentsatz)
		return str
	}

	/** 
	 * Liefert Prozentsatz im Format 0,00%, d.h. immer mit 2 Nachkommastellen.
	 * @param prozentsatz Prozentsatz.
	 * @return Prozentsatz im Format 0,00%.
	 */
	def String getProzentsatz2(double prozentsatz) {

		var df = new DecimalFormat("0.00%", new DecimalFormatSymbols(Locale.GERMAN))
		var str = df.format(prozentsatz)
		return str
	}

	/** 
	 * Liefert Prozentsatz im Format 0,0‰, d.h. immer mit 2 Nachkommastellen.
	 * @param promillesatz Promillesatz.
	 * @return Promillesatz im Format 0,0‰.
	 */
	def String getPromillesatz(double promillesatz) {

		var df = new DecimalFormat("0.0\u2030", new DecimalFormatSymbols(Locale.GERMAN))
		var str = df.format(promillesatz)
		// evtl. mit o/oo
		return str
	}

	/** 
	 * Horizontale Linie.
	 * @throws IOException
	 */
	def void horizontalLine() throws IOException {

		startBlock(null)
		startTag("fo:leader", true, "leader-pattern", "rule", "leader-length", "100%", "rule-thickness", "0.3mm")
		endBlock
	}

	/** 
	 * Hinzufügen von Text vor und hinter einem Leerraum.
	 * @param spacewidth Breite des Leerraums kann null sein.
	 * @param text Anzuzeigender Text nach dem Leerraum kann null sein.
	 */
	def void leerraumText(String spacewidth, String text) throws IOException {

		if (spacewidth === null) {
			startTag("fo:leader", true, "leader-pattern", "space")
		} else {
			startTag("fo:leader", true, "leader-pattern", "space", "leader-length", spacewidth)
		}
		if (text !== null) {
			fds.append(getCdata(text))
		}
	}

	/** 
	 * Liefert SHA-1-Hash des momentanen FO-Dokuments.
	 * @return SHA-1-Hash des momentanen FO-Dokuments.
	 */
	def byte[] getSha1Hash() {
		return fds.sha1Hash
	}

	/** 
	 * Liefert den Standard-Fontname.
	 * @return Standard-Fontname.
	 */
	def String getFontname() {
		return FONTNAME
	}

	/** 
	 * Liefert fo:inline Tag zum Starten von fetter Schrift.
	 * @return fo:inline Tag zum Starten von fetter Schrift.
	 */
	def String getStartFett() {
		return "<fo:inline font-weight=\"bold\">"
	}

	/** 
	 * Liefert fo:inline Tag zum Beenden von fetter Schrift.
	 * @return fo:inline Tag zum Beenden von fetter Schrift.
	 */
	def String getEndFett() {
		return "</fo:inline>"
	}

	/** 
	 * Anhängen von Text mit CDATA.
	 * @param text Text wird mit CDATA umschlossen.
	 * @throws IOException
	 */
	def void appendText(String text) throws IOException {
		fds.append(getCdata(text))
	}

	/** 
	 * Setzt den Stream in den Einzel- (multiName leer) oder Mehrfach-Dokument-Modus (multiName nicht leer).
	 * @param multiName Name für die Mehrfach-Dokument-Generierung.
	 */
	def void setMultiName(String multiName) {
		fds.setFragmente(!FoUtils.nes0(multiName))
		this.multiName = multiName
	}

	/** 
	 * Liefert den Namen für die Mehrfach-Dokument-Generierung.
	 * @return Name für die Mehrfach-Dokument-Generierung.
	 */
	def String getMultiName() {
		return multiName
	}

	/** 
	 * Liefert einen Namen für die Einfach bzw. Mehrfach-Dokument-Generierung. Bei Mehrfach-Dokument-Generierung wird
	 * der übergebene String durch den MultiName ergänzt.
	 * @param str String.
	 * @return Namen für die Einfach bzw. Mehrfach-Dokument-Generierung.
	 */
	def String getMultiName(String str) {

		if (FoUtils.nes0(multiName)) {
			return str
		}
		return String.format("%s-%s", str, multiName)
	}

	/** 
	 * Inhalt des Stream-Fragments als String.
	 * @param nr Nummer des Fragments beginnend mit 0.
	 * @return Inhalt des Stream-Fragments als String.
	 */
	def String getFragment(int nr) {
		return fds.getFragment(nr)
	}

	/** 
	 * Soll die Seitennumerierung bei 1 anfangen?
	 * @param resetPageNumber Soll die Seitennumerierung bei 1 anfangen?
	 */
	def void setResetPageNumber(boolean resetPageNumber) {
		this.resetPageNumber = resetPageNumber
	}

	/** 
	 * Soll die Seitennumerierung bei 1 anfangen?
	 * @return Soll die Seitennumerierung bei 1 anfangen?
	 */
	def boolean isResetPageNumber() {
		return resetPageNumber
	}

	/** 
	 * Liefert Text für Schlüssel.
	 * @param wertelistenName Der Name der Werteliste.
	 * @param key Text-Schlüssel.
	 * @return Text für Schlüssel.
	 */
	def String getKeyValue(String wertelistenName, String key) {

		try {
			return Werteliste.getKeyValue(wertelistenName, key)
		} catch (Exception e) {
			throw new JhhFopException(e)
		}

	}

	/** 
	 * Liefert Text für Schlüssel mit 1 Parameter.
	 * @param wertelistenName Der Name der Werteliste.
	 * @param key Text-Schlüssel.
	 * @param param1 1. Parameter.
	 * @return Text für Schlüssel mit 1 Parameter.
	 */
	def String getKeyValue1(String wertelistenName, String key, String param1) {
		return String.format(getKeyValue(wertelistenName, key), param1)
	}

	/** 
	 * Liefert Text für Schlüssel mit 1 Parameter.
	 * @param wertelistenName Der Name der Werteliste.
	 * @param key Text-Schlüssel.
	 * @param param1 1. Parameter.
	 * @param param2 2. Parameter.
	 * @return Text für Schlüssel mit 2 Parametern.
	 */
	def String getKeyValue2(String wertelistenName, String key, String param1, String param2) {
		return String.format(getKeyValue(wertelistenName, key), param1, param2)
	}
}

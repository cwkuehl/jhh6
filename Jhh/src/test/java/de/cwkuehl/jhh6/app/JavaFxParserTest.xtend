package de.cwkuehl.jhh6.app

import de.cwkuehl.jhh6.api.global.Global
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.Vector
import java.util.regex.Pattern
import org.junit.Test

import static org.junit.Assert.*
import de.cwkuehl.jhh6.TestBase

class JavaFxParserTest extends TestBase {

	static Pattern pform = Pattern.compile(
		".+fx:controller=\\\"(de.cwkuehl.jhh\\d.(anwendung|app).controller.\\w\\w.(\\w\\w[\\d]{3})[^\\\"]+)\\\".*",
		Pattern.CASE_INSENSITIVE)
	static Pattern pid = Pattern.compile(".+ fx:id=\\\"([\\w\\d]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ptext = Pattern.compile(".+ text=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern pat = Pattern.compile(".+accessibleText=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ppt = Pattern.compile(".+promptText=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ptt = Pattern.compile(".+<Tooltip .*", Pattern.CASE_INSENSITIVE)
	static Pattern plbl = Pattern.compile(".+<Label .*", Pattern.CASE_INSENSITIVE)
	static Pattern pcss = Pattern.compile(".+ value=\\\"@../Jhh\\d.css\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern pimg = Pattern.compile(".+<Image url=.*", Pattern.CASE_INSENSITIVE)

	/* Change JavaFX files for JHH6. */
	@Test def void parse() {

		if (skipForBuild) {
			return
		}

		// parse("ad/AD100Personen.fxml")
		// parse("ad/AD110Person.fxml")
		// parse("ad/AD120Geburtstage.fxml")
		// parse("ad/AD130Adressen.fxml")
		// parse("ad/AD200Schnittstelle.fxml")
		// parse("ag/AG000Info.fxml")
		// parse("ag/AG010Hilfe.fxml")
		// parse("ag/AG100Mandanten.fxml")
		// parse("ag/AG110Mandant.fxml")
		// parse("ag/AG200Benutzer.fxml")
		// parse("ag/AG210Benutzer.fxml")
		// parse("ag/AG400Sicherungen.fxml")
		// parse("ag/AG410Sicherung.fxml")
		// parse("am/AM000Anmeldung.fxml")
		// parse("am/AM100Aenderung.fxml")
		// parse("am/AM500Einstellungen.fxml")
		// parse("am/AM510Dialoge.fxml")
		// parse("fz/FZ100Statistik.fxml")
		// parse("fz/FZ200Fahrraeder.fxml")
		// parse("fz/FZ210Fahrrad.fxml")
		// parse("fz/FZ250Fahrradstaende.fxml")
		// parse("fz/FZ260Fahrradstand.fxml")
		// parse("fz/FZ300Autoren.fxml")
		// parse("fz/FZ310Autor.fxml")
		// parse("fz/FZ320Serien.fxml")
		// parse("fz/FZ330Serie.fxml")
		// parse("fz/FZ340Buecher.fxml")
		// parse("fz/FZ350Buch.fxml")
		// parse("fz/FZ700Notizen.fxml")
		// parse("fz/FZ710Notiz.fxml")
		// parse("hh/HH100Perioden.fxml")
		// parse("hh/HH200Konten.fxml")
		// parse("hh/HH210Konto.fxml")
		// parse("hh/HH300Ereignisse.fxml")
		// parse("hh/HH310Ereignis.fxml")
		// parse("hh/HH400Buchungen.fxml")
		// parse("hh/HH410Buchung.fxml")
		// parse("hh/HH500Bilanzen.fxml")
		// parse("hh/HH510Drucken.fxml")
		// parse("hp/HP100Patienten.fxml")
		// parse("hp/HP110Patient.fxml")
		// parse("hp/HP150Status.fxml")
		// parse("hp/HP160Status.fxml")
		// parse("hp/HP200Behandlungen.fxml")
		// parse("hp/HP210Behandlung.fxml")
		// parse("hp/HP300Leistungen.fxml")
		// parse("hp/HP310Leistung.fxml")
		// parse("hp/HP350Leistungsgruppen.fxml")
		// parse("hp/HP360Leistungsgruppe.fxml")
		// parse("hp/HP400Rechnungen.fxml")
		// parse("hp/HP410Rechnung.fxml")
		// parse("hp/HP420Behandlungen.fxml")
		// parse("mo/MO100Messdiener.fxml")
		// parse("mo/MO110Messdiener.fxml")
		// parse("mo/MO200Gottesdienste.fxml")
		// parse("mo/MO210Gottesdienst.fxml")
		// parse("mo/MO220Einteilung.fxml")
		// parse("mo/MO300Profile.fxml")
		// parse("mo/MO310Profil.fxml")
		// parse("mo/MO500Schnittstelle.fxml")
		// parse("sb/SB200Ahnen.fxml")
		// parse("sb/SB210Ahn.fxml")
		// parse("sb/SB220Drucken.fxml")
		// parse("sb/SB300Familien.fxml")
		// parse("sb/SB310Familie.fxml")
		// parse("sb/SB400Quellen.fxml")
		// parse("sb/SB410Quelle.fxml")
		// parse("sb/SB500Gedcom.fxml")
		// parse("so/SO100Sudoku.fxml")
		// parse("so/SO200Detektiv.fxml")
		// parse("so/SO210Runde.fxml")
		// parse("tb/TB100Tagebuch.fxml")
		// parse("vm/VM100Haeuser.fxml")
		// parse("vm/VM110Haus.fxml")
		// parse("vm/VM200Wohnungen.fxml")
		// parse("vm/VM210Wohnung.fxml")
		// parse("vm/VM300Mieter.fxml")
		// parse("vm/VM310Mieter.fxml")
		// parse("vm/VM400Mieten.fxml")
		// parse("vm/VM410Miete.fxml")
		// parse("vm/VM500Buchungen.fxml")
		// parse("vm/VM510Buchung.fxml")
		// parse("vm/VM520Sollstellung.fxml")
		// parse("vm/VM530Istzahlung.fxml")
		// parse("vm/VM600Konten.fxml")
		 parse("vm/VM610Konto.fxml")
		// parse("vm/VM700Ereignisse.fxml")
		// parse("vm/VM710Ereignis.fxml")
		// parse("vm/VM800Forderungen.fxml")
		// parse("vm/VM900Abrechnungen.fxml")
		// parse("vm/VM910Abrechnung.fxml")
		// parse("vm/VM920Abrechnungen.fxml")
		// parse("vm/VM930Abrechnung.fxml")
		// parse("wp/WP100Chart.fxml")
		// parse("wp/WP110Charts.fxml")
		// parse("wp/WP120ChartsEinstellungen.fxml")
		// parse("wp/WP200Wertpapiere.fxml")
		// parse("wp/WP210Wertpapier.fxml")
		// parse("wp/WP220Schnittstelle.fxml")
		// parse("wp/WP250Anlagen.fxml")
		// parse("wp/WP260Anlage.fxml")
		// parse("wp/WP300Konfigurationen.fxml")
		// parse("wp/WP310Konfiguration.fxml")
		// parse("wp/WP400Buchungen.fxml")
		// parse("wp/WP410Buchung.fxml")
		// parse("wp/WP500Staende.fxml")
		// parse("wp/WP510Stand.fxml")
		Global.machNichts
	}

	def private void parse(String datei) {

		var in = new BufferedReader(new InputStreamReader(getClass.getResourceAsStream('''/dialog/«datei»'''), "UTF-8"))
		assertNotNull(in)
		var String form
		var String str
		var String id
		var String text
		var String at
		var String pt
		var props = new Vector<String>
		while ((str = in.readLine) !== null) {
			if (str.contains("<?import de.cwkuehl.jhh5.anwendung.control.Datum?>")) {
				str = "<?import de.cwkuehl.jhh6.app.control.Datum?>"
			}
			var m = pform.matcher(str)
			if (m.matches) {
				form = m.group(3)
				// System.out.println(form)
				var c = m.group(1).replace("jhh5.anwendung", "jhh6.app")
				str = str.replace('''fx:controller="«m.group(1)»"''', '''fx:controller="«c»"''')
				props.add('''«form».title = «datei.substring(8, datei.length-5)»''')
			}
			var lbl = plbl.matcher(str).matches
			var m1 = pid.matcher(str)
			if (m1.matches) {
				id = m1.group(1)
				if (lbl && id.endsWith("0"))
					id = id.substring(0, id.length - 1)
			// System.out.println(id)
			}
			var tt = ptt.matcher(str).matches
			var m2 = ptext.matcher(str)
			if (m2.matches) {
				text = m2.group(1)
				// System.out.println(text)
				if (tt && id == 'aktuell')
					str = str.replace('''text="«text»"''', '''text="%Refresh"''')
				else if (tt && id == 'rueckgaengig')
					str = str.replace('''text="«text»"''', '''text="%Undo"''')
				else if (tt && id == 'wiederherstellen')
					str = str.replace('''text="«text»"''', '''text="%Redo"''')
				else if (tt && id == 'neu')
					str = str.replace('''text="«text»"''', '''text="%New"''')
				else if (tt && id == 'kopieren')
					str = str.replace('''text="«text»"''', '''text="%Copy"''')
				else if (tt && id == 'aendern')
					str = str.replace('''text="«text»"''', '''text="%Edit"''')
				else if (tt && id == 'loeschen')
					str = str.replace('''text="«text»"''', '''text="%Delete"''')
				else if (tt && id == 'einstellung')
					str = str.replace('''text="«text»"''', '''text="%Settings"''')
				else if (tt && id == 'tab')
					str = str.replace('''text="«text»"''', '''text="%Tab"''')
				else if (tt && id == 'einfuegen')
					str = str.replace('''text="«text»"''', '''text="%Paste"''')
				else if (tt && id == 'export')
					str = str.replace('''text="«text»"''', '''text="%Export"''')
				else if (tt && id == 'drucken')
					str = str.replace('''text="«text»"''', '''text="%Print"''')
				else if (tt && id == 'imExport')
					str = str.replace('''text="«text»"''', '''text="%ImExport"''')
				else if (id == 'ok')
					str = str.replace('''text="«text»"''', '''text="%Ok«IF tt».tt«ENDIF»"''')
				else if (id == 'abbrechen')
					str = str.replace('''text="«text»"''', '''text="%Cancel«IF tt».tt«ENDIF»"''')
				else if (id == 'angelegt')
					str = str.replace('''text="«text»"''', '''text="%Creation«IF tt».tt«ENDIF»"''')
				else if (id == 'geaendert')
					str = str.replace('''text="«text»"''', '''text="%Change«IF tt».tt«ENDIF»"''')
				else {
					str = str.replace('''text="«text»"''', '''text="%«form».«id»«IF tt».tt«ENDIF»"''')
					props.add('''«form».«id»«IF tt».tt«ENDIF» = «text»''')
				}
			}
			var m3 = pat.matcher(str)
			if (m3.matches) {
				at = m3.group(1)
				// System.out.println(at)
				if (id == 'angelegt')
					str = str.replace('''accessibleText="«at»"''', '''accessibleText="%Creation.tt"''')
				else if (id == 'geaendert')
					str = str.replace('''accessibleText="«at»"''', '''accessibleText="%Change.tt"''')
				else {
					str = str.replace('''accessibleText="«at»"''', '''accessibleText="%«form».«id».tt"''')
					props.add('''«form».«id».at = «at»''')
				}
			}
			var m4 = ppt.matcher(str)
			if (m4.matches) {
				pt = m4.group(1)
				// System.out.println(pt)
				if (id == 'angelegt')
					str = str.replace('''promptText="«pt»"''', '''promptText="%Creation.tt"''')
				else if (id == 'geaendert')
					str = str.replace('''promptText="«pt»"''', '''promptText="%Change.tt"''')
				else {
					str = str.replace('''promptText="«pt»"''', '''promptText="%«form».«id».tt"''')
					props.add('''«form».«id».pt = «pt»''')
				}
			}
			var m5 = pcss.matcher(str)
			if (m5.matches) {
				str = str.replace('''Jhh5''', '''Jhh6''')
			}
			var m6 = pimg.matcher(str)
			if (m6.matches) {
				str = str.replace('''refresh_48.png''', '''icons8-refresh.png''')
				str = str.replace('''arrow_left_48.png''', '''icons8-undo.png''')
				str = str.replace('''arrow_right_48.png''', '''icons8-redo.png''')
				str = str.replace('''document-new-4.png''', '''icons8-new-document.png''')
				str = str.replace('''edit-copy-4.png''', '''icons8-copy.png''')
				str = str.replace('''paper_content_pencil_48.png''', '''icons8-edit.png''')
				str = str.replace('''edit-delete-3.png''', '''icons8-remove.png''')
				str = str.replace('''document-properties-3.png''', '''icons8-settings.png''')
				str = str.replace('''tabs_48.png''', '''icons8-tab.png''')
				str = str.replace('''edit-paste-4.png''', '''icons8-paste.png''')
				str = str.replace('''floppy_disk_48.png''', '''icons8-save.png''')
				str = str.replace('''printer_48.png''', '''icons8-print.png''')
			}
			System.out.println(str)
		}
		System.out.println
		for (s : props)
			System.out.println(s)
	}
}

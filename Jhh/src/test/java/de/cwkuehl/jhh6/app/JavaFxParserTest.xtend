package de.cwkuehl.jhh6.app

import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.regex.Pattern
import org.junit.Test

import static org.junit.Assert.*
import java.util.Vector

class JavaFxParserTest {

	static Pattern pform = Pattern.compile(
		".+fx:controller=\\\"(de.cwkuehl.jhh\\d.(anwendung|app).controller.\\w\\w.(\\w\\w[\\d]{3})[^\\\"]+)\\\".*",
		Pattern.CASE_INSENSITIVE)
	static Pattern pid = Pattern.compile(".+ fx:id=\\\"([\\w\\d]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ptext = Pattern.compile(".+ text=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern pat = Pattern.compile(".+ accessibleText=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ppt = Pattern.compile(".+ promptText=\\\"([^\\\"]+)\\\".*", Pattern.CASE_INSENSITIVE)
	static Pattern ptt = Pattern.compile(".+<Tooltip .*", Pattern.CASE_INSENSITIVE)
	static Pattern plbl = Pattern.compile(".+<Label .*", Pattern.CASE_INSENSITIVE)
	static Pattern pcss = Pattern.compile(".+ value=\\\"@../Jhh\\d.css\\\".*", Pattern.CASE_INSENSITIVE)

	/* Change JavaFX files for JHH6. */
	@Test def void parse() {

		// parse("ag/AG000Info.fxml")
		// parse("ag/AG010Hilfe.fxml")
		// parse("am/AM000Anmeldung.fxml")
		parse("am/AM100Aenderung.fxml")
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
				str = str.replace('''text="«text»"''', '''text="%«form».«id»«IF tt».tt«ENDIF»"''')
				props.add('''«form».«id»«IF tt».tt«ENDIF» = «text»''')
			}
			var m3 = pat.matcher(str)
			if (m3.matches) {
				at = m3.group(1)
				// System.out.println(at)
				str = str.replace('''accessibleText="«at»"''', '''accessibleText="%«form».«id».tt"''')
				props.add('''«form».«id».at = «at»''')
			}
			var m4 = ppt.matcher(str)
			if (m4.matches) {
				pt = m4.group(1)
				// System.out.println(pt)
				str = str.replace('''promptText="«pt»"''', '''promptText="%«form».«id».tt"''')
				props.add('''«form».«id».pt = «pt»''')
			}
			var m5 = pcss.matcher(str)
			if (m5.matches) {
				// System.out.println(pt)
				str = str.replace('''Jhh5''', '''Jhh6''')
			}
			System.out.println(str)
		}
		System.out.println
		for (s : props)
			System.out.println(s)
	}
}

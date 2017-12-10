package de.cwkuehl.jhh6.server.fop.impl

import java.io.IOException

/** 
 * Diese Klasse erweitert die Klasse FoGeneratorDocumentBase um Textbausteine zur einfachen FO-Generierung.
 */
class FoGeneratorDocument extends FoGeneratorDocumentBase {

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		super()
	}

	/** 
	 * Fügt den Textbaustein Hello World in den Flow des FO-Dokuments.
	 * @throws IOException
	 */
	def void bausteinHelloWorld() throws IOException {
		startBlock("Hello World!", true, null, 27, null, null)
	}

	/** 
	 * Fügt den Textbaustein Adresse in das FO-Dokument.<br>
	 * @throws IOException
	 */
	def void bausteinAdresse(String anrede, String titel, String vorname, String nachname,

		String adressergaenzung) throws IOException {
		var StringBuffer sb = new StringBuffer
		FoUtils.append(sb, null, anrede)
		FoUtils.append(sb, " ", titel)
		FoUtils.append(sb, " ", vorname)
		FoUtils.append(sb, " ", nachname)
		startBlock(sb.toString, true)
		if (!FoUtils.nesTrim(adressergaenzung)) {
			startBlock(adressergaenzung, true)
		}
	}
}

package de.cwkuehl.jhh6.app.base

import de.cwkuehl.jhh6.api.global.Constant
import java.util.HashMap

import static de.cwkuehl.jhh6.app.base.Werkzeug.*

class Parameter {

	public String schluessel
	public String standard
	public boolean inDatei
	public boolean inDatenbank
	public boolean trim
	public String wert
	public String kommentar
	public boolean verschluesselt

	new(String schluessel, boolean inDatei, boolean inDatenbank, boolean trim, boolean verschluesselt) {

		this.schluessel = schluessel
		this.standard = g0('''parm.«schluessel».value''', false)
		this.inDatei = inDatei
		this.inDatenbank = inDatenbank
		this.trim = trim
		this.wert = null
		this.kommentar = g0('''parm.«schluessel».text''', false)
		this.verschluesselt = verschluesselt
	}

	// Allgemeine Einstellungen
	public static final String AG_TEST_PRODUKTION = "AG_TEST_PRODUKTION"
	public static final String AG_ANWENDUNGS_TITEL = "AG_ANWENDUNGS_TITEL"
	public static final String AG_HILFE_DATEI = "AG_HILFE_DATEI"
	public static final String AG_STARTDIALOGE = "AG_STARTDIALOGE"
	public static final String AG_TEMP_PFAD = "AG_TEMP_PFAD"
	public static final String AG_SMTP_SERVER = "AG_SMTP_SERVER"

	// Voreinstellungen
	public static final String MENU_VERMIETUNG = "MENU_VERMIETUNG"
	public static final String MENU_HEILPRAKTIKER = "MENU_HEILPRAKTIKER"
	public static final String MENU_MESSDIENER = "MENU_MESSDIENER"

	static HashMap<String, Parameter> params = null

	def static HashMap<String, Parameter> getParameter() {
		if (params === null) {
			params = new HashMap<String, Parameter>()
			var liste = #[
				new Parameter(AG_ANWENDUNGS_TITEL, true, true, false, false),
				new Parameter(AG_HILFE_DATEI, true, false, true, false),
				new Parameter(AG_STARTDIALOGE, true, true, true, false),
				new Parameter(AG_TEMP_PFAD, true, false, true, false),
				new Parameter(AG_TEST_PRODUKTION, true, false, true, false),
				new Parameter(AG_SMTP_SERVER, true, true, true, true),
				new Parameter(MENU_HEILPRAKTIKER, true, true, true, false),
				new Parameter(MENU_MESSDIENER, true, true, true, false),
				new Parameter(MENU_VERMIETUNG, true, true, true, false),
				new Parameter(Constant.MO_NAME, true, true, true, false),
				new Parameter(Constant.MO_ORT, true, true, true, false),
				new Parameter(Constant.MO_DIENSTE, true, true, true, false),
				new Parameter(Constant.MO_VERFUEGBAR, true, true, true, false),
				new Parameter(Constant.MO_FLAMBO_GRENZE, true, true, true, false)
			]
			for (Parameter p : liste) {
				params.put(p.schluessel, p)
			}
		}
		return params
	}
}

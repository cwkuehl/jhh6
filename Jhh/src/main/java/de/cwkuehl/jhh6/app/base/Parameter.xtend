package de.cwkuehl.jhh6.app.base

import java.util.HashMap

class Parameter {

	public String schluessel
	public String standard
	public boolean inDatei
	public boolean inDatenbank
	public boolean trim
	public String wert
	public String kommentar
	public boolean verschluesselt

	new(String schluessel, String standard, boolean inDatei, boolean inDatenbank, boolean trim, String kommentar,
		boolean verschluesselt) {
		this.schluessel = schluessel
		this.standard = standard
		this.inDatei = inDatei
		this.inDatenbank = inDatenbank
		this.trim = trim
		this.wert = null
		this.kommentar = kommentar
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
			var Parameter[] liste = #[
				new Parameter(AG_ANWENDUNGS_TITEL, "Java-Haushalts-Programm", true, true, false,
					"Der Text wird in den Titel der Anwendung eingebaut, z.B. AG_ANWENDUNGS_TITEL=Java-Haushalts-Programm",
					false),
					new Parameter(MENU_HEILPRAKTIKER, "1", true, true, true,
						"Ist Heilpraktiker-Menü aktiv? 0=Nein, 1=Ja, z.B. MENU_HEILPRAKTIKER=1", false),
					new Parameter(MENU_MESSDIENER, "1", true, true, true,
						"Sind Messdiener-Funktionen aktiv? 0=Nein, 1=Ja, z.B. MENU_MESSDIENER=1", false),
					new Parameter(MENU_VERMIETUNG, "1", true, true, true,
						"Ist Vermietung-Menü aktiv? 0=Nein, 1=Ja, z.B. MENU_VERMIETUNG=1", false),
					new Parameter(AG_HILFE_DATEI, "Jhh-Hilfe.html", true, false, true,
						"Name der HTML-Hilfe-Datei, z.B. HILFE_DATEI=Jhh-Hilfe.html", false), // new Parameter(LOOKANDFEEL, "SYSTEM", true, false, true,
					// "Aussehen der Anwendung; JAVA oder SYSTEM, z.B. LOOKANDFEEL=JAVA", false),
					new Parameter(AG_STARTDIALOGE, "", true, true, true,
						"Liste der Start-Dialoge, z.B. AG_STARTDIALOGE=#FZ100", false), // new Parameter(TAGEBUCH_PFAD, "", true, false, true,
					// "Pfad für Tagebuch-Dateien, z.B. TAGEBUCH_PFAD=C:/Temp"),
					new Parameter(AG_TEMP_PFAD, "", true, false, true,
						"Pfad für temporäre Dateien, z.B. AG_TEMP_PFAD=C:/Temp", false),
					new Parameter(AG_TEST_PRODUKTION, "PRODUKTION", true, false, true,
						"Unterscheidung zwischen Test- (einige Funktionen verändert) und Produktions-Modus. Mögliche Werte: TEST, PRODUKTION, z.B. AG_TEST_PRODUKTION=PRODUKTION",
						false),
						new Parameter(AG_SMTP_SERVER, "", true, true, true,
							"SMTP-Server: Servername;Port;Benutzer;Kennwort", true)]
					for (Parameter p : liste) {
						params.put(p.schluessel, p)
					}
				}
				return params
			}
		}
		
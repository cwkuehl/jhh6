package de.cwkuehl.jhh6.api.global

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

	new(String schluessel, boolean inDatei, boolean inDatenbank, boolean trim, boolean verschluesselt) {

		this.schluessel = schluessel
		this.standard = Global.g0('''parm.«schluessel».value''')
		this.inDatei = inDatei
		this.inDatenbank = inDatenbank
		this.trim = trim
		this.wert = null
		this.kommentar = Global.g0('''parm.«schluessel».text''')
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

	/** Messdiener-Parameter für Namen der Messen. */
	public static final String MO_NAME = "MO_NAME"
	/** Messdiener-Parameter für Namen der Ort. */
	public static final String MO_ORT = "MO_ORT"
	/** Messdiener-Parameter für Namen der Dienste. */
	public static final String MO_DIENSTE = "MO_DIENSTE"
	/** Messdiener-Parameter für Anfangszeiten der Messen. */
	public static final String MO_VERFUEGBAR = "MO_VERFUEGBAR"
	/** Messdiener-Parameter für Jahr der Flambogrenze. */
	public static final String MO_FLAMBO_GRENZE = "MO_FLAMBO_GRENZE"

	/** Heilpraktiker-Parameter: Logo-Dateiname oben. */
	public static final String HP_LOGO_OBEN = "HP_LOGO_OBEN"
	/** Heilpraktiker-Parameter: Vorname Nachname. */
	public static final String HP_NAME = "HP_NAME"
	/** Heilpraktiker-Parameter: Berufsbezeichnung. */
	public static final String HP_BERUF = "HP_BERUF"
	/** Heilpraktiker-Parameter: Straße Hausnummer. */
	public static final String HP_STRASSE = "HP_STRASSE"
	/** Heilpraktiker-Parameter: Postleitzahl Ort. */
	public static final String HP_ORT = "HP_ORT"
	/** Heilpraktiker-Parameter: Adresse für Fenster. */
	public static final String HP_FENSTER_ADRESSE = "HP_FENSTER_ADRESSE"
	/** Heilpraktiker-Parameter: Telefon. */
	public static final String HP_TELEFON = "HP_TELEFON"
	/** Heilpraktiker-Parameter: Steuernummer. */
	public static final String HP_STEUERNUMMER = "HP_STEUERNUMMER"
	/** Heilpraktiker-Parameter: Brieftext Anfang. */
	public static final String HP_BRIEFANFANG = "HP_BRIEFANFANG"
	/** Heilpraktiker-Parameter: Brieftext Ende. */
	public static final String HP_BRIEFENDE = "HP_BRIEFENDE"
	/** Heilpraktiker-Parameter: Grußformel. */
	public static final String HP_GRUSS = "HP_GRUSS"
	/** Heilpraktiker-Parameter: Bankverbindung. */
	public static final String HP_BANK = "HP_BANK"
	/** Heilpraktiker-Parameter: Logo-Dateiname unten. */
	public static final String HP_LOGO_UNTEN = "HP_LOGO_UNTEN"

	/** Stammbaum-Schlüssel: Herausgeber für GEDCOM-Datei. */
	public static final String SB_SUBMITTER = "SB_SUBMITTER"

	/** Vermietung-Abrechnungs-Haus-Schlüssel: Name des Vermieters oder Mieters. */
	public static final String VM_NAME = "VM_NAME"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Telefonnummer des Vermieters. */
	public static final String VM_TELEFON = "VM_TELEFON"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Straße und Hausnummer des Vermieters. */
	public static final String VM_STRASSE = "VM_STRASSE"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Postleitzahl und Ort des Vermieters. */
	public static final String VM_ORT = "VM_ORT"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Zahlungsformel bei Guthaben. */
	public static final String VM_H_GUTHABEN = "VM_H_GUTHABEN"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Zahlungsformel bei Nachzahlung. */
	public static final String VM_H_NACHZAHLUNG = "VM_H_NACHZAHLUNG"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Grußformel am Ende. */
	public static final String VM_H_GRUESSE = "VM_H_GRUESSE"
	/** Vermietung-Abrechnungs-Haus-Schlüssel: Anlage für Abrechnung. */
	public static final String VM_H_ANLAGE = "VM_H_ANLAGE"

	static HashMap<String, Parameter> params = null

	def static HashMap<String, Parameter> getParameter() {

		if (params === null) {
			params = new HashMap<String, Parameter>
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
				new Parameter(MO_NAME, true, true, true, false),
				new Parameter(MO_ORT, true, true, true, false),
				new Parameter(MO_DIENSTE, true, true, true, false),
				new Parameter(MO_VERFUEGBAR, true, true, true, false),
				new Parameter(MO_FLAMBO_GRENZE, true, true, true, false),
				new Parameter(HP_LOGO_OBEN, true, true, true, false),
				new Parameter(HP_NAME, true, true, true, false),
				new Parameter(HP_BERUF, true, true, true, false),
				new Parameter(HP_STRASSE, true, true, true, false),
				new Parameter(HP_ORT, true, true, true, false),
				new Parameter(HP_FENSTER_ADRESSE, true, true, true, false),
				new Parameter(HP_TELEFON, true, true, true, false),
				new Parameter(HP_STEUERNUMMER, true, true, true, false),
				new Parameter(HP_BRIEFANFANG, true, true, true, false),
				new Parameter(HP_BRIEFENDE, true, true, true, false),
				new Parameter(HP_GRUSS, true, true, true, false),
				new Parameter(HP_BANK, true, true, true, false),
				new Parameter(HP_LOGO_UNTEN, true, true, true, false),
				new Parameter(SB_SUBMITTER, true, true, true, false),
				new Parameter(VM_NAME, true, true, true, false),
				new Parameter(VM_TELEFON, true, true, true, false),
				new Parameter(VM_STRASSE, true, true, true, false),
				new Parameter(VM_ORT, true, true, true, false),
				new Parameter(VM_H_GUTHABEN, true, true, true, false),
				new Parameter(VM_H_NACHZAHLUNG, true, true, true, false),
				new Parameter(VM_H_GRUESSE, true, true, true, false),
				new Parameter(VM_H_ANLAGE, true, true, true, false)
			]
			for (Parameter p : liste) {
				params.put(p.schluessel, p)
			}
		}
		return params
	}

	def static Parameter get(String key) {

		var liste = parameter
		if (liste.containsKey(key))
			return liste.get(key)
		return null
	}
}

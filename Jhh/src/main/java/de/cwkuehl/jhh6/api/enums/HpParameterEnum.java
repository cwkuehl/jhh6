package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung HpParameterEnum.
 */
public enum HpParameterEnum {

    /** Heilpraktiker-Parameter: Logo-Dateiname oben. */
    HP_LOGO_OBEN,

    /** Heilpraktiker-Parameter: Vorname Nachname. */
    HP_NAME,

    /** Heilpraktiker-Parameter: Berufsbezeichnung. */
    HP_BERUF,

    /** Heilpraktiker-Parameter: Straße Hausnummer. */
    HP_STRASSE,

    /** Heilpraktiker-Parameter: Postleitzahl Ort. */
    HP_ORT,

    /** Heilpraktiker-Parameter: Adresse für Fenster. */
    HP_FENSTER_ADRESSE,

    /** Heilpraktiker-Parameter: Telefon. */
    HP_TELEFON,

    /** Heilpraktiker-Parameter: Steuernummer. */
    HP_STEUERNUMMER,

    /** Heilpraktiker-Parameter: Brieftext Anfang. */
    HP_BRIEFANFANG,

    /** Heilpraktiker-Parameter: Brieftext Ende. */
    HP_BRIEFENDE,

    /** Heilpraktiker-Parameter: Grußformel. */
    HP_GRUSS,

    /** Heilpraktiker-Parameter: Bankverbindung. */
    HP_BANK,

    /** Heilpraktiker-Parameter: Logo-Dateiname unten. */
    HP_LOGO_UNTEN;

    public String toString() {

        if (equals(HP_LOGO_OBEN)) {
            return "HP_LOGO_OBEN";
        } else if (equals(HP_NAME)) {
            return "HP_NAME";
        } else if (equals(HP_BERUF)) {
            return "HP_BERUF";
        } else if (equals(HP_STRASSE)) {
            return "HP_STRASSE";
        } else if (equals(HP_ORT)) {
            return "HP_ORT";
        } else if (equals(HP_FENSTER_ADRESSE)) {
            return "HP_FENSTER_ADRESSE";
        } else if (equals(HP_TELEFON)) {
            return "HP_TELEFON";
        } else if (equals(HP_STEUERNUMMER)) {
            return "HP_STEUERNUMMER";
        } else if (equals(HP_BRIEFANFANG)) {
            return "HP_ANFANG";
        } else if (equals(HP_BRIEFENDE)) {
            return "HP_BRIEFENDE";
        } else if (equals(HP_GRUSS)) {
            return "HP_GRUSS";
        } else if (equals(HP_BANK)) {
            return "HP_BANK";
        }
        return "HP_LOGO_UNTEN"; // HP_LOGO_UNTEN

    }

    public String toString2() {

        if (equals(HP_LOGO_OBEN)) {
            return "Logo-Dateiname#Höhe";
        } else if (equals(HP_NAME)) {
            return "Vorname Nachname";
        } else if (equals(HP_BERUF)) {
            return "Berufsbezeichnung";
        } else if (equals(HP_STRASSE)) {
            return "Straße Hausnummer";
        } else if (equals(HP_ORT)) {
            return "Postleitzahl Ort";
        } else if (equals(HP_FENSTER_ADRESSE)) {
            return "Straße Hausnummer, Postleitzahl Ort für Fenster";
        } else if (equals(HP_TELEFON)) {
            return "Telefon";
        } else if (equals(HP_STEUERNUMMER)) {
            return "Steuernummer";
        } else if (equals(HP_BRIEFANFANG)) {
            return "Brieftext Anfang";
        } else if (equals(HP_BRIEFENDE)) {
            return "Brieftext Ende";
        } else if (equals(HP_GRUSS)) {
            return "Grußformel";
        } else if (equals(HP_BANK)) {
            return "Bankverbindung";
        }
        return "Logo-Dateiname#Höhe"; // HP_LOGO_UNTEN

    }

    public static HpParameterEnum fromValue(final String v) {
        if (v != null) {
            for (HpParameterEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return null;
        // throw new IllegalArgumentException("ungültige HpParameterEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
package de.cwkuehl.jhh6.api.enums;

/**
 * Generierte Datei. BITTE NICHT AENDERN!
 * Generierte Aufzählung MoParameterEnum.
 */
public enum MoParameterEnum {
    /**
     * Messdiener-Parameter: Gottesdienst-Namen.
     */
    MO_NAME,

    /**
     * Messdiener-Parameter: Gottesdienst-Orte.
     */
    MO_ORT,

    /**
     * Messdiener-Parameter: Messdiener-Dienste.
     */
    MO_DIENSTE,

    /**
     * Messdiener-Parameter: Messdiener-Verfügbarkeit.
     */
    MO_VERFUEGBAR,

    /**
     * Messdiener-Parameter: Flambo-Grenze als Jahr.
     */
    MO_FLAMBO_GRENZE;
    public String toString() {

        if (equals(MO_NAME)) {
            return "MO_NAME";
        } else if (equals(MO_ORT)) {
            return "MO_ORT";
        } else if (equals(MO_DIENSTE)) {
            return "MO_DIENSTE";
        } else if (equals(MO_VERFUEGBAR)) {
            return "MO_VERFUEGBAR";
        }
        return "MO_FLAMBO_GRENZE"; // MO_FLAMBO_GRENZE

    }

    public String toString2() {

        if (equals(MO_NAME)) {
            return "Frühmesse;Hochamt;Vorabendmesse;Abendmesse;Hl. Messe;Jahresschlussmesse;Hirtenmesse;Vesper;Familiengottesdienst;Ökum. Familiengottesdienst;Jugendgottesdienst;Aschermittwochsgottesdienst;Palmsonntag-Gottesdienst;Gründonnerstag-Gottesdienst;Karfreitag-Gottesdienst;Ostersonntag-Gottesdienst;Osternacht-Gottesdienst;Weißer Sonntag;Weißer Montag";
        } else if (equals(MO_ORT)) {
            return "Pfarrkirche;Caritas-Zentrum;Kapelle";
        } else if (equals(MO_DIENSTE)) {
            return "Dienst;Zeremoniar;Weihrauch;Kreuz;Fahnen;Weihwasser;Altar;Akolyten;Buch;Flambo;Megaphon";
        } else if (equals(MO_VERFUEGBAR)) {
            return "Di 18:00;Do 18:00;Fr 18:00;Sa 18:00;So 08:00;So 10:00";
        }
        return "2014"; // MO_FLAMBO_GRENZE

    }

    public static MoParameterEnum fromValue(final String v) {

        if (v != null) {
            for (MoParameterEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return null;
        // throw new IllegalArgumentException("ungültige MoParameterEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
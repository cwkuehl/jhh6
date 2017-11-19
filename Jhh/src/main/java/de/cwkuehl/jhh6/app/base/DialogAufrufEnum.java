package de.cwkuehl.jhh6.app.base;

/**
 * Generierte Datei. BITTE NICHT AENDERN!
 * Generierte Aufzählung DialogAufrufEnum.
 */
@SuppressWarnings("all")
public enum DialogAufrufEnum {
    /**
     * Dialog-Aufrufart: ohne.
     */
    OHNE,

    /**
     * Dialog-Aufrufart: neu.
     */
    NEU,

    /**
     * Dialog-Aufrufart: kopieren.
     */
    KOPIEREN,

    /**
     * Dialog-Aufrufart: kopieren speziell.
     */
    KOPIEREN2,

    /**
     * Dialog-Aufrufart: Ändern.
     */
    AENDERN,

    /**
     * Dialog-Aufrufart: löschen.
     */
    LOESCHEN,

    /**
     * Dialog-Aufrufart: stornieren.
     */
    STORNO;
    public String toString() {

        if (equals(OHNE)) {
            return "OHNE";
        } else if (equals(NEU)) {
            return "Neu";
        } else if (equals(KOPIEREN)) {
            return "Kopieren";
        } else if (equals(KOPIEREN2)) {
            return "Kopieren ";
        } else if (equals(AENDERN)) {
            return "Ändern";
        } else if (equals(LOESCHEN)) {
            return "Löschen";
        }
        return "Stornieren"; // STORNO

    }

    public String toString2() {

        if (equals(OHNE)) {
            return "OHNE";
        } else if (equals(NEU)) {
            return "NEU";
        } else if (equals(KOPIEREN)) {
            return "KOPIEREN";
        } else if (equals(KOPIEREN2)) {
            return "KOPIEREN2";
        } else if (equals(AENDERN)) {
            return "AENDERN";
        } else if (equals(LOESCHEN)) {
            return "LOESCHEN";
        }
        return "STORNO"; // STORNO

    }

    public static DialogAufrufEnum fromValue(final String v) {
        if (v != null) {
            for (DialogAufrufEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige DialogAufrufEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
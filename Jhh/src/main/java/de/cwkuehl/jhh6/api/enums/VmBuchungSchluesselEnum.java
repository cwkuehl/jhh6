package de.cwkuehl.jhh6.api.enums;

/**
 * Generierte Datei. BITTE NICHT AENDERN!
 * Generierte Aufzählung VmBuchungSchluesselEnum.
 */
public enum VmBuchungSchluesselEnum {

    /**
     * Vermietung-Buchung-Schlüssel: Miete-Sollstellung.
     */
    MIET_SOLL,

    /**
     * Vermietung-Buchung-Schlüssel: Miete-Istbuchung.
     */
    MIET_IST,

    /**
     * Vermietung-Buchung-Schlüssel: Nebenkosten-Sollstellung.
     */
    NK_SOLL,

    /**
     * Vermietung-Buchung-Schlüssel: Nebenkosten-Istbuchung.
     */
    NK_IST,

    /**
     * Vermietung-Buchung-Schlüssel: Kaution-Sollstellung.
     */
    KAUTION_SOLL,

    /**
     * Vermietung-Buchung-Schlüssel: Kaution-Istbuchung.
     */
    KAUTION_IST,

    /**
     * Vermietung-Buchung-Schlüssel: Betriebskosten-Ausgabe.
     */
    BK_AUSGABE;
    public String toString() {

        if (equals(MIET_SOLL)) {
            return "MT_SOLL";
        } else if (equals(MIET_IST)) {
            return "MT_IST";
        } else if (equals(NK_SOLL)) {
            return "NK_SOLL";
        } else if (equals(NK_IST)) {
            return "NK_IST";
        } else if (equals(KAUTION_SOLL)) {
            return "KT_SOLL";
        } else if (equals(KAUTION_IST)) {
            return "KT_IST";
        }
        return "BK_AUSGABE"; // BK_AUSGABE

    }

    public String toString2() {

        if (equals(MIET_SOLL)) {
            return "MIET_SOLL";
        } else if (equals(MIET_IST)) {
            return "MIET_IST";
        } else if (equals(NK_SOLL)) {
            return "NK_SOLL";
        } else if (equals(NK_IST)) {
            return "NK_IST";
        } else if (equals(KAUTION_SOLL)) {
            return "KAUTION_SOLL";
        } else if (equals(KAUTION_IST)) {
            return "KAUTION_IST";
        }
        return "BK_AUSGABE"; // BK_AUSGABE

    }

    public static VmBuchungSchluesselEnum fromValue(final String v) {
        if (v != null) {
            for (VmBuchungSchluesselEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige VmBuchungSchluesselEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
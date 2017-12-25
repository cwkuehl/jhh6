package de.cwkuehl.jhh6.api.enums;

/**
 * Generierte Datei. BITTE NICHT AENDERN!
 * Generierte Aufzählung MoStatusEnum.
 */
public enum MoStatusEnum {

    /**
     * Messdiener-Status: automatisch.
     */
    AUTOMATISCH,

    /**
     * Messdiener-Status: manuell.
     */
    MANUELL;
    public String toString() {

        if (equals(AUTOMATISCH)) {
            return "AUTO";
        }
        return "MANUELL"; // MANUELL

    }

    public String toString2() {

        if (equals(AUTOMATISCH)) {
            return "automatisch";
        }
        return "manuell"; // MANUELL

    }

    public static MoStatusEnum fromValue(final String v) {
        if (v != null) {
            for (MoStatusEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige MoStatusEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung WpStatusEnum.
 */
public enum WpStatusEnum {

    /**
     * Wertpapier-Status: aktiv.
     */
    AKTIV,

    /**
     * Wertpapier-Status: inaktiv.
     */
    INAKTIV;

    public String toString() {

        if (equals(AKTIV)) {
            return "1";
        }
        return "0"; // INAKTIV

    }

    public String toString2() {

        if (equals(AKTIV)) {
            return "aktiv";
        }
        return "inaktiv"; // INAKTIV

    }

    public static WpStatusEnum fromValue(final String v) {
        if (v != null) {
            for (WpStatusEnum e : values()) {
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
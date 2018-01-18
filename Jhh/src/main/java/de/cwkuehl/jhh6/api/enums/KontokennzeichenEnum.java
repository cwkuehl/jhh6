package de.cwkuehl.jhh6.api.enums;

/**
 * Generierte Datei. BITTE NICHT AENDERN! Generierte Aufzählung KontokennzeichenEnum.
 */
@SuppressWarnings("all")
public enum KontokennzeichenEnum {
    /**
     * Konto-Kennzeichen: ohne Kennzeichen.
     */
    OHNE,

    /**
     * Konto-Kennzeichen: Eigenkapital.
     */
    EIGENKAPITEL,

    /**
     * Konto-Kennzeichen: Gewinn oder Verlust.
     */
    GEWINN_VERLUST,

    /**
     * Konto-Kennzeichen: B.
     */
    KEN_B,

    /**
     * Konto-Kennzeichen: D.
     */
    KEN_D,

    /**
     * Konto-Kennzeichen: I.
     */
    KEN_I,

    /**
     * Konto-Kennzeichen: O.
     */
    KEN_O;
    public String toString() {

        if (equals(OHNE)) {
            return "";
        } else if (equals(EIGENKAPITEL)) {
            return "E";
        } else if (equals(GEWINN_VERLUST)) {
            return "G";
        } else if (equals(KEN_B)) {
            return "B";
        } else if (equals(KEN_D)) {
            return "D";
        } else if (equals(KEN_I)) {
            return "I";
        }
        return "O"; // KEN_O

    }

    // public String toString2() {
    //
    // if (equals(OHNE)) {
    // return "OHNE";
    // } else if (equals(EIGENKAPITEL)) {
    // return "EIGENKAPITEL";
    // } else if (equals(GEWINN_VERLUST)) {
    // return "GEWINN_VERLUST";
    // } else if (equals(KEN_B)) {
    // return "KEN_B";
    // } else if (equals(KEN_D)) {
    // return "KEN_D";
    // } else if (equals(KEN_I)) {
    // return "KEN_I";
    // }
    // return "KEN_O"; // KEN_O
    //
    // }

    public static KontokennzeichenEnum fromValue(final String v) {

        if (v != null) {
            for (KontokennzeichenEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return null;
        // throw new IllegalArgumentException("ungültige KontokennzeichenEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
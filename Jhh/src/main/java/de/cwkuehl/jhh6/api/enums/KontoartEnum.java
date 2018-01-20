package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung KontoartEnum.
 */
public enum KontoartEnum {

    /**
     * Konto-Art: Aktivkonto.
     */
    AKTIVKONTO,

    /**
     * Konto-Art: Passivkonto.
     */
    PASSIVKONTO,

    /**
     * Konto-Art: Aufwandskonto.
     */
    AUFWANDSKONTO,

    /**
     * Konto-Art: Ertragskonto.
     */
    ERTRAGSKONTO;

    public String toString() {

        if (equals(AKTIVKONTO)) {
            return "AK";
        } else if (equals(PASSIVKONTO)) {
            return "PK";
        } else if (equals(AUFWANDSKONTO)) {
            return "AW";
        }
        return "ER"; // ERTRAGSKONTO

    }

    // public String toString2() {
    //
    // if (equals(AKTIVKONTO)) {
    // return "AKTIVKONTO";
    // } else if (equals(PASSIVKONTO)) {
    // return "PASSIVKONTO";
    // } else if (equals(AUFWANDSKONTO)) {
    // return "AUFWANDSKONTO";
    // }
    // return "ERTRAGSKONTO"; // ERTRAGSKONTO
    //
    // }

    public static KontoartEnum fromValue(final String v) {

        if (v != null) {
            for (KontoartEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return null;
        // throw new IllegalArgumentException("ungültige KontoartEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
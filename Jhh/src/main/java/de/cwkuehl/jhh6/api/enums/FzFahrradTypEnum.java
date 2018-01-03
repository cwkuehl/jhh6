package de.cwkuehl.jhh6.api.enums;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Aufzählung FzFahrradTypEnum.
 */
public enum FzFahrradTypEnum {

    /**
     * Fahrrad-Typ: Stände werden nach jeder Tour (jeden Tag) vermerkt.
     */
    TOUR,

    /**
     * Fahrrad-Typ: Pro Woche wird der Endstand vermerkt.
     */
    WOECHENTLICH;
    public String toString() {

        if (equals(TOUR)) {
            return "1";
        }
        return "2"; // WOECHENTLICH

    }

    public String toString2() {

        if (equals(TOUR)) {
            return Global.g0("bike.tour");
        }
        return Global.g0("bike.weekly"); // WOECHENTLICH

    }

    public static FzFahrradTypEnum fromValue(final String v) {

        if (v != null) {
            for (FzFahrradTypEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige FzFahrradTypEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
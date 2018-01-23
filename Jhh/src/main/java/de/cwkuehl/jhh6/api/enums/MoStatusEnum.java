package de.cwkuehl.jhh6.api.enums;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Aufzählung MoStatusEnum.
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
            return Global.g0("enum.state.auto");
        }
        return Global.g0("enum.state.manual"); // MANUELL
    }

    public static MoStatusEnum fromValue(final String v) {

        if (v != null) {
            for (MoStatusEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return MANUELL;
        // throw new IllegalArgumentException("ungültige MoStatusEnum: " + v);
    }

    // public String getItemValue() {
    // return toString();
    // }
}
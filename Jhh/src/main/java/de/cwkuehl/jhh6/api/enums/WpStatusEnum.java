package de.cwkuehl.jhh6.api.enums;

import de.cwkuehl.jhh6.api.global.Global;

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
            return Global.g0("enum.state.active");
        }
        return Global.g0("enum.state.inactive"); // INAKTIV
    }

    // public static WpStatusEnum fromValue(final String v) {
    //
    // if (v != null) {
    // for (WpStatusEnum e : values()) {
    // if (v.equals(e.toString())) {
    // return e;
    // }
    // }
    // }
    // return AKTIV;
    // // throw new IllegalArgumentException("ungültige WpStatusEnum: " + v);
    // }

    // public String getItemValue() {
    // return toString();
    // }
}
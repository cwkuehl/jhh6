package de.cwkuehl.jhh6.api.enums;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Aufzählung PersonStatusEnum.
 */
public enum PersonStatusEnum {

    /**
     * Person-Status: aktuell.
     */
    AKTUELL,

    /**
     * Person-Status: nicht aktuell.
     */
    ALT;

    public String toString() {

        if (equals(AKTUELL)) {
            return "0";
        }
        return "1"; // ALT

    }

    public String toString2() {

        if (equals(AKTUELL)) {
            return Global.g0("enum.state.actual");
        }
        return Global.g0("enum.state.old"); // ALT

    }

    // public static PersonStatusEnum fromValue(final String v) {
    //
    // if (v != null) {
    // for (PersonStatusEnum e : values()) {
    // if (v.equals(e.toString())) {
    // return e;
    // }
    // }
    // }
    // return ALT;
    // // throw new IllegalArgumentException("ungültige PersonStatusEnum: " + v);
    // }

    // public String getItemValue() {
    // return toString();
    // }

    public int intValue() {

        if (equals(AKTUELL)) {
            return 0;
        }
        return 1; // ALT
    }

    // public static PersonStatusEnum fromIntValue(final int v) {
    //
    // for (PersonStatusEnum e : values()) {
    // if (v == e.intValue()) {
    // return e;
    // }
    // }
    // throw new IllegalArgumentException("ungültige PersonStatusEnum: " + v);
    // }
}
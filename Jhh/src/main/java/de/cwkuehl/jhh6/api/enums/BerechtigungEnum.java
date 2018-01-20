package de.cwkuehl.jhh6.api.enums;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Aufzählung BerechtigungEnum.
 */
public enum BerechtigungEnum {

    /**
     * Berechtigung: Keine.
     */
    KEINE,

    /**
     * Berechtigung: Benutzer.
     */
    BENUTZER,

    /**
     * Berechtigung: Administrator.
     */
    ADMIN,

    /**
     * Berechtigung: Alles.
     */
    ALLES;

    public String toString() {

        if (equals(KEINE)) {
            return "-1";
        } else if (equals(BENUTZER)) {
            return "0";
        } else if (equals(ADMIN)) {
            return "1";
        }
        return "2"; // ALLES

    }

    public String toString2() {

        if (equals(KEINE)) {
            return Global.g0("enum.permission.no");
        } else if (equals(BENUTZER)) {
            return Global.g0("enum.permission.user");
        } else if (equals(ADMIN)) {
            return Global.g0("enum.permission.admin");
        }
        return Global.g0("enum.permission.all"); // ALLES

    }

    public static BerechtigungEnum fromValue(final String v) {

        if (v != null) {
            for (BerechtigungEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return null;
        // throw new IllegalArgumentException("ungültige BerechtigungEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }

    public int intValue() {

        if (equals(KEINE)) {
            return -1;
        } else if (equals(BENUTZER)) {
            return 0;
        } else if (equals(ADMIN)) {
            return 1;
        }
        return 2; // ALLES

    }

    public static BerechtigungEnum fromIntValue(final int v) {

        for (BerechtigungEnum e : values()) {
            if (v == e.intValue()) {
                return e;
            }
        }
        return KEINE;
        // throw new IllegalArgumentException("ungültige BerechtigungEnum: " + v);
    }
}

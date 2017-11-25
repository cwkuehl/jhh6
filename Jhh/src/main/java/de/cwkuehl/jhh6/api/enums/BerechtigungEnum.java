package de.cwkuehl.jhh6.api.enums;

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
            return "Keine";
        } else if (equals(BENUTZER)) {
            return "Benutzer";
        } else if (equals(ADMIN)) {
            return "Administrator";
        }
        return "Alles"; // ALLES

    }

    public static BerechtigungEnum fromValue(final String v) {

        if (v != null) {
            for (BerechtigungEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige BerechtigungEnum: " + v);
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
        throw new IllegalArgumentException("ungültige BerechtigungEnum: " + v);
    }
}

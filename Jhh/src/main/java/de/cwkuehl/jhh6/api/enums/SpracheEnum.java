package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung SpracheEnum.
 */
public enum SpracheEnum {

    /**
     * Sprache: ohne.
     */
    OHNE,

    /**
     * Sprache: deutsch.
     */
    DEUTSCH,

    /**
     * Sprache: englisch.
     */
    ENGLISCH,

    /**
     * Sprache: französisch.
     */
    FRANZOESISCH;

    public String toString() {

        if (equals(OHNE)) {
            return "0";
        } else if (equals(DEUTSCH)) {
            return "1";
        } else if (equals(ENGLISCH)) {
            return "2";
        }
        return "3"; // FRANZOESISCH

    }

    public static SpracheEnum fromValue(final String v) {

        if (v != null) {
            for (SpracheEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return OHNE;
        // throw new IllegalArgumentException("ungültige SpracheEnum: " + v);
    }

    public int intValue() {

        if (equals(OHNE)) {
            return 0;
        } else if (equals(DEUTSCH)) {
            return 1;
        } else if (equals(ENGLISCH)) {
            return 2;
        }
        return 3; // FRANZOESISCH
    }
}
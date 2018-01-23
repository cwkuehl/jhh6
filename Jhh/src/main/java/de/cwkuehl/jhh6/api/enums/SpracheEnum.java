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
    ENGLISCH;

    public String toString() {

        if (equals(OHNE)) {
            return "0";
        } else if (equals(DEUTSCH)) {
            return "1";
        }
        return "2"; // ENGLISCH

    }

    // public String toString2() {
    //
    // if (equals(OHNE)) {
    // return "ohne";
    // } else if (equals(DEUTSCH)) {
    // return "deutsch";
    // }
    // return "englisch"; // ENGLISCH
    //
    // }

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

    // public String getItemValue() {
    // return toString();
    // }

    public int intValue() {

        if (equals(OHNE)) {
            return 0;
        } else if (equals(DEUTSCH)) {
            return 1;
        }
        return 2; // ENGLISCH
    }

    // public static SpracheEnum fromIntValue(final int v) {
    //
    // for (SpracheEnum e : values()) {
    // if (v == e.intValue()) {
    // return e;
    // }
    // }
    // return OHNE;
    // // throw new IllegalArgumentException("ungültige SpracheEnum: " + v);
    // }
}
package de.cwkuehl.jhh6.api.rollback;

/**
 * Generierte Datei. BITTE NICHT AENDERN!
 * Generierte Aufzählung RollbackArtEnum.
 */
@SuppressWarnings("all")
public enum RollbackArtEnum {
    /**
     * Rollback-Art: Insert.
     */
    INSERT,

    /**
     * Rollback-Art: Update.
     */
    UPDATE,

    /**
     * Rollback-Art: Delete.
     */
    DELETE;
    public String toString() {

        if (equals(INSERT)) {
            return "INSERT";
        } else if (equals(UPDATE)) {
            return "UPDATE";
        }
        return "DELETE"; // DELETE

    }

    public String toString2() {

        if (equals(INSERT)) {
            return "INSERT";
        } else if (equals(UPDATE)) {
            return "UPDATE";
        }
        return "DELETE"; // DELETE

    }

    public static RollbackArtEnum fromValue(final String v) {
        if (v != null) {
            for (RollbackArtEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige RollbackArtEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}
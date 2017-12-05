package de.cwkuehl.jhh6.api.service.backup;

/**
 * Klasse zum Speichern der Daten einer Datei in einer Sicherung.
 */
public class Sicherungsdatei {

    /** Änderungszeitpunkt. */
    private long   modified = 0;
    /** Pfad der Datei in Differenz-Verzeichnis. */
    private String pfad     = null;

    /**
     * Konstruktor mit Initialisierung.
     * @param pmodified Änderungszeitpunkt.
     * @param ppfad Pfad der Datei in Differenz-Verzeichnis.
     */
    public Sicherungsdatei(final long pmodified, final String ppfad) {
        modified = pmodified;
        pfad = ppfad;
    }

    /**
     * @return Liefert modified.
     */
    public final long getModified() {
        return modified;
    }

    /**
     * @return Liefert pfad.
     */
    public final String getPfad() {
        return pfad;
    }

}

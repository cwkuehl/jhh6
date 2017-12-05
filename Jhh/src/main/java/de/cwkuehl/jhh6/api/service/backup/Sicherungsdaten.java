package de.cwkuehl.jhh6.api.service.backup;

/**
 * Klasse zum Speichern der notwendigen Aktionen bei einer Sicherung.
 */
public class Sicherungsdaten {

    /**
     * Aktion: VA Verzeichnis anlegen, VL Verzeichnis löschen, DK Datei kopieren, DL Datei löschen.
     */
    private String  aktion        = null;
    /** Name von Verzeichnis oder Datei. */
    private String  name          = null;
    /** Ursprungs-Pfad. */
    private String  pfadPfad      = null;
    /** Pfad in der Sicherung. */
    private String  sichPfad      = null;
    /** Basis-Pfad in der Sicherung. */
    private String  sichBasisPfad = null;
    /** Pfad in der Differenz-Sicherung. */
    private String  diffPfad      = null;
    /** Kennzeichen für Erledigung. */
    private boolean erledigt      = false;

    /**
     * Konstruktor mit Initialisierung.
     * @param paktion Aktion.
     * @param pname Name von Verzeichnis oder Datei.
     * @param ppfadPfad Ursprungs-Pfad.
     * @param psichPfad Pfad in der Sicherung.
     */
    public Sicherungsdaten(final String paktion, final String pname, final String ppfadPfad, final String psichPfad,
            final String psichBasisPfad, final String pdiffPfad) {
        aktion = paktion;
        name = pname;
        pfadPfad = ppfadPfad;
        sichPfad = psichPfad;
        sichBasisPfad = psichBasisPfad;
        diffPfad = pdiffPfad;
    }

    /**
     * @return Liefert aktion.
     */
    public final String getAktion() {
        return aktion;
    }

    /**
     * @return Liefert name.
     */
    public final String getName() {
        return name;
    }

    /**
     * @return Liefert pfadPfad.
     */
    public final String getPfadPfad() {
        return pfadPfad;
    }

    /**
     * @return Liefert sichPfad.
     */
    public final String getSichPfad() {
        return sichPfad;
    }

    /**
     * @return Liefert sichBasisPfad.
     */
    public final String getSichBasisPfad() {
        return sichBasisPfad;
    }

    /**
     * @return Liefert diffPfad.
     */
    public final String getDiffPfad() {
        return diffPfad;
    }

    /**
     * @return Liefert erledigt.
     */
    public final boolean isErledigt() {
        return erledigt;
    }

    /**
     * @param perledigt Der erledigt wird gesetzt.
     */
    public final void setErledigt(final boolean perledigt) {
        erledigt = perledigt;
    }

}

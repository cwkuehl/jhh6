package de.cwkuehl.jhh6.server.fop.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Diese Klasse regelt das Schreiben des Monatzeichens in das Chart.
 */
public class PnfDatum {

    /** Aktueller Kurs-Zeitpunkt. */
    private LocalDateTime datum  = null;

    /** Letztes Datum der Säule zur Bestimmung des Monatsanfangs. */
    private LocalDate     datumm = null;

    /** Aktuell zu schreibender Monat. */
    private int           monat  = 0;

    public LocalDateTime getDatum() {
        return datum;
    }

    public void setDatum(LocalDateTime datum) {

        this.datum = datum;
        monat = 0;
        LocalDate d = datum.toLocalDate();
        if (datumm == null || (datumm.getYear() * 100 + datumm.getMonthValue() < d.getYear() * 100 + d.getMonthValue())) {
            monat = d.getMonthValue();
        }
    }

    public char getNeuerMonat(char c) {

        if (monat > 0) {
            if (monat < 10) {
                return (char) ((int) '0' + monat);
            }
            return (char) ((int) 'A' + monat - 10);
        }
        return c;
    }

    public void setMonatVerwendet() {

        if (datum != null) {
            this.datumm = datum.toLocalDate();
        }
        monat = 0;
    }

}

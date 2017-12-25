package de.cwkuehl.jhh6.server.fop.dto;

import java.time.LocalDateTime;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Point & Figure-Column.
 */
public class PnfColumn {

    /** Minimum der Säule. */
    private double        min    = Double.POSITIVE_INFINITY;
    /** Maximum der Säule. */
    private double        max    = Double.NEGATIVE_INFINITY;
    /** Position der Säule. */
    private int           ypos   = 0;
    /** Boxtyp: 0 unbestimmt; 1 aufwärts (X); 2 abwärts (O). */
    private int           boxtyp = 0;
    /** Anfangsdatum der Säule. */
    private LocalDateTime datum  = null;
    /** Inhalt der Säule, bestehend aus X oder O. */
    private StringBuilder sb     = new StringBuilder();
    /** Inhalt der Säule, bestehend aus X oder O oder Monatszeichen (1-C). */
    private StringBuilder sbm    = new StringBuilder();

    public PnfColumn(double min, double max, int boxtyp, int anzahl, PnfDatum datum) {

        this.min = min;
        this.max = max;
        this.boxtyp = boxtyp;
        this.datum = datum.getDatum();
        for (int i = 0; i < anzahl; i++) {
            zeichne(datum);
        }
    }

    public void zeichne(PnfDatum datum) {

        char c = boxtyp == 1 ? 'X' : 'O';
        char cm = datum.getNeuerMonat(c);
        sb.append(c);
        sbm.append(cm);
        datum.setMonatVerwendet();
    }

    public boolean isO() {

        if (sb.length() <= 0) {
            return getBoxtyp() == 2;
        }
        char eins = sb.charAt(0);
        // return (getBoxtyp() == 2 && eins == 'O');
        return eins == 'O';
    }

    public int getSize() {
        return sb.length();
    }

    public String getString() {
        return sb.toString();
    }

    public char[] getChars() {

        if (sbm.length() <= 0) {
            return new char[0];
        }
        char[] array = null;
        if (getBoxtyp() == 2) {
            array = new StringBuilder(sbm).reverse().toString().toCharArray();
        } else {
            array = sbm.toString().toCharArray();
        }
        return array;
    }

    public double getMin() {
        return min;
    }

    /**
     * Setzen eines neuen Maximums. Wenn das Maximum erhöht wird, wird ein X gezeichnet.
     * @param max Neues mögliches Maximum.
     */
    public void setMin(double min, PnfDatum datum) {

        if (Global.compDouble4(this.min, min) > 0) {
            this.min = min;
            zeichne(datum);
        }
    }

    public double getMax() {
        return max;
    }

    /**
     * Setzen eines neuen Maximums. Wenn das Maximum erhöht wird, wird ein X gezeichnet.
     * @param max Neues mögliches Maximum.
     */
    public void setMax(double max, PnfDatum datum) {

        if (Global.compDouble4(this.max, max) < 0) {
            this.max = max;
            zeichne(datum);
        }
    }

    public int getBoxtyp() {
        return boxtyp;
    }

    public void setBoxtyp(int boxtyp) {
        this.boxtyp = boxtyp;
    }

    public int getYpos() {
        return ypos;
    }

    public void setYpos(int pos) {
        this.ypos = pos;
    }

    public int getYtop() {
        return ypos + getSize();
    }

    public LocalDateTime getDatum() {
        return datum;
    }

    // public void setDatum(LocalDateTime datum) {
    // this.datum = datum;
    // }

}

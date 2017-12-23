package de.cwkuehl.jhh6.app.control.table;

/**
 * Formel in einer Zelle.
 * <p>
 * Erstellt am 06.01.2013.
 */
final class CellFormel {

    private String funktion = null;
    private int    spalte1  = -1;
    private int    zeile1   = -1;
    private int    spalte2  = -1;
    private int    zeile2   = -1;

    public String getFunktion() {
        return funktion;
    }

    public void setFunktion(String funktion) {
        this.funktion = funktion;
    }

    public int getSpalte1() {
        return spalte1;
    }

    public void setSpalte1(int spalte1) {
        this.spalte1 = spalte1;
    }

    public int getZeile1() {
        return zeile1;
    }

    public void setZeile1(int zeile1) {
        this.zeile1 = zeile1;
    }

    public int getSpalte2() {
        return spalte2;
    }

    public void setSpalte2(int spalte2) {
        this.spalte2 = spalte2;
    }

    public int getZeile2() {
        return zeile2;
    }

    public void setZeile2(int zeile2) {
        this.zeile2 = zeile2;
    }

}

package de.cwkuehl.jhh6.app.control.table;

import javafx.beans.property.SimpleStringProperty;

/**
 * Zellinhalt.
 * <p>
 * Erstellt am 09.04.2007.
 */
final class CellInhalt {

    private String               formel      = null;
    private SimpleStringProperty wert        = new SimpleStringProperty();
    private boolean              fett        = false;
    private char                 ausrichtung = 'l';  // l: links, r: rechts, c: zentriert
    private String               format      = null;
    private CellFormel           zellFormel  = null;

    /**
     * @return the formel
     */
    public String getFormel() {
        return formel;
    }

    /**
     * @param formel the formel to set
     */
    public void setFormel(String formel) {
        this.formel = formel;
        this.wert.set(formel);
        FormelParser.parse(this);
        // Wert aus Formel wird im Model berechnet
    }

    /**
     * @return the wert
     */
    public SimpleStringProperty getValue() {
        return wert;
    }

    /**
     * @return the wert
     */
    public String getWert() {
        return wert.get();
    }

    /**
     * @return the fett
     */
    public boolean isFett() {
        return fett;
    }

    /**
     * @param fett the fett to set
     */
    public void setFett(boolean fett) {
        this.fett = fett;
    }

    /**
     * @return the zellFormel
     */
    public CellFormel getZellFormel() {
        return zellFormel;
    }

    /**
     * @param zellFormel the zellFormel to set
     */
    public void setZellFormel(CellFormel zellFormel) {
        this.zellFormel = zellFormel;
    }

    /**
     * Sollte nur von der Formel-Berechnung benutzt werden.
     * @param wert the wert to set
     */
    public void setWert(String wert) {
        this.wert.set(wert);
    }

    /**
     * @return the ausrichtung
     */
    public char getAusrichtung() {
        return ausrichtung;
    }

    /**
     * @param ausrichtung the ausrichtung to set
     */
    public void setAusrichtung(char ausrichtung) {
        this.ausrichtung = ausrichtung;
    }

    /**
     * @return the format
     */
    public String getFormat() {
        return format;
    }

    /**
     * @param format the format to set
     */
    public void setFormat(String format) {
        this.format = format;
    }

}

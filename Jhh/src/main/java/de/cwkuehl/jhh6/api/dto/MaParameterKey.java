package de.cwkuehl.jhh6.api.dto;

import java.io.Serializable;

import javax.annotation.Generated;

import de.cwkuehl.jhh6.api.dto.base.DtoBase;

/**
 * Generiertes Data Transfer Object für Primärschlüssel der Tabelle MA_Parameter.
 */
@SuppressWarnings("all")
@Generated("org.eclipse.xtend.core.compiler.XtendGenerator")
public class MaParameterKey extends DtoBase implements Serializable {
  /**
   * Versionsnummer.
   */
  private final static long serialVersionUID = 1l;
  
  /**
   * Name der Spalte MA_Parameter.
   */
  public final static String TAB_NAME = "MA_Parameter";
  
  /**
   * Länge der Spalte Schluessel.
   */
  public final static int SCHLUESSEL_LAENGE = 50;
  
  /**
   * Name der Spalte Mandant_Nr.
   */
  public final static String MANDANT_NR_NAME = "Mandant_Nr";
  
  /**
   * Name der Spalte Schluessel.
   */
  public final static String SCHLUESSEL_NAME = "Schluessel";
  
  /**
   * Standard-Konstruktor.
   */
  public MaParameterKey() {
    
  }
  
  /**
   * Konstruktor mit Initialisierung.
   */
  public MaParameterKey(final int mandantNr, final String schluessel) {
    this.mandantNr = mandantNr;
    					this.schluessel = schluessel;
  }
  
  /**
   * Spalte Mandant_Nr.
   */
  private int mandantNr;
  
  /**
   * Liefert Wert der Spalte Mandant_Nr.
   * @return Wert der Spalte Mandant_Nr.
   */
  public int getMandantNr() {
    return mandantNr;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Mandant_Nr.
   * @param v Neuer Wert der Spalte Mandant_Nr.
   */
  public void setMandantNr(final int v) {
    this.mandantNr = v;
  }
  
  /**
   * Spalte Schluessel.
   */
  private String schluessel;
  
  /**
   * Liefert Wert der Spalte Schluessel.
   * @return Wert der Spalte Schluessel.
   */
  public String getSchluessel() {
    return schluessel;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Schluessel.
   * @param v Neuer Wert der Spalte Schluessel.
   */
  public void setSchluessel(final String v) {
    this.schluessel = v;
  }
}

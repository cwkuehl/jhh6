package de.cwkuehl.jhh6.api.dto;

import java.time.LocalDateTime;

import javax.annotation.Generated;

/**
 * Generiertes Data Transfer Object für Tabelle MA_Parameter.
 */
@SuppressWarnings("all")
@Generated("org.eclipse.xtend.core.compiler.XtendGenerator")
public class MaParameter extends MaParameterKey {
  /**
   * Versionsnummer.
   */
  private final static long serialVersionUID = 1l;
  
  /**
   * Länge der Spalte Wert.
   */
  public final static int WERT_LAENGE = 255;
  
  /**
   * Länge der Spalte Angelegt_Von.
   */
  public final static int ANGELEGT_VON_LAENGE = 20;
  
  /**
   * Länge der Spalte Geaendert_Von.
   */
  public final static int GEAENDERT_VON_LAENGE = 20;
  
  /**
   * Länge der Spalte Replikation_Uid.
   */
  public final static int REPLIKATION_UID_LAENGE = 35;
  
  /**
   * Name der Spalte Wert.
   */
  public final static String WERT_NAME = "Wert";
  
  /**
   * Name der Spalte Angelegt_Von.
   */
  public final static String ANGELEGT_VON_NAME = "Angelegt_Von";
  
  /**
   * Name der Spalte Angelegt_Am.
   */
  public final static String ANGELEGT_AM_NAME = "Angelegt_Am";
  
  /**
   * Name der Spalte Geaendert_Von.
   */
  public final static String GEAENDERT_VON_NAME = "Geaendert_Von";
  
  /**
   * Name der Spalte Geaendert_Am.
   */
  public final static String GEAENDERT_AM_NAME = "Geaendert_Am";
  
  /**
   * Name der Spalte Replikation_Uid.
   */
  public final static String REPLIKATION_UID_NAME = "Replikation_Uid";
  
  /**
   * Liefert Instanz des Primärschlüssels.
   * @return Primärschlüssel.
   */
  public MaParameterKey getPk() {
    MaParameterKey pk = new MaParameterKey();
    pk.setMandantNr(getMandantNr());
    pk.setSchluessel(getSchluessel());
    return pk;
  }
  
  /**
   * Liefert Kopie der Instanz.
   * @return Kopie der Instanz.
   */
  public MaParameter getClone() {
    MaParameter c = new MaParameter();
    c.setReplikation(isReplikation());
    c.setMandantNr(getMandantNr());
    c.setSchluessel(getSchluessel());
    c.setWert(getWert());
    c.setAngelegtVon(getAngelegtVon());
    c.setAngelegtAm(getAngelegtAm());
    c.setGeaendertVon(getGeaendertVon());
    c.setGeaendertAm(getGeaendertAm());
    c.setReplikationUid(getReplikationUid());
    return c;
  }
  
  /**
   * Spalte Wert.
   */
  private String wert;
  
  /**
   * Liefert Wert der Spalte Wert.
   * @return Wert der Spalte Wert.
   */
  public String getWert() {
    return wert;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Wert.
   * @param v Neuer Wert der Spalte Wert.
   */
  public void setWert(final String v) {
    this.wert = v;
  }
  
  /**
   * Spalte Angelegt_Von.
   */
  private String angelegtVon;
  
  /**
   * Liefert Wert der Spalte Angelegt_Von.
   * @return Wert der Spalte Angelegt_Von.
   */
  public String getAngelegtVon() {
    return angelegtVon;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Angelegt_Von.
   * @param v Neuer Wert der Spalte Angelegt_Von.
   */
  public void setAngelegtVon(final String v) {
    this.angelegtVon = v;
  }
  
  /**
   * Spalte Angelegt_Am.
   */
  private LocalDateTime angelegtAm;
  
  /**
   * Liefert Wert der Spalte Angelegt_Am.
   * @return Wert der Spalte Angelegt_Am.
   */
  public LocalDateTime getAngelegtAm() {
    return angelegtAm;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Angelegt_Am.
   * @param v Neuer Wert der Spalte Angelegt_Am.
   */
  public void setAngelegtAm(final LocalDateTime v) {
    this.angelegtAm = v;
  }
  
  /**
   * Spalte Geaendert_Von.
   */
  private String geaendertVon;
  
  /**
   * Liefert Wert der Spalte Geaendert_Von.
   * @return Wert der Spalte Geaendert_Von.
   */
  public String getGeaendertVon() {
    return geaendertVon;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Geaendert_Von.
   * @param v Neuer Wert der Spalte Geaendert_Von.
   */
  public void setGeaendertVon(final String v) {
    this.geaendertVon = v;
  }
  
  /**
   * Spalte Geaendert_Am.
   */
  private LocalDateTime geaendertAm;
  
  /**
   * Liefert Wert der Spalte Geaendert_Am.
   * @return Wert der Spalte Geaendert_Am.
   */
  public LocalDateTime getGeaendertAm() {
    return geaendertAm;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Geaendert_Am.
   * @param v Neuer Wert der Spalte Geaendert_Am.
   */
  public void setGeaendertAm(final LocalDateTime v) {
    this.geaendertAm = v;
  }
  
  /**
   * Spalte Replikation_Uid.
   */
  private String replikationUid;
  
  /**
   * Liefert Wert der Spalte Replikation_Uid.
   * @return Wert der Spalte Replikation_Uid.
   */
  public String getReplikationUid() {
    return replikationUid;
  }
  
  /**
   * Setzen eines neuen Wertes für Spalte Replikation_Uid.
   * @param v Neuer Wert der Spalte Replikation_Uid.
   */
  public void setReplikationUid(final String v) {
    this.replikationUid = v;
  }
}

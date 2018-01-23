package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung VmKontoSchluesselEnum.
 */
public enum VmKontoSchluesselEnum {

    /**
     * Vermietung-Konto-Schlüssel: AK Mietforderungen.
     */
    KP200_MIETFORDERUNGEN,

    /**
     * Vermietung-Konto-Schlüssel: AK Kassenbestand.
     */
    KP271_KASSE,

    /**
     * Vermietung-Konto-Schlüssel: AK Bank.
     */
    KP2740_BANK,

    /**
     * Vermietung-Konto-Schlüssel: PK Eigenkapital.
     */
    KP301_EK,

    /**
     * Vermietung-Konto-Schlüssel: PK Erhaltene Kaution.
     */
    KP3550_KAUTION,

    /**
     * Vermietung-Konto-Schlüssel: PK Anzahlungen auf unfertige Leistungen (Betriebskosten).
     */
    KP431_ANZAHLUNG,

    /**
     * Vermietung-Konto-Schlüssel: PK Verbindlichkeiten aus Lieferungen und Leistungen.
     */
    KP442_VERBINDLICHKEIT,

    /**
     * Vermietung-Konto-Schlüssel: ER Gewinn/Verlust.
     */
    KP60_GV,

    /**
     * Vermietung-Konto-Schlüssel: ER Sollmieten.
     */
    KP600_SOLLMIETEN,

    /**
     * Vermietung-Konto-Schlüssel: ER Erträge Mieterbelastung.
     */
    KP66982_ERTRAEGE,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Wasserversorgung.
     */
    KP8000_WASSER,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Entwässerung.
     */
    KP8001_ABWASSER,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Beheizung.
     */
    KP8002_HEIZUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Straßenreinigung.
     */
    KP8005_STRASSENREINIGUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Müllabfuhr.
     */
    KP8006_MUELL,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Gartenpflege.
     */
    KP8009_GARTEN,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Beleuchtung.
     */
    KP8011_BELEUCHTUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Schornsteinreinigung.
     */
    KP8012_SCHORNSTEIN,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten der Sach- und Haftpflichtversicherung.
     */
    KP8013_VERSICHERUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Kosten für fremde Hauswartleistungen.
     */
    KP8014_VERSICHERUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Instandhaltung.
     */
    KP805_INSTANDHALTUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Mieterbelastung.
     */
    KP8099_MIETERBELASTUNG,

    /**
     * Vermietung-Konto-Schlüssel: AW Löhne und Gehälter.
     */
    KP830_GEHAELTER,

    /**
     * Vermietung-Konto-Schlüssel: AW Soziale Abgaben.
     */
    KP831_ABGABEN,

    /**
     * Vermietung-Konto-Schlüssel: AW Sächliche Verwaltungsaufwendungen.
     */
    KP850_AUFWENDUNGEN,

    /**
     * Vermietung-Konto-Schlüssel: AW Körperschaftssteuer.
     */
    KP8900_STEUER,

    /**
     * Vermietung-Konto-Schlüssel: AW Grundsteuer.
     */
    KP8910_GRUNDSTEUER;

    public String toString() {

        if (equals(KP200_MIETFORDERUNGEN)) {
            return "KP200";
        } else if (equals(KP271_KASSE)) {
            return "KP271";
        } else if (equals(KP2740_BANK)) {
            return "KP2740";
        } else if (equals(KP301_EK)) {
            return "KP301";
        } else if (equals(KP3550_KAUTION)) {
            return "KP3550";
        } else if (equals(KP431_ANZAHLUNG)) {
            return "KP431";
        } else if (equals(KP442_VERBINDLICHKEIT)) {
            return "KP442";
        } else if (equals(KP60_GV)) {
            return "KP60";
        } else if (equals(KP600_SOLLMIETEN)) {
            return "KP600";
        } else if (equals(KP66982_ERTRAEGE)) {
            return "KP66982";
        } else if (equals(KP8000_WASSER)) {
            return "KP8000";
        } else if (equals(KP8001_ABWASSER)) {
            return "KP8001";
        } else if (equals(KP8002_HEIZUNG)) {
            return "KP8002";
        } else if (equals(KP8005_STRASSENREINIGUNG)) {
            return "KP8005";
        } else if (equals(KP8006_MUELL)) {
            return "KP8006";
        } else if (equals(KP8009_GARTEN)) {
            return "KP8009";
        } else if (equals(KP8011_BELEUCHTUNG)) {
            return "KP8011";
        } else if (equals(KP8012_SCHORNSTEIN)) {
            return "KP8012";
        } else if (equals(KP8013_VERSICHERUNG)) {
            return "KP8013";
        } else if (equals(KP8014_VERSICHERUNG)) {
            return "KP8014";
        } else if (equals(KP805_INSTANDHALTUNG)) {
            return "KP805";
        } else if (equals(KP8099_MIETERBELASTUNG)) {
            return "KP8099";
        } else if (equals(KP830_GEHAELTER)) {
            return "KP830";
        } else if (equals(KP831_ABGABEN)) {
            return "KP831";
        } else if (equals(KP850_AUFWENDUNGEN)) {
            return "KP850";
        } else if (equals(KP8900_STEUER)) {
            return "KP8900";
        }
        return "KP8910"; // KP8910_GRUNDSTEUER

    }

    public String toString2() {

        if (equals(KP200_MIETFORDERUNGEN)) {
            return "AK Mietforderungen";
        } else if (equals(KP271_KASSE)) {
            return "AK Kassenbestand";
        } else if (equals(KP2740_BANK)) {
            return "AK Bank";
        } else if (equals(KP301_EK)) {
            return "PK Eigenkapital";
        } else if (equals(KP3550_KAUTION)) {
            return "PK Erhaltene Kaution";
        } else if (equals(KP431_ANZAHLUNG)) {
            return "PK Anzahlungen auf unfertige Leistungen (Betriebskosten)";
        } else if (equals(KP442_VERBINDLICHKEIT)) {
            return "PK Verbindlichkeiten aus Lief. und Leist.";
        } else if (equals(KP60_GV)) {
            return "ER Gewinn/Verlust";
        } else if (equals(KP600_SOLLMIETEN)) {
            return "ER Sollmieten";
        } else if (equals(KP66982_ERTRAEGE)) {
            return "ER Erträge Mieterbelastung";
        } else if (equals(KP8000_WASSER)) {
            return "AW Kosten der Wasserversorgung";
        } else if (equals(KP8001_ABWASSER)) {
            return "AW Kosten der Entwässerung";
        } else if (equals(KP8002_HEIZUNG)) {
            return "AW Kosten der Beheizung";
        } else if (equals(KP8005_STRASSENREINIGUNG)) {
            return "AW Kosten der Straßenreinigung";
        } else if (equals(KP8006_MUELL)) {
            return "AW Kosten der Müllabfuhr";
        } else if (equals(KP8009_GARTEN)) {
            return "AW Kosten der Gartenpflege";
        } else if (equals(KP8011_BELEUCHTUNG)) {
            return "AW Kosten der Beleuchtung";
        } else if (equals(KP8012_SCHORNSTEIN)) {
            return "AW Kosten der Schornsteinreinigung";
        } else if (equals(KP8013_VERSICHERUNG)) {
            return "AW Kosten der Sach- und Haftpflichtversicherung";
        } else if (equals(KP8014_VERSICHERUNG)) {
            return "AW Kosten für fremde Hauswartleistungen";
        } else if (equals(KP805_INSTANDHALTUNG)) {
            return "AW Instandhaltung";
        } else if (equals(KP8099_MIETERBELASTUNG)) {
            return "AW Mieterbelastung";
        } else if (equals(KP830_GEHAELTER)) {
            return "AW Löhne und Gehälter";
        } else if (equals(KP831_ABGABEN)) {
            return "AW Soziale Abgaben";
        } else if (equals(KP850_AUFWENDUNGEN)) {
            return "AW Sächliche Verwaltungsaufwendungen";
        } else if (equals(KP8900_STEUER)) {
            return "AW Körperschaftssteuer";
        }
        return "AW Grundsteuer"; // KP8910_GRUNDSTEUER
    }

    // public static VmKontoSchluesselEnum fromValue(final String v) {
    //
    // if (v != null) {
    // for (VmKontoSchluesselEnum e : values()) {
    // if (v.equals(e.toString())) {
    // return e;
    // }
    // }
    // }
    // return null;
    // // throw new IllegalArgumentException("ungültige VmKontoSchluesselEnum: " + v);
    // }

    // public String getItemValue() {
    // return toString();
    // }
}
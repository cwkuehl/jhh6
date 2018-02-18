package de.cwkuehl.jhh6.server.service.impl;

public enum BuchungSpalten {

    VALUTA("SollValuta", true), KZ("Kz", false), BETRAG("EBetrag", true), SOLLUID("SollKonto", true), HABENUID(
            "HabenKonto", true), TEXT("BText", true), BELEGNR("Beleg_Nr", false), BELEGDATUM("Beleg_Datum",
                    false), ANGELEGTAM("Angelegt_Am", false), ANGELEGTVON("Angelegt_Von", false), GEAENDERTAM(
                            "Geaendert_Am", false), GEAENDERTVON("Geaendert_Von", false), SOLLNAME("SollKontoName",
                                    false), HABENNAME("HabenKontoName", false);

    public final String  name;
    public final boolean muss;

    private BuchungSpalten(String name, boolean muss) {
        this.name = name;
        this.muss = muss;
    }

    public static BuchungSpalten fromString(String text) {

        if (text != null) {
            text = text.trim();
            for (BuchungSpalten b : BuchungSpalten.values()) {
                if (text.equalsIgnoreCase(b.name)) {
                    return b;
                }
            }
        }
        return null;
    }
}

package de.cwkuehl.jhh6.api.dto.base;

import static de.cwkuehl.jhh6.api.global.Constant.AEND_ZEIT;

import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Vector;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;

public class DtoBase {

    // private static HashMap<String, CSpalte[]> spalten = new HashMap<String,
    // CSpalte[]>();

    private static HashMap<String, Method[]> methoden        = new HashMap<String, Method[]>();

    /** Keine Parameter. */
    private static Class<?>[]                keinParameter   = new Class<?>[0];
    /** Date-Parameter. */
    private static Class<?>[]                dateParameter   = new Class[] { LocalDateTime.class };
    /** String-Parameter. */
    private static Class<?>[]                stringParameter = new Class[] { String.class };
    /** Ist der Datensatz aus der replizierten Datenbank? */
    private boolean                          replikation     = false;

    /**
     * Wert-Vergleich mit DTO-Instanz.
     * @param dto Zu vergleichende DTO-Instanz.
     * @return true, wenn gleiche Klasse und gleiche Werte (geaendertAm und geaendertVon werden nicht berücksichtigt).
     */
    public boolean equals(DtoBase dto) {

        if (dto != null && this.getClass().equals(dto.getClass())) {
            Object wert = null;
            Object wert2 = null;
            Method[] funktionen = holeMethoden();
            Object[] keineParameter = new Object[0];

            try {
                for (int i = 0; i < funktionen.length; i++) {
                    if (!funktionen[i].getName().startsWith("getGeaendert")) {
                        wert = funktionen[i].invoke(this, keineParameter);
                        wert2 = funktionen[i].invoke(dto, keineParameter);
                        if (unequals(wert, wert2)) {
                            return false;
                        }
                    }
                }
            } catch (Exception ex) {
                return false;
            }
            return true;
        }
        return false;
    }

    /**
     * Wert-Vergleich zweier Objekte.
     * @param wert 1. Objekt
     * @param wert2 2. Objekt
     * @return true, wenn beide Objekte nicht die gleichen Werte haben.
     */
    public static boolean unequals(Object wert, Object wert2) {

        if ((wert == null) != (wert2 == null)) {
            return true;
        }
        if (wert != null && !wert.equals(wert2)) {
            if (wert instanceof byte[]) {
                if (Arrays.equals((byte[]) wert, (byte[]) wert2)) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    /**
     * Eintragungen in Spalten Angelegt_Von und Angelegt_Am.
     * @param jetzt Aktuelle Zeit für die Spalte Angelegt_Am.
     * @param benutzer Benutzer-ID für die Spalte Angelegt_Von.
     */
    public final void machAngelegt(final LocalDateTime jetzt, final String benutzer) {

        try {
            getClass().getMethod("setAngelegtVon", stringParameter).invoke(this, benutzer);
            getClass().getMethod("setAngelegtAm", dateParameter).invoke(this, jetzt);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Eintragungen in Spalten Geaendert_Von und Geaendert_Am, wenn der letzte Eintrag in den Spalten Angelegt_Am oder
     * Geaendert_Am schon AEND_ZEIT Ticks her ist.
     * @param jetzt Aktuelle Zeit, die in Spalte Geaendert_Am eingetragen werden soll.
     * @param benutzer Benutzer-ID, die in Spalte Geaendert_Von eingetragen werden soll.
     */
    public final void machGeaendert(final LocalDateTime jetzt, final String benutzer) {

        LocalDateTime datum = null;
        try {
            datum = (LocalDateTime) getClass().getMethod("getGeaendertAm", keinParameter).invoke(this);
            if (datum == null) {
                datum = (LocalDateTime) getClass().getMethod("getAngelegtAm", keinParameter).invoke(this);
            }
            if (datum == null
                    || jetzt == null
                    || datum.toInstant(ZoneOffset.UTC).plusMillis(AEND_ZEIT).compareTo(jetzt.toInstant(ZoneOffset.UTC)) <= 0) {
                getClass().getMethod("setGeaendertVon", stringParameter).invoke(this, benutzer);
                getClass().getMethod("setGeaendertAm", dateParameter).invoke(this, jetzt);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    protected Method[] holeMethoden() {

        Method[] funktionen = methoden.get(this.getClass().getName());

        if (funktionen == null) {
            Vector<Method> v = new Vector<Method>();
            Method[] methods = getClass().getMethods();
            String name = null;
            int pl = 0;

            for (int i = 0; i < methods.length; i++) {
                name = methods[i].getName();
                pl = 0;
                if (name.startsWith("get") && !name.equals("getClass")) {
                    pl = 3;
                }
                if (name.startsWith("is")) {
                    pl = 2;
                }
                if (pl > 0) {
                    v.add(0, methods[i]);
                }
            }
            funktionen = v.toArray(new Method[v.size()]);
            methoden.put(this.getClass().getName(), funktionen);
        }
        return funktionen;
    }

    protected boolean isNull0(Object obj) {
        return obj == null;
    }

    public String formatDatumVon(LocalDateTime datum, String von) {
        // return Meldungen.getMeldung("1011", Global.dateTimeString(datum), von);
        return Meldungen.M1011(datum, von);
    }

    public void setReplikation(boolean replikation) {
        this.replikation = replikation;
    }

    public boolean isReplikation() {
        return replikation;
    }

    /** Kopie der Instanz. */
    public DtoBase getClone() {
        return this;
    }
    
    /** Umgekehrte Kopie der Instanz für DTO-Update. */
    public DtoBase getClone2() {
        return getClone();
    }
    
    /**
     * Rundet einen Double-Wert auf 4 Nachkommastellen.
     * <p>
     * Erstellungsdatum: 01.05.2012
     * @param d zu rundender Double-Wert.
     * @return gerundeter Wert.
     */
    public double rundeBetrag4(final double d) {
        return Global.rundeBetrag6(d);
    }

    /**
     * Klont ein Byte-Array.
     * <p>
     * Erstellungsdatum: 01.05.2012
     * @param d zu kopierende Byte-Array.
     * @return kopiertes Byte-Array.
     */
    public byte[] clone(final byte[] b) {
        return Global.clone(b);
    }
}

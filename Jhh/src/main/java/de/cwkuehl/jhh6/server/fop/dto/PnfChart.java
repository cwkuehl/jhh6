package de.cwkuehl.jhh6.server.fop.dto;

import java.awt.Dimension;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.MaEinstellung;
import de.cwkuehl.jhh6.api.dto.SoKurse;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;

/**
 * Point & Figure-Chart.<br>
 * Eine X-Box (aufwärts) beinhaltet Werte größer oder gleich der Bezeichnung.<br>
 * Eine O-Box (abwärts) beinhaltet Werte kleiner oder gleich der Bezeichnung.
 */
public class PnfChart {

    /** Bezeichnung des Charts. */
    private String           bezeichnung = null;
    /**
     * Methode der Berechnung. 1: Schlusskurse; 2: High-Low-Trendfolge; 3: High-Low-Trendumkehr; 4: Open-High-Low-Close;
     * 5: Typischer Preis.
     */
    private int              methode     = 1;
    /** Liste der Kurse. */
    private List<SoKurse>    kurse       = new ArrayList<>();
    /** Boxgröße. */
    private double           box         = 1;
    /** Box Skalierung. 0: feste Boxgröße; 1: prozentual; 2: dynamisch. */
    private int              skala       = 1;
    /** Anzahl der Umkehr-Boxen. */
    private int              umkehr      = 1;
    /** Handelt es sich um eine Relation? */
    private boolean          relativ     = false;
    /** Anzahl der Tage. */
    private int              dauer       = 0;
    /** Boxbezeichnung. */
    private double           bb          = Double.NaN;
    /** Aktueller Kurs. */
    private double           kurs        = 0;
    /** Minimum. */
    private double           min         = Double.POSITIVE_INFINITY;
    /** Maximum. */
    private double           max         = Double.NEGATIVE_INFINITY;
    /** Maximales Maximum der Säulen. */
    private int              posmax      = 0;
    /** Boxtyp: 0 unbestimmt; 1 aufwärts (X); 2 abwärts (O). */
    private int              boxtyp      = 0;
    /** Liste der Säulen. */
    private List<PnfColumn>  saeulen     = new ArrayList<>();
    /** Aktuelle Säule. */
    private PnfColumn        saeule      = null;
    /** Liste der Werte. */
    private List<Double>     werte       = new ArrayList<>();
    /** Liste der Trendlinien. */
    private List<PnfTrend>   trends      = new ArrayList<>();
    /** Liste der Muster. */
    private List<PnfPattern> pattern     = new ArrayList<>();
    /** Zielkurs. */
    private double           ziel        = 0;
    /** Stopkurs. */
    private double           stop        = 0;
    /** Trend. */
    private double           trend       = 0;
    /** Zur Bestimmung des Monatzeichens. */
    private PnfDatum         datumm      = new PnfDatum();

    /**
     * Standard-Konstruktor.
     */
    public PnfChart() {

        setMethode(methode);
    }

    /**
     * Konstruktor mit Initialisierung.
     * @param methode Betroffene Methode.
     */
    public PnfChart(int methode) {

        setMethode(methode);
    }

    public void addKurse(List<SoKurse> liste) {

        if (liste == null) {
            return;
        }
        for (SoKurse k : liste) {
            addKurse(k);
        }
        if (liste.size() >= 2) {
            kurs = liste.get(liste.size() - 1).getClose(); // letzter Kurs
            double k1 = liste.get(liste.size() - 2).getClose(); // vorletzter Kurs
            LocalDateTime datum = liste.get(liste.size() - 1).getDatum();
            PnfPattern p = PnfPattern.getMusterKurse(this, datum, kurs, k1, ziel, ziel);
            if (p != null) {
                pattern.add(p);
            }
        }

        // nur das letzte Signal behalten
        if (pattern.size() > 0) {
            PnfPattern p = pattern.get(pattern.size() - 1);
            pattern.clear();
            pattern.add(p);
        }

        // Werte in Kästchen umrechnen
        min = saeulen.stream().map(a -> a.getMin()).min(Double::compare).orElse(0d);
        max = saeulen.stream().map(a -> a.getMax()).max(Double::compare).orElse(0d);
        if (min == 0 || max == 0) {
            min = kurse.stream().map(a -> a.getClose()).min(Double::compare).orElse(0d);
            max = kurse.stream().map(a -> a.getClose()).max(Double::compare).orElse(0d);
        }
        int anzahl = 0;
        double m = min;

        werte.clear();
        saeulen.stream().forEach(a -> a.setYpos(0));
        while (Global.compDouble4(m, max) <= 0 && saeulen.size() > 0) {
            werte.add(m);
            anzahl++;
            final double fm = m;
            final int fanzahl = anzahl;
            saeulen.stream().forEach(a -> {
                if (a.getYpos() == 0 && Global.compDouble4(a.getMin(), fm) == 0) {
                    if (a.isO()) {
                        a.setYpos(fanzahl + 1);
                    } else {
                        a.setYpos(fanzahl);
                    }
                }
            });
            pattern.stream().forEach(a -> {
                if (a.getYpos() == 0 && Global.compDouble4(a.getWert(), fm) == 0) {
                    if (a.isO()) {
                        a.setYpos(fanzahl + 1);
                    } else {
                        a.setYpos(fanzahl - 2);
                    }
                }
            });
            m = nextBox(m);
        }
        posmax = anzahl;

        // Stopkurs berechnen
        stop = 0;
        int xstop = -1;
        PnfColumn tief = null;
        if (saeulen.size() > 1 && saeulen.get(saeulen.size() - 1).isO()) {
            xstop = saeulen.size() - 1;
            tief = saeulen.get(xstop);
        } else if (saeulen.size() > 2 && saeulen.get(saeulen.size() - 2).isO()) {
            xstop = saeulen.size() - 2;
            tief = saeulen.get(xstop);
        }
        trends.clear();
        if (tief != null) {
            stop = tief.getMin() * 100.0 / (105.0); // 5% des letzten Tiefs
            int y = 0;
            for (int i = 0; i < posmax; i++) {
                if (Global.compDouble4(stop, werte.get(i)) <= 0) {
                    y = i;
                    break;
                }
            }
            PnfTrend ts = new PnfTrend(xstop, y, 0);
            trends.add(ts);
        }

        trend = 0;
        if (umkehr >= 3) {
            getTrendlinien(0);
            if (kurse.size() >= 2 || trends.size() > 0) {
                // Trendlinien-Durchbrüche bestimmen
                kurs = kurse.get(kurse.size() - 1).getClose(); // letzter Kurs
                double k1 = kurse.get(kurse.size() - 2).getClose(); // vorletzter Kurs
                LocalDateTime datum = kurse.get(kurse.size() - 1).getDatum();
                PnfPattern p = PnfPattern.getMusterTrend(this, datum, kurs, k1);
                if (p != null) {
                    pattern.add(p);
                    for (int i = 0; i < posmax; i++) {
                        if (Global.compDouble4(p.getWert(), werte.get(i)) == 0) {
                            if (p.isO()) {
                                p.setYpos(i + 1 + 1);
                            } else {
                                p.setYpos(i + 1 - 2);
                            }
                            break;
                        }
                    }
                }
            }
            // Trend bestimmen
            if (!trends.isEmpty()) {
                // Trend setzen: letzten Auf- und Abwärts-Trend suchen
                double trend1 = 0;
                double trend2 = 0;
                double akt = getKurs();
                PnfTrend auf = null;
                PnfTrend ab = null;
                List<PnfTrend> l = trends;
                int anzahls = saeulen.size();
                int j = l.size() - 1;
                int yakt = -1;
                while (j >= 0 && (auf == null || ab == null)) {
                    PnfTrend x = l.get(j);
                    if (x.getXpos() + x.getLaenge() >= anzahls) {
                        // bis zum Ende
                        if (x.getBoxtyp() == 1 && auf == null) {
                            // aufwärts
                            auf = x;
                        } else if (x.getBoxtyp() == 2 && ab == null) {
                            // abwärts
                            ab = x;
                        }
                    }
                    j--;
                }
                if (Global.compDouble4(akt, 0) > 0) {
                    double d = getMax() + 1;
                    int yanzahl = getWerte().size();
                    for (int i = 0; i < yanzahl; i++) {
                        if (Global.compDouble4(getWerte().get(i), d) < 0 && Global.compDouble4(getWerte().get(i),
                                akt) > 0) {
                            d = getWerte().get(i);
                            yakt = i;
                        }
                    }
                }
                if (auf != null && yakt >= 0) {
                    int e = auf.getYpos() + auf.getLaenge();
                    if (yakt <= e - 1) {
                        trend1 = -2;
                    } else if (yakt <= e) {
                        trend1 = -1;
                    } else if (yakt <= e + 1) {
                        trend1 = -0.5;
                    }
                    // if (e >= 0 && e < werte.size()) {
                    // double w = werte.get(e);
                    // if (Global.compDouble4(akt, w) > 0)
                    // trend1 = 1;
                    // else
                    // trend1 = -1;
                    // }
                }
                if (ab != null && yakt >= 0) {
                    int e = ab.getYpos() - ab.getLaenge();
                    if (yakt >= e + 1) {
                        trend2 = 2;
                    } else if (yakt >= e) {
                        trend2 = 1;
                    } else if (yakt >= e - 1) {
                        trend2 = 0.5;
                    }
                    // if (e >= 0 && e < werte.size()) {
                    // double w = werte.get(e);
                    // if (Global.compDouble4(akt, w) > 0)
                    // trend2 = 1;
                    // else
                    // trend2 = -1;
                    // }
                }
                if (trend1 != 0 || trend2 != 0) {
                    trend = trend1 + trend2;
                }
            }
        }
    }

    /**
     * Hinzufügen von neuen Kursen zum PnfChart. Dabei werden auch Muster bzw. Signale erkannt.
     * @param k0 Neue Kurse.
     */
    private void addKurse(SoKurse k0) {

        if (k0 == null) {
            return;
        }
        if (methode == 1 && Global.compDouble4(k0.getClose(), 0) <= 0) {
            throw new RuntimeException(Meldungen.WP031());
        } else if ((methode == 2 || methode == 3) && (Global.compDouble4(k0.getHigh(), 0) <= 0 || Global.compDouble4(k0
                .getLow(), 0) <= 0)) {
            throw new RuntimeException(Meldungen.WP032());
        } else if (methode == 4 && (Global.compDouble4(k0.getOpen(), 0) <= 0 || Global.compDouble4(k0.getHigh(), 0) <= 0
                || Global.compDouble4(k0.getLow(), 0) <= 0 || Global.compDouble4(k0.getClose(), 0) <= 0)) {
            throw new RuntimeException(Meldungen.WP033());
        } else if (methode == 5 && (Global.compDouble4(k0.getHigh(), 0) <= 0 || Global.compDouble4(k0.getLow(), 0) <= 0
                || Global.compDouble4(k0.getClose(), 0) <= 0)) {
            throw new RuntimeException(Meldungen.WP034());
        }
        kurse.add(k0);
        double k = k0.getClose();
        if (Double.isNaN(bb)) {
            bb = k;
            // if (box >= 1 && !prozentual) {
            // bb = Math.floor(bb);
            // }
            if (skala != 1) {
                double x = 0;
                double x1 = 0;
                while (x1 < k) {
                    x = x1;
                    x1 = nextBox(x);
                }
                bb = Global.round(x);
            }
        }
        int neu = 0;

        if (boxtyp == 0) {
            neu = Basisalgorithmus(k, k0.getDatum());
        } else if (methode == 4) {
            // OHLC-Methode
            boolean ohlc = false; // ohlc (true) oder olhc (false)
            if (Global.compDouble4(k0.getClose(), k0.getOpen()) > 0) {
                ohlc = false;
            } else if (Global.compDouble4(k0.getClose(), k0.getOpen()) < 0) {
                ohlc = true;
            } else {
                if (Global.compDouble4(k0.getClose(), k0.getLow()) == 0) {
                    ohlc = true;
                } else if (Global.compDouble4(k0.getClose(), k0.getHigh()) == 0) {
                    ohlc = false;
                } else {
                    double m = (k0.getHigh() + k0.getLow()) / 2;
                    if (Global.compDouble4(k0.getClose(), m) < 0) {
                        ohlc = true;
                    } else if (Global.compDouble4(k0.getClose(), m) > 0) {
                        ohlc = false;
                    } else if (boxtyp == 1) {
                        ohlc = true;
                    } else {
                        ohlc = false;
                    }
                }
            }
            int neu2 = 0;
            neu2 = Basisalgorithmus(k0.getOpen(), k0.getDatum());
            if (neu2 != 0) {
                neu = neu2;
            }
            neu2 = Basisalgorithmus(ohlc ? k0.getHigh() : k0.getLow(), k0.getDatum());
            if (neu2 != 0) {
                neu = neu2;
            }
            neu2 = Basisalgorithmus(ohlc ? k0.getLow() : k0.getHigh(), k0.getDatum());
            if (neu2 != 0) {
                neu = neu2;
            }
            neu2 = Basisalgorithmus(k0.getClose(), k0.getDatum());
            if (neu2 != 0) {
                neu = neu2;
            }
        } else {
            // Auf- oder Abwärtstrend
            if (methode == 2) {
                k = boxtyp == 1 ? k0.getHigh() : k0.getLow();
            } else if (methode == 3) {
                k = boxtyp == 1 ? k0.getLow() : k0.getHigh();
            } else if (methode == 5) {
                k = (k0.getHigh() + k0.getLow() + k0.getClose()) / 3;
            }
            neu = Basisalgorithmus(k, k0.getDatum());
            if (methode == 2 && neu != 1) {
                k = boxtyp == 1 ? k0.getLow() : k0.getHigh();
                neu = Basisalgorithmus(k, k0.getDatum());
            } else if (methode == 3 && neu != -1) {
                k = boxtyp == 1 ? k0.getHigh() : k0.getLow();
                neu = Basisalgorithmus(k, k0.getDatum());
            }
        }
        min = Math.min(min, k);
        max = Math.max(max, k);
        if (neu != 0) {
            PnfPattern p = PnfPattern.getMuster(this, k0.getDatum(), 20);
            if (p != null) {
                pattern.add(p);
            }
        }
    }

    /**
     * Basisalgorithmus für die Berechnung eines PnfCharts.
     * @param k Neuer Kurs.
     * @param datum Zugehöriges Datum.
     * @return -1 Trendumkehr mit neuer Säule; 1 Säule wurde verlängert; 0 keine Änderung
     */
    public int Basisalgorithmus(double k, LocalDateTime datum) {

        int neu = 0;
        datumm.setDatum(datum);

        if (boxtyp == 0) {
            // unbestimmter Trend
            double bb0 = bb;
            double bbx = nextBox(bb);

            if (k >= bbx) {
                boxtyp = 1;
                bb = bbx;
                bbx = nextBox(bb);
                addSaeule(new PnfColumn(bb0, bbx, boxtyp, 2, datumm));
                while (k > bbx) {
                    bb = bbx;
                    bbx = nextBox(bb);
                    saeule.setMax(bbx, datumm);
                }
            } else {
                double bbo = prevBox(bb);
                if (k <= bbo) {
                    boxtyp = 2;
                    bb = bbo;
                    bbo = prevBox(bb);
                    addSaeule(new PnfColumn(bbo, bb0, boxtyp, 2, datumm));
                    while (k < bbo) {
                        bb = bbo;
                        bbo = prevBox(bb);
                        saeule.setMin(bbo, datumm);
                    }
                }
            }
        } else if (boxtyp == 1) {
            // Aufwärtstrend
            // neu = addX(k, datum);
            double m = saeule.getMax();
            double bbx = nextBox(bb);
            if (k >= bbx) {
                // Fall I: Prüfe, ob Aufwärtstrend verlängert wird.
                while (k > bbx) { // Fehler: bbx statt bb!
                    saeule.setMax(nextBox(bbx), datumm); // obere Grenze bei X
                    bb = bbx;
                    bbx = nextBox(bb);
                }
            }
            neu = Global.compDouble4(m, saeule.getMax()) != 0 ? 1 : 0;
            double bbu = prevBoxUmkehr(bb, umkehr);
            if (k <= bbu) {
                // Fall II: Prüfe, ob Trendumkehr von X zu O erfolgt.
                boxtyp = 2;
                if (saeule.getSize() > 1) {
                    addSaeule(new PnfColumn(prevBox(bbu), prevBox(bb), boxtyp, umkehr, datumm));
                } else {
                    // One-Step-Back bei 1-Box Umkehr: keine neue Säule.
                    saeule.setBoxtyp(boxtyp);
                    saeule.setMin(bbu, datumm);
                }
                bb = bbu;
                bbu = prevBox(bb);
                if (k <= bbu) {
                    // Prüfe, ob Abwärtstrend verlängert wird.
                    while (k < bbu) {
                        saeule.setMin(prevBox(bbu), datumm);
                        bb = bbu;
                        bbu = prevBox(bb);
                    }
                }
                neu = -1;
            }

        } else if (boxtyp == 2) {
            // Abwärtstrend
            double m = saeule.getMin();
            double bbo = prevBox(bb);
            if (k <= bbo) {
                // Fall I: Prüfe, ob Abwärtstrend verlängert wird.
                while (k < bbo) { // Fehler: bbo statt bb!
                    saeule.setMin(prevBox(bbo), datumm); // untere Grenze bei O
                    bb = bbo;
                    bbo = prevBox(bb);
                }
            }
            neu = Global.compDouble4(m, saeule.getMin()) != 0 ? 1 : 0;
            double bbu = nextBoxUmkehr(bb, umkehr);
            if (k >= bbu) {
                // Fall II: Prüfe, ob Trendumkehr von O zu X erfolgt.
                boxtyp = 1;
                if (saeule.getSize() > 1) {
                    addSaeule(new PnfColumn(nextBox(bb), nextBox(bbu), boxtyp, umkehr, datumm));
                } else {
                    // One-Step-Back bei 1-Box Umkehr: keine neue Säule.
                    saeule.setBoxtyp(boxtyp);
                    saeule.setMax(bbu, datumm);
                }
                bb = bbu;
                bbu = nextBox(bb);
                if (k >= bbu) {
                    // Prüfe, ob Aufwärtstrend verlängert wird.
                    while (k > bbu) {
                        saeule.setMax(nextBox(bbu), datumm);
                        bb = bbu;
                        bbu = nextBox(bb);
                    }
                }
                neu = -1;
            }
        }
        return neu;
    }

    private double nextBoxUmkehr(double b, int umk) {

        double u = b;
        for (int i = 0; i < umk; i++) {
            u = nextBox(u);
        }
        return u;
    }

    private double prevBoxUmkehr(double b, int umk) {

        double u = b;
        for (int i = 0; i < umk; i++) {
            u = prevBox(u);
        }
        return u;
    }

    private double nextBox(double b) {

        if (skala == 0) {
            return b + box;
        }
        if (skala == 1) {
            return b * (100.0 + box) / 100.0;
        }
        if (b < 0.25005 - box / 16) { // <=
            return b + box / 16;
        } else if (b < 1.00005 - box / 8) {
            return b + box / 8;
        } else if (b < 5.00005 - box / 4) {
            return b + box / 4;
        } else if (b < 20.00005 - box / 2) {
            return b + box / 2;
        } else if (b < 100.00005 - box) {
            return b + box;
        } else if (b < 200.00005 - box * 2) {
            return b + box * 2;
        } else if (b < 500.00005 - box * 4) {
            return b + box * 4;
        } else if (b < 1000.00005 - box * 5) {
            return b + box * 5;
        } else if (b < 25000.00005 - box * 50) {
            return b + box * 50;
        }
        return b + box * 500;
    }

    private double prevBox(double b) {

        if (skala == 0) {
            return b - box;
        }
        if (skala == 1) {
            return b * 100.0 / (100.0 + box);
        }
        if (b < 0.25005) { // <=
            return b - box / 16;
        } else if (b < 1.00005) {
            return b - box / 8;
        } else if (b < 5.00005) {
            return b - box / 4;
        } else if (b < 20.00005) {
            return b - box / 2;
        } else if (b < 100.00005) {
            return b - box;
        } else if (b < 200.00005) {
            return b - box * 2;
        } else if (b < 500.00005) {
            return b - box * 4;
        } else if (b < 1000.00005) {
            return b - box * 5;
        } else if (b < 25000.00005) {
            return b - box * 50;
        }
        return b - box * 500;
    }

    private void addSaeule(PnfColumn c) {

        if (c == null) {
            return;
        }
        saeule = c;
        saeulen.add(c);
    }

    private int xgroesse = 10;
    private int ygroesse = 10;

    /**
     * Liefert Größe für das Chart und führt die Berechnung der Kästchen aus.
     * @param xgroesse Größe für ein X oder O in x-Richtung.
     * @param ygroesse Größe für ein X oder O in y-Richtung.
     * @return Größe für das Chart.
     */
    public Dimension getDimension(int xgroesse, int ygroesse) {

        this.xgroesse = xgroesse;
        this.ygroesse = ygroesse;

        int breite = 21 * xgroesse;
        int hoehe = 7 * ygroesse;
        int h = (werte.size() + 1) * ygroesse + hoehe;
        int b = (saeulen.size() + 1) * xgroesse + breite;
        int l = Global.nes(bezeichnung) ? 0 : bezeichnung.length();
        l = Math.max(20, l);
        b = Math.max(b, (15 + l) * xgroesse); // min. Größe für Überschriften mit Beschreibung und Kursen
        return new Dimension(b, h);
    }

    /**
     * Liefert Dimension mit Größe für ein X oder O in x- und y-Richtung.
     * @param h Höhe des Charts in Pixeln.
     * @param b Breite des Charts in Pixeln.
     * @return Dimension mit Größe für ein X oder O in x- und y-Richtung.
     */
    public Dimension computeDimension(int b, int h) {

        int xg = 15;
        int yg = 15;

        Dimension d = getDimension(xg, yg);
        while (b > 0 && h > 0 && xg > 0 && (d.width < b && d.height < h)) {
            xg++;
            yg++;
            d = getDimension(xg, yg);
        }
        while (b > 0 && h > 0 && xg > 0 && (d.width > b || d.height > h)) {
            xg--;
            yg--;
            d = getDimension(xg, yg);
        }
        return new Dimension(xg, yg);
    }

    private void getTrendlinien(int ab) {

        int anzahl = saeulen.size();
        if (anzahl - ab < 2) {
            return;
        }
        PnfColumn c = saeulen.get(ab);
        PnfColumn c2 = saeulen.get(ab + 1);
        PnfTrend t = null; // letzter Trend
        boolean aufwaerts = false;
        int ende = 2;
        int i = 0;
        boolean aufende = false;
        boolean abende = false;
        int max = 99;
        int xminab = ab;
        int xminauf = ab;

        // 1. Trendlinie
        aufwaerts = c.isO() && !c2.isO();
        if (aufwaerts) {
            t = new PnfTrend(ab + 1, c.getYpos() - 1, aufwaerts ? 1 : 2);
            xminauf = t.getXpos() + 1;
        } else {
            t = new PnfTrend(ab + 1, c.getYtop(), aufwaerts ? 1 : 2);
            xminab = t.getXpos() + 1;
        }
        berechneLaenge(t, anzahl);
        if (t.getXpos() + t.getLaenge() >= anzahl) {
            if (aufwaerts) {
                aufende = true;
            } else {
                abende = true;
            }
        }
        trends.add(t);

        while (ende > 0) {
            i = Math.min(anzahl - 1, t.getXpos() + t.getLaenge());
            if (aufwaerts) {
                // Säule mit höchsten X des vorherigen Abwärtstrends finden.
                int c0 = -1;
                int ym = 0;
                boolean gefunden = false;
                for (int j = i; j >= xminab; j--) {
                    c = saeulen.get(j);
                    if (!c.isO() && (c0 < 0 || c.getYtop() > ym)) {
                        c0 = j;
                        ym = c.getYpos();
                    }
                }
                while (!gefunden && c0 < anzahl) {
                    if (c0 >= 0) {
                        c = saeulen.get(c0);
                        PnfTrend t0 = new PnfTrend(c0 + 1, c.getYtop(), aufwaerts ? 2 : 1);
                        berechneLaenge(t0, anzahl);
                        if (i <= t0.getXpos() + t0.getLaenge() && t0.getLaenge() > 1) {
                            gefunden = true;
                            aufwaerts = !aufwaerts;
                            xminab = t0.getXpos() + 1;
                            if (t0.getXpos() + t0.getLaenge() < anzahl || !abende) {
                                t = t0;
                                trends.add(t);
                                if (t0.getXpos() + t0.getLaenge() >= anzahl) {
                                    abende = true;
                                }
                            }
                        } else {
                            c0 += 2; // benachbarte X-Säule
                        }
                    } else {
                        if (saeulen.get(i).isO()) {
                            c0 = i;
                        } else {
                            c0 = i + 1;
                        }
                    }
                }
                if (gefunden) {
                    ende = (aufende ? 0 : 1) + (abende ? 0 : 1);
                } else {
                    aufwaerts = !aufwaerts;
                    ende--;
                }
                max--;
                if (max <= 0) {
                    ende = 0;
                }
            } else {
                // Säule mit tiefsten O des vorherigen Abwärtstrends finden.
                int c0 = -1;
                int ym = 0;
                boolean gefunden = false;
                for (int j = i; j >= xminauf; j--) {
                    c = saeulen.get(j);
                    if (c.isO() && (c0 < 0 || c.getYpos() < ym)) {
                        c0 = j;
                        ym = c.getYpos();
                    }
                }
                while (!gefunden && c0 < anzahl) {
                    if (c0 >= 0) {
                        c = saeulen.get(c0);
                        PnfTrend t0 = new PnfTrend(c0 + 1, c.getYpos() - 1, aufwaerts ? 2 : 1);
                        berechneLaenge(t0, anzahl);
                        if (i <= t0.getXpos() + t0.getLaenge() && t0.getLaenge() > 1) {
                            gefunden = true;
                            aufwaerts = !aufwaerts;
                            xminauf = t.getXpos() + 1;
                            if (t0.getXpos() + t0.getLaenge() < anzahl || !aufende) {
                                t = t0;
                                trends.add(t);
                                if (t0.getXpos() + t0.getLaenge() >= anzahl) {
                                    aufende = true;
                                }
                            }
                        } else {
                            c0 += 2; // benachbarte O-Säule
                        }
                    } else {
                        if (saeulen.get(i).isO()) {
                            c0 = i;
                        } else {
                            c0 = i + 1;
                        }
                    }
                }
                if (gefunden) {
                    ende = (aufende ? 0 : 1) + (abende ? 0 : 1);
                } else {
                    aufwaerts = !aufwaerts;
                    ende--;
                }
                max--;
                if (max <= 0) {
                    ende = 0;
                }
            }
        }
    }

    private void berechneLaenge(PnfTrend t, int anzahl) {

        if (t == null) {
            return;
        }
        boolean aufwaerts = t.getBoxtyp() == 1;
        int grenze = t.getYpos();
        int d = aufwaerts ? 1 : -1;
        boolean bruch = false;
        PnfColumn c = null;

        for (int i = t.getXpos(); i < anzahl; i++) {
            c = saeulen.get(i);
            if (aufwaerts && c.isO()) {
                if (c.getYpos() <= grenze) {
                    bruch = true;
                }
            } else if (!aufwaerts && !c.isO()) {
                if (c.getYtop() > grenze) {
                    bruch = true;
                }
            }
            if (bruch) {
                break;
            }
            t.setLaenge(t.getLaenge() + 1);
            grenze += d;
        }
    }

    public static String getBezeichnung(String bezeichnung, double box, int skala, int umkehr, int methode,
            boolean relativ, int dauer, List<SoKurse> kurse, double min, double max) {

        StringBuilder sb = new StringBuilder();
        if (!Global.nes(bezeichnung)) {
            sb.append(bezeichnung);
        }
        if (sb.length() > 0) {
            sb.append(" ");
        }
        sb.append("(").append(Meldungen.WP035());
        if (Global.compDouble(box, 0) > 0) {
            sb.append(" ").append(Global.dblStr(box));
        }
        sb.append(" ");
        if (skala == 0) {
            sb.append(Meldungen.WP036());
        } else if (skala == 1) {
            sb.append(Meldungen.WP037());
        } else {
            sb.append(Meldungen.WP038());
        }
        if (sb.length() > 0) {
            sb.append(", ");
        }
        sb.append(Meldungen.WP039(umkehr));
        if (sb.length() > 0) {
            sb.append(", ");
        }
        switch (methode) {
        case 2:
            sb.append(Meldungen.WP040());
            break;
        case 3:
            sb.append(Meldungen.WP041());
            break;
        case 4:
            sb.append(Meldungen.WP042());
            break;
        case 5:
            sb.append(Meldungen.WP043());
            break;
        default:
            sb.append(Meldungen.WP044());
        }
        if (relativ) {
            sb.append(" ").append(Meldungen.WP045());
        }
        if (dauer > 0) {
            sb.append(", ").append(Meldungen.WP046(dauer));
        }
        sb.append(")");
        return sb.toString();
    }

    public String getBezeichnung() {
        return getBezeichnung(bezeichnung, box, skala, umkehr, methode, relativ, dauer, kurse, min, max);
    }

    public String getBezeichnung2() {

        StringBuilder sb = new StringBuilder();
        if (Global.listLaenge(kurse) > 0) {
            LocalDateTime von = kurse.get(0).getDatum();
            LocalDateTime bis = kurse.get(kurse.size() - 1).getDatum();
            if (von != null && bis != null) {
                sb.append(Meldungen.WP047(von, bis));
            }
            sb.append(" O:").append(Global.dblStrFormat(Global.round(kurse.get(0).getClose()), false));
            sb.append(" H:").append(Global.dblStrFormat(Global.round(max), false));
            sb.append(" L:").append(Global.dblStrFormat(Global.round(min), false));
            sb.append(" C:").append(Global.dblStrFormat(Global.round(kurse.get(kurse.size() - 1).getClose()), false));
        }
        return sb.toString();
    }

    public void setBezeichnung(String bezeichnung) {
        this.bezeichnung = bezeichnung;
    }

    // public int getMethode() {
    // return methode;
    // }

    public void setMethode(int methode) {

        if (1 <= methode && methode <= 5) {
            this.methode = methode;
        }
    }

    public double getBox() {
        return box;
    }

    public void setBox(double box) {
        if (Global.compDouble4(box, 0) > 0) {
            this.box = box;
        }
    }

    // public boolean isProzentual() {
    // return prozentual;
    // }

    public void setSkala(int skala) {
        this.skala = skala;
    }

    // public int getUmkehr() {
    // return umkehr;
    // }

    public void setUmkehr(int umkehr) {
        if (umkehr >= 1) {
            this.umkehr = umkehr;
        }
    }

    /**
     * Liefert den aktuellen Schlusskurs.
     * @return Aktueller Schlusskurs.
     */
    public double getKurs() {
        return kurs;
    }

    public List<PnfColumn> getSaeulen() {
        return saeulen;
    }

    // public double getMin() {
    // return min;
    // }

    public double getMax() {
        return max;
    }

    public int getXgroesse() {
        return xgroesse;
    }

    public int getYgroesse() {
        return ygroesse;
    }

    public int getPosmax() {
        return posmax;
    }

    public List<Double> getWerte() {
        return werte;
    }

    public static List<MaEinstellung> getSkalaListe() {

        List<MaEinstellung> liste = new ArrayList<MaEinstellung>();
        MaEinstellung e = new MaEinstellung();
        e.setSchluessel("0");
        e.setWert(Meldungen.WP036());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("1");
        e.setWert(Meldungen.WP037());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("2");
        e.setWert(Meldungen.WP038());
        liste.add(e);
        return liste;
    }

    public static List<MaEinstellung> getMethodeListe() {

        List<MaEinstellung> liste = new ArrayList<MaEinstellung>();
        MaEinstellung e = new MaEinstellung();
        e.setSchluessel("1");
        e.setWert(Meldungen.WP044());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("2");
        e.setWert(Meldungen.WP040());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("3");
        e.setWert(Meldungen.WP041());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("4");
        e.setWert(Meldungen.WP042());
        liste.add(e);
        e = new MaEinstellung();
        e.setSchluessel("5");
        e.setWert(Meldungen.WP043());
        liste.add(e);
        return liste;
    }

    public List<PnfTrend> getTrends() {
        return trends;
    }

    public List<PnfPattern> getPattern() {
        return pattern;
    }

    public boolean isRelativ() {
        return relativ;
    }

    public void setRelativ(boolean relativ) {

        this.relativ = relativ;
        if (!relativ && !Global.nes(bezeichnung)) {
            // Relation aus Bezeichnung entfernen.
            String[] array = bezeichnung.split(" \\(");
            bezeichnung = array[0];
        }
    }

    public double getZiel() {
        return ziel;
    }

    public void setZiel(double ziel) {
        this.ziel = ziel;
    }

    public double getStop() {
        return stop;
    }

    public void setStop(double stop) {
        this.stop = stop;
    }

    public double getTrend() {
        return trend;
    }
}

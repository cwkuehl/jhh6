package de.cwkuehl.jhh6.server.fop.dto;

import java.time.LocalDateTime;
import java.util.List;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Point & Figure-Muster.</br> siehe
 * http://www.tradesignalonline.com/lexicon/view.aspx?id=Point+%26+Figure+Patternrecognition
 */
public class PnfPattern {

    /** End-Position der Säule. */
    private int           xpos     = 0;
    /** End-Position der Säule. */
    private int           ypos     = 0;
    /** Wert der Säule für Berechnung von ypos. */
    private double        wert     = 0;
    /** Boxtyp: false aufwärts (X); true abwärts (O). */
    private boolean       iso      = false;
    /** Signal mit Stärke: 0 unbestimmt; >0 kaufen (X); <0 verkaufen (O). */
    private int           signal   = 0;
    /** Muster: 0 unbestimmt; 1 double top; 2 double bottom. */
    private int           muster   = 0;
    /** Anzahl der Säulen im Muster. */
    private int           anzahl   = 0;
    /** Datum, an dem das Muster vollendet wird. */
    private LocalDateTime datum    = null;
    /** Anzahl der Boxen für Long Tail. */
    private static int    longtail = 20;

    private PnfPattern(int xpos, double wert, boolean iso, int muster, int anzahl, int signal, LocalDateTime datum) {

        this.xpos = xpos;
        this.wert = wert;
        this.iso = iso;
        this.muster = muster;
        this.anzahl = anzahl;
        this.signal = signal;
        this.datum = datum;
    }

    /**
     * Liefert englische Bezeichnung eines Musters bzw. Signals.
     * @param muster Musternummer.
     * @return Englische Muster-Bezeichnung.
     */
    public static String getBezeichnung(int muster) {

        if (muster <= 0) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        if (muster == 1) {
            sb.append("double top"); // Simple Bull
        } else if (muster == 2) {
            sb.append("double bottom"); // Simple Bear
        } else if (muster == 3) {
            sb.append("double bottom bullish");
        } else if (muster == 4) {
            sb.append("double top bearish");
        } else if (muster == 5) {
            sb.append("triple top");
        } else if (muster == 6) {
            sb.append("triple bottom");
        } else if (muster == 7) {
            sb.append("triple bottom bullish");
        } else if (muster == 8) {
            sb.append("triple top bearish");
        } else if (muster == 9) {
            sb.append("pullback bullish");
        } else if (muster == 10) {
            sb.append("pullback bearish");
        } else if (muster == 11) {
            sb.append("baisse reversal");
        } else if (muster == 12) {
            sb.append("hausse reversal");
        } else if (muster == 13) {
            sb.append("hausse breakout");
        } else if (muster == 14) {
            sb.append("baisse breakout");
        } else if (muster == 15) {
            sb.append("triangle bullish");
        } else if (muster == 16) {
            sb.append("triangle bearish");
        } else if (muster == 17) {
            sb.append("low pole bullish");
        } else if (muster == 18) {
            sb.append("high pole bearish");
        } else if (muster == 19) {
            sb.append("long tail bullish");
        } else if (muster == 20) {
            sb.append("long tail bearish");
        } else if (muster == 21) {
            sb.append("catapult bullish");
        } else if (muster == 22) {
            sb.append("catapult bearish");
        } else if (muster == 23) {
            sb.append("spread triple top");
        } else if (muster == 24) {
            sb.append("spread triple bottom");
        } else if (muster == 25) {
            sb.append("asc. triple top");
        } else if (muster == 26) {
            sb.append("desc. triple bottom");
        } else if (muster == 27) {
            sb.append("quadruple top");
        } else if (muster == 28) {
            sb.append("quadruple bottom");
        } else if (muster == 29) {
            sb.append("breakthru top"); // Trendlinie nach oben durchbrochen
        } else if (muster == 30) {
            sb.append("breakthru bottom"); // Trendlinie nach unten durchbrochen
        } else if (muster == 31) {
            sb.append("breakthru goal"); // Zielkurs durchbrochen
        } else if (muster == 32) {
            sb.append("breakthru stop"); // Stopkurs durchbrochen
        } else if (muster == 33) {
            sb.append("shakeout bullish");
        } else if (muster == 34) {
            sb.append("shakeout bearish");
        } else if (muster == 35) {
            sb.append("broadening top");
        } else if (muster == 36) {
            sb.append("broadening bottom");
        } else if (muster == 37) {
            sb.append("tr. catapult bullish");
        } else if (muster == 38) {
            sb.append("tr. catapult bearish");
        } else if (muster == 39) {
            sb.append("double top breakout");
        } else if (muster == 40) {
            sb.append("double bottom breakdown");
        } else if (muster == 41) {
            sb.append("triple top breakout");
        } else if (muster == 42) {
            sb.append("triple bottom breakdown");
        } else {
            sb.append("Muster ").append(muster);
        }
        return sb.toString();
    }

    public String getBezeichnung() {

        StringBuilder sb = new StringBuilder();
        sb.append(getBezeichnung(muster));
        if (datum != null) {
            if (sb.length() > 0) {
                sb.append(" ");
            }
            sb.append(Global.dateTimeStringForm(datum));
        }
        sb.append(" (").append(signal).append(")");
        return sb.toString();
    }

    /**
     * Liefert ein Muster bzw. Signal für Ziel- bzw. Stopkurs, falls es sich ergibt.
     * @param c Betroffenes Chart.
     * @param datum Betroffenes Datum.
     * @param kurs Aktueller Kurs.
     * @param kurs2 Vorhergehender Kurs.
     * @param ziel Zielkurs.
     * @param stop Stopkurs.
     * @return Neues Muster oder null.
     */
    public static PnfPattern getMusterKurse(PnfChart c, LocalDateTime datum, double kurs, double kurs2, double ziel,
            double stop) {

        if (c == null || c.getSaeulen().size() <= 0) {
            return null;
        }
        List<PnfPattern> p0 = c.getPattern();
        PnfPattern p = null;
        int ce = c.getSaeulen().size() - 1;
        PnfColumn c0 = c.getSaeulen().get(ce);
        int anzahl = 1; // Anzahl der Säulen.
        int bs = 5; // Alle Bewertungen für 5er Box.
        if (Global.compDouble4(ziel, 0) > 0 && Global.compDouble4(kurs2, ziel) < 0
                && Global.compDouble4(kurs, ziel) >= 0) {
            p = get(p0, ce, c0.getMax(), c0.isO(), 31, anzahl, 5 + bs, datum); // Zielkurs durchbrochen
        }
        if (Global.compDouble4(stop, 0) > 0 && Global.compDouble4(kurs2, stop) > 0
                && Global.compDouble4(kurs, stop) <= 0) {
            p = get(p0, ce, c0.getMin(), c0.isO(), 32, anzahl, -5 - bs, datum); // Stopkurs durchbrochen
        }
        return p;
    }

    /**
     * Liefert ein Muster bzw. Signal für das Durchbrechen der letzten beiden Trendlinien, falls es sich ergibt.
     * @param c Betroffenes Chart.
     * @param datum Betroffenes Datum.
     * @param kurs Aktueller Kurs.
     * @param kurs2 Vorhergehender Kurs.
     * @return Neues Muster oder null.
     */
    public static PnfPattern getMusterTrend(PnfChart c, LocalDateTime datum, double kurs, double kurs2) {

        if (c == null || c.getSaeulen().size() <= 0 || c.getTrends().size() <= 0) {
            return null;
        }
        List<PnfPattern> p0 = c.getPattern();
        PnfPattern p = null;
        int ce = c.getSaeulen().size() - 1;
        PnfColumn c0 = c.getSaeulen().get(ce);
        int anzahl = 1; // Anzahl der Säulen.
        int bs = 5; // Alle Bewertungen für 5er Box.
        PnfTrend t0 = null;
        for (int i = c.getTrends().size() - 1; i >= 0; i--) {
            t0 = c.getTrends().get(i);
            if (t0.getXpos() + t0.getLaenge() <= ce) {
                continue;
            }
            if (t0.getBoxtyp() == 1 && c0.isO()) {
                // Aufwärtstrend und Abwärtssäule
                double d = c.getWerte().get(t0.getYpos() + ce - t0.getXpos());
                if (Global.compDouble4(kurs, d) < 0 && Global.compDouble4(kurs2, d) > 0) {
                    p = get(p0, ce, d, c0.isO(), 30, anzahl, 1 - bs, datum); // breakthru bottom
                }
            } else if (t0.getBoxtyp() != 1 && !c0.isO()) {
                // Abwärtstrend und Aufwärtssäule
                double d = c.getWerte().get(t0.getYpos() - ce + t0.getXpos() - 1);
                if (Global.compDouble4(kurs, d) > 0 && Global.compDouble4(kurs2, d) < 0) {
                    p = get(p0, ce, d, c0.isO(), 29, anzahl, -1 + bs, datum); // breakthru top
                }
            }
            if (p != null) {
                return p;
            }
        }
        return null;
    }

    /**
     * Liefert ein Muster bzw. Signal, falls es sich neu ergibt.
     * @param c Betroffenes Chart.
     * @param datum Betroffenes Datum.
     * @param longtail Höhle des Longtail-Musters.
     * @return Neues Muster oder null.
     */
    public static PnfPattern getMuster(PnfChart c, LocalDateTime datum, int longtail) {

        if (c == null || c.getSaeulen().size() < 2) {
            return null;
        }
        if (longtail <= 0) {
            longtail = PnfPattern.longtail;
        }
        List<PnfPattern> p0 = c.getPattern();
        PnfPattern p = null;
        int ce = c.getSaeulen().size() - 1;
        PnfColumn c0 = null;
        PnfColumn c1 = null;
        PnfColumn c2 = null;
        PnfColumn c3 = null;
        PnfColumn c4 = null;
        PnfColumn c5 = null;
        PnfColumn c6 = null;
        int anzahl = 0;
        // int bs = c.getUmkehr();
        // int bs = (int) Global.rundeBetrag(c.getBox());
        int bs = 5; // Alle Bewertungen für 5er Box.

        if (ce >= 0) {
            c0 = c.getSaeulen().get(ce);
        }
        if (ce >= 1) {
            c1 = c.getSaeulen().get(ce - 1);
        }
        if (ce >= 2) {
            c2 = c.getSaeulen().get(ce - 2);
        }
        if (ce >= 3) {
            c3 = c.getSaeulen().get(ce - 3);
        }
        if (ce >= 4) {
            c4 = c.getSaeulen().get(ce - 4);
        }
        if (ce >= 5) {
            c5 = c.getSaeulen().get(ce - 5);
        }
        if (ce >= 6) {
            c6 = c.getSaeulen().get(ce - 6);
        }
        anzahl = 7;
        if (p == null && ce >= anzahl - 1) {
            if (p == null && !c6.isO() && c5.isO() && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c6.getMax(), c4.getMax()) > 0
                    && Global.compDouble4(c5.getMin(), c3.getMin()) < 0
                    && Global.compDouble4(c4.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c3.getMin(), c1.getMin()) < 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 15, anzahl, 1 + bs, datum); // triangle bullish
            } // 14.02.16
            if (p == null && c6.isO() && !c5.isO() && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c6.getMin(), c4.getMin()) < 0
                    && Global.compDouble4(c5.getMax(), c3.getMax()) > 0
                    && Global.compDouble4(c4.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c3.getMax(), c1.getMax()) > 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 16, anzahl, -1 - bs, datum); // triangle bearish
            } // 14.02.16
            if (p == null && !c6.isO() && !c4.isO() && !c2.isO() && !c0.isO()
                    && Global.compDouble4(c6.getMax(), c4.getMax()) == 0
                    && Global.compDouble4(c4.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c4.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 23, anzahl, bs, datum); // spread triple top
            }
            if (p == null && c6.isO() && c4.isO() && c2.isO() && c0.isO()
                    && Global.compDouble4(c6.getMin(), c4.getMin()) == 0
                    && Global.compDouble4(c4.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c4.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 24, anzahl, -bs, datum); // spread triple bottom
            }
            if (p == null && !c6.isO() && !c4.isO() && !c2.isO() && !c0.isO()
                    && Global.compDouble4(c6.getMax(), c2.getMax()) == 0
                    && Global.compDouble4(c4.getMax(), c6.getMax()) < 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 23, anzahl, bs, datum); // spread triple top
            }
            if (p == null && c6.isO() && c4.isO() && c2.isO() && c0.isO()
                    && Global.compDouble4(c6.getMin(), c2.getMin()) == 0
                    && Global.compDouble4(c4.getMin(), c6.getMin()) > 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 24, anzahl, -bs, datum); // spread triple bottom
            }
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c1.getMin(), c3.getMin()) < 0
                    && Global.compDouble4(c2.getMax(), c4.getMax()) < 0
                    && Global.compDouble4(c3.getMin(), c5.getMin()) < 0
                    && Global.compDouble4(c4.getMax(), c6.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 11, anzahl, bs, datum); // * baisse reversal
            }
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c1.getMax(), c3.getMax()) > 0
                    && Global.compDouble4(c2.getMin(), c4.getMin()) > 0
                    && Global.compDouble4(c3.getMax(), c5.getMax()) > 0
                    && Global.compDouble4(c4.getMin(), c6.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 12, anzahl, -bs, datum); // * hausse reversal
            }
            // if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
            // && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
            // && Global.compDouble4(c1.getMin(), c3.getMin()) > 0
            // && Global.compDouble4(c2.getMax(), c4.getMax()) > 0
            // && Global.compDouble4(c3.getMin(), c5.getMin()) > 0
            // && Global.compDouble4(c4.getMax(), c6.getMax()) > 0) {
            // p = get(p0, ce, c0.getMax(), c0.isO(), 13, anzahl, 2, datum); // hausse breakout
            // }
            // if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
            // && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
            // && Global.compDouble4(c1.getMax(), c3.getMax()) < 0
            // && Global.compDouble4(c2.getMin(), c4.getMin()) < 0
            // && Global.compDouble4(c3.getMax(), c5.getMax()) < 0
            // && Global.compDouble4(c4.getMin(), c6.getMin()) < 0) {
            // p = get(p0, ce, c0.getMin(), c0.isO(), 14, anzahl, -2, datum); // baisse breakout
            // }
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c1.getMin(), c3.getMin()) > 0
                    && Global.compDouble4(c2.getMax(), c4.getMax()) > 0
                    && Global.compDouble4(c3.getMin(), c5.getMin()) >= 0
                    && Global.compDouble4(c4.getMax(), c6.getMax()) == 0) { // >=
                p = get(p0, ce, c0.getMax(), c0.isO(), 21, anzahl, 3 + bs, datum); // catapult bullish
            }
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c1.getMax(), c3.getMax()) < 0
                    && Global.compDouble4(c2.getMin(), c4.getMin()) < 0
                    && Global.compDouble4(c3.getMax(), c5.getMax()) <= 0
                    && Global.compDouble4(c4.getMin(), c6.getMin()) == 0) { // <=
                p = get(p0, ce, c0.getMin(), c0.isO(), 22, anzahl, -3 - bs, datum); // catapult bearish
            }
            if (p == null && !c6.isO() && c5.isO() && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c2.getMax(), c4.getMax()) == 0
                    && Global.compDouble4(c4.getMax(), c6.getMax()) == 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 27, anzahl, 4 + bs, datum); // quadruple top
            }
            if (p == null && c6.isO() && !c5.isO() && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c2.getMin(), c4.getMin()) == 0
                    && Global.compDouble4(c4.getMin(), c6.getMin()) == 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 28, anzahl, -4 - bs, datum); // quadruple bottom
            }
        }
        anzahl = 6;
        if (p == null && ce >= anzahl - 1) {
            if (p == null && !c5.isO() && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c5.getMax(), c3.getMax()) == 0
                    && Global.compDouble4(c4.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c3.getMax(), c1.getMax()) < 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) < 0 && c0.getSize() >= 3) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 37, anzahl, 5 + bs, datum); // trading catapult bullish
            } // 14.02.16
            if (p == null && c5.isO() && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c5.getMin(), c3.getMin()) == 0
                    && Global.compDouble4(c4.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c3.getMin(), c1.getMin()) > 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) > 0 && c0.getSize() >= 3) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 38, anzahl, -5 - bs, datum); // trading catapult bearish
            } // 14.02.16
            if (p == null && c5.isO() && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c5.getMin(), c3.getMin()) == 0
                    && Global.compDouble4(c4.getMax(), c2.getMax()) == 0
                    && Global.compDouble4(c3.getMin(), c1.getMin()) == 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 7, anzahl, 2 + bs, datum); // triple bottom bullish
            }
            if (p == null && !c5.isO() && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c5.getMax(), c3.getMax()) == 0
                    && Global.compDouble4(c4.getMin(), c2.getMin()) == 0
                    && Global.compDouble4(c3.getMax(), c1.getMax()) == 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 8, anzahl, -2 - bs, datum); // triple top bearish
            }
            // double boxsize = (c3.getMax() - c3.getMin()) / c3.getSize();
            // if (p == null && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
            // && Global.compDouble4(c0.getMax(), c2.getMin()) <= 0
            // && Global.compDouble4(c1.getMin(), c3.getMin() - 3 * boxsize) <= 0
            // && Global.compDouble4(c3.getMin(), c5.getMin()) < 0
            // && Global.compDouble4(c2.getMax(), c4.getMax()) < 0) {
            // p = get(p0, ce, c0.getMax(), c0.isO(), 17, anzahl, 2, datum); // low pole bullish
            // }
            // if (p == null && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
            // && Global.compDouble4(c0.getMin(), c2.getMax()) >= 0
            // && Global.compDouble4(c1.getMax(), c3.getMax() + 3 * boxsize) >= 0
            // && Global.compDouble4(c3.getMax(), c5.getMax()) > 0
            // && Global.compDouble4(c2.getMin(), c4.getMin()) > 0) {
            // p = get(p0, ce, c0.getMin(), c0.isO(), 18, anzahl, -2, datum); // high pole bearish
            // }
        }
        anzahl = 5;
        if (p == null && ce >= anzahl - 1) {
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c4.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c4.getMax(), c2.getMax()) == 0
                    && Global.compDouble4(c3.getMin(), c1.getMin()) > 0 && c0.getSize() >= 3) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 33, anzahl, 1 + bs, datum); // shakeout bullish
            } // 14.02.16
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c4.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c4.getMin(), c2.getMin()) == 0
                    && Global.compDouble4(c3.getMax(), c1.getMax()) < 0 && c0.getSize() >= 3) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 34, anzahl, -1 - bs, datum); // shakeout bearish
            } // 14.02.16
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c4.getMax(), c2.getMax()) < 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0
                    && Global.compDouble4(c3.getMin(), c1.getMin()) > 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 35, anzahl, 1 + bs, datum); // broadening top
            } // 14.02.16
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c4.getMin(), c2.getMin()) > 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0
                    && Global.compDouble4(c3.getMax(), c1.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 36, anzahl, -1 - bs, datum); // broadening bottom
            } // 14.02.16
            if (p == null && !c2.isO() && c1.isO() && !c0.isO() && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
                    && Global.compDouble4(c1.getMin(), c3.getMin()) == 0
                    && Global.compDouble4(c2.getMax(), c4.getMax()) <= 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 3, anzahl, 1 + bs, datum); // double bottom bullish
            }
            if (p == null && c2.isO() && !c1.isO() && c0.isO() && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
                    && Global.compDouble4(c1.getMax(), c3.getMax()) == 0
                    && Global.compDouble4(c2.getMin(), c4.getMin()) >= 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 4, anzahl, -1 - bs, datum); // double top bearish
            }
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c4.getMax(), c2.getMax()) == 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) == 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 5, anzahl, 1 + bs, datum); // triple top
            }
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c4.getMin(), c2.getMin()) == 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) == 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 6, anzahl, -1 - bs, datum); // triple bottom
            }
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c4.getMax(), c2.getMax()) == 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 41, anzahl, 2 + bs, datum); // triple top breakout
            } // 06.03.16
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c4.getMin(), c2.getMin()) == 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 42, anzahl, -2 - bs, datum); // triple bottom breakdown
            } // 06.03.16
            if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
                    && Global.compDouble4(c4.getMax(), c2.getMax()) < 0
                    && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 25, anzahl, 3 + bs, datum); // ascending triple top
            }
            if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
                    && Global.compDouble4(c4.getMin(), c2.getMin()) > 0
                    && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 26, anzahl, -3 - bs, datum); // descending triple bottom
            }
            if (p == null && !c0.isO() && c1.isO() && !c2.isO() && Global.compDouble4(c0.getMax(), c2.getMax()) >= 0
                    && Global.compDouble4(c1.getMin(), c4.getMax()) > 0
                    && Global.compDouble4(c2.getMax(), c4.getMax()) > 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 9, anzahl, bs, datum); // * pullback bullish
            }
            if (p == null && c0.isO() && !c1.isO() && c2.isO() && Global.compDouble4(c0.getMin(), c2.getMin()) <= 0
                    && Global.compDouble4(c1.getMax(), c4.getMin()) < 0
                    && Global.compDouble4(c2.getMin(), c4.getMin()) < 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 10, anzahl, -bs, datum); // * pullback bearish
            }
            // if (p == null && !c4.isO() && c3.isO() && !c2.isO() && c1.isO() && !c0.isO()
            // && Global.compDouble4(c0.getMax(), c2.getMax()) > 0
            // && Global.compDouble4(c1.getMin(), c3.getMin()) > 0
            // && Global.compDouble4(c2.getMax(), c4.getMax()) < 0
            // && Global.compDouble4(c3.getMin(), c4.getMin()) > 0) {
            // p = get(p0, ce, c0.getMax(), c0.isO(), 15, anzahl, 1 + bs, datum); // triangle bullish
            // }
            // if (p == null && c4.isO() && !c3.isO() && c2.isO() && !c1.isO() && c0.isO()
            // && Global.compDouble4(c0.getMin(), c2.getMin()) < 0
            // && Global.compDouble4(c1.getMax(), c3.getMax()) < 0
            // && Global.compDouble4(c2.getMin(), c4.getMin()) > 0
            // && Global.compDouble4(c3.getMax(), c4.getMax()) < 0) {
            // p = get(p0, ce, c0.getMin(), c0.isO(), 16, anzahl, -1 - bs, datum); // triangle bearish
            // } // siehe anzahl = 7
        }
        anzahl = 3;
        if (p == null && ce >= anzahl - 1) {
            if (p == null && !c2.isO() && c1.isO() && !c0.isO() && Global.compDouble4(c2.getMax(), c0.getMax()) == 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 1, anzahl, bs, datum); // double top
            }
            if (p == null && c2.isO() && !c1.isO() && c0.isO() && Global.compDouble4(c2.getMin(), c0.getMin()) == 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 2, anzahl, -bs, datum); // double bottom
            }
            if (p == null && !c2.isO() && c1.isO() && !c0.isO() && Global.compDouble4(c2.getMax(), c0.getMax()) < 0) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 39, anzahl, 1 + bs, datum); // double top breakout
            } // 06.03.16
            if (p == null && c2.isO() && !c1.isO() && c0.isO() && Global.compDouble4(c2.getMin(), c0.getMin()) > 0) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 40, anzahl, -1 - bs, datum); // double bottom breakdown
            } // 06.03.16
        }
        // anzahl = 2;
        if (p == null && ce >= anzahl - 1) {
            if (p == null && !c0.isO() && c1.getSize() >= longtail) {
                p = get(p0, ce, c0.getMax(), c0.isO(), 19, anzahl, 3 + bs, datum); // long tail bullish
            }
            if (p == null && c0.isO() && c1.getSize() >= longtail) {
                p = get(p0, ce, c0.getMin(), c0.isO(), 20, anzahl, -3 - bs, datum); // long tail bearish
            }
        }
        return p;
    }

    /**
     * Erzeugen eines nicht doppelten Musters.
     * @param p0 letztes Muster kann null sein.
     * @param xpos Säulennummer.
     * @param wert Aktuelle Höhe der Säule, Max. bei X, Min. bei O.
     * @param iso Ist die Säule absteigend?
     * @param muster Musternummer.
     * @param anzahl Anzahl der vom Muster betroffenen Säulen.
     * @param signal Stärke des Signals.
     * @param datum Betroffenes Datum.
     * @return Neues Muster kann null sein.
     */
    private static PnfPattern get(List<PnfPattern> p0, int xpos, double wert, boolean iso, int muster, int anzahl,
            int signal, LocalDateTime datum) {

        if (p0 == null) {
            return null;
        }
        PnfPattern p = null;
        boolean doppelt = false;
        for (int i = p0.size() - 1; i >= 0; i--) {
            p = p0.get(i);
            if (p.xpos == xpos
                    && ((p.signal > 0 && signal > 0 && p.signal >= signal) || (p.signal < 0 && signal < 0 && p.signal <= signal))) {
                // Wenn eine Säule ein Muster enthält wird nur ein stärkeres Signal akzeptiert.
                doppelt = true;
                break;
            }
        }
        if (!doppelt || (muster >= 29 && muster <= 32)) {
            // Kurs- und Trendmuster immer
            p = new PnfPattern(xpos, wert, iso, muster, anzahl, signal, datum);
            return p;
        }
        return null;
    }

    public int getXpos() {
        return xpos;
    }

    public int getYpos() {
        return ypos;
    }

    public void setYpos(int ypos) {
        this.ypos = ypos;
    }

    public double getWert() {
        return wert;
    }

    public boolean isO() {
        return iso;
    }

    public int getSignal() {
        return signal;
    }

    public int getAnzahl() {
        return anzahl;
    }

    public LocalDateTime getDatum() {
        return datum;
    }

    public int getMuster() {
        return muster;
    }
}

package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.HhBilanzSb;
import de.cwkuehl.jhh6.api.dto.HhBuchungLang;
import de.cwkuehl.jhh6.api.dto.HhKonto;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.MeldungException;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.FoUtils;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Kassenbericht als FO-Dokument.
 */
public class FoKassenbericht extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoKassenbericht() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Kassenbericht.
     * @param ueberschrift Überschrift.
     */
    public void generate(boolean monatlich, String ueberschrift, LocalDate dVon, LocalDate dBis, String titel,
            double vortrag, double einnahmen, double ausgaben, double saldo, List<HhKonto> kListe,
            List<HhBilanzSb> gvListe, List<HhBuchungLang> bListeE, List<HhBuchungLang> bListeA,
            List<HhBuchungLang> bListe) {

        try {
            String fontname = d.getFontname();
            int size = 10;
            double bestand = 0;

            d.startFo1Master("10mm", "10mm", "15mm", "10mm", "18mm", "5mm", 0, null);
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startBlock(ueberschrift, true, fontname, 12, "bold", null, "text-align", "center");
            d.endTag("fo:static-content");
            d.startTag("fo:static-content", "flow-name", d.getMultiName("footer"));
            d.startBlock(null, false, fontname, size, null, null, "text-align", "center");
            d.startTag("fo:inline", Meldungen.M1058(), false, null, 0, null, null);
            d.startTag("fo:page-number", true);
            d.endTag("fo:inline");
            d.endBlock();
            d.endTag("fo:static-content");
            d.startFlow(fontname, size, 0);
            // Textausgabe
            if (monatlich) {
                d.addNewLine(0);
            }
            d.startTable(true, "35mm", "20mm", "30mm");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock("Saldovortrag", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(FoUtils.getDatum(dVon.minusDays(1)), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock(getBetrag(vortrag, null, false), true);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(Meldungen.HH065(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "number-columns-spanned", "2", "text-align", "right");
            d.startBlock(getBetrag(einnahmen, null, false), true);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(Meldungen.HH066(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "number-columns-spanned", "2", "text-align", "right");
            d.startBlock(getBetrag(ausgaben, null, false), true);
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(Meldungen.HH067(), true, null, 0, "bold", null);
            d.addNewLine(0, 2);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(FoUtils.getDatum(dBis), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock(getBetrag(saldo, null, false), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            for (HhKonto k : kListe) {
                d.startTag("fo:table-row");
                d.startTag("fo:table-cell", "number-columns-spanned", "2");
                d.startBlock(Meldungen.HH072(k.getName()), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "text-align", "right");
                d.startBlock(getBetrag(k.getEbetrag(), null, false), true);
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
                bestand += k.getEbetrag();
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.startBlock(Meldungen.HH068(), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.startBlock(FoUtils.getDatum(dBis), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.addNewLine(0);
            d.startBlock(getBetrag(bestand, null, false), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();
            // Vermerk
            d.addNewLine(0, 2);
            d.startBlock(Meldungen.HH063(titel, Global.intStr(dVon.getYear())), true);
            d.startBlock(Meldungen.HH064(), true);
            // Unterschriften
            d.addNewLine(0, 3);
            d.startTable(true, "35mm", "60mm");
            for (int i = 0; i < 2; i++) {
                d.startTag("fo:table-row");
                d.startTag("fo:table-cell", "border-before-style", "solid", "border-before-width", "0.7pt",
                        "padding-top", "1mm");
                d.startBlock("Datum", true);
                if (i == 0) {
                    d.addNewLine(0, 3);
                }
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-before-style", "solid", "border-before-width", "0.7pt",
                        "padding-top", "1mm");
                d.startBlock(Meldungen.HH069(), true);
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
            }
            d.endTable();
            // Einnahmen + Ausgaben
            einnahmenAusgaben(dBis, gvListe);
            // Aufschlüsselung
            aufschluesselung(dBis, bListeE, bListeA);
            // Abrechnung
            abrechnung(dVon, dBis, kListe, bListe);

            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

    /**
     * Generiert Einnahmen und Ausgaben.
     * @param ueberschrift Überschrift.
     * @throws IOException
     */
    private void einnahmenAusgaben(LocalDate dBis, List<HhBilanzSb> gvListe) throws IOException {

        double summe = 0;
        String einaus = null;

        d.startBlock(null, true, "page-break-after", "always");
        d.startTable(true, "55mm", "30mm");
        for (int i = 0; i < 2; i++) {
            if (i == 0) {
                einaus = Meldungen.HH065();
            } else {
                einaus = Meldungen.HH066();
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(einaus, true, null, 0, "bold", null);
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            summe = 0;
            for (HhBilanzSb b : gvListe) {
                if (b.getName() != null && ((i == 0 && b.getArt() <= 0) || (i == 1 && b.getArt() > 0))) {
                    d.startTag("fo:table-row");
                    d.startTag("fo:table-cell");
                    d.startBlock(b.getName(), true);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "text-align", "right");
                    d.startBlock(getBetrag(b.getEsumme(), null, false), true);
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    summe += b.getEsumme();
                }
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.startBlock(Global.format("{0} {1} {2}", Meldungen.HH068(), einaus, FoUtils.getDatum(dBis)), true, null, 0,
                    "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.addNewLine(0);
            d.startBlock(getBetrag(summe, null, false), true, null, 0, "bold", null);
            if (i == 0) {
                d.addNewLine(0, 2);
            }
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
        }
        d.endTable();
    }

    /**
     * Generiert Aufschlüsselung von Einnahmen und Ausgaben.
     * @throws IOException
     */
    private void aufschluesselung(LocalDate dBis, List<HhBuchungLang> bListeE, List<HhBuchungLang> bListeA)
            throws IOException {

        double summe = 0;
        String einaus = null;
        List<HhBuchungLang> bListe = null;

        d.startBlock(null, true, "page-break-after", "always");
        d.startTable(true, "77mm", "77mm", "30mm");
        for (int i = 0; i < 2; i++) {
            if (i == 0) {
                einaus = Meldungen.HH065();
                bListe = bListeE;
            } else {
                einaus = Meldungen.HH066();
                bListe = bListeA;
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell", "number-columns-spanned", "2");
            d.startBlock(Meldungen.HH070(einaus), true, null, 0, "bold", null);
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            summe = 0;
            for (HhBuchungLang b : bListe) {
                d.startTag("fo:table-row");
                d.startTag("fo:table-cell");
                d.startBlock(b.getSollName(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell");
                d.startBlock(b.getHabenName(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "text-align", "right");
                d.startBlock(getBetrag(b.getEbetrag(), null, false), true);
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
                d.startTag("fo:table-row");
                d.startTag("fo:table-cell", "number-columns-spanned", "2");
                d.startBlock(b.getBelegNr(), true);
                d.addNewLine(0);
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
                summe += b.getEbetrag();
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell", "number-columns-spanned", "2");
            d.addNewLine(0);
            d.startBlock(Meldungen.HH073(einaus, dBis.atStartOfDay()), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.addNewLine(0);
            d.startBlock(getBetrag(summe, null, false), true, null, 0, "bold", null);
            if (i == 0) {
                d.addNewLine(0, 2);
            }
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
        }
        d.endTable();
    }

    /**
     * Generiert Abrechnung von Einnahmen und Ausgaben.
     * @throws IOException
     */
    private void abrechnung(LocalDate dVon, LocalDate dBis, List<HhKonto> kListe, List<HhBuchungLang> bListe)
            throws IOException {

        double summe = 0;
        boolean einnahme = false;
        boolean newLine = false;
        List<HhBuchungLang> bListe2 = null;

        d.startBlock(null, true, "page-break-after", "always");
        d.startTable(true, "14mm", "35mm", "55mm", "18mm", "18mm", "25mm");
        for (HhKonto k : kListe) {
            bListe2 = new ArrayList<HhBuchungLang>();
            for (HhBuchungLang b : bListe) {
                if (Global.compString(k.getUid(), b.getSollKontoUid()) == 0 || Global.compString(k.getUid(), b
                        .getHabenKontoUid()) == 0) {
                    bListe2.add(b);
                }
            }
            if (bListe2.isEmpty()) {
                continue;
            }
            summe = k.getBetrag();
            if (newLine) {
                d.startTag("fo:table-row");
                d.startTag("fo:table-cell");
                d.addNewLine(0, 3);
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
            } else {
                newLine = true;
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell", "number-columns-spanned", "4");
            d.startBlock(Meldungen.HH071(k.getName(), dVon.atStartOfDay()), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock(getBetrag(summe, null, false), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row", null, false, null, 7, "bold", null);
            d.startTag("fo:table-cell");
            d.startBlock("Datum", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Beleg", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Text", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock("Einnahme", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock("Ausgabe", true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Konto", true);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            for (HhBuchungLang b : bListe2) {
                einnahme = Global.compString(k.getUid(), b.getSollKontoUid()) == 0;
                d.startTag("fo:table-row", null, false, null, 7, null, null);
                d.startTag("fo:table-cell");
                d.startBlock(FoUtils.getDatum(b.getSollValuta()), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell");
                d.startBlock(b.getBelegNr(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell");
                d.startBlock(b.getBtext(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "text-align", "right", "padding-right", "1mm");
                if (einnahme) {
                    d.startBlock(getBetrag(b.getEbetrag(), null, false), true);
                    summe += b.getEbetrag();
                } else {
                    d.addNewLine(0);
                }
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "text-align", "right", "padding-right", "1mm");
                if (einnahme) {
                    d.addNewLine(0);
                } else {
                    d.startBlock(getBetrag(b.getEbetrag(), null, false), true);
                    summe -= b.getEbetrag();
                }
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell");
                if (einnahme) {
                    d.startBlock(b.getHabenName(), true);
                } else {
                    d.startBlock(b.getSollName(), true);
                }
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
            }
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell", "number-columns-spanned", "4");
            d.startBlock(Meldungen.HH071(k.getName(), dBis.atStartOfDay()), true, null, 0, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            d.startBlock(getBetrag(summe, null, false), true, null, 0, "bold", null);
            if (Global.compDouble(summe, k.getEbetrag()) != 0) {
                throw new MeldungException(Meldungen.HH074());
            }
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
        }
        d.endTable();
    }

}

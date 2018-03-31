package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.HhBilanzDruck;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Jahresbericht als FO-Dokument.
 */
public class FoJahresbericht extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoJahresbericht() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Jahresbericht.
     * @param ueberschrift Überschrift.
     * @param ebListe Liste der Eröffnungsbilanz.
     * @param gvListe Liste der Gewinn+Verlust-Rechnung.
     * @param sbListe Liste der Schlussbilanz.
     */
    public void generate(String ueberschrift, List<HhBilanzDruck> ebListe, List<HhBilanzDruck> gvListe,
            List<HhBilanzDruck> sbListe) {

        try {
            String fontname = d.getFontname();
            int size = 10;
            boolean newPage = false;
            d.startFo1Master("10mm", "10mm", "10mm", "10mm", "10mm", "5mm", 0, null);
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
            if (Global.listLaenge(ebListe) <= 0 && Global.listLaenge(gvListe) <= 0 && Global.listLaenge(sbListe) <= 0) {
                d.addNewLine(0);
            }
            if (Global.listLaenge(ebListe) > 0) {
                bilanzkonto(Global.g0("HH500.title.EB"), Global.g("HH500.soll.EB"), Global.g("HH500.haben.EB"),
                        ebListe);
                newPage = true;
            }
            if (Global.listLaenge(gvListe) > 0) {
                if (newPage) {
                    d.startBlock(null, true, "page-break-after", "always");
                }
                bilanzkonto(Global.g0("HH500.title.GV"), Global.g("HH500.soll.GV"), Global.g("HH500.haben.GV"),
                        gvListe);
                newPage = true;
            }
            if (Global.listLaenge(sbListe) > 0) {
                if (newPage) {
                    d.startBlock(null, true, "page-break-after", "always");
                }
                bilanzkonto(Global.g0("HH500.title.SB"), Global.g("HH500.soll.EB"), Global.g("HH500.haben.EB"),
                        sbListe);
                newPage = true;
            }
            // String xml = "<svg:svg xmlns:svg=\"http://www.w3.org/2000/svg\" width=\"20pt\" height=\"20pt\">"
            // + "<svg:g style=\"fill:red; stroke:#000000\">"
            // + "<svg:rect x=\"0\" y=\"0\" width=\"15\" height=\"15\"/>"
            // + "<svg:rect x=\"5\" y=\"5\" width=\"15\" height=\"15\"/>" + "</svg:g>" + "</svg:svg>";
            // d.svg(xml);
            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

    private void bilanzkonto(String ueberschrift, String soll, String haben, List<HhBilanzDruck> liste)
            throws IOException {

        double summe1 = 0;
        double summe2 = 0;
        d.startBlock(ueberschrift, true, null, 12, "bold", null);
        d.addNewLine(0);
        d.startTable(true, "10mm", "50mm", "30mm", "10mm", "50mm", "30mm");
        d.startTag("fo:table-row");
        d.startTag("fo:table-cell", "number-columns-spanned", "3", "border-after-style", "solid", "border-after-width",
                "0.7pt");
        d.startBlock(soll, true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "number-columns-spanned", "3", "border-after-style", "solid", "border-after-width",
                "0.7pt", "text-align", "right");
        d.startBlock(haben, true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.endTag("fo:table-row");
        for (HhBilanzDruck b : liste) {
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(Global.fixiereString(b.getNr(), 5, true, " "), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(b.getName(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-end-style", "solid", "border-end-width", "0.7pt", "padding-right",
                    "1mm", "text-align", "right");
            if (Double.isNaN(b.getBetrag())) {
                d.addNewLine(0);
            } else {
                d.startBlock(getBetrag(b.getBetrag(), null, false), true);
                summe1 += b.getBetrag();
            }
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(Global.fixiereString(b.getNr2(), 5, true, " "), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(b.getName2(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "text-align", "right");
            if (Double.isNaN(b.getBetrag2())) {
                d.addNewLine(0);
            } else {
                d.startBlock(getBetrag(b.getBetrag2(), null, false), true);
                summe2 += b.getBetrag2();
            }
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
        }
        d.startTag("fo:table-row");
        d.startTag("fo:table-cell", "number-columns-spanned", "2", "border-before-style", "solid",
                "border-before-width", "0.7pt");
        d.startBlock(Global.g0("HH500.sollSumme"), true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-before-style", "solid", "border-before-width", "0.7pt", "border-end-style",
                "solid", "border-end-width", "0.7pt", "padding-right", "1mm", "text-align", "right");
        d.startBlock(getBetrag(summe1, null, false), true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "number-columns-spanned", "2", "border-before-style", "solid",
                "border-before-width", "0.7pt");
        d.startBlock(Global.g0("HH500.habenSumme"), true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-before-style", "solid", "border-before-width", "0.7pt", "text-align",
                "right");
        d.startBlock(getBetrag(summe2, null, false), true, null, 0, "bold", null);
        d.endTag("fo:table-cell");
        d.endTag("fo:table-row");
        d.endTable();
    }

}

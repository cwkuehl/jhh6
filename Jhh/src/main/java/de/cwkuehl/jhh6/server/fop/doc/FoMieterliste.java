package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.dto.FoHaus;
import de.cwkuehl.jhh6.server.fop.dto.FoMieter;
import de.cwkuehl.jhh6.server.fop.dto.FoWohnung;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.FoUtils;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Mieterliste als FO-Dokument.
 */
public class FoMieterliste extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoMieterliste() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Mieterliste.
     * @param ueberschrift Überschrift.
     * @param von Datum.
     * @param bis Datum.
     * @param haeuser Liste der Daten der Mieter pro Haus.
     */
    public void generate(String ueberschrift, LocalDate von, LocalDate bis, List<FoHaus> haeuser) {

        try {
            String fontname = d.getFontname();
            int size = 11;
            String waehrung = "€";
            int anzahl = 0;
            String pt = ".5mm";
            String[] arr = Meldungen.VM058().split(";");

            d.startFo1Master("8mm", "8mm", "5mm", "5mm", "10mm", "5mm", 0, null);
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startBlock(ueberschrift, true, fontname, size + 4, null, null);
            d.endTag("fo:static-content");

            d.startFlow(fontname, size, 0);
            for (FoHaus h : haeuser) {
                if (anzahl > 0) {
                    d.addNewLine(0, 1);
                }
                d.startBlock(Global.anhaengen(Global.anhaengen(h.getBezeichnung(), ": ", h.getHstrasse()), ", ", h
                        .getHort()), true, null, 0, "bold", null, "padding-top", pt);
                d.startTableBorder(true, "25mm", "62mm", "22mm", "22mm", "14mm", "19mm", "21mm", "16mm");
                d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                d.startTag("fo:table-cell", "border-style", "solid", "padding-top", pt);
                d.startBlock(arr[0], true, null, 0, "bold", null);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[1], true, null, 0, "bold", null, "padding-top", pt);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[2], true, null, 0, "bold", null, "padding-top", pt);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[3], true, null, 0, "bold", null, "padding-top", pt);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[4], true, null, 0, "bold", null, "padding-top", pt, "text-align", "right");
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[5], true, null, 0, "bold", null, "padding-top", pt, "text-align", "right");
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[6], true, null, 0, "bold", null, "padding-top", pt, "text-align", "right");
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(arr[7], true, null, 0, "bold", null, "padding-top", pt, "text-align", "right");
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
                for (FoWohnung w : h.getWohnungen()) {
                    for (FoMieter m : w.getMieter()) {
                        anzahl++;
                        d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(w.getBezeichnung(), true);
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(m.getName(), true);
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(FoUtils.getDatum(m.getVon()), true);
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(FoUtils.getDatum(m.getBis()), true);
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(d.getBetrag(m.getQm(), null, false), true, "text-align", "right");
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(d.getBetrag(m.getGrundmiete(), waehrung, false), true, "text-align", "right");
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(d.getBetrag(m.getKaution(), waehrung, false), true, "text-align", "right");
                        d.endTag("fo:table-cell");
                        d.startTag("fo:table-cell", "border-style", "solid");
                        d.startBlock(d.getBetrag(m.getAntenne(), waehrung, false), true, "text-align", "right");
                        d.endTag("fo:table-cell");
                        d.endTag("fo:table-row");
                    }
                }
                d.endTable();
            }
            if (anzahl <= 0) {
                d.addNewLine(0);
            }
            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }
}

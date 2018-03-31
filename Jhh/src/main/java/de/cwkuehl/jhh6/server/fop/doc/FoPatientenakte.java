package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.HpBehandlungDruck;
import de.cwkuehl.jhh6.api.dto.HpPatient;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Patientenakte als FO-Dokument.
 */
public class FoPatientenakte extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoPatientenakte() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Patientenakte.
     * @param von von-Datum.
     * @param bis bis-Datum.
     * @param patient Patienten-Daten.
     * @param behandlungen Liste der Behandlungen.
     */
    public void generate(LocalDate von, LocalDate bis, HpPatient patient, List<HpBehandlungDruck> behandlungen) {

        try {
            String fontname = d.getFontname();
            int size = 10;
            String patientName = Global.anhaengen(patient.getVorname(), " ", patient.getName1());
            String patientGeburt = "";
            String zeitraum = "";
            StringBuffer sb = new StringBuffer();

            if (patient.getGeburt() != null) {
                patientGeburt = Meldungen.HP020(patient.getGeburt().atStartOfDay());
            }
            if (von != null && bis != null) {
                zeitraum = Meldungen.HP021(von.atStartOfDay(), bis.atStartOfDay());
            }
            d.startFo1Master("8mm", "10mm", "15mm", "5mm", "15mm", "5mm", 1, "0mm");
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startTable(true, "71mm", "67mm", "50mm");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(patientName, true, fontname, 12, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(patientGeburt, true, fontname, 12, "bold", null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(zeitraum, true, "text-align", "right");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();
            d.horizontalLine();
            d.endTag("fo:static-content");

            d.startFlow(fontname, size, 0);

            // d.addNewLine(0, 2);
            d.startTableBorder(true, "22mm", "166mm");
            for (HpBehandlungDruck b : behandlungen) {
                d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm"); // , "keep-together.within-page", "always");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(Meldungen.HP022(b.getDatum().atStartOfDay()), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(b.getLeistung(), true, null, 0, "bold", null);
                sb.setLength(0);
                sb.append(b.getLeistung2());
                String[] zeilen = sb.toString().split("(<[bB][rR]>|\r\n?|\n\r?)");
                for (int k = 0; k < zeilen.length; k++) {
                    if (k == 0) {
                        d.startBlock(zeilen[k], true, "margin-top", "0.8mm");
                    } else {
                        d.startBlock(zeilen[k], true);
                    }
                }
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
            }
            d.endTable();

            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

}

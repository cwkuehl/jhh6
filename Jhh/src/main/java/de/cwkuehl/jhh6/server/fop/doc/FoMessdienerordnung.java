package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.MoGottesdienstLang;
import de.cwkuehl.jhh6.api.dto.base.DtoBase;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Messdienerordnung als FO-Dokument.
 */
public class FoMessdienerordnung extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoMessdienerordnung() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Messdienerordnung.
     * @param von von-Datum.
     * @param bis bis-Datum.
     * @param einteilungen Liste der Einteilungen.
     */
    public void generate(LocalDate von, LocalDate bis, List<MoGottesdienstLang> einteilungen) {

        try {
            String fontname = d.getFontname();
            int size = 10;
            LocalDateTime termin = null;
            String dienst = "###";
            StringBuffer sb = new StringBuffer();
            boolean terminNeu = false;
            boolean dienstNeu = false;
            String dienstFett = null;

            d.startFo1Master("8mm", "10mm", "15mm", "5mm", "15mm", "5mm", 1, "0mm");
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startBlock(Meldungen.MO037(Global.getPeriodeString(von, bis, false)), true, "text-align", "center");
            d.horizontalLine();
            d.endTag("fo:static-content");

            d.startFlow(fontname, size, 0);

            sb.setLength(0);
            for (MoGottesdienstLang e : einteilungen) {
                dienstNeu = DtoBase.unequals(dienst, e.getEinteilungDienst());
                terminNeu = DtoBase.unequals(termin, e.getTermin());
                if (terminNeu || dienstNeu) {
                    // Wechsel Termin oder Dienst
                    if (sb.length() > 0) {
                        d.startBlock(null, false);
                        if (dienstFett != null) {
                            d.inline(dienstFett, "font-weight", "bold");
                        }
                        d.inline(sb.toString());
                        d.endBlock();
                        sb.setLength(0);
                        dienstFett = null;
                    }
                    dienst = e.getEinteilungDienst();
                }
                if (terminNeu) {
                    d.addNewLine(0, 1);
                    sb.setLength(0);
                    sb.append(Meldungen.MO038(e.getTermin()));
                    Global.anhaengen(sb, ", ", e.getOrt());
                    Global.anhaengen(sb, ", ", e.getName());
                    d.startBlock(sb.toString(), true, fontname, size + 1, "bold", null, "text-decoration", "underline");
                    sb.setLength(0);
                    d.addNewLine(0, 1);
                    termin = e.getTermin();
                    if (!Global.nes(e.getNotiz())) {
                        d.startBlock(null, false);
                        d.inline(e.getNotiz(), "font-weight", "bold");
                        d.endBlock();
                    }
                }
                if (!Global.nes(e.getMessdienerName())) {
                    if (sb.length() <= 0 && !Global.nes(dienst) && !dienst.equals(Meldungen.MO005())) {
                        dienstFett = dienst + ": ";
                    } else if (sb.length() > 0) {
                        sb.append(" - ");
                    }
                    Global.anhaengen(sb, "", e.getMessdienerVorname());
                    Global.anhaengen(sb, " ", e.getMessdienerName());
                }
            }
            if (sb.length() > 0) {
                d.startBlock(null, false);
                if (dienstFett != null) {
                    d.inline(dienstFett, "font-weight", "bold");
                }
                d.inline(sb.toString());
                d.endBlock();
            }

            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }
}

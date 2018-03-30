package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;

import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.dto.FoHaus;
import de.cwkuehl.jhh6.server.fop.dto.FoMieter;
import de.cwkuehl.jhh6.server.fop.dto.FoWohnung;
import de.cwkuehl.jhh6.server.fop.dto.FoZeile;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Abrechnung als FO-Dokument.
 */
public class FoAbrechnung extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoAbrechnung() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Abrechnung.
     * @param haus Daten der Betriebskosten-Abrechnung für ein Haus.
     */
    public void generate(FoHaus haus) {

        try {
            String fontname = d.getFontname();
            int size = 11;
            String waehrung = "€";
            double summeQm = 0;
            double anteilQm = 0;
            double summePm = 0;
            double anzahlPm = 0;
            double anteilPm = 0;
            double anteil = 0;
            double db = 0;
            int anzahl = 0;
            int punkt = 0;
            int jahr = haus.getVon().getYear();
            int mon = 0;
            String str = null;

            if (Global.compDouble(haus.getQm(), 0) == 0) {
                haus.setQm(1);
            }
            if (Global.compDouble(haus.getPersonenmonate(), 0) == 0) {
                haus.setPersonenmonate(1);
            }
            d.startFo1Master("8mm", "15mm", "15mm", "5mm", "25mm", "12mm", 0, null);
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startTable(true, "117mm", "71mm");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(haus.getVmName(), true, fontname, size, null, null);
            d.startBlock(haus.getVmStrasse(), true, fontname, size, null, null);
            d.startBlock(haus.getVmOrt(), true, fontname, size, null, null);
            d.startBlock(haus.getVmTelefon(), true, fontname, size, null, null);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(haus.getDatum(), true, fontname, size, "bold", null, "text-align", "right");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();
            d.endTag("fo:static-content");

            d.startTag("fo:static-content", "flow-name", d.getMultiName("footer"));
            d.addNewLine(0, 1);
            if (!Global.nes(haus.getAnlage())) {
                String[] array = haus.getAnlage().split("\\\\n");
                for (String s : array) {
                    if (Global.nes(s)) {
                        d.addNewLine(0, 1);
                    } else {
                        d.startBlock(s, true, fontname, size, null, null);
                    }
                }
            }
            d.endTag("fo:static-content");

            d.startFlow(fontname, size, 0);
            for (FoWohnung w : haus.getWohnungen()) {
                for (FoMieter m : w.getMieter()) {
                    anzahl++;
                    punkt = 0;
                    summeQm = 0;
                    summePm = 0;
                    anteil = 0;
                    if (anzahl > 1) {
                        d.startBlock(null, true, "page-break-after", "always");
                    }
                    d.addNewLine(0, 2);
                    if (m.getAnrede() != null) {
                        d.startBlock(m.getAnrede(), true);
                    }
                    if (m.getAnrede() != null && !m.getAnrede().trim().contains(" ")) {
                        // bei Anrede mit Namen ist kein Name notwendig
                        d.startBlock(m.getName(), true);
                    }
                    d.startBlock(m.getStrasse(), true);
                    d.startBlock(m.getOrt(), true);
                    d.addNewLine(0, 2);
                    d.startBlock(Meldungen.VM033(jahr, haus.getHstrasse()), true);
                    mon = Global.monatsDifferenz(m.getVon(), m.getBis());
                    if (mon != 12) {
                        d.startBlock(Meldungen.VM034(Global.getPeriodeString(m.getVon(), m.getBis(), true)), true);
                    } else {
                        d.addNewLine(0);
                    }

                    d.startTableBorder(true, "7mm", "112mm", "25mm", "22mm", "22mm");
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "number-columns-spanned", "2", "border-style", "solid", "padding-top",
                            ".5mm");
                    d.startBlock(Meldungen.VM035(), true, null, 0, "bold", null);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM036(waehrung), true, null, 0, "bold", null, "padding-top", ".5mm");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM037(), true, null, 0, "bold", null, "padding-top", ".5mm");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM038(), true, null, 0, "bold", null, "padding-top", ".5mm");
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    // Sonstige Betriebskosten
                    addUeberschrift(++punkt, Meldungen.VM039());
                    summeQm += addZeile(haus.getGrundsteuer());
                    summeQm += addZeile(haus.getStrassenreinigung());
                    summeQm += addZeile(haus.getAbfall());
                    summeQm += addZeile(haus.getStrom());
                    if (haus.getNiederschlagswasser().getReihenfolge().endsWith("_1")) {
                        summeQm += addZeile(haus.getNiederschlagswasser());
                    }
                    summeQm += addZeile(haus.getWohnversicherung());
                    summeQm += addZeile(haus.getHaftversicherung());
                    summeQm += addZeile(haus.getGlasversicherung());
                    summeQm += addZeile(haus.getDachreinigung());
                    summeQm += addZeile(haus.getSchornsteinfeger());
                    summeQm += addZeile(haus.getGarten());
                    // Summe qm
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM040(), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid", "border-top-width", "1mm");
                    d.startBlock(d.getBetrag(summeQm, null, false), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    // Umlage qm
                    anteilQm = Global.rundeBetrag(summeQm / haus.getQm()); // + 0.005);
                    addZeile(Meldungen.VM041(haus.getQm()), null, null, null);
                    addZeile(Meldungen.VM042(d.getBetrag(summeQm, waehrung, false), haus.getQm()), d.getBetrag(anteilQm,
                            null, false), null, null);
                    db = Global.rundeBetrag(anteilQm * w.getQm() * mon / 12);
                    anteil += db;
                    str = "";
                    if (mon != 12) {
                        str = Global.format(" x {0}/12", mon);
                    }
                    addZeile(Meldungen.VM043(d.getBetrag(anteilQm, waehrung, false), w.getQm(), str), null, d.getBetrag(
                            db, null, false), null);
                    // Wasserversorgung und Entwässerung
                    addUeberschrift(++punkt, Meldungen.VM044());
                    summePm += addZeile(haus.getTrinkwasser());
                    summePm += addZeile(haus.getSchmutzwasser());
                    if (!haus.getNiederschlagswasser().getReihenfolge().endsWith("_1")) {
                        summePm += addZeile(haus.getNiederschlagswasser());
                    }
                    // Summe Personenmonate
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM040(), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid", "border-top-width", "1mm");
                    d.startBlock(d.getBetrag(summePm, null, false), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    // Umlage Personenmonate
                    anzahlPm = haus.getPersonenmonate() + m.getPersonenmonat2();
                    anteilPm = Global.rundeBetrag(summePm / anzahlPm);
                    addZeile(Meldungen.VM045(anzahlPm), null, null, null);
                    addZeile(Meldungen.VM046(d.getBetrag(summePm, waehrung, false), anzahlPm), d.getBetrag(anteilPm,
                            null, false), null, null);
                    db = Global.rundeBetrag(anteilPm * m.getPersonenmonate());
                    anteil += db;
                    addZeile(Meldungen.VM047(d.getBetrag(anteilPm, waehrung, false), m.getPersonenmonate()), null, d
                            .getBetrag(db, null, false), null);
                    // Kosten der Gemeinschaftsantenne
                    addUeberschrift(++punkt, Meldungen.VM048());
                    addZeile(Meldungen.VM049(), null, null, null);
                    db = Global.rundeBetrag(m.getAntenne() * m.getMonate());
                    anteil += db;
                    addZeile(Meldungen.VM050(d.getBetrag(m.getAntenne(), waehrung, false), m.getMonate()), null, d
                            .getBetrag(db, null, false), null);
                    // Summe Anteil
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM040(), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid", "border-top-width", "1mm");
                    d.startBlock(d.getBetrag(anteil, null, false), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(d.getBetrag(anteil, null, false), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    anteil -= m.getBkvoraus();
                    addZeile(Meldungen.VM051(), null, null, d.getBetrag(m.getBkvoraus(), null, false));
                    // Guthaben / Nachzahlung 1
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Global.iif(Global.compDouble(anteil, 0) <= 0, Meldungen.VM052(), Meldungen.VM053()),
                            true);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid", "border-top-width", "1mm");
                    d.startBlock(d.getBetrag(anteil, null, false), true, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");
                    // Heizkosten
                    addUeberschrift(++punkt, Meldungen.VM054());
                    db = m.getHkabrechnung() - m.getHkvoraus();
                    anteil += db;
                    if (Global.compDouble(db, 0) <= 0)
                        addZeile(Meldungen.VM055(jahr), null, null, d.getBetrag(db, null, false));
                    else
                        addZeile(Meldungen.VM056(jahr), null, null, d.getBetrag(db, null, false));
                    // Guthaben / Nachzahlung 2
                    d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.startBlock(Meldungen.VM057(jahr), false, null, 0, "bold", null);
                    d.startTag("fo:inline", Global.iif(Global.compDouble(anteil, 0) <= 0, Meldungen.VM052(), Meldungen
                            .VM053()), true, null, 0, "normal", null);
                    d.endBlock();
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid");
                    d.addNewLine(0);
                    d.endTag("fo:table-cell");
                    d.startTag("fo:table-cell", "border-style", "solid", "border-top-width", "1mm",
                            "border-bottom-width", "1.5mm");
                    d.startBlock(d.getBetrag(anteil, null, false), true, null, 0, "bold", null, "text-align", "right");
                    d.endTag("fo:table-cell");
                    d.endTag("fo:table-row");

                    d.endTable();
                    str = Global.iif(Global.compDouble(anteil, 0) <= 0, haus.getGuthaben(), haus.getNachzahlung());
                    if (!Global.nes(str)) {
                        d.addNewLine(0);
                        d.startBlock(str, true);
                    }
                    if (!Global.nes(haus.getGruesse())) {
                        d.addNewLine(0);
                        d.startBlock(haus.getGruesse(), true);
                    }
                }
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

    private void addUeberschrift(int punkt, String zeile) throws IOException {

        if (zeile == null) {
            return;
        }
        d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.startBlock(Global.format("{0}.", punkt), true);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.startBlock(zeile, true, "text-decoration", "underline");
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.addNewLine(0);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.addNewLine(0);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.addNewLine(0);
        d.endTag("fo:table-cell");
        d.endTag("fo:table-row");
    }

    private double addZeile(FoZeile zeile) throws IOException {

        if (zeile == null || !Constant.KZB_AKTIV.equals(zeile.getStatus())) {
            return 0;
        }
        addZeile(zeile.getBeschreibung(), d.getBetrag(zeile.getBetrag(), null, false), null, null);
        return zeile.getBetrag();
    }

    private void addZeile(String kostenart, String kosten, String anteil, String betrag) throws IOException {

        d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
        d.startTag("fo:table-cell", "border-style", "solid");
        d.addNewLine(0);
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        if (Global.nes(kostenart)) {
            d.addNewLine(0);
        } else {
            d.startBlock(kostenart, true);
        }
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        if (Global.nes(kosten)) {
            d.addNewLine(0);
        } else {
            d.startBlock(kosten, true, "text-align", "right");
        }
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        if (Global.nes(anteil)) {
            d.addNewLine(0);
        } else {
            d.startBlock(anteil, true, "text-align", "right");
        }
        d.endTag("fo:table-cell");
        d.startTag("fo:table-cell", "border-style", "solid");
        if (Global.nes(betrag)) {
            d.addNewLine(0);
        } else {
            d.startBlock(betrag, true, "text-align", "right");
        }
        d.endTag("fo:table-cell");
        d.endTag("fo:table-row");
    }

}

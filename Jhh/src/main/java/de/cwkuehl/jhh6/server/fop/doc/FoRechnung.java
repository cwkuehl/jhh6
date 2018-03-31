package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import de.cwkuehl.jhh6.api.dto.HpBehandlungDruck;
import de.cwkuehl.jhh6.api.dto.HpPatient;
import de.cwkuehl.jhh6.api.dto.HpRechnung;
import de.cwkuehl.jhh6.api.enums.GeschlechtEnum;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.global.Parameter;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.FoUtils;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Rechnung als FO-Dokument.
 */
public class FoRechnung extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoRechnung() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Rechnung.
     * @param rechnung Daten der Rechnung.
     * @param patient Patienten-Daten.
     * @param patientAdresse Patient, der die Adress-Daten enthält.
     * @param zahldatum Zahlungsziel.
     * @param behandlungen Liste der Behandlungen.
     * @param einstellungen Liste der Einstellungen.
     */
    public void generate(HpRechnung rechnung, HpPatient patient, HpPatient patientAdresse, LocalDate zahldatum,
            List<HpBehandlungDruck> behandlungen, Map<String, String> einstellungen) {

        try {
            String fontname = d.getFontname();
            int size = 10;
            String hpName = einstellungen.get(Parameter.HP_NAME);
            String hpBeruf = einstellungen.get(Parameter.HP_BERUF);
            String hpStrasse = einstellungen.get(Parameter.HP_STRASSE);
            String hpOrt = einstellungen.get(Parameter.HP_ORT);
            String hpAdresse = einstellungen.get(Parameter.HP_FENSTER_ADRESSE);
            String hpTelefon = einstellungen.get(Parameter.HP_TELEFON);
            String hpSteuernummer = einstellungen.get(Parameter.HP_STEUERNUMMER);
            String briefText = einstellungen.get(Parameter.HP_BRIEFANFANG);
            String gruss = einstellungen.get(Parameter.HP_GRUSS);
            String hpBankverbindung = einstellungen.get(Parameter.HP_BANK);
            String waehrung = "€";
            String anrede = null;
            String text = null;
            String hpNameLang = Global.anhaengen(hpName, ", ", hpBeruf);
            String name = Global.anhaengen(patientAdresse.getVorname(), " ", patientAdresse.getName1());
            String patientName = Global.anhaengen(patient.getVorname(), " ", patient.getName1());
            StringBuffer sb = new StringBuffer();
            double summe = 0;

            text = einstellungen.get(Parameter.HP_BRIEFENDE);
            sb.setLength(0);
            if (GeschlechtEnum.fromValue(patientAdresse.getGeschlecht()).equals(GeschlechtEnum.FRAU)) {
                sb.append("Sehr geehrte Frau ");
            } else {
                sb.append("Sehr geehrter Herr ");
            }
            sb.append(patientAdresse.getName1()).append(",");
            anrede = sb.toString();

            d.startFo2Master("8mm", "10mm", "15mm", "5mm", "25mm", "5mm", "15mm", "15mm");
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header-first"));
            d.startTable(true, "71mm", "117mm");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell", "number-rows-spanned", "2");
            if (!getGrafikDaten(einstellungen.get(Parameter.HP_LOGO_OBEN))) {
                d.addNewLine(0);
            }
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-after-style", "solid", "border-after-width", "0.7pt");
            d.startBlock(hpNameLang, true, fontname, 12, "bold", null, "text-align", "center");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            // d.startTag("fo:table-cell");
            // d.addNewLine(0);
            // d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(hpStrasse + ", " + hpOrt, true, fontname, 10, null, null, "text-align", "center",
                    "margin-top", "2mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Tel. " + hpTelefon, true, fontname, 10, null, null, "text-align", "center", "margin-top",
                    "1mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Steuernummer: " + hpSteuernummer, true, fontname, 10, null, null, "text-align", "center");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();
            d.endTag("fo:static-content");

            d.startTag("fo:static-content", "flow-name", d.getMultiName("footer-first"));
            d.addNewLine(0, 2);
            d.startBlock("Bankverbindung: " + hpBankverbindung, true, fontname, size, null, null);
            d.endTag("fo:static-content");

            d.startTag("fo:static-content", "flow-name", d.getMultiName("footer-rest"));
            d.addNewLine(0, 2);
            d.startBlock("Bankverbindung: " + hpBankverbindung, false, fontname, size, null, null);
            d.startTag("fo:inline", Meldungen.M1058(), false, null, 0, null, null, "padding-left", "10mm");
            d.startTag("fo:page-number", true);
            d.endTag("fo:inline");
            d.endBlock();
            d.endTag("fo:static-content");
            d.startFlow(fontname, size, 0);

            d.addNewLine(0, 6);
            d.startBlock(hpName + ", " + hpAdresse, true, null, 7, null, null);
            d.addNewLine(9, 1);
            d.startTable(true, "102mm", "20mm", "66mm");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(name, true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Rechnung:", true, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(rechnung.getRechnungsnummer(), true, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(patientAdresse.getAdresse1(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Datum:", true, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(FoUtils.getDatum(rechnung.getDatum()), true, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(patientAdresse.getAdresse2(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Patient:", true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(patientName, true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.startBlock(patientAdresse.getAdresse3(), true);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("geb.", true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(FoUtils.getDatum(patient.getGeburt()), true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.startTag("fo:table-row");
            d.startTag("fo:table-cell");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock("Diagnose:", true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell");
            d.startBlock(rechnung.getDiagnose(), true, null, 0, "bold", null, "margin-top", "1.5mm");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();

            d.startBlock(anrede, true);
            d.startBlock(briefText, true, "margin-top", "1.5mm");

            d.addNewLine(9, 1);
            d.startTableBorder(true, "22mm", "14mm", "14mm", "114mm", "24mm");
            d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("Datum", true, null, 0, "bold", "italic");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("LVKH-Ziffer", true, null, 0, "bold", "italic");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("vgl. GebüH", true, null, 0, "bold", "italic");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("Ziff. GebüH: (GOÄ) Leistung: ggf. Zeitaufwand", true, null, 0, "bold", "italic");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("Betrag", true, null, 0, "bold", "italic", "text-align", "right");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            for (HpBehandlungDruck b : behandlungen) {
                // for (int i = 0; i < 30; i++) {
                d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm", "keep-together.within-page", "always");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(FoUtils.getDatum(b.getDatum()), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(b.getZiffer(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(b.getZifferAlt(), true);
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(b.getLeistung(), true, null, 0, "bold", null);
                sb.setLength(0);
                sb.append(b.getLeistung2());
                // if (b.getDauer() > 0) {
                // sb.append(" ").append(b.getDauer()).append(" min");
                // }
                String[] zeilen = sb.toString().split("(<[bB][rR]>|\r\n?|\n\r?)");
                for (int k = 0; k < zeilen.length; k++) {
                    if (k == 0) {
                        d.startBlock(zeilen[k], true, "margin-top", "0.8mm");
                    } else {
                        d.startBlock(zeilen[k], true);
                    }
                }
                d.endTag("fo:table-cell");
                d.startTag("fo:table-cell", "border-style", "solid");
                d.startBlock(d.getBetrag(b.getBetrag(), waehrung, false), true, null, 0, "bold", null, "text-align",
                        "right");
                d.endTag("fo:table-cell");
                d.endTag("fo:table-row");
                summe += b.getBetrag();
                // }
            }
            d.startTag("fo:table-row", "margin", "1mm 1mm 1mm 1mm");
            d.startTag("fo:table-cell", "number-columns-spanned", "3", "border-style", "solid");
            d.addNewLine(0);
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock("Gesamtbetrag", true, null, 0, "bold", null);
            d.startBlock("bitte überweisen bis " + FoUtils.getDatum(zahldatum), true, null, 0, "bold", null,
                    "margin-top", "0.8mm");
            d.endTag("fo:table-cell");
            d.startTag("fo:table-cell", "border-style", "solid");
            d.startBlock(d.getBetrag(summe, waehrung, false), true, null, 0, "bold", null, "text-align", "right");
            d.endTag("fo:table-cell");
            d.endTag("fo:table-row");
            d.endTable();

            d.addNewLine(9, 1);
            d.startBlock(text, true, null, 8, null, null);
            d.addNewLine(0, 2);
            d.startBlock(gruss, true);
            d.addNewLine(0, 3);
            getGrafikDaten(einstellungen.get(Parameter.HP_LOGO_UNTEN));
            d.startBlock(hpName, true);

            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

    private boolean getGrafikDaten(String grafik) throws IOException {

        if (Global.nes(grafik)) {
            return false;
        }
        String[] array = new String[2];
        String[] split = grafik.split("#");
        if (Global.arrayLaenge(split) > 0) {
            array[0] = split[0];
        }
        if (Global.arrayLaenge(split) > 1) {
            array[1] = split[1];
        } else {
            array[1] = "50";
        }
        try {
            d.startBlock(null, false);
            d.externalGraphic(Global.leseBytes(array[0]), array[1]);
        } catch (Exception e) {
            d.startBlock("Grafik " + array[0] + " konnte nicht geladen werden.", true);
        } finally {
            d.endBlock();
        }
        return true;
    }

}

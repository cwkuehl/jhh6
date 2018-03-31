package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Adressenliste als FO-Dokument.
 */
public class FoAdressenliste extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoAdressenliste.class);

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoAdressenliste() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Adressenliste.
     * @param ueberschrift Überschrift.
     * @param liste Adressenliste.
     */
    public void generate(String ueberschrift, List<AdPersonSitzAdresse> liste) {

        try {
            String fontname = d.getFontname();
            int size = 7;
            // d.startFo(null, 10, 0, "27.5mm", false);
            d.startFo1Master("2mm", "2mm", "5mm", "1mm", "5mm", "5mm", 2, "4mm");
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
            String uid = null;
            for (AdPersonSitzAdresse a : liste) {
                if (!a.getUid().equals(uid)) {
                    d.startBlock(getPersonName(a), true, null, 0, "bold", null);
                }
                d.startBlock(getSitzName(a), true, null, 0, null, null, "start-indent", "3mm");
                uid = a.getUid();
            }
            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

    private String getPersonName(AdPersonSitzAdresse a) {

        StringBuffer sb = new StringBuffer();
        Global.anhaengen(sb, " ", a.getPraedikat());
        Global.anhaengen(sb, " ", a.getName1());
        Global.anhaengen(sb, " ", a.getName2());
        Global.anhaengen(sb, ", ", a.getVorname());
        Global.anhaengen(sb, " (", a.getTitel(), ")");
        Global.anhaengen(sb, ", ", Global.dateString(a.getGeburt()));
        return sb.toString();
    }

    private String getSitzName(AdPersonSitzAdresse a) {

        StringBuffer sb = new StringBuffer();
        Global.anhaengen(sb, null, a.getName());
        sb.append(":");
        if (!Global.nes(a.getAdUid())) {
            if (!"D".equals(a.getStaat())) {
                Global.anhaengen(sb, " ", a.getStaat(), "-");
            }
            Global.anhaengen(sb, " ", a.getStrasse());
            Global.anhaengen(sb, " ", a.getPostfach());
            Global.anhaengen(sb, " ", a.getHausnr());
            Global.anhaengen(sb, " ", a.getPlz());
            Global.anhaengen(sb, " ", a.getOrt());
        }
        Global.anhaengen(sb, " ", a.getTelefon());
        Global.anhaengen(sb, " ", a.getFax());
        Global.anhaengen(sb, " ", a.getMobil());
        Global.anhaengen(sb, " ", a.getEmail());
        Global.anhaengen(sb, " ", a.getHomepage());
        Global.anhaengen(sb, " ", a.getBemerkung());
        return sb.toString();
    }
}

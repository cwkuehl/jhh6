package de.cwkuehl.jhh6.server.fop.doc;

import java.io.IOException;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.cwkuehl.jhh6.api.dto.SbPerson;
import de.cwkuehl.jhh6.server.fop.impl.FoGeneratorDocument;
import de.cwkuehl.jhh6.server.fop.impl.JhhFopException;

/**
 * Diese Klasse generiert das Ausgangsdokument Nachfahrenliste oder Vorfahrenliste als FO-Dokument.
 */
public class FoNachfahrenliste extends FoGeneratorDocument {

    // private static Log log = LogFactory.getLog(FoNachfahrenliste.class);
    private Pattern             pbem = Pattern.compile("^( *)([0-9\\+]+ )<b>(.*)</b> (.*)$");

    /**
     * Basisklasse zum Testen als Mock.
     */
    private FoGeneratorDocument d    = null;

    /**
     * Konstruktor mit Initialisierung.
     */
    public FoNachfahrenliste() {

        super();
        d = this;
    }

    /**
     * Generiert das Ausgangsdokument Nachfahrenliste oder Vorfahrenliste.
     * @param ueberschrift Überschrift.
     * @param untertitel 2. Überschriftszeile.
     * @param liste Ahnenliste.
     */
    public void generate(String ueberschrift, String untertitel, List<SbPerson> liste) {

        try {
            String fontname = d.getFontname();
            int size = 7;
            d.startFo1Master("10mm", "10mm", "10mm", "10mm", "10mm", "5mm", 0, null);
            d.startTag("fo:static-content", "flow-name", d.getMultiName("header"));
            d.startBlock(ueberschrift, true, fontname, 12, "bold", null, "text-align", "center");
            d.startBlock(untertitel, true, fontname, 10, "bold", null, "text-align", "center");
            d.endTag("fo:static-content");
            d.startTag("fo:static-content", "flow-name", d.getMultiName("footer"));
            d.startBlock(null, false, fontname, size, null, null, "text-align", "center");
            d.startTag("fo:inline", "Seite ", false, null, 0, null, null);
            d.startTag("fo:page-number", true);
            d.endTag("fo:inline");
            d.endBlock();
            d.endTag("fo:static-content");
            d.startFlow(fontname, size, 0);
            // Textausgabe
            String bem = null;
            String leer = null;
            String normal1 = null;
            String fett = null;
            String normal2 = null;
            int ind = 0;
            Matcher m = null;
            for (SbPerson p : liste) {
                bem = p.getBemerkung();
                m = pbem.matcher(bem);
                if (m.find()) {
                    leer = m.group(1);
                    ind = leer.length();
                    normal1 = m.group(2);
                    fett = m.group(3);
                    normal2 = m.group(4);
                } else {
                    ind = 0;
                    while (bem != null && ind < bem.length() && bem.charAt(ind) == ' ') {
                        ind++;
                    }
                    normal1 = bem.trim();
                    normal2 = null;
                }
                d.startBlock(normal1, false, null, 0, null, null, "start-indent", String.format("%dmm", ind * 2));
                if (fett != null) {
                    d.inline(fett, "font-weight", "bold");
                }
                if (normal2 != null) {
                    d.inline(normal2);
                }
                d.endBlock();
            }
            d.endFo();
        } catch (IOException e) {
            // log.error("", e);
            throw new JhhFopException(e);
        }
    }

}

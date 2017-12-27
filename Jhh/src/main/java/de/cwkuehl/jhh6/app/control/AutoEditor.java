package de.cwkuehl.jhh6.app.control;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.fxmisc.richtext.StyleClassedTextArea;
import org.fxmisc.richtext.model.StyleSpans;
import org.fxmisc.richtext.model.StyleSpansBuilder;

import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;
import javafx.application.Platform;
import javafx.concurrent.Task;

/**
 * Automatische Formatierung in einem HTML-Editor.
 */
public class AutoEditor {

    private StyleClassedTextArea node  = null;
    private StyleClassedTextArea node2 = null;
    private List<Integer>        paras = new ArrayList<>();

    public AutoEditor(StyleClassedTextArea node, StringBuffer abbruch, StyleClassedTextArea node2) {

        this.node = node;
        this.node2 = node2;
        node.textProperty().addListener((obs, oldText, newText) -> {
            if (abbruch.length() <= 0) {
                // System.out.println("computeHighlighting");
                abbruch.append("x");
            }
        });
        // Damit funktion kein fett und keine anderen Größen:
        // node.setStyle("-fx-font: 20 arial;");
        // Das hat keine Auswirkung:
        // node.getStyleClass().add("auto-editor");
        node2.setEditable(false);
        node2.setOnMouseClicked(e -> {
            int p = node2.getCurrentParagraph();
            if (p < paras.size()) {
                node.moveTo(paras.get(p));
                node.selectLine();
            }
            node.requestFocus();
            e.consume();
        });
        refresh();
    }

    public void refresh() {

        StringBuffer sb2 = new StringBuffer();
        node.setStyleSpans(0, computeHighlighting(node.getText(), sb2));
        node2.replaceText(sb2.toString());
        node2.setStyleSpans(0, computeHighlighting(node2.getText(), null));
    }

    private static final Pattern PATTERN = Pattern.compile("(?m)^((?<UEBERSCHRIFT>:.+)|(?<BEOBACHTUNG>"
                                                 + Pattern.quote("-") + ".+)" + "|(?<AUSSAGE>_.+)|(?<FRAGE>"
                                                 + Pattern.quote("?") + ".+)|(?<HYPOTHESE>!.+)"
                                                 + "|(?<KONTROLLE>%.+)|(?<PARAMETER>#.+)"
                                                 + "|(?<SYMPTOM>\\<\\<.+\\>\\>))$");

    public StyleSpans<Collection<String>> computeHighlighting(String text, StringBuffer sb2) {

        Matcher matcher = PATTERN.matcher(text);
        int lastKwEnd = 0;
        StyleSpansBuilder<Collection<String>> spansBuilder = new StyleSpansBuilder<>();
        if (sb2 != null) {
            sb2.setLength(0);
            paras.clear();
        }
        if (Global.nes(text)) {
            spansBuilder.add(Collections.singleton("auto-normal"), 0);
            return spansBuilder.create();
        }
        while (matcher.find()) {
            String styleClass = matcher.group("UEBERSCHRIFT") != null ? "auto-ueberschrift" : matcher
                    .group("BEOBACHTUNG") != null ? "auto-beobachtung"
                    : matcher.group("AUSSAGE") != null ? "auto-aussage" : matcher.group("FRAGE") != null ? "auto-frage"
                            : matcher.group("HYPOTHESE") != null ? "auto-hypothese"
                                    : matcher.group("KONTROLLE") != null ? "auto-kontrolle" : matcher
                                            .group("PARAMETER") != null ? "auto-parameter"
                                            : matcher.group("SYMPTOM") != null ? "auto-symptom" : null;
            assert styleClass != null;
            // spansBuilder.add(Collections.emptyList(), matcher.start() - lastKwEnd);
            spansBuilder.add(Collections.singleton("auto-normal"), matcher.start() - lastKwEnd);
            spansBuilder.add(Collections.singleton(styleClass), matcher.end() - matcher.start());
            if (sb2 != null && matcher.end() - matcher.start() > 0) {
                Global.anhaengen(sb2, Constant.CRLF, text.substring(matcher.start(), matcher.end()));
                paras.add(matcher.end());
            }
            lastKwEnd = matcher.end();
        }
        spansBuilder.add(Collections.singleton("auto-normal"), text.length() - lastKwEnd);
        return spansBuilder.create();
    }

    public static void addHighlightning(StyleClassedTextArea node, StringBuffer abbruch, StyleClassedTextArea node2) {

        if (node == null) {
            return;
        }
        AutoEditor autoeditor = new AutoEditor(node, abbruch, node2);

        Task<Void> task = new Task<Void>() {
            @Override
            public Void call() throws Exception {
                while (true) {
                    // Prüfen, ob View geschlossen ist, damit Thread beendet werden kann.
                    if (abbruch.length() > 1) {
                        throw new Exception("Ende");
                    } else if (abbruch.length() == 1) {
                        abbruch.setLength(0);
                        Platform.runLater(() -> autoeditor.refresh());
                    }
                    Thread.sleep(5000);
                }
            }
        };
        Thread th = new Thread(task);
        th.setDaemon(true);
        th.start();
    }
}

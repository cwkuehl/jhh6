package de.cwkuehl.jhh6.app.control;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import java.util.regex.Pattern;

import de.cwkuehl.jhh6.api.dto.ByteDaten;
import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.Tooltip;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.image.WritableImage;
import javafx.scene.input.ClipboardContent;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;
import javafx.scene.input.MouseEvent;
import javafx.scene.input.TransferMode;
import javafx.scene.layout.HBox;
import javafx.scene.text.TextAlignment;

/** Klasse für Drag and Drop Bilder. */
public class Bild extends ImageView {

    /** Daten als ByteDaten. */
    private ByteDaten        bd   = null;

    /** Auszuführende Funktion beim Anlegen bzw. Drop. */
    private Consumer<String> r    = null;

    /** Parent für das Bild. */
    private HBox             p    = null;

    private boolean          leer = false;

    /**
     * Konstruktor mit Initialisierung.
     * @param p0 Parent für Bild.
     * @param pfad Datei inkl. Pfad oder Text kann null sein.
     * @param bytes0 Beinhaltende Bytes können null sein.
     * @param metadaten0 Metadaten zu den Bytes können null sein.
     * @param r0 Auszuführende Funktion beim Anlegen bzw. Drop.
     */
    public Bild(HBox p0, String pfad, byte[] bytes0, Image image, String metadaten0, Consumer<String> r0) {

        p = p0;
        r = r0;

        if (image != null) {
            // Fall: nur Bild und Text
            Global.machNichts();
        } else if (!Global.nes(pfad)) {
            // Fall: Dateiname
            try {
                bytes0 = Global.leseBytes(pfad);
                metadaten0 = getFileMetadaten(pfad);
                image = new Image(new ByteArrayInputStream(bytes0));
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
            bd = new ByteDaten();
            bd.setBytes(bytes0);
            bd.setMetadaten(metadaten0);
        } else if (bytes0 != null && !Global.nes(metadaten0)) {
            // Fall: Bytes und Metadaten
            pfad = Global.stringAusschnitt(metadaten0, "<text>", "</text>", true);
            if (Global.nes(pfad)) {
                pfad = Global.stringAusschnitt(metadaten0, "<file>", "</file>", true);
                // setText(text);
            }
            image = new Image(new ByteArrayInputStream(bytes0));
            bd = new ByteDaten();
            bd.setBytes(bytes0);
            bd.setMetadaten(metadaten0);
        } else {
            throw new RuntimeException("Falsche Parameter für Bild.");
        }
        if (!Global.nes(pfad)) {
            Tooltip.install(this, new Tooltip(pfad));
        }
        setImage(image);

        setOnDragOver((DragEvent e) -> {

            if (!isSibling(e.getGestureSource()) && (e.getDragboard().hasString() || e.getDragboard().hasFiles())) {
                e.acceptTransferModes(TransferMode.COPY_OR_MOVE);
            }
            e.consume();
            // System.out.println("setOnDragOver: ");
        });

        setOnDragDropped((DragEvent event) -> {

            Dragboard db = event.getDragboard();
            boolean success = false;
            if (db.hasFiles()) {
                // System.out.println("setOnDragDropped Files: " + db.getFiles().get(0).getAbsolutePath());
                try {
                    String datei = db.getFiles().get(0).getAbsolutePath();
                    new Bild(p, datei, null, null, null, r);
                    success = true;
                } catch (Exception e) {
                }
            } else if (db.hasString()) {
                // System.out.println("setOnDragDropped String: " + db.getString());
                // try {
                // byte[] bytes = Global.leseBytes(db.getString());
                // Image image = new Image(new ByteArrayInputStream(bytes));
                // ImageView iv = new ImageView(image);
                // hbox.getChildren().add(iv);
                // success = true;
                // } catch (Exception e) {
                // }
            }
            event.setDropCompleted(success);
            event.consume();
        });

        setOnDragDetected((MouseEvent event) -> {

            Dragboard db = this.startDragAndDrop(TransferMode.COPY_OR_MOVE);
            ClipboardContent content = new ClipboardContent();
            content.putString(this.getImage().toString());
            db.setContent(content);
            event.consume();
            // System.out.println("setOnDragDetected: " + iv.getId());
        });

        setOnDragDone((DragEvent e) -> {

            if (e.getAcceptedTransferMode() != null && e.getAcceptedTransferMode().equals(TransferMode.MOVE)) {
                p.getChildren().remove(Bild.this);
                if (p.getChildren().size() <= 0) {
                    addDragNdrop(p, r);
                }
            }
        });

        if (!p.getChildren().isEmpty() && p.getChildren().get(0) instanceof Bild) {
            Bild b = (Bild) p.getChildren().get(0);
            if (b.leer) {
                p.getChildren().remove(b);
            }
        }
        p.getChildren().add(this);
        if (r != null) {
            r.accept(metadaten0);
        }
    }

    public ByteDaten getByteDaten() {
        return bd;
    }

    private boolean isSibling(Object comp) {

        Parent p = this.getParent();
        if (comp != null && p != null) {
            for (Node n : p.getChildrenUnmodifiable()) {
                if (comp.equals(n)) {
                    return true;
                }
            }
        }
        return false;
    }

    private String getFileMetadaten(final String pfad) throws IOException {

        File f = new File(pfad);
        Path path = Paths.get(pfad);
        BasicFileAttributes attributes = Files.readAttributes(path, BasicFileAttributes.class);
        String metadaten = Global.format(
                "<image><text>Bild</text><file>{0}</file><date>{1}</date><size>{2}</size></image>",
                f.getAbsoluteFile(), attributes.creationTime().toString(), Global.lngStr(f.length()));
        return metadaten;
    }

    public static List<ByteDaten> parseBilddaten(String s, List<ByteDaten> byteliste) {

        if (Global.nes(s) || Global.listLaenge(byteliste) <= 0) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        String[] array = s.split("(" + Pattern.quote("</image>" + Constant.CRLF + "<image>") + "|"
                + Pattern.quote("</image>" + Constant.LF + "<image>") + ")");
        for (int i = 0; array != null && i < array.length && i < byteliste.size(); i++) {
            sb.setLength(0);
            if (!array[i].startsWith("<image>")) {
                sb.append("<image>");
            }
            sb.append(array[i]);
            if (!array[i].endsWith("</image>")) {
                sb.append("</image>");
            }
            ByteDaten bd = byteliste.get(i);
            bd.setMetadaten(sb.toString());
        }
        return byteliste;
    }

    public static void addDragNdrop(HBox hbox, Consumer<String> r0) {

        if (hbox == null) {
            return;
        }
        String text = Global.g0("Image.tt");
        Bild b = new Bild(hbox, text.trim(), null, textToImage(text, 300, 150), null, r0);
        b.leer = true;
        // hbox.getChildren().add(b);
    }

    public static List<ByteDaten> getBytesListe(HBox hbox) {

        if (hbox == null) {
            return null;
        }
        List<ByteDaten> byteliste = new ArrayList<ByteDaten>();
        for (Node n : hbox.getChildrenUnmodifiable()) {
            if (n instanceof Bild) {
                if (((Bild) n).bd != null) {
                    byteliste.add(((Bild) n).bd);
                }
            }
        }
        return byteliste;
    }

    private static Image textToImage(String text, double w, double h) {

        Label label = new Label(text);
        label.setMinSize(w, h);
        label.setMaxSize(w, h);
        label.setPrefSize(w, h);
        label.setStyle("-fx-background-color: lightgray; -fx-text-fill:black;");
        label.setWrapText(true);
        label.setTextAlignment(TextAlignment.CENTER);
        Scene scene = new Scene(new Group(label));
        WritableImage img = new WritableImage((int) w, (int) h);
        scene.snapshot(img);
        return img;
    }

}

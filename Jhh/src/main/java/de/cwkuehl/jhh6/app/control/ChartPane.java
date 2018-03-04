package de.cwkuehl.jhh6.app.control;

import java.awt.Dimension;
import java.util.ResourceBundle;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.server.fop.dto.PnfChart;
import de.cwkuehl.jhh6.server.fop.dto.PnfColumn;
import de.cwkuehl.jhh6.server.fop.dto.PnfPattern;
import de.cwkuehl.jhh6.server.fop.dto.PnfTrend;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Bounds;
import javafx.print.PrinterJob;
import javafx.scene.Parent;
import javafx.scene.control.ContextMenu;
import javafx.scene.control.MenuItem;
import javafx.scene.control.ScrollPane;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Ellipse;
import javafx.scene.shape.Line;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;

/**
 * Diese Klasse ermöglicht Zusatz-Funktionen für einen JPanel.
 * <p>
 * Erstellt am 15.02.2015.
 */
public class ChartPane {

    /**
     * Initialisieren des Chart-Panels mit Hinzufügen einen Kontextmenüs.
     * @param p Zu erweiterndes Panel.
     */
    public static void initChart0(final Pane p) {

        if (p == null) {
            return;
        }
        p.getProperties().put("xg", 11);
        p.getProperties().put("yg", 11);
        p.setStyle("-fx-background-color: white;");

        final ResourceBundle b = Global.getBundle();
        final ContextMenu contextMenu = new ContextMenu();
        MenuItem item = new MenuItem(b.getString("menu.chart.print"));
        item.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                printComponenet();
            }

            public void printComponenet() {

                // System.out.println("Drucken...");
                PrinterJob job = PrinterJob.createPrinterJob();
                if (job != null) {
                    job.getJobSettings().setJobName(b.getString("menu.chart.print"));
                    if (job.showPrintDialog(null)) {
                        boolean printed = job.printPage(p);
                        if (printed) {
                            job.endJob();
                        }
                    }
                }
            }
        });
        contextMenu.getItems().add(item);

        item = new MenuItem(b.getString("menu.chart.sizefit"));
        item.setOnAction(new ChartEventHandler(p, 0, 0));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizep5"));
        item.setOnAction(new ChartEventHandler(p, 5, 5));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizep3"));
        item.setOnAction(new ChartEventHandler(p, 3, 3));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizep1"));
        item.setOnAction(new ChartEventHandler(p, 1, 1));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.widthp1"));
        item.setOnAction(new ChartEventHandler(p, 1, 0));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.heightp1"));
        item.setOnAction(new ChartEventHandler(p, 0, 1));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.heightm1"));
        item.setOnAction(new ChartEventHandler(p, 0, -1));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.widthm1"));
        item.setOnAction(new ChartEventHandler(p, -1, 0));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizem1"));
        item.setOnAction(new ChartEventHandler(p, -1, -1));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizem3"));
        item.setOnAction(new ChartEventHandler(p, -3, -3));
        contextMenu.getItems().add(item);
        item = new MenuItem(b.getString("menu.chart.sizem5"));
        item.setOnAction(new ChartEventHandler(p, -5, -5));
        contextMenu.getItems().add(item);

        p.getProperties().put("menu", contextMenu);
        p.setOnMouseClicked(e -> {
            ContextMenu menu = (ContextMenu) p.getProperties().get("menu");
            if (menu != null) {
                menu.show(p, e.getScreenX(), e.getScreenY());
            }
        });
    }

    private static class ChartEventHandler implements EventHandler<ActionEvent> {

        private final Pane p;
        private final int  x;
        private final int  y;

        public ChartEventHandler(final Pane p, int x, int y) {

            this.p = p;
            this.x = x;
            this.y = y;
        }

        @Override
        public void handle(ActionEvent event) {
            GroesseAendern();
        }

        private void GroesseAendern() {

            int xg = Math.max((int) p.getProperties().get("xg") + x, 3);
            int yg = Math.max((int) p.getProperties().get("yg") + y, 3);
            PnfChart mc = (PnfChart) p.getProperties().get("mc");
            if (x == 0 && y == 0) {
                Parent p0 = p.getParent();
                while (p0 != null && !(p0 instanceof ScrollPane)) {
                    p0 = p0.getParent();
                }
                ScrollPane ap = p0 != null && p0 instanceof ScrollPane ? (ScrollPane) p0 : null;
                Bounds bounds = ap == null ? null : ap.getViewportBounds();
                double w = bounds == null ? p.getWidth() : bounds.getWidth();
                double h = bounds == null ? p.getHeight() : bounds.getHeight();
                Dimension d = mc.computeDimension((int) w, (int) h);
                xg = (int) d.getWidth();
                yg = (int) d.getHeight();
            }
            p.getProperties().put("xg", xg);
            p.getProperties().put("yg", yg);
            mc.getDimension(xg, yg);
            paintChart(mc, p);
        }
    }

    public static Dimension getBounds(Pane p) {

        Parent p0 = p.getParent();
        while (p0 != null && !(p0 instanceof ScrollPane)) {
            p0 = p0.getParent();
        }
        ScrollPane ap = p0 != null && p0 instanceof ScrollPane ? (ScrollPane) p0 : null;
        Bounds bounds = ap == null ? null : ap.getViewportBounds();
        double w = bounds == null ? p.getWidth() : bounds.getWidth();
        double h = bounds == null ? p.getHeight() : bounds.getHeight();
        return new Dimension((int) w, (int) h);
    }

    /**
     * 2. Initialisieren des Chart-Panels mit einem Point & Figure-Chart.
     * @param p Zu erweiterndes Panel.
     * @param c Betroffenes Point & Figure-Chart.
     */
    public static void initChart1(final Pane p, final PnfChart c) {

        if (p == null || c == null) {
            return;
        }
        p.getProperties().put("mc", c);
        // int xg = (int) p.getProperties().get("xg");
        // int yg = (int) p.getProperties().get("yg");
        // c.getDimension(xg, yg);
        Dimension d0 = getBounds(p);
        Dimension d = c.computeDimension((int) d0.getWidth(), (int) d0.getHeight());
        p.getProperties().put("xg", (int) d.getWidth());
        p.getProperties().put("yg", (int) d.getHeight());
        paintChart(c, p);
    }

    private static void drawString(final Pane p, double x, double y, String str, Font font, Color color) {

        Text letter = new Text(x, y, str); // Position links unten
        letter.setFont(font);
        letter.setFill(color);
        p.getChildren().add(letter);
    }

    private static void drawLine(final Pane p, double x, double y, double x2, double y2, Color color, double stroke) {

        Line l = new Line(x, y, x2, y2);
        l.setStroke(color);
        l.setStrokeWidth(stroke);
        p.getChildren().add(l);
    }

    /**
     * Zeichnen eines Point & Figure-Charts.
     */
    private static void paintChart(final PnfChart c, final Pane p) {

        final double xgroesse = c.getXgroesse();
        final double ygroesse = c.getYgroesse();
        final double max = c.getPosmax();
        final double xoffset = xgroesse * 1.5;
        final double yoffset = ygroesse * 4.0;
        final double xanzahl = c.getSaeulen().size();
        final double yanzahl = c.getWerte().size();
        double b = 0;
        double h = 0;
        double x = 0;
        double y = 0;
        Font fontx = Font.font("TimesRoman", FontWeight.NORMAL, ygroesse + 1.5);
        Font fontplain = Font.font("TimesRoman", FontWeight.NORMAL, ygroesse);
        Font fontbold = Font.font("TimesRoman", FontWeight.BOLD, ygroesse);

        p.getChildren().clear();

        double stroke = 1.2;
        Color color = Color.BLACK;
        Font font = fontplain;

        // Säulen
        drawString(p, xoffset, ygroesse * 2, c.getBezeichnung(), font, color);
        drawString(p, xoffset, ygroesse * 3.3, c.getBezeichnung2(), font, color);
        b = xoffset + xgroesse;
        h = 0;
        double xd = xgroesse / 2;
        double yd = ygroesse / 2;
        for (PnfColumn s : c.getSaeulen()) {
            h = s.getYpos();
            char[] array = s.getChars();
            for (char xo : array) {
                x = b;
                y = (max - h + 1) * ygroesse + yoffset;
                if (xo == 'O') {
                    color = Color.RED;
                    Ellipse e = new Ellipse(x + xd, y - xd, xd - 1, yd - 1);
                    e.setFill(null);
                    e.setStroke(color);
                    e.setStrokeWidth(stroke);
                    p.getChildren().add(e);
                    // g.drawOval(x, y, xgroesse - 2, ygroesse - 2);
                } else if (xo == 'X') {
                    color = Color.GREEN;
                    drawString(p, x + 1, y, "X", fontx, color);
                    // g.drawLine(x, y, x + xgroesse - 2, y + ygroesse - 2);
                    // g.drawLine(x, y + ygroesse - 2, x + xgroesse - 2, y);
                } else {
                    color = Color.BLACK;
                    drawString(p, x + 2, y - 1, String.valueOf(xo), font, color);
                }
                h += 1;
            }
            b += xgroesse;
        }

        // Werte schreiben
        stroke = 0.5;
        color = Color.LIGHTGRAY;
        x = xoffset + (xanzahl + 2) * xgroesse;
        y = yoffset + c.getWerte().size() * ygroesse;
        double aktkurs = c.getKurs();
        int yakt = -1;
        if (Global.compDouble4(aktkurs, 0) > 0) {
            double d = c.getMax() + 1;
            for (int i = 0; i < yanzahl; i++) {
                if (Global.compDouble4(c.getWerte().get(i), d) < 0
                        && Global.compDouble4(c.getWerte().get(i), aktkurs) > 0) {
                    d = c.getWerte().get(i);
                    yakt = i;
                }
            }
        }
        for (int i = 0; i < yanzahl + 1; i++) {
            if (i < yanzahl) {
                if (i == yakt) {
                    font = fontbold;
                    color = Color.BLACK;
                    drawString(p, x + 5, y, Global.dblStr(Global.round(aktkurs)), font, color);
                    font = fontplain;
                    color = Color.LIGHTGRAY;
                } else {
                    drawString(p, x + 5, y, Global.dblStr(Global.round(c.getWerte().get(i))), font, color);
                }
            }
            drawLine(p, xoffset, y, x, y, color, stroke); // waagerechte Linien
            y -= ygroesse;
        }

        // Datumswerte schreiben
        x = xoffset;
        y = yoffset + yanzahl * ygroesse;
        for (int i = 0; i < xanzahl + 3; i++) {
            drawLine(p, x, yoffset, x, y, color, stroke); // senkrechte Linien
            if (i % 6 == 0 && i < xanzahl && c.getSaeulen().get(i).getDatum() != null) {
                drawString(p, x + xgroesse, y + ygroesse * 1.5, Global.dateTimeStringForm(c.getSaeulen().get(i)
                        .getDatum()), font, color);
            }
            x += xgroesse;
        }

        // Trendlinien
        stroke = 2;
        for (PnfTrend t : c.getTrends()) {
            x = (t.getXpos() + 1) * xgroesse + xoffset;
            y = (max - t.getYpos()) * ygroesse + yoffset;
            b = t.getLaenge() * xgroesse;
            if (t.getBoxtyp() == 0) {
                b += xgroesse;
                h = 0;
                color = Color.RED;
            } else if (t.getBoxtyp() == 1) {
                h = -t.getLaenge() * ygroesse;
                color = Color.BLUE;
            } else {
                h = t.getLaenge() * ygroesse;
                y += ygroesse;
                color = Color.BLUE;
            }
            drawLine(p, x, y, x + b, y + h, color, stroke);
        }

        // Muster
        stroke = 2;
        color = Color.DARKVIOLET;
        for (PnfPattern pa : c.getPattern()) {
            x = (pa.getXpos() + 1) * xgroesse + xoffset;
            y = (max - pa.getYpos()) * ygroesse + yoffset;
            drawString(p, x, y, pa.getBezeichnung(), font, color);
        }

    }
}

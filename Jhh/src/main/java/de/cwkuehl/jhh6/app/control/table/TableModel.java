package de.cwkuehl.jhh6.app.control.table;

import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.HashMap;
import java.util.ResourceBundle;
import java.util.StringTokenizer;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

import com.sun.javafx.scene.control.ControlAcceleratorSupport;
import com.sun.javafx.scene.control.skin.TableColumnHeader;

import de.cwkuehl.jhh6.api.global.Constant;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.app.base.Werkzeug;
import javafx.beans.property.SimpleObjectProperty;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.print.PrinterJob;
import javafx.scene.control.ContextMenu;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SelectionMode;
import javafx.scene.control.SeparatorMenuItem;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableColumn.CellDataFeatures;
import javafx.scene.control.TableColumnBase;
import javafx.scene.control.TablePosition;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyCodeCombination;
import javafx.scene.input.KeyCombination;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.stage.Window;
import javafx.util.Callback;

/**
 * TableModel für JTabelle.
 * <p>
 * Erstellt am 21.04.2007.
 */
@SuppressWarnings({ "restriction" })
public final class TableModel implements EventHandler<ActionEvent> {

    /** zugehörige TableView-Instanz. */
    @SuppressWarnings("rawtypes")
    private TableView                                  tv                      = null;
    /** Anzahl der Zeilen. */
    private int                                        anzahlZeilen            = 0;
    /** Anzahl der Spalten. */
    private int                                        anzahlSpalten           = 0;
    /** Zeilen. */
    private Zeile[]                                    zeilen                  = null;
    /** Spalten. */
    private Spalte[]                                   spalten                 = null;
    /** selektierte Spalten. */
    private boolean[]                                  selektiert              = null;
    /** Breite der Spalte mit den Zeilennummern. */
    private int                                        breite0                 = 40;
    /** gemeinsame Höhe aller Zeilen. */
    private int                                        hoehe0                  = 30;
    /** Position der Unterteilung (x1000). */
    private int                                        divider                 = 300;

    /** Notiz zur Tabelle. */
    private String                                     notiz                   = null;

    private MenuItem                                   zeilenMenuItem          = null;
    private MenuItem                                   zeilenEndeMenuItem      = null;
    private MenuItem                                   zeilenLoeschenMenuItem  = null;
    private MenuItem                                   spaltenMenuItem         = null;
    private MenuItem                                   spaltenEndeMenuItem     = null;
    private MenuItem                                   spaltenLoeschenMenuItem = null;
    private MenuItem                                   druckenMenuItem         = null;
    private MenuItem                                   fettMenuItem            = null;
    private MenuItem                                   normalMenuItem          = null;
    private MenuItem                                   linksMenuItem           = null;
    private MenuItem                                   mitteMenuItem           = null;
    private MenuItem                                   rechtsMenuItem          = null;
    private MenuItem                                   copyMenuItem            = null;

    private ObservableList<ObservableList<CellInhalt>> data                    = null;

    protected class Zeile {

        int hoehe = 20;

        /**
         * @return the hoehe
         */
        public int getHoehe() {
            return hoehe;
        }

        /**
         * @param hoehe the hoehe to set
         */
        public void setHoehe(int hoehe) {
            this.hoehe = hoehe;
        }
    }

    private class Spalte {

        int breite = 75;

        /**
         * @return the breite
         */
        public int getBreite() {
            return breite;
        }

        /**
         * @param breite the breite to set
         */
        public void setBreite(int breite) {
            this.breite = breite;
        }
    }

    /**
     * Standard-Konstruktor.
     */
    public TableModel(@SuppressWarnings("rawtypes") TableView tv) {

        this.tv = tv;
        init0(1, 1);
    }

    /**
     * Initialisierung der Zeilen, Spalten und Zellen.
     * @param z neue Anzahl Zeilen.
     * @param s neue Anzahl Spalten.
     */
    public void init0(final int z, final int s) {

        anzahlZeilen = z;
        anzahlSpalten = s;
        zeilen = new Zeile[anzahlZeilen];
        spalten = new Spalte[anzahlSpalten];
        data = FXCollections.observableArrayList();
        for (int i = 1; i <= anzahlZeilen; i++) {
            ObservableList<CellInhalt> row = FXCollections.observableArrayList();
            CellInhalt ci = new CellInhalt();
            ci.setWert(Global.format("{0,number,000}", i));
            row.add(ci);
            data.add(row);
            for (int j = 1; j <= anzahlSpalten; j++) {
                ci = new CellInhalt();
                row.add(ci);
            }
        }
        for (int i = 0; i < anzahlZeilen; i++) {
            zeilen[i] = new Zeile();
        }
        for (int i = 0; i < anzahlSpalten; i++) {
            spalten[i] = new Spalte();
        }
    }

    /**
     * Returns the number of rows in this data table.
     * @return the number of rows in the model
     */
    public int getRowCount() {
        return anzahlZeilen;
    }

    /**
     * Returns the number of columns in this data table.
     * @return the number of columns in the model
     */
    public int getColumnCount() {
        return anzahlSpalten;
    }

    /**
     * @param zeile Zeilennummer in JTable.
     * @return Zeilennummer in inhalt-Array.
     */
    private int z(int zeile) {
        return zeile;
    }

    /**
     * @param spalte Spaltennummer in JTable.
     * @return Spaltennummer in inhalt-Array.
     */
    private int s(int spalte) {
        return spalte + 1;
    }

    public CellInhalt getCellInhalt(int rowIndex, int columnIndex, boolean notNull) {

        if (data != null && z(rowIndex) >= 0 && z(rowIndex) < anzahlZeilen && s(columnIndex) > 0 && s(
                columnIndex) <= anzahlSpalten) {
            CellInhalt ci = data.get(z(rowIndex)).get(s(columnIndex));
            // if (ci == null && notNull) {
            // ci = new CellInhalt();
            // data.get(z(rowIndex)).set(s(columnIndex), ci);
            // }
            return ci;
        }
        return null;
    }

    public void fireTableStructureChanged() {
        initColumns();
    }

    public void initContextMenu(final Window w) {

        if (tv == null || !tv.isEditable()) {
            return;
        }
        final ResourceBundle b = Global.getBundle();
        zeilenMenuItem = new MenuItem(b.getString("menu.table.addrow"));
        zeilenMenuItem.setOnAction(this);
        zeilenEndeMenuItem = new MenuItem(b.getString("menu.table.addrow2"));
        zeilenEndeMenuItem.setOnAction(this);
        zeilenLoeschenMenuItem = new MenuItem(b.getString("menu.table.delrow"));
        zeilenLoeschenMenuItem.setOnAction(this);
        spaltenMenuItem = new MenuItem(b.getString("menu.table.addcol"));
        spaltenMenuItem.setOnAction(this);
        spaltenEndeMenuItem = new MenuItem(b.getString("menu.table.addcol2"));
        spaltenEndeMenuItem.setOnAction(this);
        spaltenLoeschenMenuItem = new MenuItem(b.getString("menu.table.delcol"));
        spaltenLoeschenMenuItem.setOnAction(this);
        Menu layoutMenu = new Menu(b.getString("menu.table.format"));
        normalMenuItem = new MenuItem(b.getString("menu.table.normal"));
        normalMenuItem.setOnAction(this);
        fettMenuItem = new MenuItem(b.getString("menu.table.bold"));
        fettMenuItem.setOnAction(this);
        linksMenuItem = new MenuItem(b.getString("menu.table.left"));
        linksMenuItem.setOnAction(this);
        mitteMenuItem = new MenuItem(b.getString("menu.table.center"));
        mitteMenuItem.setOnAction(this);
        rechtsMenuItem = new MenuItem(b.getString("menu.table.right"));
        rechtsMenuItem.setOnAction(this);
        layoutMenu.getItems().addAll(normalMenuItem, fettMenuItem, linksMenuItem, mitteMenuItem, rechtsMenuItem);
        druckenMenuItem = new MenuItem(b.getString("menu.table.print"));
        druckenMenuItem.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent t) {
                PrinterJob printerJob = PrinterJob.createPrinterJob();
                if (printerJob.showPrintDialog(w) && printerJob.printPage(tv))
                    printerJob.endJob();
            }
        });
        copyMenuItem = new MenuItem(b.getString("menu.table.copy"));
        copyMenuItem.setOnAction(this);
        copyMenuItem.setAccelerator(new KeyCodeCombination(KeyCode.getKeyCode("C"), KeyCombination.CONTROL_DOWN));
        ContextMenu menu = new ContextMenu(zeilenMenuItem, zeilenEndeMenuItem, zeilenLoeschenMenuItem,
                new SeparatorMenuItem(), spaltenMenuItem, spaltenEndeMenuItem, spaltenLoeschenMenuItem,
                new SeparatorMenuItem(), layoutMenu, druckenMenuItem, copyMenuItem);
        tv.setContextMenu(menu);
        ControlAcceleratorSupport.addAcceleratorsIntoScene(menu.getItems(), tv);
    }

    /**
     * Initialisierung des JTables.
     */
    @SuppressWarnings({ "unchecked" })
    private void initColumns() {

        if (tv == null) {
            return;
        }
        tv.getSelectionModel().setCellSelectionEnabled(true);
        tv.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE);
        tv.getColumns().clear();
        TableColumn<ObservableList<CellInhalt>, CellInhalt> c0 = new TableColumn<>(" ");
        c0.setCellValueFactory(
                new Callback<CellDataFeatures<ObservableList<CellInhalt>, CellInhalt>, ObservableValue<CellInhalt>>() {
                    public ObservableValue<CellInhalt> call(
                            CellDataFeatures<ObservableList<CellInhalt>, CellInhalt> param) {
                        return new SimpleObjectProperty<CellInhalt>(param.getValue().get(0));
                    }
                });
        Comparator<CellInhalt> comp = new Comparator<CellInhalt>() {

            @Override
            public int compare(CellInhalt o1, CellInhalt o2) {
                return Global.compString2(o1.getWert(), o2.getWert());
            }
        };
        c0.setComparator(comp);
        c0.setCellFactory(
                new Callback<TableColumn<ObservableList<CellInhalt>, CellInhalt>, TableCell<ObservableList<CellInhalt>, CellInhalt>>() {

                    @Override
                    public TableCell<ObservableList<CellInhalt>, CellInhalt> call(
                            TableColumn<ObservableList<CellInhalt>, CellInhalt> param) {
                        return new TableCell<ObservableList<CellInhalt>, CellInhalt>() {
                            @Override
                            protected void updateItem(CellInhalt item, boolean empty) {
                                super.updateItem(item, empty);

                                if (item == null || empty) {
                                    setText(null);
                                    setStyle("");
                                } else {
                                    setText(item.getWert());
                                    // if (item.equals("0")) {
                                    // setTextFill(Color.CHOCOLATE);
                                    // setStyle("-fx-background-color: yellow");
                                    // } else {
                                    // setTextFill(Color.BLACK);
                                    // setStyle("");
                                    // }
                                }
                            }
                        };
                    }
                });
        c0.setPrefWidth(breite0);
        c0.setEditable(false);
        tv.getColumns().add(c0);
        tv.addEventFilter(MouseEvent.MOUSE_CLICKED, event -> {
            if (event.getButton() == MouseButton.SECONDARY && event.getTarget() instanceof TableColumnHeader) {
                event.consume();
                TableColumnHeader h = (TableColumnHeader) event.getTarget();
                @SuppressWarnings({ "rawtypes" })
                TableColumnBase c = h.getTableColumn();
                int p = getColumnIndex(c.getText());
                if (p < 0) {
                    tv.getSelectionModel().selectAll();
                } else {
                    tv.getSelectionModel().clearSelection();
                    for (int i = 0; i < anzahlZeilen; i++) {
                        tv.getSelectionModel().select(i, c);
                    }
                }
            }
        });

        // Callback<TableColumn<ObservableList<CellInhalt>, String>, TableCell<ObservableList<CellInhalt>, String>>
        // cellFctory = TextFieldTableCell
        // .<ObservableList<CellInhalt>, String> forTableColumn(new DefaultStringConverter());
        Callback<TableColumn<ObservableList<CellInhalt>, CellInhalt>, TableCell<ObservableList<CellInhalt>, CellInhalt>> cellFctory = new Callback<TableColumn<ObservableList<CellInhalt>, CellInhalt>, TableCell<ObservableList<CellInhalt>, CellInhalt>>() {

            @Override
            public TableCell<ObservableList<CellInhalt>, CellInhalt> call(
                    TableColumn<ObservableList<CellInhalt>, CellInhalt> param) {
                TableCell<ObservableList<CellInhalt>, CellInhalt> cell = new TableCell<ObservableList<CellInhalt>, CellInhalt>() {

                    private TextField textField;

                    @Override
                    public void startEdit() {
                        // if (!isEmpty()) {
                        super.startEdit();
                        if (isEditing()) {
                            createTextField();
                            setText(null);
                            setGraphic(textField);
                            textField.selectAll();
                            textField.requestFocus();
                        }
                        // }
                    }

                    @Override
                    public void cancelEdit() {
                        super.cancelEdit();

                        setText(getItem().getWert());
                        setGraphic(null);
                    }

                    @Override
                    public void updateItem(CellInhalt item, boolean empty) {
                        super.updateItem(item, empty);

                        if (getItem() == null) {
                            setText(null);
                            setGraphic(null);
                        } else if (empty) {
                            setText(getItem().getWert());
                            setGraphic(null);
                        } else {
                            if (isEditing()) {
                                if (textField != null) {
                                    textField.setText(getItem().getWert());
                                    // setGraphic(null);
                                }
                                setText(null);
                                setGraphic(textField);
                            } else {
                                setText(getItem().getWert());
                                char a = getItem().getAusrichtung();
                                StringBuilder sb = new StringBuilder();
                                sb.append("-fx-font-weight:");
                                if (getItem().isFett()) {
                                    sb.append("bold;");
                                } else {
                                    sb.append("normal;");
                                }
                                sb.append("-fx-alignment:");
                                if (a == 'r') {
                                    sb.append("center-right;");
                                } else if (a == 'c') {
                                    sb.append("center;");
                                } else {
                                    sb.append("center-left;");
                                }
                                setStyle(sb.toString());
                                setGraphic(null);
                            }
                        }
                    }

                    private void createTextField() {

                        textField = new TextField(getItem().getFormel());
                        textField.setMinWidth(this.getWidth() - this.getGraphicTextGap() * 2);
                        textField.setOnAction((e) -> {
                            CellInhalt ci = getItem();
                            String f = textField.getText();
                            ci.setFormel(f);
                            TableModel.this.aktualisierenFormeln();
                            commitEdit(ci);
                            tv.refresh();
                        });
                        // textField.focusedProperty()
                        // .addListener(
                        // (ObservableValue<? extends Boolean> observable, Boolean oldValue,
                        // Boolean newValue) -> {
                        // if (!newValue) {
                        // System.out.println("Commiting " + textField.getText());
                        // commitEdit(textField.getText());
                        // }
                        // });
                    }

                };
                return cell;
            }
        };

        int i = 0;
        for (Spalte s : spalten) {
            if (s == null) {
                s = new Spalte();
                s.setBreite(30);
            }
            TableColumn<ObservableList<CellInhalt>, CellInhalt> c = new TableColumn<>(getColumnNameA(i));
            c.setPrefWidth(s.getBreite());
            c.setEditable(true);
            final int j = i;
            c.setCellValueFactory(
                    new Callback<CellDataFeatures<ObservableList<CellInhalt>, CellInhalt>, ObservableValue<CellInhalt>>() {
                        public ObservableValue<CellInhalt> call(
                                CellDataFeatures<ObservableList<CellInhalt>, CellInhalt> param) {
                            return new SimpleObjectProperty<CellInhalt>(param.getValue().get(j + 1));
                        }
                    });
            c.setCellFactory(cellFctory);
            c.setComparator(comp);
            tv.getColumns().add(c);
            i++;
        }
        if (zeilen != null && zeilen.length > 0) {
            int h = zeilen[0].getHoehe();
            tv.setFixedCellSize(Math.max(h, hoehe0));
        }
        tv.setItems(data);
    }

    /**
     * Tabelleninhalt als XML-Document schreiben.
     * @return Document als String.
     */
    public String writeXmlDocument() {

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        Document document = null;
        StringWriter sw = null;
        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            Element root = null;
            Element el1 = null;
            Element el2 = null;
            int i = 0, j = 0;
            document = builder.newDocument();

            root = document.createElement("tabelle");
            document.appendChild(root);
            root.setAttribute("spalten", "" + anzahlSpalten);
            root.setAttribute("zeilen", "" + anzahlZeilen);
            @SuppressWarnings("rawtypes")
            TableColumn c0 = (TableColumn) tv.getColumns().get(0);
            root.setAttribute("breite0", "" + ((int) c0.getWidth()));
            root.setAttribute("hoehe0", "" + ((int) tv.getFixedCellSize()));
            root.setAttribute("teiler", "" + divider);
            for (i = 0; i < anzahlZeilen; i++) {
                for (j = 0; j < anzahlSpalten; j++) {
                    CellInhalt ci = getCellInhalt(i, j, true);
                    if (!Global.nes(ci.getFormel()) || ci.isFett() || ci.getAusrichtung() != 'l') {
                        el1 = document.createElement("zelle");
                        el1.setAttribute("x", "" + j);
                        el1.setAttribute("y", "" + i);
                        el2 = document.createElement("formel");
                        el2.appendChild(document.createTextNode(ci.getFormel()));
                        el1.appendChild(el2);
                        if (ci.isFett() || ci.getAusrichtung() != 'l') {
                            el2 = document.createElement("format");
                            if (ci.isFett()) {
                                el2.setAttribute("fett", "true");
                            }
                            if (ci.getAusrichtung() != 'l') {
                                el2.setAttribute("ausrichtung", String.valueOf(ci.getAusrichtung()));
                            }
                            el1.appendChild(el2);
                        }
                        root.appendChild(el1);
                    }
                }
            }
            for (i = 0; i < anzahlZeilen; i++) {
                el1 = document.createElement("zeile");
                el1.setAttribute("nr", "" + i);
                el1.setAttribute("hoehe", "" + hoehe0);
                root.appendChild(el1);
            }
            for (j = 0; j < anzahlSpalten; j++) {
                @SuppressWarnings("rawtypes")
                TableColumn c = (TableColumn) tv.getColumns().get(j + 1);
                el1 = document.createElement("spalte");
                el1.setAttribute("nr", "" + j);
                el1.setAttribute("breite", "" + ((int) c.getWidth()));
                root.appendChild(el1);
            }
            if (!Global.nes(notiz)) {
                el1 = document.createElement("notiz");
                el1.appendChild(document.createTextNode(notiz));
                root.appendChild(el1);
            }

            // Dokument als String speichern
            TransformerFactory tranFactory = TransformerFactory.newInstance();
            Transformer aTransformer = tranFactory.newTransformer();
            Source src = new DOMSource(document);
            sw = new StringWriter();
            Result dest = new StreamResult(sw);
            aTransformer.transform(src, dest);
        } catch (ParserConfigurationException pce) {
            // Parser with specified options can't be built
            pce.printStackTrace();
        } catch (TransformerConfigurationException e) {
            e.printStackTrace();
        } catch (TransformerException e) {
            e.printStackTrace();
        }
        if (sw == null) {
            return null;
        }
        return sw.toString();
    }

    /**
     * Tabelleninhalt aus XML-Document lesen.
     * @param xmlDocument XML-Document als String.
     */
    public void readXmlDocument(String xmlDocument) {

        try {
            if (xmlDocument == null || !xmlDocument.startsWith("<?xml")) {
                // Reine Text-Notiz.
                notiz = xmlDocument;
                init0(1, 1);
                // fireTableStructureChanged(tv);
                return;
            }
            notiz = "";
            XMLReader xr = XMLReaderFactory.createXMLReader();
            DefaultHandler handler = new DefaultHandler() {
                int zeile  = 0;
                int spalte = 0;
                int art    = 0;

                @Override
                public void startDocument() {
                    // System.out.println("Start document");
                }

                @Override
                public void endDocument() {
                    // fireTableStructureChanged();
                }

                @Override
                public void startElement(String uri, String name, String qName, Attributes atts) {

                    if ("".equals(uri)) {
                        if ("zelle".equals(qName) && atts != null && atts.getLength() >= 2) {
                            spalte = Global.strInt(atts.getValue("x"));
                            zeile = Global.strInt(atts.getValue("y"));
                            // inhalt[zeile][spalte] = new CellInhalt();
                            art = 0;
                        } else if ("formel".equals(qName)) {
                            art = 1;
                        } else if ("format".equals(qName)) {
                            art = 2;
                            if ("true".equalsIgnoreCase(atts.getValue("fett"))) {
                                getCellInhalt(zeile, spalte, true).setFett(true);
                            }
                            String ausrichtung = atts.getValue("ausrichtung");
                            if (!Global.nes(ausrichtung)) {
                                getCellInhalt(zeile, spalte, true).setAusrichtung(ausrichtung.charAt(0));
                            }
                        } else if ("zeile".equals(qName)) {
                            int nr = Global.strInt(atts.getValue("nr"));
                            if (zeilen[nr] == null) {
                                zeilen[nr] = new Zeile();
                            }
                            zeilen[nr].setHoehe(Global.strInt(atts.getValue("hoehe")));
                        } else if ("spalte".equals(qName)) {
                            int nr = Global.strInt(atts.getValue("nr"));
                            if (spalten[nr] == null) {
                                spalten[nr] = new Spalte();
                            }
                            spalten[nr].setBreite(Global.strInt(atts.getValue("breite")));
                        } else if ("tabelle".equals(qName) && atts != null && atts.getLength() >= 2) {
                            init0(Global.strInt(atts.getValue("zeilen")), Global.strInt(atts.getValue("spalten")));
                            if (Global.strInt(atts.getValue("breite0")) > 0) {
                                breite0 = Global.strInt(atts.getValue("breite0"));
                            }
                            if (Global.strInt(atts.getValue("hoehe0")) > 0) {
                                hoehe0 = Global.strInt(atts.getValue("hoehe0"));
                            }
                            if (Global.strInt(atts.getValue("teiler")) > 0) {
                                divider = Global.strInt(atts.getValue("teiler"));
                            }
                        } else if ("notiz".equals(qName)) {
                            art = 3;
                        }
                    }
                }

                @Override
                public void endElement(String uri, String name, String qName) {
                    // if ("".equals(uri))
                    // System.out.println("End element: " + qName);
                    // else
                    // System.out.println("End element: {" + uri + "}" + name);
                }

                @Override
                public void characters(char ch[], int start, int length) {
                    String str = new String(ch, start, length);
                    if (art == 1) {
                        CellInhalt ci = getCellInhalt(zeile, spalte, true);
                        if (ci != null && !Global.nes(str)) {
                            if (ci.getFormel() != null) {
                                str = ci.getFormel() + str;
                            }
                            ci.setFormel(str);
                        }
                    } else if (art == 3) {
                        if (!Global.nes(str)) {
                            str = notiz + str;
                        }
                        notiz = str;
                    }
                }

            };
            xr.setContentHandler(handler);
            xr.setErrorHandler(handler);
            StringReader r = new StringReader(xmlDocument);
            xr.parse(new InputSource(r));
            try {
                aktualisierenFormeln();
            } catch (Exception ex) {
                Werkzeug.showError(ex.getMessage());
            }
            // } catch (SAXException sxe) {
            // // Error generated during parsing
            // Exception x = sxe;
            // if (sxe.getException() != null)
            // x = sxe.getException();
            // x.printStackTrace();
            // // } catch (ParserConfigurationException pce) {
            // // // Parser with specified options can't be built
            // // pce.printStackTrace();
            // } catch (IOException ioe) {
            // // I/O error
            // ioe.printStackTrace();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    /**
     * Setzen der Höhe einer Reihe.
     * @param row Reihe.
     * @param rowHeight Reihenhöhe.
     */
    public void setRowHeight(int row, int rowHeight) {

        if (zeilen[row] != null) {
            zeilen[row].setHoehe(rowHeight);
        }
        // jTable.setRowHeight(row, rowHeight);
    }

    /**
     * Einfügen von Zeilen.
     * @param row Zeile.
     * @param count Anzahl.
     */
    @SuppressWarnings("unchecked")
    public void insertRows(int row, int count) {
        neueZeilenSpalten(row, 0, count, 0);
        tv.setItems(data);
    }

    /**
     * Einfügen von Spalten.
     * @param column Spalte.
     * @param count Anzahl.
     */
    public void insertColumns(int column, int count) {
        neueZeilenSpalten(0, column, 0, count);
        initColumns();
    }

    private boolean isIn(int row, int rcount, int i) {

        if (rcount < 0) {
            if (i < row || i >= row - rcount) {
                return true;
            }
            return false;
        }
        return true;
    }

    /**
     * Einfügen oder Löschen von Zeilen und Spalten.
     * @param row ab Zeile.
     * @param column ab Spalte.
     * @param rcount Anzahl Zeilen, die eingefügt (positiv) oder gelöscht (negativ) werden.
     * @param ccount Anzahl Spalten, die eingefügt (positiv) oder gelöscht (negativ) werden.
     */
    private void neueZeilenSpalten(int row, int column, int rcount, int ccount) {

        int anzahlZeilen2 = anzahlZeilen;
        int anzahlSpalten2 = anzahlSpalten;
        Zeile[] zeilen2 = zeilen;
        Spalte[] spalten2 = spalten;
        ObservableList<ObservableList<CellInhalt>> data2 = data;
        int i = 0;
        int j = 0;
        int idiff = 0;
        int jdiff = 0;
        init0(anzahlZeilen + rcount, anzahlSpalten + ccount);
        for (i = 0; i < anzahlZeilen2; i++) {
            jdiff = 0;
            if (i >= row) {
                idiff = rcount;
            }
            if (isIn(row, rcount, i)) {
                for (j = 0; j < anzahlSpalten2; j++) {
                    if (j >= column) {
                        jdiff = ccount;
                    }
                    if (isIn(column, ccount, j) && i + idiff >= 0 && i + idiff < anzahlZeilen && j + jdiff >= 0 && j
                            + jdiff < anzahlSpalten) {
                        // inhalt[i + idiff][j + jdiff] = inhalt2[i][j];
                        data.get(i + idiff).set(j + jdiff + 1, data2.get(i).get(j + 1));
                    }
                }
                if (i + idiff >= 0 && i + idiff < anzahlZeilen) {
                    zeilen[i + idiff] = zeilen2[i];
                }
            }
        }
        jdiff = 0;
        for (j = 0; j < anzahlSpalten2; j++) {
            if (j + 1 >= column) {
                jdiff = ccount;
            }
            if (isIn(column, ccount, j) && j + jdiff >= 0 && j + jdiff < anzahlSpalten) {
                spalten[j + jdiff] = spalten2[j];
            }
        }
        if (ccount > 0) {
            for (j = 0; j < anzahlSpalten; j++) {
                if (spalten[j] == null) {
                    spalten[j] = new Spalte();
                }
            }
        }
    }

    /**
     * @return the notiz
     */
    public String getNotiz() {
        return notiz;
    }

    /**
     * @param notiz the notiz to set
     */
    public void setNotiz(String notiz) {
        this.notiz = notiz;
    }

    /**
     * Setzen ein selektierten Spalten. Wenn dazu true ist, wird die Spaltennummer zusätzlich selektiert. Ansonsten
     * werden alle anderen Spalten deselektiert. Wenn Spaltennummer -1 ist, werden allen Spalten-Selektionen nach dem
     * Schalter dazu gesetzt.
     * @param column Spaltennummer.
     * @param dazu Sollte die Spalte zusätzlich selektiert werden?
     */
    public void setSelektiert(int column, boolean dazu) {
        // headerRenderer.setSelektiert(column, dazu);
    }

    /**
     * Liefert true, wenn Spalte selektiert ist.
     * @param column Spaltennummer.
     * @return Selektion der Spalte.
     */
    public boolean isColumnSelected(int column) {
        return selektiert[column];
    }

    public void kopieren(int row, int column, int rcount, int ccount) {

        StringBuffer sbf = new StringBuffer();
        CellInhalt wert = null;
        for (int i = row; i < row + rcount; i++) {
            for (int j = column; j < column + ccount; j++) {
                wert = getCellInhalt(i, j, true);
                if (wert != null && !Global.nes(wert.getWert())) {
                    sbf.append(wert.getWert());
                }
                if (j < column + ccount - 1) {
                    sbf.append("\t");
                }
            }
            sbf.append("\n");
        }
        StringSelection stsel = new StringSelection(sbf.toString());
        Clipboard cb = Toolkit.getDefaultToolkit().getSystemClipboard();
        cb.setContents(stsel, stsel);

    }

    public void einfuegen(int row, int column, int rcount, int ccount) {

        Clipboard cb = Toolkit.getDefaultToolkit().getSystemClipboard();
        String str = null;
        try {
            str = (String) (cb.getContents(this).getTransferData(DataFlavor.stringFlavor));
        } catch (UnsupportedFlavorException e) {
        } catch (IOException e) {
        }
        if (Global.nes(str)) {
            return;
        }
        StringTokenizer st1 = new StringTokenizer(str, "\n");
        for (int i = 0; st1.hasMoreTokens(); i++) {
            String rowstring = st1.nextToken();
            StringTokenizer st2 = new StringTokenizer(rowstring, "\t");
            for (int j = 0; st2.hasMoreTokens(); j++) {
                // String value = st2.nextToken();
                if ((rcount == 1 || i <= rcount) && (ccount == 1 || j <= ccount)) {
                    // setValueAt(value, row + i, column + j);
                }
            }
        }
        // fireTableDataChanged();
    }

    public void loeschen(int row, int column, int rcount, int ccount) {

        for (int i = 0; i < rcount; i++) {
            for (int j = 0; j < ccount; j++) {
                // setValueAt(null, row + i, column + j);
            }
        }
        // fireTableDataChanged();
    }

    private static String nichtBerechnet = "#null#";

    private void berechneFormel(CellInhalt ci, HashMap<CellInhalt, Dimension> formelMap, int rekursion) {

        CellFormel cf = ci.getZellFormel();
        if (cf == null) {
            ci.setWert(null);
            return;
        }
        String wert = null;
        if (cf.getFunktion().equals("TODAY")) {
            wert = Global.dateString0(LocalDate.now());
            ci.setWert(wert);
            return;
        } else if (cf.getFunktion().equals("NOW")) {
            wert = Global.dateTimeStringForm(LocalDateTime.now());
            ci.setWert(wert);
            return;
        } else if (cf.getFunktion().equals("DAYS")) {
            CellInhalt ci0 = getCellInhalt(cf.getZeile1(), cf.getSpalte1(), false);
            if (ci0 == null)
                ci.setWert(null);
            else {
                LocalDateTime d = Global.strdat(ci0.getWert());
                // TODO toEpochDay verwenden
                ci.setWert(d == null ? null
                        : Global.lngStr(d.atZone(ZoneId.systemDefault()).toInstant().getEpochSecond() / 86400l));
            }
            return;
        }
        double d1 = 0;
        CellInhalt ci1 = null;
        for (int i = cf.getZeile1(); i <= cf.getZeile2(); i++) {
            for (int j = cf.getSpalte1(); j <= cf.getSpalte2(); j++) {
                ci1 = getCellInhalt(i, j, false);
                if (ci1 != null) {
                    if (nichtBerechnet.equals(ci1.getWert())) {
                        if (rekursion > 50) {
                            throw new RuntimeException(Meldungen.M1030());
                        }
                        berechneFormel(ci1, formelMap, rekursion + 1);
                    }
                    if (cf.getFunktion().equals("SUM")) {
                        d1 += Global.strDbl(ci1.getWert());
                    } else if (cf.getFunktion().equals("COUNT")) {
                        if (!Global.nes(ci1.getWert())) {
                            d1++;
                        }
                    }
                }
            }
        }
        ci.setWert(Global.dblStr(d1));
    }

    public void aktualisierenFormeln() {

        CellInhalt ci = null;
        Dimension d = null;
        HashMap<CellInhalt, Dimension> formelMap = new HashMap<CellInhalt, Dimension>();

        for (int i = 0; i < anzahlZeilen; i++) {
            for (int j = 0; j < anzahlSpalten; j++) {
                ci = getCellInhalt(i, j, false);
                if (ci != null && ci.getZellFormel() != null) {
                    formelMap.put(ci, new Dimension(i, j));
                }
            }
        }
        for (CellInhalt inh : formelMap.keySet()) {
            d = formelMap.get(inh);
            ci = getCellInhalt(d.width, d.height, false);
            if (ci != null) {
                ci.setWert(nichtBerechnet);
            }
        }
        for (CellInhalt inh : formelMap.keySet()) {
            d = formelMap.get(inh);
            ci = getCellInhalt(d.width, d.height, false);
            if (ci != null && nichtBerechnet.equals(ci.getWert())) {
                berechneFormel(ci, formelMap, 0);
            }
        }
    }

    public static int getColumnIndex(String columnName) {

        if (Global.excelNes(columnName)) {
            return -1;
        }
        String str = columnName.toUpperCase();
        int column = 0;
        int p = 1;
        for (int i = str.length() - 1; i >= 0; i--) {
            column += ((str.charAt(i) - 'A') % 26 + 1) * p;
            p *= 26;
        }

        return column - 1;
    }

    /**
     * Returns a default name for the column using spreadsheet conventions: A, B, C, ... Z, AA, AB, etc. If
     * <code>column</code> cannot be found, returns an empty string.
     * @param column the column being queried
     * @return a string containing the default name of <code>column</code>
     */
    public static String getColumnNameA(int column) {

        if (column < 0) {
            return " ";
        }
        StringBuffer result = new StringBuffer();
        for (; column >= 0; column = column / 26 - 1) {
            result.insert(0, (char) ((char) (column % 26) + 'A'));
        }
        return result.toString();
    }

    @Override
    public void handle(ActionEvent t) {

        Object s = t.getSource();
        @SuppressWarnings({ "rawtypes", "unchecked" })
        int row1 = ((ObservableList<TablePosition>) tv.getSelectionModel().getSelectedCells()).stream().map(a -> a
                .getRow()).min(Integer::compare).orElse(-1);
        @SuppressWarnings({ "rawtypes", "unchecked" })
        int row2 = ((ObservableList<TablePosition>) tv.getSelectionModel().getSelectedCells()).stream().map(a -> a
                .getRow()).max(Integer::compare).orElse(-1);
        @SuppressWarnings({ "rawtypes", "unchecked" })
        int col1 = ((ObservableList<TablePosition>) tv.getSelectionModel().getSelectedCells()).stream().map(a -> a
                .getColumn()).min(Integer::compare).orElse(-1) - 1;
        @SuppressWarnings({ "rawtypes", "unchecked" })
        int col2 = ((ObservableList<TablePosition>) tv.getSelectionModel().getSelectedCells()).stream().map(a -> a
                .getColumn()).max(Integer::compare).orElse(-1) - 1;
        // nicht die 1. Spalte
        if (col1 < 0) {
            col1 = 0;
        }
        if (col2 < 0) {
            col2 = 0;
        }
        if (row1 < 0) {
            row1 = 0;
        }
        if (row2 < 0) {
            row2 = 0;
        }
        int row = row1;
        int rcount = row2 - row1 + 1;
        int col = col1;
        int ccount = col2 - col1 + 1;
        // System.out.println("row " + row + " col " + col + " rc " + rcount + " cc " + ccount);

        if (s.equals(zeilenMenuItem)) {
            insertRows(row, rcount);
        } else if (s.equals(zeilenEndeMenuItem)) {
            insertRows(anzahlZeilen, rcount);
        } else if (s.equals(zeilenLoeschenMenuItem) && anzahlZeilen - rcount > 0) {
            insertRows(row, -rcount);
        } else if (s.equals(spaltenMenuItem)) {
            insertColumns(col, ccount);
        } else if (s.equals(spaltenEndeMenuItem)) {
            insertColumns(anzahlSpalten + 1, ccount);
        } else if (s.equals(spaltenLoeschenMenuItem) && anzahlSpalten - ccount > 0) {
            insertColumns(col, -ccount);
        } else if (s.equals(normalMenuItem) || s.equals(fettMenuItem) || s.equals(linksMenuItem) || s.equals(
                mitteMenuItem) || s.equals(rechtsMenuItem)) {
            CellInhalt ci = null;
            int j = 0;
            for (int i = row; i < row + rcount; i++) {
                for (j = col; j < col + ccount; j++) {
                    ci = getCellInhalt(i, j, true);
                    if (ci != null) {
                        if (s.equals(normalMenuItem)) {
                            ci.setFett(false);
                        } else if (s.equals(fettMenuItem)) {
                            ci.setFett(true);
                        } else if (s.equals(linksMenuItem)) {
                            ci.setAusrichtung('l');
                        } else if (s.equals(mitteMenuItem)) {
                            ci.setAusrichtung('c');
                        } else if (s.equals(rechtsMenuItem)) {
                            ci.setAusrichtung('r');
                        }
                    }
                }
            }
            tv.refresh();
        } else if (s.equals(copyMenuItem)) {
            // System.out.println("Copy");
            StringBuilder sb = new StringBuilder();
            CellInhalt ci = null;
            int j = 0;
            for (int i = row; i < row + rcount; i++) {
                for (j = col; j < col + ccount; j++) {
                    ci = getCellInhalt(i, j, true);
                    if (j > col)
                        sb.append("\t");
                    sb.append(Global.nn(ci.getWert())); // kein null
                }
                sb.append(Constant.CRLF);
            }
            Toolkit.getDefaultToolkit().getSystemClipboard().setContents(new StringSelection(sb.toString()), null);
        }
    }

    public double getDivider() {
        return divider / 1000.0;
    }

    public void setDivider(double divider) {
        this.divider = (int) (divider * 1000.0);
    }

}

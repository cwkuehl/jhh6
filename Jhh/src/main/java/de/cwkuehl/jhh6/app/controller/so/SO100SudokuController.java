package de.cwkuehl.jhh6.app.controller.so;

import static de.cwkuehl.jhh6.server.service.sudoku.SudokuContext.MAX;

import java.util.ArrayList;
import java.util.List;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.app.Jhh6;
import de.cwkuehl.jhh6.app.base.BaseController;
import de.cwkuehl.jhh6.server.service.sudoku.SudokuContext;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;

/**
 * Controller für Dialog SO100Sudoku.
 */
public class SO100SudokuController extends BaseController<String> {

    @FXML
    private Button          aktuell;

    @FXML
    private Button          rueckgaengig;

    @FXML
    private Button          export;

    @FXML
    private Button          loeschen;

    @FXML
    private Label           sudoku0;

    @FXML
    private TextField       t00;

    @FXML
    private TextField       t01;

    @FXML
    private TextField       t02;

    @FXML
    private TextField       t03;

    @FXML
    private TextField       t04;

    @FXML
    private TextField       t05;

    @FXML
    private TextField       t06;

    @FXML
    private TextField       t07;

    @FXML
    private TextField       t08;

    @FXML
    private TextField       t10;

    @FXML
    private TextField       t11;

    @FXML
    private TextField       t12;

    @FXML
    private TextField       t13;

    @FXML
    private TextField       t14;

    @FXML
    private TextField       t15;

    @FXML
    private TextField       t16;

    @FXML
    private TextField       t17;

    @FXML
    private TextField       t18;

    @FXML
    private TextField       t20;

    @FXML
    private TextField       t21;

    @FXML
    private TextField       t22;

    @FXML
    private TextField       t23;

    @FXML
    private TextField       t24;

    @FXML
    private TextField       t25;

    @FXML
    private TextField       t26;

    @FXML
    private TextField       t27;

    @FXML
    private TextField       t28;

    @FXML
    private TextField       t30;

    @FXML
    private TextField       t31;

    @FXML
    private TextField       t32;

    @FXML
    private TextField       t33;

    @FXML
    private TextField       t34;

    @FXML
    private TextField       t35;

    @FXML
    private TextField       t36;

    @FXML
    private TextField       t37;

    @FXML
    private TextField       t38;

    @FXML
    private TextField       t40;

    @FXML
    private TextField       t41;

    @FXML
    private TextField       t42;

    @FXML
    private TextField       t43;

    @FXML
    private TextField       t44;

    @FXML
    private TextField       t45;

    @FXML
    private TextField       t46;

    @FXML
    private TextField       t47;

    @FXML
    private TextField       t48;

    @FXML
    private TextField       t50;

    @FXML
    private TextField       t51;

    @FXML
    private TextField       t52;

    @FXML
    private TextField       t53;

    @FXML
    private TextField       t54;

    @FXML
    private TextField       t55;

    @FXML
    private TextField       t56;

    @FXML
    private TextField       t57;

    @FXML
    private TextField       t58;

    @FXML
    private TextField       t60;

    @FXML
    private TextField       t61;

    @FXML
    private TextField       t62;

    @FXML
    private TextField       t63;

    @FXML
    private TextField       t64;

    @FXML
    private TextField       t65;

    @FXML
    private TextField       t66;

    @FXML
    private TextField       t67;

    @FXML
    private TextField       t68;

    @FXML
    private TextField       t70;

    @FXML
    private TextField       t71;

    @FXML
    private TextField       t72;

    @FXML
    private TextField       t73;

    @FXML
    private TextField       t74;

    @FXML
    private TextField       t75;

    @FXML
    private TextField       t76;

    @FXML
    private TextField       t77;

    @FXML
    private TextField       t78;

    @FXML
    private TextField       t80;

    @FXML
    private TextField       t81;

    @FXML
    private TextField       t82;

    @FXML
    private TextField       t83;

    @FXML
    private TextField       t84;

    @FXML
    private TextField       t85;

    @FXML
    private TextField       t86;

    @FXML
    private TextField       t87;

    @FXML
    private TextField       t88;

    @FXML
    private Label           anzahl;

    @FXML
    private Button          zug;

    @FXML
    private Button          loesen;

    @FXML
    private Button          test;

    @FXML
    private CheckBox        diagonal;

    @FXML
    private Label           leery;

    private List<TextField> tliste  = new ArrayList<>();

    /** Sudoku-Kontext. */
    SudokuContext           context = new SudokuContext(null, false);
    /** Interne Kopie der Sudoku-Zahlen. */
    private int[]           kopie   = new int[MAX * MAX];

    /**
     * Initialisierung des Dialogs.
     */
    protected void initialize() {

        tabbar = 1;
        super.initialize();
        sudoku0.setLabelFor(t00);
        initAccelerator("A", aktuell);
        initAccelerator("U", rueckgaengig);
        initAccelerator("X", export);
        initAccelerator("L", loeschen);
        TextField[] a = new TextField[] { t00, t01, t02, t03, t04, t05, t06, t07, t08, t10, t11, t12, t13, t14, t15,
                t16, t17, t18, t20, t21, t22, t23, t24, t25, t26, t27, t28, t30, t31, t32, t33, t34, t35, t36, t37, t38,
                t40, t41, t42, t43, t44, t45, t46, t47, t48, t50, t51, t52, t53, t54, t55, t56, t57, t58, t60, t61, t62,
                t63, t64, t65, t66, t67, t68, t70, t71, t72, t73, t74, t75, t76, t77, t78, t80, t81, t82, t83, t84, t85,
                t86, t87, t88 };
        for (TextField t : a) {
            t.addEventFilter(KeyEvent.KEY_TYPED, e -> onFeld(e));
            t.addEventFilter(KeyEvent.ANY, e -> onFeldAny(e));
            tliste.add(t);
        }
        initDaten(0);
        t00.requestFocus();
    }

    /**
     * Model-Daten initialisieren.
     * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
     */
    protected void initDaten(final int stufe) {

        if (stufe <= 0) {
            String key = String.format("Sudoku_%d", getServiceDaten().getMandantNr());
            int[] value = Jhh6.getEinstellungen().getIntArray(key);
            if (value.length >= context.zahlen.length) {
                for (int i = 0; i < context.zahlen.length; i++) {
                    context.zahlen[i] = value[i];
                }
            } else {
                String[] array = new String[] { "____8____", // Zeit 12/08
                        "_4_1_7_8_", //
                        "__65324__", //
                        "_71___62_", //
                        "6_9___3_7", //
                        "_34___95_", //
                        "__53298__", //
                        "_1_8_5_9_", //
                        "____1____", //
                };
                String zeile = null;
                for (int row = 0; row < array.length && row < MAX; row++) {
                    zeile = array[row];
                    for (int col = 0; col < zeile.length() && col < MAX; col++) {
                        context.zahlen[row * MAX + col] = Global.strInt(zeile.substring(col, col + 1)) % (MAX + 1);
                    }
                }
            }
            kopie = context.getClone();
        }
        if (stufe <= 1) {
            // stufe = 0;
        }
        if (stufe <= 2) {
            initDatenTable();
        }
    }

    /**
     * Tabellen-Daten initialisieren.
     */
    protected void initDatenTable() {
        onAktuell();
    }

    /**
     * Event für Aktuell.
     */
    @FXML
    public void onAktuell() {

        int i = 0;
        for (TextField t : tliste) {
            t.setText(Global.intStrFormat(context.zahlen[i++]));
        }
        onAktuell2();
    }

    /**
     * Event für Aktuell.
     */
    private void onAktuell2() {
        anzahl.setText("Gefüllt: " + context.getAnzahl());
    }

    /**
     * Event für Rueckgaengig.
     */
    @FXML
    public void onRueckgaengig() {

        SudokuContext.copy(context.zahlen, kopie);
        onAktuell();
    }

    /**
     * Event für Export.
     */
    @FXML
    public void onExport() {

        kopie = context.getClone();
        String key = String.format("Sudoku_%d", getServiceDaten().getMandantNr());
        StringBuffer sb = new StringBuffer();
        int l = kopie.length;
        for (int i = 0; i < l; i++) {
            sb.append(kopie[i]);
            if (i < l - 1) {
                sb.append(";");
            }
        }
        String value = sb.toString();
        Jhh6.getEinstellungen().setParameter(getServiceDaten().getMandantNr(), key, value);
        onAktuell();
    }

    /**
     * Event für Loeschen.
     */
    @FXML
    public void onLoeschen() {

        context.leeren();
        onAktuell();
    }

    /**
     * Sudoku lösen versuchen.
     * @param nur1Zug Soll nur 1 Zug berechnet werden?
     */
    private final void sudokuLoesenMeldung(boolean nur1Zug) {

        try {
            SudokuContext c = new SudokuContext(context.zahlen, diagonal.isSelected());
            Jhh6.setLeftStatus2(null);
            SudokuContext.sudokuLoesen(c, nur1Zug);
            SudokuContext.copy(context.zahlen, c.zahlen);
        } catch (Exception ex) {
            Jhh6.setLeftStatus2(ex.getMessage());
        }
        onAktuell();
    }

    /**
     * Event für Zug.
     */
    @FXML
    public void onZug() {
        sudokuLoesenMeldung(true);
    }

    /**
     * Event für Loesen.
     */
    @FXML
    public void onLoesen() {
        sudokuLoesenMeldung(false);
    }

    /**
     * Event für Test.
     */
    @FXML
    public void onTest() {

        Jhh6.setLeftStatus2(null);
        int feld = SudokuContext.sudokuTest(new SudokuContext(context.zahlen, diagonal.isSelected()), false);
        if (feld >= 0) {
            Jhh6.setLeftStatus2("Widerspruch in Zeile " + (feld / MAX + 1) + " und Spalte " + (feld % MAX + 1) + ".");
        }
    }

    @FXML
    public void onFeldAny(KeyEvent e) {

        if (e.getEventType() != KeyEvent.KEY_RELEASED) {
            return;
        }
        if (e.getCode() == KeyCode.DOWN || e.getCode() == KeyCode.UP || e.getCode() == KeyCode.LEFT || e
                .getCode() == KeyCode.RIGHT || e.getCode() == KeyCode.HOME || e.getCode() == KeyCode.END || e
                        .getCode() == KeyCode.DELETE) {
            e.consume();
            TextField t = (TextField) e.getSource();
            int i = tliste.indexOf(t);
            if (i >= 0) {
                switch (e.getCode()) {
                case DOWN:
                    i += MAX;
                    break;
                case UP:
                    i -= MAX;
                    break;
                case LEFT:
                    i--;
                    break;
                case RIGHT:
                    i++;
                    break;
                case HOME:
                    i -= i % MAX;
                    break;
                case END:
                    i -= i % MAX - MAX + 1;
                    break;
                case DELETE:
                    context.zahlen[i] = 0;
                    onAktuell2();
                    i++;
                    break;
                default:
                    break;
                }
                if (i >= tliste.size()) {
                    i -= tliste.size();
                }
                if (i < 0) {
                    i += tliste.size();
                }
                tliste.get(i).requestFocus();
            }
        }
    }

    @FXML
    public void onFeld(KeyEvent e) {

        if (e.getSource() instanceof TextField) {
            e.consume();
            TextField t = (TextField) e.getSource();
            String s = null;
            int z = 0;
            int diff = 1;
            switch (e.getCharacter()) {
            case "1":
                s = "1";
                z = 1;
                break;
            case "2":
                s = "2";
                z = 2;
                break;
            case "3":
                s = "3";
                z = 3;
                break;
            case "4":
                s = "4";
                z = 4;
                break;
            case "5":
                s = "5";
                z = 5;
                break;
            case "6":
                s = "6";
                z = 6;
                break;
            case "7":
                s = "7";
                z = 7;
                break;
            case "8":
                s = "8";
                z = 8;
                break;
            case "9":
                s = "9";
                z = 9;
                break;
            case "":
            case "\t":
                z = -1;
                break;
            case "\b":
                diff = -1;
                break;
            }
            int i = tliste.indexOf(t);
            if (i >= 0 && z >= 0) {
                context.zahlen[i] = z;
                if (diff != 0) {
                    i += diff;
                    if (i >= tliste.size()) {
                        i = 0;
                    }
                    if (i < 0) {
                        i += tliste.size();
                    }
                    tliste.get(i).requestFocus();
                }
                t.setText(s);
                onAktuell2();
            }
        }
    }
}

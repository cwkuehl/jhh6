package de.cwkuehl.jhh6.app.base;

import java.io.IOException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;
import java.util.function.Function;

import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sun.javafx.scene.control.skin.ComboBoxListViewSkin;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.MeldungException;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.api.service.ServiceDaten;
import de.cwkuehl.jhh6.api.service.ServiceErgebnis;
import de.cwkuehl.jhh6.app.Jhh6;
import de.cwkuehl.jhh6.app.control.Datum;
import de.cwkuehl.jhh6.app.controller.Jhh6Controller;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.RadioButton;
import javafx.scene.control.Tab;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.Toggle;
import javafx.scene.control.ToggleGroup;
import javafx.scene.input.Clipboard;
import javafx.scene.input.ClipboardContent;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyCodeCombination;
import javafx.scene.input.KeyCombination;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.GridPane;
import javafx.stage.Modality;
import javafx.stage.Stage;

@SuppressWarnings("restriction")
public abstract class BaseController<R> {

    /** Logger-Instanz. */
    protected static Logger                             log          = LoggerFactory.getLogger(BaseController.class);

    private Stage                                       window       = null;
    private DialogAufrufEnum                            aufruf       = null;
    private Object[]                                    parameter    = null;
    private R                                           returnvalue  = null;
    @SuppressWarnings({ "rawtypes" })
    private BaseController                              parent       = null;
    private static HashMap<Class<?>, BaseController<?>> dialoge      = new HashMap<>();
    /**
     * Kann der Dialog als Tab integriert werden? 0: nein, 1: nur in Tab 2: ja, 3: in Tab gewechselt.
     */
    protected int                                       tabbar       = 0;
    /** Accelerators des Dialogs. */
    private HashMap<KeyCodeCombination, Runnable>       accelerators = null;

    public ServiceDaten getServiceDaten() {
        return Jhh6.getServiceDaten();
    }

    public void setServiceDaten(ServiceDaten daten) {
        Jhh6.setServiceDaten(daten);
    }

    public DialogAufrufEnum getAufruf() {
        return aufruf;
    }

    public Object[] getParameter() {
        return parameter;
    }

    @SuppressWarnings("unchecked")
    public <S> S getParameter1() {

        if (parameter == null || parameter.length <= 0) {
            return null;
        }
        return (S) parameter[0];
    }

    @SuppressWarnings("unchecked")
    public <S> S getParameter2() {

        if (parameter == null || parameter.length <= 1) {
            return null;
        }
        return (S) parameter[1];
    }

    @SuppressWarnings("unchecked")
    public <S> S getParameter3() {

        if (parameter == null || parameter.length <= 2) {
            return null;
        }
        return (S) parameter[2];
    }

    public R getReturnvalue() {
        return returnvalue;
    }

    protected void initialize() {

        if (tabbar != 0) {
            accelerators = new HashMap<KeyCodeCombination, Runnable>();
        }
        if (tab != null) {
            if (tabbar == 1) {
                tab.setVisible(false);
            }
            initAccelerator("T", tab);
        }
        for (Field f : getClass().getDeclaredFields()) {
            if (f.getType().isAssignableFrom(Datum.class)) {
                try {
                    f.setAccessible(true);
                    Datum d = (Datum) f.get(this);
                    for (Entry<KeyCodeCombination, Runnable> a : d.getAccelators().entrySet()) {
                        accelerators.put(a.getKey(), a.getValue());
                    }
                } catch (Exception e) {
                    Global.machNichts();
                }
            }
        }
    }

    /**
     * Dialog-Daten vor updateData(false) initialisieren.
     * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
     */
    protected void initDaten(int stufe) {
        // Überschreiben
    }

    /**
     * Dialog-Daten nach den Anzeigen initialisieren.
     */
    protected void initDaten2() {
        // Überschreiben
    }

    /**
     * Aktualisieren der Tabelle.
     */
    protected void refreshTable(TableView<?> tv, int stufe) {

        TableViewStatus r = getSelectedRow(tv);
        initDaten(stufe);
        selectRow(tv, r);
    }

    protected void updateParent() {

        // Überschreiben
        if (parent != null) {
            parent.updateParent();
        }
    }

    public void init(Stage window, DialogAufrufEnum aufruf, Object... parameter) {

        this.window = window;
        this.aufruf = aufruf;
        this.parameter = parameter;
        initialize();
    }

    // protected <T extends BaseController<R>> R starteDialog(Class<T> clazz, DialogAufrufEnum aufruf, Object...
    // parameter) {
    // return open(true, clazz, aufruf, parameter);
    // }

    /** Starten eines modalen Dialogs. */
    // Anderer Typ als R
    protected <T> T starteDialog(Class<?> clazz, DialogAufrufEnum aufruf, Object... parameter) {
        return open(true, clazz, aufruf, parameter);
    }

    /** Starten eines nicht modalen Formulars. */
    protected void starteFormular(Class<?> clazz, DialogAufrufEnum aufruf, Object... parameter) {
        open(false, clazz, aufruf, parameter);
    }

    /** Fokussieren oder Starten eines nicht modalen Formulars. */
    protected BaseController<?> fokusFormular(Class<?> clazz, DialogAufrufEnum aufruf, Object... parameter) {

        BaseController<?> c = dialoge.get(clazz);
        if (c == null) {
            open(false, clazz, aufruf, parameter);
            c = dialoge.get(clazz);
            return c;
        }
        Jhh6Controller cc = getJhh6Controller(c);
        if (cc != null) {
            for (Tab t : cc.getTabs().getTabs()) {
                if (t.getUserData() == c) {
                    cc.getTabs().getSelectionModel().select(t);
                }
            }
        }
        c.window.requestFocus();
        return c;
    }

    protected <T> T open(boolean dialog, Class<?> clazz, DialogAufrufEnum aufruf, Object... parameter) {

        Stage stage = new Stage();
        // stage.initModality(dialog ? Modality.APPLICATION_MODAL : Modality.WINDOW_MODAL);
        stage.initModality(dialog ? Modality.APPLICATION_MODAL : Modality.NONE);
        Parent root = null;
        BaseController<T> c = null;
        try {
            String name = getName(clazz);
            String ns = name.substring(0, 2).toLowerCase();
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/dialog/" + ns + "/" + name + ".fxml"), Global
                    .getBundle());
            root = loader.load();
            c = loader.getController();
            c.parent = this;
            c.aufruf = aufruf;
            c.leseResourceDaten(c);
            stage.initOwner(window);
            Scene scene = new Scene(root);
            stage.setTitle(c.getTitel());
            stage.setScene(scene);
            Groesse g = Werkzeug.getDialogGroesse(c.getClass().getSimpleName());
            stage.setX(g.getX());
            stage.setY(g.getY());
            stage.setWidth(g.getWidth());
            stage.setHeight(g.getHeight());
            if (dialog || c.tabbar != 1) {
                // stage.heightProperty().addListener(new ChangeListener<Number>() {
                // @Override
                // public void changed(ObservableValue<? extends Number> wert, Number alt, Number neu) {
                // // System.out.println("Height: " + neu);
                // if (Global.compDouble(neu.doubleValue(), 33) > 0) {
                // if (Global.compDouble(neu.doubleValue(), 80) <= 0) {
                // stage.setHeight(80);
                // } else if (Global.compDouble(neu.doubleValue() - alt.doubleValue(), 32) == 0) {
                // stage.setHeight(alt.doubleValue());
                // }
                // }
                // }
                // });
                // stage.yProperty().addListener(new ChangeListener<Number>() {
                // @Override
                // public void changed(ObservableValue<? extends Number> wert, Number alt, Number neu) {
                // // System.out.println("y: " + neu);
                // if (Global.compDouble(neu.doubleValue() - alt.doubleValue(), 32) == 0) {
                // stage.setY(alt.doubleValue());
                // }
                // }
                // });
                Platform.runLater(() -> {
                    if (stage.getHeight() > g.getHeight()) {
                        stage.setHeight(g.getHeight());
                    }
                });
            }
            // Initialisierung mit fertiger Scene.
            c.init(stage, aufruf, parameter);
            dialoge.put(clazz, c);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        if (dialog) {
            stage.showAndWait();
            c.onHidden();
        } else {
            Jhh6Controller cc = getJhh6Controller(c);
            if (c.tabbar == 1 && cc != null) {
                Tab t = new Tab(c.getTitel());
                t.setContent(root);
                t.setUserData(c);
                final BaseController<T> cf = c;
                t.setOnClosed(e -> {
                    cf.onHidden();
                });
                if (root instanceof GridPane) {
                    ((GridPane) root).heightProperty().addListener(new ChangeListener<Number>() {

                        boolean b1 = true;

                        @Override
                        public void changed(ObservableValue<? extends Number> observable, Number oldValue,
                                Number newValue) {
                            if (b1 && oldValue.intValue() == 0) {
                                b1 = false;
                                Platform.runLater(() -> {
                                    cf.initDaten2();
                                });
                            }
                        }
                    });
                }
                // t.setOnSelectionChanged(new EventHandler<Event>() {
                //
                // boolean b1 = true;
                //
                // @Override
                // public void handle(Event event) {
                // if (b1) {
                // b1 = false;
                // cf.initDaten2();
                // }
                // }
                // });
                cc.getTabs().getTabs().add(t);
                cc.getTabs().getSelectionModel().selectLast();
            } else {
                stage.show();
                final BaseController<T> cf = c;
                // Für Close und Hide.
                stage.setOnHidden(e -> {
                    // System.out.println("Stage is closing");
                    cf.onHidden();
                });
            }
        }
        return c.getReturnvalue();
    }

    private Jhh6Controller getJhh6Controller(BaseController<?> c) {

        BaseController<?> bc = c.parent;
        while (bc != null) {
            if (bc instanceof Jhh6Controller) {
                return (Jhh6Controller) bc;
            }
            bc = bc.parent;
        }
        return null;
    }

    protected void onHidden() {

        if (tabbar == 0 || tabbar == 2) {
            Werkzeug.setDialogGroesse(getClass().getSimpleName(), window);
        }
        BaseController<?> bc = this;
        Class<?> key = dialoge.entrySet().stream().filter(a -> a.getValue() == bc).map(a -> a.getKey()).findFirst()
                .orElse(null);
        if (key != null) {
            dialoge.remove(key, bc);
        }
        speichereResourceDaten();
    }

    protected String getTitel() {
        return getTitel(null);
    }

    protected String getTitel(String ext) {

        String name = getNameKurz(getClass());
        String titel = Global.g0(name + ".title" + (Global.nes(ext) ? "" : "." + ext));
        if (aufruf != null && !DialogAufrufEnum.OHNE.equals(aufruf)) {
            return titel + " - " + aufruf.toString();
        }
        return titel;
    }

    protected void close(R returnvalue) {

        this.returnvalue = returnvalue;
        if (window != null) {
            window.close();
        }
    }

    protected void close() {

        if (window != null) {
            window.close();
        }
    }

    protected <T> T get(ServiceErgebnis<T> r) {

        if (r == null) {
            Jhh6.setLeftStatus(null);
            return null;
        }
        if (r.getFehler().isEmpty()) {
            Jhh6.setLeftStatus(null);
        } else {
            String str = r.getFehler().get(0).getMeldung();
            Jhh6.setLeftStatus(str);
        }
        return r.getErgebnis();
    }

    protected <T> ServiceErgebnis<T> get2(ServiceErgebnis<T> r) {

        if (r == null) {
            Jhh6.setLeftStatus(null);
            return null;
        }
        if (r.getFehler().isEmpty()) {
            Jhh6.setLeftStatus(null);
        } else {
            String str = r.getFehler().get(0).getMeldung();
            Jhh6.setLeftStatus(str);
        }
        return r;
    }

    private void setMandatory(Label l) {
        l.getStyleClass().add("label-bold");
    }

    /**
     * Liefert die selektierte Zeile einer TableView.
     */
    @SuppressWarnings("rawtypes")
    protected TableViewStatus getSelectedRow(TableView<?> tv) {

        TableViewStatus s = new TableViewStatus();
        if (tv != null) {
            s.setSortOrder(new ArrayList<>(tv.getSortOrder()));
            tv.getSortOrder().clear();
            TableViewData it = (TableViewData) tv.getSelectionModel().getSelectedItem();
            if (it != null) {
                s.setId(it.getId());
            }
        }
        return s;
    }

    /**
     * Selektiert eine TableView-Zeile.
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    protected void selectRow(TableView<?> tv, final TableViewStatus s) {

        if (tv != null && s != null) {
            if (s.getId() != null) {
                int i = -1;
                for (Object o : tv.getItems()) {
                    i++;
                    String id = ((TableViewData) o).getId();
                    if (s.getId().equals(id)) {
                        tv.getSelectionModel().select(i);
                        break;
                    }
                }
            }
            if (s.getSortOrder() != null) {
                tv.getSortOrder().clear();
                for (TableColumn c : s.getSortOrder()) {
                    tv.getSortOrder().add(c);
                }
            }
        }
    }

    /**
     * Selektiert eine TableView-Zeile.
     */
    @SuppressWarnings({ "rawtypes" })
    protected void setText(TableView<?> tv, final String s) {

        if (tv != null && s != null) {
            int i = -1;
            for (Object o : tv.getItems()) {
                i++;
                String id = ((TableViewData) o).getId();
                if (s.equals(id)) {
                    tv.getSelectionModel().select(i);
                    tv.scrollTo(i);
                    break;
                }
            }
        }
    }

    protected void setLabelFor(Label l, Node v, boolean mandatory) {

        if (l != null && v != null) {
            l.setLabelFor(v);
            if (mandatory)
                setMandatory(l);
        }
    }

    protected String getText(ToggleGroup tg) {

        if (tg != null) {
            for (Toggle t : tg.getToggles()) {
                if (t.isSelected()) {
                    return Global.objStr(t.getUserData());
                }
            }
        }
        return null;
    }

    protected void setText(ToggleGroup tg, String v) {

        if (tg != null && v != null) {
            for (Toggle t : tg.getToggles()) {
                if (v.equals(t.getUserData())) {
                    t.setSelected(true);
                }
            }
        }
    }

    protected void setLabelFor(Label l, ToggleGroup tg, boolean mandatory) {

        if (l != null && tg != null && !tg.getToggles().isEmpty()) {
            l.setLabelFor((RadioButton) tg.getToggles().get(0));
            if (mandatory)
                setMandatory(l);
        }
    }

    protected void setEditable(ToggleGroup tg, boolean b) {

        if (tg != null) {
            for (Toggle t : tg.getToggles()) {
                ((RadioButton) t).setDisable(!b);
            }
        }
    }

    protected void setEditable(CheckBox tg, boolean b) {

        if (tg != null) {
            tg.setDisable(!b);
        }
    }

    protected String getText(ComboBox<?> cb) {

        Object v = cb.getValue();
        if (v instanceof ComboBoxData<?>) {
            return ((ComboBoxData<?>) v).getId();
        }
        return null;
    }

    protected <T> void setText(ComboBox<T> cb, String v) {

        if (cb != null) {
            cb.getSelectionModel().clearSelection();
            if (v != null) {
                for (T t : cb.getItems()) {
                    if (t instanceof ComboBoxData<?>) {
                        ComboBoxData<?> d = (ComboBoxData<?>) t;
                        // System.out.println(d.toString() + " " + d.getId());
                        if (v.equals(d.getId())) {
                            // System.out.println("Selected " + d.getId());
                            cb.getSelectionModel().select(t);
                            break;
                        }
                    }
                }
            }
        }
    }

    protected <S> S getValue(ComboBox<?> cb, boolean muss) {

        S k = null;
        @SuppressWarnings("unchecked")
        ComboBoxData<S> r = (ComboBoxData<S>) cb.getSelectionModel().getSelectedItem();
        if (r != null) {
            k = r.getData();
        }
        if (k == null && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return k;
    }

    protected void setEditable(ComboBox<?> cb, boolean b) {

        if (cb != null) {
            // cb.setStyle("-fx-opacity: 1;");
            cb.setDisable(!b);
        }
    }

    protected void setLabelFor(Label l, ComboBox<?> cb, boolean mandatory) {
        setLabelFor(l, cb, mandatory, null);
    }

    protected void setLabelFor(Label l, ComboBox<?> cb, boolean mandatory, Button b) {
        setLabelFor(l, cb, mandatory, b, 20);
    }

    protected void setLabelFor(Label l, ComboBox<?> cb, boolean mandatory, Button b, int anz) {

        if (l == null || cb == null) {
            return;
        }
        l.setLabelFor(cb);
        if (mandatory)
            setMandatory(l);
        if (cb.getVisibleRowCount() < anz)
            cb.setVisibleRowCount(anz);
        StringBuilder sb = new StringBuilder();
        cb.addEventHandler(KeyEvent.KEY_RELEASED, e -> {
            if (e.getCode() == KeyCode.DOWN || e.getCode() == KeyCode.UP || e.isAltDown() || e.isControlDown() || e
                    .isMetaDown() || e.isShiftDown() || e.isShortcutDown()) {
                return;
            } else if (e.getCode() == KeyCode.ENTER) {
                if (b != null) {
                    b.fire();
                }
                return;
            } else if (e.getCode() == KeyCode.TAB) {
                sb.setLength(0);
                return;
            } else if (e.getCode() == KeyCode.ESCAPE) {
                sb.setLength(0);
            } else if (e.getCode() == KeyCode.BACK_SPACE) {
                if (sb.length() > 0) {
                    sb.deleteCharAt(sb.length() - 1);
                }
            } else {
                sb.append(e.getText());
            }
            if (sb.length() <= 0) {
                return;
            }
            boolean found = false;
            if (e.getCode() != KeyCode.BACK_SPACE) {
                String s = sb.toString().toLowerCase();
                int i = 0;
                for (Object o : cb.getItems()) {
                    if (o != null && o.toString() != null && matches(s, o.toString().toLowerCase())) {
                        ListView<?> lv = ((ComboBoxListViewSkin<?>) cb.getSkin()).getListView();
                        lv.getSelectionModel().clearAndSelect(i);
                        lv.scrollTo(i);
                        found = true;
                        break;
                    }
                    i++;
                }
            }
            if (!found && sb.length() > 0) {
                sb.deleteCharAt(sb.length() - 1);
            }
        });
    }

    protected void initListView(ListView<?> lv, Button b) {

        if (lv == null) {
            return;
        }
        StringBuilder sb = new StringBuilder();
        lv.addEventHandler(KeyEvent.KEY_RELEASED, e -> {
            if (e.getCode() == KeyCode.DOWN || e.getCode() == KeyCode.UP || e.isAltDown() || e.isControlDown() || e
                    .isMetaDown() || e.isShiftDown() || e.isShortcutDown()) {
                return;
            } else if (e.getCode() == KeyCode.ENTER) {
                if (b != null) {
                    b.fire();
                }
                return;
            } else if (e.getCode() == KeyCode.TAB) {
                sb.setLength(0);
                return;
            } else if (e.getCode() == KeyCode.ESCAPE) {
                sb.setLength(0);
            } else if (e.getCode() == KeyCode.BACK_SPACE) {
                if (sb.length() > 0) {
                    sb.deleteCharAt(sb.length() - 1);
                }
            } else {
                sb.append(e.getText());
            }
            if (sb.length() <= 0) {
                return;
            }
            boolean found = false;
            if (e.getCode() != KeyCode.BACK_SPACE) {
                String s = sb.toString().toLowerCase();
                int i = 0;
                for (Object o : lv.getItems()) {
                    if (o != null && o.toString() != null && matches(s, o.toString().toLowerCase())) {
                        lv.getSelectionModel().clearAndSelect(i);
                        lv.scrollTo(i);
                        found = true;
                        break;
                    }
                    i++;
                }
            }
            if (!found && sb.length() > 0) {
                sb.deleteCharAt(sb.length() - 1);
            }
        });
    }

    // Erster Buchstabe muss übereinstimmen, die nächsten müssen nur in der Reihenfolge vorkommen.
    private boolean matches(String s, String o) {

        // return o.startsWith(s);
        int i = 0;
        for (char c : s.toCharArray()) {
            if (i == 0 && c != o.charAt(0)) {
                return false;
            }
            i = o.indexOf(c, i) + 1;
            if (i <= 0) {
                return false;
            }
        }
        return true;
    }

    protected void setEditable(ListView<?> cb, boolean b) {

        if (cb != null) {
            cb.setDisable(!b);
        }
    }

    protected String getText(ListView<?> cb) {

        Object v = cb.getSelectionModel().getSelectedItem();
        if (v instanceof ComboBoxData<?>) {
            return ((ComboBoxData<?>) v).getId();
        }
        return null;
    }

    protected String getTexte(ListView<?> cb) {

        StringBuffer sb = new StringBuffer();
        ObservableList<?> l = cb.getSelectionModel().getSelectedItems();
        for (Object v : l) {
            if (v instanceof ComboBoxData<?>) {
                Global.anhaengen(sb, ";", ((ComboBoxData<?>) v).getId());
            }
        }
        if (sb.length() > 0) {
            return sb.toString();
        }
        return null;
    }

    protected List<String> getTexte2(ListView<?> cb) {

        List<String> liste = new ArrayList<String>();
        ObservableList<?> l = cb.getSelectionModel().getSelectedItems();
        for (Object v : l) {
            if (v instanceof ComboBoxData<?>) {
                liste.add(((ComboBoxData<?>) v).getId());
            }
        }
        return liste;
    }

    protected <T> void setText(ListView<T> cb, String v) {

        if (cb != null) {
            cb.getSelectionModel().clearSelection();
            if (v != null) {
                for (T t : cb.getItems()) {
                    if (t instanceof ComboBoxData<?>) {
                        ComboBoxData<?> d = (ComboBoxData<?>) t;
                        if (v.equals(d.getId())) {
                            cb.getSelectionModel().select(t);
                            cb.scrollTo(t);
                            break;
                        }
                    }
                }
            }
        }
    }

    protected <T> void setTexte(ListView<T> cb, String str) {

        if (cb != null) {
            cb.getSelectionModel().clearSelection();
            if (str != null) {
                String[] a = str.split(";");
                for (String v : a) {
                    for (T t : cb.getItems()) {
                        if (t instanceof ComboBoxData<?>) {
                            ComboBoxData<?> d = (ComboBoxData<?>) t;
                            if (v.equals(d.getId())) {
                                cb.getSelectionModel().select(t);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    protected <T> void setTexte2(ListView<T> cb, List<String> a) {

        if (cb != null) {
            cb.getSelectionModel().clearSelection();
            if (a != null) {
                for (String v : a) {
                    for (T t : cb.getItems()) {
                        if (t instanceof ComboBoxData<?>) {
                            ComboBoxData<?> d = (ComboBoxData<?>) t;
                            if (v.equals(d.getId())) {
                                cb.getSelectionModel().select(t);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    protected <S> S getValue(ListView<?> cb, boolean muss) {

        S k = null;
        @SuppressWarnings("unchecked")
        ComboBoxData<S> r = (ComboBoxData<S>) cb.getSelectionModel().getSelectedItem();
        if (r != null) {
            k = r.getData();
        }
        if (k == null && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return k;
    }

    protected <T, S extends ComboBoxData<T>> S getValue2(ListView<S> cb, boolean muss) {

        S r = (S) cb.getSelectionModel().getSelectedItem();
        if (r == null && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return r;
    }

    protected <S> List<S> getValues(ListView<?> tv, boolean muss) {

        List<S> liste = new ArrayList<S>();
        @SuppressWarnings("unchecked")
        ObservableList<ComboBoxData<S>> l = (ObservableList<ComboBoxData<S>>) tv.getSelectionModel().getSelectedItems();
        if (l != null) {
            for (ComboBoxData<S> r : l)
                liste.add(r.getData());
        }
        if (liste.size() <= 0 && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return liste;
    }

    protected <S> List<S> getAllValues(ListView<?> tv) {

        List<S> liste = new ArrayList<S>();
        @SuppressWarnings("unchecked")
        ObservableList<ComboBoxData<S>> l = (ObservableList<ComboBoxData<S>>) tv.getItems();
        if (l != null) {
            for (ComboBoxData<S> r : l) {
                liste.add(r.getData());
            }
        }
        return liste;
    }

    protected <S> S getValue(TableView<?> tv, boolean muss) {

        S k = null;
        @SuppressWarnings("unchecked")
        TableViewData<S> r = (TableViewData<S>) tv.getSelectionModel().getSelectedItem();
        if (r != null) {
            k = r.getData();
        }
        if (k == null && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return k;
    }

    protected <S> S getValue2(TableView<?> tv, boolean muss) {

        @SuppressWarnings("unchecked")
        S r = (S) tv.getSelectionModel().getSelectedItem();
        if (r == null && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return r;
    }

    protected <S> List<S> getValues(TableView<?> tv, boolean muss) {

        List<S> liste = new ArrayList<S>();
        @SuppressWarnings("unchecked")
        ObservableList<TableViewData<S>> l = (ObservableList<TableViewData<S>>) tv.getSelectionModel()
                .getSelectedItems();
        if (l != null) {
            for (TableViewData<S> r : l) {
                liste.add(r.getData());
            }
        }
        if (liste.size() <= 0 && muss) {
            throw new MeldungException(Meldungen.M2021());
        }
        return liste;
    }

    protected <S> List<S> getAllValues(TableView<?> tv) {

        List<S> liste = new ArrayList<S>();
        @SuppressWarnings("unchecked")
        ObservableList<TableViewData<S>> l = (ObservableList<TableViewData<S>>) tv.getItems();
        if (l != null) {
            for (TableViewData<S> r : l) {
                liste.add(r.getData());
            }
        }
        return liste;
    }

    protected <S> void initColumnBetrag(TableColumn<S, Double> tc) {

        tc.setCellFactory((TableColumn<S, Double> column) -> {
            return new TableCell<S, Double>() {
                @Override
                protected void updateItem(Double item, boolean empty) {
                    super.updateItem(item, empty);
                    setAlignment(Pos.CENTER_RIGHT);
                    if (item == null || empty) {
                        setText(null);
                    } else {
                        setText(Global.dblStr(item));
                    }
                }
            };
        });
    }

    private String getName(Class<?> clazz) {

        String name = clazz.getSimpleName();
        if (name.endsWith("Controller")) {
            name = name.substring(0, name.length() - 10);
        }
        return name;
    }

    private String getNameKurz(Class<?> clazz) {

        String name = clazz.getSimpleName();
        if (name != null && name.length() >= 5) {
            name = name.substring(0, 5);
        }
        return name;
    }

    private String getResourceKey(String schluessel) {

        StringBuffer name = new StringBuffer();
        name.append(getName(getClass())).append("_").append(StringExtensions.toFirstUpper(schluessel));
        return name.toString();
    }

    private String holeResourceDaten(String schluessel) {

        String wert = Jhh6.getEinstellungen().holeResourceDaten(getResourceKey(schluessel));
        return wert;
    }

    private void setzeResourceDaten(String schluessel, String wert) {
        Jhh6.getEinstellungen().setzeResourceDaten(getResourceKey(schluessel), wert);
    }

    /**
     * Liest alle Werte der Variablen mit Annotation Profil aus den Resourcedaten.
     */
    private final void leseResourceDaten(Object obj) {

        for (Field m : obj.getClass().getDeclaredFields()) {
            leseResourceDaten(obj, m);
        }
    }

    /**
     * Liest den Wert einer Variable mit Annotation Profil aus den Resourcedaten.
     */
    protected final void leseResourceDaten(Object obj, String f) {

        Platform.runLater(new Runnable() {

            @Override
            public void run() {

                try {
                    Field m = obj.getClass().getDeclaredField(f);
                    leseResourceDaten(obj, m);
                } catch (Exception e) {
                }
            }
        });
    }

    /**
     * Liest den Wert einer Variable mit Annotation Profil aus den Resourcedaten.
     */
    @SuppressWarnings("unchecked")
    private final void leseResourceDaten(Object obj, Field m) {

        Profil p = m.getAnnotation(Profil.class);
        if (p != null) {
            try {
                String wert = holeResourceDaten(m.getName());
                if (Global.nes(wert)) {
                    wert = p.defaultValue();
                }
                Class<?> clazz = m.getType();
                m.setAccessible(true);
                if (clazz.isAssignableFrom(String.class)) {
                    m.set(obj, wert);
                } else if (clazz.isAssignableFrom(TextField.class)) {
                    TextField t = (TextField) m.get(obj);
                    if (t != null) {
                        t.setText(wert);
                    }
                } else if (clazz.isAssignableFrom(TextArea.class)) {
                    TextArea t = (TextArea) m.get(obj);
                    if (t != null) {
                        t.setText(wert);
                    }
                } else if (clazz.isAssignableFrom(CheckBox.class)) {
                    CheckBox t = (CheckBox) m.get(obj);
                    if (t != null) {
                        t.setSelected(Global.objBool(wert));
                    }
                } else if (clazz.isAssignableFrom(ToggleGroup.class)) {
                    ToggleGroup t = (ToggleGroup) m.get(obj);
                    setText(t, wert);
                } else if (clazz.isAssignableFrom(ListView.class)) {
                    @SuppressWarnings("rawtypes")
                    ListView t = (ListView) m.get(this);
                    if (t != null) {
                        setTexte(t, wert);
                    }
                } else {
                    throw new Exception("leseResourceDaten: Typ " + clazz + " fehlt.");
                }
            } catch (Exception ex) {
                log.error("leseResourceDaten", ex);
            }
        }
    }

    /**
     * Speichert alle Werte der Variablen mit AnnotationProfil in den Resourcedaten.
     */
    public void speichereResourceDaten() {

        for (Field m : this.getClass().getDeclaredFields()) {
            Profil p = m.getAnnotation(Profil.class);
            if (p != null) {
                try {
                    String name = m.getName();
                    String wert = null;
                    Class<?> clazz = m.getType();
                    m.setAccessible(true);
                    if (clazz.isAssignableFrom(String.class)) {
                        wert = (String) m.get(this);
                    } else if (clazz.isAssignableFrom(TextField.class)) {
                        TextField t = (TextField) m.get(this);
                        if (t != null) {
                            wert = t.getText();
                        }
                    } else if (clazz.isAssignableFrom(TextArea.class)) {
                        TextArea t = (TextArea) m.get(this);
                        if (t != null) {
                            wert = t.getText();
                        }
                    } else if (clazz.isAssignableFrom(CheckBox.class)) {
                        CheckBox t = (CheckBox) m.get(this);
                        if (t != null) {
                            wert = Global.boolStr(t.isSelected());
                        }
                    } else if (clazz.isAssignableFrom(ToggleGroup.class)) {
                        ToggleGroup t = (ToggleGroup) m.get(this);
                        if (t != null) {
                            wert = getText(t);
                        }
                    } else if (clazz.isAssignableFrom(ListView.class)) {
                        @SuppressWarnings("rawtypes")
                        ListView t = (ListView) m.get(this);
                        if (t != null) {
                            wert = getTexte(t);
                        }
                    } else {
                        throw new Exception("speichereResourceDaten: Typ " + clazz + " fehlt.");
                    }
                    if (Global.nes(wert)) {
                        wert = p.defaultValue();
                    }
                    setzeResourceDaten(name, wert);
                } catch (Exception ex) {
                    log.error("speichereResourceDaten", ex);
                }
            }
        }
    }

    protected Stage getStage() {
        return window;
    }

    protected class TableViewStatus {

        String id;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        List<TableColumn<?, ?>> sortOrder;

        public List<TableColumn<?, ?>> getSortOrder() {
            return sortOrder;
        }

        public void setSortOrder(List<TableColumn<?, ?>> sortOrder) {
            this.sortOrder = sortOrder;
        }

    }

    public static class TableViewData<S> {

        private S data = null;

        public TableViewData(S data) {
            this.data = data;
        }

        public String getId() {
            return null;
        }

        public S getData() {
            return data;
        }
    }

    protected static class ComboBoxData<S> {

        private S data = null;

        public ComboBoxData(S data) {
            this.data = data;
        }

        public String getId() {
            return null;
        }

        public S getData() {
            return data;
        }
    }

    public static <R, S> ObservableList<S> getItems(List<R> l, R leer, Function<R, S> conv, ObservableList<S> liste) {

        if (liste == null) {
            liste = FXCollections.observableArrayList();
        } else {
            liste.clear();
        }
        if (leer != null && conv != null) {
            liste.add(conv.apply(leer));
        }
        if (l != null) {
            if (conv != null) {
                for (R v : l) {
                    liste.add(conv.apply(v));
                }
            }
        }
        return liste;
    }

    @SuppressWarnings("rawtypes")
    public BaseController getParent() {
        return parent;
    }

    @FXML
    private Button tab;

    /**
     * Event für Tab.
     */
    @FXML
    public void onTab() {

        if (tabbar == 2) {
            Jhh6Controller cc = getJhh6Controller(this);
            if (cc != null) {
                Tab t = new Tab(getTitel());
                t.setContent(getStage().getScene().getRoot());
                t.setUserData(this);
                t.setOnClosed(e -> {
                    onHidden();
                });
                close(); // Speichern der Dialoggröße
                cc.getTabs().getTabs().add(t);
                cc.getTabs().getSelectionModel().selectLast();
                tabbar = 3;
            }
        }
    }

    protected void initAccelerator(String c, final Button b) {

        KeyCodeCombination kc = new KeyCodeCombination(KeyCode.getKeyCode(c), KeyCombination.CONTROL_DOWN,
                KeyCombination.SHIFT_DOWN);
        Runnable r = () -> {
            b.fire();
        };
        getStage().getScene().getAccelerators().put(kc, r);
        if (accelerators != null) {
            accelerators.put(kc, r);
        }
    }

    public void addAccelerators() {

        if (accelerators != null) {
            Jhh6Controller cc = getJhh6Controller(this);
            if (cc != null) {
                for (Entry<KeyCodeCombination, Runnable> a : accelerators.entrySet()) {
                    cc.getStage().getScene().getAccelerators().put(a.getKey(), a.getValue());
                }
            }
        }
    }

    public void removeAccelerators() {

        if (accelerators != null) {
            Jhh6Controller cc = getJhh6Controller(this);
            if (cc != null) {
                for (Entry<KeyCodeCombination, Runnable> a : accelerators.entrySet()) {
                    cc.getStage().getScene().getAccelerators().remove(a.getKey(), a.getValue());
                }
            }
        }
    }

    protected void initTextArea(TextArea ta, Button b) {

        if (ta == null) {
            return;
        }
        ta.addEventHandler(KeyEvent.KEY_RELEASED, e -> {
            if (e.getCode() == KeyCode.V && e.isControlDown()) {
                Clipboard cb = Clipboard.getSystemClipboard();
                String s = cb.getString();
                if (!Global.nes(s) && cb.getContentTypes().isEmpty()) {
                    ClipboardContent content = new ClipboardContent();
                    content.putString(s);
                    cb.setContent(content);
                }
                // ta.paste();
                // e.consume();
            } else if (e.getCode() == KeyCode.ENTER && e.isControlDown()) {
                if (b != null) {
                    b.fire();
                }
                e.consume();
            }
        });
    }
}

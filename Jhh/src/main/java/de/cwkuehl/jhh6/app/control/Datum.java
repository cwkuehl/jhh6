package de.cwkuehl.jhh6.app.control;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map.Entry;

import de.cwkuehl.jhh6.api.global.Global;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.control.Tooltip;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyCodeCombination;
import javafx.scene.input.KeyCombination;
import javafx.scene.layout.HBox;
import javafx.util.StringConverter;

/** Klasse für Datumsauswahl. */
public class Datum extends HBox {

    @FXML
    private CheckBox                              ohne;

    @FXML
    private DatePicker                            datum;

    @FXML
    private TextField                             zeit;

    @FXML
    private Label                                 text;

    @FXML
    private Button                                minus;

    @FXML
    private Button                                heute;

    @FXML
    private Button                                plus;

    private boolean                               editable     = true;
    private boolean                               notnull      = false;
    private String                                schalterText = null;
    private LocalDate                             date         = LocalDate.now();
    /** Accelerators des Controls. */
    private HashMap<KeyCodeCombination, Runnable> accelators   = new HashMap<>();

    public Datum() {

        FXMLLoader fxmlLoader = new FXMLLoader(getClass().getResource("/control/Datum.fxml"));
        fxmlLoader.setRoot(this);
        fxmlLoader.setController(this);

        try {
            fxmlLoader.load();
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }

        datum.setDisable(true);
        setValue((LocalDateTime) null);
        Platform.runLater(() -> {
            String pattern = "yyyy-MM-dd";
            datum.setPromptText(pattern.toLowerCase());
            datum.setConverter(new StringConverter<LocalDate>() {
                DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern(pattern);

                @Override
                public String toString(LocalDate date) {
                    if (date != null) {
                        return dateFormatter.format(date);
                    } else {
                        return "";
                    }
                }

                @Override
                public LocalDate fromString(String string) {
                    if (string != null && !string.isEmpty()) {
                        return LocalDate.parse(string, dateFormatter);
                    } else {
                        return null;
                    }
                }
            });
            datum.valueProperty().addListener(e -> {
                text.setText(Global.holeWochentag(datum.getValue()));
            });
            text.setText(Global.holeWochentag(datum.getValue()));
        });
        ohne.setOnAction(e -> {
            if (ohne.isSelected()) {
                if (datum.getValue() != null) {
                    date = datum.getValue();
                }
                datum.setValue(null);
            } else {
                setValue(date);
            }
            datum.setDisable(!editable || ohne.isSelected());
        });
        ohne.fire();
    }

    public LocalDate getValue() {
        return datum.valueProperty().get();
    }

    public LocalDateTime getValue2() {

        LocalDate d = datum.valueProperty().get();
        if (d == null) {
            return null;
        }
        String z = zeit.getText();
        if (z == null || z.length() <= 0) {
            return d.atStartOfDay();
        }
        DateTimeFormatter f = DateTimeFormatter.ofPattern("HH:mm");
        LocalTime t = LocalTime.from(f.parse(z));
        return d.atTime(t.getHour(), t.getMinute());
    }

    public void setValue(LocalDate d) {

        if (ohne != null) {
            ohne.setSelected(d == null);
        }
        if (datum != null) {
            if (notnull) {
                if (d == null) {
                    datum.valueProperty().set(date);
                } else {
                    datum.valueProperty().set(d);
                }
                datum.setDisable(!editable);
            } else {
                datum.valueProperty().set(d);
            }
        }
    }

    public void setValue(LocalDateTime d) {

        if (d == null) {
            setValue((LocalDate) null);
            if (zeit != null) {
                zeit.setText(null);
            }
            return;
        }
        setValue(d.toLocalDate());
        String str = d.format(DateTimeFormatter.ofPattern("HH:mm"));
        zeit.setText(str);
    }

    public double getUhrzeitGroesse() {
        return zeit.getMinWidth();
    }

    public void setUhrzeitGroesse(double v) {

        if (v > 0) {
            zeit.setVisible(true);
            zeit.setMinWidth(v);
        } else {
            getChildren().remove(zeit);
            // zeit.setVisible(false);
        }
    }

    public double getWochentagGroesse() {
        return datum.getMinWidth();
    }

    public void setWochentagGroesse(double v) {

        if (v > 0) {
            text.setMinWidth(v);
            // datum.addEventHandler(ActionEvent.ACTION, (e) -> {
            // text.setText(Global.holeWochentag(datum.getValue()));
            // });
        } else {
            text.setVisible(false);
        }
    }

    public String getNullText() {
        return ohne.getText();
    }

    public void setNullText(String v) {

        ohne.setText(v);
        notnull = v == null || v.equals("");
        ohne.setVisible(!notnull);
        if (notnull) {
            this.getChildren().remove(ohne);
            setValue((LocalDateTime) null);
        }
    }

    public String getSchalterText() {
        return schalterText;
    }

    public void setSchalterText(String v) {

        schalterText = v;
        if (v == null || v.equals("")) {
            plus.setVisible(false);
            heute.setVisible(false);
            minus.setVisible(false);
            getChildren().removeAll(plus, heute, minus);
            Platform.runLater(() -> {
                Scene s = datum.getScene();
                if (s != null) {
                    for (Entry<KeyCodeCombination, Runnable> e : accelators.entrySet()) {
                        s.getAccelerators().remove(e.getKey(), e.getValue());
                    }
                }
            });
        } else {
            if (accelators.isEmpty()) {
                accelators.put(new KeyCodeCombination(KeyCode.P, KeyCombination.CONTROL_DOWN), () -> {
                    onPlus();
                });
                accelators.put(new KeyCodeCombination(KeyCode.H, KeyCombination.CONTROL_DOWN), () -> {
                    onHeute();
                });
                accelators.put(new KeyCodeCombination(KeyCode.M, KeyCombination.CONTROL_DOWN), () -> {
                    onMinus();
                });
            }
            Platform.runLater(() -> {
                Scene s = datum.getScene();
                if (s != null) {
                    for (Entry<KeyCodeCombination, Runnable> e : accelators.entrySet()) {
                        s.getAccelerators().put(e.getKey(), e.getValue());
                    }
                }
            });
            plus.setVisible(true);
            heute.setVisible(true);
            minus.setVisible(true);
        }
    }

    // private ObjectProperty<Tooltip> tooltipProperty() {
    // return datum.tooltipProperty();
    // }

    public final void setTooltip(Tooltip value) {
        datum.tooltipProperty().setValue(value);
    }

    public final Tooltip getTooltip() {
        return datum.tooltipProperty().getValue();
    }

    // public StringProperty promptTextProperty() {
    // return datum.promptTextProperty();
    // }

    public String getPromptText() {
        return datum.getPromptText();
    }

    public void setPromptText(String v) {
        datum.setPromptText(v);
        datum.setAccessibleText(v);
    }

    // public ObjectProperty<String> accessibleTextProperty() {
    // return datum.accessibleTextProperty();
    // }

    // public final ObjectProperty<EventHandler<ActionEvent>> onActionProperty() {
    // return onAction;
    // }

    public final void setOnAction(EventHandler<ActionEvent> value) {
        datum.onActionProperty().set(value);
    }

    public final EventHandler<ActionEvent> getOnAction() {
        return datum.onActionProperty().get();
    }

    public void setEditable(boolean b) {

        editable = b;
        ohne.setDisable(!b);
        datum.setDisable(!b);
        zeit.setDisable(!b);
        minus.setVisible(b);
        heute.setVisible(b);
        plus.setVisible(b);
    }

    @FXML
    public void onMinus() {

        if (datum.getValue() != null) {
            datum.setValue(datum.getValue().minusDays(1));
        }
    }

    @FXML
    public void onHeute() {
        datum.setValue(LocalDate.now());
    }

    @FXML
    public void onPlus() {

        if (datum.getValue() != null) {
            datum.setValue(datum.getValue().plusDays(1));
        }
    }

    public Node getLabelForNode() {
        return datum;
    }

    public HashMap<KeyCodeCombination, Runnable> getAccelators() {
        return accelators;
    }
}

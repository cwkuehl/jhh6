package de.cwkuehl.jhh6.app.control

import de.cwkuehl.jhh6.api.global.Global
import java.io.IOException
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.util.HashMap
import java.util.Map.Entry
import javafx.application.Platform
import javafx.event.ActionEvent
import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.DatePicker
import javafx.scene.control.Label
import javafx.scene.control.TextField
import javafx.scene.control.Tooltip
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyCodeCombination
import javafx.scene.input.KeyCombination
import javafx.scene.layout.HBox
import javafx.util.StringConverter

/** 
 * Klasse für Datumsauswahl. 
 */
class Datum extends HBox {

	@FXML CheckBox ohne
	@FXML DatePicker datum
	@FXML TextField zeit
	@FXML Label text
	@FXML Button minus
	@FXML Button heute
	@FXML Button plus
	boolean editable = true
	boolean notnull = false
	String schalterText = null
	LocalDate date = LocalDate::now
	/** 
	 * Accelerators des Controls. 
	 */
	HashMap<KeyCodeCombination, Runnable> accelators = new HashMap

	new() {

		var FXMLLoader fxmlLoader = new FXMLLoader(getClass.getResource("/control/Datum.fxml"), Global::bundle)
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		try {
			fxmlLoader.load
		} catch (IOException ex) {
			throw new RuntimeException(ex)
		}

		datum.setDisable(true)
		setValue((null as LocalDateTime))
		Platform::runLater([
			{
				val pattern = "yyyy-MM-dd"
				datum.setPromptText(pattern.toLowerCase)
				datum.setConverter(new StringConverter<LocalDate> {
					DateTimeFormatter dateFormatter = DateTimeFormatter::ofPattern(pattern)

					override String toString(LocalDate date) {
						if (date !== null) {
							return dateFormatter.format(date)
						} else {
							return ""
						}
					}

					override LocalDate fromString(String string) {
						if (string !== null && !string.isEmpty) {
							return LocalDate::parse(string, dateFormatter)
						} else {
							return null
						}
					}
				})
				datum.valueProperty.addListener([ e |
					{
						text.setText(Global::holeWochentag(datum.getValue))
					}
				])
				text.setText(Global::holeWochentag(datum.getValue))
			}
		])
		ohne.setOnAction([ e |
			{
				if (ohne.isSelected) {
					if (datum.getValue !== null) {
						date = datum.getValue
					}
					datum.setValue(null)
				} else {
					setValue(date)
				}
				datum.setDisable(!editable || ohne.isSelected)
			}
		])
		ohne.fire
	}

	def LocalDate getValue() {
		return datum.valueProperty.get
	}

	def LocalDateTime getValue2() {

		var LocalDate d = datum.valueProperty.get
		if (d === null) {
			return null
		}
		var String z = zeit.getText
		if (z === null || z.length <= 0) {
			return d.atStartOfDay
		}
		var DateTimeFormatter f = DateTimeFormatter::ofPattern("HH:mm")
		var LocalTime t = LocalTime::from(f.parse(z))
		return d.atTime(t.getHour, t.getMinute)
	}

	def void setValue(LocalDate d) {

		if (ohne !== null) {
			ohne.setSelected(d === null)
		}
		if (datum !== null) {
			if (notnull) {
				if (d === null) {
					datum.valueProperty.set(date)
				} else {
					datum.valueProperty.set(d)
				}
				datum.setDisable(!editable)
			} else {
				datum.valueProperty.set(d)
			}
		}
	}

	def void setValue(LocalDateTime d) {

		if (d === null) {
			setValue(null as LocalDate)
			if (zeit !== null) {
				zeit.setText(null)
			}
			return;
		}
		setValue(d.toLocalDate)
		var String str = d.format(DateTimeFormatter::ofPattern("HH:mm"))
		zeit.setText(str)
	}

	def double getUhrzeitGroesse() {
		return zeit.getMinWidth
	}

	def void setUhrzeitGroesse(double v) {

		if (v > 0) {
			zeit.setVisible(true)
			zeit.setMinWidth(v)
		} else {
			getChildren.remove(zeit) // zeit.setVisible(false);
		}
	}

	def double getWochentagGroesse() {
		return datum.getMinWidth
	}

	def void setWochentagGroesse(double v) {

		if (v > 0) {
			text.setMinWidth(v) // datum.addEventHandler(ActionEvent.ACTION, (e) -> {
			// text.setText(Global.holeWochentag(datum.getValue));
			// });
		} else {
			text.setVisible(false)
		}
	}

	def String getNullText() {
		return ohne.getText
	}

	def void setNullText(String v) {

		ohne.setText(v)
		notnull = v === null || v.equals("")
		ohne.setVisible(!notnull)
		if (notnull) {
			this.getChildren.remove(ohne)
			setValue(null as LocalDateTime)
		}
	}

	def String getSchalterText() {
		return schalterText
	}

	def void setSchalterText(String v) {

		schalterText = v
		if (v === null || v.equals("")) {
			plus.setVisible(false)
			heute.setVisible(false)
			minus.setVisible(false)
			getChildren.removeAll(plus, heute, minus)
			Platform::runLater([
				{
					var Scene s = datum.getScene
					if (s !== null) {
						for (Entry<KeyCodeCombination, Runnable> e : accelators.entrySet) {
							s.getAccelerators.remove(e.getKey, e.getValue)
						}
					}
				}
			])
		} else {
			if (accelators.isEmpty) {
				accelators.put(new KeyCodeCombination(KeyCode::P, KeyCombination::CONTROL_DOWN), [
					{
						onPlus
					}
				])
				accelators.put(new KeyCodeCombination(KeyCode::H, KeyCombination::CONTROL_DOWN), [
					{
						onHeute
					}
				])
				accelators.put(new KeyCodeCombination(KeyCode::M, KeyCombination::CONTROL_DOWN), [
					{
						onMinus
					}
				])
			}
			Platform::runLater([
				{
					var Scene s = datum.getScene
					if (s !== null) {
						for (Entry<KeyCodeCombination, Runnable> e : accelators.entrySet) {
							s.getAccelerators.put(e.getKey, e.getValue)
						}
					}
				}
			])
			plus.setVisible(true)
			heute.setVisible(true)
			minus.setVisible(true)
		}
	}

	// private ObjectProperty<Tooltip> tooltipProperty() {
	// return datum.tooltipProperty;
	// }
	def final void setTooltip(Tooltip value) {
		datum.tooltipProperty.setValue(value)
	}

	def final Tooltip getTooltip() {
		return datum.tooltipProperty.getValue()
	}

	// public StringProperty promptTextProperty() {
	// return datum.promptTextProperty;
	// }
	def String getPromptText() {
		return datum.getPromptText
	}

	def void setPromptText(String v) {
		datum.setPromptText(v)
		datum.setAccessibleText(v)
	}

	// public ObjectProperty<String> accessibleTextProperty() {
	// return datum.accessibleTextProperty;
	// }
	// public final ObjectProperty<EventHandler<ActionEvent>> onActionProperty() {
	// return onAction;
	// }
	def final void setOnAction(EventHandler<ActionEvent> value) {
		datum.onActionProperty.set(value)
	}

	def final EventHandler<ActionEvent> getOnAction() {
		return datum.onActionProperty.get
	}

	def void setEditable(boolean b) {

		editable = b
		ohne.setDisable(!b)
		datum.setDisable(!b)
		zeit.setDisable(!b)
		minus.setVisible(b)
		heute.setVisible(b)
		plus.setVisible(b)
	}

	@FXML def void onMinus() {

		if (datum.getValue !== null) {
			datum.setValue(datum.getValue.minusDays(1))
		}
	}

	@FXML def void onHeute() {
		datum.setValue(LocalDate::now)
	}

	@FXML def void onPlus() {

		if (datum.getValue !== null) {
			datum.setValue(datum.getValue.plusDays(1))
		}
	}

	def Node getLabelForNode() {
		return datum
	}

	def HashMap<KeyCodeCombination, Runnable> getAccelators() {
		return accelators
	}
}

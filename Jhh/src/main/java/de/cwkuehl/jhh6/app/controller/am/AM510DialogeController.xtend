package de.cwkuehl.jhh6.app.controller.am

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.controller.Jhh6Controller
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.regex.Pattern
import javafx.beans.property.SimpleStringProperty
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog AM510Dialoge.
 */
class AM510DialogeController extends BaseController<String> {

	@FXML Label dialoge0
	@FXML ListView<DialogeData> dialoge
	// @FXML Button zuordnen
	// @FXML Button entfernen
	@FXML Label zudialoge0
	@FXML ListView<DialogeData> zudialoge

	// @FXML Button oben
	// @FXML Button unten
	// @FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Daten für Tabelle Dialoge.
	 */
	static class DialogeData extends ComboBoxData<MaEinstellung> {

		SimpleStringProperty schluessel
		SimpleStringProperty wert

		new(MaEinstellung v) {
			super(v)
			schluessel = new SimpleStringProperty(v.schluessel)
			wert = new SimpleStringProperty(v.wert)
		}

		override String getId() {
			return schluessel.get
		}

		override String toString() {
			return wert.get
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		dialoge0.setLabelFor(dialoge)
		initListView(dialoge, null)
		zudialoge0.setLabelFor(zudialoge)
		initListView(zudialoge, null)
		initDaten(0)
		dialoge.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var dliste = Jhh6Controller::dialogListe
			var str = Global::nn(Jhh6::einstellungen.getStartdialoge(serviceDaten.mandantNr))
			var array = str.split(Pattern::quote("|"))
			val map = new HashSet<String>
			for (String s : array) {
				map.add(s)
			}
			val List<MaEinstellung> liste = new ArrayList<MaEinstellung>
			val List<MaEinstellung> zuliste = new ArrayList<MaEinstellung>
			dliste.stream.forEach([ a |
				{
					var me = new MaEinstellung
					me.setSchluessel(a.id)
					me.setWert(a.titel)
					if (map.contains(a.id)) {
						zuliste.add(me)
					} else {
						liste.add(me)
					}
				}
			])
			dialoge.setItems(getItems(liste, null, [a|new DialogeData(a)], null))
			zudialoge.setItems(getItems(zuliste, null, [a|new DialogeData(a)], null))
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Zuordnen.
	 */
	@FXML def void onZuordnen() {

		var DialogeData d = getValue2(dialoge, false)
		if (d !== null) {
			dialoge.items.remove(d)
			zudialoge.items.add(d)
		}
	}

	/** 
	 * Event für Entfernen.
	 */
	@FXML def void onEntfernen() {

		var DialogeData d = getValue2(zudialoge, false)
		if (d !== null) {
			zudialoge.items.remove(d)
			dialoge.items.add(d)
		}
	}

	/** 
	 * Event für Oben.
	 */
	@FXML def void onOben() {

		var DialogeData d = getValue2(zudialoge, false)
		if (d !== null) {
			var i = zudialoge.items.indexOf(d)
			if (i > 0) {
				zudialoge.items.remove(d)
				zudialoge.items.add(i - 1, d)
				setText(zudialoge, d.data.schluessel)
			}
		}
	}

	/** 
	 * Event für Unten.
	 */
	@FXML def void onUnten() {

		var DialogeData d = getValue2(zudialoge, false)
		if (d !== null) {
			var i = zudialoge.items.indexOf(d)
			if (i < zudialoge.items.size - 1) {
				zudialoge.items.remove(d)
				zudialoge.items.add(i + 1, d)
				setText(zudialoge, d.data.schluessel)
			}
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		val sb = new StringBuffer
		zudialoge.items.forEach([ a |
			{
				if (sb.length > 0) {
					sb.append("|")
				}
				sb.append(a.data.schluessel)
			}
		])
		Jhh6::einstellungen.setStartdialoge(serviceDaten.mandantNr, sb.toString)
		Jhh6::einstellungen.save
		close
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}

	@FXML def void onDialoge(MouseEvent e) {
		if (e.clickCount > 1) {
			onZuordnen
		}
	}

	@FXML def void onZudialoge(MouseEvent e) {
		if (e.clickCount > 1) {
			onEntfernen
		}
	}
}

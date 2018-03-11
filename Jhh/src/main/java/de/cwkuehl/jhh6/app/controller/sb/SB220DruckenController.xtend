package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.CheckBox
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog SB220Drucken.
 */
class SB220DruckenController extends BaseController<String> {

	@FXML Label person0
	@FXML ComboBox<PersonData> person
	@FXML Label generation0
	@FXML @Profil TextField generation
	@FXML CheckBox vorfahren
	@FXML CheckBox geschwister
	@FXML CheckBox nachfahren
	// @FXML Button ok
	// @FXML Button abbrechen
	@Profil String ahnUid = null

	/** 
	 * Daten für ComboBox Person.
	 */
	static class PersonData extends ComboBoxData<SbPersonLang> {

		new(SbPersonLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.geburtsname
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		person0.setLabelFor(person, true)
		generation0.setLabelFor(generation)
		initDaten(0)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			if (Global::strInt(generation.text) <= 0) {
				generation.setText("3")
			}
			var l = get(FactoryService::stammbaumService.getPersonListe(serviceDaten, true, false, null, null, null))
			person.setItems(getItems(l, null, [a|new PersonData(a)], null))
			setText(person, ahnUid)
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
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var byte[] pdf = get(
			FactoryService::stammbaumService.getReportAhnen(serviceDaten, getText(person),
				Global::strInt(generation.text), geschwister.isSelected, nachfahren.isSelected, vorfahren.isSelected))
		Werkzeug::speicherReport(pdf, Meldungen::SB030, true)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}

	override protected void onHidden() {
		ahnUid = getText(person)
		super.onHidden
	}
}

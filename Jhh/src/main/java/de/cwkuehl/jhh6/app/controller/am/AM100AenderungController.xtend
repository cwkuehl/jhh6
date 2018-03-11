package de.cwkuehl.jhh6.app.controller.am

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.server.FactoryService
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.PasswordField
import javafx.scene.control.TextField

/** 
 * Controller für Dialog AM100Aenderung.
 */
class AM100AenderungController extends BaseController<String> {

	@FXML Label mandant0
	@FXML TextField mandant
	@FXML Label benutzer0
	@FXML TextField benutzer
	@FXML Label kennwortAlt0
	@FXML PasswordField kennwortAlt
	@FXML Label kennwortNeu0
	@FXML PasswordField kennwortNeu
	@FXML Label kennwortNeu20
	@FXML PasswordField kennwortNeu2
	@FXML CheckBox speichern
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		mandant0.setLabelFor(mandant)
		benutzer0.setLabelFor(benutzer)
		kennwortAlt0.setLabelFor(kennwortAlt, true)
		kennwortNeu0.setLabelFor(kennwortNeu, true)
		kennwortNeu20.setLabelFor(kennwortNeu2, true)
		mandant.setEditable(false)
		benutzer.setEditable(false)
		var daten = serviceDaten
		if (daten !== null) {
			mandant.setText(Global.intStr(daten.mandantNr))
			benutzer.setText(daten.benutzerId)
			Platform.runLater([kennwortAlt.requestFocus])
		}
		ok.disableProperty.bind(kennwortNeu.textProperty.isEqualTo(kennwortNeu2.textProperty).not)
	}

	/** 
	 * Event für Ok.
	 * @FXML
	 */
	def void onOk() {

		var daten = getServiceDaten
		var r = FactoryService::anmeldungService.aendern(daten, daten.mandantNr, daten.benutzerId, kennwortAlt.text,
			kennwortNeu.text, speichern.isSelected)
		get(r)
		if (r.ok) {
			close
		}
	}

	/** 
	 * Event für Abbrechen.
	 * @FXML
	 */
	def void onAbbrechen() {
		close
	}
}

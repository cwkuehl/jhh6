package de.cwkuehl.jhh6.app.controller.am

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.server.FactoryService
import javafx.application.Platform
import javafx.event.ActionEvent
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.PasswordField
import javafx.scene.control.TextField

class AM000AnmeldungController extends BaseController<String> {

	@FXML Label mandant0
	@FXML @Profil TextField mandant
	@FXML Label benutzer0
	@FXML @Profil TextField benutzer
	@FXML Label kennwort0
	@FXML PasswordField kennwort
	@FXML Button anmelden
	@FXML CheckBox speichern

	@FXML def void onAnmelden() {

		var daten = new ServiceDaten(Global.strInt(mandant.getText), benutzer.getText)
		var r = FactoryService.anmeldungService.anmelden(daten, kennwort.getText, speichern.isSelected)
		get(r)
		if (r.ok) {
			setServiceDaten(daten)
			get(FactoryService.replikationService.createExamples(daten))
			close("Anmelden")
		}
	}

	@FXML def void onAbbrechen(ActionEvent event) {
		close("Abbrechen")
	}

	override protected void initialize() {

		mandant0.setLabelFor(mandant, true)
		benutzer0.setLabelFor(benutzer, true)
		kennwort0.setLabelFor(kennwort, true)
		if (Global.nes(mandant.text)) {
			mandant.text = "1"
		}
		anmelden.disableProperty.bind(mandant.textProperty.isEmpty.or(benutzer.textProperty.isEmpty))
		Platform.runLater([
			{
				if(Global.nes(mandant.text)) mandant.requestFocus else if(Global.nes(benutzer.text)) benutzer.
					requestFocus else kennwort.requestFocus
			}
		])
	}
}

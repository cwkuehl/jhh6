package de.cwkuehl.jhh6.app.controller.ad

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.util.stream.Collectors
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog AD120Geburtstage.
 */
class AD120GeburtstageController extends BaseController<String> {

	@FXML Label datum0
	@FXML Datum datum
	@FXML Label tage0
	@FXML @Profil TextField tage
	@FXML Label geburtstage0
	@FXML TextArea geburtstage
	@FXML Button ok
	@FXML @Profil CheckBox starten

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		datum0.setLabelFor(datum.labelForNode)
		tage0.setLabelFor(tage)
		geburtstage0.setLabelFor(geburtstage)
		var t = Global.strInt(tage.text)
		if (t <= 0) {
			tage.setText("12")
		}
		datum.setValue(LocalDate::now)
		ok.requestFocus
		starten.hashCode
		initDaten(0)
	}

	override protected void initDaten(int stufe) {

		var r = FactoryService::adresseService.getGeburtstagListe(serviceDaten, datum.value, Global.strInt(tage.text))
		var liste = get(r)
		if (liste === null || liste.size <= 1) {
			if (stufe <= 0) {
				Platform::runLater([close])
			}
			geburtstage.text = null
			return
		}
		var v = liste.stream.collect(Collectors.joining("\n"))
		geburtstage.setText(v)
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {
		close
	}

	/** 
	 * Event für Tage.
	 */
	@FXML def void onTage() {
		initDaten(1)
	}
}

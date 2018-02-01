package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Werkzeug
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.web.WebView

/** 
 * Controller für Dialog AG000Info.
 */
class AG000InfoController extends BaseController<String> {

	@FXML Label client0
	@FXML WebView client
	@FXML Label anmeldung0
	@FXML WebView anmeldung
	@FXML Label lizenz0
	@FXML WebView lizenz

	// @FXML Button ok
	// @FXML Button back
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		client0.labelFor = client
		anmeldung0.labelFor = anmeldung
		lizenz0.labelFor = lizenz
		client.engine.loadContent(Werkzeug.programInfo)
		anmeldung.engine.loadContent(Werkzeug.getLoginInfo(getServiceDaten()))
		lizenz.engine.loadContent(Werkzeug.licenseInfo)
	}

	/** 
	 * Event für Ok.
	 * @FXML
	 */
	def void onOk() {
		close()
	}

	/** 
	 * Event für Back.
	 * @FXML
	 */
	def void onBack() {

		Platform.runLater([
			val we = lizenz.engine
			val ci = we.history.currentIndex
			if (ci <= 0) {
				we.loadContent(Werkzeug.licenseInfo)
			} else
				we.history.go(-1)
		])
	}
}

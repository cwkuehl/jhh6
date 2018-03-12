package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Werkzeug
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.web.WebEngine
import javafx.scene.web.WebView

import static de.cwkuehl.jhh6.app.base.Werkzeug.*

/** 
 * Controller für Dialog AG010Hilfe.
 */
class AG010HilfeController extends BaseController<String> {

	// @FXML Button ok
	@FXML WebView webview

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		var we = webview.engine
		Werkzeug.help = we
	}

	/** 
	 * Event für Ok.
	 * @FXML
	 */
	def void onOk() {
		close
	}

	/** 
	 * Event für Back.
	 * @FXML
	 */
	def void onBack() {

		Platform.runLater([
			val we = webview.engine
			val ci = we.history.currentIndex
			if (ci <= 0) {
				Werkzeug.help = we
			} else
				we.history.go(-1)
		])
	}
}

package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Werkzeug
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

		var WebEngine we = webview.engine
		Werkzeug.help = we
	}

	/** 
	 * Event für Ok.
	 * @FXML
	 */
	def void onOk() {
		close()
	}
}

package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog AG410Sicherung.
 */
class AG410SicherungController extends BaseController<MaEinstellung> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label ziel0
	@FXML TextField ziel
	@FXML Label quelle0
	@FXML TextField quelle
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		ziel0.setLabelFor(ziel)
		quelle0.setLabelFor(quelle)
		initDaten(0)
		ziel.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var MaEinstellung k = parameter1
			if (!neu && k !== null) {
				nr.setText(Global.intStrFormat(k.mandantNr))
				ziel.setText(k.schluessel)
				quelle.setText(k.wert)
			}
			nr.setEditable(false)
			ziel.setEditable(!loeschen)
			quelle.setEditable(!loeschen)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
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

		var MaEinstellung e = parameter1
		if (!DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			if (Global.nes(ziel.text)) {
				throw new MeldungException(Meldungen::M2023)
			}
			if (Global.nes(quelle.text)) {
				throw new MeldungException(Meldungen::M2024)
			}
			if (e === null || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
				e = new MaEinstellung
			}
			e.setSchluessel(ziel.text)
			e.setWert(quelle.text)
		}
		close(e)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

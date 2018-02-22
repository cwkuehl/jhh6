package de.cwkuehl.jhh6.app.controller.ad

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import java.util.List
import javafx.fxml.FXML
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog AD200Schnittstelle.
 */
class AD200SchnittstelleController extends BaseController<String> {

	@FXML Label datei0
	@FXML @Profil TextField datei
	// @FXML Button dateiAuswahl
	@FXML CheckBox loeschen

	// @FXML Button export
	// @FXML Button importieren
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		datei0.setLabelFor(datei)
		initDaten(0)
		datei.setPrefWidth(9999)
		datei.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			loeschen.setSelected(true)
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Event für DateiAuswahl.
	 */
	@FXML def void onDateiAuswahl() {

		var d = DateiAuswahl.auswaehlen(true, "AD200.select.file", "AD200.select.ok", "csv", "AD200.select.ext")
		if (!Global.nes(d)) {
			datei.setText(d)
		}
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen.M1012)
		}
		var List<String> zeilen = get(FactoryService.adresseService.exportAdresseListe(serviceDaten))
		Werkzeug.speicherDateiOeffnen(zeilen, null, datei.text, false)
	}

	/** 
	 * Event für Import.
	 */
	@FXML def void onImport() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen.M1012)
		}
		if (Werkzeug.showYesNoQuestion(Meldungen.AD011) === 0) {
			return
		}
		var List<String> zeilen = Werkzeug.leseDatei(datei.text)
		var String meldung = get(
			FactoryService.adresseService.importAdresseListe(serviceDaten, zeilen, loeschen.isSelected))
		if (!Global.nes(meldung)) {
			updateParent
			Werkzeug.showInfo(meldung)
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

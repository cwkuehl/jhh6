package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog SB500Gedcom.
 */
class SB500GedcomController extends BaseController<String> {

	@FXML Label name0
	@FXML @Profil TextField name
	@FXML Label datei0
	@FXML @Profil TextField datei
	// @FXML Button dateiAuswahl
	@FXML Label filter0
	@FXML @Profil TextArea filter

	// @FXML Button export
	// @FXML Button importieren
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		name0.setLabelFor(name)
		datei0.setLabelFor(datei)
		filter0.setLabelFor(filter)
		initDaten(0)
		name.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
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
	 * Event für DateiAuswahl.
	 */
	@FXML def void onDateiAuswahl() {
		var d = DateiAuswahl.auswaehlen(true, "SB500.select.file", "SB500.select.ok", "ged", "SB500.select.ext")
		if (!Global.nes(d)) {
			datei.setText(d)
		}
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		var d = datei.text
		var zeilen = get2(FactoryService::stammbaumService.exportAhnen(serviceDaten, d, name.text, filter.text, null))
		if (zeilen.ok) {
			Werkzeug.speicherDateiOeffnen(zeilen.ergebnis, null, d, false)
		}
	}

	/** 
	 * Event für Import.
	 */
	@FXML def void onImport() {

		if (Global.nes(datei.getText)) {
			throw new MeldungException(Meldungen::M1012)
		}
		if (Werkzeug.showYesNoQuestion(Meldungen::SB029) === 0) {
			return;
		}
		var zeilen = Werkzeug.leseDatei(datei.getText)
		var meldung = get(FactoryService::stammbaumService.importAhnen(serviceDaten, zeilen))
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

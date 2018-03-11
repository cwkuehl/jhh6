package de.cwkuehl.jhh6.app.controller.mo

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog MO500Schnittstelle.
 */
class MO500SchnittstelleController extends BaseController<String> {

	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label datei0
	@FXML TextField datei
	// @FXML Button dateiAuswahl
	@FXML CheckBox loeschen

	// @FXML Button import1
	// @FXML Button export
	// @FXML Button import2
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		von0.setLabelFor(von.labelForNode, true)
		bis0.setLabelFor(bis.labelForNode)
		datei0.setLabelFor(datei, true)
		initDaten(0)
		datei.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			von.setValue(LocalDate::now.withDayOfYear(1))
			bis.setValue((null as LocalDate))
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
		var dateiname = DateiAuswahl.auswaehlen(true, "MO500.select.file", "MO500.select.ok", "csv", "MO500.select.ext")
		if (!Global.nes(dateiname)) {
			datei.setText(dateiname)
		}
	}

	/** 
	 * Event für Import.
	 */
	@FXML def void onImport1() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen::M1012)
		}
		if (Werkzeug.showYesNoQuestion(Meldungen::MO032) === 0) {
			return
		}
		var zeilen = Werkzeug.leseDatei(datei.text)
		var meldung = get(
			FactoryService::messdienerService.importMessdienerListe(serviceDaten, zeilen, loeschen.isSelected))
		if (!Global.nes(meldung)) {
			updateParent
			Werkzeug.showInfo(meldung)
		}
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen::M1012)
		}
		var zeilen = get(FactoryService::messdienerService.exportMessdienerListe(serviceDaten, von.value, bis.value))
		Werkzeug.speicherDateiOeffnen(zeilen, null, datei.text, false)
	}

	/** 
	 * Event für Import2.
	 */
	@FXML def void onImport2() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen::M1012)
		}
		if (Werkzeug.showYesNoQuestion(Meldungen::MO033) == 0) {
			return
		}
		var zeilen = Werkzeug.leseDatei(datei.text)
		var meldung = get(
			FactoryService::messdienerService.importGottesdienstListe(serviceDaten, zeilen, loeschen.isSelected))
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

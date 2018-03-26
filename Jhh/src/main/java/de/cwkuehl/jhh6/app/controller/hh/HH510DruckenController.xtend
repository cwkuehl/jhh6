package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.util.List
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog HH510Drucken.
 */
class HH510DruckenController extends BaseController<String> {

	@FXML Label titel0
	@FXML @Profil TextField titel
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label datei0
	@FXML TextField datei
	@FXML Button dateiAuswahl
	@FXML CheckBox loeschen
	@FXML Button import1
	@FXML CheckBox eb
	@FXML CheckBox gv
	@FXML CheckBox sb
	@FXML @Profil CheckBox kassenbericht

	// @FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		titel0.setLabelFor(titel)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		initDaten(0)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<Object> e = parameter1
			if (e !== null && e.size >= 3 && e.get(0) instanceof String && e.get(1) instanceof LocalDate &&
				e.get(2) instanceof LocalDate) {
				var kz = e.get(0) as String
				var v = e.get(1) as LocalDate
				var b = e.get(2) as LocalDate
				if (Constant.KZBI_EROEFFNUNG.equals(kz)) {
					von.setValue(v)
					bis.setValue(v.withDayOfYear(v.lengthOfYear))
					eb.setSelected(true)
				} else if (Constant.KZBI_SCHLUSS.equals(kz)) {
					bis.setValue(v)
					von.setValue(b.withDayOfYear(1))
					sb.setSelected(true)
				} else {
					von.setValue(v)
					bis.setValue(b)
					gv.setSelected(true)
				}
			}
			if (serviceDaten.benutzerId.toLowerCase != "wolfgang") {
				datei0.visible = false
				datei.visible = false
				dateiAuswahl.visible = false
				loeschen.visible = false
				import1.visible = false
			}
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) {
			initDatenTable
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
		var dateiname = DateiAuswahl.auswaehlen(true, "HH510.select.file", "HH510.select.ok", "csv", "HH510.select.ext")
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
		if (Werkzeug.showYesNoQuestion(Meldungen::HH052) === 0) {
			return
		}
		var zeilen = Werkzeug.leseDatei(datei.text)
		var meldung = get(FactoryService::haushaltService.importBuchungListe(serviceDaten, zeilen, loeschen.isSelected))
		if (!Global.nes(meldung)) {
			updateParent
			Werkzeug.showInfo(meldung)
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		if (eb.isSelected || gv.isSelected || sb.isSelected) {
			val byte[] pdf = get(
				FactoryService::haushaltService.getReportJahresbericht(serviceDaten, von.value, bis.value, titel.text,
					eb.isSelected, gv.isSelected, sb.isSelected))
			Platform::runLater([Werkzeug.speicherReport(pdf, Meldungen::HH048, true)])
		}
		if (kassenbericht.isSelected) {
			val byte[] pdf = get(
				FactoryService::haushaltService.getReportKassenbericht(serviceDaten, von.value, bis.value, titel.text))
			Platform::runLater([Werkzeug.speicherReport(pdf, Meldungen::HH049, true)])
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

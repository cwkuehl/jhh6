package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.util.List
import javafx.fxml.FXML
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
	@FXML CheckBox eb
	@FXML CheckBox gv
	@FXML CheckBox sb
	@FXML CheckBox kassenbericht

	// @FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		titel0.setLabelFor(titel)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		initDaten(0)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<Object> e = getParameter1
			if (e !== null && e.size >= 3 && e.get(0) instanceof String && e.get(1) instanceof LocalDate &&
				e.get(2) instanceof LocalDate) {
				var String kz = (e.get(0) as String)
				var LocalDate v = (e.get(1) as LocalDate)
				var LocalDate b = (e.get(2) as LocalDate)
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
		}
		if (stufe <= 1) { // stufe = 0;
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
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		if (eb.isSelected || gv.isSelected || sb.isSelected) {
			var byte[] pdf = get(
				FactoryService.getHaushaltService.getReportJahresbericht(getServiceDaten, von.getValue, bis.getValue,
					titel.getText, eb.isSelected, gv.isSelected, sb.isSelected))
			Werkzeug.speicherReport(pdf, "Jahresbericht", true)
		}
		if (kassenbericht.isSelected) {
			var byte[] pdf = get(
				FactoryService.getHaushaltService.getReportKassenbericht(getServiceDaten, von.getValue, bis.getValue,
					titel.getText))
			Werkzeug.speicherReport(pdf, "Kassenbericht", true)
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

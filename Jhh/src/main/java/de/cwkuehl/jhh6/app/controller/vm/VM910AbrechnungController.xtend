package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmAbrechnungKurz
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label

/** 
 * Controller für Dialog VM910Abrechnung.
 */
class VM910AbrechnungController extends BaseController<String> {

	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label haus0
	@FXML ComboBox<HausData> haus

	/** 
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends ComboBoxData<VmHaus> {

		new(VmHaus v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
		}
	}

	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		von0.setLabelFor(von.labelForNode, true)
		bis0.setLabelFor(bis.labelForNode, true)
		haus0.setLabelFor(haus, true)
		initDaten(0)
		von.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, null, [a|new HausData(a)], null))
			von.setValue(LocalDate::now.minusYears(1).withDayOfYear(1))
			bis.setValue(von.value.plusYears(1).minusDays(1))
			haus.getSelectionModel.select(0)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var VmAbrechnungKurz k = parameter1
			if (loeschen && k !== null) {
				von.setValue(k.datumVon)
				bis.setValue(k.datumBis)
				setText(haus, k.hausUid)
			}
			von.setEditable(!loeschen)
			bis.setEditable(!loeschen)
			setEditable(haus, !loeschen)
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
	 * Event für Von.
	 * @FXML
	 */
	def void onVon() {
		bis.setValue(von.value.plusYears(1).minusDays(1))
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf)) {
			r = FactoryService::vermietungService.insertHausAbrechnung(serviceDaten, von.value, bis.value,
				getText(haus))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::vermietungService.deleteHausAbrechnung(serviceDaten, von.value, bis.value,
				getText(haus))
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				updateParent
				close
			}
		}
	}

	/** 
	 * Event für Abbrechen.
	 * @FXML
	 */
	def void onAbbrechen() {
		close
	}
}

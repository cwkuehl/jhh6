package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM210Wohnung.
 */
class VM210WohnungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends BaseController.ComboBoxData<VmHaus> {

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

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		haus0.setLabelFor(haus, true)
		bezeichnung0.setLabelFor(bezeichnung, true)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		bezeichnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, null, [a|new HausData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var VmWohnungLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::vermietungService.getWohnungLang(serviceDaten, k.uid))
				nr.setText(k.uid)
				setText(haus, k.hausUid)
				bezeichnung.setText(k.bezeichnung)
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			setEditable(haus, !loeschen)
			bezeichnung.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
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

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateWohnung(serviceDaten, null, getText(haus),
				bezeichnung.text, notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateWohnung(serviceDaten, nr.text, getText(haus),
				bezeichnung.text, notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::vermietungService.deleteWohnung(serviceDaten, nr.text)
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
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.global.Global
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
 * Controller für Dialog HP160Status.
 */
class HP160StatusController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label status0
	@FXML TextField status
	@FXML Label beschreibung0
	@FXML TextField beschreibung
	@FXML Label sortierung0
	@FXML TextField sortierung
	@FXML Label standard0
	@FXML ComboBox<StandardData> standard
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Standard.
	 */
	static class StandardData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.schluessel
		}

		override String toString() {
			return getData.wert
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		status0.setLabelFor(status, true)
		beschreibung0.setLabelFor(beschreibung, true)
		sortierung0.setLabelFor(sortierung, true)
		standard0.setLabelFor(standard, true)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		status.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var l = get(FactoryService::heilpraktikerService.getStandardStatusListe(serviceDaten))
			standard.setItems(getItems(l, null, [a|new StandardData(a)], null))
			standard.selectionModel.select(0)
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HpStatus k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::heilpraktikerService.getStatus(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					status.setText(k.status)
					beschreibung.setText(k.beschreibung)
					sortierung.setText(Global.intStrFormat(k.sortierung))
					standard.selectionModel.clearAndSelect(k.standard)
					notiz.setText(k.notiz)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
				}
			}
			nr.setEditable(false)
			status.setEditable(!loeschen)
			beschreibung.setEditable(!loeschen)
			sortierung.setEditable(!loeschen)
			setEditable(standard, !loeschen)
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
			r = FactoryService::heilpraktikerService.insertUpdateStatus(serviceDaten, null, status.text,
				beschreibung.text, Global.strInt(sortierung.text), standard.selectionModel.selectedIndex, notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateStatus(serviceDaten, nr.text, status.text,
				beschreibung.text, Global.strInt(sortierung.text), standard.selectionModel.selectedIndex, notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deleteStatus(serviceDaten, nr.text)
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

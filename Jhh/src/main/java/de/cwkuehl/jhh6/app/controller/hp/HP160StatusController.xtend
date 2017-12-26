package de.cwkuehl.jhh6.app.controller.hp

import java.util.List
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
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
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
		standard0.setLabelFor(standard)
		initComboBox(standard, null)
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
			var List<MaEinstellung> l = get(
				FactoryService.getHeilpraktikerService.getStandardStatusListe(getServiceDaten))
			standard.setItems(getItems(l, null, [a|new StandardData(a)], null))
			standard.getSelectionModel.select(0)
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var HpStatus k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService.getHeilpraktikerService.getStatus(getServiceDaten, k.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					status.setText(k.getStatus)
					beschreibung.setText(k.getBeschreibung)
					sortierung.setText(Global.intStrFormat(k.getSortierung))
					standard.getSelectionModel.clearAndSelect(k.getStandard)
					notiz.setText(k.getNotiz)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
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
				ok.setText(Meldungen.M2001)
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

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdateStatus(getServiceDaten, null, status.getText,
				beschreibung.getText, Global.strInt(sortierung.getText), standard.getSelectionModel.getSelectedIndex,
				notiz.getText)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdateStatus(getServiceDaten, nr.getText, status.getText,
				beschreibung.getText, Global.strInt(sortierung.getText), standard.getSelectionModel.getSelectedIndex,
				notiz.getText)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.deleteStatus(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
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

package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.dto.FzNotizKurz
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.table.TableModel
import de.cwkuehl.jhh6.server.FactoryService
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.SplitPane
import javafx.scene.control.TableView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog FZ710Notiz.
 */
class FZ710NotizController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label thema0
	@FXML TextField thema
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML TableView<?> tabelle
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	// @FXML Button abbrechen
	TableModel daten = null
	@FXML SplitPane splitpane

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		super.initialize
		daten = new TableModel(tabelle)
		nr0.setLabelFor(nr)
		thema0.setLabelFor(thema, true)
		notiz0.setLabelFor(notiz)
		initTextArea(notiz, ok)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		thema.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var FzNotizKurz k = parameter1
			if (!neu && k !== null) {
				var l = get(FactoryService::freizeitService.getNotiz(serviceDaten, k.uid))
				if (l !== null) {
					nr.setText(l.uid)
					thema.setText(l.thema)
					daten.readXmlDocument(l.notiz)
					notiz.setText(daten.notiz)
					angelegt.setText(l.formatDatumVon(l.angelegtAm, l.angelegtVon))
					geaendert.setText(l.formatDatumVon(l.geaendertAm, l.geaendertVon))
				}
			}
			nr.setEditable(false)
			thema.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			tabelle.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			daten.initContextMenu(getStage)
			daten.fireTableStructureChanged
			Platform::runLater([splitpane.setDividerPosition(0, daten.divider)])
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var pos = splitpane.dividerPositions
		if (pos !== null && pos.length > 0) {
			daten.setDivider(pos.get(0))
		}
		daten.setNotiz(notiz.text)
		var xml = daten.writeXmlDocument
		// Werkzeug.showError(xml)
		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateNotiz(serviceDaten, null, thema.text, xml)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateNotiz(serviceDaten, nr.text, thema.text, xml)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::freizeitService.deleteNotiz(serviceDaten, nr.text)
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

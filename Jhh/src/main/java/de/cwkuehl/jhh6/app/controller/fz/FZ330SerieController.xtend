package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.dto.FzBuchserie
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog FZ330Serie.
 */
class FZ330SerieController extends BaseController<FzBuchserie> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label name0
	@FXML TextField name
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		name0.setLabelFor(name, true)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
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
		if (stufe <= 1) {
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var FzBuchserie k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService.getFreizeitService.getSerie(getServiceDaten, k.getUid))
				nr.setText(k.getUid)
				name.setText(k.getName)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			name.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen.M2001)
			}
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
		var FzBuchserie s = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			var ServiceErgebnis<FzBuchserie> r1 = FactoryService.getFreizeitService.insertUpdateSerie(
				getServiceDaten, null, name.getText)
			s = r1.getErgebnis
			r = r1
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getFreizeitService.insertUpdateSerie(getServiceDaten, nr.getText, name.getText)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getFreizeitService.deleteSerie(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
				updateParent
				close(s)
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

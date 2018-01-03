package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.SbQuelle
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog SB410Quelle.
 */
class SB410QuelleController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label autor0
	@FXML TextField autor
	@FXML Label beschreibung0
	@FXML TextField beschreibung
	@FXML Label zitat0
	@FXML TextArea zitat
	@FXML Label bemerkung0
	@FXML TextArea bemerkung
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	//@FXML Button abbrechen

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		autor0.setLabelFor(autor)
		beschreibung0.setLabelFor(beschreibung)
		zitat0.setLabelFor(zitat)
		bemerkung0.setLabelFor(bemerkung)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		autor.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var SbQuelle k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService.getStammbaumService.getQuelle(getServiceDaten, k.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					autor.setText(k.getAutor)
					beschreibung.setText(k.getBeschreibung)
					zitat.setText(k.getZitat)
					bemerkung.setText(k.getBemerkung)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
				}
			}
			nr.setEditable(false)
			autor.setEditable(!loeschen)
			beschreibung.setEditable(!loeschen)
			zitat.setEditable(!loeschen)
			bemerkung.setEditable(!loeschen)
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
			r = FactoryService.getStammbaumService.insertUpdateQuelle(getServiceDaten, null, autor.getText,
				beschreibung.getText, zitat.getText, bemerkung.getText)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getStammbaumService.insertUpdateQuelle(getServiceDaten, nr.getText,
				autor.getText, beschreibung.getText, zitat.getText, bemerkung.getText)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getStammbaumService.deleteQuelle(getServiceDaten, nr.getText)
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

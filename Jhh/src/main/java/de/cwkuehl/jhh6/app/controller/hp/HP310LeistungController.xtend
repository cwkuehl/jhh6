package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.api.global.Global
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
 * Controller für Dialog HP310Leistung.
 */
class HP310LeistungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label ziffer0
	@FXML TextField ziffer
	@FXML Label ziffer20
	@FXML TextField ziffer2
	@FXML Label beschreibungFett0
	@FXML TextField beschreibungFett
	@FXML Label beschreibung0
	@FXML TextArea beschreibung
	@FXML Label faktor0
	@FXML TextField faktor
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label notiz0
	@FXML TextArea notiz
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
		ziffer0.setLabelFor(ziffer)
		ziffer20.setLabelFor(ziffer2)
		beschreibungFett0.setLabelFor(beschreibungFett)
		beschreibung0.setLabelFor(beschreibung)
		faktor0.setLabelFor(faktor)
		betrag0.setLabelFor(betrag)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		ziffer.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HpLeistung k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::heilpraktikerService.getLeistung(serviceDaten, k.uid))
				nr.setText(k.uid)
				ziffer.setText(k.ziffer)
				ziffer2.setText(k.zifferAlt)
				beschreibungFett.setText(k.beschreibungFett)
				beschreibung.setText(k.beschreibung)
				faktor.setText(Global.dblStr2l(k.faktor))
				betrag.setText(Global.dblStr2l(k.festbetrag))
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			ziffer.setEditable(!loeschen)
			ziffer2.setEditable(!loeschen)
			beschreibungFett.setEditable(!loeschen)
			beschreibung.setEditable(!loeschen)
			faktor.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
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
			r = FactoryService::heilpraktikerService.insertUpdateLeistung(serviceDaten, null, ziffer.text, ziffer2.text,
				beschreibungFett.text, beschreibung.text, Global.strDbl(faktor.text), Global.strDbl(betrag.text), null,
				notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateLeistung(serviceDaten, nr.text, ziffer.text,
				ziffer2.text, beschreibungFett.text, beschreibung.text, Global.strDbl(faktor.text),
				Global.strDbl(betrag.text), null, notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deleteLeistung(serviceDaten, nr.text)
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

package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
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
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP510Stand.
 */
class WP510StandController extends BaseController<String> {

	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@FXML Label valuta0
	@FXML Datum valuta
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	// @FXML Label buchung0
	@FXML Button ok
	// @FXML Button abbrechen
	static LocalDate valutaZuletzt = LocalDate::now

	/** 
	 * Daten für ComboBox Wertpapier.
	 */
	static class WertpapierData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
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
		wertpapier0.setLabelFor(wertpapier, true)
		valuta0.setLabelFor(valuta.labelForNode, true)
		betrag0.setLabelFor(betrag, true)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		betrag.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// letztes Datum einstellen
			valuta.setValue(valutaZuletzt)
			var l = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			wertpapier.setItems(getItems(l, null, [a|new WertpapierData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var WpStandLang e = parameter1
			if (!neu && e !== null) {
				var k = get(FactoryService::wertpapierService.getStand(serviceDaten, e.wertpapierUid, e.datum))
				if (k !== null) {
					setText(wertpapier, k.wertpapierUid)
					valuta.setValue(k.datum)
					betrag.setText(Global.dblStr4l(k.stueckpreis))
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
				}
			}
			setEditable(wertpapier, !loeschen)
			valuta.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
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
			r = FactoryService::wertpapierService.insertUpdateStand(serviceDaten, getText(wertpapier), valuta.value,
				Global.strDbl(betrag.text))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::wertpapierService.insertUpdateStand(serviceDaten, getText(wertpapier), valuta.value,
				Global.strDbl(betrag.text))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::wertpapierService.deleteStand(serviceDaten, getText(wertpapier), valuta.value)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				if (r.fehler.isEmpty) {
					// letztes Datum merken
					valutaZuletzt = valuta.value
				}
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

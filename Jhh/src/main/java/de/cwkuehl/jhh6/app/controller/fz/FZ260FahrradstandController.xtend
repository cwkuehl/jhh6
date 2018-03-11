package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.dto.FzFahrradLang
import de.cwkuehl.jhh6.api.dto.FzFahrradstandLang
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
 * Controller für Dialog FZ260Fahrradstand.
 */
class FZ260FahrradstandController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label fahrrad0
	@FXML ComboBox<FahrradData> fahrrad
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label zaehler0
	@FXML TextField zaehler
	@FXML Label km0
	@FXML TextField km
	@FXML Label schnitt0
	@FXML TextField schnitt
	@FXML Label beschreibung0
	@FXML TextField beschreibung
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Fahrrad.
	 */
	static class FahrradData extends ComboBoxData<FzFahrradLang> {
		new(FzFahrradLang v) {
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
		fahrrad0.setLabelFor(fahrrad, true)
		datum0.setLabelFor(datum.labelForNode, true)
		zaehler0.setLabelFor(zaehler, true)
		km0.setLabelFor(km, true)
		schnitt0.setLabelFor(schnitt)
		beschreibung0.setLabelFor(beschreibung)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		km.requestFocus
		km.selectAll
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var fl = get(FactoryService::freizeitService.getFahrradListe(serviceDaten, true))
			fahrrad.setItems(getItems(fl, null, [a|new FahrradData(a)], null))
			datum.setValue(LocalDate::now)
			if (fl.size > 0) {
				setText(fahrrad, fl.get(0).uid)
			}
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var kopieren = DialogAufrufEnum::KOPIEREN.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var FzFahrradstandLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::freizeitService.getFahrradstandLang(serviceDaten, k.fahrradUid, k.datum, k.nr))
				nr.setText(Global.intStrFormat(k.nr))
				setText(fahrrad, k.fahrradUid)
				datum.setValue(k.datum)
				zaehler.setText(Global.lngStr(k.zaehlerKm as long))
				km.setText(Global.lngStr(k.periodeKm as long))
				schnitt.setText(Global.dblStr2l(k.periodeSchnitt))
				beschreibung.setText(k.beschreibung)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			setEditable(fahrrad, !loeschen)
			datum.setEditable(neu || kopieren)
			zaehler.setEditable(!loeschen)
			km.setEditable(!loeschen)
			schnitt.setEditable(!loeschen)
			beschreibung.setEditable(!loeschen)
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
	 * Event für Zaehler.
	 */
	@FXML def void onZaehler() {
		km.setText(null)
	}

	/** 
	 * Event für Km.
	 */
	@FXML def void onKm() {
		zaehler.setText(null)
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateFahrradstand(getServiceDaten, getText(fahrrad),
				datum.value2, -1, Global.strDbl(zaehler.text), Global.strDbl(km.text), Global.strDbl(schnitt.text),
				beschreibung.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateFahrradstand(serviceDaten, getText(fahrrad), datum.value2,
				Global.strInt(nr.text), Global.strDbl(zaehler.text), Global.strDbl(km.text),
				Global.strDbl(schnitt.text), beschreibung.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::freizeitService.deleteFahrradstand(serviceDaten, getText(fahrrad), datum.value2,
				Global.strInt(nr.text))
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

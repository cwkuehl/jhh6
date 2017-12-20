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
import java.util.List
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
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		fahrrad0.setLabelFor(fahrrad)
		initComboBox(fahrrad, null)
		datum0.setLabelFor(datum.getLabelForNode)
		zaehler0.setLabelFor(zaehler)
		km0.setLabelFor(km)
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
			var List<FzFahrradLang> fl = get(FactoryService.getFreizeitService.getFahrradListe(getServiceDaten, true))
			fahrrad.setItems(getItems(fl, null, [a|new FahrradData(a)], null))
			datum.setValue(LocalDate.now)
			if (fl.size > 0) {
				setText(fahrrad, fl.get(0).getUid)
			}
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean kopieren = DialogAufrufEnum.KOPIEREN.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var FzFahrradstandLang k = getParameter1
			if (!neu && k !== null) {
				k = get(
					FactoryService.getFreizeitService.getFahrradstandLang(getServiceDaten, k.getFahrradUid, k.getDatum,
						k.getNr))
				nr.setText(Global.intStrFormat(k.getNr))
				setText(fahrrad, k.getFahrradUid)
				datum.setValue(k.getDatum)
				zaehler.setText(Global.lngStr((k.getZaehlerKm as long)))
				km.setText(Global.lngStr((k.getPeriodeKm as long)))
				schnitt.setText(Global.dblStr2l(k.getPeriodeSchnitt))
				beschreibung.setText(k.getBeschreibung)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
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
	@FXML @SuppressWarnings("unchecked") def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getFreizeitService.insertUpdateFahrradstand(getServiceDaten, getText(fahrrad),
				datum.getValue2, -1, Global.strDbl(zaehler.getText), Global.strDbl(km.getText),
				Global.strDbl(schnitt.getText), beschreibung.getText)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getFreizeitService.insertUpdateFahrradstand(getServiceDaten, getText(fahrrad),
				datum.getValue2, Global.strInt(nr.getText), Global.strDbl(zaehler.getText), Global.strDbl(km.getText),
				Global.strDbl(schnitt.getText), beschreibung.getText)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getFreizeitService.deleteFahrradstand(getServiceDaten, getText(fahrrad), datum.getValue2,
				Global.strInt(nr.getText))
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

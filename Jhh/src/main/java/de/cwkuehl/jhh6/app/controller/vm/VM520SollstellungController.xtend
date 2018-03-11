package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM520Sollstellung.
 */
class VM520SollstellungController extends BaseController<String> {

	@FXML Label monat0
	@FXML Datum monat
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label miete0
	@FXML TextField miete
	@FXML Label nebenkosten0
	@FXML TextField nebenkosten
	// @FXML Button ok
	// @FXML Button abbrechen
	static LocalDate monatZuletzt = LocalDate::now.minusMonths(1).withDayOfMonth(1)
	int event = 0

	/** 
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends ComboBoxData<VmHaus> {

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
	 * Daten für ComboBox Wohnung.
	 */
	static class WohnungData extends ComboBoxData<VmWohnungLang> {

		new(VmWohnungLang v) {
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
		monat0.setLabelFor(monat, true)
		haus0.setLabelFor(haus, true)
		wohnung0.setLabelFor(wohnung, true)
		miete0.setLabelFor(miete)
		nebenkosten0.setLabelFor(nebenkosten)
		initDaten(0)
		monat.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// letzten Monat einstellen
			monat.setValue(monatZuletzt)
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			miete.setEditable(false)
			nebenkosten.setEditable(false)
			onHaus
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
	 * Event für Monat.
	 */
	@FXML def void onMonat() {
		onHaus
	}

	/** 
	 * Event für Haus.
	 */
	@FXML def void onHaus() {

		if (event > 0) {
			return
		}
		try {
			event++
			var VmHaus h = getValue(haus, false)
			var VmWohnungLang w = getValue(wohnung, false)
			if (h !== null && w !== null && Global::compString(h.uid, w.hausUid) !== 0) {
				setText(wohnung, null)
			}
			if ((h === null || Global::nes(h.uid)) && (w === null || Global::nes(w.uid))) {
				miete.setText(null)
				nebenkosten.setText(null)
			} else {
				var vo = get(
					FactoryService::vermietungService.getMieteSollstellung(serviceDaten, monat.value, getText(haus),
						getText(wohnung), null, true))
				miete.setText(Global::dblStr2l(vo.miete))
				nebenkosten.setText(Global::dblStr2l(vo.nebenkosten))
			}
		} finally {
			event--
		}
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {

		if (event > 0) {
			return
		}
		try {
			event++
			var VmWohnungLang w = getValue(wohnung, false)
			if (w !== null && !Global::nes(w.uid)) {
				setText(haus, w.hausUid)
			}
		} finally {
			event--
		}
		onHaus
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var r = FactoryService::vermietungService.insertSollstellung(serviceDaten, monat.value, getText(haus),
			getText(wohnung))
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				// letztes Datum merken
				monatZuletzt = monat.value
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

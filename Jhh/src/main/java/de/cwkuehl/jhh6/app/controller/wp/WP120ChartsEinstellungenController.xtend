package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.server.FactoryService
import java.util.ArrayList
import java.util.List
import javafx.fxml.FXML
import javafx.scene.control.ComboBox
import javafx.scene.control.Label

/** 
 * Controller für Dialog WP120ChartsEinstellungen.
 */
class WP120ChartsEinstellungenController extends BaseController<List<String>> {

	@FXML Label wertpapier10
	@FXML ComboBox<WertpapierData> wertpapier1
	@FXML Label konfiguration10
	@FXML ComboBox<KonfigurationData> konfiguration1
	@FXML Label wertpapier20
	@FXML ComboBox<WertpapierData> wertpapier2
	@FXML Label konfiguration20
	@FXML ComboBox<KonfigurationData> konfiguration2
	@FXML Label wertpapier30
	@FXML ComboBox<WertpapierData> wertpapier3
	@FXML Label konfiguration30
	@FXML ComboBox<KonfigurationData> konfiguration3

	// @FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBoxen Wertpapier.
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
	 * Daten für ComboBoxen Konfiguration.
	 */
	static class KonfigurationData extends ComboBoxData<WpKonfigurationLang> {

		new(WpKonfigurationLang v) {
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
		wertpapier10.setLabelFor(wertpapier1, true)
		konfiguration10.setLabelFor(konfiguration1, true)
		wertpapier20.setLabelFor(wertpapier2, false)
		konfiguration20.setLabelFor(konfiguration2, false)
		wertpapier30.setLabelFor(wertpapier3, false)
		konfiguration30.setLabelFor(konfiguration3, false)
		initDaten(0)
		wertpapier1.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var wliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			wertpapier1.setItems(getItems(wliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			wertpapier2.setItems(getItems(wliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			wertpapier3.setItems(getItems(wliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			var kliste = get(FactoryService::wertpapierService.getKonfigurationListe(serviceDaten, false, null))
			konfiguration1.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			konfiguration2.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			konfiguration3.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			var List<String> uids = parameter1
			if (Global::listLaenge(uids) >= 6) {
				setText(wertpapier1, uids.get(0))
				setText(konfiguration1, uids.get(1))
				setText(wertpapier2, uids.get(2))
				setText(konfiguration2, uids.get(3))
				setText(wertpapier3, uids.get(4))
				setText(konfiguration3, uids.get(5))
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

		var uids = new ArrayList<String>
		uids.add(getText(wertpapier1))
		uids.add(getText(konfiguration1))
		uids.add(getText(wertpapier2))
		uids.add(getText(konfiguration2))
		uids.add(getText(wertpapier3))
		uids.add(getText(konfiguration3))
		close(uids)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

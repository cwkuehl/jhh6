package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
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
 * Controller für Dialog WP260Anlage.
 */
class WP260AnlageController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label wertpapier0
	@FXML ComboBox<RelationData> wertpapier
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label daten0
	@FXML TextArea daten
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Status.
	 */
	static class StatusData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.schluessel
		}

		override String toString() {
			return getData.wert
		}
	}

	/** 
	 * Daten für ComboBox Relation.
	 */
	static class RelationData extends ComboBoxData<WpWertpapierLang> {

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
		nr0.setLabelFor(nr)
		wertpapier0.setLabelFor(wertpapier, true)
		bezeichnung0.setLabelFor(bezeichnung, true)
		notiz0.setLabelFor(notiz)
		daten0.setLabelFor(daten)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		bezeichnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var wliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			wertpapier.setItems(getItems(wliste, new WpWertpapierLang, [a|new RelationData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var WpAnlageLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::wertpapierService.getAnlageLang(serviceDaten, k.uid))
			}
			if (!neu && k !== null) {
				nr.setText(k.uid)
				setText(wertpapier, k.wertpapierUid)
				bezeichnung.setText(k.bezeichnung)
				daten.setText(k.daten)
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			setEditable(wertpapier, neu)
			setEditable(wertpapier, !loeschen)
			bezeichnung.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			daten.setEditable(false)
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
			r = FactoryService::wertpapierService.insertUpdateAnlage(serviceDaten, null, getText(wertpapier),
				bezeichnung.text, notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::wertpapierService.insertUpdateAnlage(serviceDaten, nr.text, getText(wertpapier),
				bezeichnung.text, notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::wertpapierService.deleteAnlage(serviceDaten, nr.text)
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

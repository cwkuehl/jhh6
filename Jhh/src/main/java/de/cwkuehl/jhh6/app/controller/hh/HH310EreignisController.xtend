package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.dto.HhEreignis
import de.cwkuehl.jhh6.api.dto.HhEreignisLang
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.TextField

/** 
 * Controller für Dialog HH310Ereignis.
 */
class HH310EreignisController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label kennzeichen0
	@FXML TextField kennzeichen
	@FXML Label eText0
	@FXML TextField eText
	@FXML Label sollkonto0
	@FXML ListView<SollkontoData> sollkonto
	@FXML Label habenkonto0
	@FXML ListView<HabenkontoData> habenkonto
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button kontentausch

	// @FXML Button abbrechen
	/** 
	 * Daten für ListBox Sollkonto.
	 */
	static class SollkontoData extends ComboBoxData<HhKonto> {

		new(HhKonto v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Daten für ListBox Habenkonto.
	 */
	static class HabenkontoData extends ComboBoxData<HhKonto> {

		new(HhKonto v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		bezeichnung0.setLabelFor(bezeichnung)
		kennzeichen0.setLabelFor(kennzeichen)
		eText0.setLabelFor(eText)
		sollkonto0.setLabelFor(sollkonto)
		initListView(habenkonto, null)
		habenkonto0.setLabelFor(habenkonto)
		initListView(sollkonto, null)
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
			var kl = get(FactoryService::haushaltService.getKontoListe(serviceDaten, null, null))
			sollkonto.setItems(getItems(kl, null, [a|new SollkontoData(a)], null))
			habenkonto.setItems(getItems(kl, null, [a|new HabenkontoData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HhEreignisLang e = parameter1
			if (!neu && e !== null) {
				var HhEreignis k = get(FactoryService::haushaltService.getEreignis(serviceDaten, e.uid))
				if (k !== null) {
					nr.setText(k.uid)
					bezeichnung.setText(k.bezeichnung)
					kennzeichen.setText(k.kz)
					eText.setText(k.etext)
					setText(sollkonto, k.sollKontoUid)
					setText(habenkonto, k.habenKontoUid)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
				}
			}
			nr.setEditable(false)
			bezeichnung.setEditable(!loeschen)
			kennzeichen.setEditable(!loeschen)
			eText.setEditable(!loeschen)
			setEditable(sollkonto, !loeschen)
			setEditable(habenkonto, !loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			kontentausch.setVisible(!loeschen)
		}
		if (stufe <= 1) {
			// stufe = 0;
		}
		if (stufe <= 2) {
			// initDatenTable;
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
			r = FactoryService::haushaltService.insertUpdateEreignis(serviceDaten, null, kennzeichen.text,
				getText(sollkonto), getText(habenkonto), bezeichnung.text, eText.text, null, null, null, null, null, //
				false)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateEreignis(serviceDaten, nr.text, kennzeichen.text,
				getText(sollkonto), getText(habenkonto), bezeichnung.text, eText.text, null, null, null, null, null, //
				false)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::haushaltService.deleteEreignis(serviceDaten, nr.text)
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
	 * Event für Kontentausch.
	 */
	@FXML def void onKontentausch() {
		var s = getText(sollkonto)
		var h = getText(habenkonto)
		setText(sollkonto, h)
		setText(habenkonto, s)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

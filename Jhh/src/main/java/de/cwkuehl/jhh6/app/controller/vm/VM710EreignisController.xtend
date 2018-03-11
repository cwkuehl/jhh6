package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.HhEreignisVm
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM710Ereignis.
 */
class VM710EreignisController extends BaseController<String> {

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
	@FXML Label schluessel0
	@FXML TextField schluessel
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	@FXML Label notiz0
	@FXML TextArea notiz
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
	 * Daten für ComboBox Mieter.
	 */
	static class MieterData extends ComboBoxData<VmMieterLang> {

		new(VmMieterLang v) {
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
		bezeichnung0.setLabelFor(bezeichnung, true)
		kennzeichen0.setLabelFor(kennzeichen)
		eText0.setLabelFor(eText, true)
		sollkonto0.setLabelFor(sollkonto, true)
		initListView(sollkonto, ok)
		habenkonto0.setLabelFor(habenkonto, true)
		initListView(habenkonto, ok)
		schluessel0.setLabelFor(schluessel)
		haus0.setLabelFor(haus, false)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		notiz0.setLabelFor(notiz)
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
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var ml = get(FactoryService::vermietungService.getMieterListe(serviceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HhEreignisVm k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::vermietungService.getEreignisVm(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					bezeichnung.setText(k.bezeichnung)
					kennzeichen.setText(k.kz)
					eText.setText(k.etext)
					setText(sollkonto, k.sollKontoUid)
					setText(habenkonto, k.habenKontoUid)
					schluessel.setText(k.schluessel)
					setText(haus, k.hausUid)
					setText(wohnung, k.wohnungUid)
					setText(mieter, k.mieterUid)
					notiz.setText(k.notiz)
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
			schluessel.setEditable(!loeschen)
			setEditable(haus, !loeschen)
			setEditable(wohnung, !loeschen)
			setEditable(mieter, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			kontentausch.setVisible(!loeschen)
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
	 * Event für Haus.
	 */
	@FXML def void onHaus() {

		var VmHaus h = getValue(haus, false)
		var VmWohnungLang w = getValue(wohnung, false)
		if (h !== null && w !== null && Global::compString(h.uid, w.hausUid) !== 0) {
			setText(wohnung, null)
			setText(mieter, null)
		}
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {

		var VmWohnungLang w = getValue(wohnung, false)
		if (w !== null && !Global::nes(w.uid)) {
			setText(haus, w.hausUid)
			var VmMieterLang m = getValue(mieter, false)
			if (m !== null && Global::compString(w.uid, m.wohnungUid) !== 0) {
				setText(mieter, null)
			}
		}
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {

		var VmMieterLang m = getValue(mieter, false)
		if (m !== null && !Global::nes(m.uid)) {
			setText(wohnung, m.wohnungUid)
			onWohnung
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateEreignis(getServiceDaten, null, kennzeichen.text,
				getText(sollkonto), getText(habenkonto), bezeichnung.text, eText.text, schluessel.text, getText(haus),
				getText(wohnung), getText(mieter), notiz.text, true)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateEreignis(serviceDaten, nr.text, kennzeichen.text,
				getText(sollkonto), getText(habenkonto), bezeichnung.text, eText.text, schluessel.text, getText(haus),
				getText(wohnung), getText(mieter), notiz.text, true)
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

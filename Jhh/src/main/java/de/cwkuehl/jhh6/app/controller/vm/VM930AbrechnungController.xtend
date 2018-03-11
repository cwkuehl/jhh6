package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmAbrechnungLang
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM930Abrechnung.
 */
class VM930AbrechnungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	@FXML Label schluessel0
	@FXML TextField schluessel
	@FXML Label beschreibung0
	@FXML TextField beschreibung
	@FXML Label wert0
	@FXML TextField wert
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label reihenfolge0
	@FXML TextField reihenfolge
	@FXML Label status0
	@FXML TextField status
	@FXML Label funktion0
	@FXML TextField funktion
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
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
		von0.setLabelFor(von.labelForNode, true)
		bis0.setLabelFor(bis.labelForNode, true)
		haus0.setLabelFor(haus, true)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		schluessel0.setLabelFor(schluessel, true)
		beschreibung0.setLabelFor(beschreibung)
		wert0.setLabelFor(wert, true)
		betrag0.setLabelFor(betrag)
		datum0.setLabelFor(datum.labelForNode)
		reihenfolge0.setLabelFor(reihenfolge)
		status0.setLabelFor(status)
		funktion0.setLabelFor(funktion)
		notiz0.setLabelFor(notiz)
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
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var ml = get(FactoryService::vermietungService.getMieterListe(serviceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var aendern = DialogAufrufEnum::AENDERN.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var VmAbrechnungLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::vermietungService.getAbrechnungLang(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					setText(haus, k.hausUid)
					setText(wohnung, k.wohnungUid)
					setText(mieter, k.mieterUid)
					von.setValue(k.datumVon)
					bis.setValue(k.datumBis)
					schluessel.setText(k.schluessel)
					beschreibung.setText(k.beschreibung)
					wert.setText(k.wert)
					betrag.setText(Global::dblStr2l(k.betrag))
					datum.setValue(k.datum)
					reihenfolge.setText(k.reihenfolge)
					status.setText(k.status)
					funktion.setText(k.funktion)
					notiz.setText(k.notiz)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
				}
			}
			nr.setEditable(false)
			setEditable(haus, !(loeschen || aendern))
			setEditable(wohnung, !(loeschen || aendern))
			setEditable(mieter, !(loeschen || aendern))
			von.setEditable(!loeschen)
			bis.setEditable(!loeschen)
			schluessel.setEditable(!(loeschen || aendern))
			beschreibung.setEditable(!loeschen)
			wert.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
			datum.setEditable(!loeschen)
			reihenfolge.setEditable(!loeschen)
			status.setEditable(!loeschen)
			funktion.setEditable(!loeschen)
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
	 * Event für Von.
	 */
	@FXML def void onVon() {
		// view.setBisValue(Global.datumPlusMinus(view.getVonValue, -1, 0, 1))
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
			r = FactoryService::vermietungService.insertUpdateAbrechnung(serviceDaten, null, getText(haus),
				getText(wohnung), getText(mieter), von.value, bis.value, schluessel.text, beschreibung.text, wert.text,
				Global::strDbl(betrag.text), datum.value2, reihenfolge.text, status.text, funktion.text, notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateAbrechnung(serviceDaten, nr.text, getText(haus),
				getText(wohnung), getText(mieter), von.value, bis.value, schluessel.text, beschreibung.text, wert.text,
				Global::strDbl(betrag.text), datum.value2, reihenfolge.text, status.text, funktion.text, notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::vermietungService.deleteAbrechnung(serviceDaten, nr.text)
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

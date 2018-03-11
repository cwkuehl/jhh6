package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmMieteLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
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
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM410Miete.
 */
class VM410MieteController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label miete0
	@FXML TextField miete
	@FXML Label garage0
	@FXML TextField garage
	@FXML Label summe10
	@FXML TextField summe1
	@FXML Label nebenkosten0
	@FXML TextField nebenkosten
	@FXML Label heizung0
	@FXML TextField heizung
	@FXML Label summe20
	@FXML TextField summe2
	@FXML Label summe30
	@FXML TextField summe3
	@FXML Label personen0
	@FXML TextField personen
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
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
		nr0.setLabelFor(nr)
		wohnung0.setLabelFor(wohnung, true)
		datum0.setLabelFor(datum.labelForNode, true)
		miete0.setLabelFor(miete, true)
		garage0.setLabelFor(garage)
		summe10.setLabelFor(summe1)
		nebenkosten0.setLabelFor(nebenkosten)
		heizung0.setLabelFor(heizung)
		summe20.setLabelFor(summe2)
		summe30.setLabelFor(summe3)
		personen0.setLabelFor(personen, true)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		wohnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			datum.setValue(LocalDate::now)
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, null, [a|new WohnungData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var VmMieteLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::vermietungService.getMieteLang(serviceDaten, false, k.uid, null, null))
				nr.setText(k.uid)
				setText(wohnung, k.wohnungUid)
				datum.setValue(k.datum)
				miete.setText(Global::dblStr2l(k.miete))
				garage.setText(Global::dblStr2l(k.garage))
				nebenkosten.setText(Global::dblStr2l(k.nebenkosten))
				heizung.setText(Global::dblStr2l(k.heizung))
				personen.setText(Global::intStr(k.personen))
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			nr.setFocusTraversable(false)
			setEditable(wohnung, !loeschen)
			datum.setEditable(!loeschen)
			miete.setEditable(!loeschen)
			garage.setEditable(!loeschen)
			nebenkosten.setEditable(!loeschen)
			heizung.setEditable(!loeschen)
			summe1.setEditable(false)
			summe1.setFocusTraversable(false)
			summe2.setEditable(false)
			summe2.setFocusTraversable(false)
			summe3.setEditable(false)
			summe3.setFocusTraversable(false)
			personen.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			angelegt.setFocusTraversable(false)
			geaendert.setEditable(false)
			geaendert.setFocusTraversable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
		}
		if (stufe <= 1) {
			onSummen
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
			r = FactoryService::vermietungService.insertUpdateMiete(serviceDaten, null, getText(wohnung), datum.value,
				Global::strDbl(miete.text), Global::strDbl(nebenkosten.text), Global::strDbl(garage.text),
				Global::strDbl(heizung.text), Global::strInt(personen.text), notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateMiete(serviceDaten, nr.text, getText(wohnung),
				datum.value, Global::strDbl(miete.text), Global::strDbl(nebenkosten.text), Global::strDbl(garage.text),
				Global::strDbl(heizung.text), Global::strInt(personen.text), notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::vermietungService.deleteMiete(serviceDaten, nr.text)
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

	@FXML def private void onSummen() {
		summe1.setText(Global::dblStr2l(Global::strDbl(miete.text) + Global::strDbl(garage.text)))
		summe2.setText(Global::dblStr2l(Global::strDbl(nebenkosten.text) + Global::strDbl(heizung.text)))
		summe3.setText(Global::dblStr2l(Global::strDbl(summe1.text) + Global::strDbl(summe2.text)))
	}
}

package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppe
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.controller.hp.HP210BehandlungController.LeistungData
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog HP360Leistungsgruppe.
 */
class HP360LeistungsgruppeController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label leistung0
	@FXML ComboBox<LeistungData> leistung
	@FXML Label dauer0
	@FXML TextField dauer
	@FXML Label leistungen0
	@FXML ListView<LeistungenData> leistungen
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button hinzufuegen
	// @FXML Button entfernen
	// @FXML Button abbrechen
	/** 
	 * Daten für ListView Leistungen.
	 */
	static class LeistungenData extends ComboBoxData<HpBehandlungLeistungLang> {

		new(HpBehandlungLeistungLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.leistungBeschreibungFett
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		bezeichnung0.setLabelFor(bezeichnung, true)
		notiz0.setLabelFor(notiz)
		leistung0.setLabelFor(leistung, false)
		dauer0.setLabelFor(dauer)
		leistungen0.setLabelFor(leistungen, true)
		initListView(leistungen, null)
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
			var ll = get(FactoryService::heilpraktikerService.getLeistungListe(serviceDaten, true, false))
			leistung.setItems(getItems(ll, null, [a|new LeistungData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HpLeistungsgruppe k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::heilpraktikerService.getLeistungsgruppe(serviceDaten, k.uid))
				nr.setText(k.uid)
				bezeichnung.setText(k.bezeichnung)
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			bezeichnung.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			var bhl = get(
				FactoryService::heilpraktikerService.getLeistungsgruppeLeistungListe(serviceDaten, true, nr.text, true))
			leistungen.setItems(getItems(bhl, null, [a|new LeistungenData(a)], null))
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
			r = FactoryService::heilpraktikerService.insertUpdateLeistungsgruppe(serviceDaten, null, bezeichnung.text,
				getText(leistung), Global.strDbl(dauer.text), notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateLeistungsgruppe(serviceDaten, nr.text,
				bezeichnung.text, getText(leistung), Global.strDbl(dauer.text), notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deleteLeistungsgruppe(serviceDaten, nr.text)
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
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {

		var liste = leistungen.items
		var HpLeistung l = getValue(leistung, true)
		var HpBehandlungLeistungLang bh = null
		var neu = false
		for (LeistungenData ld : liste) {
			if (ld.data.leistungUid.equals(l.uid)) {
				bh = ld.data
			}
		}
		if (bh === null) {
			neu = true
			bh = new HpBehandlungLeistungLang
		}
		bh.setLeistungUid(l.uid)
		bh.setLeistungZiffer(l.ziffer)
		bh.setLeistungBeschreibungFett(l.beschreibungFett)
		bh.setDauer(Global.strDbl(dauer.text))
		var sb = new StringBuffer(bh.leistungBeschreibungFett)
		Global.anhaengen(sb, ", ", Global.dblStr2l(bh.dauer))
		bh.setLeistungBeschreibungFett(sb.toString)
		if (neu) {
			liste.add(new LeistungenData(bh))
		}
		leistungen.refresh
	}

	/** 
	 * Event für Entfernen.
	 */
	@FXML def void onEntfernen() {

		var liste = leistungen.items
		var sel = getValues(leistungen, false)
		for (HpBehandlungLeistungLang s : sel) {
			for (LeistungenData l : liste) {
				if (s.leistungUid.equals(l.data.leistungUid)) {
					liste.remove(l)
					return
				}
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

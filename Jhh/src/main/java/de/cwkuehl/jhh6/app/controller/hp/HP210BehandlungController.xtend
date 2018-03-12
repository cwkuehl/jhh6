package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlungLang
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.AutoEditor
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent
import javafx.scene.web.HTMLEditor
import org.fxmisc.richtext.StyleClassedTextArea

/** 
 * Controller für Dialog HP210Behandlung.
 */
class HP210BehandlungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label patient0
	@FXML ComboBox<PatientData> patient
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label leistung0
	@FXML ComboBox<LeistungData> leistung
	@FXML Label dauer0
	@FXML TextField dauer
	@FXML package Label leistungen0
	@FXML package ListView<LeistungenData> leistungen
	@FXML package Button hinzufuegen
	@FXML package Button entfernen
	@FXML Label diagnose0
	@FXML TextField diagnose
	@FXML Label status0
	@FXML ComboBox<StatusData> status
	@FXML Label mittel0
	@FXML TextField mittel
	@FXML Label potenz0
	@FXML TextField potenz
	@FXML Label dosierung0
	@FXML TextField dosierung
	@FXML Label verordnung0
	@FXML TextField verordnung
	@FXML Label notiz0
	@FXML StyleClassedTextArea notiz
	@FXML StyleClassedTextArea notiz2
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	// @FXML Button drucken
	// @FXML Button abbrechen
	@FXML package HTMLEditor editor
	/** 
	 * Verbindung zum Thread. 
	 */
	StringBuffer abbruch = new StringBuffer

	/** 
	 * Daten für ComboBox Patient.
	 */
	static class PatientData extends ComboBoxData<HpPatient> {

		new(HpPatient v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name1
		}
	}

	/** 
	 * Daten für ComboBox Leistung.
	 */
	static class LeistungData extends ComboBoxData<HpLeistung> {

		new(HpLeistung v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.beschreibungFett
		}
	}

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
	 * Daten für ComboBox Status.
	 */
	static class StatusData extends ComboBoxData<HpStatus> {

		new(HpStatus v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.status
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		patient0.setLabelFor(patient, true)
		datum0.setLabelFor(datum.labelForNode, true)
		leistung0.setLabelFor(leistung, true)
		dauer0.setLabelFor(dauer)
		leistungen0.setLabelFor(leistungen)
		initListView(leistungen, null)
		diagnose0.setLabelFor(diagnose)
		status0.setLabelFor(status, true)
		mittel0.setLabelFor(mittel)
		potenz0.setLabelFor(potenz)
		dosierung0.setLabelFor(dosierung)
		verordnung0.setLabelFor(verordnung)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		patient.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			datum.setValue(LocalDate::now)
			var pl = get(FactoryService::heilpraktikerService.getPatientListe(serviceDaten, true))
			patient.setItems(getItems(pl, null, [a|new PatientData(a)], null))
			var ll = get(FactoryService::heilpraktikerService.getLeistungListe(serviceDaten, true, true))
			leistung.setItems(getItems(ll, new HpLeistung, [a|new LeistungData(a)], null))
			var sl = get(FactoryService::heilpraktikerService.getStatusListe(serviceDaten, true))
			status.setItems(getItems(sl, null, [a|new StatusData(a)], null))
			var neu0 = DialogAufrufEnum::NEU.equals(aufruf)
			var kopieren = DialogAufrufEnum::KOPIEREN.equals(aufruf)
			var loeschen0 = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			if (parameter1 instanceof String) {
				setText(patient, parameter1 as String)
			} else if (!neu0 && parameter1 instanceof HpBehandlungLang) {
				var l = parameter1 as HpBehandlungLang
				var k = get(FactoryService::heilpraktikerService.getBehandlung(serviceDaten, l.uid))
				nr.setText(k.uid)
				setText(patient, k.patientUid)
				datum.setValue(k.datum)
				dauer.setText(Global::dblStr2l(k.dauer))
				diagnose.setText(k.diagnose)
				setText(leistung, k.leistungUid)
				setText(status, k.statusUid)
				mittel.setText(k.mittel)
				potenz.setText(k.potenz)
				dosierung.setText(k.dosierung)
				verordnung.setText(k.verordnung)
				notiz.replaceText(Global.nn(k.notiz))
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			var bhl = get(
				FactoryService::heilpraktikerService.getBehandlungLeistungListe(serviceDaten, true, null, null, nr.text,
					null, null, false, true))
			leistungen.setItems(getItems(bhl, null, [a|new LeistungenData(a)], null))
			if (neu0) {
				var k = get(FactoryService::heilpraktikerService.getStandardStatus(serviceDaten, 1))
				if (k !== null) {
					setText(status, k.uid)
				}
			}
			nr.setEditable(false)
			setEditable(patient, neu0 || kopieren)
			datum.setEditable(neu0 || kopieren)
			dauer.setEditable(!loeschen0)
			diagnose.setEditable(!loeschen0)
			setEditable(leistung, !loeschen0)
			setEditable(status, !loeschen0)
			mittel.setEditable(!loeschen0)
			potenz.setEditable(!loeschen0)
			dosierung.setEditable(!loeschen0)
			verordnung.setEditable(!loeschen0)
			notiz.setEditable(!loeschen0)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen0) {
				ok.setText(Meldungen::M2001)
			}
			AutoEditor.addHighlightning(notiz, abbruch, notiz2)
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	override protected void onHidden() {
		super.onHidden
		abbruch.append("Abbruch")
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Symptome.
	 */
	@FXML def void onSymptomeMouseClick(MouseEvent e) {
		if (e.clickCount > 1) { // onAendern
		}
	}

	def private void hinzufuegen(HpLeistung l, double d) {

		var liste = leistungen.items
		var HpBehandlungLeistungLang bh
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
		bh.setDauer(d)
		var sb = new StringBuffer(bh.leistungBeschreibungFett)
		Global::anhaengen(sb, ", ", Global::dblStr2l(bh.dauer))
		bh.setLeistungBeschreibungFett(sb.toString)
		if (neu) {
			liste.add(new LeistungenData(bh))
		}
	}

	/** 
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {

		var HpLeistung l = getValue(leistung, true)
		var d = Global::strDbl(dauer.text)
		if (Global::nes(l.ziffer)) {
			// Leistungsgruppe
			var liste = get(
				FactoryService::heilpraktikerService.getLeistungsgruppeLeistungListe(serviceDaten, false, l.uid, false))
			if (liste !== null) {
				var summe = 0.0
				for (HpBehandlungLeistungLang e : liste) {
					summe += e.dauer
				}
				if (Global::compDouble(summe, 0) === 0) {
					summe = 1
				}
				for (HpBehandlungLeistungLang e : liste) {
					l = new HpLeistung
					l.setUid(e.leistungUid)
					l.setZiffer(e.leistungZiffer)
					l.setZifferAlt(e.leistungZifferAlt)
					l.setBeschreibungFett(e.leistungBeschreibungFett)
					hinzufuegen(l, d * e.dauer / summe)
				}
			}
		} else {
			hinzufuegen(l, d)
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
					return;
				}
			}
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateBehandlung(serviceDaten, null, getText(patient),
				datum.value, Global::strInt(dauer.text), diagnose.text, getText(leistung), getText(status), mittel.text,
				potenz.text, dosierung.text, verordnung.text, notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateBehandlung(serviceDaten, nr.text, getText(patient),
				datum.value, Global::strInt(dauer.text), diagnose.text, getText(leistung), getText(status), mittel.text,
				potenz.text, dosierung.text, verordnung.text, notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deleteBehandlung(serviceDaten, nr.text)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {
		var pdf = get(
			FactoryService::heilpraktikerService.getReportPatientenakte(serviceDaten, getText(patient), null, null))
		Werkzeug::speicherReport(pdf, Meldungen::HP018, true)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlung
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
import java.util.List
import javafx.collections.ObservableList
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
			return getData.getUid
		}

		override String toString() {
			return getData.getName1
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
			return getData.getUid
		}

		override String toString() {
			return getData.getBeschreibungFett
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
			return getData.getUid
		}

		override String toString() {
			return getData.getLeistungBeschreibungFett
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
			return getData.getUid
		}

		override String toString() {
			return getData.getStatus
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		patient0.setLabelFor(patient, true)
		datum0.setLabelFor(datum.getLabelForNode, true)
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
			var List<HpPatient> pl = get(
				FactoryService::getHeilpraktikerService.getPatientListe(getServiceDaten, true))
			patient.setItems(getItems(pl, null, [a|new PatientData(a)], null))
			var List<HpLeistung> ll = get(
				FactoryService::getHeilpraktikerService.getLeistungListe(getServiceDaten, true, true))
			leistung.setItems(getItems(ll, new HpLeistung, [a|new LeistungData(a)], null))
			var List<HpStatus> sl = get(
				FactoryService::getHeilpraktikerService.getStatusListe(getServiceDaten, true))
			status.setItems(getItems(sl, null, [a|new StatusData(a)], null))
			var boolean neu0 = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean kopieren = DialogAufrufEnum::KOPIEREN.equals(getAufruf)
			var boolean loeschen0 = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			if (getParameter1 instanceof String) {
				setText(patient, (getParameter1 as String))
			} else if (!neu0 && getParameter1 instanceof HpBehandlungLang) {
				var HpBehandlungLang l = (getParameter1 as HpBehandlungLang)
				var HpBehandlung k = get(
					FactoryService::getHeilpraktikerService.getBehandlung(getServiceDaten, l.getUid))
				nr.setText(k.getUid)
				setText(patient, k.getPatientUid)
				datum.setValue(k.getDatum)
				dauer.setText(Global::dblStr2l(k.getDauer))
				diagnose.setText(k.getDiagnose)
				setText(leistung, k.getLeistungUid)
				setText(status, k.getStatusUid)
				mittel.setText(k.getMittel)
				potenz.setText(k.getPotenz)
				dosierung.setText(k.getDosierung)
				verordnung.setText(k.getVerordnung)
				notiz.replaceText(Global.nn(k.getNotiz))
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			var List<HpBehandlungLeistungLang> bhl = get(
				FactoryService::getHeilpraktikerService.getBehandlungLeistungListe(getServiceDaten, true, null,
					null, nr.text, null, null, false, true))
			leistungen.setItems(getItems(bhl, null, [a|new LeistungenData(a)], null))
			if (neu0) {
				var HpStatus k = get(FactoryService::getHeilpraktikerService.getStandardStatus(getServiceDaten, 1))
				if (k !== null) {
					setText(status, k.getUid)
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
		if (e.clickCount > 1) {		// onAendern
		}
	}

	def private void hinzufuegen(HpLeistung l, double d) {

		var ObservableList<LeistungenData> liste = leistungen.getItems
		var HpBehandlungLeistungLang bh = null
		var boolean neu = false
		for (LeistungenData ld : liste) {
			if (ld.getData.getLeistungUid.equals(l.getUid)) {
				bh = ld.getData
			}
		}
		if (bh === null) {
			neu = true
			bh = new HpBehandlungLeistungLang
		}
		bh.setLeistungUid(l.getUid)
		bh.setLeistungZiffer(l.getZiffer)
		bh.setLeistungBeschreibungFett(l.getBeschreibungFett)
		bh.setDauer(d)
		var StringBuffer sb = new StringBuffer(bh.getLeistungBeschreibungFett)
		Global::anhaengen(sb, ", ", Global::dblStr2l(bh.getDauer))
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
		var double d = Global::strDbl(dauer.text)
		if (Global::nes(l.getZiffer)) {
            // Leistungsgruppe
			var List<HpBehandlungLeistungLang> liste = get(
				FactoryService::getHeilpraktikerService.getLeistungsgruppeLeistungListe(getServiceDaten, false,
					l.getUid, false))
			if (liste !== null) {
				var double summe = 0
				for (HpBehandlungLeistungLang e : liste) {
					summe += e.getDauer
				}
				if (Global::compDouble(summe, 0) === 0) {
					summe = 1
				}
				for (HpBehandlungLeistungLang e : liste) {
					l = new HpLeistung
					l.setUid(e.getLeistungUid)
					l.setZiffer(e.getLeistungZiffer)
					l.setZifferAlt(e.getLeistungZifferAlt)
					l.setBeschreibungFett(e.getLeistungBeschreibungFett)
					hinzufuegen(l, d * e.getDauer / summe)
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

		var ObservableList<LeistungenData> liste = leistungen.getItems
		var List<HpBehandlungLeistungLang> sel = getValues(leistungen, false)
		for (HpBehandlungLeistungLang s : sel) {
			for (LeistungenData l : liste) {
				if (s.getLeistungUid.equals(l.getData.getLeistungUid)) {
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

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getHeilpraktikerService.insertUpdateBehandlung(getServiceDaten, null,
				getText(patient), datum.value, Global::strInt(dauer.text), diagnose.text,
				getText(leistung), getText(status), mittel.text, potenz.text, dosierung.text,
				verordnung.text, notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getHeilpraktikerService.insertUpdateBehandlung(getServiceDaten, nr.text,
				getText(patient), datum.getValue, Global::strInt(dauer.text), diagnose.text,
				getText(leistung), getText(status), mittel.text, potenz.text, dosierung.text,
				verordnung.text, notiz.text, getAllValues(leistungen))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getHeilpraktikerService.deleteBehandlung(getServiceDaten, nr.text)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {
		var byte[] pdf = get(
			FactoryService::getHeilpraktikerService.getReportPatientenakte(getServiceDaten, getText(patient), null,
				null))
		Werkzeug::speicherReport(pdf, Meldungen.HP018, true)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

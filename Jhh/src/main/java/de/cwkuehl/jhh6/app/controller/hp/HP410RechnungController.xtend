package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.dto.HpRechnungLang
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import java.util.Vector
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HP410Rechnung.
 */
class HP410RechnungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label patient0
	@FXML ComboBox<PatientData> patient
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label rechnungsnummer0
	@FXML TextField rechnungsnummer
	@FXML Label diagnose0
	@FXML TextField diagnose
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label status0
	@FXML ComboBox<StatusData> status
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label behandlungen0
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button hinzufuegen
	@FXML Button entfernen

	// @FXML Button abbrechen
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

	@FXML TableView<BehandlungenData> behandlungen
	@FXML TableColumn<BehandlungenData, LocalDate> colDatum
	@FXML TableColumn<BehandlungenData, String> colLeistung
	@FXML TableColumn<BehandlungenData, Double> colDauer
	@FXML TableColumn<BehandlungenData, String> colDiagnose
	@FXML TableColumn<BehandlungenData, String> colStatus
	@FXML TableColumn<BehandlungenData, LocalDateTime> colGa
	@FXML TableColumn<BehandlungenData, String> colGv
	@FXML TableColumn<BehandlungenData, LocalDateTime> colAa
	@FXML TableColumn<BehandlungenData, String> colAv
	ObservableList<BehandlungenData> behandlungenData = FXCollections.observableArrayList
	List<HpBehandlungLeistungLang> listeVorher = new ArrayList<HpBehandlungLeistungLang>
	List<HpBehandlungLeistungLang> listeHinzu = new ArrayList<HpBehandlungLeistungLang>
	List<HpBehandlungLeistungLang> listeEntfernt = new ArrayList<HpBehandlungLeistungLang>

	/** 
	 * Daten für Tabelle Behandlungen.
	 */
	static class BehandlungenData extends BaseController.TableViewData<HpBehandlungLeistungLang> {

		SimpleObjectProperty<LocalDate> datum
		SimpleStringProperty leistung
		SimpleObjectProperty<Double> dauer
		SimpleStringProperty diagnose
		SimpleStringProperty status
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpBehandlungLeistungLang v) {

			super(v)
			datum = new SimpleObjectProperty<LocalDate>(v.behandlungDatum)
			leistung = new SimpleStringProperty(v.leistungZiffer)
			dauer = new SimpleObjectProperty<Double>(v.dauer)
			diagnose = new SimpleStringProperty(v.behandlungDiagnose)
			status = new SimpleStringProperty(v.behandlungStatus)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return getData.uid
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
		rechnungsnummer0.setLabelFor(rechnungsnummer, true)
		diagnose0.setLabelFor(diagnose, true)
		betrag0.setLabelFor(betrag, true)
		status0.setLabelFor(status, true)
		notiz0.setLabelFor(notiz)
		behandlungen0.setLabelFor(behandlungen, true)
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
			rechnungsnummer.setText(
				get(FactoryService::heilpraktikerService.getRechnungsnummer(serviceDaten, null, LocalDate::now)))
			var pl = get(FactoryService::heilpraktikerService.getPatientListe(serviceDaten, true))
			patient.setItems(getItems(pl, null, [a|new PatientData(a)], null))
			var sl = get(FactoryService::heilpraktikerService.getStatusListe(serviceDaten, true))
			status.setItems(getItems(sl, null, [a|new StatusData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var kopieren = DialogAufrufEnum::KOPIEREN.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			if (parameter1 instanceof String) {
				setText(patient, parameter1 as String)
			} else if (!neu && parameter1 instanceof HpRechnungLang) {
				var l = parameter1 as HpRechnungLang
				var k = get(FactoryService::heilpraktikerService.getRechnung(serviceDaten, l.uid))
				nr.setText(k.uid)
				setText(patient, k.patientUid)
				datum.setValue(k.datum)
				rechnungsnummer.setText(k.rechnungsnummer)
				diagnose.setText(k.diagnose)
				betrag.setText(Global.dblStr(k.betrag))
				setText(status, k.statusUid)
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			if (neu) {
				var HpStatus k = get(FactoryService::heilpraktikerService.getStandardStatus(serviceDaten, 2))
				if (k !== null) {
					setText(status, k.uid)
				}
			}
			nr.setEditable(false)
			setEditable(patient, neu)
			datum.setEditable(neu || kopieren)
			rechnungsnummer.setEditable(!loeschen)
			diagnose.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
			setEditable(status, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			hinzufuegen.setVisible(!loeschen)
			entfernen.setVisible(!loeschen)
		}
		if (stufe <= 1) {
			var vliste = new Vector<HpBehandlungLeistungLang>
			var puid = getText(patient)
			var List<HpBehandlungLeistungLang> liste
			if (Global.nes(nr.text)) {
				// alle Behandlungen des Patienten ohne Rechnung
				liste = get(
					FactoryService::heilpraktikerService.getBehandlungLeistungListe(serviceDaten, true, puid,
						"xxx", null, null, null, true, false))
			} else {
				// alle Behandlungen der Rechnung
				liste = get(
					FactoryService::heilpraktikerService.getBehandlungLeistungListe(serviceDaten, true, puid,
						nr.text, null, null, null, false, false)) // nr,-1
			}
			for (HpBehandlungLeistungLang e : liste) {
				if (istUidEnthalten(listeVorher, e.uid) < 0) {
					listeVorher.add(e)
				}
			}
			var summe = 0.0
			summe = addierenListe(puid, listeVorher, vliste, listeEntfernt, summe)
			summe = addierenListe(puid, listeHinzu, vliste, listeEntfernt, summe)
			betrag.setText(Global.dblStr2l(summe))
			diagnose.setText(getDiagnose1(diagnose.text, vliste))
			getItems(vliste, null, [a|new BehandlungenData(a)], behandlungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
		behandlungen.setItems(behandlungenData)
		colDatum.setCellValueFactory([c|c.value.datum])
		colLeistung.setCellValueFactory([c|c.value.leistung])
		colDauer.setCellValueFactory([c|c.value.dauer])
		initColumnBetrag(colDauer)
		colDiagnose.setCellValueFactory([c|c.value.diagnose])
		colStatus.setCellValueFactory([c|c.value.status])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	/** 
	 * Event für Patient.
	 */
	@FXML def void onPatient() {
		listeVorher.clear
		listeHinzu.clear
		listeEntfernt.clear
		diagnose.setText(null)
		initDaten(1)
	}

	/** 
	 * Event für Behandlungen.
	 */
	@FXML def void onBehandlungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			// onAendern
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		var bliste = new ArrayList<HpBehandlungLeistungLang>
		for (BehandlungenData b : behandlungen.items) {
			bliste.add(b.getData)
		}
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateRechnung(serviceDaten, null, rechnungsnummer.text,
				datum.value, getText(patient), Global.strDbl(betrag.text), diagnose.text, getText(status), notiz.text, //
				bliste)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdateRechnung(serviceDaten, nr.text, rechnungsnummer.text,
				datum.value, getText(patient), Global.strDbl(betrag.text), diagnose.text, getText(status), notiz.text, //
				bliste)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deleteRechnung(serviceDaten, nr.text)
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

		var HpRechnungLang k = new HpRechnungLang
		k.setUid(nr.text)
		k.setPatientUid(getText(patient))
		var List<HpBehandlungLeistungLang> l = starteDialog(HP420BehandlungenController, DialogAufrufEnum::OHNE, k)
		if (l !== null) {
			for (HpBehandlungLeistungLang e : l) {
				if (e !== null) {
					var i = istUidEnthalten(listeEntfernt, e.uid)
					if (i >= 0) {
						listeEntfernt.remove(i)
					}
					if (istUidEnthalten(listeHinzu, e.uid) < 0) {
						listeHinzu.add(e)
					}
				}
			}
			initDaten(1)
		}
	}

	/** 
	 * Event für Entfernen.
	 */
	@FXML def void onEntfernen() {

		var HpBehandlungLeistungLang e = getValue(behandlungen, false)
		if (e !== null) {
			for (HpBehandlungLeistungLang b : listeVorher) {
				if (Global.compString(e.uid, b.uid) === 0 ||
					Global.compString(e.behandlungUid, b.behandlungUid) === 0) {
					var i = istUidEnthalten(listeHinzu, b.uid)
					if (i >= 0) {
						listeHinzu.remove(i)
					} else {
						i = istBehEnthalten(listeHinzu, b.behandlungUid)
						if (i >= 0) {
							listeHinzu.remove(i)
						}
					}
					if (istUidEnthalten(listeEntfernt, b.uid) < 0) {
						listeEntfernt.add(b)
					}
					if (istBehEnthalten(listeEntfernt, b.behandlungUid) < 0) {
						listeEntfernt.add(b)
					}
				}
			}
		}
		initDaten(1)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}

	def private int istUidEnthalten(List<HpBehandlungLeistungLang> liste, String uid) {

		for (HpBehandlungLeistungLang e : liste) {
			if (Global.compString(e.uid, uid) === 0) {
				return liste.indexOf(e)
			}
		}
		return -1
	}

	def private int istBehEnthalten(List<HpBehandlungLeistungLang> liste, String uid) {

		for (HpBehandlungLeistungLang e : liste) {
			if (Global.compString(e.behandlungUid, uid) === 0) {
				return liste.indexOf(e)
			}
		}
		return -1
	}

	def private boolean istNichtEnthaltenNichtEntfernt(HpBehandlungLeistungLang e, String patientUid,
		List<HpBehandlungLeistungLang> liste, List<HpBehandlungLeistungLang> listeEntfernt) {

		if (Global.compString(e.patientUid, patientUid) === 0 && istUidEnthalten(liste, e.uid) < 0 &&
			istUidEnthalten(listeEntfernt, e.uid) < 0) {
			return true
		}
		return false
	}

	def private double addierenListe(String patientUid, List<HpBehandlungLeistungLang> liste,
		List<HpBehandlungLeistungLang> vliste, List<HpBehandlungLeistungLang> listeEntfernt, //
		double fsumme) {

		var summe = fsumme
		for (HpBehandlungLeistungLang e : liste) {
			if (istNichtEnthaltenNichtEntfernt(e, patientUid, vliste, listeEntfernt)) {
				vliste.add(e)
				summe += e.leistungBetrag
			}
		}
		return summe
	}

	def private String getDiagnose1(String fdiagnose, List<HpBehandlungLeistungLang> vliste) {

		var diagnose = fdiagnose // Diagnose aus 1. Eintrag
		var diagnose1 = ""
		diagnose = Global.objStr(diagnose)
		if (vliste.size > 0) {
			diagnose1 = Global.objStr(vliste.get(0).behandlungDiagnose)
		}
		if (Global.nes(diagnose)) {
			diagnose = diagnose1
		} else {
			// Diagnose aus 1. Satz, falls Diagnose aus keinen Eintrag passt
			var gefunden = false
			for (var i = 0; i < vliste.size && !gefunden; i++) {
				var HpBehandlungLeistungLang e = vliste.get(i)
				if (!Global.nes(e.behandlungDiagnose) && diagnose.startsWith(Global.objStr(e.behandlungDiagnose))) {
					gefunden = true
				}
			}
			if (!gefunden && !Global.nes(diagnose1)) {
				diagnose = diagnose1
			}
		}
		return diagnose
	}
}

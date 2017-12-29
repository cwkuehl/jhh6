package de.cwkuehl.jhh6.app.controller.hp

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import java.util.Vector
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.dto.HpRechnung
import de.cwkuehl.jhh6.api.dto.HpRechnungLang
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
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
			return getData.getUid
		}

		override String toString() {
			return getData.getName1
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
			datum = new SimpleObjectProperty<LocalDate>(v.getBehandlungDatum)
			leistung = new SimpleStringProperty(v.getLeistungZiffer)
			dauer = new SimpleObjectProperty<Double>(v.getDauer)
			diagnose = new SimpleStringProperty(v.getBehandlungDiagnose)
			status = new SimpleStringProperty(v.getBehandlungStatus)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return getData.getUid
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
			datum.setValue(LocalDate.now)
			rechnungsnummer.setText(
				get(FactoryService.getHeilpraktikerService.getRechnungsnummer(getServiceDaten, null, LocalDate.now)))
			var List<HpPatient> pl = get(FactoryService.getHeilpraktikerService.getPatientListe(getServiceDaten, true))
			patient.setItems(getItems(pl, null, [a|new PatientData(a)], null))
			var List<HpStatus> sl = get(FactoryService.getHeilpraktikerService.getStatusListe(getServiceDaten, true))
			status.setItems(getItems(sl, null, [a|new StatusData(a)], null))
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean kopieren = DialogAufrufEnum.KOPIEREN.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			if (getParameter1 instanceof String) {
				setText(patient, (getParameter1 as String))
			} else if (!neu && getParameter1 instanceof HpRechnungLang) {
				var HpRechnungLang l = (getParameter1 as HpRechnungLang)
				var HpRechnung k = get(FactoryService.getHeilpraktikerService.getRechnung(getServiceDaten, l.getUid))
				nr.setText(k.getUid)
				setText(patient, k.getPatientUid)
				datum.setValue(k.getDatum)
				rechnungsnummer.setText(k.getRechnungsnummer)
				diagnose.setText(k.getDiagnose)
				betrag.setText(Global.dblStr(k.getBetrag))
				setText(status, k.getStatusUid)
				notiz.setText(k.getNotiz)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			if (neu) {
				var HpStatus k = get(FactoryService.getHeilpraktikerService.getStandardStatus(getServiceDaten, 2))
				if (k !== null) {
					setText(status, k.getUid)
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
				ok.setText(Meldungen.M2001)
			}
			hinzufuegen.setVisible(!loeschen)
			entfernen.setVisible(!loeschen)
		}
		if (stufe <= 1) {
			var Vector<HpBehandlungLeistungLang> vliste = new Vector<HpBehandlungLeistungLang>
			var String puid = getText(patient)
			var List<HpBehandlungLeistungLang> liste = null
			if (Global.nes(nr.getText)) {
				// alle Behandlungen des Patienten ohne Rechnung
				liste = get(
					FactoryService.getHeilpraktikerService.getBehandlungLeistungListe(getServiceDaten, true, puid,
						"xxx", null, null, null, true, false))
			} else {
				// alle Behandlungen der Rechnung
				liste = get(
					FactoryService.getHeilpraktikerService.getBehandlungLeistungListe(getServiceDaten, true, puid,
						nr.getText, null, null, null, false, false)) // nr,-1
			}
			for (HpBehandlungLeistungLang e : liste) {
				if (istUidEnthalten(listeVorher, e.getUid) < 0) {
					listeVorher.add(e)
				}
			}
			var double summe = 0
			summe = addierenListe(puid, listeVorher, vliste, listeEntfernt, summe)
			summe = addierenListe(puid, listeHinzu, vliste, listeEntfernt, summe)
			betrag.setText(Global.dblStr2l(summe))
			diagnose.setText(getDiagnose1(diagnose.getText, vliste))
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
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colLeistung.setCellValueFactory([c|c.getValue.leistung])
		colDauer.setCellValueFactory([c|c.getValue.dauer])
		initColumnBetrag(colDauer)
		colDiagnose.setCellValueFactory([c|c.getValue.diagnose])
		colStatus.setCellValueFactory([c|c.getValue.status])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
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
			// onAendern;
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r = null
		var List<HpBehandlungLeistungLang> bliste = new ArrayList<HpBehandlungLeistungLang>
		for (BehandlungenData b : behandlungen.getItems) {
			bliste.add(b.getData)
		}
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdateRechnung(getServiceDaten, null,
				rechnungsnummer.getText, datum.getValue, getText(patient), Global.strDbl(betrag.getText),
				diagnose.getText, getText(status), notiz.getText, bliste)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdateRechnung(getServiceDaten, nr.getText,
				rechnungsnummer.getText, datum.getValue, getText(patient), Global.strDbl(betrag.getText),
				diagnose.getText, getText(status), notiz.getText, bliste)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.deleteRechnung(getServiceDaten, nr.getText)
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
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {

		var HpRechnungLang k = new HpRechnungLang
		k.setUid(nr.getText)
		k.setPatientUid(getText(patient))
		var List<HpBehandlungLeistungLang> l = starteDialog(HP420BehandlungenController, DialogAufrufEnum.OHNE, k)
		if (l !== null) {
			for (HpBehandlungLeistungLang e : l) {
				if (e !== null) {
					var int i = istUidEnthalten(listeEntfernt, e.getUid)
					if (i >= 0) {
						listeEntfernt.remove(i)
					}
					if (istUidEnthalten(listeHinzu, e.getUid) < 0) {
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
				if (Global.compString(e.getUid, b.getUid) === 0 ||
					Global.compString(e.getBehandlungUid, b.getBehandlungUid) === 0) {
					var int i = istUidEnthalten(listeHinzu, b.getUid)
					if (i >= 0) {
						listeHinzu.remove(i)
					} else {
						i = istBehEnthalten(listeHinzu, b.getBehandlungUid)
						if (i >= 0) {
							listeHinzu.remove(i)
						}
					}
					if (istUidEnthalten(listeEntfernt, b.getUid) < 0) {
						listeEntfernt.add(b)
					}
					if (istBehEnthalten(listeEntfernt, b.getBehandlungUid) < 0) {
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
			if (Global.compString(e.getUid, uid) === 0) {
				return liste.indexOf(e)
			}
		}
		return -1
	}

	def private int istBehEnthalten(List<HpBehandlungLeistungLang> liste, String uid) {

		for (HpBehandlungLeistungLang e : liste) {
			if (Global.compString(e.getBehandlungUid, uid) === 0) {
				return liste.indexOf(e)
			}
		}
		return -1
	}

	def private boolean istNichtEnthaltenNichtEntfernt(HpBehandlungLeistungLang e, String patientUid,
		List<HpBehandlungLeistungLang> liste, List<HpBehandlungLeistungLang> listeEntfernt) {

		if (Global.compString(e.getPatientUid, patientUid) === 0 && istUidEnthalten(liste, e.getUid) < 0 &&
			istUidEnthalten(listeEntfernt, e.getUid) < 0) {
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
				summe += e.getLeistungBetrag
			}
		}
		return summe
	}

	def private String getDiagnose1(String fdiagnose, List<HpBehandlungLeistungLang> vliste) {

		var diagnose = fdiagnose // Diagnose aus 1. Eintrag
		var String diagnose1 = ""
		diagnose = Global.objStr(diagnose)
		if (vliste.size > 0) {
			diagnose1 = Global.objStr(vliste.get(0).getBehandlungDiagnose)
		}
		if (Global.nes(diagnose)) {
			diagnose = diagnose1
		} else {
			// Diagnose aus 1. Satz, falls Diagnose aus keinen Eintrag passt
			var boolean gefunden = false
			for (var int i = 0; i < vliste.size && !gefunden; i++) {
				var HpBehandlungLeistungLang e = vliste.get(i)
				if (!Global.nes(e.getBehandlungDiagnose) &&
					diagnose.startsWith(Global.objStr(e.getBehandlungDiagnose))) {
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

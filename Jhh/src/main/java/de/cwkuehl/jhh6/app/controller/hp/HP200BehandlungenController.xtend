package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlungLang
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
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
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HP200Behandlungen.
 */
class HP200BehandlungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Label behandlungen0
	@FXML TableView<BehandlungenData> behandlungen
	@FXML TableColumn<BehandlungenData, String> colPatientUid
	@FXML TableColumn<BehandlungenData, String> colPatientName
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
	@FXML Label patient0
	@FXML ComboBox<PatientData> patient
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Behandlungen.
	 */
	static class BehandlungenData extends BaseController.TableViewData<HpBehandlungLang> {

		SimpleStringProperty uid
		SimpleStringProperty patientName
		SimpleObjectProperty<LocalDate> datum
		SimpleStringProperty leistung
		SimpleObjectProperty<Double> dauer
		SimpleStringProperty diagnose
		SimpleStringProperty status
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpBehandlungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			patientName = new SimpleStringProperty(v.patientName)
			datum = new SimpleObjectProperty<LocalDate>(v.datum)
			leistung = new SimpleStringProperty(v.leistungZiffer)
			dauer = new SimpleObjectProperty<Double>(v.dauer)
			diagnose = new SimpleStringProperty(v.diagnose)
			status = new SimpleStringProperty(v.statusStatus)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}

	/** 
	 * Daten für ComboBox Patient.
	 */
	static class PatientData extends BaseController.ComboBoxData<HpPatient> {

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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		behandlungen0.setLabelFor(behandlungen)
		patient0.setLabelFor(patient, false)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initDaten(0)
		behandlungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var l = get(FactoryService::heilpraktikerService.getPatientListe(serviceDaten, true))
			patient.setItems(getItems(l, new HpPatient, [a|new PatientData(a)], null))
			var HpPatient k = parameter1
			setText(patient, if(k === null) null else k.uid)
			var d = LocalDate::now
			d = d.withDayOfMonth(d.lengthOfMonth)
			bis.setValue(d)
			von.setValue(d.minusYears(1).withDayOfMonth(1))
		}
		if (stufe <= 1) {
			var l = get(
				FactoryService::heilpraktikerService.getBehandlungListe(serviceDaten, false, getText(patient),
					von.value, bis.value))
			getItems(l, null, [a|new BehandlungenData(a)], behandlungenData)
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
		colPatientUid.setCellValueFactory([c|c.value.uid])
		colPatientName.setCellValueFactory([c|c.value.patientName])
		colDatum.setCellValueFactory([c|c.value.datum])
		colLeistung.setCellValueFactory([c|c.value.leistung])
		colDauer.setCellValueFactory([c|c.value.dauer])
		colDiagnose.setCellValueFactory([c|c.value.diagnose])
		colStatus.setCellValueFactory([c|c.value.status])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		if (DialogAufrufEnum::NEU.equals(aufruf)) {
			var k = getText(patient)
			starteFormular(HP210BehandlungController, aufruf, k)
		} else {
			var HpBehandlungLang k = getValue(behandlungen, !DialogAufrufEnum::NEU.equals(aufruf))
			starteFormular(HP210BehandlungController, aufruf, k)
		}
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(behandlungen, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6.rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6.redo)
		onAktuell
	}

	/** 
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum::NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum::KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum::AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum::LOESCHEN)
	}

	/** 
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {
		var pdf = get(
			FactoryService::heilpraktikerService.getReportPatientenakte(serviceDaten, getText(patient), von.value,
				bis.value))
		Werkzeug.speicherReport(pdf, Meldungen::HP018, true)
	}

	/** 
	 * Event für Behandlungen.
	 */
	@FXML def void onBehandlungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Patient.
	 */
	@FXML def void onPatient() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		initDaten(0)
	}
}

package de.cwkuehl.jhh6.app.controller.hp

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HP100Patienten.
 */
class HP100PatientenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML package Button behandeln
	@FXML package Button abrechnen
	@FXML Label patienten0
	@FXML TableView<PatientenData> patienten
	@FXML TableColumn<PatientenData, String> colUid
	@FXML TableColumn<PatientenData, String> colVorname
	@FXML TableColumn<PatientenData, String> colName1
	@FXML TableColumn<PatientenData, LocalDateTime> colGa
	@FXML TableColumn<PatientenData, String> colGv
	@FXML TableColumn<PatientenData, LocalDateTime> colAa
	@FXML TableColumn<PatientenData, String> colAv
	ObservableList<PatientenData> patientenData = FXCollections::observableArrayList

	/** 
	 * Daten für Tabelle Patienten.
	 */
	static class PatientenData extends BaseController.TableViewData<HpPatient> {

		SimpleStringProperty uid
		SimpleStringProperty vorname
		SimpleStringProperty name1
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpPatient v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			vorname = new SimpleStringProperty(v.getVorname)
			name1 = new SimpleStringProperty(v.getName1)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		patienten0.setLabelFor(patienten)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("B", behandeln)
		initAccelerator("R", abrechnen)
		initDaten(0)
		patienten.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<HpPatient> l = get(
				FactoryService::getHeilpraktikerService.getPatientListe(getServiceDaten, false))
			getItems(l, null, [a|new PatientenData(a)], patientenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		patienten.setItems(patientenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colVorname.setCellValueFactory([c|c.getValue.vorname])
		colName1.setCellValueFactory([c|c.getValue.name1])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HpPatient k = getValue(patienten, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(HP110PatientController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(patienten, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6::rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6::redo)
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
	 * Event für Patienten.
	 */
	@FXML def void onPatientenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	@FXML def void onBehandeln() {
		// var HpPatient k = getValue(patienten, true)
		// starteFormular(typeof(HP200BehandlungenController), DialogAufrufEnum::OHNE, k)
	}

	@FXML def void onAbrechnen() {
		// var HpPatient k = getValue(patienten, true)
		// starteFormular(typeof(HP410RechnungController), DialogAufrufEnum::NEU, k.getUid)
	}
}

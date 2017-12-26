package de.cwkuehl.jhh6.app.controller.hp

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.global.Global
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
 * Controller für Dialog HP150Status.
 */
class HP150StatusController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label status0
	@FXML TableView<StatusData> status
	@FXML TableColumn<StatusData, String> colUid
	@FXML TableColumn<StatusData, String> colStatus
	@FXML TableColumn<StatusData, String> colBeschreibung
	@FXML TableColumn<StatusData, String> colSortierung
	@FXML TableColumn<StatusData, LocalDateTime> colGa
	@FXML TableColumn<StatusData, String> colGv
	@FXML TableColumn<StatusData, LocalDateTime> colAa
	@FXML TableColumn<StatusData, String> colAv
	ObservableList<StatusData> statusData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Status.
	 */
	static class StatusData extends BaseController.TableViewData<HpStatus> {

		SimpleStringProperty uid
		SimpleStringProperty status
		SimpleStringProperty beschreibung
		SimpleStringProperty sortierung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpStatus v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			status = new SimpleStringProperty(v.getStatus)
			beschreibung = new SimpleStringProperty(v.getBeschreibung)
			sortierung = new SimpleStringProperty(Global.intStrFormat(v.getSortierung))
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
		status0.setLabelFor(status)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		status.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<HpStatus> l = get(FactoryService.getHeilpraktikerService.getStatusListe(getServiceDaten, false))
			getItems(l, null, [a|new StatusData(a)], statusData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		status.setItems(statusData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colStatus.setCellValueFactory([c|c.getValue.status])
		colBeschreibung.setCellValueFactory([c|c.getValue.beschreibung])
		colSortierung.setCellValueFactory([c|c.getValue.sortierung])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HpStatus k = getValue(status, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(HP160StatusController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(status, 1)
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
		starteDialog(DialogAufrufEnum.NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum.KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum.AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum.LOESCHEN)
	}

	/** 
	 * Event für Status.
	 */
	@FXML def void onStatusMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

package de.cwkuehl.jhh6.app.controller.mo

import de.cwkuehl.jhh6.api.dto.MoGottesdienst
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
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
 * Controller für Dialog MO200Gottesdienste.
 */
class MO200GottesdiensteController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Button imExport
	@FXML Label gottesdienste0
	@FXML TableView<GottesdiensteData> gottesdienste
	@FXML TableColumn<GottesdiensteData, String> colUid
	@FXML TableColumn<GottesdiensteData, LocalDateTime> colTermin
	@FXML TableColumn<GottesdiensteData, String> colOrt
	@FXML TableColumn<GottesdiensteData, String> colName
	@FXML TableColumn<GottesdiensteData, LocalDateTime> colGa
	@FXML TableColumn<GottesdiensteData, String> colGv
	@FXML TableColumn<GottesdiensteData, LocalDateTime> colAa
	@FXML TableColumn<GottesdiensteData, String> colAv
	ObservableList<GottesdiensteData> gottesdiensteData = FXCollections.observableArrayList
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Gottesdienste.
	 */
	static class GottesdiensteData extends BaseController.TableViewData<MoGottesdienst> {

		SimpleStringProperty uid
		SimpleObjectProperty<LocalDateTime> termin
		SimpleStringProperty ort
		SimpleStringProperty name
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MoGottesdienst v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			termin = new SimpleObjectProperty<LocalDateTime>(v.getTermin)
			ort = new SimpleStringProperty(v.getOrt)
			name = new SimpleStringProperty(v.getName)
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
		gottesdienste0.setLabelFor(gottesdienste)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initAccelerator("X", imExport)
		initDaten(0)
		gottesdienste.setPrefWidth(2000)
		gottesdienste.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// nächsten Montag vorblenden
			var LocalDate d = LocalDate.now
			while (!d.getDayOfWeek.equals(DayOfWeek.MONDAY)) {
				d = d.plusDays(1)
			}
			von.setValue(d)
			bis.setValue(d.plusDays(20))
		}
		if (stufe <= 1) {
			var List<MoGottesdienst> l = get(
				FactoryService::messdienerService.getGottesdienstListe(serviceDaten, false, von.value, bis.value))
			getItems(l, null, [a|new GottesdiensteData(a)], gottesdiensteData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		gottesdienste.setItems(gottesdiensteData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colTermin.setCellValueFactory([c|c.getValue.termin])
		colOrt.setCellValueFactory([c|c.getValue.ort])
		colName.setCellValueFactory([c|c.getValue.name])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var MoGottesdienst k = getValue(gottesdienste, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(MO210GottesdienstController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(gottesdienste, 1)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {

		var byte[] pdf = get(
			FactoryService::messdienerService.getReportMessdienerordnung(serviceDaten, von.value, bis.value))
		Werkzeug.speicherReport(pdf, Meldungen.MO036(von.value.atStartOfDay, bis.value.atStartOfDay), false)
	}

	/** 
	 * Event für ImExport.
	 */
	@FXML def void onImExport() {
		starteFormular(MO500SchnittstelleController, DialogAufrufEnum.OHNE)
	}

	/** 
	 * Event für Gottesdienste.
	 */
	@FXML def void onGottesdiensteMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Von.
	 */
	@FXML def void onVon() {
		onAktuell
	}

	/** 
	 * Event für Bis.
	 */
	@FXML def void onBis() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(gottesdienste, 0)
	}
}

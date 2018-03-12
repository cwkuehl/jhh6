package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpRechnungLang
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
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
 * Controller für Dialog HP400Rechnungen.
 */
class HP400RechnungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Label rechnungen0
	@FXML TableView<RechnungenData> rechnungen
	@FXML TableColumn<RechnungenData, String> colUid
	@FXML TableColumn<RechnungenData, LocalDate> colDatum
	@FXML TableColumn<RechnungenData, String> colRechnungsnummer
	@FXML TableColumn<RechnungenData, String> colName
	@FXML TableColumn<RechnungenData, Double> colBetrag
	@FXML TableColumn<RechnungenData, LocalDateTime> colGa
	@FXML TableColumn<RechnungenData, String> colGv
	@FXML TableColumn<RechnungenData, LocalDateTime> colAa
	@FXML TableColumn<RechnungenData, String> colAv
	ObservableList<RechnungenData> rechnungenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Rechnungen.
	 */
	static class RechnungenData extends BaseController.TableViewData<HpRechnungLang> {

		SimpleStringProperty uid
		SimpleObjectProperty<LocalDate> datum
		SimpleStringProperty rechnungsnummer
		SimpleStringProperty name
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpRechnungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			datum = new SimpleObjectProperty<LocalDate>(v.datum)
			rechnungsnummer = new SimpleStringProperty(v.rechnungsnummer)
			name = new SimpleStringProperty(v.patientName)
			betrag = new SimpleObjectProperty<Double>(v.betrag)
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		rechnungen0.setLabelFor(rechnungen)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initDaten(0)
		rechnungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::heilpraktikerService.getRechnungListe(serviceDaten, false))
			getItems(l, null, [a|new RechnungenData(a)], rechnungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		rechnungen.setItems(rechnungenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colDatum.setCellValueFactory([c|c.value.datum])
		colRechnungsnummer.setCellValueFactory([c|c.value.rechnungsnummer])
		colName.setCellValueFactory([c|c.value.name])
		colBetrag.setCellValueFactory([c|c.value.betrag])
		initColumnBetrag(colBetrag)
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HpRechnungLang k = getValue(rechnungen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(HP410RechnungController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(rechnungen, 1)
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
		var HpRechnungLang k = getValue(rechnungen, true)
		var pdf = get(FactoryService::heilpraktikerService.getReportRechnung(serviceDaten, k.uid))
		Werkzeug.speicherReport(pdf, Meldungen::HP019, true)
	}

	/** 
	 * Event für Rechnungen.
	 */
	@FXML def void onRechnungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

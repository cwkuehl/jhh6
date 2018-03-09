package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.FzFahrradLang
import de.cwkuehl.jhh6.api.dto.FzFahrradstandLang
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
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog FZ250Fahrradstaende.
 */
class FZ250FahrradstaendeController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label fahrradstaende0
	@FXML TableView<FahrradstaendeData> fahrradstaende
	@FXML TableColumn<FahrradstaendeData, String> colFahrrad
	@FXML TableColumn<FahrradstaendeData, LocalDate> colDatum
	@FXML TableColumn<FahrradstaendeData, Integer> colNr
	@FXML TableColumn<FahrradstaendeData, Long> colZaehler
	@FXML TableColumn<FahrradstaendeData, Long> colKm
	@FXML TableColumn<FahrradstaendeData, Double> colSchnitt
	@FXML TableColumn<FahrradstaendeData, String> colBeschreibung
	@FXML TableColumn<FahrradstaendeData, LocalDateTime> colGa
	@FXML TableColumn<FahrradstaendeData, String> colGv
	@FXML TableColumn<FahrradstaendeData, LocalDateTime> colAa
	@FXML TableColumn<FahrradstaendeData, String> colAv
	ObservableList<FahrradstaendeData> fahrradstaendeData = FXCollections.observableArrayList
	@FXML Label fahrrad0
	@FXML ComboBox<FahrradData> fahrrad
	@FXML Label text0
	@FXML TextField text

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Fahrradstaende.
	 */
	static class FahrradstaendeData extends BaseController.TableViewData<FzFahrradstandLang> {

		SimpleStringProperty fahrrad
		SimpleObjectProperty<LocalDate> datum
		SimpleObjectProperty<Integer> nr
		SimpleObjectProperty<Long> zaehler
		SimpleObjectProperty<Long> km
		SimpleObjectProperty<Double> schnitt
		SimpleStringProperty beschreibung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(FzFahrradstandLang v) {

			super(v)
			fahrrad = new SimpleStringProperty(v.fahrradBezeichnung)
			datum = new SimpleObjectProperty<LocalDate>(v.datum.toLocalDate)
			nr = new SimpleObjectProperty<Integer>(v.nr)
			zaehler = new SimpleObjectProperty<Long>((v.zaehlerKm as long))
			km = new SimpleObjectProperty<Long>((v.periodeKm as long))
			schnitt = new SimpleObjectProperty<Double>(v.periodeSchnitt)
			beschreibung = new SimpleStringProperty(v.beschreibung)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return '''«nr.get»'''
		}
	}

	/** 
	 * Daten für ComboBox Fahrrad.
	 */
	static class FahrradData extends BaseController.ComboBoxData<FzFahrradLang> {

		new(FzFahrradLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		fahrradstaende0.setLabelFor(fahrradstaende)
		fahrrad0.setLabelFor(fahrrad, false)
		text0.setLabelFor(text)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		fahrradstaende.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<FzFahrradLang> fl = get(FactoryService::freizeitService.getFahrradListe(serviceDaten, true))
			fahrrad.setItems(getItems(fl, new FzFahrradLang, [a|new FahrradData(a)], null))
			setText(fahrrad, null)
			text.setText("%%")
		}
		if (stufe <= 1) {
			var List<FzFahrradstandLang> l = get(
				FactoryService::freizeitService.getFahrradstandListe(serviceDaten, getText(fahrrad), text.text))
			getItems(l, null, [a|new FahrradstaendeData(a)], fahrradstaendeData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		fahrradstaende.setItems(fahrradstaendeData)
		colFahrrad.setCellValueFactory([c|c.value.fahrrad])
		colDatum.setCellValueFactory([c|c.value.datum])
		colNr.setCellValueFactory([c|c.value.nr])
		colZaehler.setCellValueFactory([c|c.value.zaehler])
		colKm.setCellValueFactory([c|c.value.km])
		colSchnitt.setCellValueFactory([c|c.value.schnitt])
		colBeschreibung.setCellValueFactory([c|c.value.beschreibung])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
		initColumnBetrag(colSchnitt)
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var FzFahrradstandLang k = getValue(fahrradstaende, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(FZ260FahrradstandController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(fahrradstaende, 1)
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
	 * Event für Fahrradstaende.
	 */
	@FXML def void onFahrradstaendeMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Fahrrad.
	 */
	@FXML def void onFahrrad() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(fahrradstaende, 0)
	}
}

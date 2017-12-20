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
	//@FXML Button alle

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
			fahrrad = new SimpleStringProperty(v.getFahrradBezeichnung)
			datum = new SimpleObjectProperty<LocalDate>(v.getDatum.toLocalDate)
			nr = new SimpleObjectProperty<Integer>(v.getNr)
			zaehler = new SimpleObjectProperty<Long>((v.getZaehlerKm as long))
			km = new SimpleObjectProperty<Long>((v.getPeriodeKm as long))
			schnitt = new SimpleObjectProperty<Double>(v.getPeriodeSchnitt)
			beschreibung = new SimpleStringProperty(v.getBeschreibung)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
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
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		fahrradstaende0.setLabelFor(fahrradstaende)
		fahrrad0.setLabelFor(fahrrad)
		initComboBox(fahrrad, null)
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
			var List<FzFahrradLang> fl = get(
				FactoryService.getFreizeitService.getFahrradListe(getServiceDaten, true))
			fahrrad.setItems(getItems(fl, new FzFahrradLang, [a|new FahrradData(a)], null))
			setText(fahrrad, null)
			text.setText("%%")
		}
		if (stufe <= 1) {
			var List<FzFahrradstandLang> l = get(
				FactoryService.getFreizeitService.getFahrradstandListe(getServiceDaten, getText(fahrrad),
					text.getText))
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
		colFahrrad.setCellValueFactory([c|c.getValue.fahrrad])
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colNr.setCellValueFactory([c|c.getValue.nr])
		colZaehler.setCellValueFactory([c|c.getValue.zaehler])
		colKm.setCellValueFactory([c|c.getValue.km])
		colSchnitt.setCellValueFactory([c|c.getValue.schnitt])
		colBeschreibung.setCellValueFactory([c|c.getValue.beschreibung])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
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

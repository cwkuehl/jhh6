package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
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
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog VM300Mieter.
 */
class VM300MieterController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Label mieter0
	@FXML TableView<MieterData> mieter
	@FXML TableColumn<MieterData, String> colUid
	@FXML TableColumn<MieterData, String> colName
	@FXML TableColumn<MieterData, String> colWohnung
	@FXML TableColumn<MieterData, String> colHaus
	@FXML TableColumn<MieterData, LocalDate> colEinzug
	@FXML TableColumn<MieterData, LocalDate> colAuszug
	@FXML TableColumn<MieterData, Double> colQm
	@FXML TableColumn<MieterData, LocalDateTime> colGa
	@FXML TableColumn<MieterData, String> colGv
	@FXML TableColumn<MieterData, LocalDateTime> colAa
	@FXML TableColumn<MieterData, String> colAv
	ObservableList<MieterData> mieterData = FXCollections::observableArrayList
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Mieter.
	 */
	static class MieterData extends BaseController.TableViewData<VmMieterLang> {

		SimpleStringProperty uid
		SimpleStringProperty name
		SimpleStringProperty wohnung
		SimpleStringProperty haus
		SimpleObjectProperty<LocalDate> einzug
		SimpleObjectProperty<LocalDate> auszug
		SimpleObjectProperty<Double> qm
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(VmMieterLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			name = new SimpleStringProperty(v.getName)
			wohnung = new SimpleStringProperty(v.getWohnungBezeichnung)
			haus = new SimpleStringProperty(v.getHausBezeichnung)
			einzug = new SimpleObjectProperty<LocalDate>(v.getEinzugdatum)
			auszug = new SimpleObjectProperty<LocalDate>(v.getAuszugdatum)
			qm = new SimpleObjectProperty<Double>(v.getWohnungQm)
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
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends BaseController.ComboBoxData<VmHaus> {

		new(VmHaus v) {
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
	 * Daten für ComboBox Wohnung.
	 */
	static class WohnungData extends BaseController.ComboBoxData<VmWohnungLang> {

		new(VmWohnungLang v) {
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
		mieter0.setLabelFor(mieter)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		haus0.setLabelFor(haus)
		wohnung0.setLabelFor(wohnung)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initDaten(0)
		mieter.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<VmHaus> pl = get(FactoryService::getVermietungService.getHausListe(getServiceDaten, true))
			haus.setItems(getItems(pl, new VmHaus, [a|new HausData(a)], null))
			var List<VmWohnungLang> wl = get(
				FactoryService::getVermietungService.getWohnungListe(getServiceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			von.setValue(LocalDate::now.withDayOfYear(1))
			bis.setValue(von.getValue.plusYears(1).minusDays(1))
			setText(haus, null)
			setText(wohnung, null)
		}
		if (stufe <= 1) {
			var List<VmMieterLang> l = get(
				FactoryService::getVermietungService.getMieterListe(getServiceDaten, false, von.getValue, bis.getValue,
					getText(haus), getText(wohnung)))
			getItems(l, null, [a|new MieterData(a)], mieterData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		mieter.setItems(mieterData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colName.setCellValueFactory([c|c.getValue.name])
		colWohnung.setCellValueFactory([c|c.getValue.wohnung])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colEinzug.setCellValueFactory([c|c.getValue.einzug])
		colAuszug.setCellValueFactory([c|c.getValue.auszug])
		colQm.setCellValueFactory([c|c.getValue.qm])
		initColumnBetrag(colQm)
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var VmMieterLang k = getValue(mieter, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(VM310MieterController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(mieter, 1)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {
		var byte[] pdf = get(
			FactoryService::getVermietungService.getReportMieterliste(getServiceDaten, von.getValue, bis.getValue,
				getText(haus)))
		Werkzeug::speicherReport(pdf, "Mieterliste", true)
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieterMouseClick(MouseEvent e) {
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
	 * Event für Haus.
	 */
	@FXML def void onHaus() {
		onAktuell
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(mieter, 0)
	}
}

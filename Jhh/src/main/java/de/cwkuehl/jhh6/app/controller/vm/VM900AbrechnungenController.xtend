package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.util.List
import de.cwkuehl.jhh6.api.dto.VmAbrechnungKurz
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.app.Jhh6
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
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog VM900Abrechnungen.
 */
class VM900AbrechnungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button loeschen
	@FXML Label mieten0
	@FXML TableView<AbrechnungenData> abrechnungen
	@FXML TableColumn<AbrechnungenData, String> colUid
	@FXML TableColumn<AbrechnungenData, String> colHaus
	@FXML TableColumn<AbrechnungenData, LocalDate> colVon
	@FXML TableColumn<AbrechnungenData, LocalDate> colBis
	ObservableList<AbrechnungenData> abrechnungenData = FXCollections::observableArrayList
	@FXML Label von0
	@FXML Datum von
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	//@FXML Button alle

	/** 
	 * Daten für Tabelle Abrechnungen.
	 */
	static class AbrechnungenData extends BaseController.TableViewData<VmAbrechnungKurz> {

		SimpleStringProperty uid
		SimpleStringProperty haus
		SimpleObjectProperty<LocalDate> von
		SimpleObjectProperty<LocalDate> bis

		new(VmAbrechnungKurz v) {

			super(v)
			uid = new SimpleStringProperty(v.getHausUid)
			haus = new SimpleStringProperty(v.getHausBezeichnung)
			von = new SimpleObjectProperty<LocalDate>(v.getDatumVon)
			bis = new SimpleObjectProperty<LocalDate>(v.getDatumBis)
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		mieten0.setLabelFor(abrechnungen)
		von0.setLabelFor(von.getLabelForNode)
		haus0.setLabelFor(haus, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("L", loeschen)
		initDaten(0)
		abrechnungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<VmHaus> hl = get(FactoryService::getVermietungService.getHausListe(getServiceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			von.setValue(LocalDate::now.minusYears(1).withDayOfYear(1))
			setText(haus, null)
		}
		if (stufe <= 1) {
			var List<VmAbrechnungKurz> l = get(
				FactoryService::getVermietungService.getAbrechnungKurzListe(getServiceDaten, von.getValue,
					getText(haus)))
			getItems(l, null, [a|new AbrechnungenData(a)], abrechnungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		abrechnungen.setItems(abrechnungenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colVon.setCellValueFactory([c|c.getValue.von])
		colBis.setCellValueFactory([c|c.getValue.bis])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var VmAbrechnungKurz k = getValue(abrechnungen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(VM910AbrechnungController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(abrechnungen, 1)
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
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum::LOESCHEN)
	}

	/** 
	 * Event für Abrechnungen.
	 */
	@FXML def void onAbrechnungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
		}
	}

	/** 
	 * Event für Von.
	 */
	@FXML def void onVon() {
		onAktuell
	}

	/** 
	 * Event für Haus.
	 */
	@FXML def void onHaus() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(abrechnungen, 0)
	}
}

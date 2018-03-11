package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
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
 * Controller für Dialog VM200Wohnungen.
 */
class VM200WohnungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label wohnungen0
	@FXML TableView<WohnungenData> wohnungen
	@FXML TableColumn<WohnungenData, String> colUid
	@FXML TableColumn<WohnungenData, String> colBezeichnung
	@FXML TableColumn<WohnungenData, String> colHaus
	@FXML TableColumn<WohnungenData, LocalDateTime> colGa
	@FXML TableColumn<WohnungenData, String> colGv
	@FXML TableColumn<WohnungenData, LocalDateTime> colAa
	@FXML TableColumn<WohnungenData, String> colAv
	ObservableList<WohnungenData> wohnungenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Wohnungen.
	 */
	static class WohnungenData extends BaseController.TableViewData<VmWohnungLang> {

		SimpleStringProperty uid
		SimpleStringProperty bezeichnung
		SimpleStringProperty haus
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(VmWohnungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			bezeichnung = new SimpleStringProperty(v.bezeichnung)
			haus = new SimpleStringProperty(v.hausBezeichnung)
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
		wohnungen0.setLabelFor(wohnungen)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		wohnungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, false))
			getItems(l, null, [a|new WohnungenData(a)], wohnungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		wohnungen.setItems(wohnungenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colBezeichnung.setCellValueFactory([c|c.value.bezeichnung])
		colHaus.setCellValueFactory([c|c.value.haus])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var VmWohnungLang k = getValue(wohnungen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(VM210WohnungController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(wohnungen, 1)
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
	 * Event für Wohnungen.
	 */
	@FXML def void onWohnungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

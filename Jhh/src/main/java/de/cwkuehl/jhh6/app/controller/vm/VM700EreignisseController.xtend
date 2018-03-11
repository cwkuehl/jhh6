package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.HhEreignisVm
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
 * Controller für Dialog VM700Ereignisse.
 */
class VM700EreignisseController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label ereignisse0
	@FXML TableView<EreignisseData> ereignisse
	@FXML TableColumn<EreignisseData, String> colUid
	@FXML TableColumn<EreignisseData, String> colBezeichnung
	@FXML TableColumn<EreignisseData, String> colText
	@FXML TableColumn<EreignisseData, String> colSoll
	@FXML TableColumn<EreignisseData, String> colHaben
	@FXML TableColumn<EreignisseData, String> colSchluessel
	@FXML TableColumn<EreignisseData, String> colHaus
	@FXML TableColumn<EreignisseData, String> colWohnung
	@FXML TableColumn<EreignisseData, String> colMieter
	@FXML TableColumn<EreignisseData, LocalDateTime> colGa
	@FXML TableColumn<EreignisseData, String> colGv
	@FXML TableColumn<EreignisseData, LocalDateTime> colAa
	@FXML TableColumn<EreignisseData, String> colAv
	ObservableList<EreignisseData> ereignisseData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Ereignisse.
	 */
	static class EreignisseData extends BaseController.TableViewData<HhEreignisVm> {

		SimpleStringProperty uid
		SimpleStringProperty bezeichnung
		SimpleStringProperty text
		SimpleStringProperty soll
		SimpleStringProperty haben
		SimpleStringProperty schluessel
		SimpleStringProperty haus
		SimpleStringProperty wohnung
		SimpleStringProperty mieter
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhEreignisVm v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			bezeichnung = new SimpleStringProperty(v.bezeichnung)
			text = new SimpleStringProperty(v.etext)
			soll = new SimpleStringProperty(v.sollName)
			haben = new SimpleStringProperty(v.habenName)
			schluessel = new SimpleStringProperty(v.schluessel)
			haus = new SimpleStringProperty(v.hausBezeichnung)
			wohnung = new SimpleStringProperty(v.wohnungBezeichnung)
			mieter = new SimpleStringProperty(v.mieterName)
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
		ereignisse0.setLabelFor(ereignisse)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		ereignisse.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::vermietungService.getEreignisListe(serviceDaten, null, null))
			getItems(l, null, [a|new EreignisseData(a)], ereignisseData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		ereignisse.setItems(ereignisseData)
		colUid.setCellValueFactory([c|c.value.uid])
		colBezeichnung.setCellValueFactory([c|c.value.bezeichnung])
		colText.setCellValueFactory([c|c.value.text])
		colSoll.setCellValueFactory([c|c.value.soll])
		colHaben.setCellValueFactory([c|c.value.haben])
		colSchluessel.setCellValueFactory([c|c.value.schluessel])
		colHaus.setCellValueFactory([c|c.value.haus])
		colWohnung.setCellValueFactory([c|c.value.wohnung])
		colMieter.setCellValueFactory([c|c.value.mieter])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HhEreignisVm k = getValue(ereignisse, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(VM710EreignisController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(ereignisse, 1)
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
	 * Event für Ereignisse.
	 */
	@FXML def void onEreignisseMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmHaus
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
 * Controller für Dialog VM100Haeuser.
 */
class VM100HaeuserController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label haeuser0
	@FXML TableView<HaeuserData> haeuser
	@FXML TableColumn<HaeuserData, String> colUid
	@FXML TableColumn<HaeuserData, String> colBezeichnung
	@FXML TableColumn<HaeuserData, String> colStrasse
	@FXML TableColumn<HaeuserData, String> colPlz
	@FXML TableColumn<HaeuserData, String> colOrt
	@FXML TableColumn<HaeuserData, LocalDateTime> colGa
	@FXML TableColumn<HaeuserData, String> colGv
	@FXML TableColumn<HaeuserData, LocalDateTime> colAa
	@FXML TableColumn<HaeuserData, String> colAv
	ObservableList<HaeuserData> haeuserData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Haeuser.
	 */
	static class HaeuserData extends BaseController.TableViewData<VmHaus> {

		SimpleStringProperty uid
		SimpleStringProperty bezeichnung
		SimpleStringProperty strasse
		SimpleStringProperty plz
		SimpleStringProperty ort
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(VmHaus v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			bezeichnung = new SimpleStringProperty(v.bezeichnung)
			strasse = new SimpleStringProperty(v.strasse)
			plz = new SimpleStringProperty(v.plz)
			ort = new SimpleStringProperty(v.ort)
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
		haeuser0.setLabelFor(haeuser)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		haeuser.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::vermietungService.getHausListe(serviceDaten, false))
			getItems(l, null, [a|new HaeuserData(a)], haeuserData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		haeuser.setItems(haeuserData)
		colUid.setCellValueFactory([c|c.value.uid])
		colBezeichnung.setCellValueFactory([c|c.value.bezeichnung])
		colStrasse.setCellValueFactory([c|c.value.strasse])
		colPlz.setCellValueFactory([c|c.value.plz])
		colOrt.setCellValueFactory([c|c.value.ort])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var VmHaus k = getValue(haeuser, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(VM110HausController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(haeuser, 1)
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
	 * Event für Haeuser.
	 */
	@FXML def void onHaeuserMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

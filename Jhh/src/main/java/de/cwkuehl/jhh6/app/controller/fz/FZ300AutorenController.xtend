package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.FzBuchautor
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
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog FZ300Autoren.
 */
class FZ300AutorenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label autoren0
	@FXML TableView<AutorenData> autoren
	@FXML TableColumn<AutorenData, String> colUid
	@FXML TableColumn<AutorenData, String> colName
	@FXML TableColumn<AutorenData, String> colVorname
	@FXML TableColumn<AutorenData, LocalDateTime> colGa
	@FXML TableColumn<AutorenData, String> colGv
	@FXML TableColumn<AutorenData, LocalDateTime> colAa
	@FXML TableColumn<AutorenData, String> colAv
	ObservableList<AutorenData> autorenData = FXCollections.observableArrayList
	@FXML Label name0
	@FXML TextField name
	//@FXML Button alle

	/** 
	 * Daten für Tabelle Autoren.
	 */
	static class AutorenData extends TableViewData<FzBuchautor> {

		SimpleStringProperty uid
		SimpleStringProperty name
		SimpleStringProperty vorname
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(FzBuchautor v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			name = new SimpleStringProperty(v.name)
			vorname = new SimpleStringProperty(v.vorname)
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
		autoren0.setLabelFor(autoren)
		name0.setLabelFor(name)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		autoren.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			name.setText("%%")
		}
		if (stufe <= 1) {
			var List<FzBuchautor> l = get(
				FactoryService::freizeitService.getAutorListe(serviceDaten, false, name.text))
			getItems(l, null, [a|new AutorenData(a)], autorenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		autoren.setItems(autorenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colName.setCellValueFactory([c|c.value.name])
		colVorname.setCellValueFactory([c|c.value.vorname])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var FzBuchautor k = getValue(autoren, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(FZ310AutorController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(autoren, 1)
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
	 * Event für Autoren.
	 */
	@FXML def void onAutorenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern()
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(autoren, 0)
	}
}

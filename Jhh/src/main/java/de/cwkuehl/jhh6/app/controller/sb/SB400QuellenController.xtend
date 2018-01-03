package de.cwkuehl.jhh6.app.controller.sb

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.SbQuelle
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
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog SB400Quellen.
 */
class SB400QuellenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label quellen0
	@FXML TableView<QuellenData> quellen
	@FXML TableColumn<QuellenData, String> colUid
	@FXML TableColumn<QuellenData, String> colAutor
	@FXML TableColumn<QuellenData, String> colBeschreibung
	@FXML TableColumn<QuellenData, LocalDateTime> colGa
	@FXML TableColumn<QuellenData, String> colGv
	@FXML TableColumn<QuellenData, LocalDateTime> colAa
	@FXML TableColumn<QuellenData, String> colAv
	ObservableList<QuellenData> quellenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Quellen.
	 */
	static class QuellenData extends BaseController.TableViewData<SbQuelle> {

		SimpleStringProperty uid
		SimpleStringProperty autor
		SimpleStringProperty beschreibung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(SbQuelle v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			autor = new SimpleStringProperty(v.getAutor)
			beschreibung = new SimpleStringProperty(v.getBeschreibung)
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
		quellen0.setLabelFor(quellen)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		quellen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<SbQuelle> l = get(FactoryService.getStammbaumService.getQuelleListe(getServiceDaten, false))
			getItems(l, null, [a|new QuellenData(a)], quellenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		quellen.setItems(quellenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colAutor.setCellValueFactory([c|c.getValue.autor])
		colBeschreibung.setCellValueFactory([c|c.getValue.beschreibung])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var SbQuelle k = getValue(quellen, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(SB410QuelleController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(quellen, 1)
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
	 * Event für Quellen.
	 */
	@FXML def void onQuellenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}
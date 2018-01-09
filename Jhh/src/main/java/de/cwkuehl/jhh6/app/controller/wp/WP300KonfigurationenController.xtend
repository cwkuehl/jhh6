package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
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
 * Controller für Dialog WP300Konfigurationen.
 */
class WP300KonfigurationenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label konfigurationen0
	@FXML TableView<KonfigurationenData> konfigurationen
	@FXML TableColumn<KonfigurationenData, String> colUid
	@FXML TableColumn<KonfigurationenData, String> colBezeichnung
	@FXML TableColumn<KonfigurationenData, LocalDateTime> colGa
	@FXML TableColumn<KonfigurationenData, String> colGv
	@FXML TableColumn<KonfigurationenData, LocalDateTime> colAa
	@FXML TableColumn<KonfigurationenData, String> colAv
	ObservableList<KonfigurationenData> konfigurationenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Konfigurationen.
	 */
	static class KonfigurationenData extends BaseController.TableViewData<WpKonfigurationLang> {

		SimpleStringProperty uid
		SimpleStringProperty bezeichnung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpKonfigurationLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			bezeichnung = new SimpleStringProperty(v.getBezeichnung)
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
		konfigurationen0.setLabelFor(konfigurationen)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		konfigurationen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<WpKonfigurationLang> l = get(
				FactoryService.getWertpapierService.getKonfigurationListe(getServiceDaten, false, null))
			getItems(l, null, [a|new KonfigurationenData(a)], konfigurationenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		konfigurationen.setItems(konfigurationenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colBezeichnung.setCellValueFactory([c|c.getValue.bezeichnung])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpKonfigurationLang k = getValue(konfigurationen, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(WP310KonfigurationController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(konfigurationen, 1)
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
	 * Event für Konfigurationen.
	 */
	@FXML def void onKonfigurationenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

package de.cwkuehl.jhh6.app.controller.mo

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.MoMessdiener
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
 * Controller für Dialog MO100Messdiener.
 */
class MO100MessdienerController extends BaseController<String> {
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button imExport
	@FXML Label messdiener0
	@FXML TableView<MessdienerData> messdiener
	@FXML TableColumn<MessdienerData, String> colUid
	@FXML TableColumn<MessdienerData, String> colVorname
	@FXML TableColumn<MessdienerData, String> colName
	@FXML TableColumn<MessdienerData, LocalDate> colVon
	@FXML TableColumn<MessdienerData, LocalDate> colBis
	@FXML TableColumn<MessdienerData, LocalDateTime> colGa
	@FXML TableColumn<MessdienerData, String> colGv
	@FXML TableColumn<MessdienerData, LocalDateTime> colAa
	@FXML TableColumn<MessdienerData, String> colAv
	ObservableList<MessdienerData> messdienerData = FXCollections::observableArrayList

	/** 
	 * Daten für Tabelle Messdiener.
	 */
	static class MessdienerData extends BaseController.TableViewData<MoMessdiener> {

		SimpleStringProperty uid
		SimpleStringProperty vorname
		SimpleStringProperty name
		SimpleObjectProperty<LocalDate> von
		SimpleObjectProperty<LocalDate> bis
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MoMessdiener v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			vorname = new SimpleStringProperty(v.getVorname)
			name = new SimpleStringProperty(v.getName)
			von = new SimpleObjectProperty<LocalDate>(v.getVon)
			bis = new SimpleObjectProperty<LocalDate>(v.getBis)
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
		messdiener0.setLabelFor(messdiener)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("X", imExport)
		initDaten(0)
		messdiener.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<MoMessdiener> l = get(
				FactoryService::getMessdienerService.getMessdienerListe(getServiceDaten, false))
			getItems(l, null, [a|new MessdienerData(a)], messdienerData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		messdiener.setItems(messdienerData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colVorname.setCellValueFactory([c|c.getValue.vorname])
		colName.setCellValueFactory([c|c.getValue.name])
		colVon.setCellValueFactory([c|c.getValue.von])
		colBis.setCellValueFactory([c|c.getValue.bis])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var MoMessdiener k = getValue(messdiener, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(MO110MessdienerController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(messdiener, 1)
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
	 * Event für ImExport.
	 */
	@FXML def void onImExport() {
		starteFormular(typeof(MO500SchnittstelleController), DialogAufrufEnum::OHNE)
	}

	/** 
	 * Event für Messdiener.
	 */
	@FXML def void onMessdienerMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

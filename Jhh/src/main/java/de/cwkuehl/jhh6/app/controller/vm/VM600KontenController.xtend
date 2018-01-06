package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.HhKontoVm
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
 * Controller für Dialog VM600Konten.
 */
class VM600KontenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label konten0
	@FXML TableView<KontenData> konten
	@FXML TableColumn<KontenData, String> colUid
	@FXML TableColumn<KontenData, String> colArt
	@FXML TableColumn<KontenData, String> colKz
	@FXML TableColumn<KontenData, String> colName
	@FXML TableColumn<KontenData, String> colSchluessel
	@FXML TableColumn<KontenData, String> colHaus
	@FXML TableColumn<KontenData, String> colWohnung
	@FXML TableColumn<KontenData, String> colMieter
	@FXML TableColumn<KontenData, LocalDate> colVon
	@FXML TableColumn<KontenData, LocalDate> colBis
	@FXML TableColumn<KontenData, LocalDateTime> colGa
	@FXML TableColumn<KontenData, String> colGv
	@FXML TableColumn<KontenData, LocalDateTime> colAa
	@FXML TableColumn<KontenData, String> colAv
	ObservableList<KontenData> kontenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Konten.
	 */
	static class KontenData extends TableViewData<HhKontoVm> {

		SimpleStringProperty uid
		SimpleStringProperty art
		SimpleStringProperty kz
		SimpleStringProperty name
		SimpleStringProperty schluessel
		SimpleStringProperty haus
		SimpleStringProperty wohnung
		SimpleStringProperty mieter
		SimpleObjectProperty<LocalDate> von
		SimpleObjectProperty<LocalDate> bis
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhKontoVm v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			art = new SimpleStringProperty(v.getArt)
			kz = new SimpleStringProperty(v.getKz)
			name = new SimpleStringProperty(v.getName)
			schluessel = new SimpleStringProperty(v.getSchluessel)
			haus = new SimpleStringProperty(v.getHausBezeichnung)
			wohnung = new SimpleStringProperty(v.getWohnungBezeichnung)
			mieter = new SimpleStringProperty(v.getMieterName)
			von = new SimpleObjectProperty<LocalDate>(v.getGueltigVon)
			bis = new SimpleObjectProperty<LocalDate>(v.getGueltigBis)
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
		konten0.setLabelFor(konten)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		konten.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			get(FactoryService.getVermietungService.initKonten(getServiceDaten))
		}
		if (stufe <= 1) {
			var List<HhKontoVm> l = get(FactoryService.getVermietungService.getKontoListe(getServiceDaten))
			getItems(l, null, [a|new KontenData(a)], kontenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		konten.setItems(kontenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colArt.setCellValueFactory([c|c.getValue.art])
		colKz.setCellValueFactory([c|c.getValue.kz])
		colName.setCellValueFactory([c|c.getValue.name])
		colSchluessel.setCellValueFactory([c|c.getValue.schluessel])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colWohnung.setCellValueFactory([c|c.getValue.wohnung])
		colMieter.setCellValueFactory([c|c.getValue.mieter])
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
		var HhKontoVm k = getValue(konten, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(VM610KontoController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(konten, 1)
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
	 * Event für Konten.
	 */
	@FXML def void onKontenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

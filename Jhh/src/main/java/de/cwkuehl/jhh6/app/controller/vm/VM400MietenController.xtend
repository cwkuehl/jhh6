package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.VmMieteLang
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
 * Controller für Dialog VM400Mieten.
 */
class VM400MietenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label mieten0
	@FXML TableView<MietenData> mieten
	@FXML TableColumn<MietenData, String> colUid
	@FXML TableColumn<MietenData, String> colHaus
	@FXML TableColumn<MietenData, String> colWohnung
	@FXML TableColumn<MietenData, LocalDate> colDatum
	@FXML TableColumn<MietenData, Double> colMiete
	@FXML TableColumn<MietenData, Double> colNebenkosten
	@FXML TableColumn<MietenData, LocalDateTime> colGa
	@FXML TableColumn<MietenData, String> colGv
	@FXML TableColumn<MietenData, LocalDateTime> colAa
	@FXML TableColumn<MietenData, String> colAv
	ObservableList<MietenData> mietenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Mieten.
	 */
	static class MietenData extends BaseController.TableViewData<VmMieteLang> {

		SimpleStringProperty uid
		SimpleStringProperty haus
		SimpleStringProperty wohnung
		SimpleObjectProperty<LocalDate> datum
		SimpleObjectProperty<Double> miete
		SimpleObjectProperty<Double> nebenkosten
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(VmMieteLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			haus = new SimpleStringProperty(v.hausBezeichnung)
			wohnung = new SimpleStringProperty(v.wohnungBezeichnung)
			datum = new SimpleObjectProperty<LocalDate>(v.datum)
			miete = new SimpleObjectProperty<Double>(v.miete)
			nebenkosten = new SimpleObjectProperty<Double>(v.nebenkosten)
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
		mieten0.setLabelFor(mieten)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		mieten.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var List<VmMieteLang> l = get(FactoryService.vermietungService.getMieteListe(serviceDaten, true, null))
			getItems(l, null, [a|new MietenData(a)], mietenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		mieten.setItems(mietenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colWohnung.setCellValueFactory([c|c.getValue.wohnung])
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colMiete.setCellValueFactory([c|c.getValue.miete])
		colNebenkosten.setCellValueFactory([c|c.getValue.nebenkosten])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		var VmMieteLang k = getValue(mieten, !DialogAufrufEnum.NEU.equals(aufruf))
		if (k !== null) {
			k = k.getClone
			k.setMiete(k.getMiete - k.getGarage)
			k.setNebenkosten(k.getNebenkosten - k.getHeizung)
		}
		starteFormular(VM410MieteController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(mieten, 1)
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
	 * Event für Mieten.
	 */
	@FXML def void onMietenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

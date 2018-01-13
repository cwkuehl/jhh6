package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
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
 * Controller für Dialog WP500Staende.
 */
class WP500StaendeController extends BaseController<String> {

	//@FXML Button tab
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label staende0
	@FXML TableView<StaendeData> staende
	@FXML TableColumn<StaendeData, String> colWpbezeichnung
	@FXML TableColumn<StaendeData, LocalDate> colDatum
	@FXML TableColumn<StaendeData, Double> colBetrag
	@FXML TableColumn<StaendeData, LocalDateTime> colGa
	@FXML TableColumn<StaendeData, String> colGv
	@FXML TableColumn<StaendeData, LocalDateTime> colAa
	@FXML TableColumn<StaendeData, String> colAv
	ObservableList<StaendeData> staendeData = FXCollections.observableArrayList
	//@FXML Button alle
	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@Profil String wertpapierUid = null

	/** 
	 * Daten für Tabelle Wertpapiere.
	 */
	static class StaendeData extends TableViewData<WpStandLang> {

		SimpleStringProperty wpbezeichnung
		SimpleObjectProperty<LocalDate> datum
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpStandLang v) {

			super(v)
			wpbezeichnung = new SimpleStringProperty(v.getWertpapierBezeichnung)
			datum = new SimpleObjectProperty<LocalDate>(v.getDatum)
			betrag = new SimpleObjectProperty<Double>(v.getStueckpreis)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return getData.getWertpapierUid + getData.getDatum.toString
		}
	}

	/** 
	 * Daten für ComboBox Wertpapier.
	 */
	static class WertpapierData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
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
		staende0.setLabelFor(staende)
		von0.setLabelFor(von)
		bis0.setLabelFor(bis)
		wertpapier0.setLabelFor(wertpapier, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		staende.requestFocus
		staende.setPrefHeight(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			von.setValue((null as LocalDate))
			bis.setValue((null as LocalDate))
			var List<WpWertpapierLang> kliste = get(
				FactoryService.getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null, null))
			wertpapier.setItems(getItems(kliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			setText(wertpapier, wertpapierUid)
		}
		if (stufe <= 1) {
			var List<WpStandLang> l = get(
				FactoryService.getWertpapierService.getStandListe(getServiceDaten, false, getText(wertpapier),
					von.getValue, bis.getValue))
			getItems(l, null, [a|new StaendeData(a)], staendeData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		staende.setItems(staendeData)
		colWpbezeichnung.setCellValueFactory([c|c.getValue.wpbezeichnung])
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colBetrag.setCellValueFactory([c|c.getValue.betrag])
		initColumnBetrag(colBetrag)
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpStandLang k = getValue(staende, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(WP510StandController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(staende, 1)
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
	 * Event für Staende.
	 */
	@FXML def void onStaendeMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(staende, 0)
	}

	override protected void onHidden() {
		wertpapierUid = getText(wertpapier)
		super.onHidden
	}

	/** 
	 * Event für Wertpapier.
	 */
	@FXML def void onWertpapier() {
		onAktuell
	}
}

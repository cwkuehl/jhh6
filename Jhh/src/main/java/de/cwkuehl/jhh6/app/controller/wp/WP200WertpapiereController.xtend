package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import javafx.application.Platform
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog WP200Wertpapiere.
 */
class WP200WertpapiereController extends BaseController<String> {

	// @FXML Button tab
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button export
	@FXML Label wertpapiere0
	@FXML TableView<WertpapiereData> wertpapiere
	@FXML TableColumn<WertpapiereData, String> colSort
	@FXML TableColumn<WertpapiereData, String> colBezeichnung
	@FXML TableColumn<WertpapiereData, String> colQuelle
	@FXML TableColumn<WertpapiereData, String> colKuerzel
	@FXML TableColumn<WertpapiereData, String> colRelation
	@FXML TableColumn<WertpapiereData, String> colBewertung
	@FXML TableColumn<WertpapiereData, Integer> colTrend
	@FXML TableColumn<WertpapiereData, String> colBewertung1
	@FXML TableColumn<WertpapiereData, String> colTrend1
	@FXML TableColumn<WertpapiereData, String> colBewertung2
	@FXML TableColumn<WertpapiereData, String> colTrend2
	@FXML TableColumn<WertpapiereData, String> colBewertung3
	@FXML TableColumn<WertpapiereData, String> colTrend3
	@FXML TableColumn<WertpapiereData, String> colBewertung4
	@FXML TableColumn<WertpapiereData, String> colTrend4
	@FXML TableColumn<WertpapiereData, String> colBewertung5
	@FXML TableColumn<WertpapiereData, String> colTrend5
	@FXML TableColumn<WertpapiereData, String> colXo
	@FXML TableColumn<WertpapiereData, Integer> colSignalbew
	@FXML TableColumn<WertpapiereData, LocalDate> colSignaldatum
	@FXML TableColumn<WertpapiereData, String> colSignalbez
	@FXML TableColumn<WertpapiereData, String> colSchnitt200
	@FXML TableColumn<WertpapiereData, LocalDateTime> colGa
	@FXML TableColumn<WertpapiereData, String> colGv
	@FXML TableColumn<WertpapiereData, LocalDateTime> colAa
	@FXML TableColumn<WertpapiereData, String> colAv
	ObservableList<WertpapiereData> wertpapiereData = FXCollections::observableArrayList
	@FXML Label bis0
	@FXML Datum bis
	// @FXML Button alle
	// @FXML Button berechnen
	// @FXML Button abbrechen
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label muster0
	@FXML TextField muster
	@FXML Label konfiguration0
	@FXML ComboBox<KonfigurationData> konfiguration
	@Profil String konfUid = null
	/** 
	 * Abbruch-Objekt. 
	 */
	StringBuffer abbruch = new StringBuffer
	/** 
	 * Status zum Anzeigen. 
	 */
	StringBuffer status = new StringBuffer

	/** 
	 * Daten für Tabelle Wertpapiere.
	 */
	static class WertpapiereData extends TableViewData<WpWertpapierLang> {

		SimpleStringProperty sort
		SimpleStringProperty bezeichnung
		SimpleStringProperty quelle
		SimpleStringProperty kuerzel
		SimpleStringProperty relation
		SimpleStringProperty bewertung
		SimpleObjectProperty<Integer> trend
		SimpleStringProperty bewertung1
		SimpleStringProperty trend1
		SimpleStringProperty bewertung2
		SimpleStringProperty trend2
		SimpleStringProperty bewertung3
		SimpleStringProperty trend3
		SimpleStringProperty bewertung4
		SimpleStringProperty trend4
		SimpleStringProperty bewertung5
		SimpleStringProperty trend5
		SimpleStringProperty xo
		SimpleObjectProperty<Integer> signalbew
		SimpleObjectProperty<LocalDate> signaldatum
		SimpleStringProperty signalbez
		SimpleStringProperty schnitt200
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpWertpapierLang v) {

			super(v)
			sort = new SimpleStringProperty(v.sortierung)
			bezeichnung = new SimpleStringProperty(v.bezeichnung)
			quelle = new SimpleStringProperty(v.datenquelle)
			kuerzel = new SimpleStringProperty(v.kuerzel)
			relation = new SimpleStringProperty(v.relationBezeichnung)
			bewertung = new SimpleStringProperty(v.bewertung)
			trend = new SimpleObjectProperty<Integer>(if(Global::nes(v.trend)) null else Global::strInt(v.trend))
			bewertung1 = new SimpleStringProperty(v.bewertung1)
			trend1 = new SimpleStringProperty(v.trend1)
			bewertung2 = new SimpleStringProperty(v.bewertung2)
			trend2 = new SimpleStringProperty(v.trend2)
			bewertung3 = new SimpleStringProperty(v.bewertung3)
			trend3 = new SimpleStringProperty(v.trend3)
			bewertung4 = new SimpleStringProperty(v.bewertung4)
			trend4 = new SimpleStringProperty(v.trend4)
			bewertung5 = new SimpleStringProperty(v.bewertung5)
			trend5 = new SimpleStringProperty(v.trend5)
			xo = new SimpleStringProperty(v.xo)
			signalbew = new SimpleObjectProperty<Integer>(
				if(Global::nes(v.signalbew)) null else Global::strInt(v.signalbew))
			signaldatum = new SimpleObjectProperty<LocalDate>(
				if(Global::nes(v.signaldatum)) null else LocalDate::parse(v.signaldatum))
			signalbez = new SimpleStringProperty(v.signalbez)
			schnitt200 = new SimpleStringProperty(v.schnitt200)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return getData.uid
		}
	}

	/** 
	 * Daten für ComboBox Konfiguration.
	 */
	static class KonfigurationData extends ComboBoxData<WpKonfigurationLang> {

		new(WpKonfigurationLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		wertpapiere0.setLabelFor(wertpapiere)
		bis0.setLabelFor(bis)
		bezeichnung0.setLabelFor(bezeichnung)
		muster0.setLabelFor(muster)
		konfiguration0.setLabelFor(konfiguration, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("X", export)
		initDaten(0)
		wertpapiere.requestFocus
		wertpapiere.setPrefHeight(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			bis.setValue(LocalDate::now)
			bezeichnung.setText("%%")
			muster.setText("%%")
			var kliste = get(FactoryService::wertpapierService.getKonfigurationListe(serviceDaten, true, "1"))
			konfiguration.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			setText(konfiguration, konfUid)
		}
		if (stufe <= 1) {
			var l = get(
				FactoryService::wertpapierService.getWertpapierListe(serviceDaten, false, bezeichnung.text, muster.text,
					null))
			getItems(l, null, [a|new WertpapiereData(a)], wertpapiereData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		wertpapiere.setItems(wertpapiereData)
		colSort.setCellValueFactory([c|c.value.sort])
		colBezeichnung.setCellValueFactory([c|c.value.bezeichnung])
		colQuelle.setCellValueFactory([c|c.value.quelle])
		colKuerzel.setCellValueFactory([c|c.value.kuerzel])
		colRelation.setCellValueFactory([c|c.value.relation])
		colBewertung.setCellValueFactory([c|c.value.bewertung])
		colTrend.setCellValueFactory([c|c.value.trend])
		colBewertung1.setCellValueFactory([c|c.value.bewertung1])
		colTrend1.setCellValueFactory([c|c.value.trend1])
		colBewertung2.setCellValueFactory([c|c.value.bewertung2])
		colTrend2.setCellValueFactory([c|c.value.trend2])
		colBewertung3.setCellValueFactory([c|c.value.bewertung3])
		colTrend3.setCellValueFactory([c|c.value.trend3])
		colBewertung4.setCellValueFactory([c|c.value.bewertung4])
		colTrend4.setCellValueFactory([c|c.value.trend4])
		colBewertung5.setCellValueFactory([c|c.value.bewertung5])
		colTrend5.setCellValueFactory([c|c.value.trend5])
		colXo.setCellValueFactory([c|c.value.xo])
		colSignalbew.setCellValueFactory([c|c.value.signalbew])
		colSignaldatum.setCellValueFactory([c|c.value.signaldatum])
		colSignalbez.setCellValueFactory([c|c.value.signalbez])
		colSchnitt200.setCellValueFactory([c|c.value.schnitt200])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpWertpapierLang k = getValue(wertpapiere, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(WP210WertpapierController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(wertpapiere, 1)
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
	 * Event für Export.
	 */
	@FXML def void onExport() {
		starteFormular(typeof(WP220SchnittstelleController), DialogAufrufEnum::OHNE)
	}

	/** 
	 * Event für Wertpapiere.
	 */
	@FXML def void onWertpapiereMouseClick(MouseEvent e) {

		if (e.clickCount > 1) {
			var WpWertpapierLang wp = getValue(wertpapiere, true)
			var WpKonfigurationLang k = getValue(konfiguration, false)
			starteFormular(typeof(WP100ChartController), DialogAufrufEnum::OHNE, bis.value, wp, k)
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(wertpapiere, 0)
	}

	/** 
	 * Event für Berechnen.
	 */
	@FXML def void onBerechnen() {

		var task = ([|
			onStatusTimer
			try {
				var r = FactoryService::wertpapierService.bewerteteWertpapierListe(serviceDaten, false,
					bezeichnung.text, muster.text, null, bis.value, getText(konfiguration), status, abbruch)
				r.throwErstenFehler
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen.M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			Platform::runLater([WP200WertpapiereController.this.onAktuell])
			return null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onStatusTimer() {

		status.setLength(0)
		abbruch.setLength(0)
		onStatus
		var task = [|
			try {
				while (true) {
					onStatus
					Thread::sleep(1000)
				}
			} catch (Exception ex) {
				Global::machNichts
			}
			return null as Void
		] as Task<Void>
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onStatus() {
		Jhh6::setLeftStatus2(status.toString)
		if (abbruch.length > 0) {
			throw new RuntimeException("")
		}
	}

	override protected void onHidden() {
		konfUid = getText(konfiguration)
		super.onHidden
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		abbruch.append("Abbruch")
	}
}

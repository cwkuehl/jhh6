package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
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
 * Controller für Dialog WP250Anlagen.
 */
class WP250AnlagenController extends BaseController<String> {

	// @FXML Button tab
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label anlagen0
	@FXML TableView<AnlagenData> anlagen
	@FXML TableColumn<AnlagenData, String> colWpbezeichnung
	@FXML TableColumn<AnlagenData, String> colBezeichnung
	@FXML TableColumn<AnlagenData, Double> colBetrag
	@FXML TableColumn<AnlagenData, Double> colWert
	@FXML TableColumn<AnlagenData, Double> colGewinn
	@FXML TableColumn<AnlagenData, LocalDateTime> colDatum
	@FXML TableColumn<AnlagenData, String> colWaehrung
	@FXML TableColumn<AnlagenData, LocalDateTime> colGa
	@FXML TableColumn<AnlagenData, String> colGv
	@FXML TableColumn<AnlagenData, LocalDateTime> colAa
	@FXML TableColumn<AnlagenData, String> colAv
	ObservableList<AnlagenData> anlagenData = FXCollections::observableArrayList
	@FXML Label anlagenStatus
	// @FXML Button alle
	// @FXML Button berechnen
	// @FXML Button abbrechen
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@Profil String wertpapierUid = null
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
	static class AnlagenData extends TableViewData<WpAnlageLang> {

		SimpleStringProperty wpbezeichnung
		SimpleStringProperty bezeichnung
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<Double> wert
		SimpleObjectProperty<Double> gewinn
		SimpleObjectProperty<LocalDateTime> aktdatum
		SimpleStringProperty waehrung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpAnlageLang v) {

			super(v)
			wpbezeichnung = new SimpleStringProperty(v.wertpapierBezeichnung)
			bezeichnung = new SimpleStringProperty(v.bezeichnung)
			betrag = new SimpleObjectProperty<Double>(v.betrag)
			wert = new SimpleObjectProperty<Double>(v.wert)
			gewinn = new SimpleObjectProperty<Double>(v.gewinn)
			waehrung = new SimpleStringProperty(v.waehrung)
			aktdatum = new SimpleObjectProperty<LocalDateTime>(v.aktdatum)
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
	 * Daten für ComboBox Wertpapier.
	 */
	static class WertpapierData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
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
		anlagen0.setLabelFor(anlagen)
		bezeichnung0.setLabelFor(bezeichnung)
		wertpapier0.setLabelFor(wertpapier, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		anlagen.requestFocus
		anlagen.setPrefHeight(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			bezeichnung.setText("%%")
			var kliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			wertpapier.setItems(getItems(kliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			setText(wertpapier, wertpapierUid)
		}
		if (stufe <= 1) {
			var l = get(
				FactoryService::wertpapierService.getAnlageListe(serviceDaten, false, bezeichnung.text, null,
					getText(wertpapier)))
			getItems(l, null, [a|new AnlagenData(a)], anlagenData)
			var anz = Global::listLaenge(l)
			var summe = 0.0
			var wert = 0.0
			var gewinn = 0.0
			if (l !== null) {
				for (WpAnlageLang b : l) {
					summe += b.betrag
					wert += b.wert
					gewinn += b.gewinn
				}
			}
			anlagenStatus.setText(Meldungen::WP029(anz, summe, wert, gewinn))
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		anlagen.setItems(anlagenData)
		colWpbezeichnung.setCellValueFactory([c|c.value.wpbezeichnung])
		colBezeichnung.setCellValueFactory([c|c.value.bezeichnung])
		colBetrag.setCellValueFactory([c|c.value.betrag])
		initColumnBetrag(colBetrag)
		colWert.setCellValueFactory([c|c.value.wert])
		initColumnBetrag(colWert)
		colGewinn.setCellValueFactory([c|c.value.gewinn])
		initColumnBetrag(colGewinn)
		colDatum.setCellValueFactory([c|c.value.aktdatum])
		colWaehrung.setCellValueFactory([c|c.value.waehrung])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpAnlageLang k = getValue(anlagen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(WP260AnlageController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(anlagen, 1)
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
	 * Event für Anlagen.
	 */
	@FXML def void onAnlagenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		wertpapierUid = null
		refreshTable(anlagen, 0)
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

	/** 
	 * Event für Berechnen.
	 */
	@FXML def void onBerechnen() {

		var task = [|
			onStatusTimer
			try {
				var r = FactoryService::wertpapierService.bewerteteAnlageListe(serviceDaten, false, bezeichnung.text,
					null, getText(wertpapier), LocalDate::now, status, abbruch)
				r.throwErstenFehler
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen.M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			Platform::runLater([WP250AnlagenController.this.onAktuell])
			return null as Void
		] as Task<Void>
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

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		abbruch.append("Abbruch")
	}
}

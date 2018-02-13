package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
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
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog WP400Buchungen.
 */
class WP400BuchungenController extends BaseController<String> {

	//@FXML Button tab
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label buchungen0
	@FXML TableView<BuchungenData> buchungen
	@FXML TableColumn<BuchungenData, String> colWpbezeichnung
	@FXML TableColumn<BuchungenData, String> colBezeichnung
	@FXML TableColumn<BuchungenData, LocalDate> colDatum
	@FXML TableColumn<BuchungenData, String> colText
	@FXML TableColumn<BuchungenData, Double> colBetrag
	@FXML TableColumn<BuchungenData, Double> colRabatt
	@FXML TableColumn<BuchungenData, Double> colAnteile
	@FXML TableColumn<BuchungenData, Double> colZinsen
	@FXML TableColumn<BuchungenData, LocalDateTime> colGa
	@FXML TableColumn<BuchungenData, String> colGv
	@FXML TableColumn<BuchungenData, LocalDateTime> colAa
	@FXML TableColumn<BuchungenData, String> colAv
	ObservableList<BuchungenData> buchungenData = FXCollections.observableArrayList
	//@FXML Button alle
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label anlage0
	@FXML ComboBox<AnlageData> anlage
	@Profil String anlageUid = null

	/** 
	 * Daten für Tabelle Wertpapiere.
	 */
	static class BuchungenData extends TableViewData<WpBuchungLang> {

		SimpleStringProperty wpbezeichnung
		SimpleStringProperty bezeichnung
		SimpleObjectProperty<LocalDate> datum
		SimpleStringProperty text
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<Double> rabatt
		SimpleObjectProperty<Double> anteile
		SimpleObjectProperty<Double> zinsen
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpBuchungLang v) {

			super(v)
			wpbezeichnung = new SimpleStringProperty(v.getWertpapierBezeichnung)
			bezeichnung = new SimpleStringProperty(v.getAnlageBezeichnung)
			datum = new SimpleObjectProperty<LocalDate>(v.getDatum)
			text = new SimpleStringProperty(v.getBtext)
			betrag = new SimpleObjectProperty<Double>(v.getZahlungsbetrag)
			rabatt = new SimpleObjectProperty<Double>(v.getRabattbetrag)
			anteile = new SimpleObjectProperty<Double>(v.getAnteile)
			zinsen = new SimpleObjectProperty<Double>(v.getZinsen)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return getData.getUid
		}
	}

	/** 
	 * Daten für ComboBox Anlage.
	 */
	static class AnlageData extends ComboBoxData<WpAnlageLang> {

		new(WpAnlageLang v) {
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
		buchungen0.setLabelFor(buchungen)
		bezeichnung0.setLabelFor(bezeichnung)
		anlage0.setLabelFor(anlage, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		buchungen.requestFocus
		buchungen.setPrefHeight(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			bezeichnung.setText("%%")
			var List<WpAnlageLang> kliste = get(
				FactoryService.getWertpapierService.getAnlageListe(getServiceDaten, true, null, null, null))
			anlage.setItems(getItems(kliste, new WpAnlageLang, [a|new AnlageData(a)], null))
			setText(anlage, anlageUid)
		}
		if (stufe <= 1) {
			var List<WpBuchungLang> l = get(
				FactoryService.getWertpapierService.getBuchungListe(getServiceDaten, false, bezeichnung.getText,
					null, null, getText(anlage)))
			getItems(l, null, [a|new BuchungenData(a)], buchungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		buchungen.setItems(buchungenData)
		colWpbezeichnung.setCellValueFactory([c|c.getValue.wpbezeichnung])
		colBezeichnung.setCellValueFactory([c|c.getValue.bezeichnung])
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colText.setCellValueFactory([c|c.getValue.text])
		colBetrag.setCellValueFactory([c|c.getValue.betrag])
		initColumnBetrag(colBetrag)
		colRabatt.setCellValueFactory([c|c.getValue.rabatt])
		initColumnBetrag(colRabatt)
		colAnteile.setCellValueFactory([c|c.getValue.anteile])
		initColumnBetrag(colAnteile)
		colZinsen.setCellValueFactory([c|c.getValue.zinsen])
		initColumnBetrag(colZinsen)
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpBuchungLang k = getValue(buchungen, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(WP410BuchungController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(buchungen, 1)
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
	 * Event für Buchungen.
	 */
	@FXML def void onBuchungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(buchungen, 0)
	}

	override protected void onHidden() {
		anlageUid = getText(anlage)
		super.onHidden
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAnlage() {
		onAktuell
	}
}

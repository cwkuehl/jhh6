package de.cwkuehl.jhh6.app.controller.so

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.detective.Runde
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.service.detective.DetektivContext
import de.cwkuehl.jhh6.server.service.detective.DetektivContext.ErgebnisseData
import de.cwkuehl.jhh6.server.service.detective.DetektivContext.RundenData
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog SO200Detektiv.
 */
class SO200DetektivController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label runden0
	@FXML TableView<RundenData> runden
	@FXML TableColumn<RundenData, String> colRuid
	@FXML TableColumn<RundenData, String> colRspieler
	@FXML TableColumn<RundenData, String> colRverdaechtige
	@FXML TableColumn<RundenData, Boolean> colRbesitzv
	@FXML TableColumn<RundenData, String> colRwerkzeuge
	@FXML TableColumn<RundenData, Boolean> colRbesitzw
	@FXML TableColumn<RundenData, String> colRraeume
	@FXML TableColumn<RundenData, Boolean> colRbesitzr
	@FXML TableColumn<RundenData, String> colRohne
	@FXML TableColumn<RundenData, String> colRmit
	ObservableList<RundenData> rundenData = FXCollections.observableArrayList
	@FXML Label ergebnisse0
	@FXML TableView<ErgebnisseData> ergebnisse
	@FXML TableColumn<ErgebnisseData, String> colEuid
	@FXML TableColumn<ErgebnisseData, String> colEkategorie
	@FXML TableColumn<ErgebnisseData, String> colEkurz
	@FXML TableColumn<ErgebnisseData, String> colEspieler
	@FXML TableColumn<ErgebnisseData, String> colEohne
	@FXML TableColumn<ErgebnisseData, String> colEmoeglich
	@FXML TableColumn<ErgebnisseData, String> colEfrage
	@FXML TableColumn<ErgebnisseData, Double> colEwahrscheinlich
	ObservableList<ErgebnisseData> ergebnisseData = FXCollections.observableArrayList
	// @FXML Button reset
	@Profil(defaultValue="Anna, Bob") String neueSpieler = null

	/** 
	 * Detektiv-Kontext 
	 */
	package DetektivContext context = null

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		runden0.setLabelFor(runden)
		ergebnisse0.setLabelFor(ergebnisse)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		runden.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			context = DetektivContext.readObject(Jhh6::serviceDaten)
		}
		if (stufe <= 1) {
			// Runden
			var rliste = context.runden
			getItems(rliste, null, [a|new RundenData(context, a)], rundenData)
			// Ergebnisse
			var eliste = context.ergebnisse
			getItems(eliste, null, [a|new ErgebnisseData(context, a)], ergebnisseData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		runden.setItems(rundenData)
		colRuid.setCellValueFactory([c|c.value.uid])
		colRspieler.setCellValueFactory([c|c.value.spieler])
		colRverdaechtige.setCellValueFactory([c|c.value.verdaechtige])
		colRbesitzv.setCellValueFactory([c|c.value.besitzv])
		colRwerkzeuge.setCellValueFactory([c|c.value.werkzeuge])
		colRbesitzw.setCellValueFactory([c|c.value.besitzw])
		colRraeume.setCellValueFactory([c|c.value.raeume])
		colRbesitzr.setCellValueFactory([c|c.value.besitzr])
		colRohne.setCellValueFactory([c|c.value.spielerohne])
		colRmit.setCellValueFactory([c|c.value.spielermit])
		ergebnisse.setItems(ergebnisseData)
		colEuid.setCellValueFactory([c|c.value.uid])
		colEkategorie.setCellValueFactory([c|c.value.kategorie])
		colEkurz.setCellValueFactory([c|c.value.kurz])
		colEspieler.setCellValueFactory([c|c.value.spieler])
		colEohne.setCellValueFactory([c|c.value.ohne])
		colEmoeglich.setCellValueFactory([c|c.value.moeglich])
		colEfrage.setCellValueFactory([c|c.value.frage])
		colEwahrscheinlich.setCellValueFactory([c|c.value.wahrscheinlich])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var Runde k = getValue(runden, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(SO210RundeController, aufruf, context, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(runden, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6.rollback)
		refreshTable(runden, 0)
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6.redo)
		refreshTable(runden, 0)
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
	 * Event für Runden.
	 */
	@FXML def void onRundenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Ergebnisse.
	 */
	@FXML def void onErgebnisseMouseClick(MouseEvent e) {
		if (e.clickCount > 1) { // onAendern
		}
	}

	/** 
	 * Event für Reset.
	 */
	@FXML def void onReset() {

		var spieler = Werkzeug.showInputDialog(Meldungen::SO001, neueSpieler)
		if (!Global.nes(spieler)) {
			neueSpieler = spieler
			context.deleteRunde(null)
			context.spieler = spieler
			refreshTable(runden, 1)
		}
	}
}

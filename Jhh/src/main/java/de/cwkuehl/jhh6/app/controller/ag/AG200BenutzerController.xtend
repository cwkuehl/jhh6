package de.cwkuehl.jhh6.app.controller.ag

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.BenutzerLang
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
 * Controller für Dialog AG200Benutzer.
 */
class AG200BenutzerController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label benutzer0
	@FXML TableView<BenutzerData> benutzer
	@FXML TableColumn<BenutzerData, Integer> colPersonNr
	@FXML TableColumn<BenutzerData, String> colBenutzerId
	@FXML TableColumn<BenutzerData, String> colKennwort
	@FXML TableColumn<BenutzerData, String> colRechte
	@FXML TableColumn<BenutzerData, LocalDate> colGeburt
	@FXML TableColumn<BenutzerData, LocalDateTime> colGa
	@FXML TableColumn<BenutzerData, String> colGv
	@FXML TableColumn<BenutzerData, LocalDateTime> colAa
	@FXML TableColumn<BenutzerData, String> colAv
	ObservableList<BenutzerData> benutzerData = FXCollections.observableArrayList()

	/** 
	 * Daten für Tabelle Benutzer.
	 */
	static class BenutzerData extends TableViewData<BenutzerLang> {

		SimpleObjectProperty<Integer> personNr
		SimpleStringProperty benutzerId
		SimpleStringProperty kennwort
		SimpleStringProperty rechte
		SimpleObjectProperty<LocalDate> geburt
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(BenutzerLang v) {

			super(v)
			personNr = new SimpleObjectProperty<Integer>(v.getPersonNr())
			benutzerId = new SimpleStringProperty(v.getBenutzerId())
			kennwort = new SimpleStringProperty(v.getPasswort())
			rechte = new SimpleStringProperty(v.getRechte())
			geburt = new SimpleObjectProperty<LocalDate>(v.getGeburt())
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm())
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon())
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm())
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon())
		}

		override String getId() {
			return '''«personNr.get()»'''
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize()
		benutzer0.setLabelFor(benutzer)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		benutzer.requestFocus()
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// stufe = 0;
		}
		if (stufe <= 1) {
			var List<BenutzerLang> l = get(
				FactoryService.getAnmeldungService().getBenutzerListe(getServiceDaten(), true))
			getItems(l, null, [a|new BenutzerData(a)], benutzerData)
		}
		if (stufe <= 2) {
			initDatenTable()
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		benutzer.setItems(benutzerData)
		colPersonNr.setCellValueFactory([c|c.getValue().personNr])
		colBenutzerId.setCellValueFactory([c|c.getValue().benutzerId])
		colKennwort.setCellValueFactory([c|c.getValue().kennwort])
		colRechte.setCellValueFactory([c|c.getValue().rechte])
		colGeburt.setCellValueFactory([c|c.getValue().geburt])
		colGv.setCellValueFactory([c|c.getValue().geaendertVon])
		colGa.setCellValueFactory([c|c.getValue().geaendertAm])
		colAv.setCellValueFactory([c|c.getValue().angelegtVon])
		colAa.setCellValueFactory([c|c.getValue().angelegtAm])
	}

	override protected void updateParent() {
		onAktuell()
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		var BenutzerLang k = getValue(benutzer, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(AG210BenutzerController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(benutzer, 1)
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
	 * Event für Benutzer.
	 */
	@FXML def void onBenutzerMouseClick(MouseEvent e) {

		if (e.clickCount > 1) {
			onAendern
		}
	}
}

package de.cwkuehl.jhh6.app.controller.ag

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.controller.am.AM500EinstellungenController
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
 * Controller für Dialog AG100Mandanten.
 */
class AG100MandantenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button einstellung
	@FXML Label mandanten0
	@FXML TableView<MandantenData> mandanten
	@FXML TableColumn<MandantenData, Integer> colNr
	@FXML TableColumn<MandantenData, String> colBeschreibung
	@FXML TableColumn<MandantenData, LocalDateTime> colGa
	@FXML TableColumn<MandantenData, String> colGv
	@FXML TableColumn<MandantenData, LocalDateTime> colAa
	@FXML TableColumn<MandantenData, String> colAv
	ObservableList<MandantenData> mandantenData = FXCollections.observableArrayList()

	/** 
	 * Daten für Tabelle Mandanten.
	 */
	static class MandantenData extends BaseController.TableViewData<MaMandant> {

		SimpleObjectProperty<Integer> nr
		SimpleStringProperty beschreibung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MaMandant v) {

			super(v)
			nr = new SimpleObjectProperty<Integer>(v.getNr())
			beschreibung = new SimpleStringProperty(v.getBeschreibung())
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm())
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon())
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm())
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon())
		}

		override String getId() {
			return '''«nr.get()»'''
		} // stufe = 0;
		// starteFormular(AG110MandantController.class, aufruf, k);
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize()
		mandanten0.setLabelFor(mandanten)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("I", einstellung)
		initDaten(0)
		mandanten.requestFocus()
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
		}
		if (stufe <= 1) {
			var List<MaMandant> l = get(FactoryService.getAnmeldungService().getMandantListe(getServiceDaten(), false))
			getItems(l, null, [a|new MandantenData(a)], mandantenData)
		}
		if (stufe <= 2) {
			initDatenTable()
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
		mandanten.setItems(mandantenData)
		colNr.setCellValueFactory([c|c.getValue().nr])
		colBeschreibung.setCellValueFactory([c|c.getValue().beschreibung])
		colGv.setCellValueFactory([c|c.getValue().geaendertVon])
		colGa.setCellValueFactory([c|c.getValue().geaendertAm])
		colAv.setCellValueFactory([c|c.getValue().angelegtVon])
		colAa.setCellValueFactory([c|c.getValue().angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		// var MaMandant k = getValue(mandanten, !DialogAufrufEnum.NEU.equals(aufruf))
		// starteFormular(typeof(AG110MandantController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(mandanten, 1)
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
	 * Event für Einstellung.
	 */
	@FXML def void onEinstellung() {

		var MaMandant k = getValue(mandanten, true)
		starteFormular(AM500EinstellungenController, DialogAufrufEnum.OHNE, k)
	}

	/** 
	 * Event für Mandanten.
	 */
	@FXML def void onMandantenMouseClick(MouseEvent e) {

		if (e.clickCount > 1) {
			onAendern
		}
	}
}

package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
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
 * Controller für Dialog HP300Leistungen.
 */
class HP300LeistungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label leistungen0
	@FXML TableView<LeistungenData> leistungen
	@FXML TableColumn<LeistungenData, String> colUid
	@FXML TableColumn<LeistungenData, String> colZiffer
	@FXML TableColumn<LeistungenData, String> colZifferAlt
	@FXML TableColumn<LeistungenData, String> colBeschreibungFett
	@FXML TableColumn<LeistungenData, Double> colFaktor
	@FXML TableColumn<LeistungenData, Double> colFestbetrag
	@FXML TableColumn<LeistungenData, LocalDateTime> colGa
	@FXML TableColumn<LeistungenData, String> colGv
	@FXML TableColumn<LeistungenData, LocalDateTime> colAa
	@FXML TableColumn<LeistungenData, String> colAv
	ObservableList<LeistungenData> leistungenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Leistungen.
	 */
	static class LeistungenData extends TableViewData<HpLeistung> {

		SimpleStringProperty uid
		SimpleStringProperty ziffer
		SimpleStringProperty zifferAlt
		SimpleStringProperty beschreibungFett
		SimpleObjectProperty<Double> faktor
		SimpleObjectProperty<Double> festbetrag
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpLeistung v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			ziffer = new SimpleStringProperty(v.ziffer)
			zifferAlt = new SimpleStringProperty(v.zifferAlt)
			beschreibungFett = new SimpleStringProperty(v.beschreibungFett)
			faktor = new SimpleObjectProperty<Double>(v.faktor)
			festbetrag = new SimpleObjectProperty<Double>(v.festbetrag)
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
		leistungen0.setLabelFor(leistungen)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		leistungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::heilpraktikerService.getLeistungListe(getServiceDaten, false, false))
			getItems(l, null, [a|new LeistungenData(a)], leistungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		leistungen.setItems(leistungenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colZiffer.setCellValueFactory([c|c.value.ziffer])
		colZifferAlt.setCellValueFactory([c|c.value.zifferAlt])
		colBeschreibungFett.setCellValueFactory([c|c.value.beschreibungFett])
		colFaktor.setCellValueFactory([c|c.value.faktor])
		initColumnBetrag(colFaktor)
		colFestbetrag.setCellValueFactory([c|c.value.festbetrag])
		initColumnBetrag(colFestbetrag)
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HpLeistung k = getValue(leistungen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(HP310LeistungController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(leistungen, 1)
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
	 * Event für Leistungen.
	 */
	@FXML def void onLeistungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}

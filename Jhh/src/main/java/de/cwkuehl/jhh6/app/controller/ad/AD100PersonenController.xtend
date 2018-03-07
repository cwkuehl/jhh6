package de.cwkuehl.jhh6.app.controller.ad

import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
import java.util.List
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog AD100Personen.
 */
class AD100PersonenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Button imExport
	@FXML Label personen0
	@FXML Label name0
	@FXML TextField name
	@FXML Label vorname0
	@FXML TextField vorname
//	@FXML Button alle
//	@FXML Button sitzNeu
//	@FXML Button sitzEins
//	@FXML Button gebListe
	@FXML TableView<PersonenData> personen
	@FXML TableColumn<PersonenData, String> colUid
	@FXML TableColumn<PersonenData, String> colName1
	@FXML TableColumn<PersonenData, String> colSitz
	@FXML TableColumn<PersonenData, LocalDateTime> colGa
	@FXML TableColumn<PersonenData, String> colGv
	@FXML TableColumn<PersonenData, LocalDateTime> colAa
	@FXML TableColumn<PersonenData, String> colAv
	ObservableList<PersonenData> personenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Personen.
	 */
	static class PersonenData extends BaseController.TableViewData<AdPersonSitzAdresse> {

		SimpleStringProperty uid
		SimpleStringProperty name1
		SimpleStringProperty name
		SimpleObjectProperty<LocalDateTime> geaendertAm
		final SimpleStringProperty geaendertVon
		final SimpleObjectProperty<LocalDateTime> angelegtAm
		final SimpleStringProperty angelegtVon

		new(AdPersonSitzAdresse v) {
			super(v)
			uid = new SimpleStringProperty(v.getUid)
			name1 = new SimpleStringProperty(v.getName1)
			name = new SimpleStringProperty(v.getName)
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
		personen0.setLabelFor(personen)
		name0.setLabelFor(name)
		vorname0.setLabelFor(vorname)
		name.focusedProperty.addListener([ p, alt, neu |
			{
				if (neu === false) {
					onAktuell
				}
			}
		])
		vorname.focusedProperty.addListener([ p, alt, neu |
			{
				if (neu === false) {
					onAktuell
				}
			}
		])
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initAccelerator("X", imExport)
		initDaten(0)
		personen.setPrefWidth(9999)
		personen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			name.setText("%%")
			vorname.setText("%%")
		}
		if (stufe <= 1) {
			var List<AdPersonSitzAdresse> l = get(
				FactoryService.getAdresseService.getPersonenSitzAdresseListe(getServiceDaten, true, false,
					name.getText, vorname.getText, null, null))
			getItems(l, null, [a|new PersonenData(a)], personenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		personen.setItems(personenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colName1.setCellValueFactory([c|c.getValue.name1])
		colSitz.setCellValueFactory([c|c.getValue.name])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var AdPersonSitzAdresse k = getValue(personen, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(AD110PersonController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(personen, 1)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {
		var byte[] pdf = get(FactoryService.getAdresseService.getReportAdresse(getServiceDaten))
		Werkzeug.speicherReport(pdf, Meldungen.AD012, true)
	}

	/** 
	 * Event für ImExport.
	 */
	@FXML def void onImExport() {
		 starteFormular(typeof(AD200SchnittstelleController), DialogAufrufEnum.OHNE);
	}

	/** 
	 * Event für Personen.
	 */
	@FXML def void onPersonenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(personen, 0)
	}

	/** 
	 * Event für SitzNeu.
	 */
	@FXML def void onSitzNeu() {
		starteDialog(DialogAufrufEnum.KOPIEREN2)
	}

	/** 
	 * Event für SitzEins.
	 */
	@FXML def void onSitzEins() {

		var AdPersonSitzAdresse e = getValue(personen, true)
		if (e !== null) {
			get(FactoryService.getAdresseService.machSitzEins(getServiceDaten, e.getPersonUid, e.getSiUid))
			onAktuell
		}
	}

	/** 
	 * Event für GebListe.
	 */
	@FXML def void onGebListe() {
		 starteFormular(typeof(AD120GeburtstageController), DialogAufrufEnum.OHNE);
	}
}

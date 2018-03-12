package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpRechnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.SelectionMode
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HP420Behandlungen.
 */
class HP420BehandlungenController extends BaseController<List<HpBehandlungLeistungLang>> {

	@FXML Label behandlungen0
	@FXML TableView<BehandlungenData> behandlungen
	@FXML TableColumn<BehandlungenData, String> colPatientName
	@FXML TableColumn<BehandlungenData, LocalDate> colDatum
	@FXML TableColumn<BehandlungenData, String> colLeistung
	@FXML TableColumn<BehandlungenData, Double> colDauer
	@FXML TableColumn<BehandlungenData, String> colDiagnose
	@FXML TableColumn<BehandlungenData, String> colStatus
	@FXML TableColumn<BehandlungenData, LocalDateTime> colGa
	@FXML TableColumn<BehandlungenData, String> colGv
	@FXML TableColumn<BehandlungenData, LocalDateTime> colAa
	@FXML TableColumn<BehandlungenData, String> colAv
	ObservableList<BehandlungenData> behandlungenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Behandlungen.
	 */
	static class BehandlungenData extends BaseController.TableViewData<HpBehandlungLeistungLang> {

		SimpleStringProperty patientName
		SimpleObjectProperty<LocalDate> datum
		SimpleStringProperty leistung
		SimpleObjectProperty<Double> dauer
		SimpleStringProperty diagnose
		SimpleStringProperty status
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HpBehandlungLeistungLang v) {

			super(v)
			patientName = new SimpleStringProperty(v.patientName)
			datum = new SimpleObjectProperty<LocalDate>(v.behandlungDatum)
			leistung = new SimpleStringProperty(v.leistungZiffer)
			dauer = new SimpleObjectProperty<Double>(v.dauer)
			diagnose = new SimpleStringProperty(v.behandlungDiagnose)
			status = new SimpleStringProperty(v.behandlungStatus)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return getData.uid
		}
	}

	// @FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		behandlungen0.setLabelFor(behandlungen)
		initDaten(0)
		behandlungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			if (parameter1 instanceof HpRechnungLang) {
				// alle Behandlungen der Rechnung oder nicht zugeordnete
				var k = parameter1 as HpRechnungLang
				var l = get(
					FactoryService::heilpraktikerService.getBehandlungLeistungListe(serviceDaten, true, k.patientUid,
						k.uid, null, null, null, true, false)) // 0,nr
				getItems(l, null, [a|new BehandlungenData(a)], behandlungenData)
			}
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		behandlungen.setItems(behandlungenData)
		behandlungen.selectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		colPatientName.setCellValueFactory([c|c.value.patientName])
		colDatum.setCellValueFactory([c|c.value.datum])
		colLeistung.setCellValueFactory([c|c.value.leistung])
		colDauer.setCellValueFactory([c|c.value.dauer])
		initColumnBetrag(colDauer)
		colDiagnose.setCellValueFactory([c|c.value.diagnose])
		colStatus.setCellValueFactory([c|c.value.status])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	/** 
	 * Event für Behandlungen.
	 */
	@FXML def void onBehandlungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) { // onAendern
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		// Alle Leistungen von allen selektierten Behandlungen dazunehmen.
		var List<HpBehandlungLeistungLang> sel = getValues(behandlungen, true)
		var List<HpBehandlungLeistungLang> alle = getAllValues(behandlungen)
		var dazu = new ArrayList<HpBehandlungLeistungLang>
		for (HpBehandlungLeistungLang s : sel) {
			for (HpBehandlungLeistungLang a : alle) {
				if (Global.compString(s.behandlungUid, a.behandlungUid) === 0) {
					dazu.add(a)
				}
			}
		}
		close(dazu)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

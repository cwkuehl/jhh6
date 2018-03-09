package de.cwkuehl.jhh6.app.controller.ad

import de.cwkuehl.jhh6.api.dto.AdAdresse
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog AD130Adressen.
 */
class AD130AdressenController extends BaseController<AdAdresse> {

	@FXML Label adressen0
	@FXML TableView<AdressenData> adressen
	// @FXML Button ok
	// @FXML Button abbrechen
	@FXML TableColumn<AdressenData, String> colUid
	@FXML TableColumn<AdressenData, String> colStaat
	@FXML TableColumn<AdressenData, String> colPlz
	@FXML TableColumn<AdressenData, String> colOrt
	@FXML TableColumn<AdressenData, String> colStrasse
	@FXML TableColumn<AdressenData, String> colHausnr
	@FXML TableColumn<AdressenData, LocalDateTime> colGa
	@FXML TableColumn<AdressenData, String> colGv
	@FXML TableColumn<AdressenData, LocalDateTime> colAa
	@FXML TableColumn<AdressenData, String> colAv
	ObservableList<AdressenData> adressenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Adressen.
	 */
	static class AdressenData extends BaseController.TableViewData<AdAdresse> {

		SimpleStringProperty uid
		SimpleStringProperty staat
		SimpleStringProperty plz
		SimpleStringProperty ort
		SimpleStringProperty strasse
		SimpleStringProperty hausnr
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(AdAdresse v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			staat = new SimpleStringProperty(v.staat)
			plz = new SimpleStringProperty(v.plz)
			ort = new SimpleStringProperty(v.ort)
			strasse = new SimpleStringProperty(v.strasse)
			hausnr = new SimpleStringProperty(v.hausnr)
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

		tabbar = 0
		adressen0.setLabelFor(adressen)
		initDaten(0)
		adressen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::adresseService.getAdresseListe(serviceDaten))
			adressenData.clear
			if (l !== null) {
				for (AdAdresse v : l) {
					adressenData.add(new AdressenData(v))
				}
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

		adressen.setItems(adressenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colStaat.setCellValueFactory([c|c.value.staat])
		colPlz.setCellValueFactory([c|c.value.plz])
		colOrt.setCellValueFactory([c|c.value.ort])
		colStrasse.setCellValueFactory([c|c.value.strasse])
		colHausnr.setCellValueFactory([c|c.value.hausnr])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	/** 
	 * Event für Adressen.
	 */
	@FXML def void onAdressenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onOk
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {
		close(getValue(adressen, true))
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

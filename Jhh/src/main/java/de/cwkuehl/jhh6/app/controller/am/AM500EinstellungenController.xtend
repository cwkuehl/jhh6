package de.cwkuehl.jhh6.app.controller.am

import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.cell.TextFieldTableCell
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog AM500Einstellungen.
 */
class AM500EinstellungenController extends BaseController<String> {

	@FXML Label einstellungen0
	@FXML TableView<EinstellungenData> einstellungen
	@FXML TableColumn<EinstellungenData, Integer> colMandant
	@FXML TableColumn<EinstellungenData, String> colSchluessel
	@FXML TableColumn<EinstellungenData, String> colWert
	// @FXML private TableColumn<EinstellungenData, LocalDateTime> colGa
	@FXML TableColumn<EinstellungenData, String> colGv
	// @FXML private TableColumn<EinstellungenData, LocalDateTime> colAa
	@FXML TableColumn<EinstellungenData, String> colAv
	ObservableList<EinstellungenData> einstellungenData = FXCollections.observableArrayList
	// @FXML Button ok
	// @FXML Button abbrechen
	int mandantNr = 0

	/** 
	 * Daten für Tabelle Einstellungen.
	 */
	static class EinstellungenData extends BaseController.TableViewData<MaParameter> {

		SimpleObjectProperty<Integer> mandant
		SimpleStringProperty schluessel
		SimpleStringProperty wert
		// private SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		// private SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MaParameter v) {

			super(v)
			mandant = new SimpleObjectProperty<Integer>(v.mandantNr)
			schluessel = new SimpleStringProperty(v.schluessel)
			wert = new SimpleStringProperty(v.wert)
			// geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			// angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return schluessel.get
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		einstellungen0.setLabelFor(einstellungen)
		einstellungen.setEditable(true)
		initDaten(0)
		einstellungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var MaMandant m = parameter1
			if (m === null) {
				mandantNr = Jhh6::serviceDaten.mandantNr
			} else {
				mandantNr = m.nr
			}
		}
		if (stufe <= 1) {
			var l = Jhh6::einstellungen.getEinstellungen(mandantNr, true)
			einstellungenData.clear
			if (l !== null) {
				for (MaParameter v : l) {
					einstellungenData.add(new EinstellungenData(v))
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

		einstellungen.setItems(einstellungenData)
		colMandant.setCellValueFactory([c|c.value.mandant])
		colSchluessel.setCellValueFactory([c|c.value.schluessel])
		colWert.setCellValueFactory([c|c.value.wert])
		colWert.setCellFactory(TextFieldTableCell.forTableColumn)
		// colGa.setCellValueFactory(c -> c.value.geaendertAm)
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		// colAa.setCellValueFactory(c -> c.value.angelegtAm)
		colAv.setCellValueFactory([c|c.value.angelegtVon])
	}

	/** 
	 * Event für Einstellungen.
	 */
	@FXML def void onEinstellungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
		// onAendern
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		for (EinstellungenData e : einstellungenData) {
			Jhh6::einstellungen.setParameter(mandantNr, e.schluessel.get, e.wert.get)
		}
		Jhh6.aktualisiereTitel
		close
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

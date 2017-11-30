package de.cwkuehl.jhh6.app.controller.am

import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import java.util.List
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
	// @FXML private TableColumn<EinstellungenData, LocalDateTime> colGa;
	@FXML TableColumn<EinstellungenData, String> colGv
	// @FXML private TableColumn<EinstellungenData, LocalDateTime> colAa;
	@FXML TableColumn<EinstellungenData, String> colAv
	ObservableList<EinstellungenData> einstellungenData = FXCollections.observableArrayList()
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
		// private SimpleObjectProperty<LocalDateTime> geaendertAm;
		SimpleStringProperty geaendertVon
		// private SimpleObjectProperty<LocalDateTime> angelegtAm;
		SimpleStringProperty angelegtVon

		new(MaParameter v) {

			super(v)
			mandant = new SimpleObjectProperty<Integer>(v.getMandantNr())
			schluessel = new SimpleStringProperty(v.getSchluessel())
			wert = new SimpleStringProperty(v.getWert())
			// geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm());
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon())
			// angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm());
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon())
		}

		override String getId() {
			return schluessel.get()
		} // colGa.setCellValueFactory(c -> c.getValue().geaendertAm);
		// colAa.setCellValueFactory(c -> c.getValue().angelegtAm);
		// onAendern();
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
			var MaMandant m = getParameter1()
			if (m === null) {
				mandantNr = Jhh6.getServiceDaten().mandantNr
			} else {
				mandantNr = m.getNr()
			}
		}
		if (stufe <= 1) {
			var List<MaParameter> l = Jhh6.einstellungen.getEinstellungen(mandantNr, true)
			einstellungenData.clear()
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
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
	}

	/** 
	 * Event für Einstellungen.
	 */
	@FXML def void onEinstellungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		for (EinstellungenData e : einstellungenData) {
			Jhh6.einstellungen.setParameter(mandantNr, e.schluessel.get, e.wert.get)
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

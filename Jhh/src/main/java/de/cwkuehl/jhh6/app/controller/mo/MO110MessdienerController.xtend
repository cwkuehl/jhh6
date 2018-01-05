package de.cwkuehl.jhh6.app.controller.mo

import java.util.List
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MoMessdiener
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.SelectionMode
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog MO110Messdiener.
 */
class MO110MessdienerController extends BaseController<String> {
	@FXML Label nr0
	@FXML TextField nr
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML Label name0
	@FXML TextField name
	@FXML Label adresse10
	@FXML TextField adresse1
	@FXML TextField adresse2
	@FXML TextField adresse3
	@FXML Label telefon10
	@FXML TextField telefon1
	@FXML Label telefon20
	@FXML TextField telefon2
	@FXML Label email10
	@FXML TextField email1
	@FXML Label email20
	@FXML TextField email2
	@FXML Label mit0
	@FXML ComboBox<MitData> mit
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label dienste0
	@FXML ListView<DiensteData> dienste
	@FXML Label verfuegbar0
	@FXML ListView<VerfuegbarData> verfuegbar
	@FXML Label status0
	@FXML ComboBox<StatusData> status
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Mit.
	 */
	static class MitData extends ComboBoxData<MoMessdiener> {

		new(MoMessdiener v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getName
		}
	}

	/** 
	 * Daten für ListBox Dienste.
	 */
	static class DiensteData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
		}
	}

	/** 
	 * Daten für ListBox Verfuegbar.
	 */
	static class VerfuegbarData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
		}
	}

	/** 
	 * Daten für ComboBox Status.
	 */
	static class StatusData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		vorname0.setLabelFor(vorname)
		name0.setLabelFor(name)
		adresse10.setLabelFor(adresse1)
		telefon10.setLabelFor(telefon1)
		telefon20.setLabelFor(telefon2)
		email10.setLabelFor(email1)
		email20.setLabelFor(email2)
		mit0.setLabelFor(mit, false)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		dienste0.setLabelFor(dienste)
		initListView(dienste, null)
		verfuegbar0.setLabelFor(verfuegbar)
		initListView(verfuegbar, null)
		status0.setLabelFor(status, true)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		dienste.getSelectionModel.setSelectionMode(SelectionMode::MULTIPLE)
		verfuegbar.getSelectionModel.setSelectionMode(SelectionMode::MULTIPLE)
		initDaten(0)
		name.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<MoMessdiener> mliste = get(
				FactoryService::getMessdienerService.getMessdienerListe(getServiceDaten, true))
			mit.setItems(getItems(mliste, new MoMessdiener, [a|new MitData(a)], null))
			var List<MaEinstellung> dliste = get(
				FactoryService::getMessdienerService.getStandardDienstListe(getServiceDaten))
			dienste.setItems(getItems(dliste, null, [a|new DiensteData(a)], null))
			var List<MaEinstellung> vliste = get(
				FactoryService::getMessdienerService.getStandardVerfuegbarListe(getServiceDaten))
			verfuegbar.setItems(getItems(vliste, null, [a|new VerfuegbarData(a)], null))
			var List<MaEinstellung> sliste = get(
				FactoryService::getMessdienerService.getStandardStatusListe(getServiceDaten))
			status.setItems(getItems(sliste, null, [a|new StatusData(a)], null))
			status.getSelectionModel.select(0)
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var MoMessdiener k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::getMessdienerService.getMessdiener(getServiceDaten, k.getUid))
				nr.setText(k.getUid)
				name.setText(k.getName)
				vorname.setText(k.getVorname)
				adresse1.setText(k.getAdresse1)
				adresse2.setText(k.getAdresse2)
				adresse3.setText(k.getAdresse3)
				email1.setText(k.getEmail)
				email2.setText(k.getEmail2)
				telefon1.setText(k.getTelefon)
				telefon2.setText(k.getTelefon2)
				von.setValue(k.getVon)
				bis.setValue(k.getBis)
				setText(mit, k.getMessdienerUid)
				setTexte(dienste, k.getDienste)
				setTexte(verfuegbar, k.getVerfuegbarkeit)
				setText(status, k.getStatus)
				notiz.setText(k.getNotiz)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			name.setEditable(!loeschen)
			vorname.setEditable(!loeschen)
			adresse1.setEditable(!loeschen)
			adresse2.setEditable(!loeschen)
			adresse3.setEditable(!loeschen)
			email1.setEditable(!loeschen)
			email2.setEditable(!loeschen)
			telefon1.setEditable(!loeschen)
			telefon2.setEditable(!loeschen)
			von.setEditable(!loeschen)
			bis.setEditable(!loeschen)
			setEditable(mit, !loeschen)
			setEditable(dienste, !loeschen)
			setEditable(verfuegbar, !loeschen)
			setEditable(status, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.insertUpdateMessdiener(getServiceDaten, null, name.getText,
				vorname.getText, von.getValue, bis.getValue, adresse1.getText, adresse2.getText, adresse3.getText,
				email1.getText, email2.getText, telefon1.getText, telefon2.getText, getText(verfuegbar),
				getText(dienste), getText(mit), getText(status), notiz.getText)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.insertUpdateMessdiener(getServiceDaten, nr.getText, name.getText,
				vorname.getText, von.getValue, bis.getValue, adresse1.getText, adresse2.getText, adresse3.getText,
				email1.getText, email2.getText, telefon1.getText, telefon2.getText, getTexte(verfuegbar),
				getTexte(dienste), getText(mit), getText(status), notiz.getText)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.deleteMessdiener(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
				updateParent
				close
			}
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

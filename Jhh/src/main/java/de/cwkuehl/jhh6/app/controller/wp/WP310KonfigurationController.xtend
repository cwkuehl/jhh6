package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import de.cwkuehl.jhh6.server.fop.dto.PnfChart
import java.util.List
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP310Konfiguration.
 */
class WP310KonfigurationController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label box0
	@FXML TextField box
	@FXML ComboBox<SkalaData> skala
	@FXML Label umkehr0
	@FXML TextField umkehr
	@FXML Label methode0
	@FXML ComboBox<MethodeData> methode
	@FXML Label dauer0
	@FXML TextField dauer
	@FXML CheckBox relativ
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
	 * Daten für ComboBox Skala.
	 */
	static class SkalaData extends BaseController.ComboBoxData<MaEinstellung> {

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
	 * Daten für ComboBox Methode.
	 */
	static class MethodeData extends BaseController.ComboBoxData<MaEinstellung> {

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
	static class StatusData extends BaseController.ComboBoxData<MaEinstellung> {

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
		bezeichnung0.setLabelFor(bezeichnung, true)
		box0.setLabelFor(box, true)
		umkehr0.setLabelFor(umkehr, true)
		methode0.setLabelFor(methode, true)
		dauer0.setLabelFor(dauer, true)
		status0.setLabelFor(status, true)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		notiz.setPrefWidth(2000)
		initDaten(0)
		bezeichnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<MaEinstellung> sliste = get(
				FactoryService::getWertpapierService.getWertpapierStatusListe(getServiceDaten))
			status.setItems(getItems(sliste, null, [a|new StatusData(a)], null))
			status.getSelectionModel.select(0)
			var List<MaEinstellung> skliste = PnfChart::getSkalaListe
			skala.setItems(getItems(skliste, null, [a|new SkalaData(a)], null))
			skala.getSelectionModel.select(0)
			var List<MaEinstellung> mliste = PnfChart::getMethodeListe
			methode.setItems(getItems(mliste, null, [a|new MethodeData(a)], null))
			methode.getSelectionModel.select(0)
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var WpKonfigurationLang k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::getWertpapierService.getKonfigurationLang(getServiceDaten, k.getUid))
				nr.setText(k.getUid)
				bezeichnung.setText(k.getBezeichnung)
				box.setText(Global::dblStr(k.getBox))
				setText(skala, Global::intStr(k.getSkala))
				umkehr.setText(Global::intStr(k.getUmkehr))
				setText(methode, Global::intStr(k.getMandantNr))
				dauer.setText(Global::intStr(k.getDauer))
				relativ.setSelected(k.getRelativ)
				setText(status, k.getStatus)
				notiz.setText(k.getNotiz)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			bezeichnung.setEditable(!loeschen)
			box.setEditable(!loeschen)
			setEditable(skala, !loeschen)
			umkehr.setEditable(!loeschen)
			setEditable(methode, !loeschen)
			dauer.setEditable(!loeschen)
			setEditable(relativ, !loeschen)
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
			r = FactoryService::getWertpapierService.insertUpdateKonfiguration(getServiceDaten, null,
				bezeichnung.getText, Global::strDbl(box.getText), false, Global::strInt(umkehr.getText),
				Global::strInt(getText(methode)), Global::strInt(dauer.getText), relativ.isSelected,
				Global::strInt(getText(skala)), getText(status), notiz.getText)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getWertpapierService.insertUpdateKonfiguration(getServiceDaten, nr.getText,
				bezeichnung.getText, Global::strDbl(box.getText), false, Global::strInt(umkehr.getText),
				Global::strInt(getText(methode)), Global::strInt(dauer.getText), relativ.isSelected,
				Global::strInt(getText(skala)), getText(status), notiz.getText)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getWertpapierService.deleteKonfiguration(getServiceDaten, nr.getText)
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
	 * @FXML
	 */
	def void onAbbrechen() {
		close
	}
}

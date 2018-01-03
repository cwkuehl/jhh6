package de.cwkuehl.jhh6.app.controller.so

import java.util.List
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.detective.Runde
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.service.detective.DetektivContext
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.SelectionMode
import javafx.scene.control.TextField

/** 
 * Controller für Dialog SO210Runde.
 */
class SO210RundeController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label spieler0
	@FXML ListView<SpielerData> spieler
	@FXML Label verdaechtiger0
	@FXML ListView<VerdaechtigerData> verdaechtiger
	@FXML CheckBox besitzv
	@FXML Label werkzeug0
	@FXML ListView<WerkzeugData> werkzeug
	@FXML CheckBox besitzw
	@FXML Label raum0
	@FXML ListView<RaumData> raum
	@FXML CheckBox besitzr
	@FXML Label spielerOhne0
	@FXML ListView<SpielerOhneData> spielerOhne
	@FXML Label spielerMit0
	@FXML ListView<SpielerMitData> spielerMit
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	// @FXML Button abbrechen
	/** 
	 * Detektiv-Kontext 
	 */
	package DetektivContext context = null

	/** 
	 * Daten für ListBox Spieler.
	 */
	static class SpielerData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
	 * Daten für ListBox Verdaechtiger.
	 */
	static class VerdaechtigerData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
	 * Daten für ListBox Werkzeug.
	 */
	static class WerkzeugData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
	 * Daten für ListBox Raum.
	 */
	static class RaumData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
	 * Daten für ListBox SpielerOhne.
	 */
	static class SpielerOhneData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
	 * Daten für ListBox SpielerMit.
	 */
	static class SpielerMitData extends ComboBoxData<MaParameter> {

		new(MaParameter v) {
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
		spieler0.setLabelFor(spieler)
		initListView(spieler, null)
		verdaechtiger0.setLabelFor(verdaechtiger)
		verdaechtiger.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		werkzeug0.setLabelFor(werkzeug)
		werkzeug.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		raum0.setLabelFor(raum)
		raum.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		spielerOhne0.setLabelFor(spielerOhne)
		spielerOhne.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		spielerMit0.setLabelFor(spielerMit)
		initListView(spielerMit, null)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		spieler.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			context = getParameter1
			var List<MaParameter> sl = context.getSpieler
			spieler.setItems(getItems(sl, null, [a|new SpielerData(a)], null))
			spielerMit.setItems(getItems(sl, null, [a|new SpielerMitData(a)], null))
			spielerOhne.setItems(getItems(sl, null, [a|new SpielerOhneData(a)], null))
			var List<MaParameter> vl = context.getVerdaechtige
			verdaechtiger.setItems(getItems(vl, null, [a|new VerdaechtigerData(a)], null))
			var List<MaParameter> wl = context.getWerkzeuge
			werkzeug.setItems(getItems(wl, null, [a|new WerkzeugData(a)], null))
			var List<MaParameter> rl = context.getRaeume
			raum.setItems(getItems(rl, null, [a|new RaumData(a)], null))
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var Runde k = getParameter2
			if (!neu && k !== null) {
				nr.setText(k.getId)
				setText(spieler, k.getSpieler)
				setTexte2(verdaechtiger, k.getVerdaechtige)
				besitzv.setSelected(k.isBesitzv)
				setTexte2(werkzeug, k.getWerkzeuge)
				besitzw.setSelected(k.isBesitzw)
				setTexte2(raum, k.getRaeume)
				besitzr.setSelected(k.isBesitzr)
				setTexte2(spielerOhne, k.getSpielerOhne)
				setText(spielerMit, k.getSpielerMit)
			// angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
			// geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			setEditable(spieler, !loeschen)
			setEditable(verdaechtiger, !loeschen)
			setEditable(besitzv, !loeschen)
			setEditable(werkzeug, !loeschen)
			setEditable(besitzw, !loeschen)
			setEditable(raum, !loeschen)
			setEditable(besitzr, !loeschen)
			setEditable(spielerOhne, !loeschen)
			setEditable(spielerMit, !loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen.M2001)
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

		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			var Runde r = new Runde(Global.getUID, getText(spieler), getTexte2(verdaechtiger), besitzv.isSelected,
				getTexte2(werkzeug), besitzw.isSelected, getTexte2(raum), besitzr.isSelected, getTexte2(spielerOhne),
				getText(spielerMit))
			context.insertRunde(r)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			var Runde r = new Runde(nr.getText, getText(spieler), getTexte2(verdaechtiger), besitzv.isSelected,
				getTexte2(werkzeug), besitzw.isSelected, getTexte2(raum), besitzr.isSelected, getTexte2(spielerOhne),
				getText(spielerMit))
			context.updateRunde(r)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			if (!Global.nes(nr.getText)) {
				context.deleteRunde(nr.getText)
			}
		}
		DetektivContext.writeObject(context, Jhh6.getServiceDaten)
		updateParent
		close
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

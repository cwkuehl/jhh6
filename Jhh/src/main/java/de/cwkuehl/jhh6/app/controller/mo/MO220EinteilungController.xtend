package de.cwkuehl.jhh6.app.controller.mo

import java.util.ArrayList
import java.util.List
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MoEinteilungLang
import de.cwkuehl.jhh6.api.dto.MoMessdienerLang
import de.cwkuehl.jhh6.api.enums.MoStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.BaseController.ComboBoxData
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.app.controller.mo.MO220EinteilungController.DienstData
import de.cwkuehl.jhh6.app.controller.mo.MO220EinteilungController.Messdiener2Data
import de.cwkuehl.jhh6.app.controller.mo.MO220EinteilungController.MessdienerData
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.SelectionMode
import javafx.scene.control.TextField

/** 
 * Controller für Dialog MO220Einteilung.
 */
class MO220EinteilungController extends BaseController<List<MoEinteilungLang>> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label von0
	@FXML Datum von
	@FXML Label dienst0
	@FXML ComboBox<DienstData> dienst
	@FXML Label messdiener0
	@FXML ComboBox<MessdienerData> messdiener
	@FXML Label messdiener20
	@FXML ListView<Messdiener2Data> messdiener2
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	//@FXML Button abbrechen
	String ausschluss
	MoEinteilungLang einteilung

	/** 
	 * Daten für ComboBox Dienst.
	 */
	static class DienstData extends ComboBoxData<MaEinstellung> {

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
	 * Daten für ComboBox Messdiener.
	 */
	static class MessdienerData extends ComboBoxData<MoMessdienerLang> {

		new(MoMessdienerLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getInfo
		}
	}

	/** 
	 * Daten für ListBox Messdiener2.
	 */
	static class Messdiener2Data extends ComboBoxData<MoMessdienerLang> {

		new(MoMessdienerLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getInfo
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		von0.setLabelFor(von.getLabelForNode)
		dienst0.setLabelFor(dienst, true)
		messdiener0.setLabelFor(messdiener)
		messdiener20.setLabelFor(messdiener2, true)
		initListView(messdiener2, null)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		messdiener2.getSelectionModel.setSelectionMode(SelectionMode::MULTIPLE)
		initDaten(0)
		dienst.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<MaEinstellung> nliste = get(
				FactoryService::getMessdienerService.getStandardDienstListe(getServiceDaten))
			dienst.setItems(getItems(nliste, null, [a|new DienstData(a)], null))
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var MoEinteilungLang k = getParameter1
			if (k !== null) {
				einteilung = k
				nr.setText(k.getUid)
				von.setValue(k.getTermin)
				setText(dienst, k.getDienst)
				setText(messdiener, k.getMessdienerUid)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			var List<MoEinteilungLang> eliste = getParameter2
			if (eliste !== null) {
				var StringBuffer sb = new StringBuffer
				for (MoEinteilungLang e : eliste) {
					if (einteilung === null || Global::nes(einteilung.getMessdienerUid) ||
						Global::compString(einteilung.getMessdienerUid, e.getMessdienerUid) !== 0) {
						if (sb.length > 0) {
							sb.append(" ")
						}
						sb.append(e.getMessdienerUid)
					}
				}
				ausschluss = sb.toString
			}
			nr.setEditable(false)
			von.setEditable(false)
			setEditable(dienst, !loeschen)
			messdiener0.setVisible(!neu)
			setEditable(messdiener, !loeschen)
			messdiener.setVisible(!neu)
			messdiener20.setVisible(neu)
			setEditable(messdiener2, !loeschen)
			messdiener2.setVisible(neu)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			if (dienst.getSelectionModel.getSelectedIndex < 0) {
				dienst.getSelectionModel.select(0)
			}
			onDienst
			if (einteilung !== null && !DialogAufrufEnum::NEU.equals(getAufruf)) {
				setText(messdiener, einteilung.getMessdienerUid)
			}
		}
		if (stufe <= 1) { // stufe = 0

		}
		if (stufe <= 2) {		// initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Dienst.
	 */
	@FXML def void onDienst() {

		if (DialogAufrufEnum::NEU.equals(getAufruf)) {
			messdiener2.setItems(getItems(getMessdienerListe, null, [a|new Messdiener2Data(a)], null))
		} else {
			var String uid = getText(messdiener)
			messdiener.setItems(getItems(getMessdienerListe, null, [a|new MessdienerData(a)], null))
			setText(messdiener, uid)
		}
	}

	def List<MoMessdienerLang> getMessdienerListe() {

		var boolean automatisch = false
		if (einteilung !== null && einteilung.getGottesdienstStatus !== null &&
			einteilung.getGottesdienstStatus.equals(MoStatusEnum::AUTOMATISCH.toString)) {
			automatisch = true
		}
		var List<MoMessdienerLang> messdiener = get(
			FactoryService::getMessdienerService.getMessdienerListe(getServiceDaten, automatisch, von.getValue2,
				getText(dienst)))
		if (messdiener !== null && (Global::listLaenge(messdiener) > 0 || einteilung !== null)) {
			var boolean fehlt = true
			var List<MoMessdienerLang> liste = new ArrayList<MoMessdienerLang>
			for (MoMessdienerLang m : messdiener) {
				if (fehlt && einteilung !== null && !Global::nes(einteilung.getMessdienerUid) &&
					Global::compString(einteilung.getMessdienerUid, m.getUid) === 0) {
					fehlt = false
				}
				if (Global::nes(ausschluss) || !ausschluss.contains(m.getUid)) {
					liste.add(m)
				}
			}
			if (einteilung !== null && !Global::nes(einteilung.getMessdienerUid) && fehlt) {
				var MoMessdienerLang m = new MoMessdienerLang
				m.setUid(einteilung.getMessdienerUid)
				m.setName(einteilung.getMessdienerName)
				m.setVorname(einteilung.getMessdienerVorname)
				m.setInfo(Global::anhaengen(m.getName, ", ", m.getVorname))
				liste.add(m)
			}
			messdiener = liste
		}
		return messdiener
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		if (Global::nes(getText(dienst))) {
			throw new MeldungException(Meldungen::M2086)
		}
		var List<MoEinteilungLang> liste = new ArrayList
		if (DialogAufrufEnum::NEU.equals(getAufruf)) {
			var List<MoMessdienerLang> liste2 = getValues(messdiener2, false)
			if (Global::listLaenge(liste2) <= 0) {
				throw new MeldungException(Meldungen::M2085)
			}
			for (MoMessdienerLang m : liste2) {
				var MoEinteilungLang a = new MoEinteilungLang
				a.setMessdienerUid(m.getUid)
				a.setMessdienerName(m.getName)
				a.setMessdienerVorname(m.getVorname)
				a.setDienst(getText(dienst))
				liste.add(a)
			}
		} else {
			var MoMessdienerLang m = getValue(messdiener, false)
			if (m === null) {
				throw new MeldungException(Meldungen::M2085)
			}
			einteilung.setMessdienerUid(m.getUid)
			einteilung.setMessdienerName(m.getName)
			einteilung.setMessdienerVorname(m.getVorname)
			einteilung.setDienst(getText(dienst))
			liste.add(einteilung)
		}
		close(liste)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

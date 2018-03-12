package de.cwkuehl.jhh6.app.controller.mo

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MoEinteilungLang
import de.cwkuehl.jhh6.api.dto.MoMessdienerLang
import de.cwkuehl.jhh6.api.enums.MoStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.util.ArrayList
import java.util.List
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
	// @FXML Button abbrechen
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
			return getData.schluessel
		}

		override String toString() {
			return getData.wert
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
			return getData.uid
		}

		override String toString() {
			return getData.info
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
			return getData.uid
		}

		override String toString() {
			return getData.info
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		von0.setLabelFor(von.labelForNode)
		dienst0.setLabelFor(dienst, true)
		messdiener0.setLabelFor(messdiener)
		messdiener20.setLabelFor(messdiener2, true)
		initListView(messdiener2, null)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		messdiener2.selectionModel.setSelectionMode(SelectionMode::MULTIPLE)
		initDaten(0)
		dienst.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var nliste = get(FactoryService::messdienerService.getStandardDienstListe(serviceDaten))
			dienst.setItems(getItems(nliste, null, [a|new DienstData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var MoEinteilungLang k = parameter1
			if (k !== null) {
				einteilung = k
				nr.setText(k.uid)
				von.setValue(k.termin)
				setText(dienst, k.dienst)
				setText(messdiener, k.messdienerUid)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			var eliste = parameter2
			if (eliste !== null) {
				var sb = new StringBuffer
				for (MoEinteilungLang e : eliste) {
					if (einteilung === null || Global::nes(einteilung.messdienerUid) ||
						Global::compString(einteilung.messdienerUid, e.messdienerUid) !== 0) {
						if (sb.length > 0) {
							sb.append(" ")
						}
						sb.append(e.messdienerUid)
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
			if (dienst.selectionModel.selectedIndex < 0) {
				dienst.selectionModel.select(0)
			}
			onDienst
			if (einteilung !== null && !DialogAufrufEnum::NEU.equals(aufruf)) {
				setText(messdiener, einteilung.messdienerUid)
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
	 * Event für Dienst.
	 */
	@FXML def void onDienst() {

		if (DialogAufrufEnum::NEU.equals(aufruf)) {
			messdiener2.setItems(getItems(getMessdienerListe, null, [a|new Messdiener2Data(a)], null))
		} else {
			var uid = getText(messdiener)
			messdiener.setItems(getItems(getMessdienerListe, null, [a|new MessdienerData(a)], null))
			setText(messdiener, uid)
		}
	}

	def List<MoMessdienerLang> getMessdienerListe() {

		var automatisch = false
		if (einteilung !== null && einteilung.gottesdienstStatus !== null &&
			einteilung.gottesdienstStatus.equals(MoStatusEnum::AUTOMATISCH.toString)) {
			automatisch = true
		}
		var messdiener = get(FactoryService::messdienerService.getMessdienerListe(serviceDaten, automatisch, von.value2, //
		getText(dienst)))
		if (messdiener !== null && (Global::listLaenge(messdiener) > 0 || einteilung !== null)) {
			var fehlt = true
			var liste = new ArrayList<MoMessdienerLang>
			for (MoMessdienerLang m : messdiener) {
				if (fehlt && einteilung !== null && !Global::nes(einteilung.messdienerUid) &&
					Global::compString(einteilung.messdienerUid, m.uid) === 0) {
					fehlt = false
				}
				if (Global::nes(ausschluss) || !ausschluss.contains(m.uid)) {
					liste.add(m)
				}
			}
			if (einteilung !== null && !Global::nes(einteilung.messdienerUid) && fehlt) {
				var m = new MoMessdienerLang
				m.setUid(einteilung.messdienerUid)
				m.setName(einteilung.messdienerName)
				m.setVorname(einteilung.messdienerVorname)
				m.setInfo(Global::anhaengen(m.name, ", ", m.vorname))
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
			throw new MeldungException(Meldungen::MO035)
		}
		var liste = new ArrayList<MoEinteilungLang>
		if (DialogAufrufEnum::NEU.equals(aufruf)) {
			var List<MoMessdienerLang> liste2 = getValues(messdiener2, false)
			if (Global::listLaenge(liste2) <= 0) {
				throw new MeldungException(Meldungen::MO034)
			}
			for (MoMessdienerLang m : liste2) {
				var a = new MoEinteilungLang
				a.setMessdienerUid(m.uid)
				a.setMessdienerName(m.name)
				a.setMessdienerVorname(m.vorname)
				a.setDienst(getText(dienst))
				liste.add(a)
			}
		} else {
			var MoMessdienerLang m = getValue(messdiener, false)
			if (m === null) {
				throw new MeldungException(Meldungen::MO034)
			}
			einteilung.setMessdienerUid(m.uid)
			einteilung.setMessdienerName(m.name)
			einteilung.setMessdienerVorname(m.vorname)
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

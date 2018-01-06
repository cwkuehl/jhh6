package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.util.List
import de.cwkuehl.jhh6.api.dto.HhBuchungVm
import de.cwkuehl.jhh6.api.dto.HhEreignisVm
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
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
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM510Buchung.
 */
class VM510BuchungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label valuta0
	@FXML Datum valuta
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label summe0
	@FXML TextField summe
	@FXML Label ereignis0
	@FXML ListView<EreignisData> ereignis
	@FXML Label sollkonto0
	@FXML ListView<SollkontoData> sollkonto
	@FXML Label habenkonto0
	@FXML ListView<HabenkontoData> habenkonto
	@FXML Label bText0
	@FXML TextField bText
	@FXML Label belegNr0
	@FXML TextField belegNr
	@FXML Button neueNr
	@FXML Label belegDatum0
	@FXML Datum belegDatum
	@FXML Label schluessel0
	@FXML TextField schluessel
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	// @FXML Label buchung0
	@FXML TextField buchung
	@FXML Button ok
	@FXML Button kontentausch
	@FXML Button addition
	// @FXML Button abbrechen
	static LocalDate valutaZuletzt = LocalDate::now
	static LocalDate belegDatumZuletzt = LocalDate::now

	/** 
	 * Daten für ListBox Ereignis.
	 */
	static class EreignisData extends ComboBoxData<HhEreignisVm> {

		new(HhEreignisVm v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Daten für ListBox Sollkonto.
	 */
	static class SollkontoData extends ComboBoxData<HhKonto> {

		new(HhKonto v) {
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
	 * Daten für ListBox Habenkonto.
	 */
	static class HabenkontoData extends ComboBoxData<HhKonto> {

		new(HhKonto v) {
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
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends ComboBoxData<VmHaus> {

		new(VmHaus v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Daten für ComboBox Wohnung.
	 */
	static class WohnungData extends ComboBoxData<VmWohnungLang> {

		new(VmWohnungLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Daten für ComboBox Mieter.
	 */
	static class MieterData extends ComboBoxData<VmMieterLang> {

		new(VmMieterLang v) {
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		valuta0.setLabelFor(valuta.getLabelForNode, true)
		betrag0.setLabelFor(betrag, true)
		summe0.setLabelFor(summe)
		ereignis0.setLabelFor(ereignis)
		initListView(ereignis, ok)
		sollkonto0.setLabelFor(sollkonto, true)
		initListView(sollkonto, ok)
		habenkonto0.setLabelFor(habenkonto, true)
		initListView(habenkonto, ok)
		bText0.setLabelFor(bText, true)
		belegNr0.setLabelFor(belegNr)
		belegDatum0.setLabelFor(belegDatum.getLabelForNode)
		schluessel0.setLabelFor(schluessel)
		haus0.setLabelFor(haus, false)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		ereignis.getSelectionModel.selectedItemProperty.addListener([e|onEreignis])
		initDaten(0)
		betrag.requestFocus
		betrag.selectAll
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// letztes Datum einstellen
			valuta.setValue(valutaZuletzt)
			belegDatum.setValue(belegDatumZuletzt)
			var boolean init = false
			var List<VmHaus> hl = get(FactoryService::getVermietungService.getHausListe(getServiceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var List<VmWohnungLang> wl = get(
				FactoryService::getVermietungService.getWohnungListe(getServiceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var List<VmMieterLang> ml = get(
				FactoryService::getVermietungService.getMieterListe(getServiceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf) ||
				DialogAufrufEnum::STORNO.equals(getAufruf)
			var HhBuchungVm e = getParameter1
			if (!neu && e !== null) {
				var HhBuchungVm k = get(FactoryService::getVermietungService.getBuchungVm(getServiceDaten, e.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					valuta.setValue(k.getSollValuta)
					initListen
					init = true
					betrag.setText(Global::dblStr2l(k.getEbetrag))
					summe.setText(null)
					setText(sollkonto, k.getSollKontoUid)
					setText(habenkonto, k.getHabenKontoUid)
					bText.setText(k.getBtext)
					belegNr.setText(k.getBelegNr)
					belegDatum.setValue(k.getBelegDatum)
					schluessel.setText(k.getSchluessel)
					setText(haus, k.getHausUid)
					setText(wohnung, k.getWohnungUid)
					setText(mieter, k.getMieterUid)
					notiz.setText(k.getNotiz)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
				}
			}
			if (!init) {
				initListen
			}
			nr.setEditable(false)
			valuta.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
			summe.setEditable(false)
			setEditable(ereignis, !loeschen)
			setEditable(sollkonto, !loeschen)
			setEditable(habenkonto, !loeschen)
			bText.setEditable(!loeschen)
			belegNr.setEditable(!loeschen)
			belegDatum.setEditable(!loeschen)
			schluessel.setEditable(!loeschen)
			setEditable(haus, !loeschen)
			setEditable(wohnung, !loeschen)
			setEditable(mieter, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			buchung.setEditable(false)
			if (neu) {
				ok.setText(Meldungen::M2004)
			} else if (loeschen) {
				if (DialogAufrufEnum::LOESCHEN.equals(getAufruf)) {
					ok.setText(Meldungen::M2001)
				} else if (e !== null && Constant::KZB_STORNO.equals(e.getKz)) {
					ok.setText(Meldungen::M2005)
				} else {
					ok.setText(Meldungen::M2006)
				}
			}
			neueNr.setVisible(!loeschen)
			kontentausch.setVisible(!loeschen)
			addition.setVisible(!loeschen)
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	def private void initListen() {

		var List<HhEreignisVm> el = get(
			FactoryService::getVermietungService.getEreignisListe(getServiceDaten, valuta.getValue, valuta.getValue))
		ereignis.setItems(getItems(el, null, [a|new EreignisData(a)], null))
		var List<HhKonto> kl = get(
			FactoryService::getHaushaltService.getKontoListe(getServiceDaten, valuta.getValue, valuta.getValue))
		sollkonto.setItems(getItems(kl, null, [a|new SollkontoData(a)], null))
		habenkonto.setItems(getItems(kl, null, [a|new HabenkontoData(a)], null))
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Valuta.
	 */
	@FXML def void onValuta() {
		belegDatum.setValue(valuta.getValue)
		initListen
	}

	/** 
	 * Event für Ereignis.
	 */
	@FXML def void onEreignis() {

		var HhEreignisVm e = getValue(ereignis, false)
		if (e !== null) {
			setText(sollkonto, e.getSollKontoUid)
			setText(habenkonto, e.getHabenKontoUid)
			bText.setText(e.getEtext)
			schluessel.setText(e.getSchluessel)
			// nur Überschreiben, wenn nicht gesetzt bzw. gefüllt.
			if (!Global::nes(e.getHausUid) && Global::nes(getText(haus))) {
				setText(haus, e.getHausUid)
			}
			if (!Global::nes(e.getWohnungUid) && Global::nes(getText(wohnung))) {
				setText(wohnung, e.getWohnungUid)
			}
			if (!Global::nes(e.getMieterUid) && Global::nes(getText(mieter))) {
				setText(mieter, e.getMieterUid)
			}
			if (!Global::nes(e.getNotiz) && Global::nes(notiz.getText)) {
				notiz.setText(e.getNotiz)
			}
		}
	}

	/** 
	 * Event für NeueNr.
	 */
	@FXML def void onNeueNr() {
		if (Global::nes(belegNr.getText)) {
			var String nr = get(FactoryService::getHaushaltService.getNeueBelegNr(getServiceDaten, belegDatum.getValue))
			belegNr.setText(nr)
		}
	}

	/** 
	 * Event für Haus.
	 */
	@FXML def void onHaus() {
		var VmHaus h = getValue(haus, false)
		var VmWohnungLang w = getValue(wohnung, false)
		if (h !== null && w !== null && Global::compString(h.getUid, w.getHausUid) !== 0) {
			setText(wohnung, null)
			setText(mieter, null)
		}
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {
		var VmWohnungLang w = getValue(wohnung, false)
		if (w !== null && !Global::nes(w.getUid)) {
			setText(haus, w.getHausUid)
			var VmMieterLang m = getValue(mieter, false)
			if (m !== null && Global::compString(w.getUid, m.getWohnungUid) !== 0) {
				setText(mieter, null)
			}
		}
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {
		var VmMieterLang m = getValue(mieter, false)
		if (m !== null && !Global::nes(m.getUid)) {
			setText(wohnung, m.getWohnungUid)
			onWohnung
		}
	}

	/** 
	 * Event für Ok.
	 */
	@SuppressWarnings("unchecked") @FXML def void onOk() {

		var ServiceErgebnis<?> r = null
		var double dbB
		var double dbEB
		var double b
		dbEB = berechneBetrag
		dbB = Global::konvDM(dbEB)
		b = dbEB
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getHaushaltService.insertUpdateBuchung(getServiceDaten, null, valuta.getValue, dbB,
				dbEB, getText(sollkonto), getText(habenkonto), bText.getText, belegNr.getText, belegDatum.getValue,
				schluessel.getText, getText(haus), getText(wohnung), getText(mieter), notiz.getText, true)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getHaushaltService.insertUpdateBuchung(getServiceDaten, nr.getText, valuta.getValue,
				dbB, dbEB, getText(sollkonto), getText(habenkonto), bText.getText, belegNr.getText, belegDatum.getValue,
				schluessel.getText, getText(haus), getText(wohnung), getText(mieter), notiz.getText, true)
		} else if (DialogAufrufEnum::STORNO.equals(aufruf)) {
			r = FactoryService::getHaushaltService.storniereBuchung(getServiceDaten, nr.getText)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getHaushaltService.deleteBuchung(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
				// letztes Datum merken
				valutaZuletzt = valuta.getValue
				belegDatumZuletzt = belegDatum.getValue
				updateParent
				if (DialogAufrufEnum::NEU.equals(aufruf)) {
					var StringBuffer sb = new StringBuffer
					var HhKonto sk = getValue(sollkonto, true)
					var HhKonto hk = getValue(habenkonto, true)
					sb.append(Global::dateTimeStringForm(valuta.getValue.atStartOfDay)).append(", ").append(
						Global::dblStr2l(b)).append(", ").append(sk.getName).append(" an ").append(hk.getName).
						append(", ").append(bText.getText)
					if (!Global::nes(belegNr.getText)) {
						sb.append(", ").append(belegNr.getText)
					}
					sb.append(", ").append(Global::dateTimeStringForm(belegDatum.getValue.atStartOfDay))
					buchung.setText(sb.toString)
					betrag.setText("")
					summe.setText("")
					belegNr.setText("")
				} else {
					close
				}
			}
		}
	}

	/** 
	 * Event für Kontentausch.
	 */
	@FXML def void onKontentausch() {
		var s = getText(sollkonto)
		var h = getText(habenkonto)
		setText(sollkonto, h)
		setText(habenkonto, s)
	}

	/** 
	 * Berechnet den Betrag aus Einzelbetrag, Summe und Operator.
	 * @param operator Leer, * oder /.
	 * @param betrag Einzelbetrag.
	 * @param summe Summenbetrag.
	 * @return Summe, Produkt oder Quotient.
	 */
	def private double berechneBetrag() {

		var operator = ermittleOperator
		var b = Global::strDbl(betrag.getText)
		var d = Global::strDbl(summe.getText)
		if (Global::nes(operator)) {
			d += b
		} else if (operator.equals("*")) {
			d *= b
		} else if (b !== 0) { // operator.equals("/")
			d /= b
		}
		d = Global::rundeBetrag(d)
		return d
	}

	def private String ermittleOperator() {

		var op = ""
		var strBetrag = Global::objStr(betrag.getText)
		if (strBetrag.startsWith("+")) {
			strBetrag = strBetrag.substring(1)
		} else if (strBetrag.startsWith("*")) {
			op = "*"
			strBetrag = strBetrag.substring(1)
		} else if (strBetrag.startsWith("/")) {
			op = "/"
			strBetrag = strBetrag.substring(1)
		}
		betrag.setText(strBetrag)
		return op
	}

	/** 
	 * Event für Addition.
	 */
	@FXML def void onAddition() {
		summe.setText(Global::dblStr2l(berechneBetrag))
		betrag.setText("")
		betrag.requestFocus
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

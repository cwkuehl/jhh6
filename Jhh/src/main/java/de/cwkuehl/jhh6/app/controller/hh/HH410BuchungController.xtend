package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhEreignisLang
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.TextField

/** 
 * Controller für Dialog HH410Buchung.
 */
class HH410BuchungController extends BaseController<String> {

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
	static class EreignisData extends ComboBoxData<HhEreignisLang> {

		new(HhEreignisLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
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
			return getData.uid
		}

		override String toString() {
			return getData.name
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
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		valuta0.setLabelFor(valuta.labelForNode, true)
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
		belegDatum0.setLabelFor(belegDatum.labelForNode)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		ereignis.selectionModel.selectedItemProperty.addListener([e|onEreignis])
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
			var init = false
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf) || DialogAufrufEnum::STORNO.equals(aufruf)
			var HhBuchungLang e = parameter1
			if (!neu && e !== null) {
				var k = get(FactoryService::haushaltService.getBuchung(serviceDaten, e.uid))
				if (k !== null) {
					nr.setText(k.uid)
					valuta.setValue(k.sollValuta)
					initListen
					init = true
					betrag.setText(Global.dblStr2l(k.ebetrag))
					summe.setText(null)
					setText(sollkonto, k.sollKontoUid)
					setText(habenkonto, k.habenKontoUid)
					bText.setText(k.btext)
					belegNr.setText(k.belegNr)
					belegDatum.setValue(k.belegDatum)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
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
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			buchung.setEditable(false)
			if (neu) {
				ok.setText(Meldungen::M2004)
			} else if (loeschen) {
				if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
					ok.setText(Meldungen::M2001)
				} else if (e !== null && Constant.KZB_STORNO.equals(e.kz)) {
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

		var e = getText(ereignis)
		var s = getText(sollkonto)
		var h = getText(habenkonto)
		var el = get(FactoryService::haushaltService.getEreignisListe(serviceDaten, valuta.value, valuta.value))
		ereignis.setItems(getItems(el, null, [a|new EreignisData(a)], null))
		var kl = get(FactoryService::haushaltService.getKontoListe(serviceDaten, valuta.value, valuta.value))
		sollkonto.setItems(getItems(kl, null, [a|new SollkontoData(a)], null))
		habenkonto.setItems(getItems(kl, null, [a|new HabenkontoData(a)], null))
		setText(ereignis, e)
		setText(sollkonto, s)
		setText(habenkonto, h)
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	boolean event = true

	/** 
	 * Event für Valuta.
	 */
	@FXML def void onValuta() {
		try {
			event = false
			belegDatum.setValue(valuta.value)
			initListen
		} finally {
			event = true
		}
	}

	/** 
	 * Event für Ereignis.
	 */
	@FXML def void onEreignis() {
		if (!event) {
			return;
		}
		var HhEreignisLang e = getValue(ereignis, false)
		if (e !== null) {
			setText(sollkonto, e.sollKontoUid)
			setText(habenkonto, e.habenKontoUid)
			bText.setText(e.etext)
		}
	}

	/** 
	 * Event für NeueNr.
	 */
	@FXML def void onNeueNr() {

		if (Global.nes(belegNr.text)) {
			var nr = get(FactoryService::haushaltService.getNeueBelegNr(serviceDaten, belegDatum.value))
			belegNr.setText(nr)
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		var dbEB = berechneBetrag
		var dbB = Global.konvDM(dbEB)
		var b = dbEB
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateBuchung(serviceDaten, null, valuta.value, dbB, dbEB,
				getText(sollkonto), getText(habenkonto), bText.text, belegNr.text, belegDatum.value, null, null, null,
				null, null, false)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateBuchung(serviceDaten, nr.text, valuta.value, dbB, dbEB,
				getText(sollkonto), getText(habenkonto), bText.text, belegNr.text, belegDatum.value, null, null, null,
				null, null, false)
		} else if (DialogAufrufEnum::STORNO.equals(aufruf)) {
			r = FactoryService::haushaltService.storniereBuchung(serviceDaten, nr.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::haushaltService.deleteBuchung(serviceDaten, nr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				// letztes Datum merken
				valutaZuletzt = valuta.value
				belegDatumZuletzt = belegDatum.value
				updateParent
				if (DialogAufrufEnum::NEU.equals(aufruf)) {
					var sb = new StringBuffer
					var HhKonto sk = getValue(sollkonto, true)
					var HhKonto hk = getValue(habenkonto, true)
					sb.append(Meldungen::HH057(valuta.value.atStartOfDay, b, sk.name, hk.name, bText.text))
					if (!Global.nes(belegNr.text)) {
						sb.append(Meldungen::HH058(belegNr.text))
					}
					if (!valuta.value.equals(belegDatum.value)) {
						sb.append(Meldungen::HH059(belegDatum.value.atStartOfDay))
					}
					buchung.setText(sb.toString)
					betrag.setText("")
					summe.setText("")
					belegNr.setText("")
					betrag.requestFocus
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
		var b = Global.strDbl(betrag.text)
		var d = Global.strDbl(summe.text)
		if (Global.nes(operator)) {
			d += b
		} else if (operator.equals("*")) {
			d *= b
		} else if (b !== 0) { // operator.equals("/")
			d /= b
		}
		d = Global.rundeBetrag(d)
		return d
	}

	def private String ermittleOperator() {

		var op = ""
		var strBetrag = Global.objStr(betrag.text)
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
		summe.setText(Global.dblStr2l(berechneBetrag))
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

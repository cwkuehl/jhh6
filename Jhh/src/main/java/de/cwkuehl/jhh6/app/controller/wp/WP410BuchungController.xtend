package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
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
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP410Buchung.
 */
class WP410BuchungController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label anlage0
	@FXML ComboBox<AnlageData> anlage
	@FXML Label valuta0
	@FXML Datum valuta
	@FXML Label preis0
	@FXML TextField preis
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label rabatt0
	@FXML TextField rabatt
	@FXML Label anteile0
	@FXML TextField anteile
	@FXML Label preis20
	@FXML TextField preis2
	@FXML Label zinsen0
	@FXML TextField zinsen
	@FXML Label bText0
	@FXML TextField bText
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	// @FXML Label buchung0
	@FXML TextField buchung
	@FXML Button ok
	// @FXML Button abbrechen
	static LocalDate valutaZuletzt = LocalDate::now

	/** 
	 * Daten für ComboBox Anlage.
	 */
	static class AnlageData extends ComboBoxData<WpAnlageLang> {

		new(WpAnlageLang v) {
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		anlage0.setLabelFor(anlage, true)
		valuta0.setLabelFor(valuta.labelForNode, true)
		preis0.setLabelFor(preis)
		betrag0.setLabelFor(betrag)
		rabatt0.setLabelFor(rabatt)
		anteile0.setLabelFor(anteile)
		preis20.setLabelFor(preis2)
		zinsen0.setLabelFor(zinsen)
		bText0.setLabelFor(bText, true)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		betrag.textProperty.addListener([observable, oldValue, newValue|onAnteile])
		anteile.textProperty.addListener([observable, oldValue, newValue|onAnteile])
		initDaten(0)
		betrag.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// letztes Datum einstellen
			valuta.setValue(valutaZuletzt)
			var l = get(FactoryService::wertpapierService.getAnlageListe(serviceDaten, true, null, null, null))
			anlage.setItems(getItems(l, null, [a|new AnlageData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf) || DialogAufrufEnum::STORNO.equals(aufruf)
			var WpBuchungLang e = parameter1
			if (!neu && e !== null) {
				var k = get(FactoryService::wertpapierService.getBuchungLang(serviceDaten, e.uid))
				if (k !== null) {
					nr.setText(k.uid)
					setText(anlage, k.anlageUid)
					valuta.setValue(k.datum)
					preis.setText(Global.dblStr4l(k.stand))
					betrag.setText(Global.dblStr2l(k.zahlungsbetrag))
					rabatt.setText(Global.dblStr2l(k.rabattbetrag))
					anteile.setText(Global.dblStr5l(k.anteile))
					zinsen.setText(Global.dblStr2l(k.zinsen))
					bText.setText(k.btext)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
				}
			}
			nr.setEditable(false)
			setEditable(anlage, !loeschen)
			valuta.setEditable(!loeschen)
			preis.setEditable(!loeschen)
			betrag.setEditable(!loeschen)
			rabatt.setEditable(!loeschen)
			anteile.setEditable(!loeschen)
			preis2.setEditable(false)
			zinsen.setEditable(!loeschen)
			bText.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			buchung.setEditable(false)
			if (neu) {
				ok.setText(Meldungen::M2004)
			} else if (loeschen) {
				if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
					ok.setText(Meldungen::M2001)
				}
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

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::wertpapierService.insertUpdateBuchung(serviceDaten, null, getText(anlage), valuta.value,
				Global.strDbl(betrag.text), Global.strDbl(rabatt.text), Global.strDbl(anteile.text),
				Global.strDbl(zinsen.text), bText.text, null, Global.strDbl(preis.text))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::wertpapierService.insertUpdateBuchung(serviceDaten, nr.text, getText(anlage),
				valuta.value, Global.strDbl(betrag.text), Global.strDbl(rabatt.text), Global.strDbl(anteile.text),
				Global.strDbl(zinsen.text), bText.text, null, Global.strDbl(preis.text))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::wertpapierService.deleteBuchung(serviceDaten, nr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				// letztes Datum merken	
				valutaZuletzt = valuta.value
				updateParent
				if (DialogAufrufEnum::NEU.equals(aufruf)) {
					var WpAnlageLang a = getValue(anlage, true)
					buchung.text = Meldungen::WP030(valuta.value.atStartOfDay, betrag.text, rabatt.text, anteile.text,
						zinsen.text, a.bezeichnung, bText.text)
					betrag.text = null
					rabatt.text = null
					betrag.requestFocus
				} else {
					close
				}
			}
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}

	/** 
	 * Event für Valuta.
	 */
	@FXML def void onValuta() {

		var WpAnlageLang a = getValue(anlage, true)
		var s = get(FactoryService::wertpapierService.getStand(serviceDaten, a.wertpapierUid, valuta.value))
		preis.text = if(s === null) null else Global.dblStr2l(s.stueckpreis)
	}

	/** 
	 * Event für Anteile.
	 */
	@FXML def void onAnteile() {

		var b = Global.strDbl(betrag.text)
		var a = Global.strDbl(anteile.text)
		preis2.text = if (Global.compDouble4(a, 0) === 0 || Global.compDouble4(b, 0) === 0)
			null
		else
			Global.dblStr6l(b / a)
	}
}

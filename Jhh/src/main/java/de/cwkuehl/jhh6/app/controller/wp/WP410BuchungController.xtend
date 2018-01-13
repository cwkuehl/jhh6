package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDate
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
import de.cwkuehl.jhh6.api.dto.WpStand
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.BaseController.ComboBoxData
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.app.controller.wp.WP410BuchungController.AnlageData
import de.cwkuehl.jhh6.server.FactoryService
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
	static LocalDate valutaZuletzt = LocalDate.now

	/** 
	 * Daten für ComboBox Anlage.
	 */
	static class AnlageData extends ComboBoxData<WpAnlageLang> {

		new(WpAnlageLang v) {
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		anlage0.setLabelFor(anlage, true)
		valuta0.setLabelFor(valuta.getLabelForNode, true)
		preis0.setLabelFor(preis)
		betrag0.setLabelFor(betrag)
		rabatt0.setLabelFor(rabatt)
		anteile0.setLabelFor(anteile)
		preis20.setLabelFor(preis2)
		zinsen0.setLabelFor(zinsen)
		bText0.setLabelFor(bText, true)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		betrag.textProperty.addListener([ observable, oldValue, newValue |
			{
				onAnteile
			}
		])
		anteile.textProperty.addListener([ observable, oldValue, newValue |
			{
				onAnteile
			}
		])
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
			var List<WpAnlageLang> l = get(
				FactoryService.getWertpapierService.getAnlageListe(getServiceDaten, true, null, null, null))
			anlage.setItems(getItems(l, null, [a|new AnlageData(a)], null))
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf) ||
				DialogAufrufEnum.STORNO.equals(getAufruf)
			var WpBuchungLang e = getParameter1
			if (!neu && e !== null) {
				var WpBuchungLang k = get(FactoryService.getWertpapierService.getBuchungLang(getServiceDaten, e.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					setText(anlage, k.getAnlageUid)
					valuta.setValue(k.getDatum)
					preis.setText(Global.dblStr4l(k.getStand))
					betrag.setText(Global.dblStr2l(k.getZahlungsbetrag))
					rabatt.setText(Global.dblStr2l(k.getRabattbetrag))
					anteile.setText(Global.dblStr5l(k.getAnteile))
					zinsen.setText(Global.dblStr2l(k.getZinsen))
					bText.setText(k.getBtext)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
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
				ok.setText(Meldungen.M2004)
			} else if (loeschen) {
				if (DialogAufrufEnum.LOESCHEN.equals(getAufruf)) {
					ok.setText(Meldungen.M2001)
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

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getWertpapierService.insertUpdateBuchung(getServiceDaten, null, getText(anlage),
				valuta.getValue, Global.strDbl(betrag.getText), Global.strDbl(rabatt.getText),
				Global.strDbl(anteile.getText), Global.strDbl(zinsen.getText), bText.getText, null,
				Global.strDbl(preis.getText))
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getWertpapierService.insertUpdateBuchung(getServiceDaten, nr.getText, getText(anlage),
				valuta.getValue, Global.strDbl(betrag.getText), Global.strDbl(rabatt.getText),
				Global.strDbl(anteile.getText), Global.strDbl(zinsen.getText), bText.getText, null,
				Global.strDbl(preis.getText))
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getWertpapierService.deleteBuchung(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
				// letztes Datum merken	
				valutaZuletzt = valuta.getValue
				updateParent
				if (DialogAufrufEnum.NEU.equals(aufruf)) {
					var StringBuffer sb = new StringBuffer
					var WpAnlageLang a = getValue(anlage, true)
					sb.append(Global.dateTimeStringForm(valuta.getValue.atStartOfDay)).append(", Betrag ").append(
						betrag.getText).append(", Rabatt ").append(rabatt.getText).append(", Anteile ").append(
						anteile.getText).append(", Zinsen ").append(zinsen.getText).append(", ").append(
						a.getBezeichnung).append(", ").append(bText.getText)
					buchung.setText(sb.toString)
					betrag.setText("")
					rabatt.setText("")
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
		var WpStand s = get(
			FactoryService.getWertpapierService.getStand(getServiceDaten, a.getWertpapierUid, valuta.getValue))
		if (s === null) {
			preis.setText(null)
		} else {
			preis.setText(Global.dblStr2l(s.getStueckpreis))
		}
	}

	/** 
	 * Event für Anteile.
	 */
	@FXML def void onAnteile() {

		var b = Global.strDbl(betrag.getText)
		var a = Global.strDbl(anteile.getText)
		if (Global.compDouble4(a, 0) === 0 || Global.compDouble4(b, 0) === 0) {
			preis2.setText(null)
		} else {
			preis2.setText(Global.dblStr6l(b / a))
		}
	}
}

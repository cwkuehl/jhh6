package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDate
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpStand
import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
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
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP510Stand.
 */
class WP510StandController extends BaseController<String> {

	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@FXML Label valuta0
	@FXML Datum valuta
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	// @FXML Label buchung0
	@FXML Button ok
	// @FXML Button abbrechen
	static LocalDate valutaZuletzt = LocalDate.now

	/** 
	 * Daten für ComboBox Wertpapier.
	 */
	static class WertpapierData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
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
		wertpapier0.setLabelFor(wertpapier, true)
		valuta0.setLabelFor(valuta.getLabelForNode, true)
		betrag0.setLabelFor(betrag, true)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
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
			var List<WpWertpapierLang> l = get(
				FactoryService.getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null, null))
			wertpapier.setItems(getItems(l, null, [a|new WertpapierData(a)], null))
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var WpStandLang e = getParameter1
			if (!neu && e !== null) {
				var WpStand k = get(
					FactoryService.getWertpapierService.getStand(getServiceDaten, e.getWertpapierUid,
						e.getDatum))
					if (k !== null) {
						setText(wertpapier, k.getWertpapierUid)
						valuta.setValue(k.getDatum)
						betrag.setText(Global.dblStr4l(k.getStueckpreis))
						angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
						geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
					}
				}
				setEditable(wertpapier, !loeschen)
				valuta.setEditable(!loeschen)
				betrag.setEditable(!loeschen)
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

			var ServiceErgebnis<?> r = null
			if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
				r = FactoryService.getWertpapierService.insertUpdateStand(getServiceDaten, getText(wertpapier),
					valuta.getValue, Global.strDbl(betrag.getText))
			} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
				r = FactoryService.getWertpapierService.insertUpdateStand(getServiceDaten, getText(wertpapier),
					valuta.getValue, Global.strDbl(betrag.getText))
			} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
				r = FactoryService.getWertpapierService.deleteStand(getServiceDaten, getText(wertpapier),
					valuta.getValue)
			}
			if (r !== null) {
				get(r)
				if (r.getFehler.isEmpty) {
					if (r.getFehler.isEmpty) {
						// letztes Datum merken
						valutaZuletzt = valuta.getValue
					}
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
	
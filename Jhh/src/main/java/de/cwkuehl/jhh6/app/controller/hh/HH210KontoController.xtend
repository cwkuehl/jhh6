package de.cwkuehl.jhh6.app.controller.hh

import java.time.LocalDate
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.enums.KontoartEnum
import de.cwkuehl.jhh6.api.enums.KontokennzeichenEnum
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup

/** 
 * Controller für Dialog HH210Konto.
 */
class HH210KontoController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label kennzeichen0
	@FXML ToggleGroup kennzeichen
	@FXML Label kontoart0
	@FXML ToggleGroup kontoart
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Label buchung
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		bezeichnung0.setLabelFor(bezeichnung, true)
		kennzeichen0.setLabelFor(kennzeichen, false)
		kontoart0.setLabelFor(kontoart, true)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		bezeichnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			von.setValue(LocalDate::now)
			bis.setValue(null as LocalDate)
			setText(kontoart, KontoartEnum.AKTIVKONTO.toString)
			setText(kennzeichen, KontokennzeichenEnum.OHNE.toString)
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var aendern = DialogAufrufEnum::AENDERN.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HhKonto k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::haushaltService.getKonto(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					bezeichnung.setText(k.name)
					setText(kennzeichen, k.kz)
					setText(kontoart, k.art)
					von.setValue(k.gueltigVon)
					bis.setValue(k.gueltigBis)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
					buchung.setText(get(FactoryService::haushaltService.holeMinMaxKontoText(serviceDaten, k.uid)))
				}
			}
			nr.setEditable(false)
			bezeichnung.setEditable(!loeschen)
			setEditable(kennzeichen, !(loeschen || aendern))
			setEditable(kontoart, !(loeschen || aendern))
			von.setEditable(!loeschen)
			bis.setEditable(!loeschen)
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

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateKonto(serviceDaten, null, getText(kontoart),
				getText(kennzeichen), bezeichnung.text, von.value, bis.value, null, null, null, null, null, false)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::haushaltService.insertUpdateKonto(serviceDaten, nr.text, getText(kontoart),
				getText(kennzeichen), bezeichnung.text, von.value, bis.value, null, null, null, null, null, false)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::haushaltService.deleteKonto(serviceDaten, nr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
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

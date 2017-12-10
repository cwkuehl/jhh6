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
		bezeichnung0.setLabelFor(bezeichnung)
		setLabelFor(kennzeichen0, kennzeichen)
		setLabelFor(kontoart0, kontoart)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
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
			von.setValue(LocalDate.now)
			bis.setValue((null as LocalDate))
			setText(kontoart, KontoartEnum.AKTIVKONTO.toString)
			setText(kennzeichen, KontokennzeichenEnum.OHNE.toString)
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean aendern = DialogAufrufEnum.AENDERN.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var HhKonto k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService.getHaushaltService.getKonto(getServiceDaten, k.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					bezeichnung.setText(k.getName)
					setText(kennzeichen, k.getKz)
					setText(kontoart, k.getArt)
					von.setValue(k.getGueltigVon)
					bis.setValue(k.getGueltigBis)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
					buchung.setText(
						get(FactoryService.getHaushaltService.holeMinMaxKontoText(getServiceDaten, k.getUid)))
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
	@FXML @SuppressWarnings("unchecked") def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getHaushaltService.insertUpdateKonto(getServiceDaten, null, getText(kontoart),
				getText(kennzeichen), bezeichnung.getText, von.getValue, bis.getValue, null, null, null, null, null,
				false)
			} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
				r = FactoryService.getHaushaltService.insertUpdateKonto(getServiceDaten, nr.getText, getText(kontoart),
					getText(kennzeichen), bezeichnung.getText, von.getValue, bis.getValue, null, null, null, null, null,
					false)
				} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
					r = FactoryService.getHaushaltService.deleteKonto(getServiceDaten, nr.getText)
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
			 */
			@FXML def void onAbbrechen() {
				close
			}
		}
		
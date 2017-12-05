package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.api.dto.BenutzerLang
import de.cwkuehl.jhh6.api.enums.BerechtigungEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.PasswordField
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup

/** 
 * Controller für Dialog AG210Benutzer.
 */
class AG210BenutzerController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label benutzerId0
	@FXML TextField benutzerId
	@FXML Label kennwort0
	@FXML PasswordField kennwort
	@FXML Label berechtigung0
	@FXML ToggleGroup berechtigung
	@FXML Label geburt0
	@FXML Datum geburt
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		benutzerId0.setLabelFor(benutzerId)
		kennwort0.setLabelFor(kennwort)
		setLabelFor(berechtigung0, berechtigung)
		geburt0.setLabelFor(geburt)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		benutzerId.requestFocus()
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf())
			var boolean kopieren = DialogAufrufEnum.KOPIEREN.equals(getAufruf())
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf())
			var BenutzerLang k = getParameter1()
			if (!neu && k !== null) {
				k = get(FactoryService.getAnmeldungService().getBenutzerLang(getServiceDaten(), k.getPersonNr()))
				nr.setText(Global.intStrFormat(k.getPersonNr()))
				benutzerId.setText(k.getBenutzerId())
				kennwort.setText(k.getPasswort())
				setText(berechtigung, BerechtigungEnum.fromIntValue(k.getBerechtigung()).toString())
				geburt.setValue(k.getGeburt())
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm(), k.getAngelegtVon()))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm(), k.getGeaendertVon()))
			}
			nr.setEditable(false)
			benutzerId.setEditable(neu || kopieren)
			kennwort.setEditable(!loeschen)
			setEditable(berechtigung, !loeschen)
			geburt.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen.M2001())
			}
		}
		if (stufe <= 1) { // stufe = 0;
		}
		if (stufe <= 2) { // initDatenTable();
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
			r = FactoryService.anmeldungService.insertUpdateBenutzer(getServiceDaten(), benutzerId.getText(),
				kennwort.getText(), Global.strInt(getText(berechtigung)), 0, geburt.getValue())
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.anmeldungService.insertUpdateBenutzer(getServiceDaten(), benutzerId.getText(),
				kennwort.getText(), Global.strInt(getText(berechtigung)), Global.strInt(nr.getText()),
				geburt.getValue())
			} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
				r = FactoryService.anmeldungService.deleteBenutzer(getServiceDaten(), benutzerId.getText())
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
	
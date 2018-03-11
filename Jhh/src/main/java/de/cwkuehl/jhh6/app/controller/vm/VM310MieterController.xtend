package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmMieteLang
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
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
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM310Mieter.
 */
class VM310MieterController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label name0
	@FXML TextField name
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML Label anrede0
	@FXML TextField anrede
	@FXML Label einzug0
	@FXML Datum einzug
	@FXML Label auszug0
	@FXML Datum auszug
	// @FXML Label qm0
	@FXML TextField qm
	// @FXML Label grundmiete0
	@FXML TextField grundmiete
	// @FXML Label kaution0
	@FXML TextField kaution
	// @FXML Label antenne0
	@FXML TextField antenne
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label miete0
	@FXML TextField miete
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button mieteAendern
	// @FXML Button abbrechen
	VmMieteLang aktuelleMiete

	/** 
	 * Daten für ComboBox Wohnung.
	 */
	static class WohnungData extends ComboBoxData<VmWohnungLang> {

		new(VmWohnungLang v) {
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
		wohnung0.setLabelFor(wohnung, true)
		name0.setLabelFor(name, true)
		vorname0.setLabelFor(vorname)
		anrede0.setLabelFor(anrede)
		einzug0.setLabelFor(einzug, true)
		auszug0.setLabelFor(auszug)
		notiz0.setLabelFor(notiz)
		miete0.setLabelFor(miete)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		wohnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			einzug.setValue(LocalDate::now.withDayOfMonth(1))
			auszug.setValue(null as LocalDate)
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var VmMieterLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::vermietungService.getMieterLang(serviceDaten, k.uid))
				nr.setText(k.uid)
				setText(wohnung, k.wohnungUid)
				name.setText(k.name)
				vorname.setText(k.vorname)
				anrede.setText(k.anrede)
				einzug.setValue(k.einzugdatum)
				auszug.setValue(k.auszugdatum)
				qm.setText(Global::dblStr2l(k.wohnungQm))
				grundmiete.setText(Global::dblStr2l(k.wohnungGrundmiete))
				kaution.setText(Global::dblStr2l(k.wohnungKaution))
				antenne.setText(Global::dblStr2l(k.wohnungAntenne))
				notiz.setText(k.notiz)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			setEditable(wohnung, !loeschen)
			name.setEditable(!loeschen)
			vorname.setEditable(!loeschen)
			anrede.setEditable(!loeschen)
			einzug.setEditable(!loeschen)
			auszug.setEditable(!loeschen)
			qm.setEditable(!loeschen)
			grundmiete.setEditable(!loeschen)
			kaution.setEditable(!loeschen)
			antenne.setEditable(!loeschen)
			notiz.setEditable(!loeschen)
			miete.setEditable(false)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			mieteAendern.setVisible(!loeschen)
		}
		if (stufe <= 1) {
			aktuelleMiete = get(
				FactoryService::vermietungService.getMieteLang(serviceDaten, true, null, getText(wohnung),
					LocalDate::now))
			miete.setText(if(aktuelleMiete === null) null else aktuelleMiete.text1)
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
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateMieter(serviceDaten, null, getText(wohnung), name.text,
				vorname.text, anrede.text, einzug.value, auszug.value, Global::strDbl(qm.text),
				Global::strDbl(grundmiete.text), Global::strDbl(kaution.text), Global::strDbl(antenne.text), 0, //
				notiz.text)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::vermietungService.insertUpdateMieter(serviceDaten, nr.text, getText(wohnung), name.text,
				vorname.text, anrede.text, einzug.value, auszug.value, Global::strDbl(qm.text),
				Global::strDbl(grundmiete.text), Global::strDbl(kaution.text), Global::strDbl(antenne.text), 0, //
				notiz.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::vermietungService.deleteMieter(serviceDaten, nr.text)
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
	 * Event für MieteAendern.
	 */
	@FXML def void onMieteAendern() {

		var k = aktuelleMiete
		if (k === null) {
			k = new VmMieteLang
			k.setWohnungUid(getText(wohnung))
			k.setDatum(einzug.value)
		}
		// starteDialog(typeof(VM410MieteController), DialogAufrufEnum::KOPIEREN, k)
		initDaten(1)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

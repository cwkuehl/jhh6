package de.cwkuehl.jhh6.app.controller.hp

import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Bild
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.util.function.Consumer
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup
import javafx.scene.layout.HBox

/** 
 * Controller für Dialog HP110Patient.
 */
class HP110PatientController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML HBox bilder
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML Label name10
	@FXML TextField name1
	@FXML Label geschlecht0
	@FXML ToggleGroup geschlecht
	@FXML Label bilddaten0
	@FXML TextArea bilddaten
	@FXML Label adresse10
	@FXML TextField adresse1
	@FXML TextField adresse2
	@FXML TextField adresse3
	@FXML Label rechnung0
	@FXML ComboBox<RechnungData> rechnung
	@FXML Label geburt0
	@FXML Datum geburt
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button hinzufuegen
	// @FXML Button abbrechen
	Consumer<String> refresh

	/** 
	 * Daten für ComboBox Rechnung.
	 */
	static class RechnungData extends ComboBoxData<HpPatient> {

		new(HpPatient v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name1
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		vorname0.setLabelFor(vorname)
		name10.setLabelFor(name1, true)
		geschlecht0.setLabelFor(geschlecht, true)
		bilddaten0.setLabelFor(bilddaten)
		adresse10.setLabelFor(adresse1)
		rechnung0.setLabelFor(rechnung, false)
		geburt0.setLabelFor(geburt.labelForNode)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		refresh = [s|bilddaten.setText(Global.anhaengen(bilddaten.text, Constant.CRLF, s))]
		Bild.addDragNdrop(bilder, refresh)
		initDaten(0)
		name1.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var l = get(FactoryService::heilpraktikerService.getPatientListe(serviceDaten, true))
			rechnung.setItems(getItems(l, new HpPatient, [a|new RechnungData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var HpPatient k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::heilpraktikerService.getPatient(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					name1.setText(k.name1)
					vorname.setText(k.vorname)
					setText(geschlecht, k.geschlecht)
					adresse1.setText(k.adresse1)
					adresse2.setText(k.adresse2)
					adresse3.setText(k.adresse3)
					geburt.setValue(k.geburt)
					setText(rechnung, k.rechnungPatientUid)
					notiz.setText(k.notiz)
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
					var byteliste = get(FactoryService::heilpraktikerService.getPatientBytesListe(serviceDaten, k.uid))
					if (byteliste !== null) {
						for (ByteDaten bd : byteliste) {
							if (bd.getBytes !== null && bd.metadaten !== null) {
								new Bild(bilder, null, bd.bytes, null, bd.metadaten, refresh)
							}
						}
					}
				}
			}
			nr.setEditable(false)
			name1.setEditable(!loeschen)
			vorname.setEditable(!loeschen)
			setEditable(geschlecht, !loeschen)
			bilddaten.setEditable(!loeschen)
			adresse1.setEditable(!loeschen)
			adresse2.setEditable(!loeschen)
			adresse3.setEditable(!loeschen)
			geburt.setEditable(!loeschen)
			setEditable(rechnung, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			hinzufuegen.setVisible(!loeschen)
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
			r = FactoryService::heilpraktikerService.insertUpdatePatient(serviceDaten, null, name1.text, vorname.text,
				adresse1.text, adresse2.text, adresse3.text, getText(geschlecht), geburt.value, getText(rechnung), null,
				notiz.text, Bild.parseBilddaten(bilddaten.text, Bild.getBytesListe(bilder)))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.insertUpdatePatient(serviceDaten, nr.text, name1.text,
				vorname.text, adresse1.text, adresse2.text, adresse3.text, getText(geschlecht), geburt.value,
				getText(rechnung), null, notiz.text, Bild.parseBilddaten(bilddaten.text, Bild.getBytesListe(bilder)))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::heilpraktikerService.deletePatient(serviceDaten, nr.text)
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
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {
		var datei = DateiAuswahl.auswaehlen(true, "HP110.select.file", "HP110.select.ok", "png", "HP110.select.ext")
		if (!Global.nes(datei)) {
			new Bild(bilder, datei, null, null, null, refresh)
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

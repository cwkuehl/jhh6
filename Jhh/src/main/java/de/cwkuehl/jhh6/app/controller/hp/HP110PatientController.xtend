package de.cwkuehl.jhh6.app.controller.hp

import java.util.List
import java.util.function.Consumer
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
			return getData.getUid
		}

		override String toString() {
			return getData.getName1
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
		geburt0.setLabelFor(geburt.getLabelForNode)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		refresh = [ s |
			{
				bilddaten.setText(Global.anhaengen(bilddaten.getText, Constant.CRLF, s))
			}
		]
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
			var List<HpPatient> l = get(
				FactoryService.getHeilpraktikerService.getPatientListe(getServiceDaten, true))
			rechnung.setItems(getItems(l, new HpPatient, [a|new RechnungData(a)], null))
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var HpPatient k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService.getHeilpraktikerService.getPatient(getServiceDaten, k.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					name1.setText(k.getName1)
					vorname.setText(k.getVorname)
					setText(geschlecht, k.getGeschlecht)
					adresse1.setText(k.getAdresse1)
					adresse2.setText(k.getAdresse2)
					adresse3.setText(k.getAdresse3)
					geburt.setValue(k.getGeburt)
					setText(rechnung, k.getRechnungPatientUid)
					notiz.setText(k.getNotiz)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
					var List<ByteDaten> byteliste = get(
						FactoryService.getHeilpraktikerService.getPatientBytesListe(getServiceDaten, k.getUid))
					if (byteliste !== null) {
						for (ByteDaten bd : byteliste) {
							if (bd.getBytes !== null && bd.getMetadaten !== null) {
								new Bild(bilder, null, bd.getBytes, null, bd.getMetadaten, refresh)
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
				ok.setText(Meldungen.M2001)
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

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdatePatient(getServiceDaten, null, name1.getText,
				vorname.getText, adresse1.getText, adresse2.getText, adresse3.getText, getText(geschlecht),
				geburt.getValue, getText(rechnung), null, notiz.getText,
				Bild.parseBilddaten(bilddaten.getText, Bild.getBytesListe(bilder)))
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.insertUpdatePatient(getServiceDaten, nr.getText,
				name1.getText, vorname.getText, adresse1.getText, adresse2.getText, adresse3.getText,
				getText(geschlecht), geburt.getValue, getText(rechnung), null, notiz.getText,
				Bild.parseBilddaten(bilddaten.getText, Bild.getBytesListe(bilder)))
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getHeilpraktikerService.deletePatient(getServiceDaten, nr.getText)
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
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {
		var String datei = DateiAuswahl.auswaehlen(true, "", "Bild-Datei auswählen", "png", "Bild-Dateien (.png)")
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

package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.util.List
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.SelectionMode
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP220Schnittstelle.
 */
class WP220SchnittstelleController extends BaseController<String> {

	@FXML Label datum0
	@FXML Label datum20
	@FXML Datum datum
	@FXML Datum datum2
	@FXML Datum datum3
	@FXML Datum datum4
	@FXML Label anzahl0
	@FXML @Profil(defaultValue="5") TextField anzahl
	@FXML Label bezeichnung0
	@FXML @Profil(defaultValue="%%") TextField bezeichnung
	@FXML Label konfiguration0
	@FXML @Profil ListView<KonfigurationData> konfiguration
	@FXML Label datei0
	@FXML @Profil TextField datei
	// @FXML Label datei20
	@FXML @Profil TextField datei2
	@FXML TextField statustext
	// @FXML Button dateiAuswahl
	// @FXML Button datei2Auswahl
	// @FXML Button export
	// @FXML Button export2
	@FXML Label wertpapier0
	@FXML @Profil ListView<WertpapierData> wertpapier
	// @FXML Button abbrechen
	/** 
	 * Abbruch-Objekt. 
	 */
	StringBuffer abbruch = new StringBuffer
	/** 
	 * Status zum Anzeigen. 
	 */
	StringBuffer status = new StringBuffer

	/** 
	 * Daten für ListBox Konfiguration.
	 */
	static class KonfigurationData extends ComboBoxData<WpKonfigurationLang> {

		new(WpKonfigurationLang v) {
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
	 * Daten für ListBox Wertpapier.
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
		datum0.setLabelFor(datum)
		anzahl0.setLabelFor(anzahl)
		bezeichnung0.setLabelFor(bezeichnung)
		konfiguration0.setLabelFor(konfiguration)
		datei0.setLabelFor(datei)
		initDaten(0)
		konfiguration.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		datei.setPrefWidth(9999)
		datei.requestFocus
		datum20.setLabelFor(datum2)
		wertpapier0.setLabelFor(wertpapier)
		wertpapier.getSelectionModel.setSelectionMode(SelectionMode.MULTIPLE)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var LocalDate heute = LocalDate.now
			datum.setValue(Global.werktag(heute))
			datum2.setValue(Global.werktag(LocalDate.of(heute.getYear - 1, 1, 1)))
			datum3.setValue(Global.werktag(LocalDate.of(heute.getYear, 1, 1)))
			datum4.setValue(Global.werktag(heute))
			var List<WpKonfigurationLang> kliste = get(
				FactoryService.getWertpapierService.getKonfigurationListe(getServiceDaten, true, "1"))
			konfiguration.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			leseResourceDaten(this, "konfiguration")
			var List<WpWertpapierLang> wliste = get(
				FactoryService.getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null, null))
			wertpapier.setItems(getItems(wliste, null, [a|new WertpapierData(a)], null))
			leseResourceDaten(this, "wertpapier")
			statustext.setEditable(false)
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Event für DateiAuswahl.
	 */
	@FXML def void onDateiAuswahl() {
		var String d = DateiAuswahl.auswaehlen(true, "WP220.select.file", "WP220.select.ok", "csv", "WP220.select.ext")
		if (!Global.nes(d)) {
			datei.setText(d)
		}
	}

	/** 
	 * Event für Datei2Auswahl.
	 */
	@FXML def void onDatei2Auswahl() {
		var String d = DateiAuswahl.auswaehlen(true, "WP220.select2.file", "WP220.select2.ok", "xls", "WP220.select2.ext")
		if (!Global.nes(d)) {
			datei2.setText(d)
		}
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		if (Global.nes(datei.getText)) {
			throw new MeldungException(Meldungen.M1012)
		}
		var Task<Void> task = [
			status.append("Vorbereitung ...")
			onStatusTimer
			try {
				var ServiceErgebnis<List<String>> r = FactoryService.getWertpapierService.
					exportWertpapierListe(getServiceDaten, bezeichnung.getText, null, null, getTexte(konfiguration),
						datum.getValue, Global.strInt(anzahl.getText), status, abbruch)
				r.throwErstenFehler
				if (abbruch.length <= 0) {
					Werkzeug.speicherDateiOeffnen(r.getErgebnis, null, datei.getText, false)
				}
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append('''Fehler: «ex.getMessage»''')
			} finally {
				abbruch.append("Ende")
			}
			return null
		]
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	/** 
	 * Event für Export2.
	 */
	@FXML def void onExport2() {

		if (Global.nes(getText(wertpapier))) {
			throw new MeldungException(Meldungen.M2094)
		}
		if (Global.nes(datei2.getText)) {
			throw new MeldungException(Meldungen.M1012)
		}
		var Task<Void> task = [
			status.append("Vorbereitung ...")
			onStatusTimer
			try {
				var ServiceErgebnis<byte[]> r = FactoryService.getWertpapierService.
					exportWertpapierVergleichListe(getServiceDaten, getTexte(wertpapier), getText(konfiguration),
						datum2.getValue, datum3.getValue, datum4.getValue, status, abbruch)
				r.throwErstenFehler
				if (abbruch.length <= 0) {
					Werkzeug.speicherDateiOeffnen(r.getErgebnis, null, datei2.getText, false)
				}
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append('''Fehler: «ex.getMessage»''')
			} finally {
				abbruch.append("Ende")
			}
			return null
		]
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {

		if (abbruch.length <= 0) {
			abbruch.append("Abbruch")
		} else {
			close
		}
	}

	def private void onStatusTimer() {

		status.setLength(0)
		abbruch.setLength(0)
		onStatus
		var Task<Void> task = [
			try {
				while (true) {
					onStatus
					Thread.sleep(1000)
				}
			} catch (Exception ex) {
				Global.machNichts
			}
			return null
		]
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onStatus() {

		statustext.setText(status.toString)
		Jhh6.setLeftStatus2(status.toString)
		if (abbruch.length > 0) {
			throw new RuntimeException("")
		}
	}
}

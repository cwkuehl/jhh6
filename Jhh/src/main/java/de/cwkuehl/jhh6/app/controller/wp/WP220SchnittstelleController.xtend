package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
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
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
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
		datum0.setLabelFor(datum)
		anzahl0.setLabelFor(anzahl)
		bezeichnung0.setLabelFor(bezeichnung)
		konfiguration0.setLabelFor(konfiguration)
		datei0.setLabelFor(datei)
		initDaten(0)
		konfiguration.selectionModel.setSelectionMode(SelectionMode.MULTIPLE)
		datei.setPrefWidth(9999)
		datei.requestFocus
		datum20.setLabelFor(datum2)
		wertpapier0.setLabelFor(wertpapier)
		wertpapier.selectionModel.setSelectionMode(SelectionMode.MULTIPLE)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var heute = LocalDate::now
			datum.setValue(Global.werktag(heute))
			datum2.setValue(Global.werktag(LocalDate.of(heute.year - 1, 1, 1)))
			datum3.setValue(Global.werktag(LocalDate.of(heute.year, 1, 1)))
			datum4.setValue(Global.werktag(heute))
			var kliste = get(FactoryService::wertpapierService.getKonfigurationListe(serviceDaten, true, "1"))
			konfiguration.setItems(getItems(kliste, new WpKonfigurationLang, [a|new KonfigurationData(a)], null))
			leseResourceDaten(this, "konfiguration")
			var wliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
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
		var d = DateiAuswahl.auswaehlen(true, "WP220.select.file", "WP220.select.ok", "csv", "WP220.select.ext")
		if (!Global.nes(d)) {
			datei.setText(d)
		}
	}

	/** 
	 * Event für Datei2Auswahl.
	 */
	@FXML def void onDatei2Auswahl() {
		var d = DateiAuswahl.auswaehlen(true, "WP220.select2.file", "WP220.select2.ok", "xls", "WP220.select2.ext")
		if (!Global.nes(d)) {
			datei2.setText(d)
		}
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		if (Global.nes(datei.text)) {
			throw new MeldungException(Meldungen::M1012)
		}
		var task = [
			status.append(Meldungen::WP027)
			onStatusTimer
			try {
				var r = FactoryService::wertpapierService.exportWertpapierListe(serviceDaten, bezeichnung.text, null,
					null, getTexte(konfiguration), datum.value, Global.strInt(anzahl.text), status, abbruch)
				r.throwErstenFehler
				if (abbruch.length <= 0) {
					Werkzeug.speicherDateiOeffnen(r.ergebnis, null, datei.text, false)
				}
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen::M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			return null as Void
		] as Task<Void>
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	/** 
	 * Event für Export2.
	 */
	@FXML def void onExport2() {

		if (Global.nes(getText(wertpapier))) {
			throw new MeldungException(Meldungen::M2094)
		}
		if (Global.nes(datei2.text)) {
			throw new MeldungException(Meldungen::M1012)
		}
		var task = [
			status.append(Meldungen::WP027)
			onStatusTimer
			try {
				var r = FactoryService::wertpapierService.exportWertpapierVergleichListe(serviceDaten,
					getTexte(wertpapier), getText(konfiguration), datum2.value, datum3.value, datum4.value, status, //
					abbruch)
				r.throwErstenFehler
				if (abbruch.length <= 0) {
					Werkzeug.speicherDateiOeffnen(r.ergebnis, null, datei2.text, false)
				}
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen::M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			return null as Void
		] as Task<Void>
		var th = new Thread(task)
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
		var task = [
			try {
				while (true) {
					onStatus
					Thread.sleep(1000)
				}
			} catch (Exception ex) {
				Global.machNichts
			}
			return null as Void
		] as Task<Void>
		var th = new Thread(task)
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

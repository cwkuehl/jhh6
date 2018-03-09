package de.cwkuehl.jhh6.app.controller.ag

import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.service.backup.Sicherung
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog AG400Sicherungen.
 */
class AG400SicherungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label verzeichnisse0
	@FXML TableView<VerzeichnisseData> verzeichnisse
	@FXML TableColumn<VerzeichnisseData, Integer> colNr
	@FXML TableColumn<VerzeichnisseData, String> colSchluessel
	@FXML TableColumn<VerzeichnisseData, String> colWert
	@FXML TableColumn<VerzeichnisseData, LocalDateTime> colGa
	@FXML TableColumn<VerzeichnisseData, String> colGv
	@FXML TableColumn<VerzeichnisseData, LocalDateTime> colAa
	@FXML TableColumn<VerzeichnisseData, String> colAv
	ObservableList<VerzeichnisseData> verzeichnisseData = FXCollections::observableArrayList
	// @FXML Button sicherung
	// @FXML Button diffSicherung
	// @FXML Button rueckSicherung
	// @FXML Button abbrechen
	@FXML Label status0
	@FXML TextArea statusText
	// @FXML Button mandantKopieren
	// @FXML Button mandantRepKopieren
	@FXML Label mandant0
	@FXML TextField mandant

	/** 
	 * Abbruch-Objekt. 
	 */
	StringBuffer abbruch = new StringBuffer
	/** 
	 * Status zum Anzeigen. 
	 */
	StringBuffer status = new StringBuffer
	/** 
	 * Liste für Kopier-Fehler. 
	 */
	package List<String> kopierFehler = new ArrayList<String>
	/** 
	 * Maximale Anzahl Fehler. 
	 */
	int maxFehler = Sicherung::MAX_SICHERUNG_FEHLER
	/** 
	 * Zeit in Millisekunden, die sich die Dateien unterscheiden dürfen, um als gleich zu gelten.
	 */
	long diffZeit = Sicherung::MAX_SICHERUNG_DIFFZEIT

	/** 
	 * Daten für Tabelle Verzeichnisse.
	 */
	static class VerzeichnisseData extends TableViewData<MaEinstellung> {

		SimpleObjectProperty<Integer> nr
		SimpleStringProperty schluessel
		SimpleStringProperty wert
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MaEinstellung v) {

			super(v)
			nr = new SimpleObjectProperty<Integer>(v.mandantNr)
			schluessel = new SimpleStringProperty(v.schluessel)
			wert = new SimpleStringProperty(v.wert)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return '''«nr.get»'''
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		verzeichnisse0.setLabelFor(verzeichnisse)
		status0.setLabelFor(statusText)
		mandant0.setLabelFor(mandant)
		initAccelerator("A", aktuell)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		verzeichnisse.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			mandant.setText(Global::intStr(getServiceDaten.mandantNr))
		// mandant.setText("3")
		}
		if (stufe <= 1) {
			var List<MaEinstellung> l = getSicherungen
			getItems(l, null, [a|new VerzeichnisseData(a)], verzeichnisseData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		verzeichnisse.setItems(verzeichnisseData)
		colNr.setCellValueFactory([c|c.value.nr])
		colSchluessel.setCellValueFactory([c|c.getValue.schluessel])
		colWert.setCellValueFactory([c|c.value.wert])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		speichern
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		var VerzeichnisseData k = getValue2(verzeichnisse, !DialogAufrufEnum::NEU.equals(aufruf))
		var MaEinstellung e = if(k === null) null else k.getData
		e = starteDialog(typeof(AG410SicherungController), aufruf, e)
		if (e !== null) {
			if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
				e.setMandantNr(verzeichnisseData.size + 1)
				verzeichnisseData.add(new VerzeichnisseData(e))
			} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
				k.schluessel.set(e.schluessel)
				k.wert.set(e.getWert)
			} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
				verzeichnisse.getItems.remove(k)
			}
		}
		speichern
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(verzeichnisse, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6::rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6::redo)
		onAktuell
	}

	/** 
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum::NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum::KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum::AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum::LOESCHEN)
	}

	/** 
	 * Event für Verzeichnisse.
	 */
	@FXML def void onVerzeichnisseMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Sicherung.
	 */
	@FXML def void onSicherung() {
		onSicherungTimer(false, false)
	}

	/** 
	 * Event für DiffSicherung.
	 */
	@FXML def void onDiffSicherung() {
		onSicherungTimer(true, false)
	}

	/** 
	 * Event für RueckSicherung.
	 */
	@FXML def void onRueckSicherung() {
		onSicherungTimer(false, true)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		abbruch.append("Abbruch")
	}

	def private List<MaEinstellung> getSicherungen() {

		var List<MaEinstellung> v = new ArrayList<MaEinstellung>
		var MaEinstellung e = null
		var String str = null
		var String wert = null
		var String[] array = null
		var boolean ende = false
		for (var int i = 1; !ende; i++) {
			str = '''Sicherung_«i»'''
			wert = Jhh6::getEinstellungen.holeResourceDaten(str)
			if (Global::nes(wert)) {
				ende = true
			} else {
				e = new MaEinstellung
				e.setMandantNr(i)
				array = Sicherung::splitQuelleZiel(wert, false)
				e.setSchluessel(array.get(0))
				e.setWert(array.get(1))
				v.add(e)
			}
		}
		return v
	}

	def private void speichern() {

		var i = 0
		for (VerzeichnisseData e : verzeichnisse.getItems) {
			i++
			Jhh6::getEinstellungen.setzeResourceDaten('''Sicherung_«i»''',
				'''«e.getData.getSchluessel»<«e.getData.getWert»''')
		}
		Jhh6::getEinstellungen.setzeResourceDaten('''Sicherung_«(i + 1)»''', "")
	}

	def private void onSicherungTimer(boolean diffSicherung, boolean zurueck) {

		val MaEinstellung k = getValue(verzeichnisse, true)
		val Task<Void> task = ([|
			status.setLength(0)
			abbruch.setLength(0)
			kopierFehler.clear
			onSicherungStatus
			var String sicherung0 = '''«k.getSchluessel»<«k.wert»'''
			var String[] sicherungen = (#[sicherung0] as String[])
			onSicherungStatusTimer
			try {
				var Sicherung sicherung = new Sicherung(diffZeit, kopierFehler, status, maxFehler, abbruch,
					diffSicherung, zurueck, LocalDateTime::now)
				status.append(Meldungen.M1031)
				for (var int i = 0; sicherungen !== null && i < sicherungen.length; i++) {
					sicherung.machSicherungVorbereitung({
						val _rdIndx_sicherungen = i
						sicherungen.get(_rdIndx_sicherungen)
					})
				}
				status.setLength(0)
				status.append(Meldungen.M1032)
				sicherung.machSicherung
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen.M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			null as Void
		] as Task<Void>)
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onSicherungStatus() {

		// Platform.runLater(() -> statusText.setText(status.toString))
		statusText.setText(status.toString)
		// view.setKopierFehler(model.getDaten.getKopierFehler)
		if (abbruch.length > 0) {
			throw new RuntimeException("")
		}
	}

	def private void onSicherungStatusTimer() {

		var Task<Void> task = ([|
			try {
				while (true) {
					onSicherungStatus
					Thread::sleep(1000)
				}
			} catch (Exception ex) {
				Global::machNichts
			}
			return null as Void
		] as Task<Void>)
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onMandantKopierenTimer(boolean vonRep) {

		if (Werkzeug::showYesNoQuestion(Meldungen::M1010) === 0) {
			return;
		}
		var Task<Void> task = ([|
			status.setLength(0)
			abbruch.setLength(0)
			kopierFehler.clear
			onSicherungStatus
			onSicherungStatusTimer
			try {
				// ServiceErgebnis<Void> r = FactoryService.getReplikationService.copyMandant(getServiceDaten,
				// vonRep, Global.strInt(mandant.getText), status, abbruch);
				// r.throwErstenFehler
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen.M1033(ex.getMessage))
			} finally {
				abbruch.append("Ende")
			}
			return null as Void
		] as Task<Void>)
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	/** 
	 * Event für MandantKopieren.
	 */
	@FXML def void onMandantKopieren() {
		onMandantKopierenTimer(false)
	}

	/** 
	 * Event für MandantRepKopieren.
	 */
	@FXML def void onMandantRepKopieren() {
		onMandantKopierenTimer(true)
	}
}

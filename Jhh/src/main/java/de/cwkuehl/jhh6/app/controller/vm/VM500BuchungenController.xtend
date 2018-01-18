package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.HhBuchungVm
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog VM500Buchungen.
 */
class VM500BuchungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button sollstellung
	@FXML Button istzahlung
	@FXML Label buchungen0
	@FXML TableView<BuchungenData> buchungen
	@FXML TableColumn<BuchungenData, String> colUid
	@FXML TableColumn<BuchungenData, LocalDate> colValuta
	@FXML TableColumn<BuchungenData, String> colKz
	@FXML TableColumn<BuchungenData, Double> colBetrag
	@FXML TableColumn<BuchungenData, String> colText
	@FXML TableColumn<BuchungenData, String> colSoll
	@FXML TableColumn<BuchungenData, String> colHaben
	@FXML TableColumn<BuchungenData, String> colHaus
	@FXML TableColumn<BuchungenData, String> colWohnung
	@FXML TableColumn<BuchungenData, String> colMieter
	@FXML TableColumn<BuchungenData, LocalDateTime> colGa
	@FXML TableColumn<BuchungenData, String> colGv
	@FXML TableColumn<BuchungenData, LocalDateTime> colAa
	@FXML TableColumn<BuchungenData, String> colAv
	ObservableList<BuchungenData> buchungenData = FXCollections::observableArrayList
	@FXML Label kennzeichen0
	@FXML ToggleGroup kennzeichen
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label bText0
	@FXML TextField bText
	@FXML Label betrag0
	@FXML TextField betrag
	@FXML Label konto0
	@FXML ComboBox<KontoData> konto
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	// @FXML Button alle
	String letzterStorno = null

	/** 
	 * Daten für Tabelle Buchungen.
	 */
	static class BuchungenData extends TableViewData<HhBuchungVm> {

		SimpleStringProperty uid
		SimpleObjectProperty<LocalDate> valuta
		SimpleStringProperty kz
		SimpleObjectProperty<Double> betrag
		SimpleStringProperty text
		SimpleStringProperty soll
		SimpleStringProperty haben
		SimpleStringProperty haus
		SimpleStringProperty wohnung
		SimpleStringProperty mieter
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhBuchungVm v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			valuta = new SimpleObjectProperty<LocalDate>(v.getSollValuta)
			kz = new SimpleStringProperty(v.getKz)
			betrag = new SimpleObjectProperty<Double>(v.getEbetrag)
			text = new SimpleStringProperty(v.getBtext)
			soll = new SimpleStringProperty(v.getSollName)
			haben = new SimpleStringProperty(v.getHabenName)
			haus = new SimpleStringProperty(v.getHausBezeichnung)
			wohnung = new SimpleStringProperty(v.getWohnungBezeichnung)
			mieter = new SimpleStringProperty(v.getMieterName)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}

	/** 
	 * Daten für ComboBox Konto.
	 */
	static class KontoData extends ComboBoxData<HhKonto> {

		new(HhKonto v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getName
		}
	}

	/** 
	 * Daten für ComboBox Haus.
	 */
	static class HausData extends ComboBoxData<VmHaus> {

		new(VmHaus v) {
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
	 * Daten für ComboBox Wohnung.
	 */
	static class WohnungData extends ComboBoxData<VmWohnungLang> {

		new(VmWohnungLang v) {
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
	 * Daten für ComboBox Mieter.
	 */
	static class MieterData extends ComboBoxData<VmMieterLang> {

		new(VmMieterLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getName
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		buchungen0.setLabelFor(buchungen)
		kennzeichen0.setLabelFor(kennzeichen, false)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		bText0.setLabelFor(bText)
		betrag0.setLabelFor(betrag)
		konto0.setLabelFor(konto, false)
		haus0.setLabelFor(haus, false)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("S", sollstellung)
		initAccelerator("I", istzahlung)
		initDaten(0)
		buchungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			setText(kennzeichen, "1")
			var LocalDate d = LocalDate::now
			d = d.withDayOfMonth(d.lengthOfMonth)
			bis.setValue(d)
			von.setValue(d.minusMonths(13).withDayOfMonth(1))
			bText.setText("%%")
			var List<HhKonto> kl = get(
				FactoryService::getHaushaltService.getKontoListe(getServiceDaten, bis.getValue, von.getValue))
			konto.setItems(getItems(kl, new HhKonto, [a|new KontoData(a)], null))
			var List<VmHaus> hl = get(FactoryService::getVermietungService.getHausListe(getServiceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var List<VmWohnungLang> wl = get(
				FactoryService::getVermietungService.getWohnungListe(getServiceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var List<VmMieterLang> ml = get(
				FactoryService::getVermietungService.getMieterListe(getServiceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			setText(konto, null)
			setText(haus, null)
			setText(wohnung, null)
			setText(mieter, null)
		}
		if (stufe <= 1) {
			var List<HhBuchungVm> l = get(
				FactoryService::getVermietungService.getBuchungListe(getServiceDaten,
					Global::objBool(getText(kennzeichen)), von.getValue, bis.getValue, bText.getText, getText(konto),
					betrag.getText, getText(haus), getText(wohnung), getText(mieter)))
			getItems(l, null, [a|new BuchungenData(a)], buchungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		buchungen.setItems(buchungenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colValuta.setCellValueFactory([c|c.getValue.valuta])
		colKz.setCellValueFactory([c|c.getValue.kz])
		colText.setCellValueFactory([c|c.getValue.text])
		colBetrag.setCellValueFactory([c|c.getValue.betrag])
		initColumnBetrag(colBetrag)
		colSoll.setCellValueFactory([c|c.getValue.soll])
		colHaben.setCellValueFactory([c|c.getValue.haben])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colWohnung.setCellValueFactory([c|c.getValue.wohnung])
		colMieter.setCellValueFactory([c|c.getValue.mieter])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum faufruf) {

		var aufruf = faufruf
		var HhBuchungVm k = getValue(buchungen, !DialogAufrufEnum::NEU.equals(aufruf))
		if (DialogAufrufEnum::STORNO.equals(aufruf)) {
			if (Global::compString(letzterStorno, k.getUid) === 0) {
				aufruf = DialogAufrufEnum::LOESCHEN
			}
			letzterStorno = k.getUid
		}
		starteFormular(typeof(VM510BuchungController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(buchungen, 1)
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
		starteDialog(DialogAufrufEnum::STORNO)
	}

	/** 
	 * Event für Sollstellung.
	 */
	@FXML def void onSollstellung() {
		starteDialog(typeof(VM520SollstellungController), DialogAufrufEnum::NEU)
		onAktuell
	}

	/** 
	 * Event für Istzahlung.
	 */
	@FXML def void onIstzahlung() {
		starteDialog(typeof(VM530IstzahlungController), DialogAufrufEnum::NEU)
		onAktuell
	}

	/** 
	 * Event für Buchungen.
	 */
	@FXML def void onBuchungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Von.
	 */
	@FXML def void onVon() {
		onAktuell
	}

	/** 
	 * Event für Bis.
	 */
	@FXML def void onBis() {
		onAktuell
	}

	/** 
	 * Event für Konto.
	 */
	@FXML def void onKonto() {
		onAktuell
	}

	/** 
	 * Event für Haus.
	 */
	@FXML def void onHaus() {
		var VmHaus h = getValue(haus, false)
		var VmWohnungLang w = getValue(wohnung, false)
		if (h !== null && w !== null && Global::compString(h.getUid, w.getHausUid) !== 0) {
			setText(wohnung, null)
			setText(mieter, null)
		}
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {
		var VmWohnungLang w = getValue(wohnung, false)
		if (w !== null && !Global::nes(w.getUid)) {
			setText(haus, w.getHausUid)
			var VmMieterLang m = getValue(mieter, false)
			if (m !== null && Global::compString(w.getUid, m.getWohnungUid) !== 0) {
				setText(mieter, null)
			}
		}
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {
		var VmMieterLang m = getValue(mieter, false)
		if (m !== null && !Global::nes(m.getUid)) {
			setText(wohnung, m.getWohnungUid)
			onWohnung
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(buchungen, 0)
	}
}

package de.cwkuehl.jhh6.app.controller.hh

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
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
 * Controller für Dialog HH400Buchungen.
 */
class HH400BuchungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button export
	@FXML Label buchungen0
	@FXML TableView<BuchungenData> buchungen
	@FXML TableColumn<BuchungenData, String> colUid
	@FXML TableColumn<BuchungenData, LocalDate> colValuta
	@FXML TableColumn<BuchungenData, String> colKz
	@FXML TableColumn<BuchungenData, Double> colBetrag
	@FXML TableColumn<BuchungenData, String> colText
	@FXML TableColumn<BuchungenData, String> colSoll
	@FXML TableColumn<BuchungenData, String> colHaben
	@FXML TableColumn<BuchungenData, LocalDateTime> colGa
	@FXML TableColumn<BuchungenData, String> colGv
	@FXML TableColumn<BuchungenData, LocalDateTime> colAa
	@FXML TableColumn<BuchungenData, String> colAv
	ObservableList<BuchungenData> buchungenData = FXCollections::observableArrayList
	@FXML Label buchungenStatus
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
	// @FXML Button alle
	String letzterStorno = null
	String titel = null

	/** 
	 * Daten für Tabelle Buchungen.
	 */
	static class BuchungenData extends BaseController.TableViewData<HhBuchungLang> {

		SimpleStringProperty uid
		SimpleObjectProperty<LocalDate> valuta
		SimpleStringProperty kz
		SimpleObjectProperty<Double> betrag
		SimpleStringProperty text
		SimpleStringProperty soll
		SimpleStringProperty haben
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhBuchungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			valuta = new SimpleObjectProperty<LocalDate>(v.getSollValuta)
			kz = new SimpleStringProperty(v.getKz)
			betrag = new SimpleObjectProperty<Double>(v.getEbetrag)
			text = new SimpleStringProperty(v.getBtext)
			soll = new SimpleStringProperty(v.getSollName)
			haben = new SimpleStringProperty(v.getHabenName)
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
	static class KontoData extends BaseController.ComboBoxData<HhKonto> {

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
	 * Titel des Dialogs.
	 */
	override protected String getTitel() {
		if (Global::nes(titel)) {
			return super.getTitel
		}
		return titel
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
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("X", export)
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
			betrag.setText(null)
			var List<HhKonto> kl = get(
				FactoryService::getHaushaltService.getKontoListe(getServiceDaten, bis.getValue, von.getValue))
			konto.setItems(getItems(kl, new HhKonto, [a|new KontoData(a)], null))
			setText(konto, null)
			var LocalDate v = getParameter1
			if (v !== null) {
				von.setValue(v)
			}
			var LocalDate b = getParameter2
			if (b !== null) {
				bis.setValue(b)
			}
			val HhBilanzSb bi = getParameter3
			if (bi !== null) {
				setText(konto, bi.getKontoUid)
				titel = kl.stream.filter([a|a.getUid.equals(bi.getKontoUid)]).map([a|a.getName]).findFirst.
					orElse(null)
			}
		}
		if (stufe <= 1) {
			var List<HhBuchungLang> l = get(
				FactoryService::getHaushaltService.getBuchungListe(getServiceDaten,
					Global::objBool(getText(kennzeichen)), von.getValue, bis.getValue, bText.getText,
					getText(konto), betrag.getText))
			getItems(l, null, [a|new BuchungenData(a)], buchungenData)
			var int anz = Global::listLaenge(l)
			var double summe = 0
			var double saldo = 0
			var String uid = getText(konto)
			if (l !== null) {
				for (HhBuchungLang b : l) {
					summe += b.getEbetrag
					if (b.getSollKontoUid.equals(uid)) {
						saldo += b.getEbetrag
					} else if (b.getHabenKontoUid.equals(uid)) {
						saldo -= b.getEbetrag
					}
				}
			}
			var StringBuffer sb = new StringBuffer
			sb.append(Global::format("Datensätze: {0}  Summe: {1}", anz, Global::dblStr(summe)))
			if (!Global::nes(uid)) {
				sb.append("  Saldo: ").append(Global::dblStr(saldo))
			}
			buchungenStatus.setText(sb.toString)
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
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf_finalParam_) {

		var aufruf = aufruf_finalParam_
		var HhBuchungLang k = getValue(buchungen, !DialogAufrufEnum::NEU.equals(aufruf))
		if (DialogAufrufEnum::STORNO.equals(aufruf)) {
			if (Global::compString(letzterStorno, k.getUid) === 0) {
				aufruf = DialogAufrufEnum::LOESCHEN
			}
			letzterStorno = k.getUid
		}
		starteFormular(typeof(HH410BuchungController), aufruf, k)
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
	 * Event für Export.
	 */
	@FXML def void onExport() {

		var String pfad = Jhh6::getEinstellungen.getTempVerzeichnis
		var String datei = Global::getDateiname("Buchungliste", true, true, "csv")
		var List<String> zeilen = get(
			FactoryService::getHaushaltService.exportBuchungListe(getServiceDaten,
				Global::objBool(getText(kennzeichen)), von.getValue, bis.getValue, bText.getText, getText(konto),
				betrag.getText))
		Werkzeug::speicherDateiOeffnen(zeilen, pfad, datei, false)
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
	 * Event für Konto.
	 */
	@FXML def void onKonto() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(buchungen, 0)
	}
}

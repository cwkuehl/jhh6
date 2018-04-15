package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
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
	@FXML TableColumn<BuchungenData, String> colBeleg
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
		SimpleStringProperty beleg
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhBuchungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			valuta = new SimpleObjectProperty<LocalDate>(v.sollValuta)
			kz = new SimpleStringProperty(v.kz)
			betrag = new SimpleObjectProperty<Double>(v.ebetrag)
			text = new SimpleStringProperty(v.btext)
			soll = new SimpleStringProperty(v.sollName)
			haben = new SimpleStringProperty(v.habenName)
			beleg = new SimpleStringProperty(v.belegNr)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
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
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Titel des Dialogs.
	 */
	override protected String getTitel() {
		if (Global::nes(titel)) {
			return super.titel
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
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
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
			var d = LocalDate::now
			d = d.withDayOfMonth(d.lengthOfMonth)
			bis.setValue(d)
			von.setValue(d.minusMonths(13).withDayOfMonth(1))
			bText.setText("%%")
			betrag.setText(null)
			var kl = get(FactoryService::haushaltService.getKontoListe(serviceDaten, bis.value, von.value))
			konto.setItems(getItems(kl, new HhKonto, [a|new KontoData(a)], null))
			setText(konto, null)
			var v = parameter1 as LocalDate
			if (v !== null) {
				von.setValue(v)
			}
			var b = parameter2 as LocalDate
			if (b !== null) {
				bis.setValue(b)
			}
			val bi = parameter3 as HhBilanzSb
			if (bi !== null) {
				setText(konto, bi.kontoUid)
				titel = kl.stream.filter([a|a.uid.equals(bi.kontoUid)]).map([a|a.name]).findFirst.orElse(null)
			}
		}
		if (stufe <= 1) {
			var l = get(
				FactoryService::haushaltService.getBuchungListe(serviceDaten, Global::objBool(getText(kennzeichen)),
					von.value, bis.value, bText.text, getText(konto), betrag.text))
			getItems(l, null, [a|new BuchungenData(a)], buchungenData)
			var anz = Global::listLaenge(l)
			var summe = 0.0
			var saldo = 0.0
			var uid = getText(konto)
			if (l !== null) {
				for (HhBuchungLang b : l) {
					summe += b.ebetrag
					if (b.sollKontoUid.equals(uid)) {
						saldo += b.ebetrag
					} else if (b.habenKontoUid.equals(uid)) {
						saldo -= b.ebetrag
					}
				}
			}
			var sb = new StringBuffer
			sb.append(Global::format(Meldungen::HH054(anz, summe)))
			if (!Global::nes(uid)) {
				sb.append(Meldungen::HH055(saldo))
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
		colUid.setCellValueFactory([c|c.value.uid])
		colValuta.setCellValueFactory([c|c.value.valuta])
		colKz.setCellValueFactory([c|c.value.kz])
		colText.setCellValueFactory([c|c.value.text])
		colBetrag.setCellValueFactory([c|c.value.betrag])
		initColumnBetrag(colBetrag)
		colSoll.setCellValueFactory([c|c.value.soll])
		colHaben.setCellValueFactory([c|c.value.haben])
		colBeleg.setCellValueFactory([c|c.value.beleg])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum faufruf) {

		var aufruf = faufruf
		var HhBuchungLang k = getValue(buchungen, !DialogAufrufEnum::NEU.equals(aufruf))
		if (DialogAufrufEnum::STORNO.equals(aufruf)) {
			if (Global::compString(letzterStorno, k.uid) === 0) {
				aufruf = DialogAufrufEnum::LOESCHEN
			}
			letzterStorno = k.uid
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

		var pfad = Jhh6::einstellungen.tempVerzeichnis
		var datei = Global::getDateiname(Meldungen::HH056, true, true, "csv")
		var zeilen = get(
			FactoryService::haushaltService.exportBuchungListe(serviceDaten, Global::objBool(getText(kennzeichen)),
				von.value, bis.value, bText.text, getText(konto), betrag.text))
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

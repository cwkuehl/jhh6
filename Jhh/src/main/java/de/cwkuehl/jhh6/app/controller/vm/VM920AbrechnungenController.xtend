package de.cwkuehl.jhh6.app.controller.vm

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.VmAbrechnungLang
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
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
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog VM920Abrechnungen.
 */
class VM920AbrechnungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Label mieten0
	@FXML TableView<AbrechnungenData> abrechnungen
	@FXML TableColumn<AbrechnungenData, String> colUid
	@FXML TableColumn<AbrechnungenData, String> colHaus
	@FXML TableColumn<AbrechnungenData, String> colWohnung
	@FXML TableColumn<AbrechnungenData, String> colMieter
	@FXML TableColumn<AbrechnungenData, String> colSchluessel
	@FXML TableColumn<AbrechnungenData, String> colWert
	@FXML TableColumn<AbrechnungenData, Double> colBetrag
	@FXML TableColumn<AbrechnungenData, LocalDate> colVon
	@FXML TableColumn<AbrechnungenData, LocalDate> colBis
	@FXML TableColumn<AbrechnungenData, LocalDateTime> colGa
	@FXML TableColumn<AbrechnungenData, String> colGv
	@FXML TableColumn<AbrechnungenData, LocalDateTime> colAa
	@FXML TableColumn<AbrechnungenData, String> colAv
	ObservableList<AbrechnungenData> abrechnungenData = FXCollections::observableArrayList
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label haus0
	@FXML ComboBox<HausData> haus
	@FXML Label wohnung0
	@FXML ComboBox<WohnungData> wohnung
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	@FXML Label schluessel0
	@FXML ComboBox<SchluesselData> schluessel
	//@FXML Button alle

	/** 
	 * Daten für Tabelle Abrechnungen.
	 */
	static class AbrechnungenData extends TableViewData<VmAbrechnungLang> {

		SimpleStringProperty uid
		SimpleStringProperty haus
		SimpleStringProperty wohnung
		SimpleStringProperty mieter
		SimpleStringProperty schluessel
		SimpleStringProperty wert
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<LocalDate> von
		SimpleObjectProperty<LocalDate> bis
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(VmAbrechnungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			haus = new SimpleStringProperty(v.getHausBezeichnung)
			wohnung = new SimpleStringProperty(v.getWohnungBezeichnung)
			mieter = new SimpleStringProperty(v.getMieterName)
			schluessel = new SimpleStringProperty(v.getSchluessel)
			wert = new SimpleStringProperty(v.getWert)
			betrag = new SimpleObjectProperty<Double>(v.getBetrag)
			von = new SimpleObjectProperty<LocalDate>(v.getDatumVon)
			bis = new SimpleObjectProperty<LocalDate>(v.getDatumBis)
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
	 * Daten für ComboBox Schluessel.
	 */
	static class SchluesselData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		mieten0.setLabelFor(abrechnungen)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
		haus0.setLabelFor(haus, false)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		schluessel0.setLabelFor(schluessel, false, null, 30)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initDaten(0)
		abrechnungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<VmHaus> hl = get(FactoryService::getVermietungService.getHausListe(getServiceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var List<VmWohnungLang> wl = get(
				FactoryService::getVermietungService.getWohnungListe(getServiceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var List<VmMieterLang> ml = get(
				FactoryService::getVermietungService.getMieterListe(getServiceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			var List<MaEinstellung> sl = get(
				FactoryService::getVermietungService.getSchluesselListe(getServiceDaten))
			schluessel.setItems(getItems(sl, new MaEinstellung, [a|new SchluesselData(a)], null))
			von.setValue(LocalDate::now.withDayOfYear(1).minusYears(1))
			bis.setValue(von.getValue.plusYears(1).minusDays(1))
			setText(haus, null)
			setText(wohnung, null)
			setText(mieter, null)
		}
		if (stufe <= 1) {
			var List<VmAbrechnungLang> l = get(
				FactoryService::getVermietungService.getAbrechnungListe(getServiceDaten, von.getValue,
					bis.getValue, getText(haus), getText(wohnung), getText(mieter), getText(schluessel)))
			getItems(l, null, [a|new AbrechnungenData(a)], abrechnungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		abrechnungen.setItems(abrechnungenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colHaus.setCellValueFactory([c|c.getValue.haus])
		colWohnung.setCellValueFactory([c|c.getValue.wohnung])
		colMieter.setCellValueFactory([c|c.getValue.mieter])
		colSchluessel.setCellValueFactory([c|c.getValue.schluessel])
		colWert.setCellValueFactory([c|c.getValue.wert])
		colBetrag.setCellValueFactory([c|c.getValue.betrag])
		colVon.setCellValueFactory([c|c.getValue.von])
		colBis.setCellValueFactory([c|c.getValue.bis])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
		initColumnBetrag(colBetrag)
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var VmAbrechnungLang k = getValue(abrechnungen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(VM930AbrechnungController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(abrechnungen, 1)
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {

		var VmAbrechnungLang k = getValue(abrechnungen, true)
		var byte[] pdf = get(
			FactoryService::getVermietungService.getReportAbrechnung(getServiceDaten, von.getValue,
				bis.getValue, k.getHausUid, k.getMieterUid))
		Werkzeug::speicherReport(pdf, "Abrechnung", true)
	}

	/** 
	 * Event für Abrechnungen.
	 */
	@FXML def void onAbrechnungenMouseClick(MouseEvent e) {
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
	 * Event für Haus.
	 */
	@FXML def void onHaus() {
		onAktuell
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {
		onAktuell
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {
		onAktuell
	}

	/** 
	 * Event für Schluessel.
	 */
	@FXML def void onSchluessel() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(abrechnungen, 0)
	}
}

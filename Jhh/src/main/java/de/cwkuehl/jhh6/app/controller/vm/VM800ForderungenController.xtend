package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.HhBuchungVm
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
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
 * Controller für Dialog VM800Forderungen.
 */
class VM800ForderungenController extends BaseController<String> {

	@FXML Button tab
	@FXML Button aktuell
	@FXML Label forderungen0
	@FXML TableView<ForderungenData> forderungen
	@FXML TableColumn<ForderungenData, String> colMieter
	@FXML TableColumn<ForderungenData, String> colWohnung
	@FXML TableColumn<ForderungenData, String> colHaus
	@FXML TableColumn<ForderungenData, LocalDate> colValuta
	@FXML TableColumn<ForderungenData, Double> colSoll
	@FXML TableColumn<ForderungenData, Double> colIst
	ObservableList<ForderungenData> forderungenData = FXCollections::observableArrayList
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

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Forderungen.
	 */
	static class ForderungenData extends TableViewData<HhBuchungVm> {

		SimpleStringProperty mieter
		SimpleStringProperty wohnung
		SimpleStringProperty haus
		SimpleObjectProperty<LocalDate> valuta
		SimpleObjectProperty<Double> soll
		SimpleObjectProperty<Double> ist

		new(HhBuchungVm v) {

			super(v)
			mieter = new SimpleStringProperty(v.mieterName)
			wohnung = new SimpleStringProperty(v.wohnungBezeichnung)
			haus = new SimpleStringProperty(v.hausBezeichnung)
			valuta = new SimpleObjectProperty<LocalDate>(v.sollValuta)
			soll = new SimpleObjectProperty<Double>(v.betrag)
			ist = new SimpleObjectProperty<Double>(v.ebetrag)
		}

		override String getId() {
			return mieter.get
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
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
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
			return getData.uid
		}

		override String toString() {
			return getData.bezeichnung
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
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		forderungen0.setLabelFor(forderungen)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		haus0.setLabelFor(haus, false)
		wohnung0.setLabelFor(wohnung, false)
		mieter0.setLabelFor(mieter, false)
		initAccelerator("T", tab)
		initAccelerator("A", aktuell)
		initDaten(0)
		forderungen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var hl = get(FactoryService::vermietungService.getHausListe(serviceDaten, true))
			haus.setItems(getItems(hl, new VmHaus, [a|new HausData(a)], null))
			var wl = get(FactoryService::vermietungService.getWohnungListe(serviceDaten, true))
			wohnung.setItems(getItems(wl, new VmWohnungLang, [a|new WohnungData(a)], null))
			var ml = get(FactoryService::vermietungService.getMieterListe(serviceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, new VmMieterLang, [a|new MieterData(a)], null))
			von.setValue(LocalDate::now.withDayOfYear(1))
			bis.setValue(von.value.plusYears(1).minusDays(1))
			setText(haus, null)
			setText(wohnung, null)
			setText(mieter, null)
		}
		if (stufe <= 1) {
			var l = get(
				FactoryService::vermietungService.getForderungListe(serviceDaten, von.value, bis.value, getText(haus),
					getText(wohnung), getText(mieter)))
			getItems(l, null, [a|new ForderungenData(a)], forderungenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		forderungen.setItems(forderungenData)
		colMieter.setCellValueFactory([c|c.value.mieter])
		colWohnung.setCellValueFactory([c|c.value.wohnung])
		colHaus.setCellValueFactory([c|c.value.haus])
		colValuta.setCellValueFactory([c|c.value.valuta])
		colSoll.setCellValueFactory([c|c.value.soll])
		colIst.setCellValueFactory([c|c.value.ist])
		initColumnBetrag(colSoll)
		initColumnBetrag(colIst)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(forderungen, 1)
	}

	/** 
	 * Event für Forderungen.
	 */
	@FXML def void onForderungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) { // onAendern
		}
	}

	/** 
	 * Event für Haus.
	 */
	@FXML def void onHaus() {

		var VmHaus h = getValue(haus, false)
		var VmWohnungLang w = getValue(wohnung, false)
		if (h !== null && w !== null && Global::compString(h.uid, w.hausUid) !== 0) {
			setText(wohnung, null)
			setText(mieter, null)
		}
	}

	/** 
	 * Event für Wohnung.
	 */
	@FXML def void onWohnung() {

		var VmWohnungLang w = getValue(wohnung, false)
		if (w !== null && !Global::nes(w.uid)) {
			setText(haus, w.hausUid)
			var VmMieterLang m = getValue(mieter, false)
			if (m !== null && Global::compString(w.uid, m.wohnungUid) !== 0) {
				setText(mieter, null)
			}
		}
	}

	/** 
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {

		var VmMieterLang m = getValue(mieter, false)
		if (m !== null && !Global::nes(m.uid)) {
			setText(wohnung, m.wohnungUid)
			onWohnung
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(forderungen, 0)
	}
}

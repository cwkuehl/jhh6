package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.SoKurse
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.ChartPane
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import de.cwkuehl.jhh6.server.fop.dto.PnfChart
import java.time.LocalDate
import java.time.LocalDateTime
import javafx.beans.property.SimpleObjectProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.SplitPane
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent
import javafx.scene.layout.Pane

/** 
 * Controller für Dialog WP100Chart.
 */
class WP100ChartController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Label daten0
	// @FXML Label chart0
	@FXML SplitPane split
	@FXML TableView<DatenData> daten
	@FXML TableColumn<DatenData, LocalDateTime> colDatum
	@FXML TableColumn<DatenData, Double> colOpen
	@FXML TableColumn<DatenData, Double> colHigh
	@FXML TableColumn<DatenData, Double> colLow
	@FXML TableColumn<DatenData, Double> colClose
	ObservableList<DatenData> datenData = FXCollections::observableArrayList
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@FXML Label box0
	@FXML TextField box
	@FXML ComboBox<SkalaData> skala
	@FXML Label umkehr0
	@FXML TextField umkehr
	@FXML Label methode0
	@FXML ComboBox<MethodeData> methode
	@FXML CheckBox relativ
	@FXML Pane chartpane
	PnfChart chart
	String titel

	/** 
	 * Daten für Tabelle Daten.
	 */
	static class DatenData extends BaseController.TableViewData<SoKurse> {

		SimpleObjectProperty<LocalDateTime> datum
		SimpleObjectProperty<Double> open
		SimpleObjectProperty<Double> high
		SimpleObjectProperty<Double> low
		SimpleObjectProperty<Double> close

		new(SoKurse v) {
			super(v)
			datum = new SimpleObjectProperty<LocalDateTime>(v.datum)
			open = new SimpleObjectProperty<Double>(v.open)
			high = new SimpleObjectProperty<Double>(v.high)
			low = new SimpleObjectProperty<Double>(v.low)
			close = new SimpleObjectProperty<Double>(v.close)
		}

		override String getId() {
			return datum.get.toString
		}
	}

	/** 
	 * Daten für ComboBox Skala.
	 */
	static class SkalaData extends BaseController.ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.schluessel
		}

		override String toString() {
			return getData.wert
		}
	}

	/** 
	 * Daten für ComboBox Wertpapier.
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
	 * Daten für ComboBox Methode.
	 */
	static class MethodeData extends ComboBoxData<MaEinstellung> {

		new(MaEinstellung v) {
			super(v)
		}

		override String getId() {
			return getData.schluessel
		}

		override String toString() {
			return getData.wert
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		daten0.setLabelFor(split)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		wertpapier0.setLabelFor(wertpapier, true)
		box0.setLabelFor(box)
		umkehr0.setLabelFor(umkehr)
		methode0.setLabelFor(methode, true)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initDaten(0)
		daten.requestFocus
		split.setPrefWidth(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var wliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			wertpapier.setItems(getItems(wliste, null, [a|new WertpapierData(a)], null))
			var skliste = PnfChart::getSkalaListe
			skala.setItems(getItems(skliste, null, [a|new SkalaData(a)], null))
			var mliste = PnfChart::getMethodeListe
			methode.setItems(getItems(mliste, null, [a|new MethodeData(a)], null))
			var d = parameter1 as LocalDate
			var wp = parameter2 as WpWertpapierLang
			var k = parameter3 as WpKonfigurationLang
			if (d === null) {
				d = LocalDate::now
			}
			bis.setValue(d)
			if (wp === null) {
				if (Global::listLaenge(wliste) > 0) {
					setText(wertpapier, wliste.get(0).uid)
				}
			} else {
				titel = wp.getBezeichnung
				setText(wertpapier, wp.uid)
			}
			if (k === null) {
				von.setValue(d.minusDays(182))
				box.setText("1,0")
				setText(skala, "2") // dynamisch
				umkehr.setText("3")
				setText(methode, "1") // Schlusskurse
				relativ.setSelected(false)
			} else {
				von.setValue(d.minusDays(k.dauer))
				box.setText(Global::dblStr(k.box))
				setText(skala, Global::intStr(k.skala))
				umkehr.setText(Global::intStr(k.umkehr))
				setText(methode, Global::intStr(k.methode))
				relativ.setSelected(k.relativ)
			}
			ChartPane.initChart0(chartpane)
		}
		if (stufe <= 1) {
			var WpWertpapierLang wp = getValue(wertpapier, false)
			daten.items.clear
			chart = new PnfChart
			if (wp !== null) {
				var kliste = get(
					FactoryService::wertpapierService.holeKurse(serviceDaten, wp.uid, von.value, bis.value, wp.datenquelle,
						wp.kuerzel, wp.typ, wp.waehrung, if(relativ.isSelected) wp.relationUid else null))
				if (Global::listLaenge(kliste) > 0) {
					getItems(kliste, null, [a|new DatenData(a)], datenData)
					FXCollections::reverse(datenData)
				}
				chart.setMethode(Global::strInt(getText(methode)))
				// chart.setMethode(2); // High-Low-Trendfolge
				// chart.setMethode(3); // High-Low-Trendumkehr
				// chart.setMethode(4); // Open-High-Low-Close
				// chart.setMethode(5); // Typischer Preis
				chart.setBox(Global::strDbl(box.text))
				chart.setSkala(Global::strInt(getText(skala)))
				chart.setUmkehr(Global::strInt(umkehr.text))
				chart.setBezeichnung(wp.bezeichnung)
				chart.setRelativ(relativ.isSelected)
				chart.setZiel(wp.signalkurs1)
				chart.setStop(Global::strDbl(wp.stopkurs))
				chart.addKurse(kliste)
			}
			ChartPane.initChart1(chartpane, chart)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Dialog-Daten nach den Anzeigen initialisieren.
	 */
	override protected void initDaten2() {
		ChartPane.initChart1(chartpane, chart)
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		daten.setItems(datenData)
		colDatum.setCellValueFactory([c|c.value.datum])
		colOpen.setCellValueFactory([c|c.value.open])
		colHigh.setCellValueFactory([c|c.value.high])
		colLow.setCellValueFactory([c|c.value.low])
		colClose.setCellValueFactory([c|c.value.close])
		initColumnBetrag(colOpen)
		initColumnBetrag(colHigh)
		initColumnBetrag(colLow)
		initColumnBetrag(colClose)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(daten, 1)
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
	 * Event für Daten.
	 */
	@FXML def void onDatenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) { // onAendern
		}
	}
}

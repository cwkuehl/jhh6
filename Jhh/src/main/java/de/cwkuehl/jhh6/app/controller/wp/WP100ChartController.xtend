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
import java.util.List
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
	PnfChart chart = null
	String titel = null

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
			datum = new SimpleObjectProperty<LocalDateTime>(v.getDatum)
			open = new SimpleObjectProperty<Double>(v.getOpen)
			high = new SimpleObjectProperty<Double>(v.getHigh)
			low = new SimpleObjectProperty<Double>(v.getLow)
			close = new SimpleObjectProperty<Double>(v.getClose)
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
			return getData.getSchluessel
		}

		override String toString() {
			return getData.getWert
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
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
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
		daten0.setLabelFor(split)
		von0.setLabelFor(von.getLabelForNode)
		bis0.setLabelFor(bis.getLabelForNode)
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
			var List<WpWertpapierLang> wliste = get(
				FactoryService::getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null, null))
			wertpapier.setItems(getItems(wliste, null, [a|new WertpapierData(a)], null))
			var List<MaEinstellung> skliste = PnfChart::getSkalaListe
			skala.setItems(getItems(skliste, null, [a|new SkalaData(a)], null))
			var List<MaEinstellung> mliste = PnfChart::getMethodeListe
			methode.setItems(getItems(mliste, null, [a|new MethodeData(a)], null))
			var LocalDate d = getParameter1
			var WpWertpapierLang wp = getParameter2
			var WpKonfigurationLang k = getParameter3
			if (d === null) {
				d = LocalDate::now
			}
			bis.setValue(d)
			if (wp === null) {
				if (Global::listLaenge(wliste) > 0) {
					setText(wertpapier, wliste.get(0).getUid)
				}
			} else {
				titel = wp.getBezeichnung
				setText(wertpapier, wp.getUid)
			}
			if (k === null) {
				von.setValue(d.minusDays(182))
				box.setText("1,0")
				setText(skala, "2") // dynamisch
				umkehr.setText("3")
				setText(methode, "1") // Schlusskurse
				relativ.setSelected(false)
			} else {
				von.setValue(d.minusDays(k.getDauer))
				box.setText(Global::dblStr(k.getBox))
				setText(skala, Global::intStr(k.getSkala))
				umkehr.setText(Global::intStr(k.getUmkehr))
				setText(methode, Global::intStr(k.getMethode))
				relativ.setSelected(k.getRelativ)
			}
			ChartPane.initChart0(chartpane)
		}
		if (stufe <= 1) {
			var WpWertpapierLang wp = getValue(wertpapier, false)
			daten.getItems.clear
			chart = new PnfChart
			if (wp !== null) {
				var List<SoKurse> kliste = get(
					FactoryService::getWertpapierService.holeKurse(getServiceDaten, von.getValue, bis.getValue,
						wp.getKuerzel, if(relativ.isSelected) wp.getRelationKuerzel else null))
				if (Global::listLaenge(kliste) > 0) {
					getItems(kliste, null, [a|new DatenData(a)], datenData)
					FXCollections::reverse(datenData)
				}
				chart.setMethode(Global::strInt(getText(methode)))
				// chart.setMethode(2); // High-Low-Trendfolge
				// chart.setMethode(3); // High-Low-Trendumkehr
				// chart.setMethode(4); // Open-High-Low-Close
				// chart.setMethode(5); // Typischer Preis
				chart.setBox(Global::strDbl(box.getText))
				chart.setSkala(Global::strInt(getText(skala)))
				chart.setUmkehr(Global::strInt(umkehr.getText))
				chart.setBezeichnung(wp.getBezeichnung)
				chart.setRelativ(relativ.isSelected)
				chart.setZiel(wp.getSignalkurs1)
				chart.setStop(Global::strDbl(wp.getStopkurs))
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
		colDatum.setCellValueFactory([c|c.getValue.datum])
		colOpen.setCellValueFactory([c|c.getValue.open])
		colHigh.setCellValueFactory([c|c.getValue.high])
		colLow.setCellValueFactory([c|c.getValue.low])
		colClose.setCellValueFactory([c|c.getValue.close])
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

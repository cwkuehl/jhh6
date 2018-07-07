package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import javafx.fxml.FXML
import javafx.scene.chart.AreaChart
import javafx.scene.chart.CategoryAxis
import javafx.scene.chart.NumberAxis
import javafx.scene.chart.XYChart
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.layout.VBox

/** 
 * Controller für Dialog FZ100Statistik.
 */
class FZ100StatistikController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label bilanz0
	@FXML TextArea bilanz
	@FXML Label buecher0
	@FXML TextArea buecher
	@FXML Label fahrrad0
	@FXML TextArea fahrrad
	@FXML AreaChart<String, Number> chart
	@FXML AreaChart<String, Number> chart2
	@FXML VBox charts

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		if (charts !== null) {
			var xAxis = new CategoryAxis
			var yAxis = new NumberAxis
			chart = new AreaChart<String, Number>(xAxis, yAxis)
			charts.children.add(chart)
			xAxis = new CategoryAxis
			yAxis = new NumberAxis
			chart2 = new AreaChart<String, Number>(xAxis, yAxis)
			charts.children.add(chart2)
		}
		super.initialize
		datum0.setLabelFor(datum.labelForNode)
		bilanz0.setLabelFor(bilanz)
		buecher0.setLabelFor(buecher)
		fahrrad0.setLabelFor(fahrrad)
		initAccelerator("A", aktuell)
		initDaten(0)
		bilanz.requestFocus
	}

	def String axisDatum(LocalDateTime d) {
		//return if(d.monthValue == 1) (d.year % 100).toString else d.monthValue.toString
		return Meldungen.HH075(d)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			datum.setValue(LocalDate::now)
		}
		if (stufe <= 1) {
			var str = get(FactoryService::freizeitService.getStatistik(serviceDaten, 1, datum.value))
			bilanz.setText(str)
			str = get(FactoryService::freizeitService.getStatistik(serviceDaten, 2, datum.value))
			buecher.setText(str)
			str = get(FactoryService::freizeitService.getStatistik(serviceDaten, 3, datum.value))
			fahrrad.setText(str)

			var l = get(FactoryService::haushaltService.holeEkGvStaende(serviceDaten, datum.value))
			l.reverse
			val sek = new XYChart.Series
			sek.name = Meldungen.HH001 // Eigenkapital
			val sgv = new XYChart.Series
			sgv.name = Meldungen.HH002 // Gewinn/Verlust
			for (b : l) {
				sek.data.add(new XYChart.Data<String, Number>(axisDatum(b.geaendertAm), b.ebetrag))
				sgv.data.add(new XYChart.Data<String, Number>(axisDatum(b.geaendertAm), b.betrag))
			}
			chart.data.clear
			chart.data.addAll(sek)
			chart2.data.clear
			chart2.data.addAll(sgv)

		// var categorien = l.map[b|axisDatum(b.geaendertAm)]
		// var x = chart.XAxis as CategoryAxis
		// x.categorySpacing = 200
		// x.setCategories(FXCollections.observableArrayList(categorien))
		// x.setAutoRanging(false);
		// x.invalidateRange(Arrays.asList(categorien))
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		initDaten(1)
	}

	/** 
	 * Event für Datum.
	 */
	@FXML def void onDatum() {
		onAktuell
	}
}

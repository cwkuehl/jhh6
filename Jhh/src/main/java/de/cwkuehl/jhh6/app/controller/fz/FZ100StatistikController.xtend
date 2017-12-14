package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDate
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea

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

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		datum0.setLabelFor(datum.getLabelForNode)
		bilanz0.setLabelFor(bilanz)
		buecher0.setLabelFor(buecher)
		fahrrad0.setLabelFor(fahrrad)
		initAccelerator("A", aktuell)
		initDaten(0)
		bilanz.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			datum.setValue(LocalDate.now)
		}
		if (stufe <= 1) {
			var String str = get(
				FactoryService.getFreizeitService.getStatistik(getServiceDaten, 1, datum.getValue))
			bilanz.setText(str)
			str = get(FactoryService.getFreizeitService.getStatistik(getServiceDaten, 2, datum.getValue))
			buecher.setText(str)
			str = get(FactoryService.getFreizeitService.getStatistik(getServiceDaten, 3, datum.getValue))
			fahrrad.setText(str)
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

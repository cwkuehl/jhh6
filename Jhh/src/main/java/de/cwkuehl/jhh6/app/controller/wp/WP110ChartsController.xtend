package de.cwkuehl.jhh6.app.controller.wp

import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.app.control.ChartPane
import de.cwkuehl.jhh6.server.FactoryService
import de.cwkuehl.jhh6.server.fop.dto.PnfChart
import java.time.LocalDate
import java.util.ArrayList
import java.util.List
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.SplitPane
import javafx.scene.layout.Pane

/** 
 * Controller für Dialog WP110Charts.
 */
class WP110ChartsController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button einstellung
	// @FXML Label chart0
	@FXML SplitPane split
	// @FXML SplitPane split2
	@FXML Pane chartpane1
	PnfChart chart1 = null
	@FXML Pane chartpane2
	PnfChart chart2 = null
	@FXML Pane chartpane3
	PnfChart chart3 = null
	List<WpWertpapierLang> wliste = null
	List<WpKonfigurationLang> kliste = null
	@Profil(defaultValue="") String wp1Uid = null
	@Profil(defaultValue="") String wp2Uid = null
	@Profil(defaultValue="") String wp3Uid = null
	@Profil(defaultValue="") String k1Uid = null
	@Profil(defaultValue="") String k2Uid = null
	@Profil(defaultValue="") String k3Uid = null
	WpWertpapierLang wp1 = null
	WpKonfigurationLang k1 = null
	WpWertpapierLang wp2 = null
	WpKonfigurationLang k2 = null
	WpWertpapierLang wp3 = null
	WpKonfigurationLang k3 = null

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("I", einstellung)
		initDaten(0)
		split.requestFocus
		split.setPrefWidth(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			wliste = get(FactoryService::wertpapierService.getWertpapierListe(serviceDaten, true, null, null, null))
			kliste = get(FactoryService::wertpapierService.getKonfigurationListe(serviceDaten, false, null))
			wp1 = wliste.stream.filter([a|a.uid.equals(wp1Uid)]).findFirst.orElse(null)
			wp2 = wliste.stream.filter([a|a.uid.equals(wp2Uid)]).findFirst.orElse(null)
			wp3 = wliste.stream.filter([a|a.uid.equals(wp3Uid)]).findFirst.orElse(null)
			k1 = kliste.stream.filter([a|a.uid.equals(k1Uid)]).findFirst.orElse(null)
			k2 = kliste.stream.filter([a|a.uid.equals(k2Uid)]).findFirst.orElse(null)
			k3 = kliste.stream.filter([a|a.uid.equals(k3Uid)]).findFirst.orElse(null)
			if (wp1 === null) {
				wp1 = new WpWertpapierLang
				wp1.setBezeichnung("DAX")
				wp1.setKuerzel("^GDAXI")
			}
			if (k1 === null) {
				k1 = new WpKonfigurationLang
				k1.setBox(1)
				k1.setProzentual(true)
				k1.setUmkehr(3)
				k1.setMethode(4)
				// Open-High-Low-Close
				k1.setDauer(182)
				// 6 Monate
				k1.setRelativ(false)
			}
			if (wp2 === null) {
				wp2 = wp1.clone
				wp2.setUid(null)
			}
			if (k2 === null) {
				k2 = k1.clone
				k2.setUid(null)
				k2.setBox(k1.box / 2)
			}
			if (wp3 === null) {
				wp3 = wp1.clone
				wp3.setUid(null)
			}
			if (k3 === null) {
				k3 = k2.clone
				k3.setUid(null)
				k3.setBox(k2.box * 4)
			}
			// if (merken) {
			// daten.setWp1Uid(wp1.uid)
			// daten.setWp2Uid(wp2.uid)
			// daten.setWp3Uid(wp3.uid)
			// daten.setK1Uid(k1.uid)
			// daten.setK2Uid(k2.uid)
			// daten.setK3Uid(k3.uid)
			// }
			ChartPane.initChart0(chartpane1)
			ChartPane.initChart0(chartpane2)
			ChartPane.initChart0(chartpane3)
		}
		if (stufe <= 1) {
			var bis = LocalDate::now
			var von = bis.minusDays(k1.dauer)
			var liste = get(
				FactoryService::wertpapierService.holeKurse(serviceDaten, von, bis, wp1.kuerzel,
					if(k1.relativ) wp1.relationKuerzel else null))
			if (liste !== null && liste.size > 0) {
				chart1 = new PnfChart
				chart1.setBox(k1.box)
				chart1.setSkala(k1.skala)
				chart1.setUmkehr(k1.umkehr)
				chart1.setBezeichnung(wp1.bezeichnung)
				chart1.setMethode(k1.methode)
				chart1.setRelativ(k1.relativ)
				chart1.setZiel(wp1.signalkurs1)
				chart1.setStop(Global.strDbl(wp1.stopkurs))
				chart1.addKurse(liste)
			}
			if (k2.dauer !== k1.dauer || !wp2.kuerzel.equals(wp1.kuerzel)) {
				von = bis.minusDays(k2.dauer)
				liste = get(
					FactoryService::wertpapierService.holeKurse(serviceDaten, von, bis, wp2.kuerzel,
						if(k2.relativ) wp2.relationKuerzel else null))
			}
			if (liste !== null && liste.size > 0) {
				chart2 = new PnfChart
				chart2.setBox(k2.box)
				chart2.setSkala(k2.skala)
				chart2.setUmkehr(k2.umkehr)
				chart2.setBezeichnung(wp2.bezeichnung)
				chart2.setMethode(k2.methode)
				chart2.setRelativ(k2.relativ)
				chart2.setZiel(wp2.signalkurs1)
				chart2.setStop(Global.strDbl(wp2.stopkurs))
				chart2.addKurse(liste)
			}
			if (k3.dauer !== k2.dauer || !wp3.kuerzel.equals(wp2.kuerzel)) {
				von = bis.minusDays(k3.dauer)
				liste = get(
					FactoryService::wertpapierService.holeKurse(serviceDaten, von, bis, wp3.kuerzel,
						if(k3.relativ) wp3.relationKuerzel else null))
			}
			if (liste !== null && liste.size > 0) {
				chart3 = new PnfChart
				chart3.setBox(k3.box)
				chart3.setSkala(k3.skala)
				chart3.setUmkehr(k3.umkehr)
				chart3.setBezeichnung(wp3.bezeichnung)
				chart3.setMethode(k3.methode)
				chart3.setRelativ(k3.relativ)
				chart3.setZiel(wp3.signalkurs1)
				chart3.setStop(Global.strDbl(wp3.stopkurs))
				chart3.addKurse(liste)
			}
			ChartPane.initChart1(chartpane1, chart1)
			ChartPane.initChart1(chartpane2, chart2)
			ChartPane.initChart1(chartpane3, chart3)
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Dialog-Daten nach den Anzeigen initialisieren.
	 */
	override protected void initDaten2() {
		ChartPane.initChart1(chartpane1, chart1)
		ChartPane.initChart1(chartpane2, chart2)
		ChartPane.initChart1(chartpane3, chart3)
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
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6.rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6.redo)
		onAktuell
	}

	/** 
	 * Event für Einstellung.
	 */
	@FXML def void onEinstellung() {

		var uids = new ArrayList<String>
		uids.add(wp1Uid)
		uids.add(k1Uid)
		uids.add(wp2Uid)
		uids.add(k2Uid)
		uids.add(wp3Uid)
		uids.add(k3Uid)
		uids = starteDialog(WP120ChartsEinstellungenController, DialogAufrufEnum::OHNE, uids)
		if (Global.listLaenge(uids) >= 6) {
			wp1Uid = uids.get(0)
			k1Uid = uids.get(1)
			wp2Uid = uids.get(2)
			k2Uid = uids.get(3)
			wp3Uid = uids.get(4)
			k3Uid = uids.get(5)
			wp1 = wp2 = wp3 = null
			k1 = k2 = k3 = null
			initDaten(0)
		}
	}
}

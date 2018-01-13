package de.cwkuehl.jhh6.app.controller.tb

import java.time.LocalDate
import de.cwkuehl.jhh6.api.dto.TbEintrag
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog TB100Tagebuch.
 */
class TB100TagebuchController extends BaseController<String> {

	@FXML Button kopieren
	@FXML Button einfuegen
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button export
	@FXML Label zurueck10
	@FXML TextArea zurueck1
	@FXML Label zurueck20
	@FXML TextArea zurueck2
	@FXML Label zurueck30
	@FXML TextArea zurueck3
	@FXML Label datum0
	@FXML Datum datum
	@FXML Label eintrag0
	@FXML TextArea eintrag
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Label suche00
	// @FXML Label suche10
	@FXML TextField suche1
	// @FXML Label suche20
	@FXML TextField suche2
	// @FXML Label suche30
	@FXML TextField suche3
	// @FXML Label suche40
	// @FXML Label suche50
	@FXML TextField suche4
	// @FXML Label suche60
	@FXML TextField suche5
	// @FXML Label suche70
	@FXML TextField suche6
	// @FXML Label suche80
	// @FXML Label suche90
	@FXML TextField suche7
	// @FXML Label suche100
	@FXML TextField suche8
	// @FXML Label suche110
	@FXML TextField suche9
	// @FXML Label suche120
	// @FXML Button anfang
	// @FXML Button zurueck
	// @FXML Button vor
	// @FXML Button ende
	// @FXML Button leeren
	@FXML Label vor10
	@FXML TextArea vor1
	@FXML Label vor20
	@FXML TextArea vor2
	@FXML Label vor30
	@FXML TextArea vor3
	String kopie

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		initAccelerator("C", kopieren)
		initAccelerator("V", einfuegen)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("X", export)
		zurueck10.setLabelFor(zurueck1)
		zurueck20.setLabelFor(zurueck2)
		zurueck30.setLabelFor(zurueck3)
		datum0.setLabelFor(datum.getLabelForNode)
		eintrag0.setLabelFor(eintrag)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		suche00.setLabelFor(suche1)
		vor10.setLabelFor(vor1)
		vor20.setLabelFor(vor2)
		vor30.setLabelFor(vor3)
		initDaten(0)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			leerenSuche
			eintragAlt.setDatum(LocalDate.now)
			datum.setValue(eintragAlt.getDatum)
			bearbeiteEintraege(false, true)
			onEnde
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		kopie = eintrag.getText
	}

	/** 
	 * Event für Einfuegen.
	 */
	@FXML def void onEinfuegen() {
		eintrag.setText(kopie)
		bearbeiteEintraege(true, false)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6.rollback)
		bearbeiteEintraege(false, true)
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6.redo)
		bearbeiteEintraege(false, true)
	}

	/** 
	 * Event für Export.
	 */
	@FXML def void onExport() {

		// Bericht erzeugen
		bearbeiteEintraege(true, false)
		var String pfad = Jhh6.getEinstellungen.getTempVerzeichnis
		var String datei = Global.getDateiname("Tagebuch", true, true, "txt")
		Werkzeug.speicherDateiOeffnen(get(FactoryService.getTagebuchService.holeDatei(getServiceDaten, getSuche)),
			pfad, datei, false)
	}

	/** 
	 * Event für Anfang.
	 */
	@FXML def void onAnfang() {
		sucheEintraege(Constant.TB_ANFANG)
	}

	/** 
	 * Event für Zurueck.
	 */
	@FXML def void onZurueck() {
		sucheEintraege(Constant.TB_ZURUECK)
	}

	/** 
	 * Event für Vor.
	 */
	@FXML def void onVor() {
		sucheEintraege(Constant.TB_VOR)
	}

	/** 
	 * Event für Ende.
	 */
	@FXML def void onEnde() {
		sucheEintraege(Constant.TB_ENDE)
	}

	/** 
	 * Event für Leeren.
	 */
	@FXML def void onLeeren() {
		leerenSuche
		bearbeiteEintraege(true, false)
	}

	@FXML def void onDatumChanged() {
		bearbeiteEintraege(true, true)
	}

	def private void leerenSuche() {

		suche1.setText("%%")
		suche2.setText("%%")
		suche3.setText("%%")
		suche4.setText("%%")
		suche5.setText("%%")
		suche6.setText("%%")
		suche7.setText("%%")
		suche8.setText("%%")
		suche9.setText("%%")
	}

	/** 
	 * Merker, ob Eintrag gelesen wurde. 
	 */
	boolean geladen = false
	/** 
	 * alten Eintrag von vorher merken. 
	 */
	TbEintrag eintragAlt = new TbEintrag

	/** 
	 * Lesen der Einträge ausgehend vom übergebenen Datum.
	 * @param d Datum.
	 */
	def private void ladeEintraege(LocalDate d) {

		var ServiceDaten daten = getServiceDaten
		var TbEintrag tb = null
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.minusDays(1)))
		zurueck1.setText(if(tb === null) null else tb.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.minusMonths(1)))
		zurueck2.setText(if(tb === null) null else tb.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.minusYears(1)))
		zurueck3.setText(if(tb === null) null else tb.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d))
		if (tb === null) {
			eintragAlt.setEintrag(null)
			angelegt.setText(null)
			geaendert.setText(null)
		} else {
			eintragAlt.setEintrag(tb.getEintrag)
			angelegt.setText(tb.formatDatumVon(tb.getAngelegtAm, tb.getAngelegtVon))
			geaendert.setText(tb.formatDatumVon(tb.getGeaendertAm, tb.getGeaendertVon))
		}
		eintragAlt.setDatum(d)
		eintrag.setText(eintragAlt.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.plusDays(1)))
		vor1.setText(if(tb === null) null else tb.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.plusMonths(1)))
		vor2.setText(if(tb === null) null else tb.getEintrag)
		tb = get(FactoryService.getTagebuchService.getEintrag(daten, d.plusYears(1)))
		vor3.setText(if(tb === null) null else tb.getEintrag)
	}

	/** 
	 * Lesen der Einträge ausgehend vom aktuellen Datum. Evtl. wird vorher der aktuelle Eintrag gespeichert.
	 * @param speichern True, wenn vorher gespeichert werden soll.
	 * @param laden True, wenn Einträge geladen werden sollen.
	 */
	def private void bearbeiteEintraege(boolean speichern, boolean laden) {

		var ServiceDaten daten = getServiceDaten
		// Rekursion vermeiden
		if (speichern && geladen) {
			// alten Eintrag von vorher merken
			var String str = eintragAlt.getEintrag
			// nur speichern, wenn etwas geändert ist.
			if (str === null || Global.compString(str, eintrag.getText) !== 0) {
				get(
					FactoryService.getTagebuchService.speichereEintrag(daten, eintragAlt.getDatum,
						eintrag.getText))
				}
			}
			if (laden) {
				var LocalDate d = datum.getValue
				ladeEintraege(d)
				geladen = true
			}
		}

		def private String[] getSuche() {
			var String[] suche = #[suche1.getText, suche2.getText, suche3.getText, suche4.getText,
				suche5.getText, suche6.getText, suche7.getText, suche8.getText, suche9.getText]
			return suche
		}

		/** 
		 * Suche des nächsten passenden Eintrags in der Suchrichtung.
		 * @param stelle Such-Richtung.
		 */
		def private void sucheEintraege(int stelle) {
			bearbeiteEintraege(true, false)
			var ServiceDaten daten = getServiceDaten
			var LocalDate d = get(
				FactoryService.getTagebuchService.holeSucheDatum(daten, stelle, datum.getValue, getSuche))
			if (d !== null) {
				datum.setValue(d)
				bearbeiteEintraege(false, true)
			}
		}
	}
	
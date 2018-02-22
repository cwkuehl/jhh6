package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
import java.util.List
import javafx.application.Platform
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog SB200Ahnen.
 */
class SB200AhnenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button drucken
	@FXML Button imExport
	@FXML Label ahnen0
	@FXML TableView<AhnenData> ahnen
	@FXML TableColumn<AhnenData, String> colUid
	@FXML TableColumn<AhnenData, String> colGeburtsname
	@FXML TableColumn<AhnenData, String> colVorname
	@FXML TableColumn<AhnenData, String> colName
	@FXML TableColumn<AhnenData, String> colGeschlecht
	@FXML TableColumn<AhnenData, String> colGeburt
	@FXML TableColumn<AhnenData, String> colTod
	@FXML TableColumn<AhnenData, LocalDateTime> colGa
	@FXML TableColumn<AhnenData, String> colGv
	@FXML TableColumn<AhnenData, LocalDateTime> colAa
	@FXML TableColumn<AhnenData, String> colAv
	ObservableList<AhnenData> ahnenData = FXCollections::observableArrayList
	@FXML Label ahnenStatus
	@FXML Label name0
	@FXML TextField name
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML CheckBox filtern

	// @FXML Button alle
	// @FXML Label springen0
	// @FXML Button spName
	// @FXML Button spVater
	// @FXML Button spMutter
	// @FXML Button spKind
	// @FXML Button spEhegatte
	// @FXML Button spGeschwister
	// @FXML Button spFamilie
	// @FXML Button spFamilienKind
	/** 
	 * Daten für Tabelle Ahnen.
	 */
	static class AhnenData extends TableViewData<SbPersonLang> {

		SimpleStringProperty uid
		SimpleStringProperty geburtsname
		SimpleStringProperty vorname
		SimpleStringProperty name
		SimpleStringProperty geschlecht
		SimpleStringProperty geburt
		SimpleStringProperty tod
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(SbPersonLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			geburtsname = new SimpleStringProperty(v.getGeburtsname)
			vorname = new SimpleStringProperty(v.getVorname)
			name = new SimpleStringProperty(v.getName)
			geschlecht = new SimpleStringProperty(v.getGeschlecht)
			geburt = new SimpleStringProperty(v.getGeburtsdatum)
			tod = new SimpleStringProperty(v.getTodesdatum)
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
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		ahnen0.setLabelFor(ahnen)
		name0.setLabelFor(name)
		vorname0.setLabelFor(vorname)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initAccelerator("D", drucken)
		initAccelerator("X", imExport)
		initDaten(0)
		ahnen.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			name.setText("%%")
			vorname.setText("%%")
		}
		if (stufe <= 1) {
			var List<SbPersonLang> l = get(
				FactoryService::getStammbaumService.getPersonListe(getServiceDaten, false, true,
					if(filtern.isSelected) name.text else null, if(filtern.isSelected) vorname.text else null, null))
			getItems(l, null, [a|new AhnenData(a)], ahnenData)
			var int anz = Global::listLaenge(l)
			var int anzg = 0
			if (l !== null) {
				for (SbPersonLang b : l) {
					if (Global::nes(b.geburtsdatum)) {
						anzg++
					}
				}
			}
			ahnenStatus.setText(Meldungen.SB028(anz, anzg))
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		ahnen.setItems(ahnenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colGeburtsname.setCellValueFactory([c|c.getValue.geburtsname])
		colVorname.setCellValueFactory([c|c.getValue.vorname])
		colName.setCellValueFactory([c|c.getValue.name])
		colGeschlecht.setCellValueFactory([c|c.getValue.geschlecht])
		colGeburt.setCellValueFactory([c|c.getValue.geburt])
		colTod.setCellValueFactory([c|c.getValue.tod])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var SbPersonLang k = getValue(ahnen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(SB210AhnController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(ahnen, 1)
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
		starteFormular(typeof(SB220DruckenController), DialogAufrufEnum::OHNE)
	}

	/** 
	 * Event für ImExport.
	 */
	@FXML def void onImExport() {
		starteFormular(typeof(SB500GedcomController), DialogAufrufEnum::OHNE)
	}

	/** 
	 * Event für Ahnen.
	 */
	@FXML def void onAhnenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(ahnen, 0)
	}

	/** 
	 * Event für SpName.
	 */
	@FXML def void onSpName() {
		var SbPersonLang k = getValue(ahnen, false)
		var String r = get(
			FactoryService::stammbaumService.getNaechstenNamen(serviceDaten, if(k === null) null else k.uid, name.text,
				vorname.text))
		setText(ahnen, r)
	}

	/** 
	 * Event für SpVater.
	 */
	@FXML def void onSpVater() {
		var SbPersonLang k = getValue(ahnen, true)
		setText(ahnen, k.getVaterUid)
	}

	/** 
	 * Event für SpMutter.
	 */
	@FXML def void onSpMutter() {
		var SbPersonLang k = getValue(ahnen, true)
		setText(ahnen, k.getMutterUid)
	}

	/** 
	 * Event für SpKind.
	 */
	@FXML def void onSpKind() {
		var SbPersonLang k = getValue(ahnen, true)
		var String r = get(FactoryService::stammbaumService.getErstesKind(serviceDaten, k.uid))
		setText(ahnen, r)
	}

	/** 
	 * Event für SpEhegatte.
	 */
	@FXML def void onSpEhegatte() {
		var SbPersonLang k = getValue(ahnen, true)
		var String r = get(FactoryService::stammbaumService.getNaechstenEhegatten(serviceDaten, k.uid))
		setText(ahnen, r)
	}

	/** 
	 * Event für SpGeschwister.
	 */
	@FXML def void onSpGeschwister() {
		var SbPersonLang k = getValue(ahnen, true)
		var r = get(FactoryService::stammbaumService.getNaechstenGeschwister(serviceDaten, k.uid))
		setText(ahnen, r)
	}

	/** 
	 * Event für SpFamilie.
	 */
	@FXML def void onSpFamilie() {

		val SbPersonLang k = getValue(ahnen, true)
		val c = (fokusFormular(typeof(SB300FamilienController), DialogAufrufEnum::OHNE) as SB300FamilienController)
		if (c !== null) {
			Platform::runLater([c.onSpElternFamilie(k)])
		}
	}

	/** 
	 * Event für SpFamilienKind.
	 */
	@FXML def void onSpFamilienKind() {

		val SbPersonLang k = getValue(ahnen, true)
		val c = (fokusFormular(typeof(SB300FamilienController), DialogAufrufEnum::OHNE) as SB300FamilienController)
		if (c !== null) {
			Platform::runLater([c.onSpFamilienKind(k)])
		}
	}

	/** 
	 * Event für SpVater.
	 */
	def void onSpFamilieVater(String uid) {
		setText(ahnen, uid)
	}

	/** 
	 * Event für SpMutter.
	 */
	def void onSpFamilieMutter(String uid) {
		setText(ahnen, uid)
	}

	/** 
	 * Event für SpKind.
	 */
	def void onSpFamilieKind(String uid) {
		if (!Global::nes(uid)) {
			var String r = get(FactoryService::stammbaumService.getErstesFamilienKind(serviceDaten, uid))
			setText(ahnen, r)
		}
	}

	/** 
	 * Event für Filtern.
	 */
	@FXML def void onFiltern() {
		onAktuell
	}
}

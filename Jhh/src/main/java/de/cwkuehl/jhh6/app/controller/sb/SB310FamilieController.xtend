package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.SbFamilieLang
import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.enums.GedcomEreignis
import de.cwkuehl.jhh6.api.enums.GeschlechtEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
import java.util.List
import java.util.stream.Collectors
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
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog SB310Familie.
 */
class SB310FamilieController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label vater0
	@FXML ComboBox<VaterData> vater
	@FXML Label mutter0
	@FXML ComboBox<MutterData> mutter
	@FXML Label heiratsdatum0
	@FXML TextField heiratsdatum
	@FXML Label heiratsort0
	@FXML TextField heiratsort
	@FXML Label heiratsbem0
	@FXML TextArea heiratsbem
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Label kinder0
	@FXML TableView<KinderData> kinder
	@FXML TableColumn<KinderData, String> colUid
	@FXML TableColumn<KinderData, String> colGeburtsname
	@FXML TableColumn<KinderData, String> colVorname
	@FXML TableColumn<KinderData, String> colName
	@FXML TableColumn<KinderData, String> colGeschlecht
	@FXML TableColumn<KinderData, LocalDateTime> colGa
	@FXML TableColumn<KinderData, String> colGv
	@FXML TableColumn<KinderData, LocalDateTime> colAa
	@FXML TableColumn<KinderData, String> colAv
	ObservableList<KinderData> kinderData = FXCollections::observableArrayList
	@FXML Label kind0
	@FXML ComboBox<KindData> kind
	@FXML Button ok
	@FXML Button hinzufuegen
	@FXML Button entfernen
	//@FXML Button abbrechen

	/** 
	 * Daten für ComboBox Vater.
	 */
	static class VaterData extends ComboBoxData<SbPersonLang> {

		new(SbPersonLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getGeburtsname
		}
	}

	/** 
	 * Daten für ComboBox Mutter.
	 */
	static class MutterData extends ComboBoxData<SbPersonLang> {

		new(SbPersonLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getGeburtsname
		}
	}

	/** 
	 * Daten für Tabelle Kinder.
	 */
	static class KinderData extends TableViewData<SbPersonLang> {

		SimpleStringProperty uid
		SimpleStringProperty geburtsname
		SimpleStringProperty vorname
		SimpleStringProperty name
		SimpleStringProperty geschlecht
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
	 * Daten für ComboBox Kind.
	 */
	static class KindData extends ComboBoxData<SbPersonLang> {

		new(SbPersonLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getGeburtsname
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		vater0.setLabelFor(vater, false)
		mutter0.setLabelFor(mutter, false)
		heiratsdatum0.setLabelFor(heiratsdatum)
		heiratsort0.setLabelFor(heiratsort)
		heiratsbem0.setLabelFor(heiratsbem)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		kinder0.setLabelFor(kinder)
		kind0.setLabelFor(kind, false)
		initDaten(0)
		vater.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<SbPersonLang> l = get(
				FactoryService::getStammbaumService.getPersonListe(getServiceDaten, true, false, null, null, null))
			vater.setItems(
				getItems(
					l.stream.filter([a|!a.getGeschlecht.equals(GeschlechtEnum::WEIBLICH.toString)]).collect(
						Collectors::toList), new SbPersonLang, [a|new VaterData(a)], null))
			mutter.setItems(getItems(l.stream.filter([a |
				!a.getGeschlecht.equals(GeschlechtEnum::MAENNLICH.toString)
			]).collect(Collectors::toList), new SbPersonLang, [a|new MutterData(a)], null))
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var SbFamilieLang k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::getStammbaumService.getFamilieLang(getServiceDaten, k.getUid))
				if (k !== null) {
					nr.setText(k.getUid)
					setText(vater, k.getMannUid)
					setText(mutter, k.getFrauUid)
					angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
					geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
					var List<String> liste = get(
						FactoryService::getStammbaumService.getFamilieEreignis(getServiceDaten, k.getUid,
							GedcomEreignis::eHEIRAT.wert))
					if (Global::listLaenge(liste) >= 3) {
						heiratsdatum.setText(liste.get(0))
						heiratsort.setText(liste.get(1))
						heiratsbem.setText(liste.get(2))
					}
					var List<SbPersonLang> kliste = get(
						FactoryService::getStammbaumService.getKindListe(getServiceDaten, k.getUid))
					getItems(kliste, null, [a|new KinderData(a)], kinderData)
				}
			}
			nr.setEditable(false)
			setEditable(vater, !loeschen)
			setEditable(mutter, !loeschen)
			heiratsdatum.setEditable(!loeschen)
			heiratsdatum.setEditable(!loeschen)
			heiratsbem.setEditable(!loeschen)
			setEditable(kind, !loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			hinzufuegen.setVisible(!loeschen)
			entfernen.setVisible(!loeschen)
			val v = getText(vater)
			val m = getText(mutter)
			kind.setItems(getItems(l.stream.filter([a |
				!a.getUid.equals(v) && !a.getUid.equals(m) && a.getVaterUid === null && a.getMutterUid === null
			]).collect(Collectors::toList), new SbPersonLang, [a|new KindData(a)], null))
		}
		if (stufe <= 1) { // stufe = 1
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		kinder.setItems(kinderData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colGeburtsname.setCellValueFactory([c|c.getValue.geburtsname])
		colVorname.setCellValueFactory([c|c.getValue.vorname])
		colName.setCellValueFactory([c|c.getValue.name])
		colGeschlecht.setCellValueFactory([c|c.getValue.geschlecht])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	/** 
	 * Event für Kinder.
	 * @FXML
	 */
	def void onKinderMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {		// onAendern
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var List<String> kliste = kinderData.stream.map([a|a.uid.getValue]).collect(Collectors::toList)
		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getStammbaumService.insertUpdateFamilie(getServiceDaten, null, getText(vater),
				getText(mutter), heiratsdatum.getText, heiratsort.getText, heiratsbem.getText, null, kliste)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getStammbaumService.insertUpdateFamilie(getServiceDaten, nr.getText,
				getText(vater), getText(mutter), heiratsdatum.getText, heiratsort.getText, heiratsbem.getText,
				null, kliste)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getStammbaumService.deleteFamilie(getServiceDaten, nr.getText)
		}
		if (r !== null) {
			get(r)
			if (r.getFehler.isEmpty) {
				updateParent
				close
			}
		}
	}

	/** 
	 * Event für Hinzufuegen.
	 */
	@FXML def void onHinzufuegen() {

		val kuid = getText(kind)
		if (Global::nes(kuid) || kinderData.stream.anyMatch([a|Global::compString(a.uid.getValue, kuid) === 0])) {
			return;
		}
		var SbPersonLang k = get(FactoryService::getStammbaumService.getPersonLang(getServiceDaten, kuid))
		if (k !== null) {
			kinderData.add(new KinderData(k))
		}
	}

	/** 
	 * Event für Entfernen.
	 */
	@FXML def void onEntfernen() {

		var SbPersonLang k = getValue(kinder, true)
		val kuid = k.getUid
		var kd = kinderData.stream.filter([a|Global::compString(a.uid.getValue, kuid) === 0]).
			findFirst.orElse(null)
		if (kd !== null) {
			kinderData.remove(kd)
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

package de.cwkuehl.jhh6.app.controller.mo

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import java.util.Optional
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MoEinteilungLang
import de.cwkuehl.jhh6.api.dto.MoGottesdienst
import de.cwkuehl.jhh6.api.dto.MoProfil
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
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
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog MO210Gottesdienst.
 */
class MO210GottesdienstController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label von0
	@FXML Datum von
	@FXML Label name0
	@FXML ComboBox<NameData> name
	@FXML Label ort0
	@FXML ComboBox<OrtData> ort
	@FXML Label profil0
	@FXML ComboBox<ProfilData> profil
	@FXML Label status0
	@FXML ComboBox<StatusData> status
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label einteilungen0
	@FXML TableView<EinteilungenData> einteilungen
	@FXML TableColumn<EinteilungenData, String> colUid
	@FXML TableColumn<EinteilungenData, String> colDienst
	@FXML TableColumn<EinteilungenData, String> colVorname
	@FXML TableColumn<EinteilungenData, String> colName
	@FXML TableColumn<EinteilungenData, LocalDateTime> colGa
	@FXML TableColumn<EinteilungenData, String> colGv
	@FXML TableColumn<EinteilungenData, LocalDateTime> colAa
	@FXML TableColumn<EinteilungenData, String> colAv
	ObservableList<EinteilungenData> einteilungenData = null
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button neu
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Button alleLoeschen
	//@FXML Button abbrechen

	/** 
	 * Daten für ComboBox Name.
	 */
	static class NameData extends BaseController.ComboBoxData<MaEinstellung> {

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
	 * Daten für ComboBox Ort.
	 */
	static class OrtData extends ComboBoxData<MaEinstellung> {

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
	 * Daten für ComboBox Profil.
	 */
	static class ProfilData extends ComboBoxData<MoProfil> {

		new(MoProfil v) {
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
	 * Daten für ComboBox Status.
	 */
	static class StatusData extends ComboBoxData<MaEinstellung> {

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
	 * Daten für Tabelle Einteilungen.
	 */
	static class EinteilungenData extends TableViewData<MoEinteilungLang> {

		SimpleStringProperty uid
		SimpleStringProperty dienst
		SimpleStringProperty vorname
		SimpleStringProperty name
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MoEinteilungLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			dienst = new SimpleStringProperty(v.getDienst)
			vorname = new SimpleStringProperty(v.getMessdienerVorname)
			name = new SimpleStringProperty(v.getMessdienerName)
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

		tabbar = 0
		super.initialize
		nr0.setLabelFor(nr)
		von0.setLabelFor(von.getLabelForNode, true)
		name0.setLabelFor(name, true)
		ort0.setLabelFor(ort, true)
		profil0.setLabelFor(profil, true)
		status0.setLabelFor(status, true)
		notiz0.setLabelFor(notiz)
		einteilungen0.setLabelFor(einteilungen)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		name.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			von.setValue(LocalDate::now.atTime(18, 0))
			var List<MaEinstellung> nliste = get(
				FactoryService::getMessdienerService.getStandardNameListe(getServiceDaten))
			name.setItems(getItems(nliste, null, [a|new NameData(a)], null))
			name.getSelectionModel.select(0)
			var List<MaEinstellung> oliste = get(
				FactoryService::getMessdienerService.getStandardOrtListe(getServiceDaten))
			ort.setItems(getItems(oliste, null, [a|new OrtData(a)], null))
			ort.getSelectionModel.select(0)
			var List<MoProfil> pliste = get(
				FactoryService::getMessdienerService.getProfilListe(getServiceDaten, true))
			profil.setItems(getItems(pliste, new MoProfil, [a|new ProfilData(a)], null))
			 // profil.getSelectionModel.select(0)
			var List<MaEinstellung> sliste = get(
				FactoryService::getMessdienerService.getStandardStatusListe(getServiceDaten))
			status.setItems(getItems(sliste, null, [a|new StatusData(a)], null))
			status.getSelectionModel.select(0)
			var boolean neu0 = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean loeschen0 = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var MoGottesdienst k = getParameter1
			if (!neu0 && k !== null) {
				k = get(FactoryService::getMessdienerService.getGottesdienst(getServiceDaten, k.getUid))
				nr.setText(k.getUid)
				von.setValue(k.getTermin)
				setText(name, k.getName)
				setText(ort, k.getOrt)
				setText(profil, k.getProfilUid)
				setText(status, k.getStatus)
				notiz.setText(k.getNotiz)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			von.setEditable(!loeschen0)
			setEditable(name, !loeschen0)
			setEditable(ort, !loeschen0)
			setEditable(profil, !loeschen0)
			setEditable(status, !loeschen0)
			notiz.setEditable(!loeschen0)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen0) {
				ok.setText(Meldungen::M2001)
			}
			neu.setVisible(!loeschen0)
			aendern.setVisible(!loeschen0)
			loeschen.setVisible(!loeschen0)
			alleLoeschen.setVisible(!loeschen0)
		}
		if (stufe <= 1) {
			if (einteilungenData === null) {
				einteilungenData = FXCollections::observableArrayList
				if (!Global::nes(nr.getText)) {
					var List<MoEinteilungLang> l = get(
						FactoryService::getMessdienerService.getEinteilungListe(getServiceDaten, false,
							nr.getText, null))
					getItems(l, null, [a|new EinteilungenData(a)], einteilungenData)
				}
			}
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		einteilungen.setItems(einteilungenData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colDienst.setCellValueFactory([c|c.getValue.dienst])
		colVorname.setCellValueFactory([c|c.getValue.vorname])
		colName.setCellValueFactory([c|c.getValue.name])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		var MoEinteilungLang k = getValue(einteilungen, !DialogAufrufEnum::NEU.equals(aufruf))
		if (DialogAufrufEnum::NEU.equals(aufruf)) {
			k = new MoEinteilungLang
		}
		k.setTermin(von.getValue2)
		k.setGottesdienstStatus(getText(status))
		var List<MoEinteilungLang> liste = starteDialog(typeof(MO220EinteilungController), aufruf, k)
		if (liste !== null) {
			if (DialogAufrufEnum::NEU.equals(aufruf)) {
				for (MoEinteilungLang s : liste) {
					var Optional<EinteilungenData> d = einteilungenData.stream.filter([a |
						Global::compString(a.getData.getMessdienerUid, s.getMessdienerUid) === 0
					]).findFirst
					if (!d.isPresent) {
						einteilungenData.add(new EinteilungenData(s))
					}
				}
			} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
				for (MoEinteilungLang s : liste) {
					var Optional<EinteilungenData> d = einteilungenData.stream.filter([a |
						Global::compString(a.getData.getMessdienerUid, s.getMessdienerUid) === 0
					]).findFirst
					if (d.isPresent) {
						einteilungenData.remove(d.get)
					}
				}
			} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
				for (MoEinteilungLang s : liste) {
					var Optional<EinteilungenData> d = einteilungenData.stream.filter([a |
						Global::compString(a.getData.getUid, s.getUid) === 0
					]).findFirst
					if (d.isPresent) {
						einteilungenData.remove(d.get)
						einteilungenData.add(new EinteilungenData(s))
					}
				}
			}
			onAktuell
		}
	}

	/** 
	 * Event für Aktuell.
	 */
	def private void onAktuell() {
		refreshTable(einteilungen, 1)
	}

	/** 
	 * Event für Einteilungen.
	 */
	@FXML def void onEinteilungenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.insertUpdateGottesdienst(getServiceDaten, null,
				von.getValue2, getText(name), getText(ort), getText(profil), getText(status), notiz.getText,
				getAllValues(einteilungen))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.insertUpdateGottesdienst(getServiceDaten, nr.getText,
				von.getValue2, getText(name), getText(ort), getText(profil), getText(status), notiz.getText,
				getAllValues(einteilungen))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getMessdienerService.deleteGottesdienst(getServiceDaten, nr.getText)
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
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum::NEU)
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
	 * Event für AlleLoeschen.
	 */
	@FXML def void onAlleLoeschen() {
		einteilungenData.clear
		onAktuell
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

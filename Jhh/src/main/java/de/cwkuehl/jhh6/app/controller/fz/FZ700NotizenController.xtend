package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.FzNotizKurz
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog FZ700Notizen.
 */
class FZ700NotizenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label notizen0
	@FXML TableView<NotizKurz> notizen
	@FXML TableColumn<NotizKurz, String> uidCol
	@FXML TableColumn<NotizKurz, String> themaCol
	@FXML TableColumn<NotizKurz, LocalDateTime> colGa
	@FXML TableColumn<NotizKurz, String> colGv
	@FXML TableColumn<NotizKurz, LocalDateTime> colAa
	@FXML TableColumn<NotizKurz, String> colAv
	ObservableList<NotizKurz> notizenData = FXCollections.observableArrayList

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		notizen0.setLabelFor(notizen, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		notizen.requestFocus
	}

	/** 
	 * Dialog-Daten vor updateData(false) initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // model.initDaten(0);
		}
		if (stufe <= 1) {
			var List<FzNotizKurz> l = get(FactoryService.getFreizeitService.getNotizListe(getServiceDaten))
			getItems(l, null, [a|new NotizKurz(a)], notizenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		notizen.setItems(notizenData)
		uidCol.setCellValueFactory([cellData|cellData.getValue.uid])
		themaCol.setCellValueFactory([cellData|cellData.getValue.thema])
		colGv.setCellValueFactory([cellData|cellData.getValue.geaendertVon])
		colGa.setCellValueFactory([cellData|cellData.getValue.geaendertAm])
		colAv.setCellValueFactory([cellData|cellData.getValue.angelegtVon])
		colAa.setCellValueFactory([cellData|cellData.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var FzNotizKurz k = getValue(notizen, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(FZ710NotizController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(notizen, 1)
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
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum.NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum.KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum.AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum.LOESCHEN)
	}

	def void onNotizenMouseClick(MouseEvent event) {
		if (event.clickCount > 1) {
			onAendern
		}
	}

	static class NotizKurz extends TableViewData<FzNotizKurz> {

		final SimpleStringProperty uid
		final SimpleStringProperty thema
		final SimpleObjectProperty<LocalDateTime> geaendertAm
		final SimpleStringProperty geaendertVon
		final SimpleObjectProperty<LocalDateTime> angelegtAm
		final SimpleStringProperty angelegtVon

		new(FzNotizKurz v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			thema = new SimpleStringProperty(v.getThema)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}
}

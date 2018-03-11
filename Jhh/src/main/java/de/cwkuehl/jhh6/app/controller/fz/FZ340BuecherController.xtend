package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.dto.FzBuchLang
import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.Collections
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
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog FZ340Buecher.
 */
class FZ340BuecherController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label buecher0
	@FXML TableView<BuecherData> buecher
	@FXML TableColumn<BuecherData, String> colUid
	@FXML TableColumn<BuecherData, String> colTitel
	@FXML TableColumn<BuecherData, String> colAutor
	@FXML TableColumn<BuecherData, String> colSerie
	@FXML TableColumn<BuecherData, String> colSeriennr
	@FXML TableColumn<BuecherData, Integer> colSeiten
	@FXML TableColumn<BuecherData, String> colSprache
	@FXML TableColumn<BuecherData, Boolean> colBesitz
	@FXML TableColumn<BuecherData, LocalDate> colLesedatum
	@FXML TableColumn<BuecherData, LocalDate> colHoerdatum
	@FXML TableColumn<BuecherData, LocalDateTime> colGa
	@FXML TableColumn<BuecherData, String> colGv
	@FXML TableColumn<BuecherData, LocalDateTime> colAa
	@FXML TableColumn<BuecherData, String> colAv
	ObservableList<BuecherData> buecherData = FXCollections.observableArrayList
	@FXML Label autor0
	@FXML ComboBox<AutorData> autor
	@FXML Label titel0
	@FXML TextField titel

	// @FXML Button alle
	/** 
	 * Daten für Tabelle Buecher.
	 */
	static class BuecherData extends TableViewData<FzBuchLang> {

		SimpleStringProperty uid
		SimpleStringProperty titel
		SimpleStringProperty autor
		SimpleStringProperty serie
		SimpleStringProperty seriennr
		SimpleObjectProperty<Integer> seiten
		SimpleStringProperty sprache
		SimpleObjectProperty<Boolean> besitz
		SimpleObjectProperty<LocalDate> lesedatum
		SimpleObjectProperty<LocalDate> hoerdatum
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(FzBuchLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			titel = new SimpleStringProperty(v.titel)
			autor = new SimpleStringProperty(v.autorName)
			serie = new SimpleStringProperty(v.serieName)
			seriennr = new SimpleStringProperty(Global.intStrFormat(v.seriennummer))
			seiten = new SimpleObjectProperty<Integer>(v.seiten)
			sprache = new SimpleStringProperty(v.sprache)
			besitz = new SimpleObjectProperty<Boolean>(v.istBesitz)
			lesedatum = new SimpleObjectProperty<LocalDate>(v.lesedatum)
			hoerdatum = new SimpleObjectProperty<LocalDate>(v.hoerdatum)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}

	/** 
	 * Daten für ComboBox Autor.
	 */
	static class AutorData extends ComboBoxData<FzBuchautor> {

		new(FzBuchautor v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		buecher0.setLabelFor(buecher)
		autor0.setLabelFor(autor, false)
		titel0.setLabelFor(titel)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		buecher.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var al = get(FactoryService::freizeitService.getAutorListe(serviceDaten, true, null))
			autor.setItems(getItems(al, new FzBuchautor, [a|new AutorData(a)], null))
			setText(autor, null)
			titel.setText("%%")
		}
		if (stufe <= 1) {
			var l = get(FactoryService::freizeitService.getBuchListe(serviceDaten, true, getText(autor), null, null, //
			titel.text))
			getItems(l, null, [a|new BuecherData(a)], buecherData)
			// Absteigend nach Lesedatum
			Collections.sort(buecherData, [ a, b |
				{
					var al = a.lesedatum.get
					al = if(al === null) a.hoerdatum.get else al
					var bl = b.lesedatum.get
					bl = if(bl === null) b.hoerdatum.get else bl
					if (al === null) {
						if (bl === null) {
							return 0
						}
						return 1
					} else if (bl === null) {
						return -1
					}
					return -al.compareTo(bl)
				}
			])
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		buecher.setItems(buecherData)
		colUid.setCellValueFactory([c|c.value.uid])
		colTitel.setCellValueFactory([c|c.value.titel])
		colAutor.setCellValueFactory([c|c.value.autor])
		colSerie.setCellValueFactory([c|c.value.serie])
		colSeriennr.setCellValueFactory([c|c.value.seriennr])
		colSeiten.setCellValueFactory([c|c.value.seiten])
		colSprache.setCellValueFactory([c|c.value.sprache])
		colBesitz.setCellValueFactory([c|c.value.besitz])
		colLesedatum.setCellValueFactory([c|c.value.lesedatum])
		colHoerdatum.setCellValueFactory([c|c.value.hoerdatum])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var FzBuchLang k = getValue(buecher, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(FZ350BuchController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(buecher, 1)
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
	 * Event für Buecher.
	 */
	@FXML def void onBuecherMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Autor.
	 */
	@FXML def void onAutor() {
		onAktuell
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		refreshTable(buecher, 0)
	}
}

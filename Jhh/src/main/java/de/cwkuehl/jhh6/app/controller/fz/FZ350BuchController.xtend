package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDate
import java.util.List
import de.cwkuehl.jhh6.api.dto.FzBuchLang
import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.dto.FzBuchserie
import de.cwkuehl.jhh6.api.enums.SpracheEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup

/** 
 * Controller für Dialog FZ350Buch.
 */
class FZ350BuchController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label titel0
	@FXML TextField titel
	@FXML Label autor0
	@FXML ComboBox<AutorData> autor
	// @FXML Button autorNeu
	@FXML Label serie0
	@FXML ComboBox<SerieData> serie

	/** 
	 * Daten für ComboBox Autor.
	 */
	static class AutorData extends ComboBoxData<FzBuchautor> {
		new(FzBuchautor v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getName
		}
	}

	// @FXML Button serieNeu
	@FXML Label seriennummer0
	@FXML TextField seriennummer
	@FXML Label seiten0
	@FXML TextField seiten
	@FXML Label sprache0
	@FXML ToggleGroup sprache
	@FXML Label besitz0
	@FXML CheckBox besitz
	@FXML Label lesedatum0
	@FXML Datum lesedatum
	@FXML Label hoerdatum0
	@FXML Datum hoerdatum
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Daten für ComboBox Serie.
	 */
	static class SerieData extends ComboBoxData<FzBuchserie> {

		new(FzBuchserie v) {
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

		tabbar = 0
		nr0.setLabelFor(nr)
		titel0.setLabelFor(titel, true)
		autor0.setLabelFor(autor, true)
		serie0.setLabelFor(serie, false)
		seriennummer0.setLabelFor(seriennummer)
		seiten0.setLabelFor(seiten)
		sprache0.setLabelFor(sprache, true)
		besitz0.setLabelFor(besitz)
		lesedatum0.setLabelFor(lesedatum)
		hoerdatum0.setLabelFor(hoerdatum)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		titel.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<FzBuchautor> al = get(FactoryService::freizeitService.getAutorListe(serviceDaten, true, null))
			autor.setItems(getItems(al, null, [a|new AutorData(a)], null))
			var List<FzBuchserie> sl = get(FactoryService::freizeitService.getSerieListe(serviceDaten, null))
			serie.setItems(getItems(sl, null, [a|new SerieData(a)], null))
			if (al.size > 0) {
				setText(autor, al.get(0).getUid)
			}
			if (sl.size > 0) {
				setText(serie, sl.get(0).getUid)
			}
			setText(sprache, SpracheEnum.DEUTSCH.toString)
			besitz.setSelected(true)
			lesedatum.setValue(LocalDate.now)
			hoerdatum.setValue((null as LocalDate))
		}
		if (stufe <= 1) {
			var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf)
			var FzBuchLang k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::freizeitService.getBuchLang(serviceDaten, k.uid))
				nr.setText(k.uid)
				setText(autor, k.autorUid)
				setText(serie, k.serieUid)
				seriennummer.setText(Global.intStrFormat(k.seriennummer))
				titel.setText(k.titel)
				seiten.setText(Global.intStrFormat(k.seiten))
				setText(sprache, Global.intStr(k.spracheNr))
				besitz.setSelected(k.istBesitz)
				lesedatum.setValue(k.lesedatum)
				hoerdatum.setValue(k.hoerdatum)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			setEditable(autor, !loeschen)
			setEditable(serie, !loeschen)
			seriennummer.setEditable(!loeschen)
			titel.setEditable(!loeschen)
			seiten.setEditable(!loeschen)
			setEditable(sprache, !loeschen)
			setEditable(besitz, !loeschen)
			lesedatum.setEditable(!loeschen)
			hoerdatum.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen.M2001)
			}
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
	 * Event für AutorNeu.
	 */
	@FXML def void onAutorNeu() {

		var FzBuchautor k = starteDialog(FZ310AutorController, DialogAufrufEnum.NEU)
		if (k !== null) {
			var List<FzBuchautor> al = get(FactoryService::freizeitService.getAutorListe(serviceDaten, true, null))
			autor.setItems(getItems(al, null, [a|new AutorData(a)], null))
			setText(autor, k.uid)
		}
	}

	/** 
	 * Event für SerieNeu.
	 */
	@FXML def void onSerieNeu() {

		var FzBuchserie k = starteDialog(FZ330SerieController, DialogAufrufEnum.NEU)
		if (k !== null) {
			var List<FzBuchserie> sl = get(FactoryService::freizeitService.getSerieListe(serviceDaten, null))
			serie.setItems(getItems(sl, null, [a|new SerieData(a)], null))
			setText(serie, k.uid)
		}
	}

	/** 
	 * Event für Ok.
	 */
	@FXML
	def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateBuch(serviceDaten, null, getText(autor), getText(serie),
				Global.strInt(seriennummer.text), titel.text, Global.strInt(seiten.text), getText(sprache),
				besitz.isSelected, lesedatum.value, hoerdatum.value)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateBuch(serviceDaten, nr.text, getText(autor), getText(serie),
				Global.strInt(seriennummer.text), titel.text, Global.strInt(seiten.text), getText(sprache),
				besitz.isSelected, lesedatum.value, hoerdatum.value)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService::freizeitService.deleteBuch(serviceDaten, nr.text)
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
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

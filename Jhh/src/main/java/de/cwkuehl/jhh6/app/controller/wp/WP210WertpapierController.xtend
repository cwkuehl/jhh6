package de.cwkuehl.jhh6.app.controller.wp

import java.util.List
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

/** 
 * Controller für Dialog WP210Wertpapier.
 */
class WP210WertpapierController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label kuerzel0
	@FXML TextField kuerzel
	@FXML Label status0
	@FXML ComboBox<StatusData> status
	@FXML Label aktKurs0
	@FXML TextField aktKurs
	@FXML Label stopKurs0
	@FXML TextField stopKurs
	@FXML Label signalKurs10
	@FXML TextField signalKurs1
	@FXML Label muster0
	@FXML TextField muster
	@FXML Label sortierung0
	@FXML TextField sortierung
	@FXML Label relation0
	@FXML ComboBox<RelationData> relation
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
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
	 * Daten für ComboBox Relation.
	 */
	static class RelationData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		bezeichnung0.setLabelFor(bezeichnung, true)
		kuerzel0.setLabelFor(kuerzel, true)
		status0.setLabelFor(status, true)
		aktKurs0.setLabelFor(aktKurs)
		stopKurs0.setLabelFor(stopKurs)
		signalKurs10.setLabelFor(signalKurs1)
		muster0.setLabelFor(muster)
		sortierung0.setLabelFor(sortierung)
		relation0.setLabelFor(relation, false)
		notiz0.setLabelFor(notiz)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		bezeichnung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var List<MaEinstellung> sliste = get(
				FactoryService::getWertpapierService.getWertpapierStatusListe(getServiceDaten))
			status.setItems(getItems(sliste, null, [a|new StatusData(a)], null))
			status.getSelectionModel.select(0)
			var boolean neu = DialogAufrufEnum::NEU.equals(getAufruf)
			var boolean kopieren = DialogAufrufEnum::KOPIEREN.equals(getAufruf)
			var boolean loeschen = DialogAufrufEnum::LOESCHEN.equals(getAufruf)
			var WpWertpapierLang k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::getWertpapierService.getWertpapierLang(getServiceDaten, k.getUid))
				nr.setText(k.getUid)
				bezeichnung.setText(k.getBezeichnung)
				kuerzel.setText(k.getKuerzel)
				aktKurs.setText(k.getAktuellerkurs)
				stopKurs.setText(k.getStopkurs)
				signalKurs1.setText(Global::dblStr2l(k.getSignalkurs1))
				muster.setText(k.getMuster)
				sortierung.setText(k.getSortierung)
				setText(status, k.getStatus)
				setText(relation, k.getRelationUid)
				notiz.setText(k.getNotiz)
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon))
			}
			nr.setEditable(false)
			bezeichnung.setEditable(!loeschen)
			kuerzel.setEditable(!loeschen)
			aktKurs.setEditable(false)
			stopKurs.setEditable(false)
			signalKurs1.setEditable(!loeschen)
			muster.setEditable(false)
			sortierung.setEditable(!loeschen)
			setEditable(relation, !loeschen)
			setEditable(status, !loeschen)
			notiz.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			var List<WpWertpapierLang> wliste = get(
				FactoryService::getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null,
					if(kopieren) null else nr.getText))
			relation.setItems(getItems(wliste, new WpWertpapierLang, [a|new RelationData(a)], null))
			if (!neu && k !== null) {
				setText(relation, k.getRelationUid)
			}
		}
		if (stufe <= 1) { // stufe = 0
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
	 * Event für Ok.
	 */
	@FXML @SuppressWarnings("unchecked") def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::getWertpapierService.insertUpdateWertpapier(getServiceDaten, null,
				bezeichnung.getText, kuerzel.getText, signalKurs1.getText, sortierung.getText, null,
				getText(status), getText(relation), notiz.getText)
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::getWertpapierService.insertUpdateWertpapier(getServiceDaten, nr.getText,
				bezeichnung.getText, kuerzel.getText, signalKurs1.getText, sortierung.getText, null,
				getText(status), getText(relation), notiz.getText)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::getWertpapierService.deleteWertpapier(getServiceDaten, nr.getText)
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

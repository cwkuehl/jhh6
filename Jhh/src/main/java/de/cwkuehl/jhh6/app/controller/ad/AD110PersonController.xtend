package de.cwkuehl.jhh6.app.controller.ad

import java.util.List
import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup

/** 
 * Controller für Dialog AD110Person.
 */
class AD110PersonController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML TextField sitzNr
	@FXML TextField adressNr
	@FXML Label titel0
	@FXML TextField titel
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML Label praedikat0
	@FXML TextField praedikat
	@FXML Label name10
	@FXML TextField name1
	@FXML Label name20
	@FXML TextField name2
	@FXML Label geschlecht0
	@FXML ToggleGroup geschlecht
	@FXML Label geburt0
	@FXML Datum geburt
	@FXML Label personStatus0
	@FXML ToggleGroup personStatus
	@FXML Label name0
	@FXML TextField name
	@FXML Label strasse0
	@FXML TextField strasse
	@FXML Label hausnr0
	@FXML TextField hausnr
	@FXML Label postfach0
	@FXML TextField postfach
	@FXML Label staat0
	@FXML TextField staat
	@FXML Label plz0
	@FXML TextField plz
	@FXML Label ort0
	@FXML TextField ort
	@FXML Label telefon0
	@FXML TextField telefon
	@FXML Label fax0
	@FXML TextField fax
	@FXML Label mobil0
	@FXML TextField mobil
	@FXML Label homepage0
	@FXML TextField homepage
	@FXML Label email0
	@FXML TextField email
	@FXML Label notiz0
	@FXML TextArea notiz
	@FXML Label sitzStatus0
	@FXML ToggleGroup sitzStatus
	@FXML Label adresseAnzahl0
	@FXML TextField adresseAnzahl
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button adresseDupl
	@FXML Button adresseWechseln
	// @FXML Button abbrechen

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		titel0.setLabelFor(titel)
		vorname0.setLabelFor(vorname)
		praedikat0.setLabelFor(praedikat)
		name10.setLabelFor(name1)
		name20.setLabelFor(name2)
		setLabelFor(geschlecht0, geschlecht)
		geburt0.setLabelFor(geburt.getLabelForNode())
		setLabelFor(personStatus0, personStatus)
		name0.setLabelFor(name)
		strasse0.setLabelFor(strasse)
		hausnr0.setLabelFor(hausnr)
		postfach0.setLabelFor(postfach)
		staat0.setLabelFor(staat)
		plz0.setLabelFor(plz)
		ort0.setLabelFor(ort)
		telefon0.setLabelFor(telefon)
		fax0.setLabelFor(fax)
		mobil0.setLabelFor(mobil)
		homepage0.setLabelFor(homepage)
		email0.setLabelFor(email)
		notiz0.setLabelFor(notiz)
		setLabelFor(sitzStatus0, sitzStatus)
		adresseAnzahl0.setLabelFor(adresseAnzahl)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		var boolean neu = DialogAufrufEnum.NEU.equals(getAufruf())
		var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(getAufruf())
		var AdPersonSitzAdresse k = getParameter1()
		if (!neu && k !== null) {
			var List<AdPersonSitzAdresse> l = get(
				FactoryService.getAdresseService().getPersonenSitzAdresseListe(getServiceDaten(), false, false, null,
					null, k.getUid(), k.getSiUid()))
			if (l !== null && l.size() > 0) {
				k = l.get(0)
				nr.setText(k.getUid())
				sitzNr.setText(k.getSiUid())
				adressNr.setText(k.getAdresseUid())
				titel.setText(k.getTitel())
				vorname.setText(k.getVorname())
				praedikat.setText(k.getPraedikat())
				name1.setText(k.getName1())
				name2.setText(k.getName2())
				setText(geschlecht, k.getGeschlecht())
				geburt.setValue(k.getGeburt())
				setText(personStatus, Global.intStr(k.getPersonStatus()))
				name.setText(k.getName())
				strasse.setText(k.getStrasse())
				hausnr.setText(k.getHausnr())
				postfach.setText(k.getPostfach())
				staat.setText(k.getStaat())
				plz.setText(k.getPlz())
				ort.setText(k.getOrt())
				telefon.setText(k.getTelefon())
				fax.setText(k.getFax())
				mobil.setText(k.getMobil())
				homepage.setText(k.getHomepage())
				email.setText(k.getEmail())
				notiz.setText(k.getBemerkung())
				setText(sitzStatus, Global.intStr(k.getSitzStatus()))
				adresseAnzahl.setText(
					Global.intStr(
						get(FactoryService.getAdresseService().getAdresseAnzahl(getServiceDaten(), k.getAdresseUid()))))
				angelegt.setText(k.formatDatumVon(k.getAngelegtAm(), k.getAngelegtVon()))
				geaendert.setText(k.formatDatumVon(k.getGeaendertAm(), k.getGeaendertVon()))
				if (DialogAufrufEnum.KOPIEREN2.equals(getAufruf())) {
					sitzNr.setText(null)
					adressNr.setText(null)
				}
			}
		}
		nr.setEditable(false)
		sitzNr.setEditable(false)
		adressNr.setEditable(false)
		titel.setEditable(!loeschen)
		vorname.setEditable(!loeschen)
		praedikat.setEditable(!loeschen)
		name1.setEditable(!loeschen)
		name2.setEditable(!loeschen)
		setEditable(geschlecht, !loeschen)
		geburt.setEditable(!loeschen)
		setEditable(personStatus, !loeschen)
		name.setEditable(!loeschen)
		strasse.setEditable(!loeschen)
		hausnr.setEditable(!loeschen)
		postfach.setEditable(!loeschen)
		staat.setEditable(!loeschen)
		plz.setEditable(!loeschen)
		ort.setEditable(!loeschen)
		telefon.setEditable(!loeschen)
		fax.setEditable(!loeschen)
		mobil.setEditable(!loeschen)
		homepage.setEditable(!loeschen)
		email.setEditable(!loeschen)
		notiz.setEditable(!loeschen)
		setEditable(sitzStatus, !loeschen)
		adresseAnzahl.setEditable(false)
		angelegt.setEditable(false)
		geaendert.setEditable(false)
		adresseDupl.setVisible(!loeschen)
		adresseWechseln.setVisible(!loeschen)
		if (loeschen) {
			ok.setText(Meldungen.M2001())
		}
		initDaten(0)
		titel.requestFocus()
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0;
		}
		if (stufe <= 1) { // stufe = 0;
		}
		if (stufe <= 2) { // initDatenTable();
		}
	}

	def private AdPersonSitzAdresse getData() {

		var AdPersonSitzAdresse e = new AdPersonSitzAdresse()
		e.setUid(nr.getText())
		e.setSiUid(sitzNr.getText())
		e.setAdresseUid(adressNr.getText())
		e.setTitel(titel.getText())
		e.setVorname(vorname.getText())
		e.setPraedikat(praedikat.getText())
		e.setName1(name1.getText())
		e.setName2(name2.getText())
		e.setGeschlecht(getText(geschlecht))
		e.setGeburt(geburt.getValue())
		e.setPersonStatus(Global.strInt(getText(personStatus)))
		e.setName(name.getText())
		e.setStrasse(strasse.getText())
		e.setHausnr(hausnr.getText())
		e.setPostfach(postfach.getText())
		e.setStaat(staat.getText())
		e.setPlz(plz.getText())
		e.setOrt(ort.getText())
		e.setTelefon(telefon.getText())
		e.setFax(fax.getText())
		e.setMobil(mobil.getText())
		e.setHomepage(homepage.getText())
		e.setEmail(email.getText())
		e.setBemerkung(notiz.getText())
		e.setSitzStatus(Global.strInt(getText(sitzStatus)))
		return e
	}

	/** 
	 * Event für Ok.
	 */
	@SuppressWarnings("unchecked") @FXML def void onOk() {

		var DialogAufrufEnum aufruf = getAufruf()
		/*FIXME Cannot add Annotation to Variable declaration. Java code: @SuppressWarnings("rawtypes")*/
		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			var AdPersonSitzAdresse p = getData()
			p.setUid(null)
			p.setSiUid(null)
			p.setAdresseUid(null)
			r = FactoryService.getAdresseService().insertUpdatePerson(getServiceDaten(), p)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf) || DialogAufrufEnum.KOPIEREN2.equals(aufruf)) {
			var AdPersonSitzAdresse p = getData()
			r = FactoryService.getAdresseService().insertUpdatePerson(getServiceDaten(), p)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.getAdresseService().deleteSitz(getServiceDaten(), nr.getText(), sitzNr.getText())
		}
		if (r !== null) {
			get(r)
			if (r.getFehler().isEmpty()) {
				updateParent()
				close()
			}
		}
	}

	/** 
	 * Event für AdresseDupl.
	 */
	@FXML def void onAdresseDupl() {
		adressNr.setText(null)
		adresseAnzahl.setText("0")
	}

	/** 
	 * Event für AdresseWechseln.
	 */
	@FXML def void onAdresseWechseln() { // AdAdresse k = (AdAdresse) starteDialog(AD130AdressenController.class, DialogAufrufEnum.OHNE);

		// if (k != null) {
		// int diff = 0;
		// if (Global.compString(k.getUid(), adressNr.getText()) != 0) {
		// // Falls sich Nummer ändert, wird neue Nummer einmal mehr benutzt.
		// diff = 1;
		// }
		// adressNr.setText(k.getUid());
		// strasse.setText(k.getStrasse());
		// hausnr.setText(k.getHausnr());
		// staat.setText(k.getStaat());
		// plz.setText(k.getPlz());
		// ort.setText(k.getOrt());
		// adresseAnzahl.setText(Global.intStr(get(FactoryService.getAdresseService().getAdresseAnzahl(getServiceDaten(),
		// k
		// .getUid())) + diff));
		// }
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

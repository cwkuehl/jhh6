package de.cwkuehl.jhh6.app.controller.ad

import de.cwkuehl.jhh6.api.dto.AdAdresse
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
		name10.setLabelFor(name1, true)
		name20.setLabelFor(name2)
		geschlecht0.setLabelFor(geschlecht, true)
		geburt0.setLabelFor(geburt.getLabelForNode())
		personStatus0.setLabelFor(personStatus, true)
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
		sitzStatus0.setLabelFor(sitzStatus, false)
		adresseAnzahl0.setLabelFor(adresseAnzahl)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		var neu = DialogAufrufEnum.NEU.equals(aufruf)
		var loeschen = DialogAufrufEnum.LOESCHEN.equals(aufruf)
		var AdPersonSitzAdresse k = getParameter1()
		if (!neu && k !== null) {
			var l = get(
				FactoryService.adresseService.getPersonenSitzAdresseListe(serviceDaten, false, false, null, null, k.uid,
					k.siUid))
			if (l !== null && l.size > 0) {
				k = l.get(0)
				nr.text = k.getUid
				sitzNr.text = k.getSiUid
				adressNr.text = k.getAdresseUid
				titel.text = k.getTitel
				vorname.text = k.getVorname
				praedikat.text = k.getPraedikat
				name1.text = k.getName1
				name2.text = k.getName2
				setText(geschlecht, k.getGeschlecht)
				geburt.value = k.getGeburt
				setText(personStatus, Global.intStr(k.getPersonStatus))
				name.text = k.getName
				strasse.text = k.getStrasse
				hausnr.text = k.getHausnr
				postfach.text = k.getPostfach
				staat.text = k.getStaat
				plz.text = k.getPlz
				ort.text = k.getOrt
				telefon.text = k.getTelefon
				fax.text = k.getFax
				mobil.text = k.getMobil
				homepage.text = k.getHomepage
				email.text = k.getEmail
				notiz.text = k.getBemerkung
				setText(sitzStatus, Global.intStr(k.getSitzStatus))
				adresseAnzahl.text = Global.intStr(
					get(FactoryService.adresseService.getAdresseAnzahl(serviceDaten, k.getAdresseUid)))
				angelegt.text = k.formatDatumVon(k.getAngelegtAm, k.getAngelegtVon)
				geaendert.text = k.formatDatumVon(k.getGeaendertAm, k.getGeaendertVon)
				if (DialogAufrufEnum.KOPIEREN2.equals(aufruf)) {
					sitzNr.text = null
					adressNr.text = null
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
			ok.text = Meldungen.M2001
		}
		initDaten(0)
		titel.requestFocus
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

		var e = new AdPersonSitzAdresse
		e.setUid(nr.text)
		e.setSiUid(sitzNr.text)
		e.setAdresseUid(adressNr.text)
		e.setTitel(titel.text)
		e.setVorname(vorname.text)
		e.setPraedikat(praedikat.text)
		e.setName1(name1.text)
		e.setName2(name2.text)
		e.setGeschlecht(getText(geschlecht))
		e.setGeburt(geburt.getValue())
		e.setPersonStatus(Global.strInt(getText(personStatus)))
		e.setName(name.text)
		e.setStrasse(strasse.text)
		e.setHausnr(hausnr.text)
		e.setPostfach(postfach.text)
		e.setStaat(staat.text)
		e.setPlz(plz.text)
		e.setOrt(ort.text)
		e.setTelefon(telefon.text)
		e.setFax(fax.text)
		e.setMobil(mobil.text)
		e.setHomepage(homepage.text)
		e.setEmail(email.text)
		e.setBemerkung(notiz.text)
		e.setSitzStatus(Global.strInt(getText(sitzStatus)))
		return e
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			var AdPersonSitzAdresse p = getData()
			p.setUid(null)
			p.setSiUid(null)
			p.setAdresseUid(null)
			r = FactoryService.adresseService.insertUpdatePerson(serviceDaten, p)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf) || DialogAufrufEnum.KOPIEREN2.equals(aufruf)) {
			var AdPersonSitzAdresse p = getData()
			r = FactoryService.adresseService.insertUpdatePerson(serviceDaten, p)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			r = FactoryService.adresseService.deleteSitz(serviceDaten, nr.text, sitzNr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				updateParent
				close
			}
		}
	}

	/** 
	 * Event für AdresseDupl.
	 */
	@FXML def void onAdresseDupl() {
		adressNr.text = null
		adresseAnzahl.text = "0"
	}

	/** 
	 * Event für AdresseWechseln.
	 */
	@FXML def void onAdresseWechseln() {

		var AdAdresse k = starteDialog(typeof(AD130AdressenController), DialogAufrufEnum.OHNE)
		if (k !== null) {
			var diff = 0
			if (Global.compString(k.uid, adressNr.text) != 0) {
				// Falls sich Nummer ändert, wird neue Nummer einmal mehr benutzt.
				diff = 1
			}
			adressNr.text = k.uid
			strasse.text = k.strasse
			hausnr.text = k.hausnr
			staat.text = k.staat
			plz.text = k.plz
			ort.text = k.ort
			adresseAnzahl.text = Global.intStr(
				get(FactoryService.adresseService.getAdresseAnzahl(serviceDaten, k.uid)) + diff)
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}

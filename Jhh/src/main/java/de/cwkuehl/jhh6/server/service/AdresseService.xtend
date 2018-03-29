package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.AdAdresse
import de.cwkuehl.jhh6.api.dto.AdAdresseKey
import de.cwkuehl.jhh6.api.dto.AdAdresseUpdate
import de.cwkuehl.jhh6.api.dto.AdPerson
import de.cwkuehl.jhh6.api.dto.AdPersonKey
import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.dto.AdPersonUpdate
import de.cwkuehl.jhh6.api.dto.AdSitz
import de.cwkuehl.jhh6.api.dto.AdSitzUpdate
import de.cwkuehl.jhh6.api.enums.GeschlechtEnum
import de.cwkuehl.jhh6.api.enums.PersonStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.impl.AdAdresseRep
import de.cwkuehl.jhh6.server.rep.impl.AdPersonRep
import de.cwkuehl.jhh6.server.rep.impl.AdSitzRep
import java.time.LocalDate
import java.util.ArrayList
import java.util.List
import java.util.Vector
import java.util.function.BiConsumer

@Service
class AdresseService {

	@RepositoryRef AdAdresseRep adresseRep
	@RepositoryRef AdPersonRep personRep
	@RepositoryRef AdSitzRep sitzRep

	/** Lesen aller aktuellen Geburtstage.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @return Liste aller aktuellen Geburtstage.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<String>> getGeburtstagListe(ServiceDaten daten, LocalDate datum, int tage) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<String>>(null)
		var v = new ArrayList<String>
		var dvon = datum.minusDays(tage)
		var dbis = datum.plusDays(tage)
		var j = datum.year
		var j1 = 0
		var dv = dvon.monthValue * 100 + dvon.dayOfMonth
		v.add(Meldungen::AD001(dvon.atStartOfDay, dbis.atStartOfDay))
		var i = if(j != dvon.year) 1 else if(j != dbis.year) 2 else 0
		var liste = personRep.getGeburtstagListe(daten, dvon, dbis)
		for (AdPerson vo : liste) {
			var d = vo.geburtk
			if (i == 0) {
				j1 = j - vo.geburt.year
			} else {
				if (dv <= d) {
					j1 = dvon.year - vo.geburt.year
				} else {
					j1 = dbis.year - vo.geburt.year
				}
			}
			v.add(Meldungen::AD002(vo.geburt.atStartOfDay, Global.anhaengen(vo.name1, ", ", vo.vorname), j1))
		}
		r.ergebnis = v
		return r
	}

	/** Lesen aller Personen mit Adressen.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @return Liste aller Personen mit Adressen.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<AdPersonSitzAdresse>> getPersonenSitzAdresseListe(ServiceDaten daten,
		boolean zusammengesetzt, boolean nurAktuelle, String name, String vorname, String puid, String suid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<AdPersonSitzAdresse>>(null)
		var l = personRep.getPersonenSitzAdresseListe(daten, nurAktuelle, name, vorname, puid, suid)
		if (zusammengesetzt) {
			var String pnr
			for (AdPersonSitzAdresse e : l) {
				var strB = new StringBuffer
				if (Global.compString(pnr, e.uid) != 0) {
					pnr = e.uid
					if (e.personStatus != PersonStatusEnum.AKTUELL.intValue) {
						strB.append("(")
					}
					strB.append(e.name1)
					Global.anhaengen(strB, ", ", e.vorname)
					if (e.personStatus != PersonStatusEnum.AKTUELL.intValue) {
						strB.append(")")
					}
				}
				e.setName1(strB.toString)
				strB = new StringBuffer
				if (e.sitzStatus != PersonStatusEnum.AKTUELL.intValue) {
					strB.append("(")
				}
				strB.append(e.name)
				Global.anhaengen(strB, ", ", e.ort)
				if (e.sitzStatus != PersonStatusEnum.AKTUELL.intValue) {
					strB.append(")")
				}
				e.setName(strB.toString)
				if (Global.excelNes(e.name)) {
					e.setName("")
				}
			}
		}
		r.ergebnis = l
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<Integer> getAdresseAnzahl(ServiceDaten daten, String adressUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<Integer>(sitzRep.getAdresseAnzahl(daten, adressUid))
		return r
	}

	/** Lesen aller Adressen.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @return Liste aller Adressen.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<AdAdresse>> getAdresseListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<AdAdresse>>(null)
		r.ergebnis = adresseRep.getListe(daten, daten.mandantNr, null, null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportAdresse(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var ueberschrift = Meldungen::AD003(daten.jetzt)
		var liste = personRep.getPersonenSitzAdresseListe(daten, true, null, null, null, null)
		var doc = newFopDokument
		doc.addAdressenliste(true, ueberschrift, liste)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> machSitzEins(ServiceDaten daten, String personUid, String sitzUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = sitzRep.getSitzListe(daten, personUid, null, null)
		var reihenfolge = 1
		for (AdSitz e : liste) {
			var voU = new AdSitzUpdate(e)
			if (Global.compString(sitzUid, e.uid) == 0) {
				voU.setReihenfolge(1)
			} else {
				reihenfolge = reihenfolge + 1
				voU.setReihenfolge(reihenfolge)
			}
			if (voU.isChanged) {
				voU.machGeaendert(daten.jetzt, daten.benutzerId)
				sitzRep.update(daten, voU)
			}
		}
		var r = new ServiceErgebnis<Void>
		return r
	}

	def private boolean isPersonLeer(AdPerson person) {

		if (person.typ == 0 && Global.nes(person.geschlecht) && person.geburt === null && person.anrede == 0 &&
			Global.nes(person.name1) && Global.nes(person.name2) && Global.nes(person.praedikat) &&
			Global.nes(person.vorname) && Global.nes(person.titel) && person.personStatus == 0) {
			return true
		}
		return false
	}

	def private boolean isAdresseLeer(AdPersonSitzAdresse adresse) {

		if ((Global.nes(adresse.staat) || "D".equals(adresse.staat)) && Global.nes(adresse.plz) &&
			Global.nes(adresse.ort) && Global.nes(adresse.strasse) && Global.nes(adresse.hausnr)) {
			return true
		}
		return false
	}

	def private boolean isAdresseLeer(AdAdresse adresse) {

		if ((Global.nes(adresse.staat) || "D".equals(adresse.staat)) && Global.nes(adresse.plz) &&
			Global.nes(adresse.ort) && Global.nes(adresse.strasse) && Global.nes(adresse.hausnr)) {
			return true;
		}
		return false;
	}

	def private boolean isSitzLeer(AdPersonSitzAdresse sitz) {

		if (sitz.typ == 0 && Global.nes(sitz.name) && Global.nes(sitz.telefon) && Global.nes(sitz.fax) &&
			Global.nes(sitz.mobil) && Global.nes(sitz.email) && Global.nes(sitz.homepage) &&
			Global.nes(sitz.postfach) && Global.nes(sitz.bemerkung) && sitz.sitzStatus == 0) {
			return true
		}
		return false
	}

	def private boolean isSitzLeer(AdSitz sitz) {

		if (sitz.typ == 0 && Global.nes(sitz.name) && Global.nes(sitz.telefon) && Global.nes(sitz.fax) &&
			Global.nes(sitz.mobil) && Global.nes(sitz.email) && Global.nes(sitz.homepage) &&
			Global.nes(sitz.postfach) && Global.nes(sitz.bemerkung) && sitz.sitzStatus == 0) {
			return true;
		}
		return false;
	}

	val private BiConsumer<AdPerson, AdPersonUpdate> personEvent = [ AdPerson e, AdPersonUpdate u |

		var String uid
		var String name1
		var LocalDate geburt
		var geburtk = 0
		var String geschlecht
		if (e !== null) {
			uid = e.uid
			name1 = e.name1
			geburt = e.geburt
			geschlecht = e.geschlecht
		} else if (u !== null) {
			uid = u.uid
			name1 = u.name1
			geburt = u.geburt
			geschlecht = u.geschlecht
		}
		if (Global.nes(name1)) {
			name1 = Meldungen::AD013(uid)
		}
		if (geburt !== null) {
			geburtk = geburt.monthValue * 100 + geburt.dayOfMonth
		}
		if (Global.nes(geschlecht) ||
			!(GeschlechtEnum.MANN.toString.equals(geschlecht) || GeschlechtEnum.FRAU.toString.equals(geschlecht))) {
			geschlecht = GeschlechtEnum.NEUTRUM.toString
		}
		if (e !== null) {
			e.name1 = name1
			e.geburtk = geburtk
			e.geschlecht = geschlecht
		} else if (u !== null) {
			u.name1 = name1
			u.geburtk = geburtk
			u.geschlecht = geschlecht
		}
	]

	val private BiConsumer<AdSitz, AdSitzUpdate> sitzEvent = [ AdSitz e, AdSitzUpdate u |

		var String uid
		var String name
		if (e !== null) {
			uid = e.uid
			name = e.name
		} else if (u !== null) {
			uid = u.uid
			name = u.name
		}
		if (Global.nes(name)) {
			name = Meldungen::AD014
		}
		if (e !== null) {
			e.name = name
		} else if (u !== null) {
			u.name = name
		}
	]

	val private BiConsumer<AdAdresse, AdAdresseUpdate> adresseEvent = [ AdAdresse e, AdAdresseUpdate u |

		var String uid
		var String ort
		if (e !== null) {
			uid = e.uid
			ort = e.ort
		} else if (u !== null) {
			uid = u.uid
			ort = u.ort
		}
		if (Global.nes(ort)) {
			ort = ""
		}
		if (e !== null) {
			e.ort = ort
		} else if (u !== null) {
			u.ort = ort
		}
	]

	@Transaction
	override ServiceErgebnis<String> insertUpdatePerson(ServiceDaten daten, AdPersonSitzAdresse p) {

		var r = new ServiceErgebnis<String>(p.uid)
		var ps = personRep.iuAdPerson(daten, personEvent, p.uid, 0, p.geschlecht, p.geburt, 0, 0, 0, p.name1, p.name2,
			p.praedikat, p.vorname, p.titel, p.personStatus, null, null, null, null)
		r.ergebnis = ps.uid
		p.uid = ps.uid
		if ("0".equals(p.adresseUid)) {
			p.adresseUid = null // Daten-Korrektur
		}
		if (!(Global.nes(p.adresseUid) && isAdresseLeer(p))) {
			// leere Adresse wird nicht angelegt.
			var ad = adresseRep.iuAdAdresse(daten, adresseEvent, p.adresseUid, p.staat, p.plz, p.ort, p.strasse,
				p.hausnr, null, null, null, null)
			p.adresseUid = ad.uid
		}
		if (!(Global.nes(p.adresseUid) && Global.nes(p.siUid) && isSitzLeer(p))) {
			var l = sitzRep.getSitzListe(daten, p.uid, p.siUid, null)
			if (Global.nes(p.siUid)) {
				if (l.size <= 0) {
					p.reihenfolge = 1
				} else {
					p.reihenfolge = l.map[s|s.reihenfolge].reduce[a, b|if(a > b) a else b] + 1
				}
			} else if (l.size > 0) {
				p.reihenfolge = l.get(0).reihenfolge
			}
			// leerer Sitz wird nicht angelegt.
			var si = sitzRep.iuAdSitz(daten, sitzEvent, p.uid, p.reihenfolge, p.siUid, p.siTyp, p.name, p.adresseUid,
				p.telefon, p.fax, p.mobil, p.email, p.homepage, p.postfach, p.bemerkung, p.sitzStatus, null, null, null, //
				null)
			p.siUid = si.uid
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteSitz(ServiceDaten daten, String personUid, String sitzUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = sitzRep.getSitzListe(daten, personUid, sitzUid, null)
		var AdSitz adSitz
		if (liste !== null && liste.size > 0) {
			adSitz = liste.get(0)
			if (!Global.nes(adSitz.adresseUid)) {
				liste = sitzRep.getSitzListe(daten, null, null, adSitz.adresseUid)
				if (liste.size <= 1) {
					// nicht mehr verwendete Adresse löschen
					var adAdresseKey = new AdAdresseKey(daten.mandantNr, adSitz.adresseUid)
					adresseRep.delete(daten, adAdresseKey)
				}
			}
			sitzRep.delete(daten, adSitz)
		}

		liste = sitzRep.getSitzListe(daten, personUid, null, null)
		// wo.setUidNe(sitzUid)
		if (liste.size <= 0) {
			// mit dem letzten Sitz wird die Person gelöscht
			var adPersonKey = new AdPersonKey(daten.mandantNr, personUid)
			personRep.delete(daten, adPersonKey)
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private List<String> getAdresseSpalten() {

		var l = newArrayList("Uid", "Typ", "Geschlecht", "Geburt", "Anrede", "Name1", "Name2", "Praedikat", "Vorname",
			"Titel", "PersonStatus", "AngelegtVon", "AngelegtAm", "GeaendertVon", "GeaendertAm", "PersonUid", "SiUid",
			"SiTyp", "Name", "AdresseUid", "Telefon", "Fax", "Mobil", "Email", "Homepage", "Postfach", "Bemerkung",
			"SitzStatus", "SiAngelegtVon", "SiAngelegtAm", "SiGeaendertVon", "SiGeaendertAm", "AdUid", "Staat", "Plz",
			"Ort", "Strasse", "Hausnr", "AdAngelegtVon", "AdAngelegtAm", "AdGeaendertVon", "AdGeaendertAm", //
			"Reihenfolge")
		return l
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> exportAdresseListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var felder = getAdresseSpalten
		var liste = personRep.getListeSitzAdresse(daten, daten.mandantNr, null, null)
		var l = new ArrayList<String>
		l.add(Global.encodeCSV(felder))
		exportListeFuellen(felder, liste, new AdPersonSitzAdresse, l)

		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}

	@Transaction
	override ServiceErgebnis<String> importAdresseListe(ServiceDaten daten, List<String> zeilen, boolean loeschen) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var person = new AdPerson
		var sitz = new AdSitz
		var adresse = new AdAdresse
		var List<String> felder
		var werte = new Vector<Object>
		var pAnzahl = 0
		var sAnzahl = 0
		var aAnzahl = 0
		var pFehler = 0
		var sFehler = 0
		var aFehler = 0
		var geprueft = false
		var adresseLeer = false
		val pUid = 0
		val pTyp = 1
		val pGeschlecht = 2
		val pGeburt = 3
		val pAnrede = 4
		val pName1 = 5
		val pName2 = 6
		val pPraedikat = 7
		val pVorname = 8
		val pTitel = 9
		val pPersonStatus = 10
		val pAngelegtVon = 11
		val pAngelegtAm = 12
		val pGeaendertVon = 13
		val pGeaendertAm = 14
		val sPersonUid = 15
		val sUid = 16
		val sTyp = 17
		val sName = 18
		val sAdressUid = 19
		val sTelefon = 20
		val sFax = 21
		val sMobil = 22
		val sEmail = 23
		val sHomepage = 24
		val sPostfach = 25
		val sBemerkung = 26
		val sSitzStatus = 27
		val sAngelegtVon = 28
		val sAngelegtAm = 29
		val sGeaendertVon = 30
		val sGeaendertAm = 31
		val aNr = 32
		val aStaat = 33
		val aPlz = 34
		val aOrt = 35
		val aStrasse = 36
		val aHausNr = 37
		val aAngelegtVon = 38
		val aAngelegtAm = 39
		val aGeaendertVon = 40
		val aGeaendertAm = 41
		val sReihenfolge = 42

		try {
			if (loeschen) {
				var adListe = adresseRep.getListe(daten, daten.mandantNr, null, null)
				for (AdAdresse b : adListe) {
					adresseRep.delete(daten, b)
				}
				var siListe = sitzRep.getListe(daten, daten.mandantNr, null, null)
				for (AdSitz b : siListe) {
					sitzRep.delete(daten, b)
				}
				var peListe = personRep.getListe(daten, daten.mandantNr, null, null)
				for (AdPerson b : peListe) {
					personRep.delete(daten, b)
				}
				log.debug(Meldungen::AD004)
			}

			var String pnr
			var String snr
			var String anr
			var fehler = false
			var String feld
			for (String zeile : zeilen) {
				felder = Global.decodeCSV(zeile)
				if (geprueft) {
					werte.clear
					pnr = null
					snr = null
					anr = null
					adresseLeer = false
					person.setMandantNr(daten.mandantNr)
					fehler = false
					// Person suchen und einfügen oder ändern
					feld = felder.get(pUid)
					person.setUid(feld)
					feld = felder.get(pTyp)
					person.setTyp(Global.strInt(feld))
					feld = felder.get(pGeschlecht)
					person.setGeschlecht(Global.nesString(feld))
					feld = felder.get(pGeburt)
					person.setGeburt(Global.objDat2(feld))
					feld = felder.get(pAnrede)
					person.setAnrede(Global.strInt(feld))
					person.setFanrede(0)
					feld = felder.get(pName1)
					person.setName1(Global.nesString(feld))
					feld = felder.get(pName2)
					person.setName2(Global.nesString(feld))
					feld = felder.get(pPraedikat)
					person.setPraedikat(Global.nesString(feld))
					feld = felder.get(pVorname)
					person.setVorname(Global.nesString(feld))
					feld = felder.get(pTitel)
					person.setTitel(Global.nesString(feld))
					feld = felder.get(pPersonStatus)
					person.setPersonStatus(Global.strInt(feld))
					feld = felder.get(pAngelegtVon)
					person.setAngelegtVon(Global.nesString(feld))
					feld = felder.get(pAngelegtAm)
					person.setAngelegtAm(Global.objDat(feld))
					feld = felder.get(pGeaendertVon)
					person.setGeaendertVon(Global.nesString(feld))
					feld = felder.get(pGeaendertAm)
					person.setGeaendertAm(Global.objDat(feld))
					if (!isPersonLeer(person)) {
						pnr = personRep.getUid(daten, person)
					}
					try {
						if (Global.nes(pnr)) {
							pAnzahl++
							person = personRep.iuAdPerson(daten, personEvent, null, person.typ, person.geschlecht,
								person.geburt, person.geburtk, person.anrede, person.fanrede, person.name1,
								person.name2, person.praedikat, person.vorname, person.titel, person.personStatus,
								person.angelegtVon, person.angelegtAm, person.geaendertVon, person.geaendertAm)
							pnr = person.uid
						} else {
							personRep.iuAdPerson(daten, personEvent, pnr, person.typ, person.geschlecht, person.geburt,
								person.geburtk, person.anrede, person.fanrede, person.name1, person.name2,
								person.praedikat, person.vorname, person.titel, person.personStatus, person.angelegtVon,
								person.angelegtAm, person.geaendertVon, person.geaendertAm)
						}
					} catch (Exception ex) {
						log.error(Meldungen::AD007, ex)
						fehler = true
						pFehler++
						if (Global.nes(pnr)) {
							pAnzahl--
						}
					}
					if (!fehler) {
						// Sitz suchen und einfügen oder ändern
						sitz.setMandantNr(daten.mandantNr)
						feld = felder.get(sPersonUid)
						sitz.setPersonUid(pnr)
						feld = felder.get(sUid)
						sitz.setUid(feld)
						feld = felder.get(sTyp)
						sitz.setTyp(Global.strInt(feld))
						feld = felder.get(sName)
						sitz.setName(Global.nesString(feld))
						feld = felder.get(sAdressUid)
						sitz.setAdresseUid(feld)
						feld = felder.get(sTelefon)
						sitz.setTelefon(Global.nesString(feld))
						feld = felder.get(sFax)
						sitz.setFax(Global.nesString(feld))
						feld = felder.get(sMobil)
						sitz.setMobil(Global.nesString(feld))
						feld = felder.get(sEmail)
						sitz.setEmail(Global.nesString(feld))
						feld = felder.get(sHomepage)
						sitz.setHomepage(Global.nesString(feld))
						feld = felder.get(sPostfach)
						sitz.setPostfach(Global.nesString(feld))
						feld = felder.get(sBemerkung)
						sitz.setBemerkung(Global.nesString(feld))
						feld = felder.get(sSitzStatus)
						sitz.setSitzStatus(Global.strInt(feld))
						feld = felder.get(sAngelegtVon)
						sitz.setAngelegtVon(Global.nesString(feld))
						feld = felder.get(sAngelegtAm)
						sitz.setAngelegtAm(Global.objDat(feld))
						feld = felder.get(sGeaendertVon)
						sitz.setGeaendertVon(Global.nesString(feld))
						feld = felder.get(sGeaendertAm)
						sitz.setGeaendertAm(Global.objDat(feld))
						if (felder.size > sReihenfolge) {
							feld = felder.get(sReihenfolge)
							sitz.setReihenfolge(Global.strInt(feld))
						}
						// Adresse suchen und einfügen oder ändern
						adresse.setMandantNr(daten.mandantNr)
						feld = felder.get(aNr)
						adresse.setUid(feld)
						feld = felder.get(aStaat)
						adresse.setStaat(Global.nesString(feld))
						feld = felder.get(aPlz)
						adresse.setPlz(Global.nesString(feld))
						feld = felder.get(aOrt)
						adresse.setOrt(feld)
						feld = felder.get(aStrasse)
						adresse.setStrasse(Global.nesString(feld))
						feld = felder.get(aHausNr)
						adresse.setHausnr(Global.nesString(feld))
						feld = felder.get(aAngelegtVon)
						adresse.setAngelegtVon(Global.nesString(feld))
						feld = felder.get(aAngelegtAm)
						adresse.setAngelegtAm(Global.objDat(feld))
						feld = felder.get(aGeaendertVon)
						adresse.setGeaendertVon(Global.nesString(feld))
						feld = felder.get(aGeaendertAm)
						adresse.setGeaendertAm(Global.objDat(feld))
						adresseLeer = isAdresseLeer(adresse)
						if (!adresseLeer) {
							anr = adresseRep.getUid(daten, adresse)
						}
						try {
							if (Global.nes(anr)) {
								if (!adresseLeer) {
									aAnzahl++
									adresse = adresseRep.iuAdAdresse(daten, adresseEvent, null, adresse.staat,
										adresse.plz, adresse.ort, adresse.strasse, adresse.hausnr, adresse.angelegtVon,
										adresse.angelegtAm, adresse.geaendertVon, adresse.geaendertAm)
									anr = adresse.uid
								}
							} else {
								adresse = adresseRep.iuAdAdresse(daten, adresseEvent, anr, adresse.staat, adresse.plz,
									adresse.ort, adresse.strasse, adresse.hausnr, adresse.angelegtVon,
									adresse.angelegtAm, adresse.geaendertVon, adresse.geaendertAm)
							}
						} catch (Exception ex) {
							log.error(Meldungen::AD009, ex)
							fehler = true
							aFehler++
							if (Global.nes(anr)) {
								aAnzahl--
							}
						}
					}
					if (!fehler) {
						if (!isSitzLeer(sitz)) {
							snr = sitzRep.getUid(daten, sitz)
						}
						try {
							sitz.setAdresseUid(anr)
							if (Global.nes(snr)) {
								sAnzahl++
								sitz = sitzRep.iuAdSitz(daten, sitzEvent, sitz.personUid, sitz.reihenfolge, null,
									sitz.typ, sitz.name, sitz.adresseUid, sitz.telefon, sitz.fax, sitz.mobil,
									sitz.email, sitz.homepage, sitz.postfach, sitz.bemerkung, sitz.sitzStatus,
									sitz.angelegtVon, sitz.angelegtAm, sitz.geaendertVon, //
									sitz.geaendertAm)
							} else {
								sitzRep.iuAdSitz(daten, sitzEvent, sitz.personUid, sitz.reihenfolge, snr, sitz.typ,
									sitz.name, sitz.adresseUid, sitz.telefon, sitz.fax, sitz.mobil, sitz.email,
									sitz.homepage, sitz.postfach, sitz.bemerkung, sitz.sitzStatus, sitz.angelegtVon,
									sitz.angelegtAm, sitz.geaendertVon, sitz.geaendertAm)
							}
						} catch (Exception ex) {
							log.error(Meldungen::AD008, ex)
							fehler = true
							sFehler++
							if (Global.nes(snr)) {
								sAnzahl--
							}
						}
					}
				} else {
					var spaltennamen = getAdresseSpalten
					var spalten = spaltennamen.length
					if (spalten - 1 <= felder.size && felder.size <= spalten) {
						var j = 0
						var x = true
						for (; j < felder.size && x; j++) {
							if (!felder.get(j).equals(spaltennamen.get(j))) {
								x = false
							}
						}
						if (j >= spalten - 1) {
							geprueft = true
						}
						if (j >= spalten - 1) {
							geprueft = true
						}
					}
					if (!geprueft) {
						throw new MeldungException(Meldungen::AD005)
					}
				}
			}
			if (!geprueft) {
				throw new MeldungException(Meldungen::AD006)
			}
		} finally {
			Global.machNichts
		}
		var r = new ServiceErgebnis<String>(Meldungen::AD010(pAnzahl, pFehler, sAnzahl, sFehler, aAnzahl, aFehler))
		return r
	}
}

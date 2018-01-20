package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.BenutzerKey
import de.cwkuehl.jhh6.api.dto.FzBuch
import de.cwkuehl.jhh6.api.dto.FzBuchKey
import de.cwkuehl.jhh6.api.dto.FzBuchLang
import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.dto.FzBuchautorKey
import de.cwkuehl.jhh6.api.dto.FzBuchserie
import de.cwkuehl.jhh6.api.dto.FzBuchserieKey
import de.cwkuehl.jhh6.api.dto.FzBuchstatusKey
import de.cwkuehl.jhh6.api.dto.FzFahrrad
import de.cwkuehl.jhh6.api.dto.FzFahrradKey
import de.cwkuehl.jhh6.api.dto.FzFahrradLang
import de.cwkuehl.jhh6.api.dto.FzFahrradstand
import de.cwkuehl.jhh6.api.dto.FzFahrradstandKey
import de.cwkuehl.jhh6.api.dto.FzFahrradstandLang
import de.cwkuehl.jhh6.api.dto.FzFahrradstandUpdate
import de.cwkuehl.jhh6.api.dto.FzNotiz
import de.cwkuehl.jhh6.api.dto.FzNotizKey
import de.cwkuehl.jhh6.api.dto.FzNotizKurz
import de.cwkuehl.jhh6.api.dto.HhBilanz
import de.cwkuehl.jhh6.api.enums.FzFahrradTypEnum
import de.cwkuehl.jhh6.api.enums.SpracheEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.ServiceRef
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.impl.BenutzerRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchautorRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchserieRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchstatusRep
import de.cwkuehl.jhh6.server.rep.impl.FzFahrradRep
import de.cwkuehl.jhh6.server.rep.impl.FzFahrradstandRep
import de.cwkuehl.jhh6.server.rep.impl.FzNotizRep
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.List

@Service
class FreizeitService {

	@ServiceRef HaushaltService haushaltService
	@RepositoryRef BenutzerRep benutzerRep
	@RepositoryRef FzBuchRep buchRep
	@RepositoryRef FzBuchautorRep autorRep
	@RepositoryRef FzBuchserieRep serieRep
	@RepositoryRef FzBuchstatusRep statusRep
	@RepositoryRef FzFahrradRep fahrradRep
	@RepositoryRef FzFahrradstandRep standRep
	@RepositoryRef FzNotizRep notizRep

	/** Lesen aller Notizen.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @return Liste aller Notizen.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<FzNotizKurz>> getNotizListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<FzNotizKurz>>(notizRep.getListeKurz(daten, daten.mandantNr, null, null))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzNotiz> getNotiz(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzNotiz>(notizRep.get(daten, new FzNotizKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<FzNotiz> insertUpdateNotiz(ServiceDaten daten, String uid, String thema, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzNotiz>(null)
		if (Global.nes(thema)) {
			throw new MeldungException(Meldungen.FZ035)
		}
		r.ergebnis = notizRep.iuFzNotiz(daten, null, uid, thema, notiz, null, null, null, null)
		return r

	}

	@Transaction
	override ServiceErgebnis<Void> deleteNotiz(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<Void>(null)
		var key = new FzNotizKey(daten.mandantNr, uid)
		notizRep.delete(daten, key)
		return r
	}

	/**
	 * Liefert true, wenn Beträge in Euro zu verstehen sind.
	 * @return True, wenn Beträge in Euro gelten.
	 */
	def private boolean isEuroIntern() {

		// return false
		return true
	}

	@Transaction(false)
	override ServiceErgebnis<String> getStatistik(ServiceDaten daten, int nr, LocalDate jetzt0) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(null)
		var euro = isEuroIntern
		// var strE = Global.iif(euro, " €", " DM")
		if (jetzt0 === null) {
			return r
		}

		if (nr == 1) {
			// Eigenkapital
			var r1 = haushaltService.holeEkStaende(daten, jetzt0)
			r.get(r1)
			if (!r.ok) {
				return r
			}
			var hhBilanz = r1.ergebnis
			var sb = new StringBuffer
			var db = 0.0
			var alt = Double.NaN
			if (hhBilanz !== null) {
				for (HhBilanz e : hhBilanz) {
					db = if(euro) e.ebetrag else e.betrag
					if (!Double.isNaN(alt)) {
						sb.append(Meldungen.FZ002(Global.dblStr2(alt - db))).append(")") // .append(strE)
					}
					if (sb.length > 0) {
						sb.append(Constant.CRLF)
					}
					sb.append(Meldungen.FZ001(Meldungen.HH001, e.geaendertAm, db)) // .append(strE)
					alt = db
				}
			}
			r.ergebnis = sb.toString
		} else if (nr == 2) {
			// Buchstatistik
			var prSerie = ""
			var benutzer = benutzerRep.get(daten, new BenutzerKey(daten.mandantNr, daten.benutzerId))
			if (benutzer === null) {
				throw new MeldungException(Meldungen.FZ036(daten.benutzerId))
			}
			var geburt = benutzer.geburt
			var wk = benutzer.benutzerId.toLowerCase.equals("wolfgang")
			var sb = new StringBuffer
			var long anzahlTage = 0
			var jetzt = jetzt0.plusDays(1)
			if (wk) {
				var sliste = serieRep.getBuchserieListe(daten, "%Perry Rhodan")
				if (sliste.size > 0) {
					prSerie = sliste.get(0).uid
				}
			}
			sb.append(Meldungen.FZ003(benutzer.benutzerId.toFirstUpper))
			if (geburt !== null) {
				anzahlTage = ChronoUnit.DAYS.between(geburt, jetzt)
			}
			if (anzahlTage > 0) {
				sb.append(Constant.CRLF).append(Meldungen.FZ004(anzahlTage))
			}
			var anzahl = buchRep.getBuchLangAnzahl(daten, -1, null, prSerie, jetzt, null, null)
			sb.append(Constant.CRLF).append(Meldungen.FZ005(anzahl))
			var anzahl2 = buchRep.getBuchLangAnzahl(daten, -1, null, prSerie, jetzt, jetzt, null)
			sb.append(Constant.CRLF).append(Meldungen.FZ006(anzahl2))
			if (anzahl !== 0) {
				sb.append(Meldungen.FZ008(anzahl2 as double / anzahl * 100))
			}
			anzahl2 = buchRep.getBuchLangAnzahl(daten, -1, null, prSerie, jetzt, null, jetzt)
			sb.append(Constant.CRLF).append(Meldungen.FZ007(anzahl2))
			if (anzahl !== 0) {
				sb.append(Meldungen.FZ008(anzahl2 as double / anzahl * 100))
			}
			anzahl = buchRep.getBuchLangAnzahl(daten, SpracheEnum.ENGLISCH.intValue, null, null, jetzt, null, null)
			sb.append(Constant.CRLF).append(Meldungen.FZ009(anzahl))
			if (wk && !Global.nes(prSerie)) {
				anzahl = buchRep.getBuchLangAnzahl(daten, -1, prSerie, null, jetzt, null, null)
				sb.append(Constant.CRLF).append(Meldungen.FZ010(anzahl))
				anzahl2 = buchRep.getBuchLangAnzahl(daten, -1, prSerie, null, jetzt, jetzt, null)
				sb.append(Constant.CRLF).append(Meldungen.FZ011(anzahl2))
				if (anzahl !== 0) {
					sb.append(Meldungen.FZ008(anzahl2 as double / anzahl * 100))
				}
			}
			anzahl2 = buchRep.getBuchLangSeitenSumme(daten, -1, null, prSerie, jetzt, jetzt, null) as int
			sb.append(Constant.CRLF).append(Meldungen.FZ012(anzahl2))
			if (wk && !Global.nes(prSerie)) {
				anzahl2 = buchRep.getBuchLangSeitenSumme(daten, -1, prSerie, null, jetzt, jetzt, null) as int
				sb.append(Constant.CRLF).append(Meldungen.FZ013(anzahl2))
			}
			anzahl2 = buchRep.getBuchLangSeitenSumme(daten, -1, null, null, jetzt, jetzt, null) as int
			sb.append(Constant.CRLF).append(Meldungen.FZ014(anzahl2))
			if (anzahlTage > 0) {
				sb.append(Constant.CRLF).append(Meldungen.FZ015(anzahl2 as double / anzahlTage))
			}
			r.ergebnis = sb.toString
		} else if (nr == 3) {
			// Fahrradstatistik
			var summe = 0.0
			var summeJahr = 0.0
			val laenge = 18
			var LocalDateTime anfangMin = null
			var long anzahlTageMax = 0
			val jahresTage = 365.25
			var sb = new StringBuffer()
			var aktJahr = jetzt0.withDayOfYear(1)
			var fliste = fahrradRep.getFahrradLangListe(daten, null)
			for (vo : fliste) {
				var jetzt1 = jetzt0
				if (vo.typ == Global.strInt(FzFahrradTypEnum.WOECHENTLICH.toString)) {
					jetzt1 = Global.sonntag(jetzt1)
				}
				var km = standRep.getFahrradstandPeriodeKmSumme(daten, vo.uid, null, jetzt1)
				var kmJahr = standRep.getFahrradstandPeriodeKmSumme(daten, vo.uid, aktJahr, jetzt1)
				var long anzahlTage = 0
				var liste = standRep.getFahrradstandListe(daten, vo.uid, null, jetzt1.atStartOfDay, false, 1)
				var LocalDateTime anfang = null
				if (liste.size > 0) {
					anfang = liste.get(0).datum
					if (anfangMin === null || anfangMin.isAfter(anfang)) {
						anfangMin = anfang
					}
					anzahlTage = ChronoUnit.DAYS.between(anfang.toLocalDate, jetzt0)
					if (anzahlTage > anzahlTageMax) {
						anzahlTageMax = anzahlTage
					}
				}
				summe += km
				summeJahr += kmJahr
				if (sb.length > 0) {
					sb.append(Constant.CRLF)
				}
				sb.append(Meldungen.FZ016(Global.fixiereString(vo.bezeichnung + ": ", laenge, true, " "), km, kmJahr))
				if (anzahlTage > 0) {
					sb.append(Constant.CRLF).append(
						Meldungen.FZ017(
							Global.fixiereString(" " + Global.dateString0(anfang.toLocalDate) + ": ", laenge, true,
								" "), km / anzahlTage, km / anzahlTage * jahresTage))
				}
			}
			if (anzahlTageMax > 0) {
				sb.append(Constant.CRLF).append(
					Meldungen.FZ016(Global.fixiereString(Meldungen.FZ018 + ": ", laenge, true, " "), summe, summeJahr))
				sb.append(Constant.CRLF).append(
					Meldungen.FZ017(
						Global.fixiereString(" " + Global.dateString0(anfangMin.toLocalDate) + ": ", laenge, true, " "),
						summe / anzahlTageMax, summe / anzahlTageMax * jahresTage))
			}
			r.ergebnis = sb.toString
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<FzFahrradLang>> getFahrradListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = fahrradRep.getFahrradLangListe(daten, null)
		for (FzFahrradLang e : liste) {
			e.typBezeichnung = FzFahrradTypEnum.fromValue(Global.intStr(e.typ))?.toString2
			if (zusammengesetzt) {
				e.bezeichnung = Global.anhaengen(e.bezeichnung, " ", e.typBezeichnung)
			}
		}
		var r = new ServiceErgebnis<List<FzFahrradLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzFahrradLang> getFahrradLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<FzFahrradLang>(null)
		var l = fahrradRep.getFahrradLangListe(daten, uid)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<FzFahrrad> insertUpdateFahrrad(ServiceDaten daten, String uid, String bez, int typ) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzFahrrad>(null)
		if (Global.nes(bez)) {
			throw new MeldungException(Meldungen.FZ037)
		}
		// Typ prüfen
		if (FzFahrradTypEnum.fromValue(Global.intStr(typ)) === null) {
			throw new MeldungException(Meldungen.FZ038)
		}
		r.ergebnis = fahrradRep.iuFzFahrrad(daten, null, uid, bez, typ, null, null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteFahrrad(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = standRep.getFahrradstandListe(daten, uid, null, null, false, 0)
		for (FzFahrradstand e : liste) {
			standRep.delete(daten, e)
		}
		fahrradRep.delete(daten, new FzFahrradKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<FzFahrradstandLang>> getFahrradstandListe(ServiceDaten daten, String uid,
		String besch) {

		var liste = standRep.getFahrradstandLangListe(daten, uid, null, -1, besch)
		var r = new ServiceErgebnis<List<FzFahrradstandLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzFahrradstandLang> getFahrradstandLang(ServiceDaten daten, String uid,
		LocalDateTime datum, int nr) {

		var r = new ServiceErgebnis<FzFahrradstandLang>(null)
		var l = standRep.getFahrradstandLangListe(daten, uid, datum, nr, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	/**
	 * Speichern eines Fahrradstandes.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param fahrradUid Fahrrad-Nummer.
	 * @param dDatum Stichtag des Stands.
	 * @param nr0 Stand-Nummer wird neu bestimmt, falls sie 0 ist.
	 * @param dbZaehler Kilometerstand.
	 * @param dbPeriode Kilometer in der Periode (Tages- oder Wochen-km).
	 * @param dbSchnitt Durchschnitt-Kilometer in der Periode.
	 * @param besch0 Beschreibung.
	 * @return Benutzte Stand-Nummer.
	 */
	@Transaction
	override ServiceErgebnis<FzFahrradstand> insertUpdateFahrradstand(ServiceDaten daten, String fahrradUid,
		LocalDateTime datum, int nr0, double zaehler, double periode, double schnitt, String besch0) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var insert = nr0 < 0
		var dAktuell = datum
		var nr = if(insert) 0 else nr0
		var besch = besch0
		var FzFahrradstand voVorher = null
		var FzFahrradstand voNachher = null
		var zaehlerAktuell = zaehler
		var periodeAktuell = periode
		var zaehlerNull = false
		val protag = 10 + 1

		if (Global.nes(fahrradUid)) {
			throw new MeldungException(Meldungen.FZ019)
		}
		if (Global.compDouble(zaehlerAktuell, 0) < 0) {
			throw new MeldungException(Meldungen.FZ020)
		}
		if (Global.compDouble(periodeAktuell, 0) < 0) {
			throw new MeldungException(Meldungen.FZ021)
		}
		if (Global.compDouble(schnitt, 0) < 0) {
			throw new MeldungException(Meldungen.FZ022)
		}
		if (Global.compDouble(zaehlerAktuell, 0) == 0 && Global.compDouble(periodeAktuell, 0) == 0) {
			zaehlerNull = true
		}
		if (datum === null) {
			throw new MeldungException(Meldungen.FZ023)
		}
		var fzFahrrad = fahrradRep.get(daten, new FzFahrradKey(daten.mandantNr, fahrradUid))
		if (fzFahrrad === null) {
			throw new MeldungException(Meldungen.FZ024(fahrradUid))
		}
		var typ = FzFahrradTypEnum.fromValue(Global.intStr(fzFahrrad.typ))
		if (typ === null) {
			throw new MeldungException(Meldungen.FZ038)
		}
		if (insert && typ == FzFahrradTypEnum.WOECHENTLICH) { // insert neuen Stand
		// evtl. vorhandenen Satz in der gleichen Woche lesen
			var l = standRep.getFahrradstandListe(daten, fahrradUid, dAktuell, null, false, protag)
			if (l.size > 0) {
				insert = false
				var vo = l.get(0)
				dAktuell = vo.datum
				nr = vo.nr
				if (Global.nes(besch)) {
					besch = vo.beschreibung
				}
			}
		}
		var liste = standRep.getFahrradstandListe(daten, fahrradUid, null, dAktuell, true, protag) // getMaxVorher
		if (Global.listLaenge(liste) >= 1) {
			var i = 0
			do {
				var fzFahrradstand = liste.get(i)
				if (!dAktuell.equals(fzFahrradstand.datum) ||
					(dAktuell.equals(fzFahrradstand.datum) && nr > fzFahrradstand.nr)) {
					voVorher = fzFahrradstand
				}
				i++
			} while (voVorher === null && Global.listLaenge(liste) > i)
		}
		liste = standRep.getFahrradstandListe(daten, fahrradUid, dAktuell, null, false, protag) // getMinNachher
		if (Global.listLaenge(liste) >= 1) {
			var i = 0
			do {
				var fzFahrradstand = liste.get(i)
				if (!dAktuell.equals(fzFahrradstand.datum) ||
					(dAktuell.equals(fzFahrradstand.datum) && nr < fzFahrradstand.nr)) {
					voNachher = fzFahrradstand
				}
				i++
			} while (voNachher === null && Global.listLaenge(liste) > i)
		}
		var zaehlerVorher = 0.0
		var zaehlerNachher = 0.0
		var periodeNachher = 0.0
		if (voVorher !== null) { // vorherNr > 0
			if (!zaehlerNull) {
				zaehlerVorher = voVorher.zaehlerKm
				if (Global.compDouble(periodeAktuell, 0) > 0) {
					zaehlerAktuell = zaehlerVorher + periodeAktuell
				} else {
					periodeAktuell = zaehlerAktuell - zaehlerVorher
					if (Global.compDouble(periodeAktuell, 0) < 0) {
						throw new MeldungException(Meldungen.FZ025(zaehlerVorher))
					}
				}
			}
		}
		if (voNachher !== null) { // nachherNr > 0
			if (insert) {
				if (typ == FzFahrradTypEnum.WOECHENTLICH) {
					nr = voNachher.nr
					dAktuell = voNachher.datum
				} else {
					throw new MeldungException(Meldungen.FZ026)
				}
			}
			if (!zaehlerNull) {
				zaehlerNachher = voNachher.zaehlerKm
				periodeNachher = voNachher.periodeKm
			}
		}
		if (voNachher !== null /* nachherNr > 0 */ && zaehlerNull) {
			throw new MeldungException(Meldungen.FZ027)
		}
		if (!zaehlerNull) {
			if (Global.compDouble(zaehlerAktuell, periodeAktuell) < 0) {
				zaehlerAktuell = periodeAktuell
			}
			if (voVorher === null /* vorherNr <= 0 */ && Global.compDouble(zaehlerAktuell, periodeAktuell) > 0) {
				periodeAktuell = zaehlerAktuell
			}
		}
		var neueNr = true
		if (insert && typ == FzFahrradTypEnum.WOECHENTLICH) { // insert neuen Stand
			nr = 0
			neueNr = false
			if (voVorher !== null /* vorherNr > 0 */ ) {
				var woche = voVorher.datum.plusDays(7)
				while (woche.isBefore(dAktuell)) {
					standRep.iuFzFahrradstand(daten, null, fahrradUid, woche, 0, zaehlerVorher, 0, 0, Meldungen.FZ028,
						null, null, null, null)
					woche = woche.plusDays(7)
				}
				dAktuell = woche
			}
		}
		var vo = standRep.get(daten, new FzFahrradstandKey(daten.mandantNr, fahrradUid, dAktuell, nr))
		if (vo === null) {
			// Autowert
			if (nr > 0 && neueNr) {
				throw new MeldungException(Meldungen.FZ029(nr))
			}
			var l = standRep.getFahrradstandListe(daten, fahrradUid, dAktuell, dAktuell, true, 1)
			nr = 0
			if (l.size > 0) {
				nr = l.get(0).nr + 1
			}
		}
		var e = standRep.iuFzFahrradstand(daten, null, fahrradUid, dAktuell, nr, zaehlerAktuell, periodeAktuell,
			schnitt, besch, null, null, null, null)
		if (voNachher !== null /* nachherNr > 0 */ && !(dAktuell.equals(voNachher.datum) && nr == voNachher.nr) &&
			Global.compDouble(periodeNachher, zaehlerNachher - zaehlerAktuell) !== 0) {
			if (Global.compDouble(0, zaehlerNachher - zaehlerAktuell) > 0) {
				throw new MeldungException(Meldungen.FZ030)
			}
			var voNachherU = new FzFahrradstandUpdate(voNachher)
			voNachherU.setPeriodeKm(zaehlerNachher - zaehlerAktuell)
			if (voNachherU.isChanged) {
				voNachherU.machGeaendert(daten.jetzt, daten.benutzerId)
				standRep.update(daten, voNachherU)
			}
		}
		var r = new ServiceErgebnis<FzFahrradstand>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteFahrradstand(ServiceDaten daten, String fuid, LocalDateTime datum, int nr) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var key = new FzFahrradstandKey(daten.mandantNr, fuid, datum, nr)
		var fzFahrradstand = standRep.get(daten, key)
		if (fzFahrradstand === null) {
			throw new MeldungException(Meldungen.FZ029(nr))
		}
		var liste = standRep.getFahrradstandListe(daten, fuid, datum, null, false, 0)
		for (FzFahrradstand stand : liste) {
			if (stand.datum.isAfter(key.datum) || stand.nr > key.nr) {
				throw new MeldungException(Meldungen.FZ031)
			}
		}
		standRep.delete(daten, key)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<FzBuchautor>> getAutorListe(ServiceDaten daten, boolean zusammengesetzt,
		String name) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = autorRep.getBuchautorListe(daten, name)
		if (zusammengesetzt) {
			for (FzBuchautor e : liste) {
				e.name = Global.anhaengen(e.name, ", ", e.vorname)
			}
		}
		var r = new ServiceErgebnis<List<FzBuchautor>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzBuchautor> getAutor(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzBuchautor>(autorRep.get(daten, new FzBuchautorKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<FzBuchautor> insertUpdateAutor(ServiceDaten daten, String uid, String name,
		String vorname) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzBuchautor>(null)
		if (Global.nes(name)) {
			throw new MeldungException(Meldungen.FZ032)
		}
		r.ergebnis = autorRep.iuFzBuchautor(daten, null, uid, name, vorname, null, null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteAutor(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = buchRep.getBuchLangListe(daten, null, uid, null, null, 0, 1)
		if (liste.size > 0) {
			throw new MeldungException(Meldungen.FZ039)
		}
		autorRep.delete(daten, new FzBuchautorKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<FzBuchserie>> getSerieListe(ServiceDaten daten, String name) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = serieRep.getBuchserieListe(daten, name)
		var r = new ServiceErgebnis<List<FzBuchserie>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzBuchserie> getSerie(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzBuchserie>(serieRep.get(daten, new FzBuchserieKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<FzBuchserie> insertUpdateSerie(ServiceDaten daten, String uid, String name) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzBuchserie>(null)
		if (Global.nes(name)) {
			throw new MeldungException(Meldungen.FZ033)
		}
		r.ergebnis = serieRep.iuFzBuchserie(daten, null, uid, name, null, null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteSerie(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = buchRep.getBuchLangListe(daten, null, null, uid, null, 0, 1)
		if (liste.size > 0) {
			throw new MeldungException(Meldungen.FZ040)
		}
		serieRep.delete(daten, new FzBuchserieKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<FzBuchLang>> getBuchListe(ServiceDaten daten, boolean zusammengesetzt,
		String autorUid, String serieUid, String buchUid, String name) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = buchRep.getBuchLangListe(daten, null, autorUid, serieUid, name, 0, 0)
		if (zusammengesetzt) {
			for (FzBuchLang e : liste) {
				e.autorName = Global.anhaengen(e.autorName, ", ", e.autorVorname)
			}
		}
		var r = new ServiceErgebnis<List<FzBuchLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<FzBuchLang> getBuchLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<FzBuchLang>(null)
		var l = buchRep.getBuchLangListe(daten, uid, null, null, null, 0, 1)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<FzBuch> insertUpdateBuch(ServiceDaten daten, String uid, String autorUid, String serieUid,
		int seriennr, String titel, int seit, String sp, boolean besitz, LocalDate lesedatum, LocalDate hoerdatum) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<FzBuch>(null)
		if (Global.nes(titel)) {
			throw new MeldungException(Meldungen.FZ041)
		}
		if (Global.nes(autorUid)) {
			throw new MeldungException(Meldungen.FZ042)
		}
		if (Global.nes(serieUid)) {
			throw new MeldungException(Meldungen.FZ043)
		}
		// Sprache prüfen
		SpracheEnum.fromValue(sp)
		var seriennummer = seriennr
		var seiten = seit
		if (Global.nes(uid) && !Global.nes(serieUid)) {
			var keineSerie = false
			var serie = serieRep.get(daten, new FzBuchserieKey(daten.mandantNr, serieUid))
			if (serie !== null && serie.name.toLowerCase.endsWith(Meldungen.FZ034.toLowerCase)) {
				keineSerie = true
				seriennummer = 0
			}
			if (!keineSerie && seriennummer > 0) {
				var bliste = buchRep.getBuchLangListe(daten, null, null, serieUid, null, seriennummer, 0)
				if (bliste.size > 0) {
					// Seriennummer schon vorhanden.
					seriennummer = 0
				}
			}
			if (!keineSerie && (seriennummer <= 0 || seiten <= 0)) {
				var bliste = buchRep.getBuchLangListe(daten, null, null, serieUid, null, 0, 1)
				if (bliste.size <= 0) {
					if (seriennummer <= 0) {
						seriennummer = 1
					}
					if (seiten <= 0) {
						seiten = 1
					}
				} else {
					if (seriennummer <= 0) {
						seriennummer = bliste.get(0).seriennummer + 1
					}
					if (seiten <= 0) {
						seiten = bliste.get(0).seiten
					}
				}
			}
		}
		r.ergebnis = buchRep.iuFzBuch(daten, null, uid, autorUid, serieUid, seriennummer, titel, Math.abs(seiten),
			Global.strInt(sp), null, null, null, null)
		statusRep.iuFzBuchstatus(daten, null, r.ergebnis.uid, besitz, lesedatum, hoerdatum, null, null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteBuch(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		statusRep.delete(daten, new FzBuchstatusKey(daten.mandantNr, uid))
		buchRep.delete(daten, new FzBuchKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}
}

package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.Benutzer
import de.cwkuehl.jhh6.api.dto.BenutzerKey
import de.cwkuehl.jhh6.api.dto.BenutzerLang
import de.cwkuehl.jhh6.api.dto.BenutzerUpdate
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaEinstellungKey
import de.cwkuehl.jhh6.api.dto.MaEinstellungUpdate
import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.dto.MaMandantKey
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.MaParameterUpdate
import de.cwkuehl.jhh6.api.dto.VmKonto
import de.cwkuehl.jhh6.api.dto.VmKontoKey
import de.cwkuehl.jhh6.api.dto.ZeinstellungKey
import de.cwkuehl.jhh6.api.enums.BerechtigungEnum
import de.cwkuehl.jhh6.api.enums.KontoartEnum
import de.cwkuehl.jhh6.api.enums.KontokennzeichenEnum
import de.cwkuehl.jhh6.api.enums.VmKontoSchluesselEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.base.SqlBuilder
import de.cwkuehl.jhh6.server.db.DbInit
import de.cwkuehl.jhh6.server.rep.impl.BenutzerRep
import de.cwkuehl.jhh6.server.rep.impl.HhKontoRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungLeistungRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungRep
import de.cwkuehl.jhh6.server.rep.impl.MaEinstellungRep
import de.cwkuehl.jhh6.server.rep.impl.MaMandantRep
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.VmKontoRep
import de.cwkuehl.jhh6.server.rep.impl.ZeinstellungRep
import java.time.LocalDate
import java.util.List

import static de.cwkuehl.jhh6.api.global.Constant.*
import static de.cwkuehl.jhh6.api.global.Global.*

@Service
class AnmeldungService {

	@RepositoryRef BenutzerRep benutzerRep
	@RepositoryRef HhKontoRep kontoRep
	@RepositoryRef HpBehandlungRep behandlungRep
	@RepositoryRef HpBehandlungLeistungRep behleistRep
	@RepositoryRef MaEinstellungRep maEinstellungRep
	@RepositoryRef MaMandantRep mandantRep
	@RepositoryRef MaParameterRep maParameterRep
	@RepositoryRef VmKontoRep vmkontoRep
	@RepositoryRef ZeinstellungRep zeinstellungRep

	/** Abmelden. */
	@Transaction(false)
	override void abmelden(ServiceDaten daten) {
		// testService.getFunktion(daten, "")
		// var key = new AdPersonKey
		// key.mandantNr = 1
		// val p = adPersonRep.get(daten, key)
		// if (p != null)
		// machNichts
	}

	@Transaction
	override ServiceErgebnis<Void> aendern(ServiceDaten daten, int mandantNr, String benutzerId, String passwortAlt,
		String passwortNeu, boolean speichern) {

		if (daten.mandantNr < 0) {
			// Die Anmeldedaten sind ungültig. Mandant ungültig!
			throw new MeldungException(Meldungen.M1003)
		}
		if (Global.nes(daten.benutzerId)) {
			// Die Anmeldedaten sind ungültig. Benutzer ungültig!
			throw new MeldungException(Meldungen.M1003)
		}

		if (Global.nes(passwortNeu)) {
			// Das neue Kennwort darf nicht leer sein.
			throw new MeldungException(Meldungen.M1005)
		}
		// getBerechService.pruefeBerechtigungAktuellerBenutzerOderAdmin(daten, mandantNr, benutzerId)
		var benutzerKey = new BenutzerKey(mandantNr, benutzerId)
		var benutzer = benutzerRep.get(daten, benutzerKey)
		if (benutzer === null) {
			// Die Anmeldedaten sind ungültig. Der Benutzer wurde nicht gefunden!
			throw new MeldungException(Meldungen.M1003)
		}
		if (Global.compString(benutzer.passwort, passwortAlt) != 0) {
			// Die Anmeldedaten sind ungültig. Altes Kennwort ist falsch!
			throw new MeldungException(Meldungen.M1003)
		}
		var benutzerU = new BenutzerUpdate(benutzer)
		benutzerU.setPasswort(passwortNeu)
		// System.out.println("Ist  " + benutzer.toBuffer(null))
		benutzerRep.update(daten, benutzerU)
		Speichern(daten, mandantNr, benutzerId, speichern)
		var r = new ServiceErgebnis<Void>
		return r
	}

	/** Anmelden */
	@Transaction
	override ServiceErgebnis<Void> anmelden(ServiceDaten daten, String kennwort, boolean speichern) {

		if (daten.mandantNr < 0) {
			// Die Anmeldedaten sind ungültig. Mandant ungültig!
			throw new MeldungException(Meldungen.M1003)
		}
		if (Global.nes(daten.benutzerId)) {
			// Die Anmeldedaten sind ungültig. Benutzer ungültig!
			throw new MeldungException(Meldungen.M1003)
		}

		var r = new ServiceErgebnis<Void>
		var benutzerKey = new BenutzerKey(daten.mandantNr, daten.benutzerId)
		var Benutzer benutzer = null

		benutzer = benutzerRep.get(daten, benutzerKey)
		if (benutzer !== null) {
			// Benutzer vorhanden.
			log.debug(Meldungen.M1004(daten.mandantNr, daten.benutzerId))
			var wert = getOhneAnmelden(daten)
			if (!Global.nes(wert) && wert.equals(daten.benutzerId)) {
				// Anmeldung ohne Kennwort
				Speichern(daten, daten.mandantNr, daten.benutzerId, speichern)
				return r
			}
			if (Global.nes(benutzer.passwort) && Global.nes(kennwort)) {
				// Anmeldung mit leerem Kennwort
				Speichern(daten, daten.mandantNr, daten.benutzerId, speichern)
				return r
			}
			if (!Global.nes(benutzer.passwort) && !Global.nes(kennwort)) {
				// Anmeldung mit Kennwort
				if (benutzer.passwort.equals(kennwort)) {
					Speichern(daten, daten.mandantNr, daten.benutzerId, speichern)
					return r
				}
			}
		}

		// Anzumeldenden Benutzer als Benutzer eintragen
		var liste = benutzerRep.getListe(daten, daten.mandantNr, null, null)
		if (Global.arrayLaenge(liste) == 1 && "Benutzer-ID".equals(liste.get(0).benutzerId)) {
			var benutzerU = new BenutzerUpdate(liste.get(0))
			benutzerU.setBenutzerId(daten.benutzerId)
			benutzerU.setPasswort(kennwort)
			benutzerU.machGeaendert(daten.jetzt, daten.benutzerId)
			// System.out.println("Ist  " + benutzer.toBuffer(null))
			benutzerRep.update(daten, benutzerU)
			Speichern(daten, daten.mandantNr, daten.benutzerId, speichern)
			return r
		}

		// Die Anmeldedaten sind ungültig. Mandant, Benutzer oder Kennwort ungültig!
		throw new MeldungException(Meldungen.M1003)
	}

	@Transaction(true)
	override ServiceErgebnis<Void> initDatenbank(ServiceDaten daten) {

		var r = new ServiceErgebnis<Void>(null)
		var dbInit = new DbInit

		// Datenbank aktualisieren
		dbInit.machEs(daten, dbArt, zeinstellungRep, behandlungRep, behleistRep)

		var key = new ZeinstellungKey(Constant.EINST_DB_INIT)
		var e = zeinstellungRep.get(daten, key)
		if (e === null || Global.strInt(e.wert) > 0) {
			zeinstellungRep.iuZeinstellung(daten, null, Constant.EINST_DB_INIT, "0", null, null, null, null)
		}
		return r
	}

	def private void initMandant(ServiceDaten daten) {

		var e = maEinstellungRep.get(daten, new MaEinstellungKey(daten.mandantNr, Constant.EINST_MA_REPLIKATION_UID))
		if (e === null || Global.nes(e.wert)) {
			maEinstellungRep.iuMaEinstellung(daten, null, Constant.EINST_MA_REPLIKATION_UID, Global.UID, null, null,
				null, null)
		}
	}

	@Transaction(true)
	override ServiceErgebnis<Boolean> istOhneAnmelden(ServiceDaten daten) {

		var r = new ServiceErgebnis<Boolean>(false)
		// getAllgemeinService.initDatenbank
		var wert = getOhneAnmelden(daten)
		if (!nes(wert) && !nes(daten.benutzerId)) {
			r.ergebnis = wert.equals(daten.benutzerId)
			if (r.ergebnis) {
				initMandant(daten)
			}
		}
		return r
	}

	def private String getOhneAnmelden(ServiceDaten daten) {

		var maEinstellungKey = new MaEinstellungKey(daten.mandantNr, Constant.EINST_MA_OHNE_ANMELDUNG)
		var maEinstellung = maEinstellungRep.get(daten, maEinstellungKey)
		if (maEinstellung !== null) {
			// throw new NullPointerException("Darum")
			return maEinstellung.wert
		}
		return null
	}

	def private void Speichern(ServiceDaten daten, int mandantNr, String benutzerId, boolean speichern) {

		var MaEinstellung maEinstellung = null
		var String wert = null

		maEinstellung = maEinstellungRep.get(daten, new MaEinstellungKey(mandantNr, EINST_MA_OHNE_ANMELDUNG))
		if (maEinstellung === null) {
			maEinstellung = new MaEinstellung
			maEinstellung.setMandantNr(mandantNr)
			maEinstellung.setSchluessel(EINST_MA_OHNE_ANMELDUNG)
			maEinstellung.setWert("")
			maEinstellungRep.insert(daten, maEinstellung)
		}
		var maEinstellungU = new MaEinstellungUpdate(maEinstellung)
		wert = maEinstellung.wert
		if (!speichern && !Global.nes(wert) && wert.equals(benutzerId)) {
			maEinstellungU.setWert("")
			// System.out.println("Ist  " + maEinstellung.toBuffer(null))
			maEinstellungRep.update(daten, maEinstellungU)
		}
		if (speichern && (Global.nes(wert) || !wert.equals(benutzerId))) {
			maEinstellungU.setWert(benutzerId)
			maEinstellungRep.update(daten, maEinstellungU)
		}
		initMandant(daten)
	}

	def private int getParameterArt(String schluessel) {

		if (Global.nes(schluessel)) {
			return 0 // unbekannt
		}
		if (schluessel == Constant.EINST_DB_INIT || schluessel == Constant.EINST_DB_VERSION ||
			schluessel == Constant.EINST_DATENBANK) {
			return 1 // Tabelle ZEINSTSTELLUNG
		}
		return 2 // Tabelle MA_PARAMETER
	}

	@Transaction(true)
	override ServiceErgebnis<MaParameter> getParameter(ServiceDaten daten, int mandantNr, String schluessel) {

		var r = new ServiceErgebnis<MaParameter>(null)
		var art = getParameterArt(schluessel)
		if (art == 1) {
			var key = new ZeinstellungKey(schluessel)
			var e = zeinstellungRep.get(daten, key)
			if (e !== null) {
				var p = new MaParameter
				p.mandantNr = 0
				p.schluessel = schluessel
				p.wert = e.wert
				p.angelegtAm = e.angelegtAm
				p.angelegtVon = e.angelegtVon
				p.geaendertAm = e.geaendertAm
				p.geaendertVon = e.geaendertVon
				r.ergebnis = p
			}
		} else if (art == 2) {
			var key = new MaParameterKey(mandantNr, schluessel)
			r.ergebnis = maParameterRep.get(daten, key)
		}
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> setParameter(ServiceDaten daten, int mandantNr, String schluessel, String wert) {

		var r = new ServiceErgebnis<Void>(null)
		var art = getParameterArt(schluessel)
		if (art == 1) {
			zeinstellungRep.iuZeinstellung(daten, null, schluessel, wert, null, null, null, null)
		} else if (art == 2) {
			// maParameterRep.iuMaParameter(daten, null, schluessel, wert, null, null, null, null)
			var vo2 = maParameterRep.get(daten, new MaParameterKey(mandantNr, schluessel))
			if (vo2 === null) {
				var vo = new MaParameter
				vo.mandantNr = mandantNr
				vo.schluessel = schluessel
				vo.wert = wert
				vo.replikationUid = Global.UID
				maParameterRep.insert(daten, vo, true)
			} else {
				var voU = new MaParameterUpdate(vo2)
				voU.mandantNr = mandantNr
				voU.schluessel = schluessel
				voU.wert = wert
				if (nes(voU.replikationUid)) {
					voU.replikationUid = Global.UID
				}
				maParameterRep.update(daten, voU, true)
			}
		}
		return r
	}

	def private BerechtigungEnum getBerechtigung(ServiceDaten daten, int mandantNr, String benutzerId) {

		var b = benutzerRep.get(daten, new BenutzerKey(mandantNr, benutzerId))
		if (b === null) {
			return BerechtigungEnum.KEINE
		}
		return BerechtigungEnum.fromIntValue(b.berechtigung)
	}

	def private void pruefeBerechtigungAlleMandanten(ServiceDaten daten, int mandantNr) {

		var b = getBerechtigung(daten, daten.mandantNr, daten.benutzerId)
		if (b == BerechtigungEnum.ALLES) {
			return
		}
		throw new Exception("Keine Alles-Berechtigung.")
	}

	def private void pruefeBerechtigungAdmin(ServiceDaten daten, int mandantNr) {

		var b = getBerechtigung(daten, daten.mandantNr, daten.benutzerId)
		if (b == BerechtigungEnum.ALLES || (b == BerechtigungEnum.ADMIN && daten.mandantNr == mandantNr)) {
			return
		}
		throw new Exception("Keine Admin-Berechtigung.")
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaMandant>> getMandantListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var b = getBerechtigung(daten, daten.mandantNr, daten.benutzerId).intValue
		var m = if (b == BerechtigungEnum.ALLES.intValue)
				null
			else if (b == BerechtigungEnum.ADMIN.intValue)
				new Integer(daten.mandantNr)
			else
				new Integer(-1)
		var liste = mandantRep.getMandantListe(daten, m)
		var r = new ServiceErgebnis<List<MaMandant>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<MaMandant> getMandant(ServiceDaten daten, int nr) {

		var r = new ServiceErgebnis<MaMandant>(mandantRep.get(daten, new MaMandantKey(nr)))
		return r
	}

	def private void insertInitialKonten(ServiceDaten daten, int mandantNr) {

		var where = new SqlBuilder
		where.append(null, HhKonto.KZ_NAME, "=", KontokennzeichenEnum.EIGENKAPITEL.toString, null)
		var kliste = kontoRep.getListe(daten, mandantNr, where, null)
		var ek = if(kliste.size > 0) kliste.get(0) else null
		if (ek === null) {
			var hh = new HhKonto
			hh.mandantNr = mandantNr
			hh.uid = Global.UID
			hh.art = KontoartEnum.PASSIVKONTO.toString
			hh.kz = KontokennzeichenEnum.EIGENKAPITEL.toString
			hh.name = "Eigenkapital"
			hh.gueltigVon = null
			hh.gueltigBis = null
			hh.periodeVon = -1
			hh.periodeBis = Constant.MAX_PERIODE
			hh.angelegtAm = daten.jetzt
			hh.angelegtVon = daten.benutzerId
			hh.sortierung = Global.fixiereString(hh.name, HhKonto.SORTIERUNG_LAENGE, true, " ")
			kontoRep.insert(daten, hh)
			ek = hh
		}
		where = new SqlBuilder
		where.append(null, HhKonto.KZ_NAME, "=", KontokennzeichenEnum.GEWINN_VERLUST.toString, null)
		kliste = kontoRep.getListe(daten, mandantNr, where, null)
		var gv = if(kliste.size > 0) kliste.get(0) else null
		if (gv === null) {
			var hh = new HhKonto
			hh.mandantNr = mandantNr
			hh.uid = Global.UID
			hh.art = KontoartEnum.ERTRAGSKONTO.toString
			hh.kz = KontokennzeichenEnum.GEWINN_VERLUST.toString
			hh.name = "Gewinn/Verlust"
			hh.setGueltigVon(null)
			hh.gueltigVon = null
			hh.gueltigBis = null
			hh.periodeVon = -1
			hh.periodeBis = Constant.MAX_PERIODE
			hh.angelegtAm = daten.jetzt
			hh.angelegtVon = daten.benutzerId
			hh.sortierung = Global.fixiereString(hh.name, HhKonto.SORTIERUNG_LAENGE, true, " ")
			kontoRep.insert(daten, hh)
			gv = hh
		}
		if (vmkontoRep.get(daten, new VmKontoKey(mandantNr, ek.uid)) === null) {
			var vm = new VmKonto
			vm.mandantNr = mandantNr
			vm.uid = ek.uid
			vm.schluessel = VmKontoSchluesselEnum.KP301_EK.toString
			vm.angelegtAm = daten.jetzt
			vm.angelegtVon = daten.benutzerId
			vmkontoRep.insert(daten, vm)
		}
		if (vmkontoRep.get(daten, new VmKontoKey(mandantNr, gv.uid)) === null) {
			var vm = new VmKonto
			vm.mandantNr = mandantNr
			vm.uid = gv.uid
			vm.schluessel = VmKontoSchluesselEnum.KP60_GV.toString
			vm.angelegtAm = daten.jetzt
			vm.angelegtVon = daten.benutzerId
			vmkontoRep.insert(daten, vm)
		}
	}

	@Transaction(true)
	override ServiceErgebnis<MaMandant> insertUpdateMandant(ServiceDaten daten, int nr, String beschreibung,
		boolean insert) {

		pruefeBerechtigungAdmin(daten, nr)
		if (Global.nes(beschreibung)) {
			throw new MeldungException("Die Beschreibung darf nicht leer sein.")
		}
		var mnr = nr
		if (insert && mnr <= 0) {
			var liste = mandantRep.getMandantListe(daten, null)
			mnr = if(liste.size <= 0) Constant.AW_MIN else liste.get(liste.size - 1).nr + 1
		}
		var e = mandantRep.iuMaMandant(daten, null, mnr, beschreibung, null, null, null, null)
		if (insert) {
			if (benutzerRep.get(daten, new BenutzerKey(mnr, "Benutzer-ID")) === null) {
				// einen Benutzer anlegen
				var b = new Benutzer
				b.mandantNr = mnr
				b.aktPeriode = 0
				b.angelegtVon = daten.benutzerId
				b.angelegtAm = daten.jetzt
				b.benutzerId = "Benutzer-ID"
				b.passwort = null
				b.berechtigung = BerechtigungEnum.ADMIN.intValue
				b.personNr = 1
				benutzerRep.insert(daten, b)
			}
			// Mandanten-Einstellungen anlegen
			// maEinstellungRep.iuMaEinstellung(daten, mnr, Constant.EINST_MA_MANDANT_INIT, "1")
			// maEinstellungRep.iuMaEinstellung(daten, mnr, Constant.EINST_MA_REPLIKATION_UID, null)
			// getMaEinstellungDao.iuMaEinstellung(daten, mnr, Constant.EINST_MA_REPLIKATION_ROLLE, null)
			// getMaEinstellungDao.iuMaEinstellung(daten, mnr, Constant.EINST_MA_SERVER_UID, null)
			// Konten anlegen
			insertInitialKonten(daten, mnr)

			// Einstellungen anlegen
			zeinstellungRep.iuZeinstellung(daten, null, Constant.EINST_DB_INIT, "1", null, null, null, null)
		}
		var r = new ServiceErgebnis<MaMandant>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteMandant(ServiceDaten daten, int nr) {

		pruefeBerechtigungAlleMandanten(daten, nr)
		if (nr == daten.mandantNr) {
			// Der aktuelle Mandant kann nicht gelöscht werden.
			throw new MeldungException(Meldungen.M2046)
		}
		// TODO Mandant in allen Tabellen löschen
		// Ztabelle[] tabVo = null
		// String strTab = null
		// tabVo = ztabelleDao.getMandantenListe(null)
		// for (int i = 0; tabVo != null && i < tabVo.length; i++) {
		// strTab = tabVo[i].getName
		// if (allgemeinDao.countMandantTabelle(nr, strTab) > 0) {
		// allgemeinDao.deleteMandantTabelle(nr, strTab)
		// }
		// }
		mandantRep.delete(daten, new MaMandantKey(nr))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<BenutzerLang>> getBenutzerListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var b = getBerechtigung(daten, daten.mandantNr, daten.benutzerId).intValue
		var name = if (b >= BerechtigungEnum.ADMIN.intValue)
				null
			else if (b == BerechtigungEnum.BENUTZER.intValue)
				daten.benutzerId
			else
				"###"
		var liste = benutzerRep.getBenutzerLangListe(daten, 0, name, 0)
		if (zusammengesetzt) {
			for (BenutzerLang e : liste) {
				e.passwort = "oooooo"
				e.rechte = BerechtigungEnum.fromIntValue(e.berechtigung).toString2
			}
		}
		var r = new ServiceErgebnis<List<BenutzerLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<BenutzerLang> getBenutzerLang(ServiceDaten daten, int nr) {

		var r = new ServiceErgebnis<BenutzerLang>(null)
		var l = benutzerRep.getBenutzerLangListe(daten, nr, null, 0)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Benutzer> insertUpdateBenutzer(ServiceDaten daten, String benutzerId, String passwort,
		int berechtigung, int personNr, LocalDate geburt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(benutzerId)) {
			throw new MeldungException(Meldungen.M2042)
		}
		if (getBerechtigung(daten, daten.mandantNr, daten.benutzerId).intValue < berechtigung) {
			throw new MeldungException(Meldungen.M2043)
		}
		var enr = personNr
		var liste = benutzerRep.getBenutzerLangListe(daten, 0, benutzerId, enr)
		if (liste.size > 0) {
			throw new MeldungException(Meldungen.M2044)
		}
		if (enr <= 0) {
			enr = Constant.AW_MIN
			liste = benutzerRep.getBenutzerLangListe(daten, 0, null, 0)
			for (BenutzerLang e : liste) {
				if (e.personNr >= enr) {
					enr = e.personNr + 1
				}
			}
		}
		var e = benutzerRep.iuBenutzer(daten, null, benutzerId, passwort, berechtigung, 0, enr, geburt, null, null,
			null, null)
		var r = new ServiceErgebnis<Benutzer>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteBenutzer(ServiceDaten daten, String id) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		benutzerRep.delete(daten, new BenutzerKey(daten.mandantNr, id))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaParameter>> getParameterListe(ServiceDaten daten, String schluessel) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = maParameterRep.getParameterListe(daten, schluessel)
		var r = new ServiceErgebnis<List<MaParameter>>(liste)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> updateParameterListe(ServiceDaten daten, List<MaParameter> liste) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (liste !== null) {
			for (MaParameter p : liste) {
				maParameterRep.iuMaParameter(daten, null, p.schluessel, p.wert, null, null, null, null)
			}
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}
}

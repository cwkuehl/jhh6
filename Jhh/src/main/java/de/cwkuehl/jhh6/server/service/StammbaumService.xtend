package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.SbEreignis
import de.cwkuehl.jhh6.api.dto.SbFamilie
import de.cwkuehl.jhh6.api.dto.SbFamilieKey
import de.cwkuehl.jhh6.api.dto.SbFamilieLang
import de.cwkuehl.jhh6.api.dto.SbFamilieStatus
import de.cwkuehl.jhh6.api.dto.SbFamilieUpdate
import de.cwkuehl.jhh6.api.dto.SbKind
import de.cwkuehl.jhh6.api.dto.SbPerson
import de.cwkuehl.jhh6.api.dto.SbPersonKey
import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.dto.SbQuelle
import de.cwkuehl.jhh6.api.dto.SbQuelleKey
import de.cwkuehl.jhh6.api.enums.GedcomEreignis
import de.cwkuehl.jhh6.api.enums.GeschlechtEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.global.Parameter
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.impl.ByteDatenRep
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.SbEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.SbFamilieRep
import de.cwkuehl.jhh6.server.rep.impl.SbKindRep
import de.cwkuehl.jhh6.server.rep.impl.SbPersonRep
import de.cwkuehl.jhh6.server.rep.impl.SbQuelleRep
import de.cwkuehl.jhh6.server.service.impl.SbDatum
import de.cwkuehl.jhh6.server.service.impl.SbZeitangabe
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Vector
import java.util.regex.Matcher
import java.util.regex.Pattern

@Service
class StammbaumService {

	@RepositoryRef ByteDatenRep byteRep
	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef SbEreignisRep ereignisRep
	@RepositoryRef SbFamilieRep familieRep
	@RepositoryRef SbKindRep kindRep
	@RepositoryRef SbPersonRep personRep
	@RepositoryRef SbQuelleRep quelleRep

	@Transaction(false)
	override ServiceErgebnis<List<SbPersonLang>> getPersonListe(ServiceDaten daten, boolean zusammengesetzt,
		boolean ereignis, String nachname, String vorname, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = personRep.getPersonLangListe(daten, null, nachname, vorname, null, null, null)
		if (zusammengesetzt || ereignis) {
			for (SbPersonLang e : liste) {
				if (zusammengesetzt) {
					e.geburtsname = Global.ahnString(e.uid, e.geburtsname, e.vorname, false, false)
				}
				if (ereignis) {
					var s = getEreignisStringIntern(daten, e.uid, null, GedcomEreignis.eGEBURT.wert)
					if (s !== null) {
						e.geburtsdatum = s.get(0)
					}
					s = getEreignisStringIntern(daten, e.uid, null, GedcomEreignis.eTOD.wert)
					if (s !== null) {
						e.todesdatum = s.get(0)
					}
				}
			}
		}
		var r = new ServiceErgebnis<List<SbPersonLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<SbPersonLang> getPersonLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<SbPersonLang>(null)
		var l = personRep.getPersonLangListe(daten, uid, null, null, null, null, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<SbPerson> insertUpdatePerson(ServiceDaten daten, String uid, String name, String vorname,
		String gebname, String geschlecht, String titel, String konfession, String bemerkung, String quid, int status1,
		int status2, int status3, String geburtsdatum, String geburtsort, String geburtsbem, String geburtsQuelle,
		String taufdatum, String taufort, String taufbem, String taufQuelle, String todesdatum, String todesort,
		String todesbem, String todesQuelle, String begraebnisdatum, String begraebnisort, String begraebnisbem,
		String begraebnisQuelle, String gatteNeu, String vaterUidNeu, String mutterUidNeu, List<ByteDaten> byteliste) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(gebname)) {
			throw new MeldungException(Meldungen::SB001)
		}
		if (!Global.nes(gatteNeu) && (!Global.nes(vaterUidNeu) || !Global.nes(mutterUidNeu))) {
			throw new MeldungException(Meldungen::SB002)
		}
		// Typ prüfen
		var gesch = n(geschlecht)
		var g = GeschlechtEnum.fromValue(gesch)
		if (g == GeschlechtEnum.MANN) {
			gesch = GeschlechtEnum.MAENNLICH.toString
		} else if (g == GeschlechtEnum.FRAU) {
			gesch = GeschlechtEnum.WEIBLICH.toString
		}
		var name2 = name
		if (Global.nes(name2)) {
			name2 = gebname
		}
		var e = personRep.iuSbPerson(daten, null, uid, n(name2), n(vorname), n(gebname), n(gesch), n(titel),
			n(konfession), n(bemerkung), n(quid), status1, status2, status3, null, null, null, null)
		speichereEreignis(daten, e.uid, '', GedcomEreignis.eGEBURT.wert, geburtsdatum, geburtsort, geburtsbem,
			geburtsQuelle)
		speichereEreignis(daten, e.uid, '', GedcomEreignis.eTAUFE.wert, taufdatum, taufort, taufbem, taufQuelle)
		speichereEreignis(daten, e.uid, '', GedcomEreignis.eTOD.wert, todesdatum, todesort, todesbem, todesQuelle)
		speichereEreignis(daten, e.uid, '', GedcomEreignis.eBEGRAEBNIS.wert, begraebnisdatum, begraebnisort,
			begraebnisbem, begraebnisQuelle)
		byteRep.saveBytesListe(daten, "SB_Person", e.uid, byteliste)
		if (!Global.nes(vaterUidNeu) || !Global.nes(mutterUidNeu)) {
			neueFamilie(daten, null, vaterUidNeu, mutterUidNeu, e.uid, false)
		}
		if (!Global.nes(gatteNeu)) {
			var fliste = familieRep.getFamilieListe(daten, null, null, null, gatteNeu, null)
			var fuid = if(fliste.size > 0) fliste.get(0).uid else null
			if (gesch == GeschlechtEnum.MAENNLICH.toString) {
				neueFamilie(daten, fuid, e.uid, gatteNeu, null, true)
			} else {
				neueFamilie(daten, fuid, gatteNeu, e.uid, null, true)
			}
		}
		var r = new ServiceErgebnis<SbPerson>(e)
		return r
	}

	/**
	 * Speichert ein Personen- oder Familien-Ereignis.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param puid Ahnen-Nummer.
	 * @param typ Typ des Ereignisses, z.B. BIRT.
	 * @param datum Ereignis-Datum.
	 * @param ort Ereignis-Ort.
	 * @param bemerkung Ereignis-Bemerkung.
	 * @param quid Quellen-Nummer zum Ereignis.
	 */
	def private void speichereEreignis(ServiceDaten daten, String puid, String fuid, String typ, String datum,
		String ort, String bemerkung, String quid) {

		var zeitangabe = new SbZeitangabe
		if (zeitangabe.parse(datum)) {
			throw new MeldungException(Meldungen::SB003(datum))
		}
		if (Global.nes(puid) && Global.nes(fuid)) {
			throw new MeldungException(Meldungen::SB004)
		}
		if (Global.nes(typ)) {
			throw new MeldungException(Meldungen::SB005)
		}
		if (Global.nes(zeitangabe.datumTyp) && !zeitangabe.datum1.leer) {
			throw new MeldungException(Meldungen::SB006)
		}
		var loeschen = zeitangabe.datum1.leer && Global.nes(zeitangabe.datumTyp) && zeitangabe.datum2.leer &&
			Global.nes(ort) && Global.nes(bemerkung)
		if (loeschen) {
			var e = getEreignisIntern(daten, puid, fuid, typ)
			if (e !== null) {
				ereignisRep.delete(daten, e)
			}
			return
		}
		ereignisRep.iuSbEreignis(daten, null, puid, fuid, typ, zeitangabe.datum1.tag, zeitangabe.datum1.monat,
			zeitangabe.datum1.jahr, zeitangabe.datum2.tag, zeitangabe.datum2.monat, zeitangabe.datum2.jahr,
			zeitangabe.datumTyp, ort, bemerkung, quid, null, null, null, null)
	}

	@Transaction
	override ServiceErgebnis<Void> deletePerson(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deletePersonIntern(daten, uid)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> getPersonEreignis(ServiceDaten daten, String uid, String etyp) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<String>>(getEreignisStringIntern(daten, uid, null, etyp))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> getFamilieEreignis(ServiceDaten daten, String uid, String etyp) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<String>>(getEreignisStringIntern(daten, null, uid, etyp))
		return r
	}

	def private List<String> getEreignisStringIntern(ServiceDaten daten, String puid, String fuid, String etyp) {

		var liste = new ArrayList<String>
		var sbEreignis = getEreignisIntern(daten, puid, fuid, etyp)
		if (sbEreignis !== null) {
			var datum1 = new SbDatum(sbEreignis.tag1, sbEreignis.monat1, sbEreignis.jahr1)
			var datum2 = new SbDatum(sbEreignis.tag2, sbEreignis.monat2, sbEreignis.jahr2)
			var zeitangabe = new SbZeitangabe(datum1, datum2, sbEreignis.datumTyp)
			liste.add(zeitangabe.deparse)
			liste.add(sbEreignis.ort)
			liste.add(sbEreignis.bemerkung)
		}
		while (liste.size < 3) {
			liste.add(null)
		}
		return liste
	}

	def private SbEreignis getEreignisIntern(ServiceDaten daten, String puid, String fuid, String etyp) {

		var eliste = ereignisRep.getEreignisListe(daten, puid, fuid, etyp, null)
		var e = if(eliste.size > 0) eliste.get(0) else null
		return e
	}

	def private void deletePersonIntern(ServiceDaten daten, String uid) {

		// Person aus Familie löschen
		var liste = familieRep.getFamilieListe(daten, null, null, null, uid, null)
		for (SbFamilie f : liste) {
			var fU = new SbFamilieUpdate(f)
			if (Global.compString(fU.mannUid, uid) == 0) {
				fU.setMannUid(null)
			}
			if (Global.compString(fU.frauUid, uid) == 0) {
				fU.setFrauUid(null)
			}
			if (Global.nes(fU.getMannUid) && Global.nes(fU.frauUid)) {
				deleteFamilieIntern(daten, f.uid)
			}
		}

		// Person als Kind löschen
		var kliste = kindRep.getKindListe(daten, null, uid, null, null, null)
		for (SbKind k : kliste) {
			kindRep.delete(daten, k)
		}

		// Person-Ereignisse löschen
		var eliste = ereignisRep.getEreignisListe(daten, uid, null, null, null)
		for (SbEreignis e : eliste) {
			ereignisRep.delete(daten, e)
		}

		var bliste = byteRep.getBytesListe(daten, "SB_Person", uid)
		for (ByteDaten e : bliste) {
			byteRep.delete(daten, e)
		}
		personRep.delete(daten, new SbPersonKey(daten.mandantNr, uid))
	}

	@Transaction(false)
	override ServiceErgebnis<List<SbFamilieLang>> getFamilieListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = familieRep.getFamilieLangListe(daten, null, null, null, null, null)
		if (zusammengesetzt) {
			for (SbFamilieLang e : liste) {
				e.setVaterGeburtsname(Global.anhaengen(e.vaterGeburtsname, ", ", e.vaterVorname))
				e.setMutterGeburtsname(Global.anhaengen(e.mutterGeburtsname, ", ", e.mutterVorname))
			}
		}
		var r = new ServiceErgebnis<List<SbFamilieLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<SbFamilieLang> getFamilieLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<SbFamilieLang>(null)
		var l = familieRep.getFamilieLangListe(daten, uid, null, null, null, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<SbPersonLang>> getKindListe(ServiceDaten daten, String fuid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = personRep.getPersonLangListe(daten, null, null, null, fuid, null, null)
		// if (zusammengesetzt) {
		// for (SbPersonLang e : liste) {
		// e.setGeburtsname(Global.ahnString(e.nr, e.geburtsname, e.vorname))
		// }
		// }
		var r = new ServiceErgebnis<List<SbPersonLang>>(liste)
		return r
	}

	@Transaction
	override ServiceErgebnis<SbFamilie> insertUpdateFamilie(ServiceDaten daten, String uid, String mannUid,
		String frauUid, String heiratsdatum, String heiratsort, String heiratsbem, String quid, List<String> kinder) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var e = neueFamilie(daten, uid, mannUid, frauUid, null, true)
		speichereEreignis(daten, '', e.uid, GedcomEreignis.eHEIRAT.wert, heiratsdatum, heiratsort, heiratsbem, quid)

		// bestehende Kinder lesen
		var listeAlt = kindRep.getKindListe(daten, e.uid, null, null, null, null)
		for (String i : kinder) {
			var SbKind vo
			for (SbKind vo2 : listeAlt) {
				if (Global.compString(vo2.kindUid, i) == 0) {
					vo = vo2
				}
			}
			if (vo === null) {
				iuKind(daten, e.uid, i)
			} else {
				listeAlt.remove(vo)
			}
		}
		// überflüssige Kinder löschen.
		for (SbKind vo : listeAlt) {
			kindRep.delete(daten, vo)
		}
		var r = new ServiceErgebnis<SbFamilie>(e)
		return r
	}

	/**
	 * Löschen einer Familie.
	 * @param uid Familie-Nummer.
	 */
	@Transaction
	override ServiceErgebnis<Void> deleteFamilie(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deleteFamilieIntern(daten, uid)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	/**
	 * Evtl. Anlegen einer neuen Familie.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Familien-Nummer wird neu bestimmt, falls null.
	 * @param mannUid Ahnen-Nummer des Mannes.
	 * @param frauUid Ahnen-Nummer der Frau.
	 * @param kindUid Ahnen-Nummer des Kindes.
	 * @param doppelt Exception bei anderer Familie.
	 * @return Evtl. neu bestimmte Familien-Nummer.
	 * @throws Exception falls die neue Familien-Nummer nicht bestimmt werden konnte oder Ahn schon Kind in anderer
	 *         Familie ist.
	 */
	def private SbFamilie neueFamilie(ServiceDaten daten, String uid, String mannUid, String frauUid, String kindUid,
		boolean doppelt) {

		var fuid = uid
		var String fuid2
		var SbPerson sbPerson
		var maUid = mannUid
		var frUid = frauUid
		if (Global.nes(maUid) && Global.nes(frUid)) {
			throw new MeldungException(Meldungen::SB007)
		}
		if (!Global.nes(maUid)) {
			sbPerson = personRep.get(daten, new SbPersonKey(daten.mandantNr, maUid))
			if (sbPerson === null || !GeschlechtEnum.MAENNLICH.toString.equalsIgnoreCase(sbPerson.geschlecht)) {
				throw new MeldungException(Meldungen::SB008)
			}
		}
		if (!Global.nes(frUid)) {
			sbPerson = personRep.get(daten, new SbPersonKey(daten.mandantNr, frUid))
			if (sbPerson === null || !GeschlechtEnum.WEIBLICH.toString.equalsIgnoreCase(sbPerson.geschlecht)) {
				throw new MeldungException(Meldungen::SB009)
			}
		}
		var fliste = familieRep.getFamilieListe(daten, null, maUid, frUid, null, fuid)
		var sbFamilie = if(fliste.size > 0) fliste.get(0) else null
		if (sbFamilie !== null) {
			fuid2 = sbFamilie.uid
			maUid = sbFamilie.mannUid
			frUid = sbFamilie.frauUid
		}
		if (!Global.nes(fuid2)) {
			if (doppelt) {
				throw new MeldungException(Meldungen::SB010(fuid2))
			}
			fuid = fuid2
		}
		var f = iuFamilie(daten, fuid, maUid, frUid)
		fuid = f.uid
		if (!Global.nes(kindUid)) {
			iuKind(daten, fuid, kindUid)
		}
		return f
	}

	/**
	 * Anlegen oder Ändern einer Familie.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Familien-Nummer.
	 * @param mannUid Ahnen-Nummer des Mannes.
	 * @param frauUid Ahnen-Nummer der Frau.
	 * @return Benutzte Familien-Nummer.
	 */
	def private SbFamilie iuFamilie(ServiceDaten daten, String uid, String mannUid, String frauUid) {

		if (Global.nes(mannUid) && Global.nes(frauUid)) {
			throw new MeldungException(Meldungen::SB007)
		}
		var f = familieRep.iuSbFamilie(daten, null, uid, mannUid, frauUid, 0, 0, 0, null, null, null, null)
		return f
	}

	/**
	 * Anlegen oder Ändern einer Familien-Kind-Zuordung.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param fuid Familien-Nummer.
	 * @param kindUid Ahnen-Nummer des Kindes.
	 */
	def private void iuKind(ServiceDaten daten, String fuid, String kindUid) {

		if (Global.nes(fuid) || Global.nes(kindUid)) {
			throw new MeldungException(Meldungen::SB011)
		}
		var kliste = kindRep.getKindListe(daten, null, kindUid, fuid, null, null)
		var vo2 = if(kliste.size > 0) kliste.get(0) else null
		if (vo2 !== null) {
			var fuid2 = vo2.familieUid
			throw new MeldungException(Meldungen::SB012(fuid2))
		}
		kindRep.iuSbKind(daten, null, fuid, kindUid, null, null, null, null)
	}

	/**
	 * Löschen einer Familie mit Kindern und Ereignissen.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Familie-Nummer.
	 */
	def private void deleteFamilieIntern(ServiceDaten daten, String uid) {

		// Kinder löschen
		var liste = kindRep.getKindListe(daten, uid, null, null, null, null)
		for (SbKind k : liste) {
			kindRep.delete(daten, k)
		}

		// Familien-Ereignisse löschen
		var eliste = ereignisRep.getEreignisListe(daten, null, uid, null, null)
		for (SbEreignis e : eliste) {
			ereignisRep.delete(daten, e)
		}

		familieRep.delete(daten, new SbFamilieKey(daten.mandantNr, uid))
	}

	@Transaction(false)
	override ServiceErgebnis<List<SbQuelle>> getQuelleListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = quelleRep.getQuelleListe(daten, null, null)
		if (zusammengesetzt) {
			for (e : liste) {
				e.beschreibung = Global.anhaengen(e.beschreibung, ', ', e.autor)
			}
		}
		var r = new ServiceErgebnis<List<SbQuelle>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<SbQuelle> getQuelle(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<SbQuelle>(quelleRep.get(daten, new SbQuelleKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<SbQuelle> insertUpdateQuelle(ServiceDaten daten, String uid, String autor,
		String beschreibung, String zitat, String bemerkung) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var e = iuQuelle(daten, uid, autor, beschreibung, zitat, bemerkung)
		var r = new ServiceErgebnis<SbQuelle>(e)
		return r
	}

	/**
	 * Anlegen oder Ändern einer Quelle.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Quellen-Nummer.
	 * @param autor Autorenname.
	 * @param beschreibung Beschreibung.
	 * @param zitat Zitat.
	 * @param bemerkung Bemerkung.
	 * @return Benutzte Quellen-Nummer.
	 */
	def private SbQuelle iuQuelle(ServiceDaten daten, String uid, String autor, String beschreibung, String zitat,
		String bemerkung) {

		var a = autor
		var b = beschreibung
		if (Global.nes(autor)) {
			throw new MeldungException(Meldungen::SB013)
		}
		if (a.length > SbQuelle.AUTOR_LAENGE) {
			a = a.substring(0, SbQuelle.AUTOR_LAENGE)
		}
		if (Global.nes(beschreibung)) {
			throw new MeldungException(Meldungen::SB014)
		}
		if (b.length > SbQuelle.BESCHREIBUNG_LAENGE) {
			b = b.substring(0, SbQuelle.BESCHREIBUNG_LAENGE)
		}
		var e = quelleRep.iuSbQuelle(daten, null, uid, b, zitat, bemerkung, a, 0, 0, 0, null, null, null, null)
		return e
	}

	@Transaction
	override ServiceErgebnis<Void> deleteQuelle(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deleteQuelleIntern(daten, uid)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private void deleteQuelleIntern(ServiceDaten daten, String uid) {

		var pliste = personRep.getPersonLangListe(daten, null, null, null, null, uid, null)
		if (pliste.size > 0) {
			throw new MeldungException(Meldungen::SB015)
		}
		var eliste = ereignisRep.getEreignisListe(daten, null, null, null, uid)
		if (eliste.size > 0) {
			throw new MeldungException(Meldungen::SB016)
		}
		quelleRep.delete(daten, new SbQuelleKey(daten.mandantNr, uid))
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportAhnen(ServiceDaten daten, String uid, int anzahl0, boolean geschwister,
		boolean nachfahren, boolean vorfahren) {

		// Nachfahren-Liste
		// 1 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// + Vorname <b>Name</b> * tt.mm.jjjj Ort
		// 2 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// 2 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// 2 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// Vorfahren-Liste
		// 1 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// + Vorname <b>Name</b> * tt.mm.jjjj Ort
		// + Vorname <b>Name</b> * tt.mm.jjjj Ort
		// 2 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// 2 Vorname <b>Name</b> * tt.mm.jjjj Ort
		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var anzahl = if(anzahl0 <= 0) 1 else anzahl0
		var p = personRep.get(daten, new SbPersonKey(daten.mandantNr, uid))
		if (p === null) {
			throw new MeldungException(Meldungen::SB017(uid))
		}
		var doc = newFopDokument
		if (nachfahren) {
			var liste = new Vector<SbPerson>
			getNachfahrenRekursiv(daten, uid, 0, 1, anzahl, liste)
			var ueberschrift = Meldungen::SB018(daten.jetzt)
			var untertitel = Meldungen::SB019(Global.ahnString(p.uid, p.geburtsname, p.vorname, false, false), anzahl)
			doc.addNachfahrenliste(true, ueberschrift, untertitel, liste)
		}
		if (vorfahren) {
			var liste = new Vector<SbPerson>
			getVorfahrenRekursiv(daten, uid, true, geschwister, true, 1, anzahl, liste)
			var ueberschrift = Meldungen::SB020(daten.jetzt)
			var untertitel = Meldungen::SB021(Global.ahnString(p.uid, p.geburtsname, p.vorname, false, false), anzahl,
				if(geschwister) Meldungen::SB022 else "")
			doc.addVorfahrenliste(true, ueberschrift, untertitel, liste)
		}
		var r = new ServiceErgebnis<byte[]>
		if (nachfahren || vorfahren) {
			r.ergebnis = doc.erzeugePdf
		}
		return r
	}

	/**
	 * Liefert Daten zu einem Nachfahren.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Ahnen-Nummer aus Datenbank.
	 * @param stufe Daten mit (0,2) oder ohne (1,3) Ereignisse sowie mit (0,1) oder ohne (2,3)
	 *        Familien-/Ehepartner-Bestimmung.
	 * @param generation Hiervon abhängig werden weniger Zeichen pro Zeile zugelassen.
	 * @param max maximale Anzahl von Generationen.
	 * @param liste Liste von Nachfahren.
	 * @return Daten als NachfahrDaten.
	 */
	def private void getNachfahrenRekursiv(ServiceDaten daten, String uid, int stufe, int generation, int max,
		List<SbPerson> liste) {

		var mitEreignis = stufe.bitwiseAnd(1) == 0
		var mitPartner = stufe.bitwiseAnd(2) == 0
		var zeile = new StringBuffer
		var auchKinder = false

		var sbPerson = personRep.get(daten, new SbPersonKey(daten.mandantNr, uid))
		if (sbPerson === null) {
			throw new MeldungException(Meldungen::SB017(uid))
		}

		var strGen = if(mitPartner) "" + generation else "+"
		var strPraefix = Global.fixiereString("", (Math.abs(generation) - 1) * 1, false, " ") // &nbsp
		zeile.setLength(0)
		zeile.append(strPraefix).append(strGen).append(" ").append(
			Global.ahnString(sbPerson.uid, sbPerson.geburtsname, sbPerson.vorname, true, false))
		if (mitEreignis) {
			var ereignisse = ereignisRep.getEreignisListe(daten, uid, null, null, null)
			for (SbEreignis e : ereignisse) {
				zeile.append(" ").append(GedcomEreignis.symbolVon(e.typ))
				var datum1 = new SbDatum(e.tag1, e.monat1, e.jahr1)
				var datum2 = new SbDatum(e.tag2, e.monat2, e.jahr2)
				var zeitangabe = new SbZeitangabe(datum1, datum2, e.datumTyp)
				zeile.append(zeitangabe.deparse)
				Global.anhaengen(zeile, " in ", e.ort)
				Global.anhaengen(zeile, ", ", e.bemerkung)
			}
		}
		sbPerson.setBemerkung(zeile.toString)
		liste.add(sbPerson)
		if (mitPartner) {
			var familien = getElternFamilien(daten, uid)
			for (SbFamilie f : familien) {
				if (Global.compString(f.mannUid, uid) == 0) {
					if (!Global.nes(f.frauUid)) {
						getNachfahrenRekursiv(daten, f.frauUid, stufe.bitwiseOr(2), generation, max, liste)
					// auchKinder = true
					}
				} else {
					if (!Global.nes(f.mannUid)) {
						getNachfahrenRekursiv(daten, f.mannUid, stufe.bitwiseOr(2), generation, max, liste)
					// auchKinder = true
					}
				}
				auchKinder = true
				if (auchKinder && generation <= max) {
					var kinder = kindRep.getKindListe(daten, f.uid, null, null, null, null)
					for (SbKind k : kinder) {
						getNachfahrenRekursiv(daten, k.kindUid, stufe, generation + 1, max, liste)
					}
				}
			}
		}
	}

	/**
	 * Liefert alle Familien, in der der Ahn Vater oder Mutter ist.
	 * @param daten Context-Daten mit Mandantennummer.
	 * @param uid Ahnen-Nummer.
	 * @return Familie des Ahnen.
	 */
	def private List<SbFamilie> getElternFamilien(ServiceDaten daten, String uid) {

		var liste = familieRep.getFamilieListe(daten, null, null, null, uid, null)
		return liste
	}

	/**
	 * Liefert Daten zu einem Vorfahren.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Ahnen-Nummer aus Datenbank.
	 * @param mitEreignis Mit Ereignissen?
	 * @param mitGeschwistern Mit Geschwistern?
	 * @param mitEltern Mit Eltern?
	 * @param generation Hiervon abhängig werden weniger Zeichen pro Zeile zugelassen.
	 * @param max maximale Anzahl von Generationen.
	 * @param liste Liste von Nachfahren.
	 * @return Daten als NachfahrDaten.
	 */
	def private void getVorfahrenRekursiv(ServiceDaten daten, String uid, boolean mitEreignis, boolean mitGeschwistern,
		boolean mitEltern, int generation, int max, List<SbPerson> liste) {

		var zeile = new StringBuffer
		var sbPerson = personRep.get(daten, new SbPersonKey(daten.mandantNr, uid))
		if (sbPerson === null) {
			throw new MeldungException(Meldungen::SB017(uid))
		}
		var strGen = if(mitEltern) "" + generation else "+"
		var strPraefix = Global.fixiereString("", (Math.abs(generation) - 1) * 1, false, " ") // &nbsp;
		zeile.append(strPraefix).append(strGen).append(" ").append(
			Global.ahnString(sbPerson.uid, sbPerson.geburtsname, sbPerson.vorname, true, false))
		if (mitEreignis) {
			var ereignisse = ereignisRep.getEreignisListe(daten, uid, null, null, null)
			for (SbEreignis e : ereignisse) {
				zeile.append(" ").append(GedcomEreignis.symbolVon(e.typ))
				var datum1 = new SbDatum(e.tag1, e.monat1, e.jahr1)
				var datum2 = new SbDatum(e.tag2, e.monat2, e.jahr2)
				var zeitangabe = new SbZeitangabe(datum1, datum2, e.datumTyp)
				zeile.append(zeitangabe.deparse)
				Global.anhaengen(zeile, " in ", e.ort)
				Global.anhaengen(zeile, ", ", e.bemerkung)
			}
		}
		sbPerson.setBemerkung(zeile.toString)
		liste.add(sbPerson)
		var familieUid = getKindFamilieIntern(daten, uid)
		if (mitGeschwistern && !Global.nes(familieUid)) {
			var kinder = kindRep.getKindListe(daten, familieUid, null, null, uid, null)
			for (SbKind k : kinder) {
				getVorfahrenRekursiv(daten, k.kindUid, mitEreignis, false, false, generation, max, liste)
			}
		}
		if (mitEltern && generation < max && !Global.nes(familieUid)) {
			var f = familieRep.get(daten, new SbFamilieKey(daten.mandantNr, familieUid))
			if (f !== null) {
				if (!Global.nes(f.mannUid)) {
					getVorfahrenRekursiv(daten, f.mannUid, mitEreignis, mitGeschwistern, true, generation + 1, max,
						liste)
				}
				if (!Global.nes(f.frauUid)) {
					getVorfahrenRekursiv(daten, f.frauUid, mitEreignis, mitGeschwistern, true, generation + 1, max,
						liste)
				}
			}
		}
	}

	/**
	 * Liefert Familien-Nummer, in der der Ahn Kind ist.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Ahnen-Nummer.
	 * @return Familien-Nummer des Ahnen.
	 */
	def private String getKindFamilieIntern(ServiceDaten daten, String uid) {

		var kliste = kindRep.getKindListe(daten, null, uid, null, null, null)
		if (kliste.size > 0) {
			return kliste.get(0).familieUid
		}
		return null
	}

	/**
	 * Schreibt den Kopf einer GEDCOM-Datei.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param out String-Vector zum Schreiben.
	 * @param version Version der zu schreibenden GEDCOM-Schnittstelle, z.B. '5.5'.
	 * @param strDatei Dateiname wird im Kopf vermerkt.
	 */
	def private void schreibeKopf(ServiceDaten daten, List<String> out, String version, String strDatei) {

		var zeit = Global.dateTimeString(daten.jetzt)
		if (zeit.length >= 19) {
			zeit = zeit.substring(11)
		}
		out.add("0 HEAD" + Constant.CRLF)
		out.add("1 SOUR WKUEHL" + Constant.CRLF)
		out.add("2 VERS 0.1" + Constant.CRLF)
		out.add("2 NAME JHH6-Programm" + Constant.CRLF)
		out.add("1 DEST ANSTFILE or TempleReady" + Constant.CRLF)
		out.add("1 DATE " + SbDatum.gcdatum(daten.jetzt).toUpperCase + Constant.CRLF)
		out.add("2 TIME " + zeit + Constant.CRLF)
		if (version.compareTo("5.5") >= 0) {
			out.add("1 SUBM @999999@" + Constant.CRLF) // submitter
			out.add("1 SUBN @999998@" + Constant.CRLF) // submission
		}
		out.add("1 FILE " + strDatei + Constant.CRLF)
		out.add("1 GEDC" + Constant.CRLF)
		out.add("2 VERS " + version + Constant.CRLF)
		out.add("2 FORM LINEAGE-LINKED" + Constant.CRLF)
		// out.add("1 CHAR ANSI" + Constant.CRLF)
		// UNICODE: Fehler wegen fehlendem BOM
		out.add("1 CHAR UTF-8" + Constant.CRLF)
	}

	/**
	 * Liefert aus typ und nr eine Objekt-Referenz.
	 * @param map Mapping zwischen Uid und Integer für Export kleinerer IDs.
	 * @param typ "FAM" für Familie, "INDI" für Individuum, "SOUR" für Quelle.
	 * @param uid Nummer des Objekts.
	 * @return Objekt-Referenz als Zeichenkette.
	 */
	def private String getXref(HashMap<String, Integer> map, String typ, String uid) {

		var String s
		if (map === null) {
			s = Global.toXref(uid)
		} else {
			var i = map.get(uid)
			if (i === null) {
				i = map.size + 1
				map.put(uid, i)
			}
			s = i.toString
		}
		if (typ.equals("FAM")) {
			return Global.format("@F{0}@", s)
		} else if (typ.equals("INDI")) {
			return Global.format("@I{0}@", s)
		} else { // SOUR
			return Global.format("@Q{0}@", s)
		}
	}

	/**
	 * Liefert eine Uid aus Objekt-Referenz.
	 * @param map Mapping zwischen Objekt-Referenz und Uid für Import kleinerer IDs.
	 * @param xref Objekt-Referenz als Zeichenkette.
	 * @return Uid als Zeichenkette.
	 */
	def private String getUid(HashMap<String, String> map, String xref) {

		if (xref === null) {
			return null
		}
		if (map === null) {
			return Global.toUid(xref)
		} else {
			var uid = map.get(xref)
			if (uid === null) {
				uid = if(xref.length <= 6) Global.UID else Global.toUid(xref)
				map.put(xref, uid)
			}
			return uid
		}
	}

	/**
	 * Schreibt einen längeren Text in eine GEDCOM-Datei, der in maximal 248 Zeichen lange Zeilen umgebrochen wird.
	 * @param out String-Vector zum Schreiben.
	 * @param level Stufennummer.
	 * @param type Typ des Eintrags, z.B. TITL, TEXT, AUTH.
	 * @param text Auszugebender Inhalt.
	 */
	def private void schreibeFortsetzung(List<String> out, int level, String type, String text) {

		// Maximal Länge einer GEDCOM-Zeile.
		val MAX_GEDCOM_ZEILE = 248
		var String str
		var iLen = if(text === null) 0 else text.length
		if (iLen > 0) {
			var iMax = (iLen - 1) / MAX_GEDCOM_ZEILE + 1
			for (var i = 1; i <= iMax; i++) {
				if (i < iMax) {
					str = text.substring((i - 1) * MAX_GEDCOM_ZEILE, i * MAX_GEDCOM_ZEILE)
				} else { // i == iMax
					str = text.substring((i - 1) * MAX_GEDCOM_ZEILE)
				}
				if (i == 1) {
					out.add(level + " " + type + " " + str + Constant.CRLF)
				} else {
					out.add((level + 1) + " CONT " + str + Constant.CRLF)
				}
			}
		}
	}

	/**
	 * Schreibt einen Ahnen in eine GEDCOM-Datei.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param out String-Vector zum Schreiben.
	 * @param map Mapping zwischen Uid und Integer für Export kleinerer IDs.
	 * @param vers Version der zu schreibenden GEDCOM-Schnittstelle, z.B. '5.5'.
	 * @param strFilter Filter-Kriterium für Ahnen und Familien.
	 */
	def private void schreibeIndividual(ServiceDaten daten, List<String> out, HashMap<String, Integer> map, String vers,
		int status2) {

		var liste = personRep.getPersonLangListe(daten, null, null, null, null, null, status2)
		for (SbPersonLang p : liste) {
			var uid = p.uid
			var vn = p.vorname
			var gn = p.geburtsname
			var pn = Global.anhaengen(vn, " ", "/" + p.name + "/")
			var bem = p.bemerkung
			var konf = p.konfession
			var quid = p.quelleUid
			out.add(Global.format("0 {0} INDI" + Constant.CRLF, getXref(map, "INDI", uid)))
			out.add("1 NAME " + pn + Constant.CRLF)
			if (vers.compareTo("5.5") >= 0) {
				if (!Global.nes(vn)) {
					out.add("2 GIVN " + vn + Constant.CRLF)
				}
				if (!Global.nes(gn)) {
					out.add("2 SURN " + gn + Constant.CRLF)
				}
			}
			if (p.geschlecht !== null) {
				var geschlecht = p.geschlecht.toUpperCase
				geschlecht = geschlecht.replace('W', 'F')
				if (geschlecht.matches("M|F")) {
					out.add("1 SEX " + geschlecht + Constant.CRLF)
				}
			}
			// Ereignisse
			var ereignisse = ereignisRep.getEreignisListe(daten, uid, null, null, null)
			for (SbEreignis e : ereignisse) {
				var datum1 = new SbDatum(e.tag1, e.monat1, e.jahr1)
				var datum2 = new SbDatum(e.tag2, e.monat2, e.jahr2)
				var zeitangabe = new SbZeitangabe(datum1, datum2, e.datumTyp)
				out.add("1 " + e.typ + Constant.CRLF)
				out.add("2 DATE " + zeitangabe.deparse(true) + Constant.CRLF)
				var ort = e.ort
				var ebem = e.bemerkung
				if (!Global.nes(ort)) {
					out.add("2 PLAC " + ort + Constant.CRLF)
				}
				if (!Global.nes(ebem)) {
					schreibeFortsetzung(out, 2, "NOTE", ebem)
				// out.add("2 NOTE " + ebem + Constant.CRLF)
				}
			}
			if (!Global.nes(konf)) {
				out.add("1 RELI " + konf + Constant.CRLF)
			}
			if (!Global.nes(quid)) {
				out.add("1 SOUR " + getXref(map, "SOUR", quid) + Constant.CRLF)
			}
			if (!Global.nes(bem)) {
				schreibeFortsetzung(out, 1, "NOTE", bem)
			// out.add("1 NOTE " + bem + Constant.CRLF)
			}
			var eltern = familieRep.getFamilieStatusListe(daten, null, uid, status2)
			if (eltern !== null && eltern.size > 0) {
				out.add("1 FAMC " + getXref(map, "FAM", eltern.get(0).uid) + Constant.CRLF)
			}
			eltern = familieRep.getFamilieStatusListe(daten, uid, null, status2)
			var String fuid
			for (SbFamilieStatus f : eltern) {
				// keine doppelten Einträge
				if (Global.compString(f.uid, fuid) != 0) {
					out.add("1 FAMS " + getXref(map, "FAM", f.uid) + Constant.CRLF)
				}
				fuid = f.uid
			}
		}
	}

	/**
	 * Schreibt eine Familie in eine GEDCOM-Datei.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param out String-Vector zum Schreiben.
	 * @param map Mapping zwischen Uid und Integer für Export kleinerer IDs.
	 * @param strFilter Filter-Kriterium für Familien.
	 * @param operator Vergleichsoperator für tot.
	 * @param tot Todesjahr zum Vergleichen und Filtern.
	 */
	def private void schreibeFamily(ServiceDaten daten, List<String> out, HashMap<String, Integer> map, int status2,
		String operator, int tot) {

		var String mannUid
		var String frauUid
		var familien = familieRep.getFamilieStatusListe(daten, null, null, status2)
		for (SbFamilieStatus f : familien) {
			var familienUid = f.uid
			var muid = f.mannUid
			var fuid = f.frauUid
			var kindUid = f.kindUid
			var mannTot = f.mannStatus1
			var frauTot = f.frauStatus1
			var kindTot = f.kindStatus1
			if (!Global.vergleicheInt(mannTot, operator, tot)) {
				muid = null
			}
			if (!Global.vergleicheInt(frauTot, operator, tot)) {
				fuid = null
			}
			if (!Global.vergleicheInt(kindTot, operator, tot)) {
				kindUid = null
			}
			var neu = Global.compString(mannUid, muid) != 0 || Global.compString(frauUid, fuid) != 0
			var filter = !Global.nes(muid) || !Global.nes(fuid)
			if (filter && neu) {
				out.add(("0 " + getXref(map, "FAM", familienUid)) + " FAM" + Constant.CRLF)
				var ereignisse = ereignisRep.getEreignisListe(daten, null, familienUid, null, null)
				for (SbEreignis e : ereignisse) {
					var datum1 = new SbDatum(e.tag1, e.monat1, e.jahr1)
					var datum2 = new SbDatum(e.tag2, e.monat2, e.jahr2)
					var zeitangabe = new SbZeitangabe(datum1, datum2, e.datumTyp)
					out.add("1 " + e.typ + Constant.CRLF)
					out.add("2 DATE " + zeitangabe.deparse(true) + Constant.CRLF)
					var ort = e.ort
					var ebem = e.bemerkung
					if (!Global.nes(ort)) {
						out.add("2 PLAC " + ort + Constant.CRLF)
					}
					if (!Global.nes(ebem)) {
						schreibeFortsetzung(out, 2, "NOTE", ebem)
					// out.add("2 NOTE " + ebem + Constant.CRLF)
					}
				}
				if (!Global.nes(muid)) {
					out.add("1 HUSB " + getXref(map, "INDI", muid) + Constant.CRLF)
				}
				if (!Global.nes(fuid)) {
					out.add("1 WIFE " + getXref(map, "INDI", fuid) + Constant.CRLF)
				}
			}
			if (filter) {
				if (!Global.nes(kindUid)) {
					out.add("1 CHIL " + getXref(map, "INDI", kindUid) + Constant.CRLF)
				}
			}
			mannUid = muid
			frauUid = fuid
		}
	}

	/**
	 * Schreibt eine Quelle in eine GEDCOM-Datei.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param out String-Vector zum Schreiben.
	 * @param map Mapping zwischen Uid und Integer für Export kleinerer IDs.
	 * @param status2 Status2.
	 */
	def private void schreibeSource(ServiceDaten daten, List<String> out, HashMap<String, Integer> map, int status2) {

		var quellen = quelleRep.getQuelleListe(daten, null, status2)
		for (SbQuelle q : quellen) {
			var quid = q.uid
			var autor = q.autor
			var beschreibung = q.beschreibung
			var zitat = q.zitat
			var bemerkung = q.bemerkung
			out.add(("0 " + getXref(map, "SOUR", quid)) + " SOUR" + Constant.CRLF)
			schreibeFortsetzung(out, 1, "AUTH", autor)
			schreibeFortsetzung(out, 1, "TITL", beschreibung)
			schreibeFortsetzung(out, 1, "TEXT", zitat)
			schreibeFortsetzung(out, 1, "NOTE", bemerkung)
		}
	}

	def private MaParameter getParameter(ServiceDaten daten, String schluessel) {

		var key = new MaParameterKey(daten.mandantNr, schluessel)
		var r = parameterRep.get(daten, key)
		if (r === null) {
			r = new MaParameter
			r.mandantNr = daten.mandantNr
			r.schluessel = schluessel
			var p = Parameter.get(schluessel)
			if (p !== null)
				r.wert = p.wert
		}
		return r
	}

	/**
	 * Schreibt den Schluss einer GEDCOM-Datei.
	 * @param out String-Vector zum Schreiben.
	 * @param version Version der zu schreibenden GEDCOM-Schnittstelle, z.B. '5.5'.
	 * @param name Bezeichnung des Stammbaums.
	 */
	def private void schreibeFuss(ServiceDaten daten, List<String> out, String version, String name) {

		if (version.compareTo("5.5") >= 0) {
			// # submitter
			var p = getParameter(daten, Parameter.SB_SUBMITTER)
			if (p !== null && !Global.nes(p.wert)) {
				var arr = p.wert.split(';')
				out.add("0 @999999@ SUBM" + Constant.CRLF)
				if (arr.length > 0)
				out.add("1 NAME " + arr.get(0) + Constant.CRLF)
				if (arr.length > 1)
				out.add("1 ADDR " + arr.get(1) + Constant.CRLF)
				if (arr.length > 2)
				out.add("2 CONT " + arr.get(2) + Constant.CRLF)
				if (arr.length > 3)
				out.add("2 CONT " + arr.get(3) + Constant.CRLF)
				if (arr.length > 4)
				out.add("2 CONT " + arr.get(4) + Constant.CRLF)
			// out.add("1 PHON 00000-11111" + Constant.CRLF)
			}
		}
		if (version.compareTo("5.5") >= 0) {
			// submission
			out.add("0 @999998@ SUBN" + Constant.CRLF)
			out.add("1 SUBM @999999@" + Constant.CRLF)
			out.add("1 FAMF " + name + Constant.CRLF)
		}
		out.add("0 TRLR" + Constant.CRLF)
	}

	/**
	 * Erstellen einer GEDCOM-Datei der Version 4.0 oder 5.5.
	 * @param skript Name der Datei mit Pfad.
	 * @param name Name des Stammbaums in der Datei.
	 * @param filter Filter-Kriterium für Ahnen.
	 * @param version0 Version kann null sein, dann gilt Version "5.5".
	 * @return Datei als String-Array.
	 */
	@Transaction
	override ServiceErgebnis<List<String>> exportAhnen(ServiceDaten daten, String skript, String name, String filter,
		String version0) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var version = version0

		// Status2=1 heißt Export in Datei, sonst nicht.
		if (Global.nes(version)) {
			version = "5.5"
		}
		if (Global.nes(name)) {
			throw new MeldungException(Meldungen::SB023)
		}
		if (Global.nes(skript)) {
			throw new MeldungException(Meldungen::M1012)
		}
		if (!(version.equals("4.0") || version.equals("5.5"))) {
			throw new MeldungException(Meldungen::SB024)
		}
		var status2 = 1
		var operator = ">="
		var tot = 0
		if (Global.nes(filter)) {
			personRep.updateStatus2(daten, null, 0, status2)
			familieRep.updateStatus2(daten, status2)
			quelleRep.updateStatus2(daten, status2)
		} else {
			var m = Pattern.compile("^status1\\s*(<|<=|=|>=|>)\\s*(\\d+)$", Pattern.CASE_INSENSITIVE).matcher(filter)
			if (m.find) {
				operator = m.group(1)
				tot = Global.strInt(m.group(2))
			} else {
				throw new MeldungException(Meldungen::SB025)
			}
			status2 = 0
			personRep.updateStatus2(daten, null, 0, status2)
			familieRep.updateStatus2(daten, status2)
			quelleRep.updateStatus2(daten, status2)
			status2 = 1
			personRep.updateStatus2(daten, operator, tot, status2)
			familieRep.updateMannFrauStatus2(daten, status2)
			quelleRep.updatePersonStatus2(daten, status2)
		}
		var out = new Vector<String>
		var map = new HashMap<String, Integer>
		schreibeKopf(daten, out, version, skript)
		schreibeIndividual(daten, out, map, version, status2)
		schreibeFamily(daten, out, map, status2, operator, tot)
		schreibeSource(daten, out, map, status2)
		schreibeFuss(daten, out, version, name)
		var r = new ServiceErgebnis<List<String>>(out)
		return r
	}

	private Pattern level = Pattern.compile("^([\\d]+) (.*)$")
	private Pattern indi0 = Pattern.compile("^0 @I([\\da-fA-F;\\-]+)@ INDI$") // 297f9764:141887cfc37:-8000-
	private Pattern name1 = Pattern.compile("^1 NAME [^/]*/([^/]+)/$")
	private Pattern givn2 = Pattern.compile("^2 GIVN (.*)$")
	private Pattern surn2 = Pattern.compile("^2 SURN (.*)$")
	private Pattern sex1 = Pattern.compile("^1 SEX ([M|F])$")
	private Pattern birt1 = Pattern.compile("^1 BIRT$")
	private Pattern buri1 = Pattern.compile("^1 BURI$")
	private Pattern chr1 = Pattern.compile("^1 CHR$")
	private Pattern deat1 = Pattern.compile("^1 DEAT$")
	private Pattern date2 = Pattern.compile("^2 DATE (.*)$")
	private Pattern plac2 = Pattern.compile("^2 PLAC (.*)$")
	private Pattern note2 = Pattern.compile("^2 NOTE (.*)$")
	private Pattern cont3 = Pattern.compile("^3 CONT (.*)$")
	private Pattern reli1 = Pattern.compile("^1 RELI (.*)$")
	private Pattern note1 = Pattern.compile("^1 NOTE (.*)$")
	private Pattern cont2 = Pattern.compile("^2 CONT (.*)$")
	private Pattern sour1 = Pattern.compile("^1 SOUR @Q([\\da-fA-F;\\-]+)@$")
	private Pattern fam0 = Pattern.compile("^0 @F([\\da-fA-F;\\-]+)@ FAM$")
	private Pattern husb1 = Pattern.compile("^1 HUSB @I([\\da-fA-F;\\-]+)@$")
	private Pattern wife1 = Pattern.compile("^1 WIFE @I([\\da-fA-F;\\-]+)@$")
	private Pattern marr1 = Pattern.compile("^1 MARR$")
	private Pattern chil1 = Pattern.compile("^1 CHIL @I([\\da-fA-F;\\-]+)@$")
	private Pattern sour0 = Pattern.compile("^0 @Q([\\da-fA-F;\\-]+)@ SOUR$")
	private Pattern auth1 = Pattern.compile("^1 AUTH (.*)$")
	private Pattern titl1 = Pattern.compile("^1 TITL (.*)$")
	private Pattern text1 = Pattern.compile("^1 TEXT (.*)$")

	def private int importiereAhnen(ServiceDaten daten, List<String> datei, HashMap<String, String> map) {

		var Matcher m
		var String uid
		var v = new Vector<String>
		var anzahl = 0

		for (String s : datei) {
			var str = if(s === null) '' else s
			if (str.startsWith("0")) {
				try {
					if (v.size > 0) {
						var str0 = v.get(0)
						var g = false
						v.remove(0)
						m = indi0.matcher(str0)
						if (m.find) {
							uid = getUid(map, m.group(1))
							importIndividual(daten, v, uid, map)
							anzahl++
							g = true
						}
						if (!g) {
							m = fam0.matcher(str0)
							if (m.find) {
								uid = getUid(map, m.group(1))
								importFamily(daten, v, uid, map)
								g = true
							}
						}
						if (!g) {
							m = sour0.matcher(str0)
							if (m.find) {
								uid = getUid(map, m.group(1))
								importSource(daten, v, uid)
								g = true
							}
						}
					}
				} finally {
					v.clear
					v.add(str)
				}
			} else {
				v.add(str)
			}
		}
		return anzahl
	}

	def private int getLevel(String str) {

		var l = -1
		if (!Global.nes(str)) {
			var m = level.matcher(str)
			if (m.find) {
				l = Global.strInt(m.group(1))
			}
		}
		return l
	}

	def private void importIndividual(ServiceDaten daten, Vector<String> v, String uid, HashMap<String, String> map) {

		var ve = new Vector<String>
		var p = new SbPerson
		p.mandantNr = daten.mandantNr
		p.uid = uid
		p.geschlecht = GeschlechtEnum.MAENNLICH.toString
		while (v.size > 0) {
			var str = v.remove(0)
			var g = false
			var m = name1.matcher(str)
			if (m.find) {
				p.setName(n(m.group(1)))
				g = true
			}
			if (!g) {
				m = givn2.matcher(str)
				if (m.find) {
					p.setVorname(n(m.group(1)))
					g = true
				}
			}
			if (!g) {
				m = surn2.matcher(str)
				if (m.find) {
					p.setGeburtsname(n(m.group(1)))
					g = true
				}
			}
			if (!g) {
				m = sex1.matcher(str)
				if (m.find) {
					if ("F".equals(m.group(1))) {
						p.setGeschlecht(GeschlechtEnum.WEIBLICH.toString)
					}
					g = true
				}
			}
			if (!g) {
				m = birt1.matcher(str)
				if (m.find) {
					ve.clear
					while (getLevel(v.get(0)) > 1) {
						ve.add(v.remove(0))
					}
					importEvent(daten, ve, uid, "INDI", GedcomEreignis.eGEBURT)
					g = true
				}
			}
			if (!g) {
				m = buri1.matcher(str)
				if (m.find) {
					ve.clear
					while (getLevel(v.get(0)) > 1) {
						ve.add(v.remove(0))
					}
					importEvent(daten, ve, uid, "INDI", GedcomEreignis.eBEGRAEBNIS)
					g = true
				}
			}
			if (!g) {
				m = chr1.matcher(str)
				if (m.find) {
					ve.clear
					while (getLevel(v.get(0)) > 1) {
						ve.add(v.remove(0))
					}
					importEvent(daten, ve, uid, "INDI", GedcomEreignis.eTAUFE)
					g = true
				}
			}
			if (!g) {
				m = deat1.matcher(str)
				if (m.find) {
					ve.clear
					while (getLevel(v.get(0)) > 1) {
						ve.add(v.remove(0))
					}
					importEvent(daten, ve, uid, "INDI", GedcomEreignis.eTOD)
					g = true
				}
			}
			if (!g) {
				m = reli1.matcher(str)
				if (m.find) {
					p.konfession = n(m.group(1))
					g = true
				}
			}
			if (!g) {
				m = note1.matcher(str)
				if (m.find) {
					p.bemerkung = n(m.group(1))
					g = true
				}
			}
			if (!g) {
				m = cont2.matcher(str)
				if (m.find) {
					p.bemerkung = Global.anhaengen(p.bemerkung, null, n(m.group(1)))
					g = true
				}
			}
			if (!g) {
				m = sour1.matcher(str)
				if (m.find) {
					p.quelleUid = getUid(map, m.group(1))
					g = true
				}
			}
		}
		p.machAngelegt(daten.jetzt, daten.benutzerId)
		personRep.insert(daten, p)
	}

	def private void importFamily(ServiceDaten daten, Vector<String> v, String uid, HashMap<String, String> map) {

		var ve = new Vector<String>
		var f = new SbFamilie
		f.mandantNr = daten.mandantNr
		f.uid = uid
		while (v.size > 0) {
			var str = v.remove(0)
			var g = false
			var m = husb1.matcher(str)
			if (m.find) {
				f.mannUid = getUid(map, m.group(1))
				g = true
			}
			if (!g) {
				m = wife1.matcher(str)
				if (m.find) {
					f.frauUid = getUid(map, m.group(1))
					g = true
				}
			}
			if (!g) {
				m = marr1.matcher(str)
				if (m.find) {
					ve.clear
					while (getLevel(v.get(0)) > 1) {
						ve.add(v.remove(0))
					}
					importEvent(daten, ve, uid, "FAM", GedcomEreignis.eHEIRAT)
					g = true
				}
			}
			if (!g) {
				m = chil1.matcher(str)
				if (m.find) {
					var k = new SbKind
					k.mandantNr = daten.mandantNr
					k.familieUid = uid
					k.kindUid = getUid(map, m.group(1))
					k.machAngelegt(daten.jetzt, daten.benutzerId)
					kindRep.insert(daten, k)
					g = true
				}
			}
		}
		f.machAngelegt(daten.jetzt, daten.benutzerId)
		familieRep.insert(daten, f)
	}

	def private void importEvent(ServiceDaten daten, Vector<String> v, String uid, String nrTyp, GedcomEreignis typ) {

		var datum = new SbZeitangabe
		var e = new SbEreignis
		e.mandantNr = daten.mandantNr
		if ("INDI".equals(nrTyp)) {
			e.setPersonUid(uid)
			e.setFamilieUid("")
		} else {
			e.setPersonUid("")
			e.setFamilieUid(uid)
		}
		e.setTyp(typ.wert)
		while (v.size > 0) {
			var str = v.remove(0)
			var g = false
			var m = date2.matcher(str)
			if (m.find) {
				datum.parse(m.group(1), true)
				e.datumTyp = datum.datumTyp
				e.tag1 = datum.datum1.tag
				e.monat1 = datum.datum1.monat
				e.jahr1 = datum.datum1.jahr
				e.tag2 = datum.datum2.tag
				e.monat2 = datum.datum2.monat
				e.jahr2 = datum.datum2.jahr
				g = true
			}
			if (!g) {
				m = plac2.matcher(str)
				if (m.find) {
					e.ort = n(m.group(1))
					g = true
				}
			}
			if (!g) {
				m = note2.matcher(str)
				if (m.find) {
					e.bemerkung = n(m.group(1))
					g = true
				}
			}
			if (!g) {
				m = cont3.matcher(str)
				if (m.find) {
					e.bemerkung = Global.anhaengen(e.bemerkung, null, n(m.group(1)))
					g = true
				}
			}
		}
		e.replikationUid = Global.UID
		e.machAngelegt(daten.jetzt, daten.benutzerId)
		ereignisRep.insert(daten, e)
	}

	def private void importSource(ServiceDaten daten, Vector<String> v, String uid) {

		var q = new SbQuelle
		var zuletzt = 0
		q.setMandantNr(daten.mandantNr)
		q.setUid(uid)
		while (v.size > 0) {
			var str = v.remove(0)
			var g = false
			var m = auth1.matcher(str)
			if (m.find) {
				q.autor = n(m.group(1))
				zuletzt = 1
				g = true
			}
			if (!g) {
				m = titl1.matcher(str)
				if (m.find) {
					q.beschreibung = n(m.group(1))
					zuletzt = 2
					g = true
				}
			}
			if (!g) {
				m = text1.matcher(str)
				if (m.find) {
					q.zitat = n(m.group(1))
					zuletzt = 3
					g = true
				}
			}
			if (!g) {
				m = note1.matcher(str)
				if (m.find) {
					q.bemerkung = n(m.group(1))
					zuletzt = 4
					g = true
				}
			}
			if (!g) {
				m = cont2.matcher(str)
				if (m.find) {
					if (zuletzt == 1) {
						q.autor = Global.anhaengen(q.autor, null, n(m.group(1)))
					} else if (zuletzt == 2) {
						q.beschreibung = Global.anhaengen(q.beschreibung, null, n(m.group(1)))
					} else if (zuletzt == 3) {
						q.zitat = Global.anhaengen(q.zitat, null, n(m.group(1)))
					} else if (zuletzt == 4) {
						q.bemerkung = Global.anhaengen(q.bemerkung, null, n(m.group(1)))
					}
					g = true
				}
			}
		}
		q.machAngelegt(daten.jetzt, daten.benutzerId)
		quelleRep.insert(daten, q)
	}

	@Transaction
	override ServiceErgebnis<String> importAhnen(ServiceDaten daten, List<String> datei) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var pliste = personRep.getPersonLangListe(daten, null, null, null, null, null, null)
		for (SbPersonLang p : pliste) {
			deletePersonIntern(daten, p.uid)
		}
		var fliste = familieRep.getFamilieListe(daten, null, null, null, null, null)
		for (SbFamilie f : fliste) {
			deleteFamilieIntern(daten, f.uid)
		}
		var qliste = quelleRep.getQuelleListe(daten, null, null)
		for (SbQuelle q : qliste) {
			deleteQuelleIntern(daten, q.uid)
		}
		var map = new HashMap<String, String>
		var anzahl = importiereAhnen(daten, datei, map)
		var r = new ServiceErgebnis<String>(Meldungen::SB026(anzahl))
		return r
	}

	/**
	 * Liefert erste Familie, in der der Ahn Vater oder Mutter ist.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Ahnen-Nummer.
	 * @return Familie des Ahnen.
	 */
	def private SbFamilie getElternFamilieIntern(ServiceDaten daten, String uid) {

		var fliste = familieRep.getFamilieListe(daten, null, null, null, uid, null)
		return if(fliste.size > 0) fliste.get(0) else null
	}

	@Transaction(false)
	override ServiceErgebnis<String> getErstesKind(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var String kuid
		var f = getElternFamilieIntern(daten, puid)
		if (f !== null) {
			var kliste = kindRep.getKindListe(daten, f.uid, null, null, null, null)
			if (kliste.size > 0) {
				kuid = kliste.get(0).kindUid
			}
		}
		var r = new ServiceErgebnis<String>(kuid)
		return r
	}

	def private List<String> getEhegatten0(ServiceDaten daten, String puid) {

		var liste = new ArrayList<String>
		if (!Global.nes(puid)) {
			var fliste = familieRep.getFamilieListe(daten, null, null, null, puid, null)
			for (f : fliste) {
				if (!Global.nes(f.mannUid) && Global.compString(puid, f.mannUid) != 0) {
					liste.add(f.mannUid)
				}
				if (!Global.nes(f.frauUid) && Global.compString(puid, f.frauUid) != 0) {
					liste.add(f.frauUid)
				}
			}
		}
		return liste
	}

	def private List<String> getAlleEhegatten(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = new ArrayList<String>
		if (puid === null) {
			return liste
		}
		var liste0 = new ArrayList<String>
		var liste1 = new ArrayList<String>
		liste0.add(puid)
		var anz = -1
		while (anz < liste.size) {
			anz = liste.size
			liste1.clear
			for (s : liste0) {
				var l = getEhegatten0(daten, s)
				for (e : l) {
					if (!liste.contains(e)) {
						liste.add(e)
						liste1.add(e)
					}
				}
			}
			liste0.clear
			liste0.addAll(liste1)
		}
		return liste
	}

	@Transaction(false)
	override ServiceErgebnis<List<SbPerson>> getEhegatten(ServiceDaten daten, String puid) {

		var r = new ServiceErgebnis<List<SbPerson>>(new ArrayList<SbPerson>)
		var liste = getAlleEhegatten(daten, puid)
		for (s : liste) {
			var p = personRep.get(daten, new SbPersonKey(daten.mandantNr, s))
			if (p !== null && Global.compString(puid, p.uid) != 0) {
				r.ergebnis.add(p)
			}
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getNaechstenEhegatten(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(null)
		if (puid === null) {
			return r
		}
		var liste = getAlleEhegatten(daten, puid)
		Collections.sort(liste, String.CASE_INSENSITIVE_ORDER)
		var i = liste.indexOf(puid)
		if (i >= 0) {
			i = (i + 1) % liste.size
			r.ergebnis = liste.get(i)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getNaechstenGeschwister(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(null)
		if (Global.nes(puid)) {
			return r
		}
		var fuid = getKindFamilieIntern(daten, puid)
		if (Global.nes(fuid)) {
			return r
		}
		var f = familieRep.get(daten, new SbFamilieKey(daten.mandantNr, fuid))
		var euid = if(f !== null && !Global.nes(f.mannUid)) f.mannUid else f.frauUid
		if (Global.nes(euid)) {
			return r
		}
		var liste = new ArrayList<String>
		var eliste = getAlleEhegatten(daten, euid)
		for (e : eliste) {
			var kliste = familieRep.getFamilieStatusListe(daten, e, null, null)
			for (k : kliste) {
				if (!liste.contains(k.kindUid)) {
					liste.add(k.kindUid)
				}
			}
		}
		// nächsten Geschwister
		var i = liste.indexOf(puid)
		if (i >= 0) {
			i = (i + 1) % liste.size
			r.ergebnis = liste.get(i)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getNaechstenNamen(ServiceDaten daten, String puid, String name, String vorname) {

		var SbPersonLang p0
		if (!Global.nes(puid)) {
			var liste0 = personRep.getPersonLangListe(daten, puid, null, null, null, null, null)
			p0 = if(liste0.size > 0) liste0.get(0) else null
		}
		var p = personRep.getPersonLang(daten, p0, name, vorname)
		if (p === null && p0 !== null) {
			// 1. Treffer suchen
			p = personRep.getPersonLang(daten, null, name, vorname)
		}
		var r = new ServiceErgebnis<String>(if(p === null) null else p.uid)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getElternFamilie(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(null)
		var f = getElternFamilieIntern(daten, puid)
		if (f !== null) {
			r.ergebnis = f.uid
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getKindFamilie(ServiceDaten daten, String puid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(getKindFamilieIntern(daten, puid))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getErstesFamilienKind(ServiceDaten daten, String fuid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(null)
		var kliste = kindRep.getKindListe(daten, fuid, null, null, null, null)
		if (kliste.size > 0) {
			r.ergebnis = kliste.get(0).kindUid
		}
		return r
	}
}

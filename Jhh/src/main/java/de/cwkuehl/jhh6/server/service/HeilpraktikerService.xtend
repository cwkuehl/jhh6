package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.HpBehandlung
import de.cwkuehl.jhh6.api.dto.HpBehandlungDruck
import de.cwkuehl.jhh6.api.dto.HpBehandlungKey
import de.cwkuehl.jhh6.api.dto.HpBehandlungLang
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistung
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungUpdate
import de.cwkuehl.jhh6.api.dto.HpBehandlungUpdate
import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.api.dto.HpLeistungKey
import de.cwkuehl.jhh6.api.dto.HpLeistungUpdate
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppe
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppeKey
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppeUpdate
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.dto.HpPatientKey
import de.cwkuehl.jhh6.api.dto.HpPatientUpdate
import de.cwkuehl.jhh6.api.dto.HpRechnung
import de.cwkuehl.jhh6.api.dto.HpRechnungKey
import de.cwkuehl.jhh6.api.dto.HpRechnungLang
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.dto.HpStatusKey
import de.cwkuehl.jhh6.api.dto.HpStatusUpdate
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.enums.GeschlechtEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.global.Parameter
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.base.SqlBuilder
import de.cwkuehl.jhh6.server.rep.impl.ByteDatenRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungLeistungRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungRep
import de.cwkuehl.jhh6.server.rep.impl.HpLeistungRep
import de.cwkuehl.jhh6.server.rep.impl.HpLeistungsgruppeRep
import de.cwkuehl.jhh6.server.rep.impl.HpPatientRep
import de.cwkuehl.jhh6.server.rep.impl.HpRechnungRep
import de.cwkuehl.jhh6.server.rep.impl.HpStatusRep
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.ArrayList
import java.util.Collections
import java.util.Comparator
import java.util.HashMap
import java.util.List
import java.util.function.BiConsumer
import java.util.regex.Pattern

@Service
class HeilpraktikerService {

	@RepositoryRef ByteDatenRep byteRep
	@RepositoryRef HpBehandlungRep behandlungRep
	@RepositoryRef HpBehandlungLeistungRep behleistRep
	@RepositoryRef HpLeistungRep leistungRep
	@RepositoryRef HpLeistungsgruppeRep leistgruppeRep
	@RepositoryRef HpPatientRep patientRep
	@RepositoryRef HpRechnungRep rechnungRep
	@RepositoryRef HpStatusRep statusRep
	@RepositoryRef MaParameterRep parameterRep

	/** Lesen aller Status.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @return Liste aller Status.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<HpStatus>> getStatusListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpStatus>>(null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Sortierung, a.Uid")
		var liste = statusRep.getListe(daten, daten.mandantNr, null, order)
		if (zusammengesetzt) {
			for (HpStatus e : liste) {
				var strB = new StringBuffer(e.status)
				Global.anhaengen(strB, ", ", e.beschreibung)
				e.setStatus(strB.toString)
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardStatusListe(ServiceDaten daten) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = newArrayList(new MaEinstellung, new MaEinstellung, new MaEinstellung)
		liste.get(0).setSchluessel("0")
		liste.get(0).setWert("kein Standard")
		liste.get(1).setSchluessel("1")
		liste.get(1).setWert("Standard für Behandlung")
		liste.get(2).setSchluessel("2")
		liste.get(2).setWert("Standard für Rechnung")
		var r = new ServiceErgebnis<List<MaEinstellung>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpStatus> getStandardStatus(ServiceDaten daten, int standard) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<HpStatus>(null)
		var liste = statusRep.getStatusListe(daten, standard)
		if (liste.length > 0) {
			r.ergebnis = liste.get(0)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpStatus> getStatus(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpStatus>(statusRep.get(daten, new HpStatusKey(daten.mandantNr, uid)))
		return r
	}

	val private BiConsumer<HpStatus, HpStatusUpdate> statusEvent = [ HpStatus e, HpStatusUpdate u |

		var String uid
		var String status
		var String besch
		var int sortierung
		if (e !== null) {
			uid = e.uid
			status = e.status
			besch = e.beschreibung
			sortierung = e.sortierung
		} else if (u !== null) {
			uid = u.uid
			status = u.status
			besch = u.beschreibung
			sortierung = u.sortierung
		}
		if (Global.nes(status)) {
			status = '''Status«uid»'''
		}
		if (status.length > HpStatus.STATUS_LAENGE) {
			status = status.substring(0, HpStatus.STATUS_LAENGE)
		}
		if (Global.nes(besch)) {
			besch = '''Status«uid»'''
		}
		if (status.length > HpStatus.BESCHREIBUNG_LAENGE) {
			status = status.substring(0, HpStatus.BESCHREIBUNG_LAENGE)
		}
		if (sortierung <= 0) {
			sortierung = 1
		}
		if (e !== null) {
			e.status = status
			e.beschreibung = besch
			e.sortierung = sortierung
		} else if (u !== null) {
			u.status = status
			u.beschreibung = besch
			u.sortierung = sortierung
		}
	]

	@Transaction
	override ServiceErgebnis<HpStatus> insertUpdateStatus(ServiceDaten daten, String uid, String status, String besch,
		int sortierung, int standard, String notiz) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<HpStatus>(null)
		r.ergebnis = statusRep.iuHpStatus(daten, statusEvent, uid, status, besch, sortierung, standard, notiz, null,
			null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteStatus(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (behandlungRep.getStatusAnzahl(daten, uid) > 0) {
			throw new MeldungException(Meldungen.M2017)
		}
		var r = new ServiceErgebnis<Void>(null)
		var key = new HpStatusKey(daten.mandantNr, uid)
		statusRep.delete(daten, key)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpLeistung>> getLeistungListe(ServiceDaten daten, boolean zusammengesetzt,
		boolean gruppen) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpLeistung>>(null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Ziffer, a.Uid")
		var liste = leistungRep.getListe(daten, daten.mandantNr, null, order)
		if (gruppen) {
			var gliste = leistgruppeRep.getListe(daten, daten.mandantNr, null, null)
			for (HpLeistungsgruppe e : gliste) {
				var l = new HpLeistung
				l.uid = e.uid
				l.beschreibungFett = e.bezeichnung
				liste.add(l)
			}
		}
		if (zusammengesetzt) {
			for (HpLeistung e : liste) {
				var sb = new StringBuffer
				Global.anhaengen(sb, ", ", e.ziffer)
				Global.anhaengen(sb, ", ", e.zifferAlt)
				Global.anhaengen(sb, ", ", e.beschreibungFett)
				e.beschreibungFett = sb.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpLeistung> getLeistung(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpLeistung>(leistungRep.get(daten, new HpLeistungKey(daten.mandantNr, uid)))
		return r
	}

	val private BiConsumer<HpLeistung, HpLeistungUpdate> leistungEvent = [ HpLeistung e, HpLeistungUpdate u |

		var String uid
		var String ziffer
		var String zifferAlt
		var String besch
		var String beschFett
		if (e !== null) {
			uid = e.uid
			ziffer = e.ziffer
			zifferAlt = e.zifferAlt
			besch = e.beschreibung
			beschFett = e.beschreibungFett
		} else if (u !== null) {
			uid = u.uid
			ziffer = u.ziffer
			zifferAlt = u.zifferAlt
			besch = u.beschreibung
			beschFett = u.beschreibungFett
		}
		if (Global.nes(ziffer)) {
			ziffer = '''Z«uid»'''
		}
		if (ziffer.length > HpLeistung.ZIFFER_LAENGE) {
			ziffer = ziffer.substring(0, HpLeistung.ZIFFER_LAENGE)
		}
		if (Global.nes(beschFett)) {
			beschFett = '''Beschreibung«uid»'''
		}
		if (beschFett.length > HpLeistung.BESCHREIBUNG_FETT_LAENGE) {
			beschFett = beschFett.substring(0, HpLeistung.BESCHREIBUNG_FETT_LAENGE)
		}
		if (Global.nes(zifferAlt)) {
			zifferAlt = ''
		}
		if (Global.nes(besch)) {
			besch = ''
		}
		if (e !== null) {
			e.ziffer = ziffer
			e.zifferAlt = zifferAlt
			e.beschreibung = besch
			e.beschreibungFett = beschFett
		} else if (u !== null) {
			u.ziffer = ziffer
			u.zifferAlt = zifferAlt
			u.beschreibung = besch
			u.beschreibungFett = beschFett
		}
	]

	@Transaction
	override ServiceErgebnis<HpLeistung> insertUpdateLeistung(ServiceDaten daten, String uid, String ziffer,
		String zifferAlt, String beschFett, String besch, double faktor, double betrag, String fragen, String notiz) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<HpLeistung>(null)
		r.ergebnis = leistungRep.iuHpLeistung(daten, leistungEvent, uid, ziffer, zifferAlt, beschFett, besch, faktor,
			betrag, fragen, notiz, null, null, null, null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteLeistung(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (behandlungRep.getLeistungAnzahl(daten, uid) > 0) {
			throw new MeldungException(Meldungen.M2036)
		}
		var ll = behleistRep.getBehandlungLeistungLangListe(daten, null, uid)
		if (ll.size > 0) {
			throw new MeldungException(Meldungen.M2036)
		}
		// Leistung aus Leistungsgruppen löschen
		var lliste = behleistRep.getBehandlungLeistungListe(daten, null, uid)
		for (HpBehandlungLeistung l : lliste) {
			behleistRep.delete(daten, l)
		}
		var key = new HpLeistungKey(daten.mandantNr, uid)
		leistungRep.delete(daten, key)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpLeistungsgruppe>> getLeistungsgruppeListe(ServiceDaten daten,
		boolean zusammengesetzt) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpLeistungsgruppe>>(null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var liste = leistgruppeRep.getListe(daten, daten.mandantNr, null, order)
		if (zusammengesetzt) {
			for (HpLeistungsgruppe e : liste) {
				// var strB = new StringBuffer(e.ziffer)
				// Global.anhaengen(strB, ", ", e.beschreibungFett)
				// e.beschreibungFett = strB.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpLeistungsgruppe> getLeistungsgruppe(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpLeistungsgruppe>(
			leistgruppeRep.get(daten, new HpLeistungsgruppeKey(daten.mandantNr, uid)))
		return r
	}

	val private BiConsumer<HpLeistungsgruppe, HpLeistungsgruppeUpdate> leistgruppeEvent = [ HpLeistungsgruppe e, HpLeistungsgruppeUpdate u |

		var String uid
		var String bez
		if (e !== null) {
			uid = e.uid
			bez = e.bezeichnung
		} else if (u !== null) {
			uid = u.uid
			bez = u.bezeichnung
		}
		if (Global.nes(bez)) {
			bez = '''Bezeichnung«uid»'''
		}
		if (bez.length > HpLeistungsgruppe.BEZEICHNUNG_LAENGE) {
			bez = bez.substring(0, HpLeistungsgruppe.BEZEICHNUNG_LAENGE)
		}
		if (e !== null) {
			e.bezeichnung = bez
		} else if (u !== null) {
			u.bezeichnung = bez
		}
	]

	@Transaction
	override ServiceErgebnis<HpLeistungsgruppe> insertUpdateLeistungsgruppe(ServiceDaten daten, String uid, String bez,
		String leistungUid, double dauer, String notiz, List<HpBehandlungLeistungLang> leistungen) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var lliste = leistungen
		if (Global.arrayLaenge(leistungen) <= 0) {
			if (Global.nes(leistungUid)) {
				throw new MeldungException(Meldungen.M2035)
			}
			if (lliste === null) {
				lliste = new ArrayList<HpBehandlungLeistungLang>
			}
			var bh = new HpBehandlungLeistungLang
			bh.leistungUid = leistungUid
			bh.dauer = dauer
			lliste.add(bh)
		}
		var List<HpBehandlungLeistung> listeAlt = null
		if (!Global.nes(uid)) {
			listeAlt = behleistRep.getBehandlungLeistungListe(daten, uid, null)
		}

		var r = new ServiceErgebnis<HpLeistungsgruppe>(null)
		r.ergebnis = leistgruppeRep.iuHpLeistungsgruppe(daten, leistgruppeEvent, uid, bez, notiz, null, null, null,
			null)

		// Leistungen eintragen
		var buid = r.ergebnis.uid
		for (HpBehandlungLeistungLang vo : lliste) {
			var ll = behleistRep.getBehandlungLeistungListe(daten, buid, vo.leistungUid)
			if (ll.size > 0) {
				var b = ll.get(0)
				var voU = new HpBehandlungLeistungUpdate(b)
				voU.dauer = vo.dauer
				if (voU.isChanged) {
					voU.machGeaendert(daten.getJetzt, daten.getBenutzerId)
					behleistRep.update(daten, voU)
				}
				if (listeAlt !== null) {
					// Löschen aus der alten Liste
					var HpBehandlungLeistung d = null
					for (HpBehandlungLeistung vo2 : listeAlt) {
						if (Global.compString(vo2.leistungUid, vo.leistungUid) == 0) {
							d = vo2
						}
					}
					if (d !== null) {
						listeAlt.remove(d)
					}
				}
			} else {
				behleistRep.iuHpBehandlungLeistung(daten, null, null, buid, vo.leistungUid, vo.dauer, null, null, null,
					null, null)
			}
		}
		if (listeAlt !== null) {
			// Leistungen entfernen.
			for (HpBehandlungLeistung vo : listeAlt) {
				behleistRep.delete(daten, vo)
			}
		}

		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteLeistungsgruppe(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<Void>(null)
		var lliste = behleistRep.getBehandlungLeistungListe(daten, uid, null)
		for (HpBehandlungLeistung l : lliste) {
			behleistRep.delete(daten, l)
		}
		var key = new HpLeistungsgruppeKey(daten.mandantNr, uid)
		leistgruppeRep.delete(daten, key)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpPatient>> getPatientListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpPatient>>(null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Name1, a.Vorname, a.Uid")
		var liste = patientRep.getListe(daten, daten.mandantNr, null, order)
		if (zusammengesetzt) {
			for (HpPatient e : liste) {
				var strB = new StringBuffer(e.name1)
				Global.anhaengen(strB, ", ", e.vorname)
				e.name1 = strB.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpPatient> getPatient(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpPatient>(patientRep.get(daten, new HpPatientKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<ByteDaten>> getPatientBytesListe(ServiceDaten daten, String puid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<ByteDaten>>
		r.ergebnis = byteRep.getBytesListe(daten, "", puid)
		return r
	}

	val private BiConsumer<HpPatient, HpPatientUpdate> patientEvent = [ HpPatient e, HpPatientUpdate u |

		var String uid
		var String name
		var String geschl
		if (e !== null) {
			uid = e.uid
			name = e.name1
			geschl = e.geschlecht
		} else if (u !== null) {
			uid = u.uid
			name = u.name1
			geschl = u.geschlecht
		}
		if (Global.nes(name)) {
			name = '''N«uid»'''
		}
		if (name.length > HpPatient.NAME1_LAENGE) {
			name = name.substring(0, HpPatient.NAME1_LAENGE)
		}
		if (Global.nes(geschl)) {
			geschl = GeschlechtEnum.NEUTRUM.toString
		}
		if (e !== null) {
			e.name1 = name
			e.geschlecht = geschl
		} else if (u !== null) {
			u.name1 = name
			u.geschlecht = geschl
		}
	]

	@Transaction
	override ServiceErgebnis<HpPatient> insertUpdatePatient(ServiceDaten daten, String uid, String name1,
		String vorname, String adresse1, String adresse2, String adresse3, String geschlecht, LocalDate geburt,
		String patientUid, String status, String notiz, List<ByteDaten> byteliste) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<HpPatient>(null)
		r.ergebnis = patientRep.iuHpPatient(daten, patientEvent, uid, name1, vorname, geschlecht, geburt, adresse1,
			adresse2, adresse3, patientUid, status, notiz, null, null, null, null)
		byteRep.saveBytesListe(daten, "HP_Patient", uid, byteliste)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deletePatient(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var pliste = patientRep.getPatientListe(daten, uid)
		if (pliste.length > 0) {
			throw new MeldungException(Meldungen.M2077)
		}
		var rliste = rechnungRep.getRechnungListe(daten, null, uid, null)
		for (HpRechnung re : rliste) {
			rechnungRep.delete(daten, re)
		}
		var bliste = behandlungRep.getBehandlungLangListe(daten, uid, null, null)
		for (HpBehandlungLang b : bliste) {
			behandlungRep.delete(daten, new HpBehandlungKey(daten.mandantNr, b.uid))
		}
		var key = new HpPatientKey(daten.mandantNr, uid)
		patientRep.delete(daten, key)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpBehandlungLeistungLang>> getBehandlungLeistungListe(ServiceDaten daten, boolean zus,
		String patUid, String rechUid, String bUid, LocalDate von, LocalDate bis, boolean auchNull, boolean bleer) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpBehandlungLeistungLang>>(null)
		if (bleer && Global.nes(bUid)) {
			return r
		}
		var liste = behleistRep.getBehandlungLangListe(daten, patUid, rechUid, bUid, von, bis, auchNull)
		if (zus) {
			for (HpBehandlungLeistungLang e : liste) {
				var strB = new StringBuffer(e.patientName)
				Global.anhaengen(strB, ", ", e.patientVorname)
				e.patientName = strB.toString
				strB = new StringBuffer(e.leistungZiffer)
				Global.anhaengen(strB, ", ", e.leistungBeschreibungFett)
				Global.anhaengen(strB, ", ", Global.dblStr2l(e.dauer))
				e.leistungBeschreibungFett = strB.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpBehandlungLeistungLang>> getLeistungsgruppeLeistungListe(ServiceDaten daten,
		boolean zus, String lgUid, boolean bleer) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpBehandlungLeistungLang>>(new ArrayList<HpBehandlungLeistungLang>)
		if (bleer && Global.nes(lgUid)) {
			return r
		}
		var liste = behleistRep.getBehandlungLeistungListe(daten, lgUid, null)
		for (HpBehandlungLeistung e : liste) {
			var l = leistungRep.get(daten, new HpLeistungKey(daten.mandantNr, e.leistungUid))
			if (l !== null) {
				var bl = new HpBehandlungLeistungLang
				bl.leistungUid = l.uid
				bl.leistungZiffer = l.ziffer
				bl.leistungZifferAlt = l.zifferAlt
				bl.leistungBeschreibungFett = l.beschreibungFett
				bl.leistungBeschreibung = l.beschreibung
				bl.dauer = e.dauer
				if (zus) {
					var sb = new StringBuffer(bl.leistungZiffer)
					Global.anhaengen(sb, ", ", bl.leistungBeschreibungFett)
					Global.anhaengen(sb, ", ", Global.dblStr2l(bl.dauer))
					bl.leistungBeschreibungFett = sb.toString
				}
				r.ergebnis.add(bl)
			}
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpBehandlungLang>> getBehandlungListe(ServiceDaten daten, boolean zusammengesetzt,
		String patientUid, LocalDate von, LocalDate bis) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpBehandlungLang>>(null)
		var liste = behandlungRep.getBehandlungLangListe(daten, patientUid, von, bis)
		if (zusammengesetzt) {
			for (HpBehandlungLang e : liste) {
				var strB = new StringBuffer(e.leistungZiffer)
				Global.anhaengen(strB, ", ", e.leistungBeschreibungFett)
				Global.anhaengen(strB, ", ", Global.dblStr2l(e.dauer))
				e.leistungBeschreibungFett = strB.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpBehandlung> getBehandlung(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpBehandlung>(behandlungRep.get(daten, new HpBehandlungKey(daten.mandantNr, uid)))
		return r
	}

	val private BiConsumer<HpBehandlung, HpBehandlungUpdate> behandlungEvent = [ HpBehandlung e, HpBehandlungUpdate u |

		var String uid
		var String puid
		var String luid
		var String suid
		var LocalDate datum
		var String besch
		if (e !== null) {
			uid = e.uid
			puid = e.patientUid
			luid = e.leistungUid
			suid = e.statusUid
			datum = e.datum
			besch = e.beschreibung
		} else if (u !== null) {
			uid = u.uid
			puid = u.patientUid
			luid = u.leistungUid
			suid = u.statusUid
			datum = u.datum
			besch = u.beschreibung
		}
		if (Global.nes(puid)) {
			throw new MeldungException(Meldungen.M2011)
		}
		if (Global.nes(luid)) {
			luid = ''
		// throw new MeldungException(Meldungen.M2035)
		}
		if (Global.nes(suid)) {
			throw new MeldungException(Meldungen.M2016)
		}
		if (datum === null) {
			throw new MeldungException(Meldungen.M2012)
		}
		if (Global.nes(besch)) {
			besch = ''
		}
		if (e !== null) {
			e.leistungUid = luid
			e.beschreibung = besch
		} else if (u !== null) {
			u.leistungUid = luid
			u.beschreibung = besch
		}
	]

	@Transaction
	override ServiceErgebnis<HpBehandlung> insertUpdateBehandlung(ServiceDaten daten, String uid, String patientUid,
		LocalDate datum, int dauer, String diagnose, String leistungUid, String statusUid, String mittel, String potenz,
		String dosierung, String verordnung, String notiz, List<HpBehandlungLeistungLang> leistungen) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var lliste = leistungen
		if (Global.arrayLaenge(leistungen) <= 0) {
			if (Global.nes(leistungUid)) {
				throw new MeldungException(Meldungen.M2035)
			}
			if (lliste === null) {
				lliste = new ArrayList<HpBehandlungLeistungLang>
			}
			var bh = new HpBehandlungLeistungLang
			bh.leistungUid = leistungUid
			bh.dauer = dauer
			lliste.add(bh)
		}
		var List<HpBehandlungLeistung> listeAlt = null
		if (!Global.nes(uid)) {
			listeAlt = behleistRep.getBehandlungLeistungListe(daten, uid, null)
		}

		var r = new ServiceErgebnis<HpBehandlung>(null)
		var String rechnungUid = null
		if (!Global.nes(uid)) {
			var b = behandlungRep.get(daten, new HpBehandlungKey(daten.mandantNr, uid))
			if (b !== null) {
				rechnungUid = b.rechnungUid
			}
		}
		var summe = lliste.map[it.dauer].reduce[sum, x|sum + x]
		var e = behandlungEvent // wegen Formatierung
		r.ergebnis = behandlungRep.iuHpBehandlung(daten, e, uid, patientUid, datum, summe, null, diagnose, 0,
			leistungUid, rechnungUid, statusUid, mittel, potenz, dosierung, verordnung, notiz, null, null, null, null)

		// Leistungen eintragen
		var buid = r.ergebnis.uid
		for (HpBehandlungLeistungLang vo : lliste) {
			var ll = behleistRep.getBehandlungLeistungListe(daten, buid, vo.leistungUid)
			if (ll.size > 0) {
				var b = ll.get(0)
				var voU = new HpBehandlungLeistungUpdate(b)
				voU.dauer = vo.dauer
				if (voU.isChanged) {
					voU.machGeaendert(daten.getJetzt, daten.getBenutzerId)
					behleistRep.update(daten, voU)
				}
				if (listeAlt !== null) {
					// Löschen aus der alten Liste
					var HpBehandlungLeistung d = null
					for (HpBehandlungLeistung vo2 : listeAlt) {
						if (Global.compString(vo2.leistungUid, vo.leistungUid) == 0) {
							d = vo2
						}
					}
					if (d !== null) {
						listeAlt.remove(d)
					}
				}
			} else {
				behleistRep.iuHpBehandlungLeistung(daten, null, null, buid, vo.leistungUid, vo.dauer, null, null, null,
					null, null)
			}
		}
		if (listeAlt !== null) {
			// Leistungen entfernen.
			for (HpBehandlungLeistung vo : listeAlt) {
				behleistRep.delete(daten, vo)
			}
		}

		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteBehandlung(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		behandlungRep.delete(daten, new HpBehandlungKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportPatientenakte(ServiceDaten daten, String patientUid, LocalDate von,
		LocalDate bis) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (patientUid === null) {
			throw new MeldungException(Meldungen.M2011)
		}

		// Patient
		var p = patientRep.get(daten, new HpPatientKey(daten.mandantNr, patientUid))
		if (p === null) {
			throw new MeldungException(Meldungen.M2011)
		}
		// Behandlungen
		var list = new ArrayList<HpBehandlungDruck>
		var liste = behandlungRep.getBehandlungLangListe(daten, patientUid, von, bis)
		for (HpBehandlungLang e : liste) {
			var z = new HpBehandlungDruck
			z.setDatum(e.getDatum)
			z.setLeistung(e.getDiagnose)
			var sb = new StringBuffer
			sb.append(e.getNotiz)
			var leer = Global.nes(e.mittel) && Global.nes(e.potenz) && Global.nes(e.dosierung) &&
				Global.nes(e.verordnung)
			if (!leer) {
				sb.append("\n")
				Global.anhaengen(sb, " ", e.mittel)
				Global.anhaengen(sb, " ", e.potenz)
				Global.anhaengen(sb, " ", e.dosierung)
				Global.anhaengen(sb, " ", e.verordnung)
			}
			z.setLeistung2(sb.toString)
			if (!Global.nes(z.leistung) || !Global.nes(z.leistung2)) {
				// leere Sätze ignorieren
				list.add(z)
			}
		}
		Collections.sort(list, new Comparator<HpBehandlungDruck> {

			override compare(HpBehandlungDruck o1, HpBehandlungDruck o2) {
				if (o1.datum !== null && o2.datum !== null) {
					return o1.datum.compareTo(o2.datum)
				}
				return 0
			}
		})
		var doc = newFopDokument
		doc.addPatientenakte(true, von, bis, p, list)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HpRechnungLang>> getRechnungListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HpRechnungLang>>(null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Datum DESC, a.Rechnungsnummer DESC, a.Uid DESC")
		var liste = rechnungRep.getListeLang(daten, daten.mandantNr, null, order)
		if (zusammengesetzt) {
			for (HpRechnungLang e : liste) {
				var strB = new StringBuffer(e.patientName)
				Global.anhaengen(strB, ", ", e.patientVorname)
				e.patientName = strB.toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getRechnungsnummer(ServiceDaten daten, String uid, LocalDate datum) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>("")
		if (datum === null) {
			return r
		}
		var rliste = rechnungRep.getRechnungListe(daten, null, uid, datum)
		if (rliste.length <= 0) {
			r.ergebnis = datum.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + '01'
		} else {
			r.ergebnis = Global.lngStr(Global.strLng(rliste.get(0).rechnungsnummer) + 1)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HpRechnung> getRechnung(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HpRechnung>(rechnungRep.get(daten, new HpRechnungKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<HpRechnung> insertUpdateRechnung(ServiceDaten daten, String uid, String rnr,
		LocalDate datum, String patientUid, double betrag, String diagnose, String statusUid, String notiz,
		List<HpBehandlungLeistungLang> bliste) {

		if (Global.arrayLaenge(bliste) <= 0) {
			throw new MeldungException(Meldungen.M2013)
		}
		var r = new ServiceErgebnis<HpRechnung>(null)
		var summe = 0.0
		var List<HpBehandlung> listeAlt = null
		if (!Global.nes(uid)) {
			listeAlt = behandlungRep.getBehandlungListe(daten, uid)
		}
		// Summe berechnen
		for (HpBehandlungLeistungLang vo : bliste) {
			summe += vo.leistungBetrag
		}
		if (Global.compDouble(summe, 0) <= 0) {
			throw new MeldungException(Meldungen.M2037)
		}
		r.ergebnis = rechnungRep.iuHpRechnung(daten, null, uid, rnr, datum, patientUid, summe, diagnose, statusUid,
			notiz, null, null, null, null)
		var enr = r.ergebnis.uid
		// Rechnung-Nr. in Behandlungen eintragen
		for (HpBehandlungLeistungLang vo : bliste) {
			var b = behandlungRep.get(daten, new HpBehandlungKey(daten.mandantNr, vo.behandlungUid))
			if (b !== null) {
				var voU = new HpBehandlungUpdate(b)
				voU.rechnungUid = enr
				if (!Global.nes(statusUid)) {
					voU.statusUid = statusUid
				}
				if (voU.isChanged) {
					voU.machGeaendert(daten.getJetzt, daten.getBenutzerId)
					behandlungRep.update(daten, voU)
				}
				if (listeAlt !== null) {
					// Löschen aus der alten Liste
					var HpBehandlung d = null
					for (HpBehandlung vo2 : listeAlt) {
						if (Global.compString(vo2.uid, vo.behandlungUid) == 0) {
							d = vo2
						}
					}
					if (d !== null) {
						listeAlt.remove(d)
					}
				}
			}
		}
		if (listeAlt !== null) {
			// Rechnung-Nr. aus Behandlungen entfernen.
			for (HpBehandlung vo : listeAlt) {
				var voU = new HpBehandlungUpdate(vo)
				voU.rechnungUid = null
				if (voU.isChanged) {
					voU.machGeaendert(daten.getJetzt, daten.getBenutzerId)
					behandlungRep.update(daten, voU)
				}
			}
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteRechnung(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		// Rechnung-Nr. aus Behandlungen entfernen.
		var bliste = behandlungRep.getBehandlungListe(daten, uid)
		for (HpBehandlung b : bliste) {
			var u = new HpBehandlungUpdate(b)
			u.rechnungUid = null
			if (u.isChanged) {
				u.machGeaendert(daten.getJetzt, daten.getBenutzerId)
				behandlungRep.update(daten, u)
			}
		}
		var key = new HpRechnungKey(daten.mandantNr, uid)
		rechnungRep.delete(daten, key)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	private def List<MaParameter> getEinstellungListeIntern(ServiceDaten daten, int mandantNr) {

		var pliste = Parameter.parameter.values.filter[schluessel.startsWith("HP_")]
		var liste = new ArrayList<MaParameter>
		for (Parameter p : pliste) {
			var e = parameterRep.get(daten, new MaParameterKey(mandantNr, p.schluessel))
			if (e === null) {
				e = new MaParameter
				e.mandantNr = mandantNr
				e.schluessel = p.schluessel
				e.wert = p.wert
			}
			liste.add(e)
		}
		return liste
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportRechnung(ServiceDaten daten, String uid) {

		// getBerechService().pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (uid === null) {
			throw new MeldungException(Meldungen.M2038)
		}

		// Rechnung
		var re = rechnungRep.get(daten, new HpRechnungKey(daten.mandantNr, uid))
		if (re === null) {
			throw new MeldungException(Meldungen.M2038)
		}
		var p = patientRep.get(daten, new HpPatientKey(daten.mandantNr, re.patientUid))
		if (p === null) {
			throw new MeldungException(Meldungen.M2011)
		}
		var HpPatient p2 = null
		if (!Global.nes(p.rechnungPatientUid)) {
			p2 = patientRep.get(daten, new HpPatientKey(daten.mandantNr, p.rechnungPatientUid))
			if (p2 === null) {
				throw new MeldungException(Meldungen.M2011)
			}
		} else {
			p2 = p
		}

		// Behandlungen
		val mpProzent = Pattern.compile("(\\{\\d+\\,?\\d*%\\})")
		val mpDauer = Pattern.compile("(\\{Dauer\\})", Pattern.CASE_INSENSITIVE)
		var list = new ArrayList<HpBehandlungDruck>
		var liste = behleistRep.getBehandlungLangListe(daten, null, uid, null, null, null, false)
		for (HpBehandlungLeistungLang e : liste) {
			var z = new HpBehandlungDruck
			z.datum = e.behandlungDatum
			z.ziffer = e.leistungZiffer
			z.zifferAlt = e.getLeistungZifferAlt
			z.leistung = e.leistungBeschreibungFett
			var leistung = e.leistungBeschreibung
			if (Global.nes(leistung)) {
				leistung = ""
			}
			var m = mpProzent.matcher(leistung)
			if (m.find) {
				var sbl = new StringBuffer
				var start = 0
				do {
					sbl.append(leistung.substring(start, m.start))
					var d = Global.strDbl(leistung.substring(m.start + 1, m.end - 2)) / 100.0
					sbl.append(Global.dblStr2l(e.leistungBetrag * d))
					start = m.end
				} while (m.find)
				sbl.append(leistung.substring(start))
				leistung = sbl.toString
			}
			m = mpDauer.matcher(leistung)
			if (m.find) {
				var sbl = new StringBuffer
				var start = 0
				do {
					sbl.append(leistung.substring(start, m.start))
					sbl.append(e.dauer)
					start = m.end
				} while (m.find)
				sbl.append(leistung.substring(start))
				leistung = sbl.toString
			}
			z.leistung2 = leistung
			z.betrag = e.leistungBetrag
			z.dauer = e.dauer
			if (z.leistung !== null) {
				// leere Sätze ignorieren
				list.add(z)
			}
		}
		var zahldatum = re.datum.plusDays(14)
		var eliste = getEinstellungListeIntern(daten, daten.mandantNr)
		var emap = new HashMap<String, String>
		for (MaParameter e : eliste) {
			emap.put(e.schluessel, e.wert)
		}
		var doc = newFopDokument
		doc.addRechnung(true, re, p, p2, zahldatum, list, emap)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}
}

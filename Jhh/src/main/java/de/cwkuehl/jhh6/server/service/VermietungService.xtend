package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.HhBuchungVm
import de.cwkuehl.jhh6.api.dto.HhEreignisVm
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.HhKontoVm
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.VmAbrechnung
import de.cwkuehl.jhh6.api.dto.VmAbrechnungKey
import de.cwkuehl.jhh6.api.dto.VmAbrechnungKurz
import de.cwkuehl.jhh6.api.dto.VmAbrechnungLang
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmHausKey
import de.cwkuehl.jhh6.api.dto.VmKonto
import de.cwkuehl.jhh6.api.dto.VmMiete
import de.cwkuehl.jhh6.api.dto.VmMieteKey
import de.cwkuehl.jhh6.api.dto.VmMieteLang
import de.cwkuehl.jhh6.api.dto.VmMieter
import de.cwkuehl.jhh6.api.dto.VmMieterKey
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnung
import de.cwkuehl.jhh6.api.dto.VmWohnungKey
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
import de.cwkuehl.jhh6.api.enums.VmAbrechnungSchluesselEnum
import de.cwkuehl.jhh6.api.enums.VmBuchungSchluesselEnum
import de.cwkuehl.jhh6.api.enums.VmKontoSchluesselEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.global.Parameter
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.ServiceRef
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.fop.dto.FoHaus
import de.cwkuehl.jhh6.server.fop.dto.FoMieter
import de.cwkuehl.jhh6.server.fop.dto.FoWohnung
import de.cwkuehl.jhh6.server.fop.dto.FoZeile
import de.cwkuehl.jhh6.server.fop.impl.FoUtils
import de.cwkuehl.jhh6.server.rep.impl.HhBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.HhEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.HhKontoRep
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.VmAbrechnungRep
import de.cwkuehl.jhh6.server.rep.impl.VmBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.VmEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.VmHausRep
import de.cwkuehl.jhh6.server.rep.impl.VmKontoRep
import de.cwkuehl.jhh6.server.rep.impl.VmMieteRep
import de.cwkuehl.jhh6.server.rep.impl.VmMieterRep
import de.cwkuehl.jhh6.server.rep.impl.VmWohnungRep
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.HashMap
import java.util.List

@Service
class VermietungService {

	@ServiceRef HaushaltService haushaltService
	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef HhBuchungRep buchungRep
	@RepositoryRef HhEreignisRep ereignisRep
	@RepositoryRef HhKontoRep kontoRep
	@RepositoryRef VmAbrechnungRep abrechnungRep
	@RepositoryRef VmBuchungRep vmbuchungRep
	@RepositoryRef VmEreignisRep vmereignisRep
	@RepositoryRef VmHausRep hausRep
	@RepositoryRef VmKontoRep vmkontoRep
	@RepositoryRef VmMieteRep mieteRep
	@RepositoryRef VmMieterRep mieterRep
	@RepositoryRef VmWohnungRep wohnungRep

	@Transaction(false)
	override ServiceErgebnis<List<VmHaus>> getHausListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<VmHaus>>(null)
		var liste = hausRep.getHausListe(daten, null, null)
		if (zusammengesetzt) {
			for (VmHaus e : liste) {
				e.setBezeichnung = Global.anhaengen(
					Global.anhaengen(Global.anhaengen(new StringBuffer(e.bezeichnung), ", ", e.strasse), ", ", e.plz),
					" ", e.ort).toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmHaus> getHaus(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<VmHaus>(hausRep.get(daten, new VmHausKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction
	override ServiceErgebnis<VmHaus> insertUpdateHaus(ServiceDaten daten, String uid, String bez, String strasse,
		String plz, String ort, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(bez)) {
			throw new MeldungException(Meldungen::VM001)
		}
		var e = hausRep.iuVmHaus(daten, null, uid, bez, strasse, plz, ort, notiz, null, null, null, null)
		var r = new ServiceErgebnis<VmHaus>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteHaus(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var wliste = wohnungRep.getWohnungLangListe(daten, null, uid)
		if (Global.listLaenge(wliste) > 0) {
			throw new MeldungException(Meldungen::VM003)
		}
		hausRep.delete(daten, new VmHausKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<VmWohnungLang>> getWohnungListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<VmWohnungLang>>(null)
		var liste = wohnungRep.getWohnungLangListe(daten, null, null)
		if (zusammengesetzt) {
			for (VmWohnungLang e : liste) {
				e.bezeichnung = Global.anhaengen(new StringBuffer(e.bezeichnung), ", ", e.hausBezeichnung).toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmWohnungLang> getWohnungLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<VmWohnungLang>(null)
		var l = wohnungRep.getWohnungLangListe(daten, uid, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<VmWohnung> insertUpdateWohnung(ServiceDaten daten, String uid, String hausUid, String bez,
		String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(hausUid)) {
			throw new MeldungException(Meldungen::VM002)
		}
		if (Global.nes(bez)) {
			throw new MeldungException(Meldungen::VM001)
		}
		var e = wohnungRep.iuVmWohnung(daten, null, uid, hausUid, bez, notiz, null, null, null, null)
		var r = new ServiceErgebnis<VmWohnung>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteWohnung(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var mliste = mieterRep.getMieterLangListe(daten, null, uid, null, null, null, false)
		if (Global.listLaenge(mliste) > 0) {
			throw new MeldungException(Meldungen::VM004)
		}
		var liste = mieteRep.getMieteLangListe(daten, null, uid, null, null)
		if (Global.listLaenge(liste) > 0) {
			throw new MeldungException(Meldungen::VM005)
		}
		wohnungRep.delete(daten, new VmWohnungKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<VmMieterLang>> getMieterListe(ServiceDaten daten, boolean zusammengesetzt,
		LocalDate von, LocalDate bis, String hausUid, String wohnungUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<VmMieterLang>>(null)
		var liste = mieterRep.getMieterLangListe(daten, null, wohnungUid, von, bis, hausUid, false)
		if (zusammengesetzt) {
			for (VmMieterLang e : liste) {
				e.name = Global.anhaengen(new StringBuffer(e.name), ", ", e.vorname).toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmMieterLang> getMieterLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<VmMieterLang>(null)
		var l = mieterRep.getMieterLangListe(daten, uid, null, null, null, null, false)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<VmMieter> insertUpdateMieter(ServiceDaten daten, String uid, String wohnungUid,
		String name, String vorname, String anrede, LocalDate einzug, LocalDate auszug, double qm, double miete,
		double kaution, double antenne, int status, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(wohnungUid)) {
			throw new MeldungException(Meldungen::VM006)
		}
		if (Global.nes(name)) {
			throw new MeldungException(Meldungen::VM008)
		}
		if (einzug === null) {
			throw new MeldungException(Meldungen::VM009)
		}
		var e = mieterRep.iuVmMieter(daten, null, uid, wohnungUid, name, vorname, anrede, einzug, auszug, qm, miete,
			kaution, antenne, status, notiz, null, null, null, null)
		var r = new ServiceErgebnis<VmMieter>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteMieter(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		mieterRep.delete(daten, new VmMieterKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportMieterliste(ServiceDaten daten, LocalDate von, LocalDate bis,
		String hausUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var haeuser = new ArrayList<FoHaus>
		var hliste = hausRep.getHausListe(daten, hausUid, null)
		if (Global.listLaenge(hliste) <= 0) {
			throw new MeldungException(Meldungen::VM002)
		}

		var periode = Global.getPeriodeString(von, bis, false)
		var ueberschrift = Meldungen::VM010(periode, daten.jetzt)
		for (VmHaus h : hliste) {
			var haus = new FoHaus
			haus.bezeichnung = h.bezeichnung
			haus.hort = Global.anhaengen(h.plz, " ", h.ort)
			haus.hstrasse = h.strasse
			haus.von = von
			haus.bis = bis
			haeuser.add(haus)
			var wliste = wohnungRep.getWohnungLangListe(daten, null, h.uid)
			for (VmWohnungLang w : wliste) {
				var wohnung = new FoWohnung
				wohnung.bezeichnung = w.bezeichnung
				haus.wohnungen.add(wohnung)
				var mliste = mieterRep.getMieterLangListe(daten, null, w.uid, von, bis, null, true)
				for (VmMieterLang m : mliste) {
					var mieter = new FoMieter
					mieter.name = Global.anhaengen(m.vorname, " ", m.name)
					mieter.von = m.einzugdatum
					mieter.bis = m.auszugdatum
					mieter.qm = m.wohnungQm
					mieter.grundmiete = m.wohnungGrundmiete
					mieter.kaution = m.wohnungKaution
					mieter.antenne = m.wohnungAntenne
					var datum = von
					if (datum === null || datum.isBefore(m.einzugdatum)) {
						datum = m.einzugdatum
					}
					var aliste = abrechnungRep.getAbrechnungLangListe(daten, null,
						VmAbrechnungSchluesselEnum.W_WOHNFLAECHE.toString, null, w.uid, null, null, bis, null, null)
					if (Global.listLaenge(aliste) > 0) {
						wohnung.qm = aliste.get(0).betrag
					}
					var miete = getMieteSollstellungIntern(daten, datum, h.uid, w.uid, null, false)
					if (miete !== null) {
						mieter.bkvoraus = miete.nebenkosten + miete.heizung
						mieter.monate = miete.personen
					}
					wohnung.mieter.add(mieter)
				}
				if (mliste.size <= 0) {
					var mieter = new FoMieter
					mieter.setName(Meldungen::VM011)
					wohnung.mieter.add(mieter)
				}
			}
		}
		var doc = newFopDokument
		doc.addMieterliste(true, ueberschrift, von, bis, haeuser)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	def private VmMieteLang getMieteSollstellungIntern(ServiceDaten daten, LocalDate valuta, String hausUid,
		String wohnungUid, String mieterUid, boolean summe) {

		var wuid = wohnungUid
		var v = valuta.withDayOfMonth(1)
		var vo = new VmMieteLang
		if (!Global.nes(mieterUid)) {
			var m = mieterRep.get(daten, new VmMieterKey(daten.mandantNr, mieterUid))
			if (m !== null) {
				wuid = m.wohnungUid
			}
		}
		var liste = mieteRep.getMieteLangListe(daten, null, wuid, hausUid, v)
		if (summe) {
			for (VmMieteLang e : liste) {
				vo.miete = vo.miete + e.miete + e.garage
				vo.nebenkosten = vo.nebenkosten + e.nebenkosten + e.heizung
			}
		} else {
			if (!liste.isEmpty) {
				vo = liste.get(0)
			}
		}
		return vo
	}

	@Transaction(false)
	override ServiceErgebnis<List<VmMieteLang>> getMieteListe(ServiceDaten daten, boolean zusammengesetzt,
		String wohnungUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<VmMieteLang>>(null)
		var liste = mieteRep.getMieteLangListe(daten, null, wohnungUid, null, null)
		if (zusammengesetzt) {
			for (VmMieteLang e : liste) {
				e.miete = e.miete + e.garage
				e.nebenkosten = e.nebenkosten + e.heizung
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmMieteLang> getMieteLang(ServiceDaten daten, boolean zusammengesetzt, String uid,
		String wohnungUid, LocalDate datum) {

		var r = new ServiceErgebnis<VmMieteLang>(null)
		var l = mieteRep.getMieteLangListe(daten, uid, wohnungUid, null, datum)
		if (l.size > 0) {
			var m = l.get(0)
			var summe = 0.0
			var sb = new StringBuffer(Meldungen::VM012)
			sb.append(Global.dateTimeStringForm(m.datum.atStartOfDay))
			if (Global.compDouble(m.miete, 0) > 0) {
				summe += m.miete
				sb.append(Meldungen::VM013).append(Global.dblStr2l(m.miete))
			}
			if (Global.compDouble(m.garage, 0) > 0) {
				summe += m.garage
				sb.append(Meldungen::VM014).append(Global.dblStr2l(m.garage))
			}
			if (Global.compDouble(m.nebenkosten, 0) > 0) {
				summe += m.nebenkosten
				sb.append(Meldungen::VM015).append(Global.dblStr2l(m.nebenkosten))
			}
			if (Global.compDouble(m.heizung, 0) > 0) {
				summe += m.heizung
				sb.append(Meldungen::VM016).append(Global.dblStr2l(m.heizung))
			}
			if (Global.compDouble(summe, 0) > 0) {
				sb.append(Meldungen::VM017).append(Global.dblStr2l(summe))
			}
			if (m.personen > 0) {
				sb.append(Meldungen::VM018).append(Global.intStr(m.personen))
			}
			m.text1 = sb.toString
			r.ergebnis = m
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<VmMiete> insertUpdateMiete(ServiceDaten daten, String uid, String wohnungUid,
		LocalDate datum, double miete, double nebenkosten, double garage, double heizung, int personen, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(wohnungUid)) {
			throw new MeldungException(Meldungen::VM006)
		}
		if (datum === null) {
			throw new MeldungException(Meldungen::VM019)
		}
		var e = mieteRep.iuVmMiete(daten, null, uid, wohnungUid, datum, miete, nebenkosten, garage, heizung, personen,
			notiz, null, null, null, null)
		var r = new ServiceErgebnis<VmMiete>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteMiete(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		mieteRep.delete(daten, new VmMieteKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
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

	/**
	 * Liefert Value Object mit passenden Buchungen.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param valutasuche Datumssuche nach Valuta?
	 * @param dVon Valuta-Anfangsdatum.
	 * @param dBis Valuta-Enddatum.
	 * @param strText Such-String für Buchungstext.
	 * @param kontoUid Such-Konto-Nummer.
	 * @param strBetrag Such-String für Buchungsbetrag.
	 * @return Value Object mit passenden Buchungen.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<HhBuchungVm>> getBuchungListe(ServiceDaten daten, boolean valutasuche, LocalDate von,
		LocalDate bis, String text, String kontoUid, String betrag, String huid, String wuid, String mieterUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhBuchungVm>>(null)
		var euro = isEuroIntern
		r.ergebnis = buchungRep.getBuchungVmListe(daten, euro, valutasuche, null, von, bis, text, kontoUid, betrag,
			null, null, huid, wuid, mieterUid)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhBuchungVm> getBuchungVm(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhBuchungVm>(null)
		var euro = isEuroIntern
		var l = buchungRep.getBuchungVmListe(daten, euro, false, uid, null, null, null, null, null, null, null, null,
			null, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmMieteLang> getMieteSollstellung(ServiceDaten daten, LocalDate valuta, String hausUid,
		String wohnungUid, String mieterUid, boolean summe) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<VmMieteLang>(
			getMieteSollstellungIntern(daten, valuta, hausUid, wohnungUid, mieterUid, summe))
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> insertSollstellung(ServiceDaten daten, LocalDate valuta, String hausUid,
		String wohnungUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (hausUid === null && wohnungUid === null) {
			throw new MeldungException(Meldungen::VM020)
		}
		var v = valuta.withDayOfMonth(1)
		var buchung = false
		var euro = isEuroIntern
		var mietforderung = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP200_MIETFORDERUNGEN.toString)
		var sollmiete = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP600_SOLLMIETEN.toString)
		var anzahlung = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP431_ANZAHLUNG.toString)
		var liste = mieteRep.getMieteLangListe(daten, null, wohnungUid, hausUid, v)
		for (VmMieteLang e : liste) {
			var mliste = mieterRep.getMieterLangListe(daten, null, e.wohnungUid, v, v, null, true)
			var mieter = if(mliste.size > 0) mliste.get(0) else null
			if (mieter !== null && (mieter.auszugdatum === null || mieter.auszugdatum.isAfter(valuta))) {
				var schluessel = VmBuchungSchluesselEnum.MIET_SOLL.toString
				var bliste = buchungRep.getBuchungVmListe(daten, euro, true, null, v, v, null, null, null,
					Constant.KZB_AKTIV, schluessel, null, e.wohnungUid, null)
				if (bliste.empty) {
					var ebetrag = e.miete + e.garage
					var betrag = Global.konvDM(ebetrag)
					var btext = Meldungen::VM022(v.atStartOfDay, mieter.wohnungBezeichnung, mieter.name)
					haushaltService.insertUpdateBuchung(daten, null, v, betrag, ebetrag, mietforderung, sollmiete,
						btext, null, v, schluessel, e.hausUid, e.wohnungUid, mieter.uid, null, true)
					buchung = true
				}
				schluessel = VmBuchungSchluesselEnum.NK_SOLL.toString
				bliste = buchungRep.getBuchungVmListe(daten, euro, true, null, v, v, null, null, null,
					Constant.KZB_AKTIV, schluessel, null, e.wohnungUid, null)
				if (bliste.empty) {
					var ebetrag = e.nebenkosten + e.heizung
					var betrag = Global.konvDM(ebetrag)
					var btext = Meldungen::VM023(v.atStartOfDay, mieter.wohnungBezeichnung, mieter.name)
					haushaltService.insertUpdateBuchung(daten, null, v, betrag, ebetrag, mietforderung, anzahlung,
						btext, null, v, schluessel, e.hausUid, e.wohnungUid, mieter.uid, null, true)
					buchung = true
				}
			}
		}
		if (!buchung) {
			throw new MeldungException(Meldungen::VM021)
		}

		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> insertIstzahlung(ServiceDaten daten, LocalDate valuta, LocalDate belegDatum,
		String mieterUid, double miete, double nebenkosten, double garage, double heizung) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var summeMiete = miete + garage
		var summeBk = nebenkosten + heizung
		var v = valuta.withDayOfMonth(1)

		if (Global.nes(mieterUid)) {
			throw new MeldungException(Meldungen::VM024)
		}
		if (Global.compDouble(summeMiete, 0) <= 0 && Global.compDouble(summeBk, 0) <= 0) {
			throw new MeldungException(Meldungen::VM025)
		}

		var buchung = false
		var euro = isEuroIntern
		var liste = mieterRep.getMieterLangListe(daten, mieterUid, null, v, v, null, true)
		if (liste.isEmpty) {
			throw new MeldungException(Meldungen::VM026(mieterUid))
		}
		var mieter = liste.get(0)
		var hausUid = mieter.hausUid
		var wohnungUid = mieter.wohnungUid
		var mietforderung = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP200_MIETFORDERUNGEN.toString)
		var bank = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP2740_BANK.toString)

		if (Global.compDouble(summeMiete, 0) > 0) {
			var schluessel = VmBuchungSchluesselEnum.MIET_IST.toString
			var bliste = buchungRep.getBuchungVmListe(daten, euro, true, null, v, v, null, null, null,
				Constant.KZB_AKTIV, schluessel, null, wohnungUid, null)
			if (bliste.empty) {
				var ebetrag = summeMiete
				var betrag = Global.konvDM(ebetrag)
				var btext = Meldungen::VM029(v.atStartOfDay, mieter.wohnungBezeichnung, mieter.name)
				haushaltService.insertUpdateBuchung(daten, null, v, betrag, ebetrag, bank, mietforderung, btext, null,
					belegDatum, schluessel, hausUid, wohnungUid, mieterUid, null, true)
				buchung = true
			}
		}

		if (Global.compDouble(summeBk, 0) > 0) {
			var schluessel = VmBuchungSchluesselEnum.NK_IST.toString
			var bliste = buchungRep.getBuchungVmListe(daten, euro, true, null, v, v, null, null, null,
				Constant.KZB_AKTIV, schluessel, null, wohnungUid, null)
			if (bliste.empty) {
				var ebetrag = summeBk
				var betrag = Global.konvDM(ebetrag)
				var btext = Meldungen::VM030(v.atStartOfDay, mieter.wohnungBezeichnung, mieter.name)
				haushaltService.insertUpdateBuchung(daten, null, v, betrag, ebetrag, bank, mietforderung, btext, null,
					belegDatum, schluessel, hausUid, wohnungUid, mieterUid, null, true)
				buchung = true
			}
		}
		if (!buchung) {
			throw new MeldungException(Meldungen::VM021)
		}

		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private String getKontoNrIntern(ServiceDaten daten, String schluessel) {

		var vo = getKontoIntern(daten, schluessel)
		if (vo === null) {
			throw new MeldungException(Meldungen::VM027(schluessel))
		}
		return vo.uid
	}

	def private VmKonto getKontoIntern(ServiceDaten daten, String schluessel) {

		var liste = vmkontoRep.getKontoListe(daten, null, schluessel, null, null, null)
		if (liste.size > 0) {
			return liste.get(0)
		}
		return null
	}

	@Transaction
	override ServiceErgebnis<Void> initKonten(ServiceDaten daten) {

		var hash = new HashMap<String, VmKonto>
		var liste = vmkontoRep.getListe(daten, daten.mandantNr, null, null)
		for (VmKonto e : liste) {
			hash.put(e.schluessel, e)
		}
		for (VmKontoSchluesselEnum e : VmKontoSchluesselEnum.values) {
			var vo = hash.get(e.toString)
			if (vo === null) {
				var art = e.toString2.substring(0, 2)
				var name = e.toString2.substring(3)
				if (name.length > HhKonto.NAME_LAENGE) {
					name = name.substring(0, HhKonto.NAME_LAENGE)
				}
				var schluessel = e.toString
				var uid = kontoRep.getMinKonto(daten, null, null, null, name)
				if (Global.nes(uid)) {
					haushaltService.insertUpdateKonto(daten, null, art, "", name, null, null, schluessel, null, null,
						null, null, true)
				}
			}
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhKontoVm>> getKontoListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhKontoVm>>(null)
		r.ergebnis = kontoRep.getKontoVmListe(daten, null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhKontoVm> getKontoVm(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhKontoVm>(null)
		var l = kontoRep.getKontoVmListe(daten, uid)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhEreignisVm>> getEreignisListe(ServiceDaten daten, LocalDate von, LocalDate bis) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhEreignisVm>>(null)
		var list = ereignisRep.getEreignisVmListe(daten, null, null, von, bis)
		r.ergebnis = list
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhEreignisVm> getEreignisVm(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhEreignisVm>(null)
		var l = ereignisRep.getEreignisVmListe(daten, uid, null, null, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhBuchungVm>> getForderungListe(ServiceDaten daten, LocalDate von, LocalDate bis,
		String hausUid, String wohnungUid, String mieterUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var euro = isEuroIntern
		var mietforderung = getKontoNrIntern(daten, VmKontoSchluesselEnum.KP200_MIETFORDERUNGEN.toString)
		var result = buchungRep.getBuchungVmListe(daten, euro, true, null, von, bis, null, mietforderung, null,
			Constant.KZB_AKTIV, null, hausUid, wohnungUid, mieterUid)
		var hash = new HashMap<String, HhBuchungVm>
		var liste = new ArrayList<HhBuchungVm>
		for (HhBuchungVm b : result) {
			var b2 = hash.get(b.mieterUid)
			if (b2 === null) {
				b2 = b.clone
				b2.betrag = 0
				b2.ebetrag = 0
				hash.put(b2.mieterUid, b2)
				liste.add(b2)
			}
			if (Global.compString(b.sollKontoUid, mietforderung) == 0) {
				b2.betrag = b2.betrag + b.ebetrag
			} else {
				b2.ebetrag = b2.ebetrag + b.ebetrag
			}
		}
		for (HhBuchungVm b : hash.values) {
			if (Global.compDouble(b.betrag, b.ebetrag) == 0) {
				liste.remove(b)
			}
		}
		var r = new ServiceErgebnis<List<HhBuchungVm>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<VmAbrechnungKurz>> getAbrechnungKurzListe(ServiceDaten daten, LocalDate datum,
		String hausUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = abrechnungRep.getAbrechnungKurzListe(daten, datum, hausUid, "null", "null")
		var r = new ServiceErgebnis<List<VmAbrechnungKurz>>(liste)
		return r
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

	@Transaction
	override ServiceErgebnis<Void> insertHausAbrechnung(ServiceDaten daten, LocalDate von, LocalDate bis,
		String hausUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = 1
		var String wohnungUid
		var String mieterUid
		var VmAbrechnungSchluesselEnum e
		var String wert
		var Double betrag
		var LocalDate datum
		if (Global.nes(hausUid)) {
			throw new MeldungException(Meldungen::VM002)
		}
		var haus = hausRep.get(daten, new VmHausKey(daten.mandantNr, hausUid))
		if (haus === null) {
			throw new MeldungException(Meldungen::VM002)
		}

		e = VmAbrechnungSchluesselEnum.H_DATUM
		wert = null
		betrag = null
		datum = bis.plusMonths(3)
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, true)
		e = VmAbrechnungSchluesselEnum.VM_NAME
		wert = getParameter(daten, Parameter.VM_NAME).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.VM_STRASSE
		wert = getParameter(daten, Parameter.VM_STRASSE).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.VM_ORT
		wert = getParameter(daten, Parameter.VM_ORT).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.VM_TELEFON
		wert = getParameter(daten, Parameter.VM_TELEFON).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.H_STRASSE
		wert = haus.strasse
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, true)
		e = VmAbrechnungSchluesselEnum.H_ORT
		wert = Global.anhaengen(haus.plz, " ", haus.ort)
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, true)
		e = VmAbrechnungSchluesselEnum.H_GUTHABEN
		wert = getParameter(daten, Parameter.VM_H_GUTHABEN).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.H_NACHZAHLUNG
		wert = getParameter(daten, Parameter.VM_H_NACHZAHLUNG).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.H_GRUESSE
		wert = getParameter(daten, Parameter.VM_H_GRUESSE).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.H_ANLAGE
		wert = getParameter(daten, Parameter.VM_H_ANLAGE).wert
		betrag = null
		datum = null
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, wert, betrag, datum, false)
		e = VmAbrechnungSchluesselEnum.H_GRUNDSTEUER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_STRASSENREINIGUNG
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_ABFALL
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_STROM
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_NIEDERSCHLAGSWASSER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_WOHNVERSICHERUNG
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_HAFTVERSICHERUNG
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_GLASVERSICHERUNG
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_DACHREINIGUNG
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_SCHORNSTEINFEGER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_GARTEN
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_TRINKWASSER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_SCHMUTZWASSER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_NIEDERSCHLAGSWASSER
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_WOHNFL_KORR
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		e = VmAbrechnungSchluesselEnum.H_PERSMON_KORR
		iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		var listeW = wohnungRep.getWohnungLangListe(daten, null, hausUid)
		for (VmWohnungLang w : listeW) {
			wohnungUid = w.uid
			e = VmAbrechnungSchluesselEnum.W_WOHNFLAECHE
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, von, bis, e, r++, null, null, null, false)
		}
		var listeM = mieterRep.getMieterLangListe(daten, null, null, von, bis, hausUid, false)
		for (VmMieterLang m : listeM) {
			wohnungUid = m.wohnungUid
			mieterUid = m.uid
			var mvon = von
			var mbis = bis
			if (m.einzugdatum !== null && m.einzugdatum.isAfter(mvon)) {
				mvon = m.einzugdatum
			}
			if (m.auszugdatum !== null && m.auszugdatum.isBefore(bis)) {
				mbis = m.auszugdatum
			}
			e = VmAbrechnungSchluesselEnum.M_ANREDE
			wert = m.anrede
			betrag = null
			datum = null
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, wert, betrag, datum, true)
			e = VmAbrechnungSchluesselEnum.M_NAME
			wert = Global.anhaengen(m.vorname, " ", m.name)
			betrag = null
			datum = null
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, wert, betrag, datum, true)
			e = VmAbrechnungSchluesselEnum.M_STRASSE
			wert = haus.strasse
			betrag = null
			datum = null
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, wert, betrag, datum, true)
			e = VmAbrechnungSchluesselEnum.M_ORT
			wert = Global.anhaengen(haus.plz, " ", haus.ort)
			betrag = null
			datum = null
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, wert, betrag, datum, true)
			e = VmAbrechnungSchluesselEnum.M_PERSONENMONATE
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_BK_VORAUS
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_HK_VORAUS
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_HK_ABRECHNUNG
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_ANTENNE
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_GARTEN
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_WASSER_ANFANG
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_WASSER_ENDE
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
			e = VmAbrechnungSchluesselEnum.M_PERSMON_KORR
			iuAbrechnungVorlage(daten, hausUid, wohnungUid, mieterUid, mvon, mbis, e, r++, null, null, null, false)
		}
		var r0 = new ServiceErgebnis<Void>(null)
		return r0
	}

	/**
	 * @param daten
	 * @param hausUid
	 * @param wohnungUid
	 * @param mieterUid
	 * @param von
	 * @param bis
	 * @param e
	 * @param r
	 * @param wert
	 * @param betrag
	 * @param datum
	 * @param werteVorrang true: wert, betrag, datum werden in einem neuen Datensatz oder Kopie übernommen; false: wert,
	 *        betrag, datum werden nur in neuen Datensatz oder Kopie übernommen
	 * @throws JhhException
	 */
	def private void iuAbrechnungVorlage(ServiceDaten daten, String hausUid, String wuid, String mieterUid,
		LocalDate von, LocalDate bis, VmAbrechnungSchluesselEnum e, int r, String wert, Double betrag, LocalDate datum,
		boolean werteVorrang) {

		// Kopiervorlage lesen
		var neu = false;
		var kopie = false;
		// Kopiervorlage lesen
		var aliste = abrechnungRep.getAbrechnungLangListe(daten, null, e.toString, hausUid,
			if(wuid === null) "null" else wuid, if(mieterUid === null) "null" else mieterUid, null, null, von, null)
		var a = if(aliste.size > 0) aliste.get(0) else null
		if (a === null) {
			a = new VmAbrechnungLang
			a.beschreibung = e.toString2
			a.reihenfolge = Global.format("{0,number,000}", r)
			a.status = Constant.KZB_AKTIV
			neu = true
		} else if (von.isAfter(a.datumVon) || bis.isBefore(a.datumBis)) {
			// !(von <= DatumVon und DatumBis <= bis)
			// Satz aus anderem Abrechnungszeitraum: neuen Satz einfügen
			a.uid = null
			kopie = true
		}
		if (neu || (kopie && werteVorrang)) {
			if (wert !== null) {
				a.wert = wert
			}
			if (betrag !== null) {
				a.betrag = betrag
			}
			if (datum !== null) {
				a.datum = datum.atStartOfDay
			}
		}
		abrechnungRep.iuVmAbrechnung(daten, null, a.uid, hausUid, wuid, mieterUid, von, bis, e.toString, a.beschreibung,
			a.wert, a.betrag, a.datum, a.reihenfolge, a.status, a.funktion, a.notiz, null, null, null, null)
	}

	@Transaction
	override ServiceErgebnis<Void> deleteHausAbrechnung(ServiceDaten daten, LocalDate von, LocalDate bis,
		String hausUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		// Intervall vollständig im Zeitraum: von <= DatumVon und DatumBis <= bis
		var liste = abrechnungRep.getAbrechnungLangListe(daten, null, null, hausUid, null, null, von, bis, null, null)
		for (VmAbrechnungLang e : liste) {
			abrechnungRep.delete(daten, new VmAbrechnungKey(daten.mandantNr, e.uid))
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getSchluesselListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = new ArrayList<MaEinstellung>
		for (VmAbrechnungSchluesselEnum e : VmAbrechnungSchluesselEnum.values) {
			var m = new MaEinstellung
			m.schluessel = e.toString
			m.wert = '''«e.toString» «e.toString2»'''
			liste.add(m)
		}
		var r = new ServiceErgebnis<List<MaEinstellung>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<VmAbrechnungLang>> getAbrechnungListe(ServiceDaten daten, LocalDate von,
		LocalDate bis, String hausUid, String wohnungUid, String mieterUid, String schluessel) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = abrechnungRep.getAbrechnungLangListe(daten, null, schluessel, hausUid, wohnungUid, mieterUid, von,
			bis, null, null)
		var r = new ServiceErgebnis<List<VmAbrechnungLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<VmAbrechnungLang> getAbrechnungLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<VmAbrechnungLang>(null)
		var l = abrechnungRep.getAbrechnungLangListe(daten, uid, null, null, null, null, null, null, null, null)
		if (l.size > 0) {
			r.ergebnis = l.get(0)
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<VmAbrechnung> insertUpdateAbrechnung(ServiceDaten daten, String uid, String hausUid,
		String wohnungUid, String mieterUid, LocalDate von, LocalDate bis, String schluessel, String beschreibung,
		String wert, double betrag, LocalDateTime datum, String reihenfolge, String status, String funktion, //
		String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(hausUid)) {
			throw new MeldungException(Meldungen::VM002)
		}
		if (Global.nes(schluessel)) {
			throw new MeldungException(Meldungen::VM007)
		}
		var haus = hausRep.get(daten, new VmHausKey(daten.mandantNr, hausUid))
		if (haus === null) {
			throw new MeldungException(Meldungen::VM002)
		}
		var e = abrechnungRep.iuVmAbrechnung(daten, null, uid, hausUid, wohnungUid, mieterUid, von, bis, schluessel,
			beschreibung, wert, betrag, datum, reihenfolge, status, funktion, notiz, null, null, null, null)
		var r = new ServiceErgebnis<VmAbrechnung>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteAbrechnung(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		abrechnungRep.delete(daten, new VmAbrechnungKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportAbrechnung(ServiceDaten daten, LocalDate von0, LocalDate bis0,
		String hausUid, String mieterUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(hausUid)) {
			throw new MeldungException(Meldungen::VM002)
		}

		var haus = new FoHaus
		var von = von0
		var bis = bis0
		var FoZeile z
		var FoWohnung wohnung
		var FoMieter mieter
		var aliste = abrechnungRep.getAbrechnungLangListe(daten, null, null, hausUid, "null", "null", null, null, von,
			bis)
		if (aliste.size <= 0) {
			throw new MeldungException(Meldungen::VM028)
		}
		var a0 = aliste.get(0)
		if (a0.datumVon.isBefore(von)) {
			von = a0.datumVon
		}
		if (a0.datumBis.isAfter(bis)) {
			bis = a0.datumBis
		}
		var listeH = abrechnungRep.getAbrechnungLangListe(daten, null, null, hausUid, null, null, von, bis, null, null)
		if (Global.listLaenge(listeH) <= 0) {
			throw new MeldungException(Meldungen::VM028)
		}
		haus.setVon(von)
		haus.setBis(bis)
		haus.setMonate(Global.monatsDifferenz(von, bis))
		for (VmAbrechnungLang a : listeH) {
			if (a.wohnungUid === null) {
				// Haus
				if (VmAbrechnungSchluesselEnum.H_DATUM.toString.equals(a.schluessel)) {
					if (a.datum === null) {
						haus.datum = a.wert
					} else {
						haus.datum = FoUtils.getDatum(a.datum.toLocalDate)
					}
				} else if (VmAbrechnungSchluesselEnum.H_GUTHABEN.toString.equals(a.schluessel)) {
					haus.guthaben = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_NACHZAHLUNG.toString.equals(a.schluessel)) {
					haus.nachzahlung = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_GRUESSE.toString.equals(a.schluessel)) {
					haus.gruesse = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_ANLAGE.toString.equals(a.schluessel)) {
					haus.anlage = a.wert
				} else if (VmAbrechnungSchluesselEnum.VM_NAME.toString.equals(a.schluessel)) {
					haus.vmName = a.wert
				} else if (VmAbrechnungSchluesselEnum.VM_STRASSE.toString.equals(a.schluessel)) {
					haus.vmStrasse = a.wert
				} else if (VmAbrechnungSchluesselEnum.VM_ORT.toString.equals(a.schluessel)) {
					haus.vmOrt = a.wert
				} else if (VmAbrechnungSchluesselEnum.VM_TELEFON.toString.equals(a.schluessel)) {
					haus.vmTelefon = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_STRASSE.toString.equals(a.schluessel)) {
					haus.hstrasse = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_ORT.toString.equals(a.schluessel)) {
					haus.hort = a.wert
				} else if (VmAbrechnungSchluesselEnum.H_WOHNFL_KORR.toString.equals(a.schluessel)) {
					haus.qm = haus.qm + a.betrag
				} else if (VmAbrechnungSchluesselEnum.H_PERSMON_KORR.toString.equals(a.schluessel)) {
					haus.personenmonate = haus.personenmonate + a.betrag
				} else if (VmAbrechnungSchluesselEnum.H_GRUNDSTEUER.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.grundsteuer = z
				} else if (VmAbrechnungSchluesselEnum.H_STRASSENREINIGUNG.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.strassenreinigung = z
				} else if (VmAbrechnungSchluesselEnum.H_ABFALL.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.abfall = z
				} else if (VmAbrechnungSchluesselEnum.H_STROM.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.strom = z
				} else if (VmAbrechnungSchluesselEnum.H_WOHNVERSICHERUNG.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.wohnversicherung = z
				} else if (VmAbrechnungSchluesselEnum.H_HAFTVERSICHERUNG.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.haftversicherung = z
				} else if (VmAbrechnungSchluesselEnum.H_GLASVERSICHERUNG.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.glasversicherung = z
				} else if (VmAbrechnungSchluesselEnum.H_DACHREINIGUNG.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.setDachreinigung = z
				} else if (VmAbrechnungSchluesselEnum.H_SCHORNSTEINFEGER.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.schornsteinfeger = z
				} else if (VmAbrechnungSchluesselEnum.H_GARTEN.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.garten = z
				} else if (VmAbrechnungSchluesselEnum.H_TRINKWASSER.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.trinkwasser = z
				} else if (VmAbrechnungSchluesselEnum.H_SCHMUTZWASSER.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.setSchmutzwasser = z
				} else if (VmAbrechnungSchluesselEnum.H_NIEDERSCHLAGSWASSER.toString.equals(a.schluessel)) {
					z = new FoZeile(a)
					haus.niederschlagswasser = z
				}
			} else if (a.mieterUid === null) {
				// Wohnung
				if (wohnung === null || Global.compString(a.wohnungUid, wohnung.uid) != 0) {
					wohnung = new FoWohnung
					wohnung.uid = a.wohnungUid
					haus.wohnungen.add(wohnung)
				}
				if (VmAbrechnungSchluesselEnum.W_WOHNFLAECHE.toString.equals(a.schluessel)) {
					wohnung.qm = a.betrag
					haus.qm = haus.qm + wohnung.qm
				}
			} else {
				// Mieter
				if (mieter === null || Global.compString(a.mieterUid, mieter.uid) != 0) {
					mieter = new FoMieter
					mieter.uid = a.mieterUid
					mieter.von = a.datumVon
					mieter.bis = a.datumBis
					mieter.monate = Global.monatsDifferenz(a.datumVon, a.datumBis)
					wohnung.mieter.add(mieter)
				}
				if (VmAbrechnungSchluesselEnum.M_ANREDE.toString.equals(a.schluessel)) {
					mieter.anrede = a.wert
				} else if (VmAbrechnungSchluesselEnum.M_NAME.toString.equals(a.schluessel)) {
					mieter.name = a.wert
				} else if (VmAbrechnungSchluesselEnum.M_STRASSE.toString.equals(a.schluessel)) {
					mieter.strasse = a.wert
				} else if (VmAbrechnungSchluesselEnum.M_ORT.toString.equals(a.schluessel)) {
					mieter.ort = a.wert
				} else if (VmAbrechnungSchluesselEnum.M_PERSONENMONATE.toString.equals(a.schluessel)) {
					mieter.personenmonate = a.betrag
					if (Global.compDouble(mieter.personenmonate, 0) <= 0) {
						mieter.personenmonate = mieter.monate
					}
					haus.personenmonate = haus.personenmonate + mieter.personenmonate
				} else if (VmAbrechnungSchluesselEnum.M_BK_VORAUS.toString.equals(a.schluessel)) {
					mieter.bkvoraus = a.betrag
				} else if (VmAbrechnungSchluesselEnum.M_HK_VORAUS.toString.equals(a.schluessel)) {
					mieter.hkvoraus = a.betrag
				} else if (VmAbrechnungSchluesselEnum.M_HK_ABRECHNUNG.toString.equals(a.schluessel)) {
					mieter.hkabrechnung = a.betrag
				} else if (VmAbrechnungSchluesselEnum.M_ANTENNE.toString.equals(a.schluessel)) {
					mieter.antenne = a.betrag
				} else if (VmAbrechnungSchluesselEnum.M_GARTEN.toString.equals(a.schluessel)) {
					mieter.garten = a.betrag
				} else if (VmAbrechnungSchluesselEnum.M_PERSMON_KORR.toString.equals(a.schluessel)) {
					mieter.personenmonat2 = a.betrag
				}
			}
		}
		var doc = newFopDokument
		doc.addAbrechnung(true, haus)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}
}

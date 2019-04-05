package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.HhBilanz
import de.cwkuehl.jhh6.api.dto.HhBilanzDruck
import de.cwkuehl.jhh6.api.dto.HhBilanzKey
import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.dto.HhBilanzUpdate
import de.cwkuehl.jhh6.api.dto.HhBuchung
import de.cwkuehl.jhh6.api.dto.HhBuchungHaben
import de.cwkuehl.jhh6.api.dto.HhBuchungKey
import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhBuchungSoll
import de.cwkuehl.jhh6.api.dto.HhBuchungUpdate
import de.cwkuehl.jhh6.api.dto.HhEreignis
import de.cwkuehl.jhh6.api.dto.HhEreignisKey
import de.cwkuehl.jhh6.api.dto.HhEreignisLang
import de.cwkuehl.jhh6.api.dto.HhEreignisUpdate
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.HhKontoKey
import de.cwkuehl.jhh6.api.dto.HhKontoUpdate
import de.cwkuehl.jhh6.api.dto.HhPeriode
import de.cwkuehl.jhh6.api.dto.HhPeriodeKey
import de.cwkuehl.jhh6.api.dto.HhPeriodeLang
import de.cwkuehl.jhh6.api.dto.VmBuchungKey
import de.cwkuehl.jhh6.api.dto.VmEreignisKey
import de.cwkuehl.jhh6.api.dto.VmKontoKey
import de.cwkuehl.jhh6.api.enums.KontoartEnum
import de.cwkuehl.jhh6.api.enums.KontokennzeichenEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.impl.HhBilanzRep
import de.cwkuehl.jhh6.server.rep.impl.HhBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.HhEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.HhKontoRep
import de.cwkuehl.jhh6.server.rep.impl.HhPeriodeRep
import de.cwkuehl.jhh6.server.rep.impl.VmBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.VmEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.VmKontoRep
import de.cwkuehl.jhh6.server.service.impl.BuchungSpalten
import de.cwkuehl.jhh6.server.service.impl.SbDatum
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Vector
import java.util.function.BiConsumer

@Service
class HaushaltService {

	@RepositoryRef HhBilanzRep bilanzRep
	@RepositoryRef HhBuchungRep buchungRep
	@RepositoryRef HhEreignisRep ereignisRep
	@RepositoryRef HhKontoRep kontoRep
	@RepositoryRef HhPeriodeRep periodeRep
	@RepositoryRef VmBuchungRep vmbuchungRep
	@RepositoryRef VmEreignisRep vmereignisRep
	@RepositoryRef VmKontoRep vmkontoRep

	@Transaction(false)
	override ServiceErgebnis<List<HhPeriodeLang>> getPeriodeListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhPeriodeLang>>(null)
		var list = periodeRep.getPeriodeLangListe(daten)
		for (HhPeriodeLang p : list) {
			p.text = Global.getPeriodeString(p.datumVon, p.datumBis, false)
		}
		r.ergebnis = list
		return r
	}

	/**
	 * Anlegen einer neuen Periode.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param iMonate Anzahl der Monate, die die Periode umfassen soll.
	 * @param bEnde True, wenn Periode nach der letzten Perioden anschließen soll; sonst vor der ersten.
	 */
	@Transaction
	override ServiceErgebnis<Void> anlegenPeriode(ServiceDaten daten, int iMonate, boolean bEnde) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var dVon = LocalDate::now.withDayOfYear(1)
		var dBis = dVon.minusDays(1)
		var lNr = 0
		var pdiff = 0

		var min = periodeRep.getMaxMinPeriode(daten, true, null)
		var max = periodeRep.getMaxMinPeriode(daten, false, null)
		if (bEnde) {
			if (max !== null) {
				lNr = max.nr
			}
			pdiff = -1
		} else {
			if (min !== null) {
				lNr = min.nr
			}
			pdiff = 1
		}
		if (lNr <= 0) {
			lNr = Constant.START_PERIODE
			dVon = dBis.plusDays(1)
			dBis = dBis.plusMonths(iMonate)
		} else {
			if (min === null || max === null) {
				throw new MeldungException(Meldungen::HH003)
			}
			dVon = min.datumVon
			dBis = max.datumBis
			if (bEnde) {
				lNr++
				dVon = dBis.plusDays(1)
				dBis = dBis.plusMonths(iMonate)
				dBis = dBis.withDayOfMonth(dBis.lengthOfMonth)
			} else {
				lNr--
				dBis = dVon.minusDays(1)
				dVon = dVon.minusMonths(iMonate)
			}
		}
		periodeRep.iuHhPeriode(daten, null, lNr, dVon, dBis, 0, null, null, null, null)
		// Bilanz aktualisieren
		insertBilanz2(daten, lNr, null, 0, 0, pdiff)
		// Neue Periode muss neu berechnet werden.
		if (periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, lNr + pdiff)) === null) {
			// Wenn Periode nicht vorhanden ist.
			pdiff = 0
		}
		setzeBerPeriode(daten, lNr + pdiff)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	/**
	 * Löschen einer Periode.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param bEnde True, wenn die letzte Periode gelöscht werden soll; sonst die erste.
	 */
	@Transaction
	override ServiceErgebnis<Void> loeschePeriode(ServiceDaten daten, boolean bEnde) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var lNr = 0

		var minNr = periodeRep.getMaxMinPeriodeNr(daten, true)
		var maxNr = periodeRep.getMaxMinPeriodeNr(daten, false)
		if (minNr >= maxNr) {
			throw new MeldungException(Meldungen::HH004)
		}
		if (bEnde) {
			lNr = maxNr
		} else {
			lNr = minNr
		}
		periodeRep.delete(daten, new HhPeriodeKey(daten.mandantNr, lNr))

		var list = bilanzRep.getBilanzListe(daten, null, lNr, lNr, null)
		for (HhBilanz b : list) {
			bilanzRep.delete(daten, b)
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	/**
	 * Setzen der zu berechnenden Periode.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param nr Perioden-Nummer.
	 */
	def private void setzeBerPeriode(ServiceDaten daten, int nr) {

		if (periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, nr)) === null) {
			throw new MeldungException(Meldungen::HH005(nr))
		}
		var lBer = holeBerPeriodeIntern(daten)
		if (lBer >= Constant.MIN_PERIODE && lBer < nr) {
			return // frühere Periode ist schon nicht berechnet!
		}
		var dHeute = daten.heute
		periodeRep.iuHhPeriode(daten, null, Constant.PN_BERECHNET, dHeute, dHeute, nr, null, null, null, null)
	}

	/**
	 * Setzen der berechneten Periode. Die nächste Periode ist zu berechnen.
	 * @param lNr Perioden-Nummer.
	 * @param berechnet Ist die Periode berechnet? Wenn ja, dann die nächste setzen.
	 * @param dJetzt Zeitstempel für Datenbank-Eintrag.
	 */
	def private void setzeBerPeriode2(ServiceDaten daten, int lNr, boolean berechnet) {

		var nr = lNr
		var minNr = periodeRep.getMaxMinPeriodeNr(daten, true)
		if (nr >= minNr) {
			if (periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, nr)) === null) {
				throw new MeldungException(Meldungen::HH005(nr))
			}
			if (berechnet) {
				nr++
			}
		} else {
			nr = minNr
		}
		var dHeute = daten.heute
		periodeRep.iuHhPeriode(daten, null, Constant.PN_BERECHNET, dHeute, dHeute, nr, null, null, null, null)
	}

	/**
	 * Liefert die nächste zu berechnende Perioden-Nummer.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param mandantNr Mandantennummer.
	 * @return Nächste zu berechnende Perioden-Nummer.
	 */
	def private int holeBerPeriodeIntern(ServiceDaten daten) {

		var iBerPeriode = 0
		var hhPeriode = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, Constant.PN_BERECHNET))
		if (hhPeriode !== null) {
			iBerPeriode = hhPeriode.art
		}
		if (iBerPeriode <= 0) {
			iBerPeriode = periodeRep.getMaxMinPeriodeNr(daten, true)
		}
		return iBerPeriode
	}

	/**
	 * Einfügen von Bilanz-Einträgen aus anderer Periode für ein oder alle Konten.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param pnr Quell-Perioden-Nummer.
	 * @param knr Konto-Nummer. Wenn 0, werden alle Konten kopiert; sonst nur das eine.
	 * @param dbBetrag DM-Betrag.
	 * @param dbEBetrag Euro-Betrag.
	 * @param pdiff Differenz zwischen Quell- und Ziel-Perioden-Nummer, üblicherweise 1 oder -1.
	 * @param dJetzt Zeitstempel für Datenbank-Eintrag.
	 */
	def private void insertBilanz2(ServiceDaten daten, int pnr, String knr, double dbBetrag, double dbEBetrag,
		int pdiff) {

		var vListe = new Vector<String>
		var longPNr = new Long(pnr)
		var HhBilanz hhBilanz
		var dbB = dbBetrag
		var dbEB = dbEBetrag

		// Bilanz-Einträge für eine Periode und ein oder alle Konten erstellen
		var hhKontos = kontoRep.getKontoListe(daten, pnr, pnr, null, null, null, null)
		for (HhKonto hhKonto : hhKontos) {
			var longKNr2 = hhKonto.uid
			if (istAktivPassivKontoIntern(hhKonto.art.toString)) {
				vListe.add(Meldungen::HH006(longPNr, Constant.KZBI_EROEFFNUNG, holeBilanzSH(hhKonto.art), longKNr2))
				vListe.add(Meldungen::HH006(longPNr, Constant.KZBI_SCHLUSS, holeBilanzSH(hhKonto.art), longKNr2))
			} else {
				vListe.add(Meldungen::HH006(longPNr, Constant.KZBI_GV, holeBilanzSH(hhKonto.art), longKNr2))
			}
		}

		for (String str : vListe) {
			var pnr3 = Global.strInt(str.substring(0, 10))
			var strK3 = str.substring(10, 12)
			var strS3 = str.substring(12, 13)
			var knr3 = str.substring(13)
			hhBilanz = bilanzRep.get(daten, new HhBilanzKey(daten.mandantNr, pnr3 + pdiff, strK3, knr3))
			if (hhBilanz === null) {
				dbB = 0
				dbEB = 0
			} else {
				if (Constant.KZBI_GV.equals(strK3)) {
					dbB = 0
					dbEB = 0
				} else {
					dbB = hhBilanz.betrag
					dbEB = hhBilanz.ebetrag
				}
				bilanzRep.iuBilanz(daten, pnr3, strK3, knr3, strS3, dbB, strS3, dbEB, false)
			}
		}
	}

	/**
	 * Prüfung auf Aktiv- oder Passiv-Konto.
	 * @param art Konto-Art.
	 * @return True, wenn Aktiv- oder Passiv-Konto.
	 */
	def private boolean istAktivPassivKontoIntern(String art) {
		return ( Constant.ARTK_AKTIVKONTO.equals(art) || Constant.ARTK_PASSIVKONTO.equals(art))
	}

	/**
	 * Prüfung auf Aktiv- oder Aufwands-Konto.
	 * @param art Konto-Art.
	 * @return True, wenn Aktiv- oder Aufwands-Konto.
	 */
	def private boolean istAktivAufwandKontoIntern(String art) {
		return ( Constant.ARTK_AKTIVKONTO.equals(art) || Constant.ARTK_AUFWANDSKONTO.equals(art))
	}

	/**
	 * Prüfung auf Aufwand- oder Ertrag-Konto.
	 * @param strArt Konto-Art.
	 * @return True, wenn Aufwand- oder Ertrag-Konto.
	 */
	def private boolean istAufwandErtragKontoIntern(String art) {
		return ( Constant.ARTK_AUFWANDSKONTO.equals(art) || Constant.ARTK_ERTRAGSKONTO.equals(art))
	}

	/**
	 * Liefert Soll/Haben-Kennzeichen für Bilanz an Hand der Konto-Art. A bei Aktiv- oder Aufwandskonto, sonst P.
	 * @param art Konto-Art.
	 * @return Soll/Haben-Kennzeichen für Bilanz: A oder P.
	 */
	def private String holeBilanzSH(String art) {

		if (istAktivAufwandKontoIntern(art)) {
			return Constant.KZSH_A
		}
		// if(strArt == ARTK_PASSIVKONTO || strArt == ARTK_ERTRAGSKONTO)
		return Constant.KZSH_P
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhKonto>> getKontoListe(ServiceDaten daten, LocalDate vonle, LocalDate bisge) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhKonto>>(null)
		r.ergebnis = kontoRep.getKontoListe(daten, -1, -1, null, null, vonle, bisge)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhKonto> getKonto(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhKonto>(kontoRep.get(daten, new HhKontoKey(daten.mandantNr, uid)))
		return r
	}

	/**
	 * Anlegen eines neuen Kontos mit Eintragen in die passenden Bilanzen.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param uid Konto-Nummer. Falls 0, wird die Nummer neu bestimmt.
	 * @param strA Konto-Art (AK, PK, AW, ER).
	 * @param strK Konto-Kennzeichen.
	 * @param strName Konto-Bezeichnung.
	 * @param dVon Anfangsdatum.
	 * @param dBis Enddatum.
	 * @return Konto.
	 */
	@Transaction
	override ServiceErgebnis<HhKonto> insertUpdateKonto(ServiceDaten daten, String uid, String strA, String strK,
		String strName, LocalDate dVon, LocalDate dBis, String s, String huid, String wuid, String muid, String n,
		boolean vermietung) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var knr = uid
		var lVon = Constant.MIN_PERIODE
		var lBis = Constant.MAX_PERIODE
		var lVonAlt = Constant.MIN_PERIODE
		var lBisAlt = Constant.MAX_PERIODE
		var lBer = Constant.MAX_PERIODE
		var strN = strName
		var anzahl = 0
		var String sort
		var insert = Global.nes(uid)
		var HhKonto hhKonto

		if (Global.nes(strN)) {
			throw new MeldungException(Meldungen::HH007)
		}
		if (KontoartEnum.fromValue(strA) === null) {
			throw new MeldungException(Meldungen::HH008(strA))
		}
		if (KontokennzeichenEnum.fromValue(strK) === null || strK.length > 1) {
			throw new MeldungException(Meldungen::HH009(strK))
		}
		if (istSpezialKontokennzeichen(strK)) {
			if (!Global.nes(kontoRep.getMinKonto(daten, uid, strK, null, null))) {
				throw new MeldungException(Meldungen::HH010(strK))
			}
			if (dVon !== null || dBis !== null) {
				throw new MeldungException(Meldungen::HH011)
			}
		}
		if (dVon !== null) {
			lVon = periodeRep.getMaxMinNr(daten, false, dVon)
		}
		if (!insert) {
			hhKonto = getKontoIntern(daten, uid, true)
			if (!hhKonto.art.equals(strA)) {
				throw new MeldungException(Meldungen::HH012)
			}
			var kzAlt = hhKonto.kz
			if (istSpezialKontokennzeichen(kzAlt) && !kzAlt.equals(strK)) {
				throw new MeldungException(Meldungen::HH013(kzAlt))
			}
			lVonAlt = hhKonto.periodeVon
			lVonAlt = Math.max(lVonAlt, Constant.MIN_PERIODE)
			lBisAlt = hhKonto.periodeBis
			lBisAlt = Math.max(lBisAlt, Constant.MIN_PERIODE)
			sort = hhKonto.sortierung
			if (dVon !== null) {
				if (buchungRep.countKontoValutaVorNach(daten, uid, dVon, null, Constant.KZB_AKTIV) > 0) {
					throw new MeldungException(Meldungen::HH014)
				}
			}
		}
		if (dBis !== null) {
			if (dVon !== null && dBis.isBefore(dVon)) {
				throw new MeldungException(Meldungen::HH015)
			}
			lBis = periodeRep.getMaxMinNr(daten, true, dBis)
			if (lBis <= 0) {
				lBis = Constant.MAX_PERIODE
			}
			if (!insert && buchungRep.countKontoValutaVorNach(daten, uid, null, dBis, Constant.KZB_AKTIV) > 0) {
				throw new MeldungException(Meldungen::HH016)
			}
		}
		if (Global.nes(sort)) {
			sort = kontoRep.findKontoSortierung(daten, knr)
		}
		if (!Global.nes(kontoRep.getMinKonto(daten, knr, null, null, strN))) {
			throw new MeldungException(Meldungen::HH017(strN))
		}
		if (insert) {
			knr = Global::UID
			var hhBilanz = new HhBilanz
			hhBilanz.mandantNr = daten.mandantNr
			hhBilanz.setKontoUid(knr)
			hhBilanz.machAngelegt(daten.jetzt, daten.benutzerId)
			if (istAktivPassivKontoIntern(strA)) {
				// Konto in Eröffnungsbilanz einfügen
				hhBilanz.setKz(Constant.KZBI_EROEFFNUNG)
				hhBilanz.setSh(holeBilanzSH(strA))
				hhBilanz.setEsh(hhBilanz.sh)
				anzahl = insertBilanzPerioden(daten, hhBilanz, dVon, dBis)
			}
			if (istAktivPassivKontoIntern(strA)) {
				// Konto in Schlussbilanz einfügen
				hhBilanz.setKz(Constant.KZBI_SCHLUSS)
				hhBilanz.setSh(holeBilanzSH(strA))
				hhBilanz.setEsh(hhBilanz.sh)
				anzahl = insertBilanzPerioden(daten, hhBilanz, dVon, dBis)
			}
			if (istAufwandErtragKontoIntern(strA)) {
				// Konto in G+V-Rechnung einfügen
				hhBilanz.setKz(Constant.KZBI_GV)
				hhBilanz.setSh(holeBilanzSH(strA))
				hhBilanz.setEsh(hhBilanz.sh)
				anzahl = insertBilanzPerioden(daten, hhBilanz, dVon, dBis)
			}
			if (anzahl <= 0) {
				throw new MeldungException(Meldungen::HH018)
			}
			hhKonto = new HhKonto
			hhKonto.mandantNr = daten.mandantNr
			hhKonto.setUid(knr)
			hhKonto.setSortierung(sort)
			hhKonto.setArt(strA)
			hhKonto.setKz(strK)
			hhKonto.setName(strN)
			hhKonto.setGueltigVon(dVon)
			hhKonto.setGueltigBis(dBis)
			hhKonto.setPeriodeVon(lVon)
			hhKonto.setPeriodeBis(lBis)
			hhKonto.machAngelegt(daten.jetzt, daten.benutzerId)
			kontoRep.insert(daten, hhKonto)
		} else {
			// Bilanz aktualisieren
			if (lVon > lVonAlt) {
				bilanzRep.deleteKontoVonBis(daten, uid, lVon, 0)
				lBer = Math.min(lBer, lVonAlt)
			}
			if (lBis < lBisAlt) {
				bilanzRep.deleteKontoVonBis(daten, uid, 0, lBis)
				lBer = Math.min(lBer, lBis)
			}
			if (lVon < lVonAlt) {
				var dbB = 0.0
				var dbEB = 0.0
				var lMin = periodeRep.getMaxMinPeriodeNr(daten, true)
				lVon = Math.max(lVon, lMin)
				for (var pnr = lVonAlt - 1; pnr >= lVon; pnr--) {
					insertBilanz2(daten, pnr, uid, dbB, dbEB, 1)
				}
				lBer = Math.min(lBer, lVon)
			}
			if (lBis > lBisAlt) {
				var dbB = 0.0
				var dbEB = 0.0
				var lMax = periodeRep.getMaxMinPeriodeNr(daten, false)
				lBis = Math.min(lBis, lMax)
				for (var pnr = lBisAlt + 1; pnr <= lBis; pnr++) {
					insertBilanz2(daten, pnr, uid, dbB, dbEB, -1)
				}
			}
			var hhKontoU = new HhKontoUpdate(hhKonto)
			hhKontoU.setArt(strA)
			hhKontoU.setKz(strK)
			hhKontoU.setName(strN)
			hhKontoU.setGueltigVon(dVon)
			hhKontoU.setGueltigBis(dBis)
			hhKontoU.setPeriodeVon(lVon)
			hhKontoU.setPeriodeBis(lBis)
			if (hhKontoU.isChanged) {
				hhKontoU.machGeaendert(daten.jetzt, daten.benutzerId)
				kontoRep.update(daten, hhKontoU)
			}
			hhKonto = hhKontoU.cloneDto
		}
		if (Global.nes(s) && Global.nes(huid) && Global.nes(wuid) && Global.nes(muid) && Global.nes(n)) {
			if (vermietung && !insert) {
				vmkontoRep.delete(daten, new VmKontoKey(daten.mandantNr, uid))
			}
		} else {
			vmkontoRep.iuVmKonto(daten, null, hhKonto.uid, s, huid, wuid, muid, n, null, null, null, null)
		}

		var r = new ServiceErgebnis<HhKonto>(hhKonto)
		return r
	}

	/**
	 * Liefert true bei Spezial-Kontokennzeichen E und G.
	 * @param strKz Kontokennzeichen.
	 * @return true bei Spezial-Kontokennzeichen E und G.
	 */
	def private boolean istSpezialKontokennzeichen(String kz) {

		if (KontokennzeichenEnum.EIGENKAPITEL.toString.equals(kz) ||
			KontokennzeichenEnum.GEWINN_VERLUST.toString.equals(kz)) {
			return true
		}
		return false
	}

	def private int insertBilanzPerioden(ServiceDaten daten, HhBilanz hhBilanz, LocalDate dVon, LocalDate dBis) {

		var list = periodeRep.getPeriodeListe(daten, dVon, dBis)
		for (HhPeriode p : list) {
			hhBilanz.setPeriode(p.nr)
			bilanzRep.insert(daten, hhBilanz)
		}
		return list.size
	}

	def private HhKonto getKontoIntern(ServiceDaten daten, String uid, boolean exception) {

		var hhKonto = kontoRep.get(daten, new HhKontoKey(daten.mandantNr, uid))
		if (exception && hhKonto === null) {
			throw new MeldungException(Meldungen::HH019(uid))
		}
		return hhKonto
	}

	/**
	 * Löschen eines Kontos.
	 * @param rbListe Rollback-Liste.
	 * @param uid Konto-Nummer.
	 */
	@Transaction
	override ServiceErgebnis<Void> deleteKonto(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var hhKonto = getKontoIntern(daten, uid, true)
		if (buchungRep.countKontoValutaVorNach(daten, uid, null, null, null) > 0) {
			throw new MeldungException(Meldungen::HH020)
		}
		if (istSpezialKontokennzeichen(hhKonto.kz)) {
			throw new MeldungException(Meldungen::HH021)
		}
		var biliste = bilanzRep.getBilanzListe(daten, null, Constant.PN_BERECHNET, Constant.PN_BERECHNET, uid)
		for (HhBilanz b : biliste) {
			bilanzRep.delete(daten, b)
		}
		var buliste = buchungRep.getBuchungListe(daten, uid, null, null, null)
		for (HhBuchung b : buliste) {
			buchungRep.delete(daten, b)
		}
		var erliste = ereignisRep.getEreignisListe(daten, uid)
		for (HhEreignis b : erliste) {
			ereignisRep.delete(daten, b)
		}
		kontoRep.delete(daten, hhKonto)
		vmkontoRep.delete(daten, new VmKontoKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> holeMinMaxKontoText(ServiceDaten daten, String kontoUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<String>(Meldungen::HH022)
		var min = buchungRep.getBuchungMaxMin(daten, kontoUid, true)
		if (min !== null) {
			var max = buchungRep.getBuchungMaxMin(daten, kontoUid, false)
			var dMin = min.sollValuta.atStartOfDay
			var dMax = max.sollValuta.atStartOfDay
			r.ergebnis = Meldungen::HH023(dMin, dMax)
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhEreignisLang>> getEreignisListe(ServiceDaten daten, LocalDate von, LocalDate bis) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhEreignisLang>>(null)
		var list = ereignisRep.getEreignisLangListe(daten, null, von, bis)
		r.ergebnis = list
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhEreignis> getEreignis(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhEreignis>(ereignisRep.get(daten, new HhEreignisKey(daten.mandantNr, uid)))
		return r
	}

	val private BiConsumer<HhEreignis, HhEreignisUpdate> ereignisEvent = [ HhEreignis e, HhEreignisUpdate u |

		var String uid
		var String bez
		var String kz
		var String text
		var String suid
		var String huid
		if (e !== null) {
			uid = e.uid
			bez = e.bezeichnung
			kz = e.kz
			text = e.etext
			suid = e.sollKontoUid
			huid = e.habenKontoUid
		} else if (u !== null) {
			uid = u.uid
			bez = u.bezeichnung
			kz = u.kz
			text = u.etext
			suid = u.sollKontoUid
			huid = u.habenKontoUid
		}
		if (Global.nes(bez)) {
			if (u !== null) {
				throw new MeldungException(Meldungen::HH024)
			}
			bez = Meldungen::HH025(uid)
		}
		if (kz !== null && kz.length > HhEreignis.KZ_LAENGE) {
			throw new MeldungException(Meldungen::HH026(HhEreignis.KZ_LAENGE))
		}
		if (Global.nes(text)) {
			throw new MeldungException(Meldungen::HH027)
		}
		if (text.length > HhEreignis.ETEXT_LAENGE) {
			text = text.substring(0, HhEreignis.ETEXT_LAENGE)
		}
		if (Global.nes(suid)) {
			throw new MeldungException(Meldungen::HH028)
		}
		if (Global.nes(huid)) {
			throw new MeldungException(Meldungen::HH029)
		}
		if (suid.equals(huid)) {
			throw new MeldungException(Meldungen::HH030)
		}
		if (e !== null) {
			e.bezeichnung = bez
			e.etext = text
		} else if (u !== null) {
			u.bezeichnung = bez
			u.etext = text
		}
	]

	@Transaction
	override ServiceErgebnis<HhEreignis> insertUpdateEreignis(ServiceDaten daten, String uid, String kz, String sollUid,
		String habUid, String bez, String text, String s, String huid, String wuid, String muid, String n, boolean v) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var insert = Global.nes(uid)
		var ereignis = ereignisRep.iuHhEreignis(daten, ereignisEvent, uid, kz, sollUid, habUid, bez, text, null, null,
			null, null)
		if (Global.nes(s) && Global.nes(huid) && Global.nes(wuid) && Global.nes(muid) && Global.nes(n)) {
			if (v && !insert) {
				vmereignisRep.delete(daten, new VmEreignisKey(daten.mandantNr, uid))
			}
		} else {
			vmereignisRep.iuVmEreignis(daten, null, ereignis.uid, s, huid, wuid, muid, n, null, null, null, null)
		}
		var r = new ServiceErgebnis<HhEreignis>(ereignis)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteEreignis(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		ereignisRep.delete(daten, new HhEreignisKey(daten.mandantNr, uid))
		vmereignisRep.delete(daten, new VmEreignisKey(daten.mandantNr, uid))
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
	override ServiceErgebnis<List<HhBuchungLang>> getBuchungListe(ServiceDaten daten, boolean valutasuche,
		LocalDate von, LocalDate bis, String text, String kontoUid, String betrag) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<HhBuchungLang>>(null)
		var euro = isEuroIntern
		r.ergebnis = buchungRep.getBuchungLangListe(daten, euro, valutasuche, von, bis, text, kontoUid, betrag, null,
			true)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<HhBuchung> getBuchung(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<HhBuchung>(buchungRep.get(daten, new HhBuchungKey(daten.mandantNr, uid)))
		return r
	}

	def private List<String> getBuchungSpalten() {

		var l = newArrayList("SollValuta", "Btext", "Ebetrag", "Uid", "Kz", "SollKontoUid", "HabenKontoUid", "BelegNr",
			"BelegDatum", "HabenValuta", "Betrag", "AngelegtVon", "AngelegtAm", "GeaendertVon", "GeaendertAm")
		return l
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> exportBuchungListe(ServiceDaten daten, boolean valutasuche, LocalDate von,
		LocalDate bis, String text, String kontoUid, String betrag) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var felder = getBuchungSpalten
		var euro = isEuroIntern
		var liste = buchungRep.getBuchungLangListe(daten, euro, valutasuche, von, bis, text, kontoUid, betrag, null,
			false)
		var l = new ArrayList<String>
		l.add(Global.encodeCSV(felder))
		exportListeFuellen(felder, liste, new HhBuchungLang, l)

		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<String> getNeueBelegNr(ServiceDaten daten, LocalDate belegDatum) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var belegNr = ""
		if (belegDatum !== null) {
			var bu = buchungRep.getLetzteBelegnummer(daten, belegDatum)
			if (bu === null) {
				belegNr = belegDatum.format(DateTimeFormatter.ofPattern("yyyyMMdd01"))
			} else {
				belegNr = Global.lngStr(Global.strLng(bu.belegNr) + 1)
			}
		}
		var r = new ServiceErgebnis<String>(belegNr)
		return r
	}

	/**
	 * Liefert die Konto-Nummer des Eigenkapitals.
	 * @param mandantNr Mandantennummer.
	 * @param exception Soll eine Exception geworfen werden, wenn das Konto fehlt?
	 * @return Konto-Nummer des Eigenkapitals.
	 */
	def private String holeEkKonto(ServiceDaten daten, boolean exception) {

		var ek = kontoRep.getMinKonto(daten, null, KontokennzeichenEnum.EIGENKAPITEL.toString, null, null)
		if (exception && Global.nes(ek)) {
			throw new MeldungException(Meldungen::HH031)
		}
		return ek
	}

	/**
	 * Liefert die Konto-Nummer des G+V-Kontos.
	 * @param mandantNr Mandantennummer.
	 * @param exception Soll eine Exception geworfen werden, wenn das Konto fehlt?
	 * @return Konto-Nummer des G+V-Kontos.
	 */
	def private String holeGvKonto(ServiceDaten daten, boolean exception) {

		var gv = kontoRep.getMinKonto(daten, null, KontokennzeichenEnum.GEWINN_VERLUST.toString, null, null)
		if (exception && Global.nes(gv)) {
			throw new MeldungException(Meldungen::HH032)
		}
		return gv
	}

	/**
	 * Prüfung der Buchung.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param buchung HhBuchung-Instanz.
	 */
	def private void pruefBuchung(ServiceDaten daten, LocalDate sv, double b, double eb, String sollUid,
		String habenUid, String text, String bn, LocalDate bd) {

		if (sv === null) {
			throw new MeldungException(Meldungen::HH033)
		}
		if (Global.compDouble(b, 0) <= 0 || Global.compDouble(eb, 0) <= 0) {
			throw new MeldungException(Meldungen::HH034)
		}
		if (Global.nes(sollUid)) {
			throw new MeldungException(Meldungen::HH028)
		}
		if (Global.nes(habenUid)) {
			throw new MeldungException(Meldungen::HH029)
		}
		if (habenUid == sollUid) {
			throw new MeldungException(Meldungen::HH030)
		}
		var ek = holeEkKonto(daten, true)
		var gv = holeGvKonto(daten, true)
		if (sollUid.equals(ek) || habenUid.equals(ek) || sollUid.equals(gv) || habenUid.equals(gv)) {
			throw new MeldungException(Meldungen::HH035)
		}
		if (Global.nes(text)) {
			throw new MeldungException(Meldungen::HH027)
		}
		if (bd === null) {
			throw new MeldungException(Meldungen::HH036)
		}
		var hhKonto = getKontoIntern(daten, sollUid, false)
		if (hhKonto === null) {
			throw new MeldungException(Meldungen::HH037)
		}
		if (hhKonto.gueltigVon !== null && sv.isBefore(hhKonto.gueltigVon)) {
			throw new MeldungException(Meldungen::HH038(hhKonto.gueltigVon.atStartOfDay))
		}
		if (hhKonto.gueltigBis !== null && sv.isAfter(hhKonto.gueltigBis)) {
			throw new MeldungException(Meldungen::HH039(hhKonto.gueltigBis.atStartOfDay))
		}
		hhKonto = getKontoIntern(daten, habenUid, false)
		if (hhKonto === null) {
			throw new MeldungException(Meldungen::HH040)
		}
		if (hhKonto.gueltigVon !== null && sv.isBefore(hhKonto.gueltigVon)) {
			throw new MeldungException(Meldungen::HH041(hhKonto.gueltigVon.atStartOfDay))
		}
		if (hhKonto.gueltigBis !== null && sv.isAfter(hhKonto.gueltigBis)) {
			throw new MeldungException(Meldungen::HH042(hhKonto.gueltigBis.atStartOfDay))
		}
	}

	/**
	 * Anlegen einer Buchung.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param uid Buchungs-Nummer muss 0 sein.
	 * @param v Valuta-Datum.
	 * @param b DM-Betrag.
	 * @param eb Euro-Betrag.
	 * @param sollUid Soll-Konto-Nummer.
	 * @param habenUid Haben-Konto-Nummer.
	 * @param text Buchungstext.
	 * @param bn Belegnummer als Text.
	 * @param bd Belegdatum.
	 * @param s Schlüssel.
	 * @param huid Haus-Nummer.
	 * @param wuid Wohnung-Nummer.
	 * @param muid Mieter-Nummer.
	 * @param vermietung Handelt es sich um eine Vermietungsbuchung?
	 */
	@Transaction
	override ServiceErgebnis<HhBuchung> insertUpdateBuchung(ServiceDaten daten, String uid, LocalDate v, double b,
		double eb, String sollUid, String habenUid, String text, String bn, LocalDate bd, String s, String huid,
		String wuid, String muid, String n, boolean vermietung) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var buchung = insertUpdateBuchungIntern(daten, uid, v, b, eb, sollUid, habenUid, text, bn, bd, s, huid, wuid,
			muid, n, vermietung, null, null, null, null)
		var r = new ServiceErgebnis<HhBuchung>(buchung)
		return r
	}

	def private HhBuchung insertUpdateBuchungIntern(ServiceDaten daten, String uid, LocalDate v, double b, double eb,
		String sollUid, String habenUid, String text, String bn, LocalDate bd, String s, String huid, String wuid,
		String muid, String n, boolean vermietung, String angelegtVon, LocalDateTime angelegtAm, String geaendertVon,
		LocalDateTime geaendertAm) {

		var strKz = Constant.KZB_AKTIV
		var strT = text
		var insert = Global.nes(uid)
		var LocalDate dValt
		var HhBuchung balt

		if (!insert) {
			balt = buchungRep.get(daten, new HhBuchungKey(daten.mandantNr, uid))
		}
		pruefBuchung(daten, v, b, eb, sollUid, habenUid, strT, bn, bd)
		var buchung = buchungRep.iuHhBuchung(daten, null, uid, v, v, strKz, b, eb, sollUid, habenUid, strT, bn, bd,
			angelegtVon, angelegtAm, geaendertVon, geaendertAm)
		if (Global.nes(s) && Global.nes(huid) && Global.nes(wuid) && Global.nes(muid) && Global.nes(n)) {
			if (vermietung && !insert) {
				vmbuchungRep.delete(daten, new VmBuchungKey(daten.mandantNr, uid))
			}
		} else {
			vmbuchungRep.iuVmBuchung(daten, null, buchung.uid, s, huid, wuid, muid, n, angelegtVon, angelegtAm,
				geaendertVon, geaendertAm)
		}
		if (insert) {
			setzePassendeBerPeriode(daten, v)
		} else {
			dValt = balt.sollValuta
			if (dValt === null || dValt.isAfter(v)) {
				dValt = v
			}
			setzePassendeBerPeriode(daten, dValt)
		}
		return buchung
	}

	/**
	 * Setzen der passenden berechneten Periode.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param datum Datum, zu dem die passende Periode bestimmt wird.
	 */
	def private void setzePassendeBerPeriode(ServiceDaten daten, LocalDate datum) {

		var nr = holePassendePeriodeNr(daten, datum)
		// TODO Fehlerfall: minimale passende Periode setzen
		setzeBerPeriode(daten, nr)
	}

	/**
	 * Liefert die Perioden-Nummer, in der das angegebene Datum liegt.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param d Datum.
	 * @return Passende Perioden-Nummer.
	 */
	def private int holePassendePeriodeNr(ServiceDaten daten, LocalDate d) {

		var p = holePassendePeriode(daten, d, true)
		return p.nr
	}

	/**
	 * Liefert die Periode, in der das angegebene Datum liegt.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param d Datum.
	 * @return Passende Periode.
	 */
	def private HhPeriode holePassendePeriode(ServiceDaten daten, LocalDate d, boolean exception) {

		var p = periodeRep.getMaxMinPeriode(daten, false, d)
		if (p === null && exception) {
			throw new MeldungException(Meldungen::HH018)
		}
		return p
	}

	/**
	 * Stornieren einer Buchung.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param uid Buchungs-Nummer.
	 */
	@Transaction
	override ServiceErgebnis<Void> storniereBuchung(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var hhBuchung = buchungRep.get(daten, new HhBuchungKey(daten.mandantNr, uid))
		if (hhBuchung === null) {
			throw new MeldungException(Meldungen::HH043(uid))
		}
		var hhBuchungU = new HhBuchungUpdate(hhBuchung)
		if (Constant.KZB_AKTIV.equals(hhBuchung.kz)) {
			hhBuchungU.setKz(Constant.KZB_STORNO)
		} else {
			hhBuchungU.setKz(Constant.KZB_AKTIV)
		}
		hhBuchungU.machGeaendert(daten.jetzt, daten.benutzerId)
		buchungRep.update(daten, hhBuchungU)
		setzePassendeBerPeriode(daten, hhBuchung.sollValuta)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	/**
	 * Löschen einer Buchung.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param uid Buchungs-Nummer.
	 */
	@Transaction
	override ServiceErgebnis<Void> deleteBuchung(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deleteBuchungIntern(daten, uid, true)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private void deleteBuchungIntern(ServiceDaten daten, String uid, boolean pruefen) {

		var key = new HhBuchungKey(daten.mandantNr, uid)
		var hhBuchung = buchungRep.get(daten, key)
		if (hhBuchung === null) {
			throw new MeldungException(Meldungen::HH043(uid))
		}
		setzePassendeBerPeriode(daten, hhBuchung.sollValuta)
		buchungRep.delete(daten, key)
		vmbuchungRep.delete(daten, new VmBuchungKey(daten.mandantNr, uid))
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhBilanzSb>> getBilanzZeilen(ServiceDaten daten, String strKz, LocalDate dVon,
		LocalDate dBis) {

		var r = new ServiceErgebnis<List<HhBilanzSb>>(getBilanzZeilenIntern(daten, strKz, dVon, dBis))
		return r
	}

	def private List<HhBilanzSb> getBilanzZeilenIntern(ServiceDaten daten, String kz0, LocalDate dVon, LocalDate dBis) {

		var euro = isEuroIntern
		var dV = dVon
		var dB = dBis
		var berechnen = false
		var nullen = false
		var String ek
		var kz = kz0

		var pVon = holePassendePeriode(daten, dVon, false)
		var pBis = pVon
		if (pVon === null) {
			return new ArrayList<HhBilanzSb>
		}
		if (!dVon.equals(dBis)) {
			pBis = holePassendePeriode(daten, dBis, true)
		}
		if (Constant.KZBI_EROEFFNUNG.equals(kz)) {
			if (!dVon.equals(pVon.datumVon)) {
				dV = pVon.datumVon
				dB = dVon
				ek = holeEkKonto(daten, false)
				berechnen = true
			}
		} else if (Constant.KZBI_GV.equals(kz)) {
			if (!(dVon.equals(pVon.datumVon) && dBis.equals(pBis.datumBis))) {
				ek = holeGvKonto(daten, false)
				berechnen = true
				nullen = true
			}
		} else if (Constant.KZBI_SCHLUSS.equals(kz)) {
			if (!dBis.equals(pBis.datumBis)) {
				dV = pBis.datumVon
				kz = Constant.KZBI_EROEFFNUNG
				ek = holeEkKonto(daten, false)
				berechnen = true
			}
		}

		var result = bilanzRep.getBilanzSbListe(daten, kz, pVon.nr, pBis.nr, null)
		var betrag = 0.0
		var String sh

		if (berechnen) {
			var hash = new HashMap<String, HhBilanzSb>
			for (HhBilanzSb b : result) {
				hash.put(b.kontoUid, b)
				if (nullen) {
					b.summe = 0
					b.esumme = 0
				}
			}
			var bEk = hash.get(ek)
			var listeS = buchungRep.getBuchungSollListe(daten, null, dV, dB, Constant.KZB_AKTIV)
			for (HhBuchungSoll bu : listeS) {
				var b = hash.get(bu.uid)
				if (b !== null) {
					b.summe = b.summe + bu.summe
					b.esumme = b.esumme + bu.esumme
					if (bEk !== null) {
						bEk.summe = bEk.summe - bu.summe
						bEk.esumme = bEk.esumme - bu.esumme
					}
				}
			}
			var listeH = buchungRep.getBuchungHabenListe(daten, null, dV, dB, Constant.KZB_AKTIV)
			for (HhBuchungHaben bu : listeH) {
				var b = hash.get(bu.uid)
				if (b !== null) {
					b.summe = b.summe + bu.summe
					b.esumme = b.esumme + bu.esumme
					if (bEk !== null) {
						bEk.summe = bEk.summe - bu.summe
						bEk.esumme = bEk.esumme - bu.esumme
					}
				}
			}
		}
		for (HhBilanzSb b : result) {
			if (euro) {
				betrag = b.esumme
				sh = b.esh
			} else {
				betrag = b.summe
				sh = b.sh
			}
			if (Global.compDouble(betrag, 0) < 0) {
				b.art = 1
				b.esumme = -b.esumme
				b.summe = -b.summe
			} else if (Global.compDouble(betrag, 0) > 0) {
				b.art = 0
			} else if (Global.compDouble(betrag, 0) == 0) {
				if (Constant.KZSH_A.equals(sh)) {
					b.art = 1
				}
				b.esumme = 0
				b.summe = 0
			}
		}
		return result
	}

	/**
	 * Liefert ein VO mit kleinsten Perioden-Anfang und größtem Perioden-Ende.
	 */
	@Transaction(false)
	override ServiceErgebnis<HhPeriode> holeMinMaxPerioden(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var max = periodeRep.getMaxMinPeriode(daten, false, null)
		if (max === null) {
			max = new HhPeriode
			max.mandantNr = daten.mandantNr
		} else {
			var min = periodeRep.getMaxMinPeriode(daten, true, null)
			if (min !== null) {
				max.datumVon = min.datumVon
			}
		}
		var r = new ServiceErgebnis<HhPeriode>(max)
		return r
	}

	/**
	 * Neuberechnung der Bilanzen in einer oder mehreren Perioden.
	 * @param alles True, wenn alle neu zu berechnenden Perioden in einer Schleife berechnet werden; sonst nur eine.
	 * @return 0 alles aktuell; 1 eine Periode aktualisiert; 2 noch eine weitere kann Periode aktualisiert werden.
	 */
	@Transaction
	override ServiceErgebnis<String[]> aktualisiereBilanz(ServiceDaten daten, boolean alles, LocalDate von) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (von !== null) {
			var pnr = holePassendePeriodeNr(daten, von)
			setzeBerPeriode2(daten, pnr, false)
		}
		var rc = aktualisierenBilanz(daten, alles)
		var r = new ServiceErgebnis<String[]>(newArrayOfSize(2))
		r.ergebnis.set(0, Global.intStr(rc))
		var b = holeBerPeriodeIntern(daten)
		var p = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, b))
		if (p !== null) {
			r.ergebnis.set(1, Global.getPeriodeString(p.datumVon, p.datumBis, false))
		}
		return r
	}

	/**
	 * Neuberechnung der Bilanzen in einer oder mehreren Perioden.
	 * @param bAlles True, wenn alle neu zu berechnenden Perioden in einer Schleife berechnet werden; sonst nur eine.
	 * @return 0 alles aktuell; 1 eine Periode aktualisiert; 2 noch eine weitere kann Periode aktualisiert werden.
	 * @throws JhhException im unerwarteten Fehlerfalle.
	 */
	def private int aktualisierenBilanz(ServiceDaten daten, boolean bAlles) {

		var iWeiter = 0
		var pber = holeBerPeriodeIntern(daten) // erste zu berechnende Periode
		var pmin = periodeRep.getMaxMinPeriodeNr(daten, true) // erste Periode
		var pmax = periodeRep.getMaxMinPeriodeNr(daten, false) // letzte Periode
		// pber = pmin // immer berechnen alles berechnen
		if (pber < pmin) {
			pber = pmin
		}
		var ek = holeEkKonto(daten, true)
		var gv = holeGvKonto(daten, true)
		var ende = false
		for (var p = pber; p <= pmax && !ende; p++) {
			anlegenKontenBilanz(daten, p, Constant.KZBI_EROEFFNUNG, pmin)
			anlegenKontenBilanz(daten, p, Constant.KZBI_GV, pmin)
			anlegenKontenBilanz(daten, p, Constant.KZBI_SCHLUSS, pmin)
			if (p > pmin) {
				uebernehmenBilanz(daten, p - 1, Constant.KZBI_SCHLUSS, p, Constant.KZBI_EROEFFNUNG, true, ek, gv)
			} else { // if (p == pber) {
				aktualisierenEK(daten, p, Constant.KZBI_EROEFFNUNG, ek, gv)
			}
			aktualisierenBilanz1(daten, p, ek, gv)
			setzeBerPeriode2(daten, p, true)
			if (!bAlles) {
				// nur einen Durchgang
				ende = true
			}
		}
		if (pber == pmax) {
			iWeiter = 1
		} else if (pber < pmax) {
			iWeiter = 2
		}
		return iWeiter
	}

	/*
	 * Anlegen aller Konten in allen Bilanz (außer Plan) zur vorgegebenen Periode.
	 * @param pnr Perioden-Nummer.
	 * @param strKz Bilanz-Kennzeichen.
	 * @param pmin erste Perioden-Nummer.
	 */
	def private void anlegenKontenBilanz(ServiceDaten daten, int pnr, String strKz, int pmin) {

		var art1 = Constant.ARTK_AKTIVKONTO
		var art2 = Constant.ARTK_PASSIVKONTO
		if (Constant.KZBI_GV.equals(strKz)) {
			art1 = Constant.ARTK_AUFWANDSKONTO
			art2 = Constant.ARTK_ERTRAGSKONTO
		}
		var liste = kontoRep.getKontoListe(daten, pnr, pnr, art1, art2, null, null)
		for (HhKonto k : liste) {
			var strSh = holeBilanzSH(k.art)
			var betrag = 0.0
			var ebetrag = 0.0
			if (Constant.KZBI_EROEFFNUNG.equals(strKz)) {
				// Bilanz-Betrag mit Konto-Betrag aktualisieren, wenn EB dieser Periode
				if (k.periodeVon == pnr || k.periodeVon <= pmin) {
					betrag = k.betrag
					ebetrag = k.ebetrag
				}
			}
			var hhBilanzKey = new HhBilanzKey(daten.mandantNr, pnr, strKz, k.uid)
			var b = bilanzRep.get(daten, hhBilanzKey)
			if (b === null) {
				b = new HhBilanz
				b.mandantNr = daten.mandantNr
				b.periode = pnr
				b.kz = strKz
				b.kontoUid = k.uid
				b.sh = strSh
				b.betrag = betrag
				b.esh = strSh
				b.ebetrag = ebetrag
				b.machAngelegt(daten.jetzt, daten.benutzerId)
				bilanzRep.insert(daten, b)
			} else {
				var bU = new HhBilanzUpdate(b)
				bU.sh = strSh
				bU.betrag = betrag
				bU.esh = strSh
				bU.ebetrag = ebetrag
				if (bU.isChanged) {
					bU.machGeaendert(daten.jetzt, daten.benutzerId)
					bilanzRep.update(daten, bU)
				}
			}
		}
	}

	/**
	 * Übertragen der Beträge von einer Bilanz in eine andere mit evtl. anschließendem Neuberechnen des Eigenkapitals.
	 * @param pnr1 Quell-Perioden-Nummer.
	 * @param strK1 Quell-Bilanz-Kennzeichen.
	 * @param pnr2 Ziel-Perioden-Nummer.
	 * @param strK2 Ziel-Bilanz-Kennzeichen.
	 * @param bEKAktuell True, wenn Eigenkapital neu berechnet wird.
	 * @param ek Eigenkapital-Kontonummer.
	 * @param gv Gewinn+Verlust-Kontonummer.
	 */
	def private void uebernehmenBilanz(ServiceDaten daten, int pnr1, String strK1, int pnr2, String strK2,
		boolean bEKAktuell, String ek, String gv) {

		var liste = bilanzRep.getBilanzListe(daten, strK2, pnr2, pnr2, null)
		if (pnr1 <= 0) {
			for (HhBilanz b : liste) {
				var bU = new HhBilanzUpdate(b)
				bU.betrag = 0
				bU.ebetrag = 0
				if (bU.isChanged) {
					bU.machGeaendert(daten.jetzt, daten.benutzerId)
					bilanzRep.update(daten, bU)
				}
			}
		} else {
			for (HhBilanz b : liste) {
				var key = b.pk
				key.kz = strK1
				key.periode = pnr1
				var b1 = bilanzRep.get(daten, key)
				if (b1 !== null) {
					var bU = new HhBilanzUpdate(b)
					bU.betrag = b1.betrag
					bU.ebetrag = b1.ebetrag
					if (bU.isChanged) {
						bU.machGeaendert(daten.jetzt, daten.benutzerId)
						bilanzRep.update(daten, bU)
					}
				}
			}
		}
		if (bEKAktuell) {
			// Konten können hinzugekommen oder weggefallen sein!
			aktualisierenEK(daten, pnr2, strK2, ek, gv)
		}
	}

	/**
	 * Aktualisieren der Eigenkapital- oder G+V-Kontos in einer Bilanz.
	 * @param pnr Perioden-Nummer.
	 * @param strK Bilanzkennzeichen (EB, SB, GV oder PL).
	 * @param ek Eigenkapital-Kontonummer.
	 * @param gv Gewinn+Verlust-Kontonummer.
	 */
	def private void aktualisierenEK(ServiceDaten daten, int pnr, String strK, String ek, String gv) {

		var strSh = Constant.KZSH_P
		var strESh = Constant.KZSH_P
		var dbB = 0.0
		var dbEB = 0.0
		var knr = ek
		if (strK == Constant.KZBI_GV || strK == Constant.KZBI_PLAN) {
			knr = gv
		}
		var liste = bilanzRep.getBilanzSummeListe(daten, strK, pnr, knr)
		if (liste.size > 0 && liste.get(0) !== null) {
			dbB = liste.get(0).summe
			dbEB = liste.get(0).esumme
		}
		bilanzRep.iuBilanz(daten, pnr, strK, knr, strSh, -dbB, strESh, -dbEB, false)
	}

	/**
	 * Aktualisieren aller Bilanzen einer Periode außer EB: Kopieren von EB nach SB; GV auf 0 setzen; Buchungen in SB
	 * und GV eintragen; Summenkonten in SB, GB und PL aktualisieren.
	 * @param pnr Perioden-Nummer.
	 * @param ek Eigenkapital-Kontonummer.
	 * @param gv Gewinn+Verlust-Kontonummer.
	 */
	def private void aktualisierenBilanz1(ServiceDaten daten, int pnr, String ek, String gv) {

		var vo = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, pnr))
		if (vo === null) {
			throw new MeldungException(Meldungen::HH005(pnr))
		}
		uebernehmenBilanz(daten, pnr, Constant.KZBI_EROEFFNUNG, pnr, Constant.KZBI_SCHLUSS, false, ek, gv)
		uebernehmenBilanz(daten, 0, "", pnr, Constant.KZBI_GV, false, ek, gv)

		var String knr
		var String knr2
		var betrag = 0.0
		var ebetrag = 0.0
		var String strA
		var String strKz
		var i = -1
		var liste = buchungRep.getBuchungHabenListe(daten, null, vo.datumVon, vo.datumBis, Constant.KZB_AKTIV)
		var listeSoll = buchungRep.getBuchungSollListe(daten, null, vo.datumVon, vo.datumBis, Constant.KZB_AKTIV)
		for (HhBuchungSoll s : listeSoll) {
			var h = new HhBuchungHaben
			h.uid = s.uid
			h.art = s.art
			h.summe = s.summe
			h.esumme = s.esumme
			liste.add(h)
		}

		// Schleife einmal mehr durchlaufen.
		var iWeiter = true
		while (iWeiter) {
			i++
			if (liste !== null && i < liste.size) {
				knr = liste.get(i).uid
				if (Global.nes(knr2)) {
					// Beim 1. Durchlauf nichts machen.
					knr2 = knr
				}
			} else {
				knr = null
				iWeiter = false
			}
			if (Global.compString(knr, knr2) != 0) {
				if (istAktivPassivKontoIntern(strA)) {
					strKz = Constant.KZBI_SCHLUSS
				} else {
					strKz = Constant.KZBI_GV
				}
				bilanzRep.iuBilanz(daten, pnr, strKz, knr2, null, betrag, null, ebetrag, true)
				betrag = 0
				ebetrag = 0
			}
			if (iWeiter) {
				strA = liste.get(i).art
				betrag += liste.get(i).summe
				ebetrag += liste.get(i).esumme
				knr2 = knr
			}
		}
		// Eigenkapital berechnen
		var strK = Constant.KZBI_SCHLUSS
		aktualisierenEK(daten, pnr, strK, ek, gv)
		// Gewinn/Verlust berechnen
		strK = Constant.KZBI_GV
		aktualisierenEK(daten, pnr, strK, ek, gv)
		// Plan-Gewinn/Verlust berechnen
		strK = Constant.KZBI_PLAN
		aktualisierenEK(daten, pnr, strK, ek, gv)
	}

	@Transaction
	override ServiceErgebnis<Void> tauscheKontoSortierung(ServiceDaten daten, String uid, String uid2) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var k = getKontoIntern(daten, uid, true)
		var k2 = getKontoIntern(daten, uid2, true)
		if (k === null || k2 === null) {
			throw new MeldungException(Meldungen::HH044)
		}
		var s = k.sortierung
		var s2 = k2.sortierung

		if (Global.nes(s)) {
			s = kontoRep.findKontoSortierung(daten, null)
		}
		while (Global.nes(s2) || s2.equals(s)) {
			s2 = kontoRep.findKontoSortierung(daten, null)
		}
		var kU = new HhKontoUpdate(k)
		kU.setSortierung(s2)
		if (kU.isChanged) {
			kU.machGeaendert(daten.jetzt, daten.benutzerId)
		}
		kontoRep.update(daten, kU)
		var k2U = new HhKontoUpdate(k2)
		k2U.sortierung = s
		if (k2U.isChanged) {
			k2U.machGeaendert(daten.jetzt, daten.benutzerId)
		}
		kontoRep.update(daten, k2U)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportJahresbericht(ServiceDaten daten, LocalDate dVon, LocalDate dBis,
		String titel, boolean eb, boolean gv, boolean sb) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(titel)) {
			throw new MeldungException(Meldungen::HH045)
		}
		var List<HhBilanzSb> liste
		var List<HhBilanzDruck> ebListe
		var List<HhBilanzDruck> gvListe
		var List<HhBilanzDruck> sbListe
		var periode = Global.getPeriodeString(dVon, dBis, false)
		var euro = isEuroIntern
		var ueberschrift = Meldungen::HH046(periode, titel, daten.jetzt)
		var HhBilanzDruck z
		if (eb) {
			z = new HhBilanzDruck
			z.setName(Constant.KZBI_EROEFFNUNG)
			liste = getBilanzZeilenIntern(daten, Constant.KZBI_EROEFFNUNG, dVon, dVon)
			ebListe = getBilanzDruckListe(liste, euro)
		}
		if (gv) {
			z = new HhBilanzDruck
			z.setName(Constant.KZBI_GV)
			liste = getBilanzZeilenIntern(daten, Constant.KZBI_GV, dVon, dBis)
			gvListe = getBilanzDruckListe(liste, euro)
		}
		if (sb) {
			z = new HhBilanzDruck
			z.setName(Constant.KZBI_SCHLUSS)
			liste = getBilanzZeilenIntern(daten, Constant.KZBI_SCHLUSS, dBis, dBis)
			sbListe = getBilanzDruckListe(liste, euro)
		}
		var doc = newFopDokument
		doc.addJahresbericht(true, ueberschrift, ebListe, gvListe, sbListe)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	def private List<HhBilanzDruck> getBilanzDruckListe(List<HhBilanzSb> liste, boolean euro) {

		var list = new ArrayList<HhBilanzDruck>
		var listeS = new ArrayList<HhBilanzSb>
		var listeH = new ArrayList<HhBilanzSb>
		var HhBilanzSb bi
		for (HhBilanzSb b : liste) {
			if (b.art > 0) {
				listeS.add(b)
			} else {
				listeH.add(b)
			}
		}
		var l = Math.max(listeS.size, listeH.size)
		for (var i = 0; i < l; i++) {
			var z = new HhBilanzDruck
			if (i < listeS.size) {
				bi = listeS.get(i)
				z.nr = bi.kontoUid
				z.name = bi.name
				if (euro) {
					z.betrag = bi.esumme
				} else {
					z.betrag = bi.summe
				}
			} else {
				z.nr = ""
				z.name = ""
				z.betrag = Double.NaN
			}
			if (i < listeH.size) {
				bi = listeH.get(i)
				z.nr2 = bi.kontoUid
				z.name2 = bi.name
				if (euro) {
					z.betrag2 = bi.esumme
				} else {
					z.betrag2 = bi.summe
				}
			} else {
				z.nr2 = ""
				z.name2 = ""
				z.betrag2 = Double.NaN
			}
			// System.out.println(z.toBuffer(null))
			list.add(z)
		}
		return list
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportKassenbericht(ServiceDaten daten, LocalDate dVon, LocalDate dBis,
		String titel) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(titel)) {
			throw new MeldungException(Meldungen::HH045)
		}
		var periode = Global.getPeriodeString(dVon, dBis, false)
		var euro = isEuroIntern
		var monatlich = false
		var dbV = 0.0
		var dbE = 0.0
		var dbA = 0.0
		var dbS = 0.0
		var ueberschrift = Meldungen::HH047(periode, titel, daten.jetzt)
		var ek = holeEkKonto(daten, true)
		var gv = holeGvKonto(daten, true)
		var ebListe = getBilanzZeilenIntern(daten, Constant.KZBI_EROEFFNUNG, dVon, dVon)
		for (HhBilanzSb b : ebListe) {
			if (Global.compString(b.kontoUid, ek) == 0) {
				dbV = Global.iif(euro, b.esumme, b.summe)
			}
		}
		var gvListe = getBilanzZeilenIntern(daten, Constant.KZBI_GV, dVon, dBis)
		for (HhBilanzSb b : gvListe) {
			var db = Global.iif(euro, b.esumme, b.summe)
			if (Global.compString(b.kontoUid, gv) == 0) {
				b.setName(null)
			} else if (b.art > 0) {
				dbA += db
			} else {
				dbE += db
			}
			b.esumme = db
		}
		dbS = dbV + dbE - dbA
		var kListe = kontoRep.getKontoListe(daten, -1, -1, Constant.ARTK_AKTIVKONTO, null, dBis, dVon)
		var kpListe = kontoRep.getKontoListe(daten, -1, -1, Constant.ARTK_PASSIVKONTO, null, dBis, dVon)
		for (HhKonto k : kpListe) {
			if (k.uid != ek) {
				kListe.add(k)
			}
		}
		for (HhKonto k : kListe) {
			k.setBetrag(-getKontoStandIntern(daten, k.uid, dVon))
			k.setEbetrag(-getKontoStandIntern(daten, k.uid, dBis))
		}
		var bListe = buchungRep.getBuchungLangListe(daten, euro, true, dVon, dBis, null, null, null, Constant.KZB_AKTIV,
			false)
		for (HhBuchungLang b : bListe) {
			var db = Global.iif(euro, b.ebetrag, b.betrag)
			b.ebetrag = db
			if (Global.nes(b.belegNr)) {
				b.belegNr = b.uid
			}
		}

		// Gruppierung nach Soll- und Habenkonto
		var bMap = new HashMap<String, HhBuchungLang>
		for (HhBuchungLang b : bListe) {
			if (KontoartEnum.ERTRAGSKONTO.toString.equals(b.habenArt) ||
				KontoartEnum.AUFWANDSKONTO.toString.equals(b.habenArt)) {
				var bKey = b.sollKontoUid + b.habenKontoUid
				var b2 = bMap.get(bKey)
				if (b2 === null) {
					bMap.put(bKey, b.clone)
				} else {
					b2.ebetrag = b2.ebetrag + b.ebetrag
					b2.belegNr = b2.belegNr + ", " + b.belegNr
				}
			}
		}
		var bListeE2 = new ArrayList<HhBuchungLang>(bMap.values)
		bMap = new HashMap<String, HhBuchungLang>
		for (HhBuchungLang b : bListe) {
			if (KontoartEnum.ERTRAGSKONTO.toString.equals(b.sollArt) ||
				KontoartEnum.AUFWANDSKONTO.toString.equals(b.sollArt)) {
				var bKey = b.sollKontoUid + b.habenKontoUid
				var b2 = bMap.get(bKey)
				if (b2 === null) {
					bMap.put(bKey, b.clone)
				} else {
					b2.ebetrag = b2.ebetrag + b.ebetrag
					b2.belegNr = b2.belegNr + ", " + b.belegNr
				}
			}
		}
		var bListeA2 = new ArrayList<HhBuchungLang>(bMap.values)
		var doc = newFopDokument
		doc.addKassenbericht(true, monatlich, ueberschrift, dVon, dBis, titel, periode, dbV, dbE, dbA, dbS, kListe,
			gvListe, bListeE2, bListeA2, bListe)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	/**
	 * Liefert den Stand eines Kontos am Anfang einer Periode.
	 */
	def private double getKontoStandIntern(ServiceDaten daten, String uid, LocalDate dVon) {

		var euro = isEuroIntern
		var HhPeriode pVon
		var LocalDate dV
		var LocalDate dB
		var berechnen = false
		var String strKz
		var betrag = 0.0

		var hhKonto = getKontoIntern(daten, uid, true)
		if (istAktivPassivKontoIntern(hhKonto.art)) {
			strKz = Constant.KZBI_EROEFFNUNG
		} else {
			// strKz = Constant.KZBI_GV
			return betrag
		}
		pVon = holePassendePeriode(daten, dVon, false)
		if (pVon === null) {
			betrag = Global.iif(euro, hhKonto.ebetrag, hhKonto.betrag)
			return betrag
		}
		if (!dVon.equals(pVon.datumVon)) {
			dV = pVon.datumVon
			dB = dVon
			berechnen = true
		}
		var result = bilanzRep.get(daten, new HhBilanzKey(daten.mandantNr, pVon.nr, strKz, uid))
		if (result !== null) {
			betrag = Global.iif(euro, result.ebetrag, result.betrag)
		}

		if (berechnen) {
			var listeS = buchungRep.getBuchungSollListe(daten, uid, dV, dB, Constant.KZB_AKTIV)
			for (HhBuchungSoll bu : listeS) {
				betrag += Global.iif(euro, bu.esumme, bu.summe)
			}
			var listeH = buchungRep.getBuchungHabenListe(daten, uid, dV, dB, Constant.KZB_AKTIV)
			for (HhBuchungHaben bu : listeH) {
				betrag += Global.iif(euro, bu.esumme, bu.summe)
			}
		}
		return betrag
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhBilanz>> holeEkStaende(ServiceDaten daten, LocalDate datum) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var v = new Vector<HhBilanz>
		var r = new ServiceErgebnis<List<HhBilanz>>(v)
		var p = holePassendePeriode(daten, datum, false)
		if (p === null) {
			return r
		}
		var pnr = p.nr
		var diff = 1
		var p2 = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, pnr - 1))
		if (p2 !== null && p.datumVon.year * 12 + (p.datumVon.monthValue - 1) == //
		p2.datumVon.year * 12 + (p2.datumVon.monthValue - 1) + 1) {
			diff = 12
		}
		var pnr2 = Constant.PN_BERECHNET
		p2 = holePassendePeriode(daten, datum.minusYears(10), false)
		if (p2 !== null) {
			pnr2 = p2.nr - 1
		}
		var kontoUid = holeEkKonto(daten, true)
		while (pnr > pnr2) {
			var hhBilanz = bilanzRep.get(daten, new HhBilanzKey(daten.mandantNr, pnr, Constant.KZBI_SCHLUSS, kontoUid))
			if (hhBilanz !== null) {
				var hhPeriode = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, pnr))
				if (hhPeriode !== null) {
					hhBilanz.geaendertAm = hhPeriode.datumBis.atStartOfDay
				}
				v.add(hhBilanz)
			}
			pnr = pnr - diff
		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<HhBilanz>> holeEkGvStaende(ServiceDaten daten, LocalDate datum) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var v = new Vector<HhBilanz>
		var r = new ServiceErgebnis<List<HhBilanz>>(v)
		var p = holePassendePeriode(daten, datum, false)
		if (p === null) {
			return r
		}
		var pnr = p.nr
		var pnr2 = Constant.PN_BERECHNET
		var p2 = holePassendePeriode(daten, datum.minusYears(10), false)
		if (p2 !== null) {
			pnr2 = p2.nr - 1
		}
		val ek = holeEkKonto(daten, true)
		val gv = holeGvKonto(daten, true)
		while (pnr > pnr2) {
			var hhBilanz = bilanzRep.get(daten, new HhBilanzKey(daten.mandantNr, pnr, Constant.KZBI_SCHLUSS, ek))
			if (hhBilanz !== null) {
				var bi = bilanzRep.get(daten, new HhBilanzKey(daten.mandantNr, pnr, Constant.KZBI_GV, gv))
				if (bi !== null) {
					hhBilanz.betrag = -bi.ebetrag
				}
				var hhPeriode = periodeRep.get(daten, new HhPeriodeKey(daten.mandantNr, pnr))
				if (hhPeriode !== null) {
					hhBilanz.geaendertAm = hhPeriode.datumBis.atStartOfDay
				}
				v.add(hhBilanz)
			}
			pnr--
		}
		return r
	}

	def private String getWertM(List<String> werte, BuchungSpalten e, HashMap<BuchungSpalten, Integer> h) {

		if (werte !== null && e !== null && h !== null && h.containsKey(e)) {
			var i = h.get(e)
			if (0 <= i && i < werte.size) {
				var str = werte.get(i)
				if (!Global.nes(str)) {
					return str.trim
				}
			}
		}
		return null
	}

	@Transaction
	override ServiceErgebnis<String> importBuchungListe(ServiceDaten daten, List<String> zeilen, boolean loeschen) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (loeschen) {
			var listem = buchungRep.getListe(daten, daten.mandantNr, null, null)
			for (HhBuchung b : listem) {
				deleteBuchungIntern(daten, b.uid, false)
			}
		}
		if (Global.arrayLaenge(zeilen) <= 1) {
			throw new MeldungException(Meldungen::HH050)
		}
		var h = new HashMap<BuchungSpalten, Integer>
		for (BuchungSpalten e : BuchungSpalten.values) {
			h.put(e, -1)
		}
		var werte = Global.decodeCSV(zeilen.get(0))
		for (var i = 0; werte !== null && i < werte.size; i++) {
			var e = BuchungSpalten.fromString(werte.get(i))
			if (e !== null) {
				h.put(e, i)
			}
		}
		for (BuchungSpalten e : BuchungSpalten.values) {
			if (e.muss && h.get(e) < 0) {
				throw new MeldungException(Meldungen::HH051(e.name))
			}
		}
		var anzahl = 0
		for (var i = 1; zeilen !== null && i < zeilen.size; i++) {
			werte = Global.decodeCSV(zeilen.get(i))
			var wert = getWertM(werte, BuchungSpalten.VALUTA, h)
			var LocalDate valuta
			if (wert !== null) {
				var d = new SbDatum
				d.parse(wert)
				if (!d.isLeer) {
					valuta = d.getDate(true)
				}
			}
			var ebetrag = Global.strDbl(getWertM(werte, BuchungSpalten.BETRAG, h))
			var betrag = Global.konvDM(ebetrag)
			var solluid = getWertM(werte, BuchungSpalten.SOLLUID, h)
			var sk = getKontoIntern(daten, solluid, false)
			if (sk === null) {
				wert = getWertM(werte, BuchungSpalten.SOLLNAME, h)
				if (!Global.nes(wert)) {
					solluid = kontoRep.getMinKonto(daten, null, null, null, wert)
				}
			}
			var habenuid = getWertM(werte, BuchungSpalten.HABENUID, h)
			sk = getKontoIntern(daten, habenuid, false)
			if (sk === null) {
				wert = getWertM(werte, BuchungSpalten.HABENNAME, h)
				if (!Global.nes(wert)) {
					habenuid = kontoRep.getMinKonto(daten, null, null, null, wert)
				}
			}
			var btext = getWertM(werte, BuchungSpalten.TEXT, h)
			var belegnr = getWertM(werte, BuchungSpalten.BELEGNR, h)
			wert = getWertM(werte, BuchungSpalten.VALUTA, h)
			var LocalDate belegdatum
			if (wert !== null) {
				var d = new SbDatum
				d.parse(wert)
				if (!d.isLeer) {
					belegdatum = d.getDate(true)
				}
			}
			var angelegtVon = getWertM(werte, BuchungSpalten.ANGELEGTVON, h)
			var angelegtAm = Global.objDat(getWertM(werte, BuchungSpalten.ANGELEGTAM, h))
			var geaendertVon = getWertM(werte, BuchungSpalten.GEAENDERTVON, h)
			var geaendertAm = Global.objDat(getWertM(werte, BuchungSpalten.GEAENDERTAM, h))
			insertUpdateBuchungIntern(daten, null, valuta, betrag, ebetrag, solluid, habenuid, btext, belegnr,
				belegdatum, null, null, null, null, null, false, angelegtVon, angelegtAm, geaendertVon, geaendertAm)
			anzahl++
		}
		var r = new ServiceErgebnis<String>(Meldungen::HH053(anzahl))
		return r
	}
}

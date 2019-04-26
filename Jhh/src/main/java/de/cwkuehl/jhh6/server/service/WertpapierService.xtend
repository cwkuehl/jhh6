package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.SoKurse
import de.cwkuehl.jhh6.api.dto.WpAnlage
import de.cwkuehl.jhh6.api.dto.WpAnlageKey
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpBuchung
import de.cwkuehl.jhh6.api.dto.WpBuchungKey
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
import de.cwkuehl.jhh6.api.dto.WpKonfiguration
import de.cwkuehl.jhh6.api.dto.WpKonfigurationKey
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpStand
import de.cwkuehl.jhh6.api.dto.WpStandKey
import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.dto.WpWertpapier
import de.cwkuehl.jhh6.api.dto.WpWertpapierKey
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.enums.WpStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.global.Parameter
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.fop.dto.PnfChart
import de.cwkuehl.jhh6.server.fop.dto.PnfPattern
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.WpAnlageRep
import de.cwkuehl.jhh6.server.rep.impl.WpBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.WpKonfigurationRep
import de.cwkuehl.jhh6.server.rep.impl.WpStandRep
import de.cwkuehl.jhh6.server.rep.impl.WpWertpapierRep
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.Graphics2D
import java.awt.geom.Ellipse2D
import java.awt.geom.Line2D
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Locale
import javax.net.ssl.HttpsURLConnection
import org.json.JSONObject

@Service
class WertpapierService {

	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef WpAnlageRep anlageRep
	@RepositoryRef WpBuchungRep buchungRep
	@RepositoryRef WpKonfigurationRep konfigurationRep
	@RepositoryRef WpStandRep standRep
	@RepositoryRef WpWertpapierRep wertpapierRep

	@Transaction(false)
	override ServiceErgebnis<List<WpKonfigurationLang>> getKonfigurationListe(ServiceDaten daten,
		boolean zusammengesetzt, String status) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpKonfigurationLang>>(null)
		var liste = konfigurationRep.getKonfigurationLangListe(daten, null, status)
		for (WpKonfigurationLang e : liste) {
			fillKonfiguration(e)
			if (zusammengesetzt) {
				e.bezeichnung = PnfChart.getBezeichnung(e.bezeichnung, e.box, e.skala, e.umkehr, e.methode, e.relativ,
					e.dauer, null, 0, 0)
			}
		}
		r.ergebnis = liste
		return r
	}

	def private WpKonfigurationLang fillKonfiguration(WpKonfigurationLang e) {

		if (e !== null) {
			var array = if(Global.nes(e.parameter)) null else e.parameter.split(";")
			var l = Global.arrayLaenge(array)
			if (l >= 4) {
				e.box = Global.strDbl(array.get(0))
				e.prozentual = Global.objBool(array.get(1))
				e.skala = if(e.prozentual) 1 else 2
				e.umkehr = Global.strInt(array.get(2))
				e.methode = Global.strInt(array.get(3))
			}
			if (l >= 6) {
				e.dauer = Global.strInt(array.get(4))
				e.relativ = Global.objBool(array.get(5))
			}
			if (l >= 7) {
				e.skala = Global.strInt(array.get(6))
			}
			if (e.dauer <= 0) {
				e.dauer = 182
			}
		}
		return e
	}

	@Transaction(false)
	override ServiceErgebnis<WpKonfigurationLang> getKonfigurationLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpKonfigurationLang>(null)
		var l = konfigurationRep.getKonfigurationLangListe(daten, uid, null)
		if (l.size > 0) {
			r.ergebnis = fillKonfiguration(l.get(0))
		}
		return r
	}

	@Transaction
	override ServiceErgebnis<WpKonfiguration> insertUpdateKonfiguration(ServiceDaten daten, String uid, String bez,
		double box, boolean proz, int umkehr, int methode, int dauer, boolean relativ, int skala, String status, //
		String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (!Global.nes(uid) && Global.nes(bez)) {
			throw new MeldungException(Meldungen::WP001)
		}
		if (!Global.nes(bez) && bez.length > WpKonfiguration.BEZEICHNUNG_LAENGE) {
			throw new MeldungException(Meldungen::WP050)
		}
		if (!Global.nes(uid) && Global.nes(status)) {
			throw new MeldungException(Meldungen::WP002)
		}
		if (Global.compDouble4(box, 0) <= 0) {
			throw new MeldungException(Meldungen::WP003)
		}
		if (umkehr <= 0) {
			throw new MeldungException(Meldungen::WP004)
		}
		if (!Global.in(methode, 1, 5)) {
			throw new MeldungException(Meldungen::WP005)
		}
		if (dauer <= 10) {
			throw new MeldungException(Meldungen::WP006)
		}
		if (!Global.in(skala, 0, 2)) {
			throw new MeldungException(Meldungen::WP007)
		}
		var sb = new StringBuilder
		sb.append(Global.dblStr2l(box))
		sb.append(";").append(proz)
		sb.append(";").append(umkehr)
		sb.append(";").append(methode)
		sb.append(";").append(dauer)
		sb.append(";").append(relativ)
		sb.append(";").append(skala)
		var e = konfigurationRep.iuWpKonfiguration(daten, null, uid, bez, sb.toString, status, notiz, null, null, null,
			null)
		var r = new ServiceErgebnis<WpKonfiguration>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteKonfiguration(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		konfigurationRep.delete(daten, new WpKonfigurationKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getWertpapierProviderListe(ServiceDaten daten) {

		var liste = new ArrayList<MaEinstellung>
		var e = new MaEinstellung
		e.mandantNr = daten.mandantNr
		e.schluessel = "yahoo"
		e.wert = "Yahoo, finance.yahoo.com"
		liste.add(e)
		e = new MaEinstellung
		e.mandantNr = daten.mandantNr
		e.schluessel = "onvista"
		e.wert = "Onvista Fonds, www.onvista.de"
		liste.add(e)
		e = new MaEinstellung
		e.mandantNr = daten.mandantNr
		e.schluessel = "ariva"
		e.wert = "Ariva, www.ariva.de"
		liste.add(e)
		var r = new ServiceErgebnis<List<MaEinstellung>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getWertpapierStatusListe(ServiceDaten daten) {

		var liste = new ArrayList<MaEinstellung>
		for (WpStatusEnum p : WpStatusEnum.values) {
			var e = new MaEinstellung
			e.mandantNr = daten.mandantNr
			e.schluessel = p.toString
			e.wert = p.toString2
			liste.add(e)
		}
		var r = new ServiceErgebnis<List<MaEinstellung>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpWertpapierLang>> getWertpapierListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String muster, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpWertpapierLang>>(null)
		var liste = getWertpapierListeIntern(daten, zusammengesetzt, bez, muster, uid, null, null, false, false, null,
			null)
		r.ergebnis = liste
		return r
	}

	@Transaction
	override ServiceErgebnis<List<WpWertpapierLang>> bewerteteWertpapierListe(ServiceDaten daten,
		boolean zusammengesetzt, String bez, String muster, String uid, LocalDate bewertungsdatum, String kuid,
		StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpWertpapierLang>>(null)
		var liste = getWertpapierListeIntern(daten, zusammengesetzt, bez, muster, uid, bewertungsdatum, kuid, true,
			true, status, abbruch)
		r.ergebnis = liste
		return r
	}

	def private List<WpWertpapierLang> getWertpapierListeIntern(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String muster, String uid, LocalDate bewertungsdatum, String kuid, boolean nuraktiv, boolean speichern,
		StringBuffer status, StringBuffer abbruch) {

		var WpKonfigurationLang k
		if (!Global.nes(kuid)) {
			var l = konfigurationRep.getKonfigurationLangListe(daten, kuid, null)
			if (Global.listLaenge(l) > 0) {
				k = fillKonfiguration(l.get(0))
				k.bezeichnung = PnfChart.getBezeichnung(k.bezeichnung, 0, k.skala, k.umkehr, k.methode, k.relativ,
					k.dauer, null, 0, 0)
			}
		}
		var liste = wertpapierRep.getWertpapierLangListe(daten, bez, muster, null, uid, null, nuraktiv)
		for (WpWertpapierLang e : liste) {
			fillWertpapier(e, k)
			if (zusammengesetzt && !Global.nes(e.relationBezeichnung)) {
				e.bezeichnung = Global.anhaengen(new StringBuffer(e.bezeichnung), " (", e.relationBezeichnung, ")").
					toString
			}
		}
		if (bewertungsdatum !== null) {
			val bis = bewertungsdatum
			val von = bis.minusDays(if(k === null) 182 else k.dauer)
			val l = liste.size
			for (var i = 0; i < l && abbruch.length <= 0; i++) {
				val a = liste.get(i)
				status.length = 0
				status.append(
					Meldungen::WP008(i + 1, l, a.bezeichnung, bis.atStartOfDay,
						if(k === null) Meldungen::WP009 else k.bezeichnung))
				berechneBewertung(daten, von, bis, a, k, speichern)
			}
		}
		return liste
	}

	def private WpWertpapierLang fillWertpapier(WpWertpapierLang e, WpKonfigurationLang k) {

		if (e !== null) {
			var array = if(Global.nes(e.parameter)) null else e.parameter.split(";")
			var l = Global.arrayLaenge(array)
			e.aktuellerkurs = if(l <= 0) "" else array.get(0)
			// Zielkurs wird manuell erfasst.
			e.signalkurs1 = if (l <= 1)
				Double.POSITIVE_INFINITY
			else if (Global.compDouble4(Global.strDbl(array.get(1)), 0) == 0)
				Double.NaN
			else
				Global.strDbl(array.get(1))
			e.signalkurs2 = if(l <= 2) "" else array.get(2)
			e.stopkurs = if(l <= 3) "" else array.get(3)
			e.muster = if(l <= 4) "" else array.get(4)
			e.sortierung = if(l <= 5) "" else array.get(5)
			e.bewertung = if(l <= 6) "" else array.get(6)
			e.bewertung1 = if(l <= 7) "" else array.get(7)
			e.bewertung2 = if(l <= 8) "" else array.get(8)
			e.bewertung3 = if(l <= 9) "" else array.get(9)
			e.bewertung4 = if(l <= 10) "" else array.get(10)
			e.bewertung5 = if(l <= 11) "" else array.get(11)
			e.trend1 = if(l <= 12) "" else array.get(12)
			e.trend2 = if(l <= 13) "" else array.get(13)
			e.trend3 = if(l <= 14) "" else array.get(14)
			e.trend4 = if(l <= 15) "" else array.get(15)
			e.trend5 = if(l <= 16) "" else array.get(16)
			e.trend = if(l <= 17) "" else array.get(17)
			e.kursdatum = if(l <= 18) "" else array.get(18)
			e.xo = if(l <= 19) "" else array.get(19)
			e.signalbew = if(l <= 20) "" else array.get(20)
			e.signaldatum = if(l <= 21) "" else array.get(21)
			e.signalbez = if(l <= 22) "" else array.get(22)
			e.index1 = if(l <= 23) "" else array.get(23)
			e.index2 = if(l <= 24) "" else array.get(24)
			e.index3 = if(l <= 25) "" else array.get(25)
			e.index4 = if(l <= 26) "" else array.get(26)
			e.schnitt200 = if(l <= 27) "" else array.get(27)
			e.konfiguration = if(k === null) Meldungen::WP010 else k.bezeichnung
			e.typ = if(l <= 29) "" else array.get(29)
			e.waehrung = if(l <= 30) "" else array.get(30)
		}
		return e
	}

	def private void berechneBewertung(ServiceDaten daten, LocalDate dvon, LocalDate dbis, WpWertpapierLang wp,
		WpKonfigurationLang k, boolean speichern) {

		if (wp === null) {
			return
		}
		wp.bewertung = '''00 «Meldungen::WP010»'''
		wp.bewertung1 = ""
		wp.bewertung2 = ""
		wp.bewertung3 = ""
		wp.bewertung4 = ""
		wp.bewertung5 = ""
		wp.muster = ""
		wp.stopkurs = ""
		// wp.signalkurs1 Zielkurs (Signalkur1) wird manuell erfasst.
		wp.signalkurs2 = ""
		wp.trend1 = ""
		wp.trend2 = ""
		wp.trend3 = ""
		wp.trend4 = ""
		wp.trend5 = ""
		wp.trend = ""
		wp.kursdatum = ""
		wp.xo = ""
		wp.signalbew = ""
		wp.signaldatum = ""
		wp.signalbez = ""
		wp.index1 = ""
		wp.index2 = ""
		wp.index3 = ""
		wp.index4 = ""
		wp.schnitt200 = ""
		// wp.konfiguration = if (k === null) "ohne" else k.bezeichnung
		// wp.typ
		// wp.waehrung
		if (Global.nes(wp.datenquelle) || Global.nes(wp.kuerzel) || !"1".equals(wp.status)) {
			return
		}
		try {
			var wpr = if(k !== null && k.relativ) getWertpapierLangIntern(daten, wp.relationUid) else null
			var liste = holeKurseIntern(daten, wp.uid, dvon, dbis, wp.datenquelle, wp.kuerzel, wp.typ, wp.waehrung,
				if(wpr === null) null else wpr.datenquelle, if(wpr === null) null else wpr.kuerzel,
				if(wpr === null) null else wpr.typ, if(wpr === null) null else wpr.waehrung)
			var kursdatum = if(liste.size > 0) liste.get(liste.size - 1).datum.toLocalDate else dbis
			var signalbew = 0
			var signaldatum = dvon
			var String signalbez
			var double[] a = #[0.5, 1, 2, 3, 5]
			var String[] t = #[null, null, null, null, null]
			var int[] bew = #[0, 0, 0, 0, 0]
			for (var i = 0; i < a.length; i++) {
				var c = new PnfChart
				// c.setUmkehr(box)
				c.box = a.get(i)
				c.bezeichnung = wp.bezeichnung
				c.ziel = wp.signalkurs1
				c.stop = Global.strDbl(wp.stopkurs)
				if (k === null) {
					c.methode = 4
					c.skala = 2 // dynamisch
					c.umkehr = 3
					c.relativ = false
				} else {
					c.methode = k.methode
					c.skala = k.skala
					c.umkehr = k.umkehr
					c.relativ = k.relativ
				}
				c.addKurse(liste)
				// letztes Signal
				var p = c.pattern.reduce[prev, cur|cur] // .orElse(null)
				// nur bei letzter Säule, Signal am gleichen Tag
				if (p !== null) {
					if (p.xpos >= c.saeulen.size - 1 && p.datum.toLocalDate.equals(kursdatum)) {
						bew.set(i, p.signal)
						if (Global.nes(wp.muster)) {
							wp.muster = PnfPattern.getBezeichnung(p.muster)
						}
					}
					if (p.datum.toLocalDate.isAfter(signaldatum) ||
						(p.datum.toLocalDate.equals(signaldatum) && Math.abs(p.signal) > Math.abs(signalbew))) {
						signalbew = p.signal
						signaldatum = p.datum.toLocalDate
						signalbez = PnfPattern.getBezeichnung(p.muster)
					}
				}
				if (c.saeulen.size > 0 && c.saeulen.get(c.saeulen.size - 1).datum.toLocalDate.equals(kursdatum)) {
					wp.xo = Meldungen.WP048(if(c.saeulen.get(c.saeulen.size - 1).isO) "xo" else "ox", c.box)
				}
				if (i == 0) {
					wp.aktuellerkurs = Global.dblStr2l(c.kurs)
					if (Global.compDouble4(c.stop, 0) > 0) {
						wp.stopkurs = Global.dblStr2l(c.stop)
						wp.signalkurs2 = Global.dblStr4l(c.kurs / c.stop)
					}
				}
				var tr = c.trend
				// t.set(i, if(tr > 0) "+1" else if(tr < 0) "-1" else "0")
				t.set(i, if (tr == 2)
					"+2"
				else if (tr == 1)
					"+1"
				else if (tr == 0.5)
					"+0,5"
				else if (tr == -2)
					"-2"
				else if (tr == -1)
					"-1"
				else if (tr == -0.5)
					"-0,5"
				else if(tr == 0) "0" else Global.dblStr(tr))
			}
			wp.bewertung1 = Global.intStrFormat(bew.get(0))
			wp.bewertung2 = Global.intStrFormat(bew.get(1))
			wp.bewertung3 = Global.intStrFormat(bew.get(2))
			wp.bewertung4 = Global.intStrFormat(bew.get(3))
			wp.bewertung5 = Global.intStrFormat(bew.get(4))
			wp.bewertung = Global.format("{0,number,00}",
				bew.get(0) + bew.get(1) + bew.get(2) + bew.get(3) + bew.get(4))
			wp.trend1 = t.get(0)
			wp.trend2 = t.get(1)
			wp.trend3 = t.get(2)
			wp.trend4 = t.get(3)
			wp.trend5 = t.get(4)
			wp.trend = Global.format("{0,number,0}",
				Global.strInt(t.get(0)) + Global.strInt(t.get(1)) + Global.strInt(t.get(2)) + Global.strInt(t.get(3)) +
					Global.strInt(t.get(4)))
			wp.kursdatum = kursdatum.toString
			wp.signalbew = Global.intStr(signalbew)
			wp.signaldatum = if(signaldatum === null) "" else signaldatum.toString
			wp.signalbez = signalbez
			var int[] ia = #[182, 730, 1460, 3650]
			var double[] mina = #[0, 0, 0, 0]
			var double[] maxa = #[0, 0, 0, 0]
			var double[] difa = #[0, 0, 0, 0]
			var bis = liste.get(liste.size - 1).datum
			var min0 = liste.get(liste.size - 1).close
			for (var i = 0; i < ia.length; i++) {
				var datumi = bis.minusDays(ia.get(i))
				var mini = min0
				var maxi = 0.0
				var diff = 0.0
				for (ku : liste) {
					if (datumi.isBefore(ku.datum)) {
						// && datumi.hour == 0 && datumi.minute == 0 && datumi.second == 0) {
						// evtl. aktuellen Kurs ignorieren
						diff = diff + ku.open - ku.close
						if (Global.compDouble(diff, maxi) > 0)
							maxi = diff
						if (Global.compDouble(diff, mini) < 0)
							mini = diff
					}
				}
				mina.set(i, mini)
				maxa.set(i, maxi)
				difa.set(i, diff)
			}
			wp.index1 = Global.dblStr(ClIndex(difa.get(0), mina.get(0), maxa.get(0)))
			wp.index2 = Global.dblStr(ClIndex(difa.get(1), mina.get(1), maxa.get(1)))
			wp.index3 = Global.dblStr(ClIndex(difa.get(2), mina.get(2), maxa.get(2)))
			wp.index4 = Global.dblStr(ClIndex(difa.get(3), mina.get(3), maxa.get(3)))
			var datum14 = bis.minusDays(14)
			var datum200 = bis.minusDays(200)
			var datum214 = bis.minusDays(214)
			var summe14 = 0.0
			var summe200 = 0.0
			var summe214 = 0.0
			var anzahl14 = 0
			var anzahl200 = 0
			var anzahl214 = 0
			for (ku : liste) {
				if (datum14.isBefore(ku.datum)) {
					summe14 += ku.close
					anzahl14++
				}
				if (datum200.isBefore(ku.datum)) {
					summe200 += ku.close
					anzahl200++
				}
				if (datum214.isBefore(ku.datum)) {
					summe214 += ku.close
					anzahl214++
				}
			}
			summe214 -= summe14
			anzahl214 -= anzahl14
			if (anzahl200 > 0 && anzahl214 > 0) {
				var schnitt200 = summe200 / anzahl200
				var schnitt214 = summe214 / anzahl214
				wp.schnitt200 = Global.compDouble(schnitt200, schnitt214).toString
			}
		} catch (Exception ex) {
			wp.bewertung = '''00 «Meldungen::M1033(ex.message)»'''
		// throw new RuntimeException(ex)
		} finally {
			if (speichern) {
				var String[] b = #[wp.bewertung, wp.bewertung1, wp.bewertung2, wp.bewertung3, wp.bewertung4,
					wp.bewertung5, wp.trend1, wp.trend2, wp.trend3, wp.trend4, wp.trend5, wp.trend, wp.kursdatum, wp.xo,
					wp.signalbew, wp.signaldatum, wp.signalbez, wp.index1, wp.index2, wp.index3, //
					wp.index4, wp.schnitt200, wp.konfiguration, wp.typ, wp.waehrung]
				try {
					iuWertpapier(daten, wp.uid, wp.bezeichnung, wp.kuerzel, wp.aktuellerkurs,
						Global.dblStr2l(wp.signalkurs1), wp.signalkurs2, wp.stopkurs, wp.muster, wp.sortierung, b,
						wp.datenquelle, wp.status, wp.relationUid, wp.notiz, wp.typ, wp.waehrung)
				} catch (Exception e) {
					Global.machNichts
				}
			}
		}
	}

	def private double ClIndex(double diff, double mini, double maxi) {
		if (Global.compDouble(mini, maxi) == 0) {
			return 0
		} else {
			return (diff - mini) / (maxi - mini)
		}
	}

	def private List<SoKurse> holeKurseIntern(ServiceDaten daten, String wpuid, LocalDate dvon, LocalDate dbis, String quelle,
		String kursname, String typ, String waehrung, String quelleRelation, String kursnameRelation, String typRelation,
		String waehrungRelation) {

		var liste = holeKursListe(daten, wpuid, dvon, dbis, quelle, kursname, typ, waehrung, true, 0)
		if (liste !== null && !Global.nes(kursnameRelation)) {
			var rliste = new ArrayList<SoKurse>
			var liste2 = holeKursListe(daten, wpuid, dvon, dbis, quelleRelation, kursnameRelation, typRelation, waehrungRelation, true, 0)
			var h = new HashMap<Long, SoKurse>
			for (SoKurse k : liste2) {
				h.put(k.datum.toEpochSecond(ZoneOffset.UTC), k)
			}
			var anfang = true
			var faktor = 0.0
			for (SoKurse k : liste) {
				var k2 = h.get(k.datum.toEpochSecond(ZoneOffset.UTC))
				if (k2 !== null && Global.compDouble4(k.close, 0) != 0 && Global.compDouble4(k2.close, 0) != 0) {
					if (anfang) {
						faktor = k2.close / k.close * 100
						anfang = false
					}
					k.setClose(k.close / k2.close * faktor)
					if (Global.compDouble4(k.open, 0) != 0 && Global.compDouble4(k2.open, 0) != 0) {
						k.setOpen(k.open / k2.open * faktor)
					} else {
						k.setOpen(0)
					}
					if (Global.compDouble4(k.high, 0) != 0 && Global.compDouble4(k2.high, 0) != 0) {
						k.setHigh(k.high / k2.high * faktor)
					} else {
						k.setHigh(0)
					}
					if (Global.compDouble4(k.low, 0) != 0 && Global.compDouble4(k2.low, 0) != 0) {
						k.setLow(k.low / k2.low * faktor)
					} else {
						k.setLow(0)
					}
					rliste.add(k)
				}
			}
			liste = rliste
		}
		return liste
	}

	def private List<SoKurse> holeKursListe(ServiceDaten daten, String wpuid, LocalDate dvon, LocalDate dbis, String quelle,
		String kursname, String typ, String waehrung, boolean letzter, double klf) {

		var liste = new ArrayList<SoKurse>
		if (Global.nes(quelle) || Global.nes(kursname)) {
			return liste
		}
		var bis = if(dbis === null) daten.heute else dbis
		var von = if(dvon === null || !dvon.isBefore(bis)) bis.minusDays(182) else dvon
		var wp = kursname
		if (quelle == "yahoo") {
			var url = Global.format("https://query1.finance.yahoo.com/v7/finance/chart/{0}" +
				"?period1={1}&period2={2}&interval=1d&indicators=quote&includeTimestamps=true", wp, //
			von.atStartOfDay(ZoneOffset.UTC).toEpochSecond.toString,
				bis.atStartOfDay(ZoneOffset.UTC).toEpochSecond.toString)
			var v = executeHttps(url, null, false, null)
			if (v !== null && v.size > 0) {
				try {
					var jr = new JSONObject(v.get(0))
					var jc = jr.getJSONObject("chart")
					var error = jc.get("error")
					if (error !== null && error.toString !== "null") {
						throw new Exception(error.toString)
					}
					var jresult = jc.getJSONArray("result").getJSONObject(0)
					var jmeta = jresult.getJSONObject("meta")
					var jts = if(jresult.has("timestamp")) jresult.getJSONArray("timestamp") else null
					var jquote = jresult.getJSONObject("indicators").getJSONArray("quote").getJSONObject(0)
					if (jquote.length > 0) {
						var jopen = jquote.getJSONArray("open")
						var jclose = jquote.getJSONArray("close")
						var jlow = jquote.getJSONArray("low")
						var jhigh = jquote.getJSONArray("high")
						for (var i = 0; jts !== null && i < jts.size; i++) {
							var k = new SoKurse
							k.datum = Instant.ofEpochSecond(jts.getLong(i)).atZone(ZoneId.systemDefault).toLocalDate.
								atStartOfDay
							k.open = jopen.optDouble(i, 0)
							k.high = jhigh.optDouble(i, 0)
							k.low = jlow.optDouble(i, 0)
							k.close = jclose.optDouble(i, 0)
							k.bewertung = jmeta.getString("currency").toUpperCase
							if (Global.compDouble4(k.close, 0) != 0) {
								k.open = if(Global.compDouble4(k.open, 0) == 0) k.close else k.open
								k.high = if(Global.compDouble4(k.open, 0) == 0) k.close else k.high
								k.low = if(Global.compDouble4(k.open, 0) == 0) k.close else k.low
								liste.add(k)
							}
						}
					} else {
						var k = new SoKurse
						var tl = jmeta.getJSONObject("currentTradingPeriod").getJSONObject("pre").getLong("end")
						k.datum = Instant.ofEpochSecond(tl).atZone(ZoneId.systemDefault).toLocalDate.atStartOfDay
						k.close = jmeta.getDouble("chartPreviousClose")
						k.bewertung = jmeta.getString("currency").toUpperCase
						if (Global.compDouble4(k.close, 0) != 0) {
							k.open = k.close
							k.high = k.close
							k.low = k.close
							liste.add(k)
						}
					}
				} catch (Exception ex) {
					throw new RuntimeException(ex)
				}
			}
		} else if (quelle == "ariva") {
			var url = Global.format("https://www.ariva.de/quote/historic/historic.csv?secu={0}&boerse_id=6" +
				"&clean_split=1&clean_payout=0&clean_bezug=1&min_time={1}&max_time={2}&trenner=%3B&go=Download", wp,
				Global.dateString(von), Global.dateString(bis))
			var v = executeHttps(url, null, true, null)
			if (v !== null && v.size > 1) {
				if (v.get(0) != "Datum;Erster;Hoch;Tief;Schlusskurs;Stuecke;Volumen")
					throw new RuntimeException('''Falsches Format: "«v.get(0)»" statt "Datum;Erster;Hoch;Tief;Schlusskurs;Stuecke;Volumen"''')
				for (var i = 1; i < v.size; i++) {
					var c = Global.decodeCSV(v.get(i), ';', ';')
					if (c !== null && c.size >= 5) {
						var k = new SoKurse
						k.datum = LocalDate.parse(c.get(0)).atStartOfDay
						k.open = Global.strDbl(c.get(1), Locale.GERMAN)
						k.high = Global.strDbl(c.get(2), Locale.GERMAN)
						k.low = Global.strDbl(c.get(3), Locale.GERMAN)
						k.close = Global.strDbl(c.get(4), Locale.GERMAN)
						k.bewertung = 'EUR'
						k.preis = 1
						if (Global.compDouble4(k.close, 0) != 0)
							liste.add(k)
					}
				}
			}
		} else if (quelle == "onvista") {
			if (Global.nes(typ)) {
				val d = bis.year * 365 + bis.dayOfYear - (von.year * 365 + von.dayOfYear)
				var span = '''«d»D'''
				// if (d > 365) {
				// val y = d / 365 + 1
				// span = '''«y»Y'''
				// von = bis.minusYears(y)
				// }
				var url = Global.format(
					"https://www.onvista.de/fonds/snapshotHistoryCSV?idNotation={0}" +
						"&datetimeTzStartRange={1}&timeSpan={2}&codeResolution=1D", wp, Global.dateString(von), span)
				var v = executeHttps(url, null, true, null)
				if (v !== null && v.size > 1) {
					val vt = von.atStartOfDay
					val bt = bis.plusDays(1).atStartOfDay
					if (v.get(0) != "Datum;Eröffnung;Hoch;Tief;Schluss;Volumen")
						throw new RuntimeException('''Falsches Format: "«v.get(0)»" statt "Datum;Eröffnung;Hoch;Tief;Schluss;Volumen"''')
					for (var i = 1; i < v.size; i++) {
						var c = Global.decodeCSV(v.get(i), ';', ';')
						if (c !== null && c.size >= 5) {
							var k = new SoKurse
							k.datum = Global.objDat2(c.get(0))?.atStartOfDay
							k.open = Global.strDbl(c.get(1), Locale.GERMAN)
							k.high = Global.strDbl(c.get(2), Locale.GERMAN)
							k.low = Global.strDbl(c.get(3), Locale.GERMAN)
							k.close = Global.strDbl(c.get(4), Locale.GERMAN)
							k.bewertung = if (Global.nes(waehrung)) 'EUR' else waehrung
							k.preis = 1
							if (k.datum.compareTo(vt) >= 0 && k.datum.compareTo(bt) < 0 && Global.compDouble4(k.close, 0) != 0)
								liste.add(k)
						}
					}
				}
			} else {
				var date = Global.werktag(bis)
				while (!date.isBefore(von)) {
					val d = (date.toEpochDay * 86400) + 39944
					var url = Global.format(
						"https://www.onvista.de/component/timesAndSalesCsv?codeMarket=_STU&idInstrument={0}" +
							"&idTypeCategory=2&day={1}", wp, d.toString)
					var v = executeHttps(url, null, true, null)
					if (v !== null && v.size > 1) {
						if (v.get(0) != "Zeit;Kurs;Stück;Kumuliert")
							throw new RuntimeException('''Falsches Format: "«v.get(0)»" statt "Zeit;Kurs;Stück;Kumuliert"''')
						var k = new SoKurse
						for (var i = 1; i < v.size; i++) {
							// absteigende Uhrzeit
							var c = Global.decodeCSV(v.get(i), ';', ';')
							if (c !== null && c.size >= 4) {
								// Prozent
								k.open = Global.strDbl(c.get(1), Locale.ENGLISH) / 100 // Prozent
								if (i == 1) {
									k.high = k.open
									k.low = k.open
									k.close = k.open
								} else {
									k.high = Math.max(k.high, k.open)
									k.low = Math.min(k.low, k.open)
								}
							}
						}
						if (Global.compDouble4(k.open, 0) != 0) {
							k.datum = date.atStartOfDay
							k.bewertung = if (Global.nes(waehrung)) 'EUR' else waehrung
							k.preis = 1
							liste.add(k)
						}
					}
					if (liste.size > 0)
						date = Global.werktag(date.minusDays(1))
					else
						date = von.minusDays(1) // Schleife beenden
				}
			}
		}
		if (liste.size <= 1 && !Global.nes(wpuid)) {
			var datum = if (liste.size <= 0) null else liste.get(0).datum 
			var liste2 = standRep.getStandLangListe(daten, wpuid, von, bis, true)
			for (st : liste2) {
				if (datum === null || datum.compareTo(st.datum.atStartOfDay) != 0) {
					var k = new SoKurse
					k.datum = st.datum.atStartOfDay
					k.open = st.stueckpreis
					k.high = st.stueckpreis
					k.low = st.stueckpreis
					k.close = st.stueckpreis
					k.bewertung = 'EUR'
					liste.add(k)
				}
			}
		}
		var cur = if (liste.size > 0) liste.get(0).bewertung else null
		var curprice = if (liste.size > 0) getAktWaehrungKurs(daten, cur, liste.get(liste.size - 1).datum.toLocalDate) else null
		var kl = klf
		for (k : liste) {
			if (Global.compDouble4(kl, 0) == 0) {
				kl = k.close
			}
			if (curprice !== null) {
				k.open = k.open * curprice.close
				k.high = k.high * curprice.close
				k.low = k.low * curprice.close
				k.close = k.close * curprice.close
				k.preis = curprice.close
			}
			while (Global.compDouble4(kl, 0) != 0 && Global.compDouble4(k.close / kl, 5) > 0) {
				// richtig skalieren: bei WATL.L Faktor 100. 
				k.open = k.open / 10
				k.high = k.high / 10
				k.low = k.low / 10
				k.close = k.close / 10
			}
		}

		// Datum aufsteigend
		Collections.sort(liste) [ k1, k2 |
			if (k1.datum === null) {
				if (k2.datum === null) {
					return 0
				}
				return 1
			} else if (k2.datum === null) {
				return -1
			}
			return k1.datum.compareTo(k2.datum)
		]

		// if(letzter && !bis.isBefore(daten.heute)) {
		// var k = getAktKurs(daten, wp, daten.heute, kl, false)
		// if(k !== null) {
		// var ll = if(liste.size <= 0) null else liste.get(liste.size - 1)
		// if(ll === null || k.datum.isAfter(ll.datum))
		// liste.add(k)
		// }
		// }
		return liste
	}

	var df0 = DateTimeFormatter.ofPattern("M/d/yyyy", Locale.ENGLISH)
	var df = DateTimeFormatter.ofPattern("h:mma", Locale.ENGLISH)

	def private SoKurse getAktKurs(ServiceDaten daten, String wpuid, String quelle, String kuerzel, String typ, String waehrung, LocalDate heute, double kl) {

		var von = heute.minusDays(7)
		var l = holeKursListe(daten, wpuid, von, heute, quelle, kuerzel, typ, waehrung, false, kl)
		if (l !== null && l.size > 0) {
			return l.get(l.size - 1)
		}
		return null
	}

	def private String getFixerIoAccessKey(ServiceDaten daten) {

		var p = parameterRep.get(daten, new MaParameterKey(daten.mandantNr, Parameter.WP_FIXER_IO_ACCESS_KEY))
		if (p !== null) {
			return p.wert
		}
		return null
	}

	protected static HashMap<String, SoKurse> wkurse = new HashMap

	def private SoKurse getAktWaehrungKurs(ServiceDaten daten, String kuerzel, LocalDate heute) {

		if (Global.nes(kuerzel)) {
			return null
		}
		if (kuerzel == "EUR") {
			var k = new SoKurse
			k.close = 1
			k.bewertung = "EUR"
			return k
		}
		if (heute === null) {
			return null
		}
		var key = '''«heute» «kuerzel»'''
		var wert = WertpapierService::wkurse.get(key)
		if (wert !== null) {
			return wert
		}
		var accesskey = getFixerIoAccessKey(daten)
		if (Global.nes(accesskey)) {
			throw new MeldungException(Meldungen.WP049)
		}
		var url = '''http://data.fixer.io/api/«heute»?symbols=«kuerzel»&access_key=«accesskey»'''
		var v = executeHttp(url, null, false, null)
		if (v !== null && v.size > 0) {
			try {
				var jr = new JSONObject(v.get(0))
				var success = jr.getBoolean("success")
				if (!success) {
					var error = jr.getJSONObject("error")
					var info = error.getString("info")
					throw new Exception(info)
				}
				var jresult = jr.getJSONObject("rates")
				if (jresult.has(kuerzel)) {
					var k = new SoKurse
					k.datum = LocalDate.parse(jr.getString("date")).atStartOfDay
					k.close = jresult.optDouble(kuerzel)
					if (Global.compDouble(k.close, 0) != 0)
						k.close = Global.rundeBetrag4(1 / k.close)
					k.open = k.close
					k.high = k.close
					k.low = k.close
					k.bewertung = kuerzel
					WertpapierService::wkurse.put(key, k)
					return k
				}
			} catch (Exception ex) {
				throw new RuntimeException(ex)
			}
		}
		return null
	}

	def private List<String> executeHttp(String targetURL, String urlParameters, boolean lines, StringBuffer cookie) {

		var URL url
		var HttpURLConnection connection
		try {
			// Create connection
			url = new URL(targetURL)
			connection = url.openConnection as HttpURLConnection
			if (!Global.nes(urlParameters)) {
				connection.requestMethod = "POST"
				connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
				connection.setRequestProperty("Content-Length", "" + Integer.toString(urlParameters.bytes.length))
				connection.setRequestProperty("Content-Language", "en-US")
				connection.useCaches = false
				connection.doInput = true
			}
			if (cookie !== null && cookie.length > 0) {
				connection.requestMethod = "POST"
				connection.setRequestProperty("Cookie", cookie.toString)
				connection.useCaches = false
				connection.doInput = true
			}
			connection.doOutput = true
			connection.connectTimeout = 3000
			connection.readTimeout = 3000

			// Send request
			var wr = new DataOutputStream(connection.outputStream)
			if (!Global.nes(urlParameters)) {
				wr.writeBytes(urlParameters)
			}
			wr.flush
			wr.close

			// Get Response
			if (cookie !== null && cookie.length <= 0) {
				var cookies = connection.headerFields.get("set-cookie")
				if (cookies !== null && cookies.length > 0) {
					var c = cookies.get(0)
					if (c !== null)
						cookie.append(c.split(" ").get(0))
				}
				return null
			}
			if (connection.responseCode != HttpURLConnection.HTTP_OK) {
				throw new Exception(Meldungen::WP012(connection.responseCode, targetURL))
			}
			var is = connection.inputStream
			var rd = new BufferedReader(new InputStreamReader(is, "UTF-8"))
			var v = new ArrayList<String>
			var String line
			while ((line = rd.readLine) !== null) {
				v.add(line)
			}
			if (!lines && v.length > 1) {
				var sb = new StringBuilder
				for (s : v) {
					sb.append(s)
				}
				v.clear
				v.add(sb.toString)
			}
			rd.close
			return v
		} catch (Exception ex) {
			throw new RuntimeException(ex)
		} finally {
			if (connection !== null) {
				connection.disconnect
			}
		}
	}

	def private List<String> executeHttps(String targetURL, String urlParameters, boolean lines, StringBuffer cookie) {

		var URL url
		var HttpsURLConnection connection
		try {
			// Create connection
			url = new URL(targetURL)
			connection = url.openConnection as HttpsURLConnection
			connection.connectTimeout = 3000
			connection.readTimeout = 3000
			if (connection.responseCode != HttpURLConnection.HTTP_OK) {
				throw new Exception(Meldungen::WP012(connection.responseCode, targetURL))
			}
			var is = connection.getInputStream
			var rd = new BufferedReader(new InputStreamReader(is, "UTF-8"))
			var v = new ArrayList<String>
			var String line
			while ((line = rd.readLine) !== null) {
				v.add(line)
			}
			if (!lines && v.length > 1) {
				var sb = new StringBuilder
				for (s : v) {
					sb.append(s)
				}
				v.clear
				v.add(sb.toString)
			}
			rd.close
			return v
		} catch (Exception ex) {
			throw new RuntimeException(ex)
		} finally {
			if (connection !== null) {
				connection.disconnect
			}
		}
	}

	/**
	 * Anlegen oder Ändern eines Wertpapiers.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Wertpapier-Nummer.
	 * @param bez Bezeichnung.
	 * @param kuerzel Kürzel für Datenabfrage.
	 * @param aktkurs0 Aktueller Kurs.
	 * @param signal1 1. Signalkurs.
	 * @param signal20 2. Signalkurs.
	 * @param stop0 Stopkurs.
	 * @param muster0 letztes erkanntes Muster.
	 * @param sort Sortiermerkmal.
	 * @param bew0 Array von Bewertungen.
	 * @param quelle Datenquelle.
	 * @param status Status.
	 * @param ruid Relation zu anderem Wertpapier.
	 * @param notiz Notiz.
	 * @param typ Typ.
	 * @param waehrung Währungskürzel.
	 */
	def private WpWertpapier iuWertpapier(ServiceDaten daten, String uid, String bez, String kuerzel, String aktkurs0,
		String signal1, String signal20, String stop0, String muster0, String sort, String[] bew0, String quelle,
		String status, String ruid, String notiz, String typ, String waehrung) {

		var strB = bez
		var strQ = quelle
		var strK = kuerzel
		var strStatus = status
		var aktkurs = aktkurs0
		var signal2 = signal20
		var stop = stop0
		var muster = muster0
		var bew = bew0

		if (Global.nes(uid)) {
			if (Global.nes(strB)) {
				strB = Meldungen::WP013(strK)
			}
			if (Global.nes(strStatus)) {
				strStatus = "0"
			}
		}
		if (Global.nes(strB)) {
			throw new MeldungException(Meldungen::WP001)
		}
		if (!Global.nes(strB) && strB.length > WpWertpapier.BEZEICHNUNG_LAENGE) {
			throw new MeldungException(Meldungen::WP050)
		}
		if (Global.nes(status)) {
			throw new MeldungException(Meldungen::WP002)
		}
		if (Global.nes(strQ)) {
			strQ = ""
			strK = ""
		} else if (Global.nes(strK)) {
			throw new MeldungException(Meldungen::WP014)
		}
		if (bew === null) {
			var WpWertpapierLang w
			if (Global.nes(uid))
				w = new WpWertpapierLang
			else {
				// Update aus Formular
				w = getWertpapierLangIntern(daten, uid)
				aktkurs = w.aktuellerkurs
				signal2 = w.signalkurs2
				stop = w.stopkurs
				muster = w.muster
			}
			bew = #[w.bewertung, w.bewertung1, w.bewertung2, w.bewertung3, w.bewertung4, w.bewertung5, w.trend1,
				w.trend2, w.trend3, w.trend4, w.trend5, w.trend, w.kursdatum, w.xo, w.signalbew, w.signaldatum, //
				w.signalbez, w.index1, w.index2, w.index3, w.index4, w.schnitt200, w.konfiguration, typ, waehrung]
		}
		var sb = new StringBuilder
		sb.append(Global.dblStr2l(Global.strDbl(aktkurs)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(signal1)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(signal2)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(stop)))
		sb.append(";").append(muster)
		sb.append(";").append(sort)
		for (var i = 0; bew !== null && i < bew.length; i++) {
			sb.append(";")
			if (bew.get(i) !== null) {
				sb.append(bew.get(i))
			}
		}
		return wertpapierRep.iuWpWertpapier(daten, null, uid, strB, strK, sb.toString, strQ, strStatus, ruid, notiz,
			null, null, null, null)
	}

	def private WpWertpapierLang getWertpapierLangIntern(ServiceDaten daten, String uid) {

		var l = wertpapierRep.getWertpapierLangListe(daten, null, null, uid, null, null, false)
		if (l.size > 0) {
			return fillWertpapier(l.get(0), null)
		}
		return null
	}

	@Transaction(false)
	override ServiceErgebnis<WpWertpapierLang> getWertpapierLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpWertpapierLang>(getWertpapierLangIntern(daten, uid))
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteWertpapier(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = wertpapierRep.getWertpapierLangListe(daten, null, null, null, null, uid, false)
		if (liste.size > 0) {
			throw new MeldungException(Meldungen::WP015)
		}
		var aliste = anlageRep.getAnlageLangListe(daten, null, null, uid)
		if (aliste.size > 0) {
			throw new MeldungException(Meldungen::WP016)
		}
		wertpapierRep.delete(daten, new WpWertpapierKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction
	override ServiceErgebnis<WpWertpapier> insertUpdateWertpapier(ServiceDaten daten, String uid, String bez,
		String kuerzel, String signal1, String sort, String quelle, String status, String ruid, String notiz,
		String typ, String waehrung) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var e = iuWertpapier(daten, uid, bez, kuerzel, null, signal1, null, null, null, sort, null, quelle, status,
			ruid, notiz, typ, waehrung)
		var r = new ServiceErgebnis<WpWertpapier>(e)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<SoKurse>> holeKurse(ServiceDaten daten, String wpuid, LocalDate dvon, LocalDate dbis, String quelle,
		String kursname, String typ, String waehrung, String relationUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var wpr = if (Global.nes(relationUid)) null else getWertpapierLangIntern(daten, relationUid)
		var r = new ServiceErgebnis<List<SoKurse>>(
			holeKurseIntern(daten, wpuid, dvon, dbis, quelle, kursname, typ, waehrung,
				if(wpr === null) null else wpr.datenquelle, if(wpr === null) null else wpr.kuerzel,
				if(wpr === null) null else wpr.typ, if(wpr === null) null else wpr.waehrung))
		return r
	}

	def private List<String> getWertpapierSpalten() {

		var l = newArrayList("Kursdatum", "Konfiguration", "Uid", "Bezeichnung", "RelationBezeichnung", "Bewertung",
			"Trend", "Bewertung1", "Trend1", "Bewertung2", "Trend2", "Bewertung3", "Trend3", "Bewertung4", "Trend4",
			"Bewertung5", "Trend5", "Aktuellerkurs", "Signalkurs1", "Stopkurs", "Signalkurs2", "Muster", //
			"Sortierung", "Kuerzel", "Xo", "Signalbew", "Signaldatum", "Signalbez", "Index1", "Index2", "Index3",
			"Index4", "Schnitt200", "Typ", "Waehrung", "GeaendertAm", "GeaendertVon", "AngelegtAm", "AngelegtVon")
		return l
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> exportWertpapierListe(ServiceDaten daten, String bez, String muster,
		String uid, String kuid, LocalDate datum, int tage, StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var felder = getWertpapierSpalten
		var l = new ArrayList<String>
		l.add(Global.encodeCSV(felder))
		var LocalDate d
		var anzahl = tage
		if (datum !== null && tage > 0) {
			d = Global.werktag(datum)
		} else {
			anzahl = 1
		}
		var array = if(Global.nes(kuid)) newArrayOfSize(1) else kuid.split(";")
		while (anzahl > 0) {
			for (k : array) {
				var liste = getWertpapierListeIntern(daten, true, bez, muster, uid, d, k, true, false, status, abbruch)
				exportListeFuellen(felder, liste, new WpWertpapierLang, l)
			}
			if (d !== null) {
				d = Global.werktag(d.minusDays(1))
			}
			anzahl--
		}
		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}

	/**
	 * Zeichnen eines Point & Figure-Charts.
	 */
	def private void paintChart(PnfChart c, Graphics2D p) {

		val xgroesse = c.xgroesse as double
		val ygroesse = c.ygroesse as double
		val max = c.posmax as double
		val xoffset = xgroesse * 1.5
		val yoffset = ygroesse * 4.0
		val xanzahl = c.saeulen.size as double
		val yanzahl = c.werte.size as double
		var b = 0.0
		var h = 0.0
		var x = 0.0
		var y = 0.0
		val fontx = new Font("TimesRoman", Font.PLAIN, (ygroesse + 1.5) as int)
		val fontplain = new Font("TimesRoman", Font.PLAIN, ygroesse as int)
		val fontbold = new Font("TimesRoman", Font.BOLD, ygroesse as int)

		var stroke = 1.2
		var color = Color.black
		var font = fontplain

		// Werte schreiben
		stroke = 0.5
		color = Color.lightGray
		x = xoffset + (xanzahl + 2) * xgroesse
		y = yoffset + c.werte.size * ygroesse
		var aktkurs = c.kurs
		var yakt = -1;
		if (Global.compDouble4(aktkurs, 0) > 0) {
			var d = c.max + 1;
			for (var i = 0; i < yanzahl; i++) {
				if (Global.compDouble4(c.werte.get(i), d) < 0 && Global.compDouble4(c.werte.get(i), aktkurs) > 0) {
					d = c.werte.get(i)
					yakt = i
				}
			}
		}
		for (var i = 0; i < yanzahl + 1; i++) {
			if (i < yanzahl) {
				if (i == yakt) {
					font = fontbold
					color = Color.black
					drawString(p, x + 5, y, Global.dblStr(Global.round(aktkurs)), font, color)
					font = fontplain
					color = Color.lightGray
				} else {
					drawString(p, x + 5, y, Global.dblStr(Global.round(c.werte.get(i))), font, color)
				}
			}
			drawLine(p, xoffset, y, x, y, color, stroke) // waagerechte Linien
			y -= ygroesse
		}

		// Datumswerte schreiben
		x = xoffset
		y = yoffset + yanzahl * ygroesse
		for (var i = 0; i < xanzahl + 3; i++) {
			drawLine(p, x, yoffset, x, y, color, stroke) // senkrechte Linien
			if (i % 6 == 0 && i < xanzahl && c.saeulen.get(i).datum !== null) {
				drawString(p, x + xgroesse, y + ygroesse * 1.5, Global.dateTimeStringForm(c.saeulen.get(i).datum), font,
					color)
			}
			x += xgroesse
		}

		// Säulen
		stroke = 1.2
		drawString(p, xoffset, ygroesse * 2, c.bezeichnung, font, color)
		drawString(p, xoffset, ygroesse * 3.3, c.bezeichnung2, font, color)
		b = xoffset + xgroesse
		h = 0
		// var xd = xgroesse / 2
		// var yd = ygroesse / 2
		for (s : c.saeulen) {
			h = s.ypos
			var array = s.chars
			for (char xo : array) {
				x = b
				y = (max - h + 1) * ygroesse + yoffset
				if (xo == Character.valueOf('O')) {
					color = Color.red
					// drawOval(p, x + xd, y - xd, xd - 1, yd - 1, stroke, color)
					drawOval(p, x + 1, y - ygroesse + 1, xgroesse - 2, ygroesse - 2, stroke, color)
				} else if (xo == Character.valueOf('X')) {
					color = Color.green
					drawString(p, x + 1, y, "X", fontx, color)
				} else {
					color = Color.black
					drawString(p, x + 2, y - 1, String.valueOf(xo), font, color)
				}
				h += 1
			}
			b += xgroesse
		}

		// Trendlinien
		stroke = 2
		for (t : c.trends) {
			x = (t.xpos + 1) * xgroesse + xoffset
			y = (max - t.ypos) * ygroesse + yoffset
			b = t.laenge * xgroesse
			if (t.boxtyp == 0) {
				b += xgroesse
				h = 0
				color = Color.red
			} else if (t.boxtyp == 1) {
				h = -t.laenge * ygroesse
				color = Color.blue
			} else {
				h = t.laenge * ygroesse
				y += ygroesse
				color = Color.blue
			}
			drawLine(p, x, y, x + b, y + h, color, stroke)
		}

		// Muster
		stroke = 2
		color = new Color(0.5803922f, 0.0f, 0.827451f) // DARKVIOLET
		for (pa : c.pattern) {
			x = (pa.xpos + 1) * xgroesse + xoffset
			y = (max - pa.ypos) * ygroesse + yoffset
			drawString(p, x, y, pa.bezeichnung, font, color)
		}
	}

	def private void drawOval(Graphics2D p, double x, double y, double w, double h, double stroke, Color color) {

		// p.fill(null)
		p.paint = color
		p.stroke = new BasicStroke(stroke as float)
		p.draw(new Ellipse2D.Double(x, y, w, h))
	// p.drawOval(x as int, y as int, w as int,h as int)
	}

	def private void drawString(Graphics2D p, double x, double y, String str, Font font, Color color) {

		p.font = font
		p.paint = color
		p.drawString(str, x as int, y as int)
	}

	def private void drawLine(Graphics2D p, double x, double y, double x2, double y2, Color color, double stroke) {

		p.paint = color
		p.stroke = new BasicStroke(stroke as float)
		p.draw(new Line2D.Double(x, y, x2, y2));
	}

//	def private List<SoKurse> getChart(ServiceDaten daten, WpWertpapierLang wp, WpKonfigurationLang k, LocalDate dbis,
//		List<SoKurse> l, HSSFWorkbook wb, HSSFSheet sheet, int cp, int rp, HSSFRow row) {
//
//		var dvon = dbis.minusDays(k.dauer)
//		var liste = if(l === null)
//				holeKurseIntern(daten, dvon, dbis, wp.kuerzel, if(k !== null && k.relativ) wp.relationKuerzel else null)
//			else
//				l
//		val c = new PnfChart
//		c.box = k.box
//		c.bezeichnung = wp.bezeichnung
//		c.ziel = wp.signalkurs1
//		c.stop = Global.strDbl(wp.stopkurs)
//		c.methode = k.methode
//		c.skala = k.skala
//		c.umkehr = k.umkehr
//		c.relativ = k.relativ
//		c.addKurse(liste)
//		var d0 = c.computeDimension(500, 500)
//		var d = c.getDimension(d0.width, d0.height)
//		var width = d.width
//		var height = d.height
//
//		row.heightInPoints = (height * 0.75) as float
//		sheet.setColumnWidth(cp, width * 40)
//		// TYPE_INT_ARGB specifies the image format: 8-bit RGBA packed into integer pixels
//		var bi = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB)
//		var ig2 = bi.createGraphics
//		paintChart(c, ig2)
//
//		var pictureIdx = 0
//		var osp = new ByteArrayOutputStream
//		try {
//			ImageIO.write(bi, "PNG", osp)
//		} finally {
//			osp.flush
//			pictureIdx = wb.addPicture(osp.toByteArray, Workbook.PICTURE_TYPE_PNG)
//			osp.close
//		}
//		var drawing = sheet.createDrawingPatriarch
//		var helper = wb.creationHelper
//		// add a picture shape
//		var anchor = helper.createClientAnchor
//		// set top-left corner of the picture,
//		// subsequent call of Picture#resize() will operate relative to it
//		anchor.setCol1(cp)
//		anchor.setRow1(rp)
//		var pict = drawing.createPicture(anchor, pictureIdx)
//		// auto-size picture relative to its top-left corner
//		pict.resize
//		return liste
//	}
	@Transaction(false)
	override ServiceErgebnis<byte[]> exportWertpapierVergleichListe(ServiceDaten daten, String uid, String kuid,
		LocalDate datum, LocalDate datum2, LocalDate datum3, StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<byte[]>
		// var warray = if(Global.nes(uid)) newArrayOfSize(1) else uid.split(";")
		if (Global.nes(uid) || datum === null || datum2 === null || datum3 === null) {
			return r
		}
//		var wb = new HSSFWorkbook
//		var WpKonfigurationLang k
//		if(!Global.nes(kuid)) {
//			var l = konfigurationRep.getKonfigurationLangListe(daten, kuid, null)
//			if(Global.listLaenge(l) > 0) {
//				k = fillKonfiguration(l.get(0))
//				k.relativ = false
//				k.bezeichnung = PnfChart.getBezeichnung(k.bezeichnung, 0, k.skala, k.umkehr, k.methode, k.relativ,
//					k.dauer, null, 0, 0)
//			}
//		}
//		if(k === null) {
//			k = new WpKonfigurationLang
//			k.bezeichnung = "ohne Konfiguration"
//			k.dauer = 182
//			k.methode = 4
//			k.umkehr = 3
//		}
//		k.skala = 1 // prozentual
//		k.relativ = false
//		var zeiten = #[datum, datum2, datum3]
//		var us = #['''Kauf «datum.toString»''', '''Verkauf «datum2.toString»''', '''Aktuell «datum3.toString»''']
//		var double[] boxen = #[5, 2, 1, 1]
//		var dauern = #[5 * 365 + 1, 365 + 182, 182, 5 * 365 + 1]
//
//		for (wuid : warray) {
//			var cp = -3
//			var wp = getWertpapierLangIntern(daten, wuid)
//			status.length = 0
//			status.append(wp.bezeichnung)
//			var wp1 = if(Global.nes(wp.relationUid)) null else getWertpapierLangIntern(daten, wp.relationUid)
//			var wp2 = wp
//			var sheet = wb.createSheet(wp.bezeichnung)
//			var row0 = sheet.createRow(0)
//			var row2 = sheet.createRow(2)
//			var row3 = sheet.createRow(3)
//			var row5 = sheet.createRow(5)
//			var row6 = sheet.createRow(6)
//			for (var i = 0; i <= 2 && abbruch.length <= 0; i++) {
//				var rp = 3
//				cp = cp + 3
//				var dbis = zeiten.get(i)
//				var cell = row0.createCell(cp)
//				cell.cellValue = us.get(i)
//				if(wp1 !== null) {
//					// var List<SoKurse> liste
//					k.box = boxen.get(0)
//					k.dauer = dauern.get(0)
//					k.relativ = false
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp, rp - 1, row2)
//					k.box = boxen.get(1)
//					k.dauer = dauern.get(1)
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp + 1, rp - 1, row2)
//					k.box = boxen.get(2)
//					k.dauer = dauern.get(3)
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp, rp, row3)
//				}
//				rp = rp + 3
//				if(wp2 !== null) {
//					k.box = boxen.get(0)
//					k.dauer = dauern.get(0)
//					k.relativ = false
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp, rp - 1, row5)
//					k.box = boxen.get(1)
//					k.dauer = dauern.get(1)
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp + 1, rp - 1, row5)
//					k.box = boxen.get(2)
//					k.dauer = dauern.get(2)
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp, rp, row6)
//					if(wp1 !== null) {
//						k.box = boxen.get(3)
//						k.dauer = dauern.get(3)
//						k.relativ = true
//						wp2.bezeichnung = Global.anhaengen(new StringBuffer(wp2.bezeichnung), " (",
//							wp2.relationBezeichnung, ")").toString
//						getChart(daten, wp2, k, dbis, null, wb, sheet, cp + 1, rp, row6)
//					}
//				}
//			}
//		}
//		var os = new ByteArrayOutputStream
//		try {
//			wb.write(os)
//		} finally {
//			os.flush
//			r.ergebnis = os.toByteArray
//			os.close
//		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpAnlageLang>> getAnlageListe(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String uid, String wpuid, boolean auchinaktive) {

		var liste = getAnlageLangListeIntern(daten, zusammengesetzt, bez, uid, wpuid, null, auchinaktive, null, null)
		var r = new ServiceErgebnis<List<WpAnlageLang>>(liste)
		return r
	}

	@Transaction
	override ServiceErgebnis<List<WpAnlageLang>> bewerteteAnlageListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String uid, String wpuid, LocalDate bewertungsdatum, StringBuffer status, StringBuffer abbruch) {

		var r = new ServiceErgebnis<List<WpAnlageLang>>(null)
		var liste = getAnlageLangListeIntern(daten, zusammengesetzt, bez, uid, wpuid, bewertungsdatum, false, status, abbruch)
		r.ergebnis = liste
		return r
	}

	def private WpAnlageLang fillAnlageLang(WpAnlageLang a, boolean zusammengesetzt) {

		var array = if(Global.nes(a.parameter)) null else a.parameter.split(";")
		var l = Global.arrayLaenge(array)
		if (l >= 11) {
			a.betrag = Global.strDbl(array.get(0))
			a.anteile = Global.strDbl(array.get(1))
			a.preis = Global.strDbl(array.get(2))
			a.zinsen = Global.strDbl(array.get(3))
			a.aktpreis = Global.strDbl(array.get(4))
			a.aktdatum = if(Global.nes(array.get(5))) null else LocalDateTime.parse(array.get(5))
			a.wert = Global.strDbl(array.get(6))
			a.gewinn = Global.strDbl(array.get(7))
			a.pgewinn = Global.strDbl(array.get(8))
			a.waehrung = array.get(9)
			a.kurs = Global.strDbl(array.get(10))
		}
		a.mindatum = if(l >= 12 && !Global.excelNes(array.get(11))) LocalDateTime.parse(array.get(11)) else null
		a.status = if(l >= 13 && !Global.excelNes(array.get(12))) Global.strInt(array.get(12)) else 1
		if (zusammengesetzt) {
			var p0 = if(a.aktdatum === null) null else Meldungen::WP026(a.aktdatum)
			var pm = if(a.mindatum === null) null else Meldungen::WP051(a.mindatum)
			var p1 = if(Global.nes(a.waehrung)) p0 else Meldungen::WP025(a.waehrung, a.kurs, p0)
			var p2 = if (a.anteile == 0 || a.aktpreis == 0)
					null
				else
					Meldungen::WP024(a.aktpreis, p1, a.wert, a.gewinn, a.pgewinn)
			a.daten = if (a.anteile == 0)
				null
			else
				Meldungen::WP023(a.betrag, pm, a.anteile, a.preis, a.zinsen, p2)
		}
		return a
	}

	def private WpAnlageLang fillAnlageLangParameter(WpAnlageLang a) {

		var sb = new StringBuilder
		sb.append(Global.dblStr2l(a.betrag))
		sb.append(";").append(Global.dblStr5l(a.anteile))
		sb.append(";").append(Global.dblStr4l(a.preis))
		sb.append(";").append(Global.dblStr2(a.zinsen))
		sb.append(";").append(Global.dblStr4l(a.aktpreis))
		sb.append(";").append(if(a.aktdatum === null) '' else a.aktdatum.toString)
		sb.append(";").append(Global.dblStr2l(a.wert))
		sb.append(";").append(Global.dblStr2l(a.gewinn))
		sb.append(";").append(Global.dblStr2l(a.pgewinn))
		sb.append(";").append(Global.nn(a.waehrung))
		sb.append(";").append(Global.dblStr4l(a.kurs))
		sb.append(";").append(if(a.mindatum === null) '' else a.mindatum.toString)
		sb.append(";").append(Global.intStr(a.status))
		a.parameter = sb.toString
		return a
	}

	def private List<WpAnlageLang> getAnlageLangListeIntern(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String uid, String wpuid, LocalDate bewertungsdatum, boolean auchinaktive, StringBuffer status, StringBuffer abbruch) {

		var liste = anlageRep.getAnlageLangListe(daten, bez, uid, wpuid)
		if (bewertungsdatum !== null) {
			val bis = bewertungsdatum
			val l = liste.size
			for (var i = 0; i < l && abbruch.length <= 0; i++) {
				val a = liste.get(i)
				status.length = 0
				status.append(Meldungen::WP008(i + 1, l, a.bezeichnung, bis.atStartOfDay, null))
				fillAnlageLang(a, false)
				if (a.status == 1) {
					// nur aktive Anlagen berechnen
					var wp = getWertpapierLangIntern(daten, a.wertpapierUid)
					var bliste = buchungRep.getBuchungLangListe(daten, null, null, null, a.uid, null, bis, false)
					var betrag0 = bliste.map[b|b.zahlungsbetrag].reduce[sum, x|sum + x]
					a.betrag = if(betrag0 === null) 0.0 else betrag0
					var rabatt = bliste.map[b|b.rabattbetrag].reduce[sum, x|sum + x]
					rabatt = if(rabatt === null) 0.0 else rabatt
					a.betrag = a.betrag - rabatt
					var anteile0 = bliste.map[b|b.anteile].reduce[sum, x|sum + x]
					a.anteile = if(anteile0 === null) 0.0 else anteile0
					a.preis = if(a.anteile == 0) 0 else a.betrag / a.anteile
					var zinsen0 = bliste.map[b|b.zinsen].reduce[sum, x|sum + x]
					a.zinsen = if(zinsen0 === null) 0.0 else zinsen0
					a.mindatum = bliste.map[b|b.datum.atStartOfDay].reduce[x,y|if (x.isBefore(y)) x else y]
					var SoKurse k
					try {
						k = getAktKurs(daten, null, wp.datenquelle, wp.kuerzel, wp.typ, wp.waehrung, bis, a.preis)
					} catch (Exception ex) {
						// ignorieren
						Global.machNichts
					}
					if (k === null) {
						var s = standRep.getAktStand(daten, wp.uid, bis)
						if (s !== null) {
							k = new SoKurse
							k.close = s.stueckpreis
							k.datum = s.datum.atStartOfDay
							k.bewertung = 'EUR'
							k.preis = 1
						}
					}
					a.aktpreis = if(k === null) 0 else k.close // * kurs
					a.aktdatum = if(k === null) null else k.datum
					a.waehrung = if (k === null) '' else k.bewertung
					a.wert = a.anteile * a.aktpreis
					a.gewinn = a.wert + a.zinsen - a.betrag
					a.pgewinn = if(a.wert == 0 || a.betrag == 0) 0 else if (a.gewinn < 0) a.gewinn / a.wert * 100 else a.gewinn / a.betrag * 100
					a.kurs = k.preis
					fillAnlageLangParameter(a)
					anlageRep.iuWpAnlage(daten, null, a.uid, a.wertpapierUid, a.bezeichnung, a.parameter, a.notiz, null,
						null, null, null)
					if (a.aktdatum !== null && Global.compDouble4(a.aktpreis, 0) > 0) {
						var st = standRep.get(daten, new WpStandKey(daten.mandantNr, a.wertpapierUid, a.aktdatum.toLocalDate))
						if (st === null || Global.compDouble4(st.stueckpreis, a.aktpreis) != 0)
							standRep.iuWpStand(daten, null, a.wertpapierUid, a.aktdatum.toLocalDate, a.aktpreis, null, null, null, null)
					}
				}
			}
		}
		var l2 = new ArrayList<WpAnlageLang>
		for (a : liste) {
			fillAnlageLang(a, zusammengesetzt)
			if (auchinaktive || a.status != 0)
				l2.add(a)
		}
		return l2
	}

	@Transaction(false)
	override ServiceErgebnis<WpAnlageLang> getAnlageLang(ServiceDaten daten, String uid) {

		var l = getAnlageLangListeIntern(daten, true, null, uid, null, null, true, null, null)
		var r = new ServiceErgebnis<WpAnlageLang>(if(l.size > 0) l.get(0) else null)
		return r
	}

	@Transaction
	override ServiceErgebnis<WpAnlage> insertUpdateAnlage(ServiceDaten daten, String uid, String wpuid, String bez,
		String notiz, int status) {

		if (Global.nes(bez)) {
			throw new MeldungException(Meldungen::WP001)
		}
		if (!Global.nes(bez) && bez.length > WpAnlage.BEZEICHNUNG_LAENGE) {
			throw new MeldungException(Meldungen::WP050)
		}
		if (Global.nes(wpuid) || wertpapierRep.get(daten, new WpWertpapierKey(daten.mandantNr, wpuid)) === null) {
			throw new MeldungException(Meldungen::WP017)
		}
		var String parameter
		if (!Global.nes(uid)) {
			var liste = anlageRep.getAnlageLangListe(daten, null, uid, null)
			var a = if (liste === null || liste.size <= 0) null else liste.get(0)
			if (a !== null) {
				fillAnlageLang(a, false)
				a.status = status
				fillAnlageLangParameter(a)
				parameter = a.parameter
			}
		}
		var e = anlageRep.iuWpAnlage(daten, null, uid, wpuid, bez, parameter, notiz, null, null, null, null)
		var r = new ServiceErgebnis<WpAnlage>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteAnlage(ServiceDaten daten, String uid) {

		var bliste = buchungRep.getBuchungLangListe(daten, null, null, null, uid, null, null, false)
		if (bliste.size > 0) {
			throw new MeldungException(Meldungen::WP018)
		}
		anlageRep.delete(daten, new WpAnlageKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpBuchungLang>> getBuchungListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String uid, String wpuid, String auid) {

		var r = new ServiceErgebnis<List<WpBuchungLang>>(null)
		var liste = buchungRep.getBuchungLangListe(daten, bez, uid, wpuid, auid, null, null, true)
//		for (WpBuchungLang e : liste) {
//			if (zusammengesetzt) {
//				e.bezeichnung = Global.anhaengen(new StringBuffer(e.wertpapierBezeichnung), ", ", e.bezeichnung).
//					toString
//			}
//		}
		r.ergebnis = liste
		return r
	}

	def private WpBuchungLang getBuchungLangIntern(ServiceDaten daten, String uid) {

		var l = buchungRep.getBuchungLangListe(daten, null, uid, null, null, null, null, false)
		if (l.size > 0) {
			var b = l.get(0)
			return b
		}
		return null
	}

	@Transaction(false)
	override ServiceErgebnis<WpBuchungLang> getBuchungLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpBuchungLang>(getBuchungLangIntern(daten, uid))
		return r
	}

	@Transaction
	override ServiceErgebnis<WpBuchung> insertUpdateBuchung(ServiceDaten daten, String uid, String auid,
		LocalDate datum, double betrag, double rabatt, double anteile, double zinsen, String btext, //
		String notiz, double stand) {

		var WpAnlage anlage
		if (!Global.nes(auid)) {
			anlage = anlageRep.get(daten, new WpAnlageKey(daten.mandantNr, auid))
		}
		if (anlage === null) {
			throw new MeldungException(Meldungen::WP019)
		}
		if (datum === null) {
			throw new MeldungException(Meldungen::WP020)
		}
		if (Global.nes(btext)) {
			throw new MeldungException(Meldungen::WP021)
		}
		if (Global.compDouble(betrag, 0) == 0 && Global.compDouble(rabatt, 0) == 0 &&
			Global.compDouble4(anteile, 0) == 0 && Global.compDouble(zinsen, 0) == 0) {
			throw new MeldungException(Meldungen::WP022)
		}
		var WpBuchung balt
		if (!Global.nes(uid)) {
			balt = buchungRep.get(daten, new WpBuchungKey(daten.mandantNr, uid))
		}
		var e = buchungRep.iuWpBuchung(daten, null, uid, anlage.wertpapierUid, auid, datum, betrag, rabatt, anteile,
			zinsen, btext, notiz, null, null, null, null)

		// Stand korrigieren
		var stand2 = stand
		if (balt !== null && balt.datum != datum) {
			if (balt.wertpapierUid == anlage.wertpapierUid && stand == 0) {
				// Datum-Änderung nimmt den Stand mit
				var st = standRep.get(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
				if (st !== null) {
					stand2 = st.stueckpreis
					standRep.delete(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
				}
			}
			if (balt.wertpapierUid != anlage.wertpapierUid) {
				standRep.delete(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
			}
		}
		if (Global.compDouble(stand2, 0) <= 0) {
			standRep.delete(daten, new WpStandKey(daten.mandantNr, anlage.wertpapierUid, datum))
		} else {
			standRep.iuWpStand(daten, null, anlage.wertpapierUid, datum, stand2, null, null, null, null)
		}
		var r = new ServiceErgebnis<WpBuchung>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteBuchung(ServiceDaten daten, String uid) {

		buchungRep.delete(daten, new WpBuchungKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpStandLang>> getStandListe(ServiceDaten daten, boolean zusammengesetzt, String wpuid,
		LocalDate von, LocalDate bis) {

		var r = new ServiceErgebnis<List<WpStandLang>>(null)
		var liste = standRep.getStandLangListe(daten, wpuid, von, bis, true)
		// for (WpAnlageLang e : liste) {
		// if (zusammengesetzt) {
		// e.bezeichnung = Global.anhaengen(new StringBuffer(e.wertpapierBezeichnung), ", ", e.bezeichnung).
		// toString
		// }
		// }
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<WpStand> getStand(ServiceDaten daten, String wpuid, LocalDate datum) {

		var r = new ServiceErgebnis<WpStand>(standRep.get(daten, new WpStandKey(daten.mandantNr, wpuid, datum)))
		return r
	}

	@Transaction
	override ServiceErgebnis<WpStand> insertUpdateStand(ServiceDaten daten, String wpuid, LocalDate datum,
		double betrag) {

		if (Global.nes(wpuid) || wertpapierRep.get(daten, new WpWertpapierKey(daten.mandantNr, wpuid)) === null) {
			throw new MeldungException(Meldungen::WP017)
		}
		var e = standRep.iuWpStand(daten, null, wpuid, datum, betrag, null, null, null, null)
		var r = new ServiceErgebnis<WpStand>(e)
		return r
	}

	@Transaction
	override ServiceErgebnis<Void> deleteStand(ServiceDaten daten, String wpuid, LocalDate datum) {

		standRep.delete(daten, new WpStandKey(daten.mandantNr, wpuid, datum))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

}

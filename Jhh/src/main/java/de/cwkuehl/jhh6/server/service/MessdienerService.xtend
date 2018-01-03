package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.MoEinteilung
import de.cwkuehl.jhh6.api.dto.MoEinteilungKey
import de.cwkuehl.jhh6.api.dto.MoEinteilungLang
import de.cwkuehl.jhh6.api.dto.MoGottesdienst
import de.cwkuehl.jhh6.api.dto.MoGottesdienstKey
import de.cwkuehl.jhh6.api.dto.MoMessdiener
import de.cwkuehl.jhh6.api.dto.MoMessdienerKey
import de.cwkuehl.jhh6.api.dto.MoMessdienerLang
import de.cwkuehl.jhh6.api.dto.MoProfil
import de.cwkuehl.jhh6.api.dto.MoProfilKey
import de.cwkuehl.jhh6.api.enums.MoStatusEnum
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
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.MoEinteilungRep
import de.cwkuehl.jhh6.server.rep.impl.MoGottesdienstRep
import de.cwkuehl.jhh6.server.rep.impl.MoMessdienerRep
import de.cwkuehl.jhh6.server.rep.impl.MoProfilRep
import de.cwkuehl.jhh6.server.service.impl.MessdienerSpalten
import de.cwkuehl.jhh6.server.service.impl.MoLexer
import de.cwkuehl.jhh6.server.service.impl.MoLexer.Token
import de.cwkuehl.jhh6.server.service.impl.SbDatum
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.List

@Service
class MessdienerService {

	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef MoEinteilungRep einteilungRep
	@RepositoryRef MoGottesdienstRep gottesdienstRep
	@RepositoryRef MoMessdienerRep messdienerRep
	@RepositoryRef MoProfilRep profilRep

	@Transaction(false)
	override ServiceErgebnis<List<MoProfil>> getProfilListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MoProfil>>(null)
		var liste = profilRep.getProfilListe(daten, null)
		if (zusammengesetzt) {
			for (MoProfil e : liste) {
				e.name = Global.anhaengen(new StringBuffer(e.name), ", ", e.dienste).toString
			}
		}
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<MoProfil> getProfil(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<MoProfil>(profilRep.get(daten, new MoProfilKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<MoProfil> insertUpdateProfil(ServiceDaten daten, String uid, String name, String dienste,
		String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(name)) {
			throw new MeldungException(Meldungen.M2088)
		}
		if (Global.nes(dienste)) {
			throw new MeldungException(Meldungen.M2089)
		}
		pruefDienste(daten, dienste)
		var e = profilRep.iuMoProfil(daten, null, uid, name, 0, dienste, notiz, null, null, null, null)
		var r = new ServiceErgebnis<MoProfil>(e)
		return r
	}

	def private HashMap<String, Integer> pruefDienste(ServiceDaten daten, String dienste) {

		if (Global.nes(dienste) || !dienste.matches("^([A-Za-zäöüßÄÖÜ0-1]+;\\d+)(;[A-Za-zäöüßÄÖÜ0-1]+;\\d+)*$")) {
			throw new MeldungException(Meldungen.M2089)
		}
		var array = dienste.split(";")
		if (array.length % 2 == 1) {
			throw new MeldungException(Meldungen.M2089)
		}
		var liste = getParameterAlsListe(daten, Parameter.MO_DIENSTE)
		var hash = new HashMap<String, Integer>
		for (MaEinstellung e : liste) {
			hash.put(e.schluessel, 0)
		}
		for (var j = 0; j < array.length; j = j + 2) {
			if (!hash.containsKey(array.get(j))) {
				throw new MeldungException(Meldungen.M2091(array.get(j)))
			}
			if (!Global.isNumeric(array.get(j + 1))) {
				throw new MeldungException(Meldungen.M2092(array.get(j + 1)))
			}
			hash.put(array.get(j), Global.strInt(array.get(j + 1)))
		}
		return hash
	}

	def private MaEinstellung[] getParameterAlsListe(ServiceDaten daten, String key) {

		var p = parameterRep.get(daten, new MaParameterKey(daten.mandantNr, key))
		if (p !== null && !Global.nes(p.wert)) {
			var a = p.wert.split(";")
			var MaEinstellung[] liste = newArrayOfSize(a.length)
			for (var i = 0; i < a.length; i++) {
				liste.set(i, new MaEinstellung)
				liste.get(i).schluessel = a.get(i)
				liste.get(i).wert = a.get(i)
			}
			return liste
		}
		throw new MeldungException(Meldungen.M2090(key))
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteProfil(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (gottesdienstRep.getGottesdienstListe(daten, uid, null, null, null, false).size > 0) {
			throw new MeldungException(Meldungen.M2081)
		}
		profilRep.delete(daten, new MoProfilKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MoMessdiener>> getMessdienerListe(ServiceDaten daten, boolean zusammengesetzt) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MoMessdiener>>(null)
		var liste = messdienerRep.getMessdienerListe(daten, null, null, null)
		if (zusammengesetzt) {
			for (MoMessdiener e : liste) {
				e.name = Global.anhaengen(new StringBuffer(e.name), ", ", e.vorname).toString
			}
		}
		r.ergebnis = liste
		return r
	}

	def private LocalDate getFlamboGrenze(ServiceDaten daten) {

		var p = parameterRep.get(daten, new MaParameterKey(daten.mandantNr, Parameter.MO_FLAMBO_GRENZE))
		if (p !== null && Global.strInt(p.wert) > 0) {
			return LocalDate.of(Global.strInt(p.wert), 1, 1)
		}
		return LocalDate.of(LocalDate.now.year - 2, 1, 1)
	}

	@Transaction(false)
	override ServiceErgebnis<List<MoMessdienerLang>> getMessdienerListe(ServiceDaten daten, boolean automatisch,
		LocalDateTime termin, String dienst) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var flamboGrenze = getFlamboGrenze(daten)
		var liste = messdienerRep.getMessdienerLangListe(daten, automatisch, termin, dienst, null, null)
		var liste2 = new ArrayList<MoMessdienerLang>
		for (MoMessdienerLang e : liste) {
			var sb = new StringBuffer(e.name)
			Global.anhaengen(sb, ", ", e.vorname)
			Global.anhaengen(sb, " (", e.von.year.toString, ")")
			if (e.von.compareTo(flamboGrenze) >= 0) {
				sb.append(" FLAMBO!")
			}
			if (MoStatusEnum.MANUELL.toString.equals(e.status)) {
				sb.append(" MANUELL!")
			}
			if (!Global.nes(e.messdienerUid)) {
				Global.anhaengen(sb, " mit ", e.messdienerName)
				Global.anhaengen(sb, ", ", e.messdienerVorname)
			}
			var mliste = messdienerRep.getMessdienerListe(daten, null, null, e.uid)
			if (Global.listLaenge(mliste) > 0) {
				var m = mliste.get(0)
				if (e.messdienerUid != m.uid) {
					Global.anhaengen(sb, " mit ", m.name)
					Global.anhaengen(sb, ", ", m.vorname)
				}
			}
			var et = einteilungRep.getLastEinteilung(daten, e.uid, termin)
			if (et === null) {
				e.termin = LocalDate.of(1, 1, 1).atStartOfDay
			} else {
				e.termin = et.termin
				Global.anhaengen(sb, ", ", Global.dateTimeStringForm(e.termin))
			}
			Global.anhaengen(sb, ", ", e.notiz)
			e.setInfo(sb.toString)
			if (!"Flambo".equals(dienst) || e.von.compareTo(flamboGrenze) >= 0) {
				liste2.add(e)
			}
		// System.out.println(sb.toString)
		}
		liste = liste2
		Collections.sort(liste) [ o1, o2 |
			var m1 = MoStatusEnum.MANUELL.toString.equals(o1.status)
			var m2 = MoStatusEnum.MANUELL.toString.equals(o2.status)
			if (m1 != m2) {
				if (m1) {
					return 1
				} else {
					return -1
				}
			}
			return o1.termin.compareTo(o2.termin)
		]
		var r = new ServiceErgebnis<List<MoMessdienerLang>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<MoMessdiener> getMessdiener(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<MoMessdiener>(messdienerRep.get(daten, new MoMessdienerKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<MoMessdiener> insertUpdateMessdiener(ServiceDaten daten, String uid, String name,
		String vorname, LocalDate von, LocalDate bis, String adresse1, String adresse2, String adresse3, String email,
		String email2, String telefon, String telefon2, String verfuegbar, String dienste0, String mitUid,
		String status, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(name)) {
			throw new MeldungException("Der Name darf nicht leer sein.")
		}
		if (von === null) {
			throw new MeldungException("Der Eintritt darf nicht leer sein.")
		}
		if (MoStatusEnum.AUTOMATISCH.toString.equals(status)) {
			if (Global.nes(dienste0)) {
				throw new MeldungException("Mindestens ein Dienst muss ausgewählt werden.")
			}
			if (Global.nes(verfuegbar)) {
				throw new MeldungException("Mindestens eine Verfügbarkeit muss ausgewählt werden.")
			}
		}
		if (!Global.nes(uid) && Global.compString(uid, mitUid) == 0) {
			throw new MeldungException("Das Dienen mit sich selbst ist sinnlos.")
		}
		var dienste = addStandardDienste(dienste0)
		var e = messdienerRep.iuMoMessdiener(daten, null, uid, name, vorname, von, bis, adresse1, adresse2, adresse3,
			email, email2, telefon, telefon2, verfuegbar, dienste, mitUid, status, notiz, null, null, null, null)
		var r = new ServiceErgebnis<MoMessdiener>(e)
		return r
	}

	def private String addStandardDienste(String dienste) {

		var sb = new StringBuffer
		if (!Global.nes(dienste)) {
			sb.append(dienste)
		}
		if (!sb.toString.contains("Flambo")) {
			Global.anhaengen(sb, ";", "Flambo")
		}
		if (!sb.toString.contains("Dienst")) {
			Global.anhaengen(sb, ";", "Dienst")
		}
		return sb.toString
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteMessdiener(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deleteMessdienerIntern(daten, uid, true)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private void deleteMessdienerIntern(ServiceDaten daten, String uid, boolean pruefen) {

		var liste = messdienerRep.getMessdienerListe(daten, null, null, uid)
		if (pruefen && liste.size > 0) {
			throw new MeldungException(Meldungen.M2076)
		}
		messdienerRep.delete(daten, new MoMessdienerKey(daten.mandantNr, uid))
		// Abhängigkeiten löschen
		var listee = einteilungRep.getEinteilungListe(daten, null, uid)
		for (MoEinteilung e : listee) {
			einteilungRep.delete(daten, e)
		}
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardDienstListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MaEinstellung>>(getParameterAlsListe(daten, Parameter.MO_DIENSTE))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardNameListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MaEinstellung>>(getParameterAlsListe(daten, Parameter.MO_NAME))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardOrtListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MaEinstellung>>(getParameterAlsListe(daten, Parameter.MO_ORT))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardVerfuegbarListe(ServiceDaten daten) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MaEinstellung>>(getParameterAlsListe(daten, Parameter.MO_VERFUEGBAR))
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getStandardStatusListe(ServiceDaten daten) {

		var liste = new ArrayList<MaEinstellung>
		for (MoStatusEnum p : MoStatusEnum.values) {
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
	override ServiceErgebnis<List<MoGottesdienst>> getGottesdienstListe(ServiceDaten daten, boolean zusammengesetzt,
		LocalDate von, LocalDate bis) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MoGottesdienst>>(null)
		var liste = gottesdienstRep.getGottesdienstListe(daten, null, von, bis, null, true)
		// if (zusammengesetzt) {
		// for (MoGottesdienst e : liste) {
		// e.name = Global.anhaengen(new StringBuffer(e.name), ", ", e.vorname).toString
		// }
		// }
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<MoGottesdienst> getGottesdienst(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<MoGottesdienst>(
			gottesdienstRep.get(daten, new MoGottesdienstKey(daten.mandantNr, uid)))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<MoGottesdienst> insertUpdateGottesdienst(ServiceDaten daten, String uid, LocalDateTime t,
		String name, String ort, String pUid, String status, String notiz, List<MoEinteilungLang> et) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (Global.nes(uid) && et !== null) {
			for (MoEinteilungLang e2 : et) {
				e2.uid = null
			}
		}
		pruefEinteilungen(daten, pUid, et)
		var e = gottesdienstRep.iuMoGottesdienst(daten, null, uid, t, name, ort, pUid, status, notiz, null, null, null,
			null)
		updateEinteilungen(daten, e.uid, t, et)
		var r = new ServiceErgebnis<MoGottesdienst>(e)
		return r
	}

	def private void pruefEinteilungen(ServiceDaten daten, String profilUid, List<MoEinteilungLang> einteilungen) {

		if (!Global.nes(profilUid)) {
			var p = profilRep.get(daten, new MoProfilKey(daten.mandantNr, profilUid))
			if (p === null) {
				throw new MeldungException(Meldungen.M2087)
			}
			var hash = pruefDienste(daten, p.dienste)
			var Integer i = null
			if (einteilungen !== null) {
				for (MoEinteilungLang e : einteilungen) {
					i = hash.get(e.dienst)
					if (i === null) {
						throw new MeldungException(Meldungen.M2091(e.dienst))
					}
					hash.put(e.dienst, i - 1)
				}
			}
			for (String s : hash.keySet) {
				i = hash.get(s)
				if (i > 0) {
					throw new MeldungException(Meldungen.M2093(s))
				}
			}
		}
	}

	def private void updateEinteilungen(ServiceDaten daten, String gottesdienstUid, LocalDateTime termin,
		List<MoEinteilungLang> einteilungen) {

		// bestehende Einteilungen lesen
		var listeAlt = einteilungRep.getEinteilungListe(daten, gottesdienstUid, null)
		var hash = new HashSet<String>
		if (einteilungen !== null) {
			for (MoEinteilungLang s : einteilungen) {
				if (!Global.nes(s.uid)) {
					hash.add(s.uid)
				}
			}
		}
		// fehlende Einteilungen löschen
		for (MoEinteilung sa : listeAlt) {
			if (!hash.contains(sa.uid)) {
				deleteEinteilungIntern(daten, sa.uid)
			}
		}
		if (einteilungen !== null) {
			for (MoEinteilungLang s : einteilungen) {
				einteilungRep.iuMoEinteilung(daten, null, s.uid, gottesdienstUid, s.messdienerUid, termin, s.dienst,
					null, null, null, null)
			}
		}
	}

	def private void deleteEinteilungIntern(ServiceDaten daten, String uid) {
		einteilungRep.delete(daten, new MoEinteilungKey(daten.mandantNr, uid))
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteGottesdienst(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		deleteGottesdienstIntern(daten, uid, true)
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private void deleteGottesdienstIntern(ServiceDaten daten, String uid, boolean pruefen) {

		gottesdienstRep.delete(daten, new MoGottesdienstKey(daten.mandantNr, uid))
		// Abhängigkeiten löschen
		var listee = einteilungRep.getEinteilungListe(daten, uid, null)
		for (MoEinteilung e : listee) {
			einteilungRep.delete(daten, e)
		}
	}

	@Transaction(false)
	override ServiceErgebnis<List<MoEinteilungLang>> getEinteilungListe(ServiceDaten daten, boolean zusammengesetzt,
		String gdUid, String mdUid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<MoEinteilungLang>>(null)
		var liste = einteilungRep.getEinteilungLangListe(daten, gdUid, mdUid)
		var l = new ArrayList<MoEinteilungLang>
		if (Global.listLaenge(liste) > 0) {
			for (MoEinteilungLang s : liste) {
				if (!Global.nes(s.uid)) {
					// leeren Eintrag aus left join entfernen
					l.add(s)
				}
			}
		}
		// if (zusammengesetzt) {
		// for (MoGottesdienst e : liste) {
		// e.name = Global.anhaengen(new StringBuffer(e.name), ", ", e.vorname).toString
		// }
		// }
		r.ergebnis = l
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> getReportMessdienerordnung(ServiceDaten daten, LocalDate von, LocalDate bis) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = gottesdienstRep.getGottesdienstLangListe(daten, null, von, bis, false)
		if (Global.listLaenge(liste) <= 0) {
			throw new MeldungException("Keine Gottesdienst mit Einteilungen vorhanden.")
		}
		var doc = newFopDokument
		doc.addMessdienerordnung(true, von, bis, liste)
		var r = new ServiceErgebnis<byte[]>
		r.ergebnis = doc.erzeugePdf
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> exportMessdienerListe(ServiceDaten daten, LocalDate von, LocalDate bis) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var felder = newArrayList("Uid", "Name", "Vorname", "Von", "Bis", "Adresse1", "Adresse2", "Adresse3", "Email",
			"Email2", "Telefon", "Telefon2", "Verfuegbarkeit", "Dienste", "MessdienerUid", "Status", "Notiz",
			"MessdienerName", "MessdienerVorname", "AngelegtVon", "AngelegtAm", "GeaendertVon", "GeaendertAm")
		var liste = messdienerRep.getMessdienerLangListe(daten, false, null, null, von, bis)
		var l = new ArrayList<String>
		l.add(Global.encodeCSV(felder))
		exportListeFuellen(felder, liste, new MoMessdienerLang, l)

		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}

	def private String getWertM(List<String> werte, MessdienerSpalten e, HashMap<MessdienerSpalten, Integer> h) {

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

	@Transaction(true)
	override ServiceErgebnis<String> importMessdienerListe(ServiceDaten daten, List<String> zeilen, boolean loeschen) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (loeschen) {
			var listem = messdienerRep.getListe(daten, daten.mandantNr, null, null)
			for (MoMessdiener b : listem) {
				deleteMessdienerIntern(daten, b.uid, false)
			}
		}
		if (Global.arrayLaenge(zeilen) <= 1) {
			throw new MeldungException("Die Datei ist zu kurz.")
		}
		var h = new HashMap<MessdienerSpalten, Integer>
		for (MessdienerSpalten e : MessdienerSpalten.values) {
			h.put(e, -1)
		}
		var werte = Global.decodeCSV(zeilen.get(0))
		for (var i = 0; werte !== null && i < werte.size; i++) {
			var e = MessdienerSpalten.fromString(werte.get(i))
			if (e !== null) {
				h.put(e, i)
			}
		}
		for (MessdienerSpalten e : MessdienerSpalten.values) {
			if (e.muss && h.get(e) < 0) {
				throw new MeldungException("Die Spalte " + e.name + " ist nicht vorhanden.")
			}
		}
		var anzahl = 0
		for (var i = 1; zeilen !== null && i < zeilen.size; i++) {
			werte = Global.decodeCSV(zeilen.get(i))
			var suche2 = false
			var name = getWertM(werte, MessdienerSpalten.NAME, h)
			var vorname = getWertM(werte, MessdienerSpalten.VORNAME, h)
			var name2 = getWertM(werte, MessdienerSpalten.NAME2, h)
			if (name2 !== null) {
				suche2 = true
			}
			var vorname2 = getWertM(werte, MessdienerSpalten.VORNAME2, h)
			if (vorname2 !== null) {
				suche2 = true
			}
			var telefon = getWertM(werte, MessdienerSpalten.TELEFON, h)
			if (!Global.nes(telefon)) {
				telefon = telefon.replace(" ", "")
			}
			var email = getWertM(werte, MessdienerSpalten.EMAIL, h)
			if (!Global.nes(email)) {
				email = email.replace(" ", "").toLowerCase
			}
			var email2 = getWertM(werte, MessdienerSpalten.EMAIL2, h)
			if (!Global.nes(email2)) {
				email2 = email2.replace(" ", "").toLowerCase
			}
			var wert = getWertM(werte, MessdienerSpalten.SEIT, h)
			var LocalDate von = null
			if (wert !== null) {
				var d = new SbDatum
				d.parse(wert)
				if (!d.isLeer) {
					von = d.getDate(true)
				}
			}
			wert = getWertM(werte, MessdienerSpalten.BIS, h)
			var LocalDate bis = null
			if (wert !== null && Global.strInt(wert) > 0) {
				var d = new SbDatum
				d.parse(wert)
				if (!d.isLeer) {
					bis = d.getDate(false)
				}
			}
			wert = getWertM(werte, MessdienerSpalten.MANUELL, h)
			var String status = null
			if (wert === null) {
				status = MoStatusEnum.AUTOMATISCH.toString
			} else {
				status = MoStatusEnum.MANUELL.toString
			}
			var String mitUid = null
			if (suche2) {
				var liste2 = messdienerRep.getMessdienerListe(daten, name2, vorname2, null)
				if (liste2.size <= 0) {
					throw new MeldungException("Der 2. Messdiener in Zeile " + i + " ist nicht vorhanden.")
				} else if (liste2.size == 1) {
					mitUid = liste2.get(0).uid
				} else {
					throw new MeldungException("Der 2. Messdiener in Zeile " + i + " ist doppeldeutig.")
				}
			}
			var sb = new StringBuffer
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.DI18, h))) null else MessdienerSpalten.DI18.name)
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.DO18, h))) null else MessdienerSpalten.DO18.name)
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.FR18, h))) null else MessdienerSpalten.FR18.name)
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.SA18, h))) null else MessdienerSpalten.SA18.name)
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.SO08, h))) null else MessdienerSpalten.SO08.name)
			Global.anhaengen(sb, ";",
				if(Global.nes(getWertM(werte, MessdienerSpalten.SO10, h))) null else MessdienerSpalten.SO10.name)
			if (sb.length <= 0) {
				// keine Angabe: immer verfügbar
				Global.anhaengen(sb, ";", MessdienerSpalten.DI18.name)
				Global.anhaengen(sb, ";", MessdienerSpalten.DO18.name)
				Global.anhaengen(sb, ";", MessdienerSpalten.FR18.name)
				Global.anhaengen(sb, ";", MessdienerSpalten.SA18.name)
				Global.anhaengen(sb, ";", MessdienerSpalten.SO08.name)
				Global.anhaengen(sb, ";", MessdienerSpalten.SO10.name)
			}
			var verfuegbar = sb.toString
			var liste = messdienerRep.getMessdienerListe(daten, name, vorname, null)
			if (liste.size <= 0) {
				// insert
				anzahl++
				var dienste = addStandardDienste(null)
				messdienerRep.iuMoMessdiener(daten, null, null, name, vorname, von, bis, null, null, null, email,
					email2, telefon, null, verfuegbar, dienste, mitUid, status, null, null, null, null, null)
			} else if (liste.size == 1) {
				// update
				var m = liste.get(0)
				messdienerRep.iuMoMessdiener(daten, null, m.uid, name, vorname, von, bis, m.adresse1, m.adresse2,
					m.adresse3, email, email2, telefon, m.telefon2, verfuegbar, addStandardDienste(m.dienste), mitUid,
					status, m.notiz, null, null, null, null)
			} else {
				throw new MeldungException("Der Messdiener in Zeile " + i + " ist doppeldeutig.")
			}
		}
		var r = new ServiceErgebnis<String>(
			Global.format("Es wurde(n) {0} Messdiener importiert.", Global.intStr(anzahl)))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<String> importGottesdienstListe(ServiceDaten daten, List<String> zeilen,
		boolean loeschen) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if (loeschen) {
			// Was soll gelöscht werden?
			// MoMessdienerWO wom = new MoMessdienerWO
			// wom.setMandantNrEq(mandantNr)
			// List<MoMessdiener> listem = getMoMessdienerDao.findList(wom)
			// for (MoMessdiener b : listem) {
			// deleteMessdienerIntern(daten, b.getUid, false)
			// }
		}
		if (Global.arrayLaenge(zeilen) <= 1) {
			throw new MeldungException("Die Datei ist zu kurz.")
		}
		var sb = new StringBuffer
		for (String s : zeilen) {
			sb.append(s).append(Constant.CRLF)
		}
		var anzahl = 0
		var jahr = -1
		var messe = -1
		var zeile = 1
		var String messename = null
		var LocalDateTime messedatum = null
		var String messeort = null
		var String dienst = null
		var String zeit = null
		var MoGottesdienst g = null
		var addGd = false
		var addMd = false
		var namen = new ArrayList<String>
		var tokens = MoLexer.lex(sb.toString)
		for (Token token : tokens) {
			addGd = false
			addMd = false
			switch (token.type) {
				case WOCHENTAG: {
					messe = 0
					messename = null
					messedatum = null
					messeort = null
					zeit = null
					dienst = null
					namen.clear
				}
				case UHR: {
					if (zeit === null) {
						throw new MeldungException("Unbekannte Uhrzeit.");
					}
					if (messedatum === null) {
						throw new MeldungException("Unbekanntes Messedatum.");
					}
					var z = zeit.split("\\.")
					var minute = 0
					var stunde = 0
					if (z.length >= 1) {
						stunde = Global.strInt(z.get(0))
					}
					if (z.length >= 2) {
						minute = Global.strInt(z.get(1))
					}
					messedatum = messedatum.plusMinutes(minute - messedatum.minute).plusHours(stunde - messedatum.hour)
					namen.clear
				// System.out.println(messedatum)
				}
				case ZEIT:
					if (messe == 1) {
						zeit = token.data;
					}
				case DATUMZEIT:
					if (messe == 0) {
						if (jahr < 0) {
							throw new MeldungException("Das Jahr ist nicht festgelegt.");
						}
						var str = token.data + "." + jahr;
						messedatum = Global.objDat(str)
						messe = 1
					} else if (messe == 1) {
						zeit = token.data
					}
				case DATUM: {
					var d = Global.objDat(token.data)
					jahr = d.year
					// System.out.println(jahr)
					if (messe == 0) {
						messedatum = d
						messe = 1
					}
				}
				case MESSE: {
					messename = token.data
					namen.clear
				}
				case DIENST: {
					dienst = token.data;
					namen.clear
				// System.out.println(dienst)
				}
				case CRLF: {
					zeile++
					// Gottesdienst speichern
					if (messedatum !== null && messedatum.hour > 0) {
						addGd = true
					}
					addMd = true
				}
				case MDO:
					Global.machNichts
				case MIN:
					addMd = true
				case NAMENSTEIL:
					namen.add(token.data)
				case VOM:
					Global.machNichts
				case WHITESPACE:
					Global.machNichts
				case ORT:
					messeort = token.data
			// default:
			}
			if (addGd) {
				var gliste = gottesdienstRep.getGottesdienstListe(daten, null, null, null, messedatum, true)
				g = if(gliste.length > 0) gliste.get(0) else null
				if (Global.nes(messename)) {
					messename = "Hl. Messe"
				}
				if (messename.equals("Fruehmesse")) {
					messename = "Frühmesse"
				}
				if (Global.nes(messeort)) {
					messeort = "Pfarrkirche"
				}
				if (messename.equals("CAZ")) {
					messename = "Caritas-Zentrum"
				}
				if (g === null) {
					anzahl++
					g = gottesdienstRep.iuMoGottesdienst(daten, null, null, messedatum, messename, messeort, null,
						MoStatusEnum.MANUELL.toString, null, null, null, null, null)
				} else {
					g = gottesdienstRep.iuMoGottesdienst(daten, null, g.uid, messedatum, messename, messeort, null,
						MoStatusEnum.MANUELL.toString, null, null, null, null, null)
				}
			}
			if (addMd && namen.size > 1) {
				var vorname = namen.get(0);
				for (var i = 1; i < namen.size - 1; i++) {
					vorname += " " + namen.get(i)
				}
				var name = namen.get(namen.size - 1)
				var mliste = messdienerRep.getMessdienerListe(daten, name, vorname, null)
				var md = if(mliste.length > 0) mliste.get(0) else null
				if (md === null) {
					throw new MeldungException("Messdiener " + vorname + " " + name + " nicht vorhanden.")
				}
				if (g === null) {
					throw new MeldungException("Gottesdienst nicht vorhanden.")
				}
				if (Global.nes(dienst)) {
					dienst = "Dienst"
				}
				if (dienst.endsWith(":")) {
					dienst = dienst.substring(0, dienst.length - 1)
				}
				if (Global.nes(md.dienste) || !md.dienste.contains(dienst)) {
					md.dienste = Global.anhaengen(md.dienste, ";", dienst)
					messdienerRep.iuMoMessdiener(daten, null, md.uid, md.name, md.vorname, md.von, md.bis, md.adresse1,
						md.adresse2, md.adresse3, md.email, md.email2, md.telefon, md.telefon2, md.verfuegbarkeit,
						md.dienste, md.messdienerUid, md.status, md.notiz, null, null, null, null)
				}
				var eliste = einteilungRep.getEinteilungListe(daten, g.uid, md.uid)
				var e = if(eliste.length > 0) eliste.get(0) else null
				einteilungRep.iuMoEinteilung(daten, null, if(e === null) null else e.uid, g.uid, md.uid, g.termin,
					dienst, null, null, null, null)
				namen.clear
			}
			// System.out.println(token)
			if (zeile > 12) {
				Global.machNichts
			// break;
			}
		}
		var r = new ServiceErgebnis<String>(
			Global.format("Es wurde(n) {0} Gottesdienste importiert.", Global.intStr(anzahl)))
		return r
	}
}

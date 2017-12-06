package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.TbEintrag
import de.cwkuehl.jhh6.api.dto.TbEintragKey
import de.cwkuehl.jhh6.api.dto.TbEintragUpdate
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.impl.TbEintragRep
import java.time.LocalDate
import java.util.ArrayList
import java.util.List
import java.util.regex.Pattern

@Service
class TagebuchService {

	// @ServiceRef TestService testService
	@RepositoryRef TbEintragRep tagebuchRep

	/**
	 * Lesen eines Tagebuch-Eintrages zu einem Datum.
	 * 
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param datum Datum des Eintrages.
	 * @return Eintrag als String.
	 */
	@Transaction(false)
	override ServiceErgebnis<TbEintrag> getEintrag(ServiceDaten daten, LocalDate datum) {

		// getBerechService().pruefeBerechtigungAdmin(daten, mandantNr);
		var r = new ServiceErgebnis<TbEintrag>(null)
		if (datum === null) {
			return r
		}
		var key = new TbEintragKey(daten.mandantNr, datum)
		var tb = tagebuchRep.get(daten, key)
		if (tb !== null) {
			r.ergebnis = tb
		}
		return r
	}

	/**
	 * Speichern eines Eintrags in der Datenbank.
	 * 
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param datum Eintragsdatum.
	 * @param strText Eintragstext.
	 */
	@Transaction
	override ServiceErgebnis<Void> speichereEintrag(ServiceDaten daten, LocalDate datum, String strText) {

		var r = new ServiceErgebnis<Void>(null)
		if (datum === null) {
			return r
		}

		// getBerechService().pruefeBerechtigungAdmin(daten, mandantNr);
		var tbEintragKey = new TbEintragKey(daten.mandantNr, datum);
		var TbEintragUpdate tbEintragU = null;
		var strEintrag = strText;

		if (!Global.nes(strEintrag)) {
			strEintrag = strEintrag.trim
		}
		var leer = Global.nes(strEintrag)
		var tbEintrag = tagebuchRep.get(daten, tbEintragKey)
		if (tbEintrag === null) {
			if (!leer) {
				tbEintrag = new TbEintrag()
				if (tbEintrag.getReplikationUid() === null) {
					tbEintrag.setReplikationUid(Global.getUID())
				}
				tbEintrag.setMandantNr(daten.mandantNr)
				tbEintrag.setDatum(datum)
				tbEintrag.setEintrag(strEintrag)
				tagebuchRep.insert(daten, tbEintrag)
			}
		} else if (!leer) {
			if (!strEintrag.equals(tbEintrag.getEintrag())) {
				tbEintragU = new TbEintragUpdate(tbEintrag)
				if (tbEintragU.getReplikationUid() === null) {
					tbEintragU.setReplikationUid(Global.getUID())
				}
				tbEintragU.setEintrag(strEintrag)
				tagebuchRep.update(daten, tbEintragU)
			}
		} else {
			// leeren Eintrag löschen
			tagebuchRep.delete(daten, tbEintragKey)
		}
		return r
	}

	/**
	 * Suche des nächsten passenden Eintrags in der Suchrichtung.
	 * 
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param stelle Such-Richtung.
	 * @param aktDatum Aufsetzpunkt der Suche.
	 * @param strSuche Such-String, evtl. mit Platzhalter, z.B. %B_den% findet
	 *            Baden und Boden.
	 * @return Datum des passenden Eintrags.
	 */
	@Transaction
	override ServiceErgebnis<LocalDate> holeSucheDatum(ServiceDaten daten, int stelle, LocalDate aktDatum,
		String[] suche) {

		var r = new ServiceErgebnis<LocalDate>(null)
		if (aktDatum === null) {
			return r
		}

		// getBerechService().pruefeBerechtigungAdmin(daten, mandantNr);
		pruefeSuche(suche)
		var LocalDate datum = tagebuchRep.sucheDatum(daten, stelle, aktDatum, suche)
		if (datum !== null && stelle == Constant.TB_ENDE && suche.get(0).equals("%")) {
			datum = datum.plusDays(1)
		}
		r.ergebnis = datum
		return r
	}

	def private void pruefeSuche(String[] suche) {

		if (Global.arrayLaenge(suche) != 9) {
			// Der Parameter %1$s ist ungültig.
			throw new MeldungException(Meldungen.M1007("suche"))
		}

		var str = suche.get(0);
		if (str === null || str.equals("%%")) {
			str = "%"
		}
		suche.set(0, str)
		for (i : 1 .. 8) {
			str = suche.get(i)
			if (str === null || str.equals("%") || str.equals("%%")) {
				str = ""
			}
			suche.set(i, str)
		}
		if (suche.get(3) == "" && suche.get(4) != "") {
			suche.set(3, suche.get(4))
		}
		if (suche.get(3) == "" && suche.get(5) != "") {
			suche.set(3, suche.get(5))
		}
		if (suche.get(6) == "" && suche.get(7) != "") {
			suche.set(6, suche.get(7))
		}
		if (suche.get(6) == "" && suche.get(8) != "") {
			suche.set(6, suche.get(8))
		}
	}

	/**
	 * Erzeugung einer Datei, die alle Einträge einer Person enthält, die einem
	 * Such-String entsprechen.
	 * 
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param strSuche Such-String, evtl. mit Platzhalter, z.B. %B_den% findet
	 *            Baden und Boden. Bei der Suche kann auch ein Zähler geprüft
	 *            werden, z.B. %####. BGS: %
	 * @return String-Array, das in einer Datei gespeichert werden kann.
	 */
	@Transaction(false)
	override ServiceErgebnis<List<String>> holeDatei(ServiceDaten daten, String[] suche) {

		// getBerechService().pruefeBerechtigungAdmin(daten, mandantNr);
		pruefeSuche(suche)

		var v = new ArrayList<String>
		var r = new ServiceErgebnis<List<String>>(v)
		var rf = false // Reihenfolge-Test
		var str = suche.get(0)
		var muster = ""
		if (Global.nes(str)) {
			str = ""
		} else {
			if (str.indexOf("####") >= 0) {
				muster = str.replaceAll("####", "\\\\D*(\\\\d+)")
				if (muster.startsWith("%")) {
					muster = muster.substring(1)
				}
				if (muster.endsWith("%")) {
					muster = muster.substring(0, muster.length() - 1)
				}
				str = str.replaceAll("####", "")
				rf = true
			}
		}
		suche.set(0, str)

		// Bericht vom: %1$s
		v.add(Meldungen.M1008(daten.jetzt, Constant.CRLF))
		// Suche nach: ('%1$s' oder '%2$s' oder '%3$s') und ('%4$s' oder '%5$s'
		// oder '%6$s') und nicht ('%7$s' oder '%8$s' oder '%9$s')%10$s
		v.add(
			Meldungen.M1009(suche.get(0), suche.get(1), suche.get(2), suche.get(3), suche.get(4), suche.get(5),
				suche.get(6), suche.get(7), suche.get(8), Constant.CRLF))
		v.add(Constant.CRLF);
		var liste = tagebuchRep.erzeugeDatei(daten, suche);
		for (e : liste) {
			v.add(
				Global.dateString(e.datum) + " " + e.eintrag + Constant.CRLF
			)
		}
		if (rf) {
			var long z = -1
			var p = Pattern.compile(muster)
			for (e : liste) {
				str = e.eintrag
				if (!Global.nes(str)) {
					var m = p.matcher(str)
					if (m.find()) {
						var l = Global.strLng(m.group(1))
						if (z < 0) {
							z = l
						} else {
							if (z != l) {
								// Falscher Zähler am %1$s: %2$s, erwartet: %3$s
								throw new MeldungException(
									Meldungen.M1010(e.datum.atTime(0, 0), m.group(1), Global.lngStr(z)))
							}
						}
						z++;
					}
				}
			}
		}

		return r
	}
}

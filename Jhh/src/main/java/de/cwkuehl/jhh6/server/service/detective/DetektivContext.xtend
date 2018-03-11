package de.cwkuehl.jhh6.server.service.detective

import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.detective.Ergebnis
import de.cwkuehl.jhh6.api.service.detective.Kategorie
import de.cwkuehl.jhh6.api.service.detective.Runde
import de.cwkuehl.jhh6.api.service.detective.Statistik
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.BaseController.TableViewData
import de.cwkuehl.jhh6.server.FactoryService
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.io.Serializable
import java.util.ArrayList
import java.util.Base64
import java.util.Collections
import java.util.HashMap
import java.util.Iterator
import java.util.LinkedHashMap
import java.util.List
import java.util.Map.Entry
import java.util.Vector
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty

class DetektivContext implements Serializable {

	static final String SCHLUESSEL = "SO_DETEKTIV"
	static final String KAT_VERDAECHTIGER = "V"
	static final String KAT_WERKZEUG = "W"
	static final String KAT_RAUM = "R"
	/** 
	 * Spieler 
	 */
	LinkedHashMap<String, Kategorie> spieler = null
	/** 
	 * Runden 
	 */
	LinkedHashMap<String, Runde> runden = null
	/** 
	 * Ergebnisse 
	 */
	transient LinkedHashMap<String, Ergebnis> ergebnisse = null
	/** 
	 * Kategorie 1: Verdächtige 
	 */
	LinkedHashMap<String, Kategorie> verdaechtige = null
	/** 
	 * Kategorie 2: Tatwerkzeuge 
	 */
	LinkedHashMap<String, Kategorie> werkzeuge = null
	/** 
	 * Kategorie 3: Räume 
	 */
	LinkedHashMap<String, Kategorie> raeume = null

	new() { // initCluedo
	}

	def private void initCluedo() {

		var Kategorie k = null
		if (spieler === null) {
			// Spieler
			spieler = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global::UID, "Benjamin", "B")
			spieler.put(k.id, k)
			k = new Kategorie(Global::UID, "Claudia", "C")
			spieler.put(k.id, k)
			k = new Kategorie(Global::UID, "Deborah", "D")
			spieler.put(k.id, k)
			k = new Kategorie(Global::UID, "Viktoria", "V")
			spieler.put(k.id, k)
			k = new Kategorie(Global::UID, "Wolfgang", "W")
			spieler.put(k.id, k)
		} else {
			k = getNr(spieler, 1) // if (k != null && "C".equals(k.kurz)) {
			// spieler.remove(k.id)
			// }
		}
		if (verdaechtige === null) {
			// Verdächtige
			verdaechtige = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global::UID, "Prof. Bloom", "Blo")
			verdaechtige.put(k.id, k)
			k = new Kategorie(Global::UID, "Baronin von Porz", "Por")
			verdaechtige.put(k.id, k)
			k = new Kategorie(Global::UID, "Frl. Ming", "Min")
			verdaechtige.put(k.id, k)
			k = new Kategorie(Global::UID, "Frau Weiß", "Wei")
			verdaechtige.put(k.id, k)
			k = new Kategorie(Global::UID, "Oberst von Gatow", "Gat")
			verdaechtige.put(k.id, k)
			k = new Kategorie(Global::UID, "Herr Dir. Grün", "Grü")
			verdaechtige.put(k.id, k)
		}
		if (werkzeuge === null) {
			// Werkzeuge
			werkzeuge = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global::UID, "Heizungsrohr", "H")
			werkzeuge.put(k.id, k)
			k = new Kategorie(Global::UID, "Leuchter", "L")
			werkzeuge.put(k.id, k)
			k = new Kategorie(Global::UID, "Pistole", "P")
			werkzeuge.put(k.id, k)
			k = new Kategorie(Global::UID, "Seil", "S")
			werkzeuge.put(k.id, k)
			k = new Kategorie(Global::UID, "Dolch", "D")
			werkzeuge.put(k.id, k)
			k = new Kategorie(Global::UID, "Rohrzange", "R")
			werkzeuge.put(k.id, k)
		}
		if (raeume === null) {
			// Räume
			raeume = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global::UID, "Küche", "Kü")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Bibliothek", "Bi")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Salon", "Sa")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Speisezimmer", "Sp")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Billardzimmer", "Bd")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Eingangshalle", "Ei")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Veranda", "Ve")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Arbeitszimmer", "Ar")
			raeume.put(k.id, k)
			k = new Kategorie(Global::UID, "Musikzimmer", "Mu")
			raeume.put(k.id, k)
		}
		if (runden === null) {
			// Runden
			var Runde r = null
			runden = new LinkedHashMap<String, Runde>
			r = new Runde(Global::UID, getNr(spieler, spieler.size - 1).id, toList(getNr(verdaechtige, 3).id), true,
				toList(getNr(werkzeuge, 0).id, getNr(werkzeuge, 2).id), true, toList(getNr(raeume, 6).id), true, toList,
				getNr(spieler, 4).id)
			runden.put(r.id, r)
		}
	}

	def static List<String> toList(String... strings) {

		var liste = new Vector<String>
		if (Global.arrayLaenge(strings) > 0) {
			for (String s : strings) {
				liste.add(s)
			}
		}
		return liste
	}

	def private Kategorie getNr(LinkedHashMap<String, Kategorie> hm, int fnr) {

		var nr = fnr
		var Kategorie k = null
		if (hm !== null) {
			var Iterator<String> it = hm.keySet.iterator
			var String key
			while (it.hasNext && nr >= 0) {
				key = it.next
				if (nr === 0) {
					k = hm.get(key)
				}
				nr--
			}
		}
		if (k === null) {
			k = new Kategorie("unb.", "unb.", "unb.")
		}
		return k
	}

	def private List<MaParameter> toList(LinkedHashMap<String, Kategorie> hm) {

		var liste = new Vector<MaParameter>
		var MaParameter p
		var sb = new StringBuffer
		for (Entry<String, Kategorie> e : hm.entrySet) {
			p = new MaParameter
			p.setSchluessel(e.key)
			sb.setLength(0)
			sb.append(e.value.wert)
			Global.anhaengen(sb, " (", e.value.kurz, ")")
			p.setWert(sb.toString)
			liste.add(p)
		}
		return liste
	}

	def private String toString(LinkedHashMap<String, Kategorie> hm, List<String> liste) {

		var sb = new StringBuffer
		if (hm !== null && liste !== null) {
			var Kategorie k = null
			for (String id : liste) {
				k = hm.get(id)
				if (k !== null) {
					Global.anhaengen(sb, " ", k.kurz)
				}
			}
		}
		return sb.toString
	}

	def private String toString(LinkedHashMap<String, Kategorie> hm, HashMap<String, Integer> liste) {

		var sb = new StringBuffer
		if (hm !== null && liste !== null) {
			var Kategorie k = null
			for (String id : liste.keySet) {
				k = hm.get(id)
				if (k !== null) {
					Global.anhaengen(sb, " ", k.kurz)
					var Integer i = liste.get(id)
					if (i !== null && i > 1) {
						Global.anhaengen(sb, "", i.toString)
					}
				}
			}
		}
		return sb.toString
	}

	/** 
	 * Daten für Tabelle Runden.
	 */
	static class RundenData extends BaseController.TableViewData<Runde> {

		public SimpleStringProperty uid
		public SimpleStringProperty spieler
		public SimpleStringProperty verdaechtige
		public SimpleObjectProperty<Boolean> besitzv
		public SimpleStringProperty werkzeuge
		public SimpleObjectProperty<Boolean> besitzw
		public SimpleStringProperty raeume
		public SimpleObjectProperty<Boolean> besitzr
		public SimpleStringProperty spielerohne
		public SimpleStringProperty spielermit

		new(DetektivContext c, Runde v) {

			super(v)
			uid = new SimpleStringProperty(v.id)
			spieler = new SimpleStringProperty(if (c.spieler.get(v.spieler) === null)
				'''Fehler: «v.spieler»'''
			else
				c.spieler.get(v.spieler).kurz)
			verdaechtige = new SimpleStringProperty(c.toString(c.verdaechtige, v.verdaechtige))
			besitzv = new SimpleObjectProperty<Boolean>(v.isBesitzv)
			werkzeuge = new SimpleStringProperty(c.toString(c.werkzeuge, v.werkzeuge))
			besitzw = new SimpleObjectProperty<Boolean>(v.isBesitzw)
			raeume = new SimpleStringProperty(c.toString(c.raeume, v.raeume))
			besitzr = new SimpleObjectProperty<Boolean>(v.isBesitzr)
			spielerohne = new SimpleStringProperty(c.toString(c.spieler, v.spielerOhne))
			spielermit = new SimpleStringProperty(
				if(c.spieler.get(v.spielerMit) === null) null else c.spieler.get(v.spielerMit).kurz)
		}

		override String getId() {
			return getData.id
		}
	}

	/** 
	 * Daten für Tabelle Ergebnisse.
	 */
	static class ErgebnisseData extends TableViewData<Ergebnis> {

		public SimpleStringProperty uid
		public SimpleStringProperty kategorie
		public SimpleStringProperty kurz
		public SimpleStringProperty spieler
		public SimpleStringProperty ohne
		public SimpleStringProperty moeglich
		public SimpleStringProperty frage
		public SimpleObjectProperty<Double> wahrscheinlich

		new(DetektivContext c, Ergebnis v) {

			super(v)
			uid = new SimpleStringProperty(v.id)
			kategorie = new SimpleStringProperty(v.kategorie)
			kurz = new SimpleStringProperty(v.kurz)
			spieler = new SimpleStringProperty(
				if(c.spieler.get(v.spieler) === null) null else c.spieler.get(v.spieler).kurz)
			ohne = new SimpleStringProperty(if (v.spielerOhne === null)
				null
			else
				c.toString(c.spieler, new ArrayList<String>(v.spielerOhne)))
			moeglich = new SimpleStringProperty(if (v.spielerWahr === null)
				null
			else
				c.toString(c.spieler, new ArrayList<String>(v.spielerWahr)))
			frage = new SimpleStringProperty(
				if(v.spielerFrage === null) null else c.toString(c.spieler, v.spielerFrage))
			wahrscheinlich = new SimpleObjectProperty(v.wahrscheinlichkeit)
		}

		override String getId() {
			return getData.id
		}
	}

	def List<MaParameter> getSpieler() {
		return toList(spieler)
	}

	def List<MaParameter> getWerkzeuge() {
		return toList(werkzeuge)
	}

	def List<MaParameter> getVerdaechtige() {
		return toList(verdaechtige)
	}

	def List<MaParameter> getRaeume() {
		return toList(raeume)
	}

	def List<Runde> getRunden() {
		var liste = new ArrayList<Runde>
		for (Runde r : runden.values) {
			liste.add(r)
		}
		return liste
	}

	def List<Ergebnis> getErgebnisse() {

		berechneErgebnisse(false)
		var liste = new ArrayList<Ergebnis>
		for (Ergebnis e : ergebnisse.values) {
			liste.add(e)
		}
		Collections.sort(liste, [ Ergebnis o1, Ergebnis o2 |
			return Global.compDouble(o2.wahrscheinlichkeit, o1.wahrscheinlichkeit)
		])
		return liste
	}

	def private void berechneErgebnisse(boolean widerspruch) {

		ergebnisse = new LinkedHashMap<String, Ergebnis>
		var Ergebnis e = null
		var anzahl = spieler.size
		var w = 0.0
		// Ergebnisse aus allen Kategorien
		w = 100.0 / verdaechtige.size
		for (Kategorie k : verdaechtige.values) {
			e = new Ergebnis(k.id, KAT_VERDAECHTIGER, k.kurz, null, null, null, null, w)
			ergebnisse.put(e.id, e)
		}
		w = 100.0 / werkzeuge.size
		for (Kategorie k : werkzeuge.values) {
			e = new Ergebnis(k.id, KAT_WERKZEUG, k.kurz, null, null, null, null, w)
			ergebnisse.put(e.id, e)
		}
		w = 100.0 / raeume.size
		for (Kategorie k : raeume.values) {
			e = new Ergebnis(k.id, KAT_RAUM, k.kurz, null, null, null, null, w)
			ergebnisse.put(e.id, e)
		}
		// Auswertung der Runde
		for (Runde r : runden.values) {
			// Fragen merken
			if (!Global.nes(r.spieler) && !r.spieler.equals(r.spielerMit)) {
				// nicht beim eigenen Stand
				for (String s : r.verdaechtige) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.spieler)
					}
				}
				for (String s : r.werkzeuge) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.spieler)
					}
				}
				for (String s : r.raeume) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.spieler)
					}
				}
			}
			// Besitz auswerten
			if (!Global.nes(r.spielerMit)) {
				if (r.isBesitzv && r.verdaechtige !== null) {
					for (String s : r.verdaechtige) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.spieler)) {
								e.setSpieler(r.spielerMit)
							} else if (widerspruch && !e.spieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon den Verdächtigen.")
							}
						}
					}
				}
				if (r.isBesitzw && r.werkzeuge !== null) {
					for (String s : r.werkzeuge) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.spieler)) {
								e.setSpieler(r.spielerMit)
							} else if (widerspruch && !e.spieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon das Tatwerkzeug.")
							}
						}
					}
				}
				if (r.isBesitzr && r.raeume !== null) {
					for (String s : r.raeume) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.spieler)) {
								e.setSpieler(r.spielerMit)
							} else if (widerspruch && !e.spieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon den Raum.")
							}
						}
					}
				}
			}
			// Nicht-Besitz auswerten
			if (Global.listLaenge(r.spielerOhne) > 0) {
				for (String s : r.spielerOhne) {
					for (String v : r.verdaechtige) {
						e = ergebnisse.get(v)
						if (e !== null) {
							e.addSpielerOhne(s)
						}
					}
					for (String v : r.werkzeuge) {
						e = ergebnisse.get(v)
						if (e !== null) {
							e.addSpielerOhne(s)
						}
					}
					for (String v : r.raeume) {
						e = ergebnisse.get(v)
						if (e !== null) {
							e.addSpielerOhne(s)
						}
					}
				}
			}
		}
		// Möglichkeiten berechnen
		for (Runde r : runden.values) {
			if (!Global.nes(r.spielerMit) && !r.isBesitzv && !r.isBesitzw && !r.isBesitzr) {
				var sliste = new Vector<String>
				for (String s : r.verdaechtige) {
					sliste.add(s)
				}
				for (String s : r.werkzeuge) {
					sliste.add(s)
				}
				for (String s : r.raeume) {
					sliste.add(s)
				}
				var keiner = true
				for (String s : sliste) {
					var Ergebnis er = ergebnisse.get(s)
					if (er !== null) {
						if (r.spielerMit.equals(er.spieler)) {
							keiner = false
						}
					}
				}
				if (keiner) {
					for (String s : sliste) {
						var Ergebnis er = ergebnisse.get(s)
						if (er !== null) {
							er.addSpielerWahr(r.spielerMit)
						}
					}
				}
			}
		}
		// Wahrscheinlichkeiten berechnen
		var katw = new HashMap<String, Statistik>
		var Statistik s = null
		katw.put(KAT_VERDAECHTIGER, new Statistik(KAT_VERDAECHTIGER))
		katw.put(KAT_WERKZEUG, new Statistik(KAT_WERKZEUG))
		katw.put(KAT_RAUM, new Statistik(KAT_RAUM))
		// Zählen
		for (Ergebnis er : ergebnisse.values) {
			s = katw.get(er.kategorie)
			s.setAnzahl(s.anzahl + 1)
			if (er.spielerOhneAnzahl >= anzahl) {
				// Lösung dieser Kategorie gefunden
				s.setGefundenId(er.id)
			}
			if (Global.nes(er.spieler)) {
				s.setAnzahl2(s.anzahl2 + 1)
				s.setAnzahlNicht(s.anzahlNicht + 1 + er.spielerOhneAnzahl + er.spielerWahrAnzahl)
			}
		}
		// Wahrscheinlichkeiten eintragen
		for (Ergebnis er : ergebnisse.values) {
			s = katw.get(er.kategorie)
			if (Global.nes(s.gefundenId)) {
				if (Global.nes(er.spieler) && s.anzahlNicht > 0) {
					er.setWahrscheinlichkeit(100.0 * (1 + er.spielerOhneAnzahl + er.spielerWahrAnzahl) / s.anzahlNicht)
				// er.setWahrscheinlichkeit(100.0 / s.anzahl2)
				} else {
					er.setWahrscheinlichkeit(0)
				}
			} else {
				if (s.gefundenId.equals(er.id)) {
					er.setWahrscheinlichkeit(100)
				} else {
					er.setWahrscheinlichkeit(0)
				}
			}
		}
	}

	def Runde getRunde(String id) {
		var r = runden.get(id)
		return r
	}

	def void insertRunde(Runde r) {

		if (r === null) {
			return
		}
		if (r.spieler === null) {
			throw new MeldungException("Bitte einen Spieler auswählen.")
		}
		runden.put(r.id, r)
	}

	def void updateRunde(Runde r) {

		if (r === null) {
			return;
		}
		if (r.spieler === null) {
			throw new MeldungException("Bitte einen Spieler auswählen.")
		}
		var Runde rU = runden.get(r.id)
		if (rU !== null) {
			rU.setSpieler(r.spieler)
			rU.setVerdaechtige(r.verdaechtige)
			rU.setBesitzv(r.isBesitzv)
			rU.setWerkzeuge(r.werkzeuge)
			rU.setBesitzw(r.isBesitzw)
			rU.setRaeume(r.raeume)
			rU.setBesitzr(r.isBesitzr)
			rU.setSpielerOhne(r.spielerOhne)
			rU.setSpielerMit(r.spielerMit)
		}
	}

	def void deleteRunde(String id) {

		if (Global.nes(id)) {
			runden.clear
			return;
		}
		if (runden.containsKey(id)) {
			runden.remove(id)
		}
	}

	def static DetektivContext readObject(ServiceDaten daten) {

		var DetektivContext context
		var r = FactoryService::anmeldungService.getParameterListe(daten, SCHLUESSEL)
		r.throwErstenFehler
		var pliste = r.ergebnis
		if (Global.listLaenge(pliste) > 0 && !Global.nes(pliste.get(0).wert)) {
			var s = pliste.get(0).wert
			var bytes = Base64.decoder.decode(s)
			var bs = new ByteArrayInputStream(bytes)
			try {
				var in = new ObjectInputStream(bs)
				context = in.readObject as DetektivContext
			} catch (IOException e1) {
				e1.printStackTrace
				throw new MeldungException(e1.message)
			} catch (ClassNotFoundException e1) {
				e1.printStackTrace
				throw new MeldungException(e1.message)
			}

		}
		if (context === null) {
			context = new DetektivContext
		}
		context.initCluedo
		return context
	}

	def static void writeObject(DetektivContext context, ServiceDaten daten) {

		var pliste = new ArrayList<MaParameter>
		var p = new MaParameter
		pliste.add(p)
		try {
			var bs = new ByteArrayOutputStream
			var out = new ObjectOutputStream(bs)
			out.writeObject(context)
			out.close
			bs.close
			var byte[] bytes = bs.toByteArray
			p.setSchluessel(SCHLUESSEL)
			p.setWert(Base64.encoder.encodeToString(bytes))
			var r = FactoryService::anmeldungService.updateParameterListe(daten, pliste)
			r.throwErstenFehler
		} catch (Exception e1) {
			e1.printStackTrace
			throw new MeldungException(e1.message)
		}

	}

	def void setSpieler(String sp) {

		if (Global.nes(sp)) {
			return;
		}
		var array = sp.split(", *")
		spieler = new LinkedHashMap<String, Kategorie>
		for (String s : array) {
			var Kategorie k = new Kategorie(Global::UID, s, s.substring(0, 1))
			spieler.put(k.id, k)
		}
	}
}

package de.cwkuehl.jhh6.server.service.detective

import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
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
		// spieler = null;
		if (spieler === null) {
			// Spieler
			spieler = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global.getUID, "Benjamin", "B")
			spieler.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Claudia", "C")
			spieler.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Deborah", "D")
			spieler.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Viktoria", "V")
			spieler.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Wolfgang", "W")
			spieler.put(k.getId, k)
		} else {
			k = getNr(spieler, 1) // if (k != null && "C".equals(k.getKurz)) {
			// spieler.remove(k.getId)
			// }
		}
		if (verdaechtige === null) {
			// Verdächtige
			verdaechtige = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global.getUID, "Prof. Bloom", "Blo")
			verdaechtige.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Baronin von Porz", "Por")
			verdaechtige.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Frl. Ming", "Min")
			verdaechtige.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Frau Weiß", "Wei")
			verdaechtige.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Oberst von Gatow", "Gat")
			verdaechtige.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Herr Dir. Grün", "Grü")
			verdaechtige.put(k.getId, k)
		}
		if (werkzeuge === null) {
			// Werkzeuge
			werkzeuge = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global.getUID, "Heizungsrohr", "H")
			werkzeuge.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Leuchter", "L")
			werkzeuge.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Pistole", "P")
			werkzeuge.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Seil", "S")
			werkzeuge.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Dolch", "D")
			werkzeuge.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Rohrzange", "R")
			werkzeuge.put(k.getId, k)
		}
		if (raeume === null) {
			// Räume
			raeume = new LinkedHashMap<String, Kategorie>
			k = new Kategorie(Global.getUID, "Küche", "Kü")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Bibliothek", "Bi")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Salon", "Sa")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Speisezimmer", "Sp")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Billardzimmer", "Bd")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Eingangshalle", "Ei")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Veranda", "Ve")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Arbeitszimmer", "Ar")
			raeume.put(k.getId, k)
			k = new Kategorie(Global.getUID, "Musikzimmer", "Mu")
			raeume.put(k.getId, k)
		}
		if (runden === null) {
			// Runden
			var Runde r = null
			runden = new LinkedHashMap<String, Runde>
			r = new Runde(Global.getUID, getNr(spieler, spieler.size - 1).getId,
				toList(getNr(verdaechtige, 3).getId), true,
				toList(getNr(werkzeuge, 0).getId, getNr(werkzeuge, 2).getId), true,
				toList(getNr(raeume, 6).getId), true, toList, getNr(spieler, 4).getId)
			runden.put(r.getId, r)
		}
	}

	def static List<String> toList(String... strings) {

		var List<String> liste = new Vector<String>
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
			var String key = null
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

		var Vector<MaParameter> liste = new Vector<MaParameter>
		var MaParameter p = null
		var StringBuffer sb = new StringBuffer
		for (Entry<String, Kategorie> e : hm.entrySet) {
			p = new MaParameter
			p.setSchluessel(e.getKey)
			sb.setLength(0)
			sb.append(e.getValue.getWert)
			Global.anhaengen(sb, " (", e.getValue.getKurz, ")")
			p.setWert(sb.toString)
			liste.add(p)
		}
		return liste
	}

	def private String toString(LinkedHashMap<String, Kategorie> hm, List<String> liste) {

		var StringBuffer sb = new StringBuffer
		if (hm !== null && liste !== null) {
			var Kategorie k = null
			for (String id : liste) {
				k = hm.get(id)
				if (k !== null) {
					Global.anhaengen(sb, " ", k.getKurz)
				}
			}
		}
		return sb.toString
	}

	def private String toString(LinkedHashMap<String, Kategorie> hm, HashMap<String, Integer> liste) {

		var StringBuffer sb = new StringBuffer
		if (hm !== null && liste !== null) {
			var Kategorie k = null
			for (String id : liste.keySet) {
				k = hm.get(id)
				if (k !== null) {
					Global.anhaengen(sb, " ", k.getKurz)
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
			uid = new SimpleStringProperty(v.getId)
			spieler = new SimpleStringProperty(if (c.spieler.get(v.getSpieler) === null)
				'''Fehler: «v.getSpieler»'''
			else
				c.spieler.get(v.getSpieler).getKurz)
			verdaechtige = new SimpleStringProperty(c.toString(c.verdaechtige, v.getVerdaechtige))
			besitzv = new SimpleObjectProperty<Boolean>(v.isBesitzv)
			werkzeuge = new SimpleStringProperty(c.toString(c.werkzeuge, v.getWerkzeuge))
			besitzw = new SimpleObjectProperty<Boolean>(v.isBesitzw)
			raeume = new SimpleStringProperty(c.toString(c.raeume, v.getRaeume))
			besitzr = new SimpleObjectProperty<Boolean>(v.isBesitzr)
			spielerohne = new SimpleStringProperty(c.toString(c.spieler, v.getSpielerOhne))
			spielermit = new SimpleStringProperty(
				if(c.spieler.get(v.getSpielerMit) === null) null else c.spieler.get(v.getSpielerMit).getKurz)
		}

		override String getId() {
			return getData.getId
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
			uid = new SimpleStringProperty(v.getId)
			kategorie = new SimpleStringProperty(v.getKategorie)
			kurz = new SimpleStringProperty(v.getKurz)
			spieler = new SimpleStringProperty(
				if(c.spieler.get(v.getSpieler) === null) null else c.spieler.get(v.getSpieler).getKurz)
			ohne = new SimpleStringProperty(if (v.getSpielerOhne === null)
				null
			else
				c.toString(c.spieler, new ArrayList<String>(v.getSpielerOhne)))
			moeglich = new SimpleStringProperty(if (v.getSpielerWahr === null)
				null
			else
				c.toString(c.spieler, new ArrayList<String>(v.getSpielerWahr)))
			frage = new SimpleStringProperty(
				if(v.getSpielerFrage === null) null else c.toString(c.spieler, v.getSpielerFrage))
			wahrscheinlich = new SimpleObjectProperty(v.getWahrscheinlichkeit)
		}

		override String getId() {
			return getData.getId
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
		var List<Runde> liste = new ArrayList<Runde>
		for (Runde r : runden.values) {
			liste.add(r)
		}
		return liste
	}

	def List<Ergebnis> getErgebnisse() {

		berechneErgebnisse(false)
		var List<Ergebnis> liste = new ArrayList<Ergebnis>
		for (Ergebnis e : ergebnisse.values) {
			liste.add(e)
		}
		Collections.sort(liste, [ Ergebnis o1, Ergebnis o2 |
			return Global.compDouble(o2.getWahrscheinlichkeit, o1.getWahrscheinlichkeit)
		])
		return liste
	}

	def private void berechneErgebnisse(boolean widerspruch) {

		ergebnisse = new LinkedHashMap<String, Ergebnis>
		var Ergebnis e = null
		var int anzahl = spieler.size
		var double w = 0
		// Ergebnisse aus allen Kategorien
		w = 100.0 / verdaechtige.size
		for (Kategorie k : verdaechtige.values) {
			e = new Ergebnis(k.getId, KAT_VERDAECHTIGER, k.getKurz, null, null, null, null, w)
			ergebnisse.put(e.getId, e)
		}
		w = 100.0 / werkzeuge.size
		for (Kategorie k : werkzeuge.values) {
			e = new Ergebnis(k.getId, KAT_WERKZEUG, k.getKurz, null, null, null, null, w)
			ergebnisse.put(e.getId, e)
		}
		w = 100.0 / raeume.size
		for (Kategorie k : raeume.values) {
			e = new Ergebnis(k.getId, KAT_RAUM, k.getKurz, null, null, null, null, w)
			ergebnisse.put(e.getId, e)
		}
		// Auswertung der Runde
		for (Runde r : runden.values) {
			// Fragen merken
			if (!Global.nes(r.getSpieler) && !r.getSpieler.equals(r.getSpielerMit)) {
				// nicht beim eigenen Stand
				for (String s : r.getVerdaechtige) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.getSpieler)
					}
				}
				for (String s : r.getWerkzeuge) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.getSpieler)
					}
				}
				for (String s : r.getRaeume) {
					e = ergebnisse.get(s)
					if (e !== null) {
						e.addSpielerFrage(r.getSpieler)
					}
				}
			}
			// Besitz auswerten
			if (!Global.nes(r.getSpielerMit)) {
				if (r.isBesitzv && r.getVerdaechtige !== null) {
					for (String s : r.getVerdaechtige) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.getSpieler)) {
								e.setSpieler(r.getSpielerMit)
							} else if (widerspruch && !e.getSpieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon den Verdächtigen.")
							}
						}
					}
				}
				if (r.isBesitzw && r.getWerkzeuge !== null) {
					for (String s : r.getWerkzeuge) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.getSpieler)) {
								e.setSpieler(r.getSpielerMit)
							} else if (widerspruch && !e.getSpieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon das Tatwerkzeug.")
							}
						}
					}
				}
				if (r.isBesitzr && r.getRaeume !== null) {
					for (String s : r.getRaeume) {
						e = ergebnisse.get(s)
						if (e !== null) {
							if (Global.nes(e.getSpieler)) {
								e.setSpieler(r.getSpielerMit)
							} else if (widerspruch && !e.getSpieler.equals(s)) {
								throw new MeldungException("Ein anderer Spieler hat schon den Raum.")
							}
						}
					}
				}
			}
			// Nicht-Besitz auswerten
			if (Global.listLaenge(r.getSpielerOhne) > 0) {
				for (String s : r.getSpielerOhne) {
					for (String v : r.getVerdaechtige) {
						e = ergebnisse.get(v)
						if (e !== null) {
							e.addSpielerOhne(s)
						}
					}
					for (String v : r.getWerkzeuge) {
						e = ergebnisse.get(v)
						if (e !== null) {
							e.addSpielerOhne(s)
						}
					}
					for (String v : r.getRaeume) {
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
			if (!Global.nes(r.getSpielerMit) && !r.isBesitzv && !r.isBesitzw && !r.isBesitzr) {
				var List<String> sliste = new Vector<String>
				for (String s : r.getVerdaechtige) {
					sliste.add(s)
				}
				for (String s : r.getWerkzeuge) {
					sliste.add(s)
				}
				for (String s : r.getRaeume) {
					sliste.add(s)
				}
				var boolean keiner = true
				for (String s : sliste) {
					var Ergebnis er = ergebnisse.get(s)
					if (er !== null) {
						if (r.getSpielerMit.equals(er.getSpieler)) {
							keiner = false
						}
					}
				}
				if (keiner) {
					for (String s : sliste) {
						var Ergebnis er = ergebnisse.get(s)
						if (er !== null) {
							er.addSpielerWahr(r.getSpielerMit)
						}
					}
				}
			}
		}
		// Wahrscheinlichkeiten berechnen
		var HashMap<String, Statistik> katw = new HashMap<String, Statistik>
		var Statistik s = null
		katw.put(KAT_VERDAECHTIGER, new Statistik(KAT_VERDAECHTIGER))
		katw.put(KAT_WERKZEUG, new Statistik(KAT_WERKZEUG))
		katw.put(KAT_RAUM, new Statistik(KAT_RAUM))
		// Zählen
		for (Ergebnis er : ergebnisse.values) {
			s = katw.get(er.getKategorie)
			s.setAnzahl(s.getAnzahl + 1)
			if (er.getSpielerOhneAnzahl >= anzahl) {
				// Lösung dieser Kategorie gefunden
				s.setGefundenId(er.getId)
			}
			if (Global.nes(er.getSpieler)) {
				s.setAnzahl2(s.getAnzahl2 + 1)
				s.setAnzahlNicht(s.getAnzahlNicht + 1 + er.getSpielerOhneAnzahl + er.getSpielerWahrAnzahl)
			}
		}
		// Wahrscheinlichkeiten eintragen
		for (Ergebnis er : ergebnisse.values) {
			s = katw.get(er.getKategorie)
			if (Global.nes(s.getGefundenId)) {
				if (Global.nes(er.getSpieler) && s.getAnzahlNicht > 0) {
					er.setWahrscheinlichkeit(100.0 * (1 + er.getSpielerOhneAnzahl + er.getSpielerWahrAnzahl) /
						s.getAnzahlNicht)
				// er.setWahrscheinlichkeit(100.0 / s.getAnzahl2);
				} else {
					er.setWahrscheinlichkeit(0)
				}
			} else {
				if (s.getGefundenId.equals(er.getId)) {
					er.setWahrscheinlichkeit(100)
				} else {
					er.setWahrscheinlichkeit(0)
				}
			}
		}
	}

	def Runde getRunde(String id) {
		var Runde r = runden.get(id)
		return r
	}

	def void insertRunde(Runde r) {
		if (r === null) {
			return;
		}
		if (r.getSpieler === null) {
			throw new MeldungException("Bitte einen Spieler auswählen.")
		}
		runden.put(r.getId, r)
	}

	def void updateRunde(Runde r) {

		if (r === null) {
			return;
		}
		if (r.getSpieler === null) {
			throw new MeldungException("Bitte einen Spieler auswählen.")
		}
		var Runde rU = runden.get(r.getId)
		if (rU !== null) {
			rU.setSpieler(r.getSpieler)
			rU.setVerdaechtige(r.getVerdaechtige)
			rU.setBesitzv(r.isBesitzv)
			rU.setWerkzeuge(r.getWerkzeuge)
			rU.setBesitzw(r.isBesitzw)
			rU.setRaeume(r.getRaeume)
			rU.setBesitzr(r.isBesitzr)
			rU.setSpielerOhne(r.getSpielerOhne)
			rU.setSpielerMit(r.getSpielerMit)
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

		var DetektivContext context = null
		var ServiceErgebnis<List<MaParameter>> r = FactoryService.getAnmeldungService.getParameterListe(daten,
			SCHLUESSEL)
		r.throwErstenFehler
		var List<MaParameter> pliste = r.getErgebnis
		if (Global.listLaenge(pliste) > 0 && !Global.nes(pliste.get(0).getWert)) {
			var String s = pliste.get(0).getWert
			var byte[] bytes = Base64.getDecoder.decode(s)
			var ByteArrayInputStream bs = new ByteArrayInputStream(bytes)
			try {
				var ObjectInputStream in = new ObjectInputStream(bs)
				context = in.readObject as DetektivContext
			} catch (IOException e1) {
				e1.printStackTrace
				throw new MeldungException(e1.getMessage)
			} catch (ClassNotFoundException e1) {
				e1.printStackTrace
				throw new MeldungException(e1.getMessage)
			}

		}
		if (context === null) {
			context = new DetektivContext
		}
		context.initCluedo
		return context
	}

	def static void writeObject(DetektivContext context, ServiceDaten daten) {

		var List<MaParameter> pliste = new ArrayList<MaParameter>
		var MaParameter p = new MaParameter
		pliste.add(p)
		try {
			var ByteArrayOutputStream bs = new ByteArrayOutputStream
			var ObjectOutputStream out = new ObjectOutputStream(bs)
			out.writeObject(context)
			out.close
			bs.close
			var byte[] bytes = bs.toByteArray
			p.setSchluessel(SCHLUESSEL)
			p.setWert(Base64.getEncoder.encodeToString(bytes))
			var ServiceErgebnis<Void> r = FactoryService.getAnmeldungService.updateParameterListe(daten, pliste)
			r.throwErstenFehler
		} catch (Exception e1) {
			e1.printStackTrace
			throw new MeldungException(e1.getMessage)
		}

	}

	def void setSpieler(String sp) {

		if (Global.nes(sp)) {
			return;
		}
		var String[] array = sp.split(", *")
		spieler = new LinkedHashMap<String, Kategorie>
		for (String s : array) {
			var Kategorie k = new Kategorie(Global.getUID, s, s.substring(0, 1))
			spieler.put(k.getId, k)
		}
	}
}

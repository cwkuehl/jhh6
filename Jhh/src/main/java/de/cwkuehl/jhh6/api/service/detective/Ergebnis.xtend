package de.cwkuehl.jhh6.api.service.detective

import java.io.Serializable
import java.util.HashMap
import java.util.HashSet

class Ergebnis implements Serializable {

	String id = null
	String kategorie = null
	String kurz = null
	String spieler = null
	HashSet<String> spielerOhne = null
	HashSet<String> spielerWahr = null
	HashMap<String, Integer> spielerFrage = null
	double wahrscheinlichkeit = 1

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param id ID.
	 * @param kategorie Kategorie.
	 * @param kurz Kurzer Wert.
	 * @param spieler Spieler, der diese Karte besitzt.
	 * @param spielerOhne Spieler, die diese Karte nicht besitzen.
	 * @param spielerWahr Spieler, die diese Karte besitzen können.
	 * @param spielerFrage Spieler, die nach dieser Karte gefragt haben.
	 * @param wahrscheinlichkeit Wahrscheinlichkeit, dass diese Karte kein Spieler besitzt.
	 */
	new(String id, String kategorie, String kurz, String spieler, HashSet<String> spielerOhne,
		HashSet<String> spielerWahr, HashMap<String, Integer> spielerFrage, double wahrscheinlichkeit) {
		super()
		setId(id)
		setKategorie(kategorie)
		setKurz(kurz)
		setSpieler(spieler)
		setSpielerOhne(spielerOhne)
		setSpielerWahr(spielerWahr)
		setSpielerFrage(spielerFrage)
		setWahrscheinlichkeit(wahrscheinlichkeit)
	}

	def void addSpielerOhne(String s) {
		if (spielerOhne === null) {
			spielerOhne = new HashSet<String>()
		}
		spielerOhne.add(s)
	}

	def int getSpielerOhneAnzahl() {
		if (spielerOhne === null) {
			return 0
		}
		return spielerOhne.size()
	}

	def void addSpielerWahr(String s) {
		if (spielerWahr === null) {
			spielerWahr = new HashSet<String>()
		}
		spielerWahr.add(s)
	}

	def int getSpielerWahrAnzahl() {
		if (spielerWahr === null) {
			return 0
		}
		return spielerWahr.size()
	}

	def void addSpielerFrage(String s) {
		if (spielerFrage === null) {
			spielerFrage = new HashMap<String, Integer>()
		}
		var Integer i = spielerFrage.get(s)
		if (i === null) {
			spielerFrage.put(s, 1)
		} else {
			spielerFrage.put(s, i + 1)
		}
	}

	def String getId() {
		return id
	}

	def void setId(String id) {
		this.id = id
	}

	def String getKategorie() {
		return kategorie
	}

	def void setKategorie(String kategorie) {
		this.kategorie = kategorie
	}

	def String getSpieler() {
		return spieler
	}

	def void setSpieler(String spieler) {
		this.spieler = spieler
	}

	def String getKurz() {
		return kurz
	}

	def void setKurz(String kurz) {
		this.kurz = kurz
	}

	def HashSet<String> getSpielerOhne() {
		return spielerOhne
	}

	def void setSpielerOhne(HashSet<String> spielerOhne) {
		this.spielerOhne = spielerOhne
	}

	def double getWahrscheinlichkeit() {
		return wahrscheinlichkeit
	}

	def void setWahrscheinlichkeit(double wahrscheinlichkeit) {
		this.wahrscheinlichkeit = wahrscheinlichkeit
	}

	def HashSet<String> getSpielerWahr() {
		return spielerWahr
	}

	def void setSpielerWahr(HashSet<String> spielerWahr) {
		this.spielerWahr = spielerWahr
	}

	def HashMap<String, Integer> getSpielerFrage() {
		return spielerFrage
	}

	def void setSpielerFrage(HashMap<String, Integer> spielerFrage) {
		this.spielerFrage = spielerFrage
	}
}

package de.cwkuehl.jhh6.api.service.detective

import java.io.Serializable

class Kategorie implements Serializable {

	String id = null
	String wert = null
	String kurz = null

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param id ID.
	 * @param wert Wert.
	 * @param kurz Kurzer Wert.
	 */
	new(String id, String wert, String kurz) {
		super()
		this.id = id
		this.wert = wert
		this.kurz = kurz
	}

	def String getId() {
		return id
	}

	def void setId(String id) {
		this.id = id
	}

	def String getWert() {
		return wert
	}

	def void setWert(String wert) {
		this.wert = wert
	}

	def String getKurz() {
		return kurz
	}

	def void setKurz(String kurz) {
		this.kurz = kurz
	}
}

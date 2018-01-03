package de.cwkuehl.jhh6.api.service.detective

import java.io.Serializable

class Statistik implements Serializable {

	String id = null
	int anzahl = 0
	int anzahl2 = 0
	int anzahlNicht = 0
	String gefundenId = null

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param id ID.
	 */
	new(String id) {
		super()
		this.id = id
	}

	def String getId() {
		return id
	}

	def void setId(String id) {
		this.id = id
	}

	def int getAnzahl() {
		return anzahl
	}

	def void setAnzahl(int anzahl) {
		this.anzahl = anzahl
	}

	def int getAnzahl2() {
		return anzahl2
	}

	def void setAnzahl2(int anzahl2) {
		this.anzahl2 = anzahl2
	}

	def int getAnzahlNicht() {
		return anzahlNicht
	}

	def void setAnzahlNicht(int anzahlNicht) {
		this.anzahlNicht = anzahlNicht
	}

	def String getGefundenId() {
		return gefundenId
	}

	def void setGefundenId(String gefundenId) {
		this.gefundenId = gefundenId
	}
}

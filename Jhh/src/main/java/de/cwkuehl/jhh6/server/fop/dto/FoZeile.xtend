package de.cwkuehl.jhh6.server.fop.dto

import de.cwkuehl.jhh6.api.dto.VmAbrechnungLang

class FoZeile {

	String beschreibung = null
	String wert = null
	double betrag = 0
	String status = null
	String reihenfolge = null

	new() {
	}

	new(VmAbrechnungLang a) {
		beschreibung = a.getBeschreibung()
		wert = a.getWert()
		betrag = a.getBetrag()
		status = a.getStatus()
		reihenfolge = a.getReihenfolge()
	}

	def String getBeschreibung() {
		return beschreibung
	}

	def void setBeschreibung(String beschreibung) {
		this.beschreibung = beschreibung
	}

	def double getBetrag() {
		return betrag
	}

	def void setBetrag(double betrag) {
		this.betrag = betrag
	}

	def String getStatus() {
		return status
	}

	def void setStatus(String status) {
		this.status = status
	}

	def String getReihenfolge() {
		return reihenfolge
	}

	def void setReihenfolge(String reihenfolge) {
		this.reihenfolge = reihenfolge
	}

	def String getWert() {
		return wert
	}

	def void setWert(String wert) {
		this.wert = wert
	}
}

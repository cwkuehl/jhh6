package de.cwkuehl.jhh6.server.fop.dto

import java.util.ArrayList
import java.util.List

class FoWohnung {

	String uid = null
	String bezeichnung = null
	List<FoMieter> mieter = new ArrayList<FoMieter>()
	double qm = 0

	def List<FoMieter> getMieter() {
		return mieter
	}

	def double getQm() {
		return qm
	}

	def void setQm(double qm) {
		this.qm = qm
	}

	def String getUid() {
		return uid
	}

	def void setUid(String uid) {
		this.uid = uid
	}

	def String getBezeichnung() {
		return bezeichnung
	}

	def void setBezeichnung(String bezeichnung) {
		this.bezeichnung = bezeichnung
	}
}

package de.cwkuehl.jhh6.server.fop.dto

import java.time.LocalDate

class FoMieter {

	String uid = null
	boolean drucken = false
	LocalDate von = null
	LocalDate bis = null
	String anrede = null
	String name = null
	String strasse = null
	String ort = null
	double personenmonate = 0
	double personenmonat2 = 0
	int monate = 0
	double bkvoraus = 0
	double hkvoraus = 0
	double hkabrechnung = 0
	double qm = 0
	double grundmiete = 0
	double kaution = 0
	double antenne = 0
	double garten = 0

	def double getPersonenmonate() {
		return personenmonate
	}

	def void setPersonenmonate(double personenmonate) {
		this.personenmonate = personenmonate
	}

	def double getPersonenmonat2() {
		return personenmonat2
	}

	def void setPersonenmonat2(double personenmonat2) {
		this.personenmonat2 = personenmonat2
	}

	def LocalDate getVon() {
		return von
	}

	def void setVon(LocalDate von) {
		this.von = von
	}

	def LocalDate getBis() {
		return bis
	}

	def void setBis(LocalDate bis) {
		this.bis = bis
	}

	def boolean isDrucken() {
		return drucken
	}

	def void setDrucken(boolean drucken) {
		this.drucken = drucken
	}

	def String getStrasse() {
		return strasse
	}

	def void setStrasse(String strasse) {
		this.strasse = strasse
	}

	def String getOrt() {
		return ort
	}

	def void setOrt(String ort) {
		this.ort = ort
	}

	def String getUid() {
		return uid
	}

	def void setUid(String uid) {
		this.uid = uid
	}

	def String getAnrede() {
		return anrede
	}

	def void setAnrede(String anrede) {
		this.anrede = anrede
	}

	def String getName() {
		return name
	}

	def void setName(String name) {
		this.name = name
	}

	def int getMonate() {
		return monate
	}

	def void setMonate(int monate) {
		this.monate = monate
	}

	def double getAntenne() {
		return antenne
	}

	def void setAntenne(double antenne) {
		this.antenne = antenne
	}

	def double getGarten() {
		return garten
	}

	def void setGarten(double garten) {
		this.garten = garten
	}

	def double getBkvoraus() {
		return bkvoraus
	}

	def void setBkvoraus(double bkvoraus) {
		this.bkvoraus = bkvoraus
	}

	def double getHkvoraus() {
		return hkvoraus
	}

	def void setHkvoraus(double hkvoraus) {
		this.hkvoraus = hkvoraus
	}

	def double getHkabrechnung() {
		return hkabrechnung
	}

	def void setHkabrechnung(double hkabrechnung) {
		this.hkabrechnung = hkabrechnung
	}

	def double getQm() {
		return qm
	}

	def void setQm(double qm) {
		this.qm = qm
	}

	def double getGrundmiete() {
		return grundmiete
	}

	def void setGrundmiete(double grundmiete) {
		this.grundmiete = grundmiete
	}

	def double getKaution() {
		return kaution
	}

	def void setKaution(double kaution) {
		this.kaution = kaution
	}
}

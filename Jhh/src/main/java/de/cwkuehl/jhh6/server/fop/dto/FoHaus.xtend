package de.cwkuehl.jhh6.server.fop.dto

import java.time.LocalDate
import java.util.ArrayList
import java.util.List

class FoHaus {

	String bezeichnung = null
	LocalDate von = null
	LocalDate bis = null
	List<FoWohnung> wohnungen = new ArrayList<FoWohnung>()
	String datum = null
	String vmName = null
	String vmStrasse = null
	String vmOrt = null
	String vmTelefon = null
	String hStrasse = null
	String hausOrt = null
	String guthaben = null
	String nachzahlung = null
	String gruesse = null
	String anlage = null
	double qm = 0
	double personenmonate = 0
	int monate = 0
	FoZeile grundsteuer = null
	FoZeile strassenreinigung = null
	FoZeile abfall = null
	FoZeile strom = null
	FoZeile trinkwasser = null
	FoZeile schmutzwasser = null
	FoZeile niederschlagswasser = null
	FoZeile wohnversicherung = null
	FoZeile haftversicherung = null
	FoZeile glasversicherung = null
	FoZeile dachreinigung = null
	FoZeile schornsteinfeger = null
	FoZeile garten = null

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

	def List<FoWohnung> getWohnungen() {
		return wohnungen
	}

	def void setWohnungen(List<FoWohnung> wohnungen) {
		this.wohnungen = wohnungen
	}

	def String getDatum() {
		return datum
	}

	def void setDatum(String datum) {
		this.datum = datum
	}

	def String getVmName() {
		return vmName
	}

	def void setVmName(String vmName) {
		this.vmName = vmName
	}

	def String getVmStrasse() {
		return vmStrasse
	}

	def void setVmStrasse(String vmStrasse) {
		this.vmStrasse = vmStrasse
	}

	def String getVmOrt() {
		return vmOrt
	}

	def void setVmOrt(String vmOrt) {
		this.vmOrt = vmOrt
	}

	def String getVmTelefon() {
		return vmTelefon
	}

	def void setVmTelefon(String vmTelefon) {
		this.vmTelefon = vmTelefon
	}

	def String getHstrasse() {
		return hStrasse
	}

	def void setHstrasse(String hStrasse) {
		this.hStrasse = hStrasse
	}

	def String getHort() {
		return hausOrt
	}

	def void setHort(String hOrt) {
		this.hausOrt = hOrt
	}

	def String getAnlage() {
		return anlage
	}

	def void setAnlage(String anlage) {
		this.anlage = anlage
	}

	def double getQm() {
		return qm
	}

	def void setQm(double qm) {
		this.qm = qm
	}

	def double getPersonenmonate() {
		return personenmonate
	}

	def void setPersonenmonate(double personenmonate) {
		this.personenmonate = personenmonate
	}

	def int getMonate() {
		return monate
	}

	def void setMonate(int monate) {
		this.monate = monate
	}

	def FoZeile getGrundsteuer() {
		return grundsteuer
	}

	def void setGrundsteuer(FoZeile grundsteuer) {
		this.grundsteuer = grundsteuer
	}

	def FoZeile getStrassenreinigung() {
		return strassenreinigung
	}

	def void setStrassenreinigung(FoZeile strassenreinigung) {
		this.strassenreinigung = strassenreinigung
	}

	def FoZeile getAbfall() {
		return abfall
	}

	def void setAbfall(FoZeile abfall) {
		this.abfall = abfall
	}

	def FoZeile getStrom() {
		return strom
	}

	def void setStrom(FoZeile strom) {
		this.strom = strom
	}

	def FoZeile getTrinkwasser() {
		return trinkwasser
	}

	def void setTrinkwasser(FoZeile trinkwasser) {
		this.trinkwasser = trinkwasser
	}

	def FoZeile getSchmutzwasser() {
		return schmutzwasser
	}

	def void setSchmutzwasser(FoZeile schmutzwasser) {
		this.schmutzwasser = schmutzwasser
	}

	def FoZeile getNiederschlagswasser() {
		return niederschlagswasser
	}

	def void setNiederschlagswasser(FoZeile niederschlagswasser) {
		this.niederschlagswasser = niederschlagswasser
	}

	def FoZeile getWohnversicherung() {
		return wohnversicherung
	}

	def void setWohnversicherung(FoZeile wohnversicherung) {
		this.wohnversicherung = wohnversicherung
	}

	def FoZeile getHaftversicherung() {
		return haftversicherung
	}

	def void setHaftversicherung(FoZeile haftversicherung) {
		this.haftversicherung = haftversicherung
	}

	def FoZeile getGlasversicherung() {
		return glasversicherung
	}

	def void setGlasversicherung(FoZeile glasversicherung) {
		this.glasversicherung = glasversicherung
	}

	def FoZeile getDachreinigung() {
		return dachreinigung
	}

	def void setDachreinigung(FoZeile dachreinigung) {
		this.dachreinigung = dachreinigung
	}

	def FoZeile getSchornsteinfeger() {
		return schornsteinfeger
	}

	def void setSchornsteinfeger(FoZeile schornsteinfeger) {
		this.schornsteinfeger = schornsteinfeger
	}

	def FoZeile getGarten() {
		return garten
	}

	def void setGarten(FoZeile garten) {
		this.garten = garten
	}

	def String getGuthaben() {
		return guthaben
	}

	def void setGuthaben(String guthaben) {
		this.guthaben = guthaben
	}

	def String getNachzahlung() {
		return nachzahlung
	}

	def void setNachzahlung(String nachzahlung) {
		this.nachzahlung = nachzahlung
	}

	def String getGruesse() {
		return gruesse
	}

	def void setGruesse(String gruesse) {
		this.gruesse = gruesse
	}

	def String getBezeichnung() {
		return bezeichnung
	}

	def void setBezeichnung(String bezeichnung) {
		this.bezeichnung = bezeichnung
	}
}

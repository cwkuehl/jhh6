package de.cwkuehl.jhh6.api.service.detective

import java.io.Serializable
import java.util.List

class Runde implements Serializable {

	String id = null
	String spieler = null
	List<String> verdaechtige = null
	boolean besitzv = false
	List<String> werkzeuge = null
	boolean besitzw = false
	List<String> raeume = null
	boolean besitzr = false
	List<String> spielerOhne = null
	String spielerMit = null

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param id ID.
	 * @param spieler Spieler.
	 * @param verdaechtige Verdächtige.
	 */
	new(String id, String spieler, List<String> verdaechtige, boolean besitzv, List<String> werkzeuge, boolean besitzw,
		List<String> raeume, boolean besitzr, List<String> spielerOhne, String spielerMit) {
		super()
		setId(id)
		setSpieler(spieler)
		setVerdaechtige(verdaechtige)
		setBesitzv(besitzv)
		setWerkzeuge(werkzeuge)
		setBesitzw(besitzw)
		setRaeume(raeume)
		setBesitzr(besitzr)
		setSpielerOhne(spielerOhne)
		setSpielerMit(spielerMit)
	}

	def String getSpieler() {
		return spieler
	}

	def void setSpieler(String spieler) {
		this.spieler = spieler
	}

	def List<String> getVerdaechtige() {
		return verdaechtige
	}

	def void setVerdaechtige(List<String> verdaechtige) {
		this.verdaechtige = verdaechtige
	}

	def boolean isBesitzv() {
		return besitzv
	}

	def void setBesitzv(boolean besitzv) {
		this.besitzv = besitzv
	}

	def List<String> getWerkzeuge() {
		return werkzeuge
	}

	def void setWerkzeuge(List<String> werkzeuge) {
		this.werkzeuge = werkzeuge
	}

	def boolean isBesitzw() {
		return besitzw
	}

	def void setBesitzw(boolean besitzw) {
		this.besitzw = besitzw
	}

	def List<String> getRaeume() {
		return raeume
	}

	def void setRaeume(List<String> raeume) {
		this.raeume = raeume
	}

	def boolean isBesitzr() {
		return besitzr
	}

	def void setBesitzr(boolean besitzr) {
		this.besitzr = besitzr
	}

	def List<String> getSpielerOhne() {
		return spielerOhne
	}

	def void setSpielerOhne(List<String> spielerOhne) {
		this.spielerOhne = spielerOhne
	}

	def String getSpielerMit() {
		return spielerMit
	}

	def void setSpielerMit(String spielerMit) {
		this.spielerMit = spielerMit
	}

	def String getId() {
		return id
	}

	def void setId(String id) {
		this.id = id
	}
}

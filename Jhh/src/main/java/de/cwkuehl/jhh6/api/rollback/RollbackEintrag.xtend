package de.cwkuehl.jhh6.api.rollback

import de.cwkuehl.jhh6.api.dto.base.DtoBase

class RollbackEintrag {

	RollbackArtEnum art = null
	DtoBase eintrag = null

	/** 
	 * Standard-Konstruktor mit Initialisierung.
	 * @param a Rollback-Art.
	 * @param e DtoBase-Instanz.
	 */
	new(RollbackArtEnum a, DtoBase e) {
		art = a
		eintrag = e
	}

	def DtoBase getEintrag() {
		return eintrag
	}

	def RollbackArtEnum getArt() {
		return art
	}
}

package de.cwkuehl.jhh6.api.rollback

import java.util.ArrayList
import java.util.List
import de.cwkuehl.jhh6.api.dto.base.DtoBase

class RollbackListe {

	List<RollbackEintrag> liste = null
	boolean rollbackRedo = false

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		liste = new ArrayList<RollbackEintrag>()
	}

	def void addInsert(DtoBase e) {
		liste.add(0, new RollbackEintrag(RollbackArtEnum.INSERT, e))
	}

	def void addUpdate(DtoBase e) {
		liste.add(0, new RollbackEintrag(RollbackArtEnum.UPDATE, e))
	}

	def void addDelete(DtoBase e) {
		liste.add(0, new RollbackEintrag(RollbackArtEnum.DELETE, e))
	}

	def List<RollbackEintrag> getListe() {
		return liste
	}

	def boolean isRollbackRedo() {
		return rollbackRedo
	}

	def void setRollbackRedo(boolean rollbackRedo) {
		this.rollbackRedo = rollbackRedo
	}
}

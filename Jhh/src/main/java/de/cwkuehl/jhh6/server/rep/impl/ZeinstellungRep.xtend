package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.sql.PreparedStatement
import java.time.LocalDateTime

@Repository
@Table(name="zEinstellung")
class ZeinstellungRep {

	/**  
	* WHERE Schluessel: eq
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Schluessel")
		@Column(name="Schluessel", length=50, nullable=true)
		public String schluessel

		@Column(name="Wert", length=255, nullable=true)
		public String wert

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}
	
	override public int execute(ServiceDaten daten, String s) {
		
		if (Global.nes(s)) {
			return 0
		}
		val con = daten.getDb.con
		var PreparedStatement stmt = null
		var int rs
		try {
			log.info('''execute: «s»''')
			stmt = con.prepareStatement(s)
			rs = stmt.executeUpdate
		} finally {
			if (stmt !== null) {
				stmt.close
			}
		}
		return rs
	}
}

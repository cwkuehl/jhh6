package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="MA_Mandant")
class MaMandantRep {

	/**  
	 * WHERE Nr: eq
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Nr")
		@Column(name="Nr", nullable=false)
		public int nr

		@Column(name="Beschreibung", length=100, nullable=false)
		public String beschreibung

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Mandant-Liste lesen. */
	override List<MaMandant> getMandantListe(ServiceDaten daten, Integer nr) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (nr !== null) {
			sql.append(null, MaMandant.NR_NAME, "=", nr, null)
		}
		var order = new SqlBuilder("a.Nr")
		var l = getListe(daten, sql, order)
		return l
	}
}

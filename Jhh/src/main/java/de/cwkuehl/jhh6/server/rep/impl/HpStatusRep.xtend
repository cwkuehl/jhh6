package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="HP_Status")
class HpStatusRep {

	/** 
	 * Replication-Nr. 23 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Standard: eq
	 * ORDER BY SORTIERUNG: Mandant_Nr, Sortierung, Uid
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=false)
		public String uid

		@Column(name="Status", length=10, nullable=false)
		public String status

		@Column(name="Beschreibung", length=40, nullable=false)
		public String beschreibung

		@Column(name="Sortierung", nullable=false)
		public int sortierung

		@Column(name="Standard", nullable=false)
		public int standard

		@Column(name="Notiz", length=-1, nullable=true)
		public String notiz

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Status-Liste lesen. */
	override public List<HpStatus> getStatusListe(ServiceDaten daten, int standard) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, HpStatus.STANDARD_NAME, "=", standard, null)
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

}

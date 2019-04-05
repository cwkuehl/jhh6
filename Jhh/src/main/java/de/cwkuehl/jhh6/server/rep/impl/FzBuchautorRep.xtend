package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.global.Global
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
@Table(name="FZ_Buchautor")
class FzBuchautorRep {

	/** 
	 * Replication-Nr. 33 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * ORDER BY NAME: Mandant_Nr, Name, Vorname, Uid
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

		@Column(name="Name", length=50, nullable=false)
		public String name

		@Column(name="Vorname", length=50, nullable=true)
		public String vorname

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Buchautor-Liste lesen. */
	override List<FzBuchautor> getBuchautorListe(ServiceDaten daten, String name) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(name)) {
			sql.append("(", FzBuchautor.NAME_NAME, "like", name, null)
			sql.append(" OR ", FzBuchautor.VORNAME_NAME, "like", name, ")", true)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Name, a.Vorname, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

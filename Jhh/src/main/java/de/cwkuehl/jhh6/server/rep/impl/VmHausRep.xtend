package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmHaus
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
@Table(name="VM_Haus")
class VmHausRep {

	/** 
	 * Replication-Nr. 14 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung, Uid
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

		@Column(name="Bezeichnung", length=40, nullable=false)
		public String bezeichnung

		@Column(name="Strasse", length=40, nullable=true)
		public String strasse

		@Column(name="Plz", length=10, nullable=true)
		public String plz

		@Column(name="Ort", length=40, nullable=true)
		public String ort

		@Column(name="Notiz", nullable=true)
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

	/** Haus-Liste lesen. */
	override List<VmHaus> getHausListe(ServiceDaten daten, String uid, String bez) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, VmHaus.UID_NAME, "=", uid, null)
		}
		if (!Global.nesLike(bez)) {
			sql.append(null, VmHaus.BEZEICHNUNG_NAME, "like", bez, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.SbKind
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="SB_Kind")
class SbKindRep {

	/** 
	 * Replication-Nr. 29 Attribut Replikation_Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Familie_Uid: eq ne
	 * WHERE Kind_Uid: eq gt ne
	 * WHERE Replikation_Uid: eq isNull
	 * INDEX XRKSB_Kind: Replikation_Uid, Mandant_Nr
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Familie_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(SbFamilieRep))
		@Column(name="Familie_Uid", length=35, nullable=false)
		public String familieUid

		@PrimaryKeyJoinColumn(name="Kind_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(SbPersonRep))
		@Column(name="Kind_Uid", length=35, nullable=false)
		public String kindUid

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="Replikation_Uid", length=35, nullable=true)
		public String replikationUid
	}

	/** Kind-Liste lesen. */
	override List<SbKind> getKindListe(ServiceDaten daten, String fuid, String kuid, String fuidne, String kuidne,
		String kuidgt) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(fuid)) {
			sql.append(null, SbKind.FAMILIE_UID_NAME, "=", fuid, null)
		}
		if (!Global.nes(kuid)) {
			sql.append(null, SbKind.KIND_UID_NAME, "=", kuid, null)
		}
		if (!Global.nes(fuidne)) {
			sql.append(null, SbKind.FAMILIE_UID_NAME, "<>", fuidne, null)
		}
		if (!Global.nes(kuidne)) {
			sql.append(null, SbKind.KIND_UID_NAME, "<>", kuidne, null)
		}
		if (!Global.nes(kuidgt)) {
			sql.append(null, SbKind.KIND_UID_NAME, ">", kuidgt, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Familie_Uid, a.Kind_Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

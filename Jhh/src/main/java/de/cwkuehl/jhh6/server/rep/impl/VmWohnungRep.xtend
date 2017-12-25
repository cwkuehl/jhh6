package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmWohnung
import de.cwkuehl.jhh6.api.dto.VmWohnungLang
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
@Table(name="VM_Wohnung")
class VmWohnungRep {

	/** 
	 * Replication-Nr. 15 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Haus_Uid: eq
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung, Uid
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=true)
		public String uid

		@Column(name="Haus_Uid", length=35, nullable=false)
		public String hausUid

		@Column(name="Bezeichnung", length=40, nullable=false)
		public String bezeichnung

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

	/** SelectFrom: VM_Wohnung a left join VM_Haus b
	 *   on a.Mandant_Nr=b.Mandant_Nr and a.Haus_Uid=b.Uid
	 *  SelectOrderBy: a.Mandant_Nr, a.Haus_Uid, a.Bezeichnung, a.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Haus_Uid", length=35, nullable=false)
		public String hausUid

		@Column(name="a.Bezeichnung", length=40, nullable=false)
		public String bezeichnung

		@Column(name="a.Notiz", nullable=true)
		public String notiz

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Bezeichnung", nullable=true)
		public String hausBezeichnung
	}

	/** Wohnung-Lang-Liste lesen. */
	override List<VmWohnungLang> getWohnungLangListe(ServiceDaten daten, String uid, String hausUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (uid !== null) {
			sql.append(null, VmWohnung.UID_NAME, "=", uid, null)
		}
		if (hausUid !== null) {
			sql.append(null, VmWohnung.HAUS_UID_NAME, "=", hausUid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

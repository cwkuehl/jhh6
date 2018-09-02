package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.MoEinteilung
import de.cwkuehl.jhh6.api.dto.MoEinteilungLang
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
@Table(name="MO_Einteilung")
class MoEinteilungRep {

	/** 
	 * Replication-Nr. 43 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Gottesdienst_Uid: eq
	 * WHERE Messdiener_Uid: eq
	 * ORDER BY TERMIN: Mandant_Nr, Termin, Uid
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

		@Column(name="Gottesdienst_Uid", length=35, nullable=false)
		public String gottesdienstUid

		@Column(name="Messdiener_Uid", length=35, nullable=false)
		public String messdienerUid

		@Column(name="Termin", nullable=false)
		public LocalDateTime termin

		@Column(name="Dienst", length=50, nullable=false)
		public String dienst

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (MO_Einteilung a
	 *   inner join MO_Messdiener b on a.Mandant_Nr=b.Mandant_Nr and a.Messdiener_Uid=b.Uid)
	 *  SelectOrderBy: a.Dienst, b.Name, b.Vorname, a.Termin, a.Uid, b.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Gottesdienst_Uid", length=35, nullable=false)
		public String gottesdienstUid

		@Column(name="a.Messdiener_Uid", length=35, nullable=false)
		public String messdienerUid

		@Column(name="a.Termin", nullable=false)
		public LocalDateTime termin

		@Column(name="a.Dienst", length=50, nullable=false)
		public String dienst

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Name", nullable=true)
		public String messdienerName

		@Column(name="b.Vorname", nullable=true)
		public String messdienerVorname

		@Column(name="NULL", nullable=true)
		public String messdienerInfo

		@Column(name="NULL", nullable=true)
		public String gottesdienstStatus
	}

	/** Einteilung-Liste lesen. */
	override List<MoEinteilung> getEinteilungListe(ServiceDaten daten, String gdUid, String mdUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(gdUid)) {
			sql.append(null, MoEinteilung.GOTTESDIENST_UID_NAME, "=", gdUid, null)
		}
		if (!Global.nes(mdUid)) {
			sql.append(null, MoEinteilung.MESSDIENER_UID_NAME, "=", mdUid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Termin, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Einteilung-Lang-Liste lesen. */
	override List<MoEinteilungLang> getEinteilungLangListe(ServiceDaten daten, String gdUid, String mdUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(gdUid)) {
			sql.append(null, MoEinteilung.GOTTESDIENST_UID_NAME, "=", gdUid, null)
		}
		if (!Global.nes(mdUid)) {
			sql.append(null, MoEinteilung.MESSDIENER_UID_NAME, "=", mdUid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Termin, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Letzte Einteilung lesen. */
	override MoEinteilung getLastEinteilung(ServiceDaten daten, String mdUid, LocalDateTime vor) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		if (!Global.nes(mdUid)) {
			where.append(null, MoEinteilung.MESSDIENER_UID_NAME, "=", mdUid, null)
		}
		if (vor !== null) {
			where.append(null, MoEinteilung.TERMIN_NAME, "<=", vor, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Termin DESC, a.Uid")
		var sql = selectSql(null, daten.mandantNr, where, order)
		var l = selectOne(daten, sql, readDto, typeof(MoEinteilung))
		return l
	}
}

package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.MoGottesdienst
import de.cwkuehl.jhh6.api.dto.MoGottesdienstLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="MO_Gottesdienst")
class MoGottesdienstRep {

	/** 
	 * Replication-Nr. 41 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Profil_Uid: eq
	 * WHERE Termin: eq ge lt
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

		@Column(name="Termin", nullable=false)
		public LocalDateTime termin

		@Column(name="Name", length=50, nullable=false)
		public String name

		@Column(name="Ort", length=50, nullable=false)
		public String ort

		@Column(name="Profil_Uid", length=35, nullable=true)
		public String profilUid

		@Column(name="Status", length=10, nullable=false) // null in Datenbank
		public String status

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

	/** SelectFrom: (((MO_Gottesdienst a
	 *   left join MO_Einteilung b on a.Mandant_Nr=b.Mandant_Nr and a.Uid=b.Gottesdienst_Uid)
	 *   left join MO_Messdiener c on b.Mandant_Nr=c.Mandant_Nr and b.Messdiener_Uid=c.Uid)
	 *   left join MO_Profil d on a.Mandant_Nr=d.Mandant_Nr and a.Profil_Uid=d.Uid)
	 *  SelectOrderBy: a.Termin, b.Dienst, c.Name, c.Vorname, a.Uid, b.Uid, c.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Termin", nullable=false)
		public LocalDateTime termin

		@Column(name="a.Name", length=50, nullable=false)
		public String name

		@Column(name="a.Ort", length=50, nullable=false)
		public String ort

		@Column(name="a.Profil_Uid", length=35, nullable=true)
		public String profilUid

		@Column(name="a.Status", length=10, nullable=false)
		public String status

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

		@Column(name="b.Uid", nullable=true)
		public String einteilungUid

		@Column(name="b.Dienst", nullable=true)
		public String einteilungDienst

		@Column(name="c.Uid", nullable=true) // Where:  eq
		public String messdienerUid

		@Column(name="c.Name", nullable=true)
		public String messdienerName

		@Column(name="c.Vorname", nullable=true)
		public String messdienerVorname
	}

	/** Gottesdienst-Liste lesen. */
	override List<MoGottesdienst> getGottesdienstListe(ServiceDaten daten, String profilUid, LocalDate von,
		LocalDate bis, LocalDateTime termin, boolean absteigend) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(profilUid)) {
			sql.append(null, MoGottesdienst.PROFIL_UID_NAME, "=", profilUid, null)
		}
		if (von !== null) {
			sql.append(null, MoGottesdienst.TERMIN_NAME, ">=", von.atStartOfDay, null)
		}
		if (bis !== null) {
			sql.append(null, MoGottesdienst.TERMIN_NAME, "<", bis.plusDays(1).atStartOfDay, null)
		}
		if (termin !== null) {
			sql.append(null, MoGottesdienst.TERMIN_NAME, "=", termin, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Termin")
		if (absteigend) {
			order.append(" DESC")
		}
		order.append(", a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Gottesdienst-Lang-Liste lesen. */
	override List<MoGottesdienstLang> getGottesdienstLangListe(ServiceDaten daten, String profilUid, LocalDate von,
		LocalDate bis, boolean absteigend) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(profilUid)) {
			sql.append(null, MoGottesdienst.PROFIL_UID_NAME, "=", profilUid, null)
		}
		if (von !== null) {
			sql.append(null, MoGottesdienst.TERMIN_NAME, ">=", von.atStartOfDay, null)
		}
		if (bis !== null) {
			sql.append(null, MoGottesdienst.TERMIN_NAME, "<", bis.plusDays(1).atStartOfDay, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Termin, b.Dienst, c.Name, c.Vorname, a.Uid, b.Uid, c.Uid")
		if (absteigend) {
			order.append(" DESC")
		}
		order.append(", a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

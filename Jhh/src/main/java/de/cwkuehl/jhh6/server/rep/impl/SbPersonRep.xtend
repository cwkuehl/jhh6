package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.SbPerson
import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.dto.SbPersonUpdate
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
@Table(name="SB_Person")
class SbPersonRep {

	/** 
	 * Replication-Nr. 30 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Vorname: like
	 * WHERE Quelle_Uid: eq
	 * WHERE Status1: lt le eq ge gt
	 * WHERE Status2: eq ne
	 * WHERE OR Nachname: Name Geburtsname: like
	 * ORDER BY GEBURTSNAME: Mandant_Nr, Geburtsname, Vorname, Uid
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

		@Column(name="Geburtsname", length=50, nullable=true)
		public String geburtsname

		@Column(name="Geschlecht", length=1, nullable=true)
		public String geschlecht

		@Column(name="Titel", length=50, nullable=true)
		public String titel

		@Column(name="Konfession", length=20, nullable=true)
		public String konfession

		@Column(name="Bemerkung", length=255, nullable=true)
		public String bemerkung

		@Column(name="Quelle_Uid", length=35, nullable=true)
		public String quelleUid

		@Column(name="Status1", nullable=false)
		public int status1

		@Column(name="Status2", nullable=false)
		public int status2

		@Column(name="Status3", nullable=false)
		public int status3

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: ((((SB_Person a
	 *   LEFT JOIN SB_Kind b ON a.Mandant_Nr = b.Mandant_Nr and a.Uid = b.Kind_Uid)
	 *   LEFT JOIN SB_Familie c ON b.Mandant_Nr = c.Mandant_Nr and b.Familie_Uid = c.Uid)
	 *   LEFT JOIN SB_Person d ON c.Mandant_Nr = d.Mandant_Nr and c.Mann_Uid = d.Uid)
	 *   LEFT JOIN SB_Person e ON c.Mandant_Nr = e.Mandant_Nr and c.Frau_Uid = e.Uid)
	 *  SelectOrderBy: a.Mandant_Nr, a.Geburtsname, a.Vorname, a.Uid
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=false)
		public String uid

		@Column(name="a.Name", length=50, nullable=false)
		public String name

		@Column(name="a.Vorname", length=50, nullable=true)
		public String vorname

		@Column(name="a.Geburtsname", length=50, nullable=true)
		public String geburtsname

		@Column(name="a.Geschlecht", length=1, nullable=true)
		public String geschlecht

		@Column(name="a.Titel", length=50, nullable=true)
		public String titel

		@Column(name="a.Konfession", length=20, nullable=true)
		public String konfession

		@Column(name="a.Bemerkung", length=255, nullable=true)
		public String bemerkung

		@Column(name="a.Quelle_Uid", length=35, nullable=true)
		public String quelleUid

		@Column(name="a.Status1", nullable=false)
		public int status1

		@Column(name="a.Status2", nullable=false)
		public int status2

		@Column(name="a.Status3", nullable=false)
		public int status3

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Familie_Uid", nullable=true) // Where:  eq
		public String familieUid

		@Column(name="d.Uid", nullable=true)
		public String vaterUid

		@Column(name="d.Geburtsname", nullable=true)
		public String vaterGeburtsname

		@Column(name="d.Vorname", nullable=true)
		public String vaterVorname

		@Column(name="e.Uid", nullable=true)
		public String mutterUid

		@Column(name="e.Geburtsname", nullable=true)
		public String mutterGeburtsname

		@Column(name="e.Vorname", nullable=true)
		public String mutterVorname

		@Column(name="NULL", nullable=true)
		public String geburtsdatum

		@Column(name="NULL", nullable=true)
		public String todesdatum
	}

	/** Person-Lang-Liste lesen. */
	override List<SbPersonLang> getPersonLangListe(ServiceDaten daten, String uid, String nachname, String vorname,
		String fuid, String quid, Integer status2) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, SbPerson.UID_NAME, "=", uid, null)
		}
		if (!Global.nesLike(nachname)) {
			sql.append("(", SbPerson.NAME_NAME, "like", nachname, null)
			sql.append(" OR ", SbPerson.GEBURTSNAME_NAME, "like", nachname, ")", true)
		}
		if (!Global.nesLike(vorname)) {
			sql.append(null, SbPerson.VORNAME_NAME, "like", vorname, null)
		}
		if (!Global.nes(fuid)) {
			sql.append(null, "b.Familie_Uid", "=", fuid, null)
		}
		if (!Global.nes(quid)) {
			sql.append(null, SbPerson.QUELLE_UID_NAME, "=", quid, null)
		}
		if (status2 !== null) {
			sql.append(null, SbPerson.STATUS2_NAME, "=", status2, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Geburtsname, a.Name, a.Vorname, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Suchen der nächsten Person-Lang. */
	override SbPersonLang getPersonLang(ServiceDaten daten, SbPersonLang p0, String suchname, String suchvorname) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.max = 1
		if (p0 !== null && !Global.nes(p0.geburtsname) && !Global.nes(p0.name) && !Global.nes(p0.uid)) {
			if (Global.nes(p0.vorname)) {
				sql.append("((", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null)
				sql.append(" AND ", SbPerson.NAME_NAME, "=", p0.name, null, true)
				sql.append(" AND ", "(Vorname IS NULL OR Vorname='')", null, true)
				sql.append(" AND ", SbPerson.UID_NAME, ">", p0.uid, ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null, true)
				sql.append(" AND ", SbPerson.NAME_NAME, "=", p0.name, null, true)
				sql.append(" AND ", "NOT (Vorname IS NULL OR Vorname='')", ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null, true)
				sql.append(" AND ", SbPerson.NAME_NAME, ">", p0.name, ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, ">", p0.geburtsname, "))", true)
			} else {
				sql.append("((", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null)
				sql.append(" AND ", SbPerson.NAME_NAME, "=", p0.name, null, true)
				sql.append(" AND ", SbPerson.VORNAME_NAME, "=", p0.vorname, null, true)
				sql.append(" AND ", SbPerson.UID_NAME, ">", p0.uid, ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null, true)
				sql.append(" AND ", SbPerson.NAME_NAME, "=", p0.name, null, true)
				sql.append(" AND ", SbPerson.VORNAME_NAME, ">", p0.vorname, ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, "=", p0.geburtsname, null, true)
				sql.append(" AND ", SbPerson.NAME_NAME, ">", p0.name, ")", true)
				sql.append(" OR (", SbPerson.GEBURTSNAME_NAME, ">", p0.geburtsname, "))", true)
			}
		}
		if (!Global.nesLike(suchname)) {
			sql.append("(", SbPerson.NAME_NAME, "like", suchname, null)
			sql.append(" OR ", SbPerson.GEBURTSNAME_NAME, "like", suchname, ")", true)
		}
		if (!Global.nesLike(suchvorname)) {
			sql.append(null, SbPerson.VORNAME_NAME, "like", suchvorname, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Geburtsname, a.Name, a.Vorname, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return if(l.size > 0) l.get(0) else null
	}

	override int updateStatus2(ServiceDaten daten, String operator, int status1, int status2) {

		var anzahl = 0
		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (Global.nes(operator)) {
			sql.append(null, SbPerson.STATUS2_NAME, "=", status1, null)
		} else {
			sql.append(null, SbPerson.STATUS1_NAME, operator, status1, null)
		}
		sql.append(null, SbPerson.STATUS2_NAME, "<>", status2, null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var liste = getListe(daten, daten.mandantNr, sql, order)
		for (SbPerson p : liste) {
			var pU = new SbPersonUpdate(p)
			pU.status2 = status2
			update(daten, pU)
			anzahl++
		}
		return anzahl
	}
}

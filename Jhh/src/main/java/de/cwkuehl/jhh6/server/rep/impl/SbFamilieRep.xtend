package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.SbFamilie
import de.cwkuehl.jhh6.api.dto.SbFamilieKey
import de.cwkuehl.jhh6.api.dto.SbFamilieLang
import de.cwkuehl.jhh6.api.dto.SbFamilieStatus
import de.cwkuehl.jhh6.api.dto.SbFamilieUpdate
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
@Table(name="SB_Familie")
class SbFamilieRep {

	/** 
	 * Replication-Nr. 28 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq ne
	 * WHERE Mann_Uid: eq
	 * WHERE Frau_Uid: eq
	 * WHERE Status2: eq ne
	 * WHERE OR Person_Uid: Mann_Uid Frau_Uid: eq
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

		@Column(name="Mann_Uid", length=35, nullable=true)
		public String mannUid

		@Column(name="Frau_Uid", length=35, nullable=true)
		public String frauUid

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

	/** SelectFrom: ((SB_Familie a
	 *   LEFT JOIN SB_Person b ON a.Mandant_Nr = b.Mandant_Nr and a.Mann_Uid = b.Uid)
	 *   LEFT JOIN SB_Person c ON a.Mandant_Nr = c.Mandant_Nr and a.Frau_Uid = c.Uid)
	 *  SelectOrderBy: a.Mandant_Nr, b.Geburtsname, b.Vorname, c.Geburtsname, c.Vorname, a.Uid
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Mann_Uid", length=35, nullable=true)
		public String mannUid

		@Column(name="a.Frau_Uid", length=35, nullable=true)
		public String frauUid

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

		@Column(name="b.Geburtsname", nullable=true)
		public String vaterGeburtsname

		@Column(name="b.Vorname", nullable=true)
		public String vaterVorname

		@Column(name="c.Geburtsname", nullable=true)
		public String mutterGeburtsname

		@Column(name="c.Vorname", nullable=true)
		public String mutterVorname
	}

	/** SelectFrom: (((SB_Familie a
	 *   LEFT JOIN SB_Kind b ON a.Mandant_Nr = b.Mandant_Nr AND a.Uid = b.Familie_Uid)
	 *   LEFT JOIN SB_Person c ON a.Mandant_Nr = c.Mandant_Nr AND a.Mann_Uid = c.Uid)
	 *   LEFT JOIN SB_Person d ON a.Mandant_Nr = d.Mandant_Nr AND a.Frau_Uid = d.Uid)
	 *   LEFT JOIN SB_Person e ON b.Mandant_Nr = e.Mandant_Nr AND b.Kind_Uid = e.Uid
	 *  SelectOrderBy: a.Mandant_Nr, a.Uid, b.Kind_Uid
	 */
	static class VoStatus {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Mann_Uid", length=35, nullable=true)
		public String mannUid

		@Column(name="a.Frau_Uid", length=35, nullable=true)
		public String frauUid

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

		@Column(name="b.Kind_Uid", nullable=true) // Where:  eq
		public String kindUid

		@Column(name="c.Status1", nullable=true)
		public int mannStatus1

		@Column(name="c.Status2", nullable=true) // Where:  eq
		public int mannStatus2

		@Column(name="d.Status1", nullable=true)
		public int frauStatus1

		@Column(name="d.Status2", nullable=true) // Where:  eq
		public int frauStatus2

		@Column(name="e.Status1", nullable=true)
		public int kindStatus1
	}

	/** Familie-Liste lesen. */
	override List<SbFamilie> getFamilieListe(ServiceDaten daten, String uid, String muid, String fuid, String personuid,
		String uidne) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, SbFamilie.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(uidne)) {
			sql.append(null, SbFamilie.UID_NAME, "<>", uidne, null)
		}
		if (!Global.nes(muid)) {
			sql.append(null, SbFamilie.MANN_UID_NAME, "=", muid, null)
		}
		if (!Global.nes(fuid)) {
			sql.append(null, SbFamilie.FRAU_UID_NAME, "=", fuid, null)
		}
		if (!Global.nes(personuid)) {
			sql.append("(", SbFamilie.MANN_UID_NAME, "=", personuid, null)
			sql.append(" OR ", SbFamilie.FRAU_UID_NAME, "=", personuid, ")", true)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Familie-Lang-Liste lesen. */
	override List<SbFamilieLang> getFamilieLangListe(ServiceDaten daten, String uid, String muid, String fuid,
		String personuid, String uidne) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, SbFamilie.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(uidne)) {
			sql.append(null, SbFamilie.UID_NAME, "<>", uidne, null)
		}
		if (!Global.nes(muid)) {
			sql.append(null, SbFamilie.MANN_UID_NAME, "=", muid, null)
		}
		if (!Global.nes(fuid)) {
			sql.append(null, SbFamilie.FRAU_UID_NAME, "=", fuid, null)
		}
		if (!Global.nes(personuid)) {
			sql.append("(", SbFamilie.MANN_UID_NAME, "=", personuid, null)
			sql.append(" OR ", SbFamilie.FRAU_UID_NAME, "=", personuid, ")", true)
		}
		var order = new SqlBuilder("a.Mandant_Nr, b.Geburtsname, b.Vorname, c.Geburtsname, c.Vorname, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Familie-Status-Liste lesen. */
	override List<SbFamilieStatus> getFamilieStatusListe(ServiceDaten daten, String personuid, String kuid, Integer status2) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(personuid)) {
			sql.append("(", SbFamilie.MANN_UID_NAME, "=", personuid, null)
			sql.append(" OR ", SbFamilie.FRAU_UID_NAME, "=", personuid, ")", true)
		}
		if (!Global.nes(kuid)) {
			sql.append(null, "b.Kind_Uid", "=", kuid, null)
		}
		if (status2 !== null) {
			sql.append(null, SbFamilie.STATUS2_NAME, "=", status2, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var l = getListeStatus(daten, daten.mandantNr, sql, order)
		return l
	}

	override int updateStatus2(ServiceDaten daten, int status2) {

		var anzahl = 0
		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, SbFamilie.STATUS2_NAME, "<>", status2, null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var liste = getListe(daten, daten.mandantNr, sql, order)
		for (SbFamilie p : liste) {
			var pU = new SbFamilieUpdate(p)
			pU.status2 = status2
			update(daten, pU)
			anzahl++
		}
		return anzahl
	}

    override int updateMannFrauStatus2(ServiceDaten daten, int status2) {

        var anzahl = 0
		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, SbFamilie.STATUS2_NAME, "<>", status2, null)
		sql.append("(", "c.Status2", "=", status2, null)
		sql.append(" OR ", "d.Status2", "=", status2, ")", true)

		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var liste = getListeStatus(daten, daten.mandantNr, sql, order)

        for (SbFamilieStatus p : liste) {
            var f = get(daten, new SbFamilieKey(daten.mandantNr, p.uid))
            var pU = new SbFamilieUpdate(f)
            pU.setStatus2(status2)
            update(daten, pU)
            anzahl++
        }
        return anzahl
    }
}

package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.SbQuelle
import de.cwkuehl.jhh6.api.dto.SbQuelleKey
import de.cwkuehl.jhh6.api.dto.SbQuelleStatus
import de.cwkuehl.jhh6.api.dto.SbQuelleUpdate
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
@Table(name="SB_Quelle")
class SbQuelleRep {

	/** 
	 * Replication-Nr. 31 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Status2: eq ne
	 * ORDER BY AUTOR: Mandant_Nr, Autor, Uid
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=false)
		public String uid

		@Column(name="Beschreibung", length=255, nullable=false)
		public String beschreibung

		@Column(name="Zitat", nullable=true)
		public String zitat

		@Column(name="Bemerkung", nullable=true)
		public String bemerkung

		@Column(name="Autor", length=255, nullable=false)
		public String autor

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

	/** SelectFrom: (SB_Quelle a
	 *   LEFT JOIN SB_Person b ON a.Mandant_Nr = b.Mandant_Nr AND a.Uid = b.Quelle_Uid)
	 *  SelectOrderBy: a.Mandant_Nr, a.Uid, b.Uid
	 */
	static class VoStatus {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=false)
		public String uid

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

		@Column(name="b.Status2", nullable=true) // Where:  eq
		public int personStatus2
	}

	/** Quelle-Liste lesen. */
	override List<SbQuelle> getQuelleListe(ServiceDaten daten, String uid, Integer status2) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, SbQuelle.UID_NAME, "=", uid, null)
		}
		if (status2 !== null) {
			sql.append(null, SbQuelle.STATUS2_NAME, "=", status2, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Autor, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	override int updateStatus2(ServiceDaten daten, int status2) {

		var anzahl = 0
		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, SbQuelle.STATUS2_NAME, "<>", status2, null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var liste = getListe(daten, daten.mandantNr, sql, order)
		for (SbQuelle p : liste) {
			var pU = new SbQuelleUpdate(p)
			pU.status2 = status2
			update(daten, pU)
			anzahl++
		}
		return anzahl
	}

    override int updatePersonStatus2(ServiceDaten daten, int status2) {

        var anzahl = 0
        var String quid = null
		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, SbQuelle.STATUS2_NAME, "<>", status2, null)
		sql.append(null, "b.Status2", "=", status2, null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid, b.Uid")
		var liste = getListeStatus(daten, daten.mandantNr, sql, order)
        for (SbQuelleStatus p : liste) {
            if (Global.compString(quid, p.getUid()) != 0) {
                var q = get(daten, new SbQuelleKey(daten.mandantNr, p.uid))
                var pU = new SbQuelleUpdate(q)
                pU.setStatus2 = status2
                update(daten, pU)
                anzahl++
            }
            quid = p.getUid()
        }
        return anzahl
    }
}

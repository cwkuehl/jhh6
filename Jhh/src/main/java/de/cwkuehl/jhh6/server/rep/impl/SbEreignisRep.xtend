package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.SbEreignis
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
@Table(name="SB_Ereignis")
class SbEreignisRep {

	/** 
	 * Replication-Nr. 27 Attribut Replikation_Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Person_Uid: eq
	 * WHERE Familie_Uid: eq
	 * WHERE Typ: eq
	 * WHERE Quelle_Uid: eq
	 * WHERE Replikation_Uid: eq isNull
	 * INDEX XRKSB_Ereignis: Replikation_Uid, Mandant_Nr
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Person_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(SbPersonRep))
		@Column(name="Person_Uid", length=35, nullable=false)
		public String personUid

		@PrimaryKeyJoinColumn(name="Familie_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(SbFamilieRep))
		@Column(name="Familie_Uid", length=35, nullable=false)
		public String familieUid

		@PrimaryKeyJoinColumn(name="Typ")
		@Column(name="Typ", length=4, nullable=false)
		public String typ

		@Column(name="Tag1", nullable=false)
		public int tag1

		@Column(name="Monat1", nullable=false)
		public int monat1

		@Column(name="Jahr1", nullable=false)
		public int jahr1

		@Column(name="Tag2", nullable=false)
		public int tag2

		@Column(name="Monat2", nullable=false)
		public int monat2

		@Column(name="Jahr2", nullable=false)
		public int jahr2

		@Column(name="Datum_Typ", length=4, nullable=false)
		public String datumTyp

		@Column(name="Ort", length=120, nullable=true)
		public String ort

		@Column(name="Bemerkung", nullable=true)
		public String bemerkung

		@Column(name="Quelle_Uid", length=12, nullable=true)
		public String quelleUid

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

	/** Ereignis-Liste lesen. */
	override List<SbEreignis> getEreignisListe(ServiceDaten daten, String personUid, String familieUid, String typ,
		String quid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(personUid)) {
			sql.append(null, SbEreignis.PERSON_UID_NAME, "=", personUid, null)
		}
		if (!Global.nes(familieUid)) {
			sql.append(null, SbEreignis.FAMILIE_UID_NAME, "=", familieUid, null)
		}
		if (!Global.nes(typ)) {
			sql.append(null, SbEreignis.TYP_NAME, "=", typ, null)
		}
		if (!Global.nes(quid)) {
			sql.append(null, SbEreignis.QUELLE_UID_NAME, "=", quid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Person_Uid, a.Familie_Uid, a.Typ")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

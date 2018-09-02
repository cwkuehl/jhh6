package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HpRechnung
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
@Table(name="HP_Rechnung")
class HpRechnungRep {

	/** 
	 * Replication-Nr. 22 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq ne
	 * WHERE Patient_Uid: eq
	 * WHERE Status_Uid: eq
	 * WHERE Datum: eq
	 * ORDER BY DATUM: Mandant_Nr, Datum, Rechnungsnummer, Uid
	 * ORDER BY RECHNUNGSNUMMER: Mandant_Nr, Rechnungsnummer DESC, Uid DESC
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

		@Column(name="Rechnungsnummer", length=20, nullable=false)
		public String rechnungsnummer

		@Column(name="Datum", nullable=false)
		public LocalDate datum

		@Column(name="Patient_Uid", length=35, nullable=false)
		public String patientUid

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="Diagnose", length=50, nullable=false)
		public String diagnose

		@Column(name="Status_Uid", length=35, nullable=false)
		public String statusUid

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

	/** SelectFrom: (HP_Rechnung a
	 *   inner join HP_Patient b on a.Mandant_Nr=b.Mandant_Nr and a.Patient_Uid=b.Uid)
	 *  SelectOrderBy: a.Datum DESC, a.Rechnungsnummer DESC, a.Uid DESC
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Rechnungsnummer", length=20, nullable=false)
		public String rechnungsnummer

		@Column(name="a.Datum", nullable=false)
		public LocalDate datum

		@Column(name="a.Patient_Uid", length=35, nullable=false)
		public String patientUid

		@Column(name="a.Betrag", nullable=false)
		public double betrag

		@Column(name="a.Diagnose", length=50, nullable=false)
		public String diagnose

		@Column(name="a.Status_Uid", length=35, nullable=false)
		public String statusUid

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

		@Column(name="b.Name1", nullable=true)
		public String patientName

		@Column(name="b.Vorname", nullable=true)
		public String patientVorname
	}

	/** Rechnung-Liste lesen. */
	override public List<HpRechnung> getRechnungListe(ServiceDaten daten, String uid, String patientUid,
		LocalDate datum) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, HpRechnung.UID_NAME, "<>", uid, null)
		}
		if (!Global.nes(patientUid)) {
			sql.append(null, HpRechnung.PATIENT_UID_NAME, "=", patientUid, null)
		}
		if (datum !== null) {
			sql.append(null, HpRechnung.DATUM_NAME, "=", datum, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Rechnungsnummer DESC, a.Uid DESC")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

}

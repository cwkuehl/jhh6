package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HpPatient
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
@Table(name="HP_Patient")
class HpPatientRep {

	/** 
	* Replication-Nr. 21 Attribut Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Uid: eq
	* WHERE Rechnung_Patient_Uid: eq
	* ORDER BY NAME: Mandant_Nr, Name1, Vorname, Uid
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

		@Column(name="Name1", length=50, nullable=false)
		public String name1

		@Column(name="Vorname", length=50, nullable=true)
		public String vorname

		@Column(name="Geschlecht", length=1, nullable=false)
		public String geschlecht

		@Column(name="Geburt", nullable=true)
		public LocalDate geburt

		@Column(name="Adresse1", length=50, nullable=true)
		public String adresse1

		@Column(name="Adresse2", length=50, nullable=true)
		public String adresse2

		@Column(name="Adresse3", length=50, nullable=true)
		public String adresse3

		@Column(name="Rechnung_Patient_Uid", length=35, nullable=true)
		public String rechnungPatientUid

		@Column(name="Status", length=10, nullable=true)
		public String status

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

	/** Patient-Liste lesen. */
	override public List<HpPatient> getPatientListe(ServiceDaten daten, String rechnungPatientUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(rechnungPatientUid)) {
			sql.append(null, HpPatient.RECHNUNG_PATIENT_UID_NAME, "=", rechnungPatientUid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

}

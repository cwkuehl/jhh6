package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDate
import java.time.LocalDateTime

@Repository
@Table(name="FZ_Buchstatus")
class FzBuchstatusRep {

	/** 
	* Replication-Nr. 35 Attribut Replikation_Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Buch_Uid: eq
	* WHERE Replikation_Uid: eq isNull
	* INDEX XRKFZ_Buchstatus: Replikation_Uid, Mandant_Nr
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Buch_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(FzBuchRep))
		@Column(name="Buch_Uid", length=35, nullable=false)
		public String buchUid

		@Column(name="Ist_Besitz", nullable=false)
		public boolean istBesitz

		@Column(name="Lesedatum", nullable=true)
		public LocalDate lesedatum

		@Column(name="Hoerdatum", nullable=true)
		public LocalDate hoerdatum

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
}

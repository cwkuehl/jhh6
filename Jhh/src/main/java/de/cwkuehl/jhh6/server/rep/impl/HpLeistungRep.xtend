package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDateTime

@Repository
@Table(name="HP_Leistung")
class HpLeistungRep {

	/** 
	* Replication-Nr. 20 Attribut Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Uid: eq
	* ORDER BY ZIFFER: Mandant_Nr, Ziffer, Uid
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

		@Column(name="Ziffer", length=10, nullable=false)
		public String ziffer

		@Column(name="Ziffer_Alt", length=10, nullable=false)
		public String zifferAlt

		@Column(name="Beschreibung_Fett", length=100, nullable=false)
		public String beschreibungFett

		@Column(name="Beschreibung", length=-1, nullable=false)
		public String beschreibung

		@Column(name="Faktor", nullable=false)
		public double faktor

		@Column(name="Festbetrag", nullable=false)
		public double festbetrag

		@Column(name="Fragen", length=-1, nullable=true)
		public String fragen // Spalte entfällt

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
}

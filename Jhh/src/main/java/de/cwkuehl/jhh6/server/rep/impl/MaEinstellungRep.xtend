package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDateTime

@Repository
@Table(name="MA_Einstellung")
class MaEinstellungRep {

	/**  
	* WHERE Mandant_Nr: eq
	* WHERE Schluessel: like
	* WHERE Wert: like
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Schluessel")
		@Column(name="Schluessel", length=50, nullable=false)
		public String schluessel

		@Column(name="Wert", length=-1, nullable=true)
		public String wert

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

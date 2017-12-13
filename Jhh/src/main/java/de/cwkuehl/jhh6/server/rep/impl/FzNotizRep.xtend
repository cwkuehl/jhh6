package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDateTime

@Repository
@Table(name="FZ_Notiz")
class FzNotizRep {

	/** 
	* Replication-Nr. 2 Attribut Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Uid: eq
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=true)
		public String uid

		@Column(name="Thema", length=100, nullable=false)
		public String thema

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

	/** SelectFrom: FZ_Notiz a
	 */
	static class VoKurz {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Thema", length=100, nullable=false)
		public String thema

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

}

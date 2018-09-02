package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDateTime

@Repository
@Table(name="VM_Ereignis")
class VmEreignisRep {

	/** 
	* Replication-Nr. 9 Attribut Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Uid: eq
	* WHERE Haus_Uid: eq
	* WHERE Wohnung_Uid: eq
	* WHERE Mieter_Uid: eq
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(HhEreignisRep))
		@Column(name="Uid", length=35, nullable=false)
		public String uid

		@Column(name="Schluessel", length=10, nullable=true)
		public String schluessel

		@Column(name="Haus_Uid", length=35, nullable=true)
		public String hausUid

		@Column(name="Wohnung_Uid", length=35, nullable=true)
		public String wohnungUid

		@Column(name="Mieter_Uid", length=35, nullable=true)
		public String mieterUid

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
}

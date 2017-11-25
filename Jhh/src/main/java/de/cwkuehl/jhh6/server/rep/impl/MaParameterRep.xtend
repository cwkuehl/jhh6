package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.MaParameter
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
@Table(name="MA_Parameter")
class MaParameterRep {

	/** 
	* Replication-Nr. 39 Attribut Replikation_Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Schluessel: like
	* WHERE Wert: like
	* WHERE Replikation_Uid: eq isNull
	* INDEX XRKMA_Parameter: Replikation_Uid, Mandant_Nr
	*/
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Schluessel")
		@Column(name="Schluessel", length=50, nullable=true)
		public String schluessel

		@Column(name="Wert", nullable=true)
		public String wert

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

	/** Parameter-Liste lesen. */
	override List<MaParameter> getParameterListe(ServiceDaten daten, String schluessel) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(schluessel)) {
			sql.append(null, MaParameter.SCHLUESSEL_NAME, "like", schluessel, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Schluessel")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

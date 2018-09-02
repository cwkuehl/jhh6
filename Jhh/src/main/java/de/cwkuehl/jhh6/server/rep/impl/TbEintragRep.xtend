package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.TbEintrag
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="TB_Eintrag")
class TbEintragRep {

	/** 
	 * Replication-Nr. 1 Attribut Replikation_Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Replikation_Uid: eq isNull
	 * INDEX XRKTB_Eintrag: Replikation_Uid, Mandant_Nr
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Datum")
		@Column(name="Datum", nullable=false)
		public LocalDate datum

		@Column(name="Eintrag", length=-1, nullable=false)
		public String eintrag

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

	/** Suchen des nächsten passenden Eintrags. */
	override public LocalDate sucheDatum(ServiceDaten daten, int stelle, LocalDate aktDatum, String[] suche) {

		var s = stelle
		if (s < Constant.TB_ANFANG || s > Constant.TB_ENDE) {
			s = Constant.TB_ANFANG
		}
		var sql = new SqlBuilder
		sql.append("SELECT ")
		if (s == Constant.TB_ANFANG || s == Constant.TB_VOR) {
			sql.append("MIN(").append(TbEintrag.DATUM_NAME).append(")")
		} else {
			sql.append("MAX(").append(TbEintrag.DATUM_NAME).append(")")
		}
		sql.append(" FROM ").append(TbEintrag.TAB_NAME)
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, TbEintrag.MANDANT_NR_NAME, "=", daten.mandantNr, null)
		if (s == Constant.TB_ZURUECK) {
			sql.append(null, TbEintrag.DATUM_NAME, "<", aktDatum, null)
		}
		if (s == Constant.TB_VOR) {
			sql.append(null, TbEintrag.DATUM_NAME, ">", aktDatum, null)
		}
		sql.praefix(null, null)
		sql.append(" AND (")
		sql.append("(", TbEintrag.EINTRAG_NAME, "like", suche.get(0), null)
		if (suche.get(1) != '') {
			sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(1), null)
		}
		if (suche.get(2) != '') {
			sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(2), null)
		}
		sql.append(")")
		if (suche.get(3) != '') {
			sql.append(" AND (", TbEintrag.EINTRAG_NAME, "like", suche.get(3), null)
			if (suche.get(4) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(4), null)
			}
			if (suche.get(5) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(5), null)
			}
			sql.append(")")
		}
		if (suche.get(6) != '') {
			sql.append(" AND NOT (", TbEintrag.EINTRAG_NAME, "like", suche.get(6), null)
			if (suche.get(7) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(7), null)
			}
			if (suche.get(8) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(8), null)
			}
			sql.append(")")
		}
		sql.append(")")
		var d = convDto(selectOne(daten, sql))
		return d as LocalDate
	}

	/** Lesen aller passenden Einträge. */
	override List<TbEintrag> erzeugeDatei(ServiceDaten daten, String[] suche) {

		var sql = new SqlBuilder
		sql.append("SELECT ").append(columns(null))
		sql.append(" FROM ").append(TbEintrag.TAB_NAME)
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, TbEintrag.MANDANT_NR_NAME, "=", daten.mandantNr, null)
		sql.praefix(null, null)
		sql.append(" AND (")
		sql.append("(", TbEintrag.EINTRAG_NAME, "like", suche.get(0), null)
		if (suche.get(1) != '') {
			sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(1), null)
		}
		if (suche.get(2) != '') {
			sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(2), null)
		}
		sql.append(")")
		if (suche.get(3) != '') {
			sql.append(" AND (", TbEintrag.EINTRAG_NAME, "like", suche.get(3), null)
			if (suche.get(4) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(4), null)
			}
			if (suche.get(5) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(5), null)
			}
			sql.append(")")
		}
		if (suche.get(6) != '') {
			sql.append(" AND NOT (", TbEintrag.EINTRAG_NAME, "like", suche.get(6), null)
			if (suche.get(7) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(7), null)
			}
			if (suche.get(8) != '') {
				sql.append(" OR ", TbEintrag.EINTRAG_NAME, "like", suche.get(8), null)
			}
			sql.append(")")
		}
		sql.append(")")

		return selectList(daten, sql, readDto, typeof(TbEintrag))
	}

}

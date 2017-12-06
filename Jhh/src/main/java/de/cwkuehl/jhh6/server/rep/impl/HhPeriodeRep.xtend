package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HhPeriode
import de.cwkuehl.jhh6.api.dto.HhPeriodeLang
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
@Table(name="HH_Periode")
class HhPeriodeRep {

	/**  
	 * ReplicationCopy
	 * WHERE Mandant_Nr: eq
	 * WHERE Nr: eq ne gt
	 * WHERE Datum_Von: eq le
	 * WHERE Datum_Bis: eq ge
	 * ORDER BY orderPk: Mandant_Nr, Nr DESC
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Nr")
		@Column(name="Nr", nullable=true)
		public int nr

		@Column(name="Datum_Von", nullable=false)
		public LocalDate datumVon

		@Column(name="Datum_Bis", nullable=false)
		public LocalDate datumBis

		@Column(name="Art", nullable=false)
		public int art

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** 
	 */
	static class VoLang {

		@Column(name="a.Nr", nullable=true)
		public int nr

		@Column(name="a.Datum_Von", nullable=false)
		public LocalDate datumVon

		@Column(name="a.Datum_Bis", nullable=false)
		public LocalDate datumBis

		@Column(name="a.Art", nullable=false)
		public int art

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="''", nullable=true)
		public String text

		@Column(name="0.0", nullable=true)
		public double betrag1

		@Column(name="0.0", nullable=true)
		public double betrag2
	}

	/** Periode-Lang-Liste lesen. */
	override List<HhPeriodeLang> getPeriodeLangListe(ServiceDaten daten) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, HhPeriode.NR_NAME, "<>", Constant.PN_BERECHNET, null)
		var order = new SqlBuilder("a.Mandant_Nr, a.Nr DESC")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Periode-Liste lesen. */
	override List<HhPeriode> getPeriodeListe(ServiceDaten daten, LocalDate von, LocalDate bis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.append(null, HhPeriode.NR_NAME, "<>", Constant.PN_BERECHNET, null)
		if (von !== null) {
			sql.append(null, HhPeriode.DATUM_BIS_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, HhPeriode.DATUM_VON_NAME, "<=", bis, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Nr DESC")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Maximale oder minimale Periode lesen, optional vor Anfang bzw. nach Ende. */
	override HhPeriode getMaxMinPeriode(ServiceDaten daten, boolean min, LocalDate d) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		where.append(null, HhPeriode.NR_NAME, "<>", Constant.PN_BERECHNET, null)
		if (d !== null) {
			if (min) {
				where.append(null, HhPeriode.DATUM_BIS_NAME, ">=", d, null)
			} else {
				where.append(null, HhPeriode.DATUM_VON_NAME, "<=", d, null)
			}
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Nr")
		if (!min) {
			order.append(" DESC")
		}
		var sql = selectSql(null, daten.mandantNr, where, order)
		var l = selectOne(daten, sql, readDto, typeof(HhPeriode))
		return l
	}

	/**
	 * Liefert die Nummer der ersten oder letzen Periode.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param min Erste Periodennummer?
	 * @return Nummer der ersten oder letzen Periode.
	 */
	override int getMaxMinPeriodeNr(ServiceDaten daten, boolean min) {

		var p = getMaxMinPeriode(daten, min, null)
		if (p === null) {
			return 0
		}
		return p.nr
	}

	/**
	 * Liefert die Nummer der ersten oder letzen Periode vor Anfang bzw. nach Ende.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param min Erste Periodennummer?
	 * @param d Datum.
	 * @return Nummer der ersten oder letzen Periode.
	 */
	override int getMaxMinNr(ServiceDaten daten, boolean min, LocalDate d) {

		var p = getMaxMinPeriode(daten, min, d)
		if (p === null) {
			return 0
		}
		return p.nr
	}

}

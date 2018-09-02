package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.WpStand
import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.global.Global
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
@Table(name="WP_Stand")
class WpStandRep {

	/** 
	 * ReplicationCopy
	 * WHERE Mandant_Nr: eq
	 * WHERE Wertpapier_Uid: eq
	 * WHERE Datum: eq
	 * ORDER BY DATUM: Mandant_Nr, Wertpapier_Uid, Datum
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Wertpapier_Uid")
		@Column(name="Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@PrimaryKeyJoinColumn(name="Datum")
		@Column(name="Datum", length=35, nullable=false)
		public LocalDate datum

		@Column(name="Stueckpreis", nullable=false)
		public double stueckpreis

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (WP_Stand a
	 *   LEFT JOIN WP_Wertpapier b ON a.Mandant_Nr=b.Mandant_Nr AND a.Wertpapier_Uid=b.Uid)
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@Column(name="a.Datum", length=35, nullable=false)
		public LocalDate datum

		@Column(name="a.Stueckpreis", nullable=false)
		public double stueckpreis

		@Column(name="b.Bezeichnung", length=50, nullable=false)
		public String wertpapierBezeichnung

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Stand-Lang-Liste lesen. */
	override List<WpStandLang> getStandLangListe(ServiceDaten daten, String wpuid, LocalDate von, LocalDate bis, boolean desc) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		if (!Global.nes(wpuid)) {
			where.append(null, WpStand.WERTPAPIER_UID_NAME, "=", wpuid, null)
		}
		if (von !== null) {
			where.append(null, WpStand.DATUM_NAME, ">=", von, null)
		}
		if (bis !== null) {
			where.append(null, WpStand.DATUM_NAME, "<=", bis, null)
		}
		var order = new SqlBuilder(if (desc) "a.Mandant_Nr, b.Bezeichnung, a.Datum DESC" else "a.Mandant_Nr, b.Bezeichnung, a.Datum")
		var l = getListeLang(daten, daten.mandantNr, where, order)
		return l
	}

	/** Letzten Stand lesen. */
	override WpStand getAktStand(ServiceDaten daten, String wpuid, LocalDate datum) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		if (!Global.nes(wpuid)) {
			where.append(null, WpStand.WERTPAPIER_UID_NAME, "=", wpuid, null)
		}
		if (datum !== null) {
			where.append(null, WpStand.DATUM_NAME, "<=", datum, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Wertpapier_Uid, a.Datum desc")
		var sql = selectSql(null, daten.mandantNr, where, order)
		var e = selectOne(daten, sql, readDto, typeof(WpStand))
		return e
	}
}

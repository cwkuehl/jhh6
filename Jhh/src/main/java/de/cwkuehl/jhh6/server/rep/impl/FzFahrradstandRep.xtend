package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.FzFahrradstand
import de.cwkuehl.jhh6.api.dto.FzFahrradstandLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import de.cwkuehl.jhh6.server.rep.impl.FzFahrradRep
import de.cwkuehl.jhh6.server.rep.impl.MaMandantRep
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="FZ_Fahrradstand")
class FzFahrradstandRep {

	/** 
	 * Replication-Nr. 7 Attribut Replikation_Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Fahrrad_Uid: eq
	 * WHERE Datum: eq le ge
	 * WHERE Nr: le
	 * WHERE Beschreibung: like
	 * WHERE Replikation_Uid: eq isNull
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Fahrrad_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(FzFahrradRep))
		@Column(name="Fahrrad_Uid", length=35, nullable=false)
		public String fahrradUid

		@PrimaryKeyJoinColumn(name="Datum")
		@Column(name="Datum", nullable=false)
		public LocalDateTime datum

		@PrimaryKeyJoinColumn(name="Nr")
		@Column(name="Nr", nullable=false)
		public int nr

		@Column(name="Zaehler_km", nullable=false)
		public double zaehlerKm

		@Column(name="Periode_km", nullable=false)
		public double periodeKm

		@Column(name="Periode_Schnitt", nullable=false)
		public double periodeSchnitt

		@Column(name="Beschreibung", length=255, nullable=true)
		public String beschreibung

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

	/** SelectFrom: FZ_Fahrradstand a 
	 *   INNER JOIN FZ_Fahrrad b on a.Mandant_Nr = b.Mandant_Nr and a.Fahrrad_Uid = b.Uid
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Fahrrad_Uid", length=35, nullable=false)
		public String fahrradUid

		@Column(name="a.Datum", nullable=false)
		public LocalDateTime datum

		@Column(name="a.Nr", nullable=false)
		public int nr

		@Column(name="a.Zaehler_km", nullable=false)
		public double zaehlerKm

		@Column(name="a.Periode_km", nullable=false) // SelectSum
		public double periodeKm

		@Column(name="a.Periode_Schnitt", nullable=false)
		public double periodeSchnitt

		@Column(name="a.Beschreibung", length=255, nullable=true)
		public String beschreibung

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Bezeichnung", nullable=true)
		public String fahrradBezeichnung
	}

	/** Fahrradstand-Liste lesen. */
	override List<FzFahrradstand> getFahrradstandListe(ServiceDaten daten, String fuid, LocalDateTime datumge,
		LocalDateTime datumle, boolean desc, int max) {

		var sql = new SqlBuilder
		sql.max = max
		sql.praefix(null, " AND ")
		if (!Global.nes(fuid)) {
			sql.append(null, FzFahrradstand.FAHRRAD_UID_NAME, "=", fuid, null)
		}
		if (datumge !== null) {
			sql.append(null, FzFahrradstand.DATUM_NAME, ">=", datumge, null)
		}
		if (datumle !== null) {
			sql.append(null, FzFahrradstand.DATUM_NAME, "<=", datumle, null)
		}
		var order = new SqlBuilder(if(desc) "a.Mandant_Nr, a.Datum DESC, a.Nr DESC" else "a.Mandant_Nr, a.Datum, a.Nr")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Fahrradstand-Lang-Liste lesen. */
	override List<FzFahrradstandLang> getFahrradstandLangListe(ServiceDaten daten, String fuid, LocalDateTime datum,
		int nr, String besch) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(fuid)) {
			sql.append(null, FzFahrradstand.FAHRRAD_UID_NAME, "=", fuid, null)
		}
		if (datum !== null) {
			sql.append(null, FzFahrradstand.DATUM_NAME, "=", datum, null)
		}
		if (nr >= 0) {
			sql.append(null, FzFahrradstand.NR_NAME, "=", nr, null)
		}
		if (!Global.nesLike(besch)) {
			sql.append(null, FzFahrradstand.BESCHREIBUNG_NAME, "like", besch, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Datum DESC, a.Nr DESC")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Fahrradstand-PeriodeKm-Summe lesen. */
	override double getFahrradstandPeriodeKmSumme(ServiceDaten daten, String fuid, LocalDate datumge,
		LocalDate datumle) {

		var sql = new SqlBuilder('''SELECT SUM(«FzFahrradstand.PERIODE_KM_NAME») FROM «FzFahrradstand.TAB_NAME» a''')
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, "a.Mandant_Nr", "=", daten.mandantNr, null)
		if (!Global.nes(fuid)) {
			sql.append(null, FzFahrradstand.FAHRRAD_UID_NAME, "=", fuid, null)
		}
		if (datumge !== null) {
			sql.append(null, FzFahrradstand.DATUM_NAME, ">=", datumge, null)
		}
		if (datumle !== null) {
			sql.append(null, FzFahrradstand.DATUM_NAME, "<=", datumle, null)
		}
		var sum = selectOne(daten, sql)
		return Global.objDbl(sum)
	}
}

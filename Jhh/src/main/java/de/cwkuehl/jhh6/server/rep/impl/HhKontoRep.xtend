package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.HhKontoVm
import de.cwkuehl.jhh6.api.enums.KontoartEnum
import de.cwkuehl.jhh6.api.enums.KontokennzeichenEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="HH_Konto")
class HhKontoRep {

//	enum KontoartEnum { /** Konto-Art: Aktivkonto. AKTIVKONTO */
//		AK,
//		/** Konto-Art: Passivkonto. PASSIVKONTO */
//		PK,
//		/** Konto-Art: Aufwandskonto. AUFWANDSKONTO */
//		AW,
//		/** Konto-Art: Ertragskonto. ERTRAGSKONTO */
//		ER
//	}
//	enum KontokennzeichenEnum {
//		/** Konto-Kennzeichen: ohne Kennzeichen. OHNE */ _leer,
//		/** Konto-Kennzeichen: Eigenkapital. EIGENKAPITEL */ E,
//		/** Konto-Kennzeichen: Gewinn oder Verlust. GEWINN_VERLUST */ G,
//		/** Konto-Kennzeichen: B. KEN_B */ B,
//		/** Konto-Kennzeichen: D. KEN_D */ D,
//		/** Konto-Kennzeichen: I. KEN_I */ I,
//		/** Konto-Kennzeichen: O. KEN_O */ O
//	}
	/** 
	 * Replication-Nr. 10 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq ne
	 * WHERE Sortierung: eq
	 * WHERE Art: in
	 * WHERE Kz: eq
	 * WHERE Name: eq
	 * WHERE Periode_Von: le
	 * WHERE Periode_Bis: ge
	 * WHERE Gueltig_Von: leOrNull
	 * WHERE Gueltig_Bis: geOrNull
	 * ORDER BY NAME: Mandant_Nr, Name, Uid
	 * ORDER BY SORTIERUNG: Mandant_Nr, Sortierung, Uid
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

		@Column(name="Sortierung", length=10, nullable=false)
		public String sortierung

		@Column(name="Art", length=2, nullable=false)
		// public KontoartEnum art
		public String art

		@Column(name="Kz", length=1, nullable=true)
		// public KontokennzeichenEnum kz
		public String kz

		@Column(name="Name", length=50, nullable=false)
		public String name

		@Column(name="Gueltig_Von", nullable=true)
		public LocalDate gueltigVon

		@Column(name="Gueltig_Bis", nullable=true)
		public LocalDate gueltigBis

		@Column(name="Periode_Von", nullable=false)
		public int periodeVon

		@Column(name="Periode_Bis", nullable=false)
		public int periodeBis

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="EBetrag", nullable=false)
		public double ebetrag

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (((HH_Konto a
	 *   left join VM_Konto b on a.Mandant_Nr=b.Mandant_Nr and a.Uid=b.Uid)
	 *   left join VM_Haus c on b.Mandant_Nr=c.Mandant_Nr and b.Haus_Uid=c.Uid)
	 *   left join VM_Wohnung d on b.Mandant_Nr= d.Mandant_Nr and b.Wohnung_Uid=d.Uid)
	 *   left join VM_Mieter e on b.Mandant_Nr=e.Mandant_Nr and b.Mieter_Uid=e.Uid
	 *  SelectOrderBy: a.Mandant_Nr, b.Schluessel, a.Uid
	 */
	static class VoVm {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Art", nullable=false)
		public KontoartEnum art

		@Column(name="a.Kz", nullable=true)
		public KontokennzeichenEnum kz

		@Column(name="a.Name", length=50, nullable=false)
		public String name

		@Column(name="a.Gueltig_Von", nullable=true)
		public LocalDate gueltigVon

		@Column(name="a.Gueltig_Bis", nullable=true)
		public LocalDate gueltigBis

		@Column(name="a.Periode_Von", nullable=false)
		public int periodeVon

		@Column(name="a.Periode_Bis", nullable=false)
		public int periodeBis

		@Column(name="a.Betrag", nullable=false)
		public double betrag

		@Column(name="a.EBetrag", nullable=false)
		public double ebetrag

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Schluessel", nullable=true)
		public String schluessel

		@Column(name="b.Haus_Uid", nullable=true)
		public String hausUid

		@Column(name="b.Wohnung_Uid", nullable=true)
		public String wohnungUid

		@Column(name="b.Mieter_Uid", nullable=true)
		public String mieterUid

		@Column(name="b.Notiz", nullable=true)
		public String notiz

		@Column(name="c.Bezeichnung", nullable=true)
		public String hausBezeichnung

		@Column(name="d.Bezeichnung", nullable=true)
		public String wohnungBezeichnung

		@Column(name="e.Name", nullable=true)
		public String mieterName
	}

	/** Konto-Liste lesen. */
	override List<HhKonto> getKontoListe(ServiceDaten daten, int perVonLe, int perBisGe, String art1, String art2,
		LocalDate vonle, LocalDate bisge) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (perVonLe >= 0) {
			sql.append(null, HhKonto.PERIODE_VON_NAME, "<=", perVonLe, null)
		}
		if (perBisGe >= 0) {
			sql.append(null, HhKonto.PERIODE_BIS_NAME, ">=", perBisGe, null)
		}
		if (art1 !== null && art2 !== null) {
			sql.append("(", HhKonto.ART_NAME, "=", art1, null)
			sql.append(" OR ", HhKonto.ART_NAME, "=", art2, ")", true)
		} else if (art1 !== null) {
			sql.append(null, HhKonto.ART_NAME, "=", art1, null)
		}
		if (vonle !== null) {
			sql.append("(", "Gueltig_Von IS NULL OR Gueltig_Von", "<=", vonle, ")")
		}
		if (bisge !== null) {
			sql.append("(", "Gueltig_Bis IS NULL OR Gueltig_Bis", ">=", bisge, ")")
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Name, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Konto-Vm-Liste lesen. */
	override List<HhKontoVm> getKontoVmListe(ServiceDaten daten, String uid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, HhKonto.UID_NAME, "=", uid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Name, a.Uid")
		var l = getListeVm(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Minimales Konto-Uid nach Kennzeichen. */
	override String getMinKonto(ServiceDaten daten, String kontoUid, String kz, String sort, String name) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			where.append(null, HhKonto.UID_NAME, "<>", kontoUid, null)
		}
		if (kz !== null) {
			where.append(null, HhKonto.KZ_NAME, "=", kz, null)
		}
		if (!Global.nes(sort)) {
			where.append(null, HhKonto.SORTIERUNG_NAME, "=", sort, null)
		}
		if (!Global.nes(name)) {
			where.append(null, HhKonto.NAME_NAME, "=", name, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Uid")
		var sql = selectSql(null, daten.mandantNr, where, order)
		var e = selectOne(daten, sql, readDto, typeof(HhKonto))
		if (e === null) {
			return null
		}
		return e.uid
	}

	override String findKontoSortierung(ServiceDaten daten, String uid) {

		var String sort = null
		while (Global.nes(sort)) {
			sort = Global.fixiereString(Global.objStr(Global.getNextRandom()), HhKonto.SORTIERUNG_LAENGE, false, "0")
			var k = getMinKonto(daten, uid, null, sort, null)
			if (k !== null) {
				sort = null
			}
		}
		return sort
	}
}

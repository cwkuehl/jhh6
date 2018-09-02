package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HhBuchung
import de.cwkuehl.jhh6.api.dto.HhBuchungHaben
import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhBuchungSoll
import de.cwkuehl.jhh6.api.dto.HhBuchungVm
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
@Table(name="HH_Buchung")
class HhBuchungRep {

	/** 
	 * Replication-Nr. 12 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Soll_Valuta: gt lt ge le eq
	 * WHERE Haben_Valuta: gt lt ge le
	 * WHERE Soll_Konto_Uid: eq
	 * WHERE Haben_Konto_Uid: eq
	 * WHERE Kz: eq
	 * WHERE BText: like
	 * WHERE Betrag: eq
	 * WHERE EBetrag: eq
	 * WHERE Beleg_Nr: notNull
	 * WHERE Beleg_Datum: eq
	 * WHERE OR Konto_Uid: Soll_Konto_Uid Haben_Konto_Uid: eq
	 * WHERE OR Revision: Angelegt_Am Geaendert_Am: ge lt
	 * ORDER BY VALUTA: Mandant_Nr, Soll_Valuta DESC, Uid DESC
	 * ORDER BY BELEG: Mandant_Nr, Beleg_Nr DESC, Uid DESC
	 * ORDER BY VALUTA_BELEG: Mandant_Nr, Soll_Valuta, Beleg_Nr, Uid
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

		@Column(name="Soll_Valuta", nullable=false)
		public LocalDate sollValuta

		@Column(name="Haben_Valuta", nullable=false)
		public LocalDate habenValuta

		@Column(name="Kz", length=1, nullable=true)
		public String kz

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="EBetrag", nullable=false)
		public double ebetrag

		@Column(name="Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="BText", length=100, nullable=false)
		public String btext

		@Column(name="Beleg_Nr", length=50, nullable=true)
		public String belegNr

		@Column(name="Beleg_Datum", nullable=false)
		public LocalDate belegDatum

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (HH_Buchung a
	 *   inner join HH_Konto b on a.Mandant_Nr=b.Mandant_Nr and a.Soll_Konto_Uid=b.Uid)
	 *   inner join HH_Konto c on a.Mandant_Nr=c.Mandant_Nr and a.Haben_Konto_Uid=c.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Soll_Valuta", nullable=false)
		public LocalDate sollValuta

		@Column(name="a.Haben_Valuta", nullable=false)
		public LocalDate habenValuta

		@Column(name="a.Kz", length=1, nullable=true)
		public String kz

		@Column(name="a.Betrag", nullable=false)
		public double betrag

		@Column(name="a.EBetrag", nullable=false)
		public double ebetrag

		@Column(name="a.Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="a.Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="a.BText", length=100, nullable=false)
		public String btext

		@Column(name="a.Beleg_Nr", length=50, nullable=true)
		public String belegNr

		@Column(name="a.Beleg_Datum", nullable=false)
		public LocalDate belegDatum

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Name", nullable=true)
		public String sollName

		@Column(name="c.Name", nullable=true)
		public String habenName

		@Column(name="b.Art", nullable=true) // Where:  eq
		public String sollArt

		@Column(name="c.Art", nullable=true) // Where:  eq
		public String habenArt
	}

	/** SelectFrom: HH_Buchung a inner join HH_Konto b
	 *   on a.Mandant_Nr = b.Mandant_Nr and a.Haben_Konto_Uid = b.Uid
	 *  SelectOrderBy: b.Uid, b.Art
	 *  SelectGroupBy: b.Uid, b.Art */
	static class VoHaben {

		@Column(name="b.Uid", nullable=true)
		public String uid

		@Column(name="b.Art", nullable=true)
		public String art

		@Column(name="SUM(a.Betrag)", nullable=true)
		public double summe

		@Column(name="SUM(a.EBetrag)", nullable=true)
		public double esumme
	}

	/** SelectFrom: HH_Buchung a inner join HH_Konto b
	 *   on a.Mandant_Nr = b.Mandant_Nr and a.Soll_Konto_Uid = b.Uid
	 *  SelectOrderBy: b.Uid, b.Art
	 *  SelectGroupBy: b.Uid, b.Art */
	static class VoSoll {

		@Column(name="b.Uid", nullable=true)
		public String uid

		@Column(name="b.Art", nullable=true)
		public String art

		@Column(name="-SUM(a.Betrag)", nullable=true)
		public double summe

		@Column(name="-SUM(a.EBetrag)", nullable=true)
		public double esumme
	}

	/** SelectFrom: (((((HH_Buchung a
	 *   left join VM_Buchung b on a.Mandant_Nr=b.Mandant_Nr and a.Uid=b.Uid)
	 *   left join VM_Haus c on b.Mandant_Nr=c.Mandant_Nr and b.Haus_Uid=c.Uid)
	 *   left join VM_Wohnung d on b.Mandant_Nr= d.Mandant_Nr and b.Wohnung_Uid=d.Uid)
	 *   left join VM_Mieter e on b.Mandant_Nr=e.Mandant_Nr and b.Mieter_Uid=e.Uid)
	 *   inner join HH_Konto f on a.Mandant_Nr=f.Mandant_Nr and a.Soll_Konto_Uid=f.Uid)
	 *   inner join HH_Konto g on a.Mandant_Nr=g.Mandant_Nr and a.Haben_Konto_Uid=g.Uid
	 */
	static class VoVm {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Soll_Valuta", nullable=false)
		public LocalDate sollValuta

		@Column(name="a.Haben_Valuta", nullable=false)
		public LocalDate habenValuta

		@Column(name="a.Kz", length=1, nullable=true)
		public String kz

		@Column(name="a.Betrag", nullable=false)
		public double betrag

		@Column(name="a.EBetrag", nullable=false)
		public double ebetrag

		@Column(name="a.Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="a.Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="a.BText", length=100, nullable=false)
		public String btext

		@Column(name="a.Beleg_Nr", length=50, nullable=true)
		public String belegNr

		@Column(name="a.Beleg_Datum", nullable=false)
		public LocalDate belegDatum

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Schluessel", nullable=true) // Where:  eq
		public String schluessel

		@Column(name="b.Haus_Uid", nullable=true) // Where:  eq
		public String hausUid

		@Column(name="b.Wohnung_Uid", nullable=true) // Where:  eq
		public String wohnungUid

		@Column(name="b.Mieter_Uid", nullable=true) // Where:  eq
		public String mieterUid

		@Column(name="b.Notiz", nullable=true)
		public String notiz

		@Column(name="c.Bezeichnung", nullable=true)
		public String hausBezeichnung

		@Column(name="d.Bezeichnung", nullable=true)
		public String wohnungBezeichnung

		@Column(name="e.Name", nullable=true)
		public String mieterName

		@Column(name="f.Name", nullable=true)
		public String sollName

		@Column(name="g.Name", nullable=true)
		public String habenName
	}

	override int countKontoValutaVorNach(ServiceDaten daten, String kontoUid, LocalDate vor, LocalDate nach,
		String ken) {

		var von = nach
		if (von !== null) {
			von = von.plusDays(1)
		}
		var bis = vor
		if (bis !== null) {
			bis = bis.minusDays(1)
		}
		var l = getBuchungListe(daten, kontoUid, von, bis, ken)
		var anzahl = l.size
		return anzahl
	}

	override List<HhBuchung> getBuchungListe(ServiceDaten daten, String kontoUid, LocalDate von, LocalDate bis,
		String ken) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhBuchung.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhBuchung.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		if (!Global.nes(ken)) {
			sql.append(null, HhBuchung.KZ_NAME, "=", ken, null)
		}
		if (von !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, "<=", bis, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Soll_Valuta, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	override List<HhBuchungSoll> getBuchungSollListe(ServiceDaten daten, String kontoUid, LocalDate von, LocalDate bis,
		String ken) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBuchung.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
		}
		if (!Global.nes(ken)) {
			sql.append(null, HhBuchung.KZ_NAME, "=", ken, null)
		}
		if (von !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, "<=", bis, null)
		}
		var l = getListeSoll(daten, daten.mandantNr, sql, null)
		return l
	}

	override List<HhBuchungHaben> getBuchungHabenListe(ServiceDaten daten, String kontoUid, LocalDate von,
		LocalDate bis, String ken) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBuchung.HABEN_KONTO_UID_NAME, "=", kontoUid, null)
		}
		if (!Global.nes(ken)) {
			sql.append(null, HhBuchung.KZ_NAME, "=", ken, null)
		}
		if (von !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, HhBuchung.SOLL_VALUTA_NAME, "<=", bis, null)
		}
		var l = getListeHaben(daten, daten.mandantNr, sql, null)
		return l
	}

	override List<HhBuchungLang> getBuchungLangListe(ServiceDaten daten, boolean euro, boolean valutasuche,
		LocalDate von, LocalDate bis, String text, String kontoUid, String betrag, String ken, boolean desc) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (von !== null) {
			if (valutasuche) {
				sql.append(null, HhBuchung.SOLL_VALUTA_NAME, ">=", von, null)
			} else {
				sql.append("(", HhBuchung.ANGELEGT_AM_NAME, ">=", von, null)
				sql.append(" OR ", HhBuchung.GEAENDERT_AM_NAME, ">=", von, ")", true)
			}
		}
		if (bis !== null) {
			if (valutasuche) {
				sql.append(null, HhBuchung.SOLL_VALUTA_NAME, "<=", bis, null)
			} else {
				sql.append("(", HhBuchung.ANGELEGT_AM_NAME, "<=", bis, null)
				sql.append(" OR ", HhBuchung.GEAENDERT_AM_NAME, "<=", bis, ")", true)
			}
		}
		if (!Global.nesLike(text)) {
			sql.append(null, HhBuchung.BTEXT_NAME, "like", text, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhBuchung.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhBuchung.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		if (!Global.nes(betrag)) {
			if (euro) {
				sql.append(null, HhBuchung.EBETRAG_NAME, "=", Global.strDbl(betrag), null)
			} else {
				sql.append(null, HhBuchung.BETRAG_NAME, "=", Global.strDbl(betrag), null)
			}
		}
		if (!Global.nes(ken)) {
			sql.append(null, HhBuchung.KZ_NAME, "=", ken, null)
		}
		var order = new SqlBuilder(
			if(desc) "a.Mandant_Nr, a.Soll_Valuta desc, a.Beleg_Nr desc, a.Uid desc" else "a.Mandant_Nr, a.Soll_Valuta, a.Beleg_Nr, a.Uid"
		)
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	override List<HhBuchungVm> getBuchungVmListe(ServiceDaten daten, boolean euro, boolean vsuche, String uid,
		LocalDate von, LocalDate bis, String text, String kontoUid, String betrag, String ken, String schluessel,
		String huid, String wuid, String muid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, HhBuchung.UID_NAME, "=", uid, null)
		}
		if (von !== null) {
			if (vsuche) {
				sql.append(null, HhBuchung.SOLL_VALUTA_NAME, ">=", von, null)
			} else {
				sql.append("(", HhBuchung.ANGELEGT_AM_NAME, ">=", von, null)
				sql.append(" OR ", HhBuchung.GEAENDERT_AM_NAME, ">=", von, ")", true)
			}
		}
		if (bis !== null) {
			if (vsuche) {
				sql.append(null, HhBuchung.SOLL_VALUTA_NAME, "<=", bis, null)
			} else {
				sql.append("(", HhBuchung.ANGELEGT_AM_NAME, "<=", bis, null)
				sql.append(" OR ", HhBuchung.GEAENDERT_AM_NAME, "<=", bis, ")", true)
			}
		}
		if (!Global.nesLike(text)) {
			sql.append(null, HhBuchung.BTEXT_NAME, "like", text, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhBuchung.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhBuchung.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		if (!Global.nes(betrag)) {
			if (euro) {
				sql.append(null, HhBuchung.EBETRAG_NAME, "=", Global.strDbl(betrag), null)
			} else {
				sql.append(null, HhBuchung.BETRAG_NAME, "=", Global.strDbl(betrag), null)
			}
		}
		if (!Global.nes(ken)) {
			sql.append(null, HhBuchung.KZ_NAME, "=", ken, null)
		}
		if (!Global.nes(schluessel)) {
			sql.append(null, "b.Schluessel", "=", schluessel, null)
		}
		if (!Global.nes(huid)) {
			sql.append(null, "b.Haus_Uid", "=", huid, null)
		}
		if (!Global.nes(wuid)) {
			sql.append(null, "b.Wohnung_Uid", "=", wuid, null)
		}
		if (!Global.nes(muid)) {
			sql.append(null, "b.Mieter_Uid", "=", muid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Soll_Valuta, a.Beleg_Nr, a.Uid")
		var l = getListeVm(daten, daten.mandantNr, sql, order)
		return l
	}

	override HhBuchung getBuchungMaxMin(ServiceDaten daten, String kontoUid, boolean min) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			where.append("(", HhBuchung.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			where.append(" OR ", HhBuchung.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Soll_Valuta")
		if (!min) {
			order.append(" DESC")
		}
		var sql = selectSql(null, daten.mandantNr, where, order)
		var e = selectOne(daten, sql, readDto, typeof(HhBuchung))
		return e
	}

	/** Buchung mit höchster Belegnummer. */
	override HhBuchung getLetzteBelegnummer(ServiceDaten daten, LocalDate d) {

		var where = new SqlBuilder
		where.praefix(null, " AND ")
		where.append("NOT (a.Beleg_Nr IS NULL OR a.Beleg_Nr='')")
		if (d !== null) {
			where.append(null, HhBuchung.BELEG_DATUM_NAME, "=", d, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Beleg_Nr DESC, a.Uid DESC")
		var sql = selectSql(null, daten.mandantNr, where, order)
		var e = selectOne(daten, sql, readDto, typeof(HhBuchung))
		return e
	}

}

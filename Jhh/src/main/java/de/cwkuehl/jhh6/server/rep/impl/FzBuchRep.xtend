package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.FzBuch
import de.cwkuehl.jhh6.api.dto.FzBuchLang
import de.cwkuehl.jhh6.api.dto.FzBuchstatus
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
@Table(name="FZ_Buch")
class FzBuchRep {

	/** 
	 * Replication-Nr. 32 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Autor_Uid: eq
	 * WHERE Serie_Uid: eq ne
	 * WHERE Seriennummer: eq
	 * WHERE Titel: like
	 * WHERE Sprache_Nr: eq
	 * WHERE Angelegt_Am: le
	 * ORDER BY SERIE_TITEL: Mandant_Nr, Serie_Uid DESC, Seriennummer DESC, Titel
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=false)
		public String uid

		@Column(name="Autor_Uid", length=35, nullable=false)
		public String autorUid

		@Column(name="Serie_Uid", length=35, nullable=false)
		public String serieUid

		@Column(name="Seriennummer", nullable=false)
		public int seriennummer

		@Column(name="Titel", length=100, nullable=false)
		public String titel

		@Column(name="Seiten", nullable=false)
		public int seiten

		@Column(name="Sprache_Nr", nullable=false)
		public int spracheNr

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: ((FZ_Buch a 
	 *   LEFT JOIN FZ_Buchautor b on a.Mandant_Nr = b.Mandant_Nr and a.Autor_Uid = b.Uid)
	 *   LEFT JOIN FZ_Buchserie c on a.Mandant_Nr = c.Mandant_Nr and a.Serie_Uid = c.Uid)
	 *   LEFT JOIN FZ_Buchstatus d on a.Mandant_Nr = d.Mandant_Nr and a.Uid = d.Buch_Uid
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=false)
		public String uid

		@Column(name="a.Autor_Uid", length=35, nullable=false)
		public String autorUid

		@Column(name="a.Serie_Uid", length=35, nullable=false)
		public String serieUid

		@Column(name="a.Seriennummer", nullable=false)
		public int seriennummer

		@Column(name="a.Titel", length=100, nullable=false)
		public String titel

		@Column(name="a.Seiten", nullable=false) // SelectSum
		public int seiten

		@Column(name="a.Sprache_Nr", nullable=false)
		public int spracheNr

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Name", nullable=true)
		public String autorName

		@Column(name="b.Vorname", nullable=true)
		public String autorVorname

		@Column(name="c.Name", nullable=true)
		public String serieName

		@Column(name="''", nullable=true)
		public String sprache

		@Column(name="d.Ist_Besitz", nullable=true)
		public boolean istBesitz

		@Column(name="d.Lesedatum", nullable=true) // Where:  le
		public LocalDate lesedatum

		@Column(name="d.Hoerdatum", nullable=true) // Where:  le
		public LocalDate hoerdatum
	}

	/** Buch-Lang-Liste lesen. */
	override List<FzBuchLang> getBuchLangListe(ServiceDaten daten, String uid, String auid, String suid, String name,
		int snr, int max) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		sql.max = max
		if (!Global.nes(uid)) {
			sql.append(null, FzBuch.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(auid)) {
			sql.append(null, FzBuch.AUTOR_UID_NAME, "=", auid, null)
		}
		if (!Global.nes(suid)) {
			sql.append(null, FzBuch.SERIE_UID_NAME, "=", suid, null)
		}
		if (!Global.nesLike(name)) {
			sql.append(null, FzBuch.TITEL_NAME, "like", name, null)
		}
		if (snr > 0) {
			sql.append(null, FzBuch.SERIENNUMMER_NAME, "=", snr, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Serie_Uid DESC, a.Seriennummer DESC, a.Titel")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Buch-Lang-Anzahl lesen. */
	override int getBuchLangAnzahl(ServiceDaten daten, int sprachenr, String suid, String suidne,
		LocalDate angelegtamle, LocalDate lesedatumle, LocalDate hoerdatumle) {

		var sql = new SqlBuilder('''SELECT COUNT(*) FROM ((FZ_Buch a 
			LEFT JOIN FZ_Buchautor b on a.Mandant_Nr = b.Mandant_Nr and a.Autor_Uid = b.Uid)
			LEFT JOIN FZ_Buchserie c on a.Mandant_Nr = c.Mandant_Nr and a.Serie_Uid = c.Uid)
			LEFT JOIN FZ_Buchstatus d on a.Mandant_Nr = d.Mandant_Nr and a.Uid = d.Buch_Uid''')
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, "a.Mandant_Nr", "=", daten.mandantNr, null)
		if (sprachenr >= 0) {
			sql.append(null, FzBuch.SPRACHE_NR_NAME, "=", sprachenr, null)
		}
		if (!Global.nes(suid)) {
			sql.append(null, FzBuch.SERIE_UID_NAME, "=", suid, null)
		}
		if (!Global.nes(suidne)) {
			sql.append(null, FzBuch.SERIE_UID_NAME, "<>", suidne, null)
		}
		if (angelegtamle !== null) {
			sql.append(null, "a.Angelegt_Am", "<=", angelegtamle, null)
		}
		if (lesedatumle !== null) {
			sql.append(null, FzBuchstatus.LESEDATUM_NAME, "<=", lesedatumle, null)
		}
		if (hoerdatumle !== null) {
			sql.append(null, FzBuchstatus.HOERDATUM_NAME, "<=", hoerdatumle, null)
		}
		var anz = selectOne(daten, sql)
		return Global.objInt(anz)
	}

	/** Buch-Lang-Seiten-Summe lesen. */
	override double getBuchLangSeitenSumme(ServiceDaten daten, int sprachenr, String suid, String suidne,
		LocalDate angelegtamle, LocalDate lesedatumle, LocalDate hoerdatumle) {

		var sql = new SqlBuilder('''SELECT SUM(Seiten) FROM ((FZ_Buch a 
			LEFT JOIN FZ_Buchautor b on a.Mandant_Nr = b.Mandant_Nr and a.Autor_Uid = b.Uid)
			LEFT JOIN FZ_Buchserie c on a.Mandant_Nr = c.Mandant_Nr and a.Serie_Uid = c.Uid)
			LEFT JOIN FZ_Buchstatus d on a.Mandant_Nr = d.Mandant_Nr and a.Uid = d.Buch_Uid''')
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, "a.Mandant_Nr", "=", daten.mandantNr, null)
		if (sprachenr >= 0) {
			sql.append(null, FzBuch.SPRACHE_NR_NAME, "=", sprachenr, null)
		}
		if (!Global.nes(suid)) {
			sql.append(null, FzBuch.SERIE_UID_NAME, "=", suid, null)
		}
		if (!Global.nes(suidne)) {
			sql.append(null, FzBuch.SERIE_UID_NAME, "<>", suidne, null)
		}
		if (angelegtamle !== null) {
			sql.append(null, "a.Angelegt_Am", "<=", angelegtamle, null)
		}
		if (lesedatumle !== null) {
			sql.append(null, FzBuchstatus.LESEDATUM_NAME, "<=", lesedatumle, null)
		}
		if (hoerdatumle !== null) {
			sql.append(null, FzBuchstatus.HOERDATUM_NAME, "<=", hoerdatumle, null)
		}
		var sum = selectOne(daten, sql)
		return Global.objDbl(sum)
	}
}

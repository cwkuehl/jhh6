package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HhEreignis
import de.cwkuehl.jhh6.api.dto.HhEreignisLang
import de.cwkuehl.jhh6.api.dto.HhEreignisVm
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
@Table(name="HH_Ereignis")
class HhEreignisRep {

	/** 
	 * Replication-Nr. 8 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Soll_Konto_Uid: eq
	 * WHERE Haben_Konto_Uid: eq
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung
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

		@Column(name="Kz", length=1, nullable=true)
		public String kz

		@Column(name="Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="EText", length=100, nullable=false)
		public String etext

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (HH_Ereignis a
	 *   left join HH_Konto b on a.Mandant_Nr=b.Mandant_Nr and a.Soll_Konto_Uid=b.Uid)
	 *   left join HH_Konto c on a.Mandant_Nr=c.Mandant_Nr and a.Haben_Konto_Uid=c.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Kz", length=1, nullable=true)
		public String kz

		@Column(name="a.Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="a.Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="a.Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="a.EText", length=100, nullable=false)
		public String etext

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

		@Column(name="b.Gueltig_Von", nullable=true) // Where:  leOrNull
		public LocalDate sollGueltigVon

		@Column(name="b.Gueltig_Bis", nullable=true) // Where:  geOrNull
		public LocalDate sollGueltigBis

		@Column(name="c.Name", nullable=true)
		public String habenName

		@Column(name="c.Gueltig_Von", nullable=true) // Where:  leOrNull
		public LocalDate habenGueltigVon

		@Column(name="c.Gueltig_Bis", nullable=true) // Where:  geOrNull
		public LocalDate habenGueltigBis
	}

	/** SelectFrom: (((((HH_Ereignis a
	 *   left join VM_Ereignis b on a.Mandant_Nr=b.Mandant_Nr and a.Uid=b.Uid)
	 *   left join VM_Haus c on b.Mandant_Nr=c.Mandant_Nr and b.Haus_Uid=c.Uid)
	 *   left join VM_Wohnung d on b.Mandant_Nr= d.Mandant_Nr and b.Wohnung_Uid=d.Uid)
	 *   left join VM_Mieter e on b.Mandant_Nr=e.Mandant_Nr and b.Mieter_Uid=e.Uid)
	 *   left join HH_Konto f on a.Mandant_Nr=f.Mandant_Nr and a.Soll_Konto_Uid=f.Uid)
	 *   left join HH_Konto g on a.Mandant_Nr=g.Mandant_Nr and a.Haben_Konto_Uid=g.Uid
	 *  SelectOrderBy: a.Mandant_Nr, a.Bezeichnung, a.Uid
	 */
	static class VoVm {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Kz", length=1, nullable=true)
		public String kz

		@Column(name="a.Soll_Konto_Uid", length=35, nullable=false)
		public String sollKontoUid

		@Column(name="a.Haben_Konto_Uid", length=35, nullable=false)
		public String habenKontoUid

		@Column(name="a.Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="a.EText", length=100, nullable=false)
		public String etext

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

		@Column(name="f.Gueltig_Von", nullable=true) // Where:  leOrNull
		public LocalDate sollGueltigVonVm

		@Column(name="f.Gueltig_Bis", nullable=true) // Where:  geOrNull
		public LocalDate sollGueltigBisVm

		@Column(name="g.Name", nullable=true)
		public String habenName

		@Column(name="g.Gueltig_Von", nullable=true) // Where:  leOrNull
		public LocalDate habenGueltigVonVm

		@Column(name="g.Gueltig_Bis", nullable=true) // Where:  geOrNull
		public LocalDate habenGueltigBisVm
	}

	override List<HhEreignis> getEreignisListe(ServiceDaten daten, String kontoUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhEreignis.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhEreignis.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	override List<HhEreignisLang> getEreignisLangListe(ServiceDaten daten, String kontoUid, LocalDate von,
		LocalDate bis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhEreignis.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhEreignis.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		if (von !== null) {
			sql.append("(", "b.Gueltig_Von IS NULL OR b.Gueltig_Von", "<=", von, ")")
			sql.append("(", "c.Gueltig_Von IS NULL OR c.Gueltig_Von", "<=", von, ")")
		}
		if (bis !== null) {
			sql.append("(", "b.Gueltig_Bis IS NULL OR b.Gueltig_Bis", ">=", bis, ")")
			sql.append("(", "c.Gueltig_Bis IS NULL OR c.Gueltig_Bis", ">=", bis, ")")
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	override List<HhEreignisVm> getEreignisVmListe(ServiceDaten daten, String uid, String kontoUid, LocalDate von, LocalDate bis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, HhEreignis.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append("(", HhEreignis.SOLL_KONTO_UID_NAME, "=", kontoUid, null)
			sql.append(" OR ", HhEreignis.HABEN_KONTO_UID_NAME, "=", kontoUid, ")", true)
		}
		if (von !== null) {
			sql.append("(", "f.Gueltig_Von IS NULL OR f.Gueltig_Von", "<=", von, ")")
			sql.append("(", "g.Gueltig_Von IS NULL OR g.Gueltig_Von", "<=", von, ")")
		}
		if (bis !== null) {
			sql.append("(", "f.Gueltig_Bis IS NULL OR f.Gueltig_Bis", ">=", bis, ")")
			sql.append("(", "g.Gueltig_Bis IS NULL OR g.Gueltig_Bis", ">=", bis, ")")
		}
		var l = getListeVm(daten, daten.mandantNr, sql, null)
		return l
	}
}

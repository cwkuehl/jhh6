package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.WpBuchung
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
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
@Table(name="WP_Buchung")
class WpBuchungRep {

	/** 
	 * Replication-Nr. 50 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Uid
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

		@ManyToOne(targetEntity=typeof(WpWertpapierRep))
		@Column(name="Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@ManyToOne(targetEntity=typeof(WpAnlageRep))
		@Column(name="Anlage_Uid", length=35, nullable=false)
		public String anlageUid

		@Column(name="Datum", nullable=false)
		public LocalDate datum

		@Column(name="Zahlungsbetrag", nullable=false)
		public double zahlungsbetrag

		@Column(name="Rabattbetrag", nullable=false)
		public double rabattbetrag

		@Column(name="Anteile", nullable=false)
		public double anteile

		@Column(name="Zinsen", nullable=false)
		public double zinsen

		@Column(name="BText", length=100, nullable=false)
		public String btext

		@Column(name="Notiz", length=-1, nullable=true)
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

	/** SelectFrom: (((WP_Buchung a
	 *   LEFT JOIN WP_Wertpapier b ON a.Mandant_Nr=b.Mandant_Nr AND a.Wertpapier_Uid=b.Uid)
	 *   LEFT JOIN WP_Anlage c ON a.Mandant_Nr=c.Mandant_Nr AND a.Anlage_Uid=c.Uid)
	 *   LEFT JOIN WP_Stand d ON a.Mandant_Nr=d.Mandant_Nr AND a.Wertpapier_Uid=d.Wertpapier_Uid AND a.Datum=d.Datum)
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@Column(name="a.Anlage_Uid", length=35, nullable=false)
		public String anlageUid

		@Column(name="a.Datum", nullable=false)
		public LocalDate datum

		@Column(name="a.Zahlungsbetrag", nullable=false)
		public double zahlungsbetrag

		@Column(name="a.Rabattbetrag", nullable=false)
		public double rabattbetrag

		@Column(name="a.Anteile", nullable=false)
		public double anteile

		@Column(name="a.Zinsen", nullable=false)
		public double zinsen

		@Column(name="a.BText", length=100, nullable=false)
		public String btext

		@Column(name="a.Notiz", nullable=true)
		public String notiz

		@Column(name="b.Bezeichnung", length=50, nullable=false)
		public String wertpapierBezeichnung

		@Column(name="c.Bezeichnung", length=50, nullable=false)
		public String anlageBezeichnung

		@Column(name="d.Stueckpreis", nullable=true)
		public double stand

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Buchung-Lang-Liste lesen. */
	override List<WpBuchungLang> getBuchungLangListe(ServiceDaten daten, String btext, String uid,
		String wpuid, String auid, LocalDate von, LocalDate bis, boolean desc) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(btext)) {
			sql.append(null, WpBuchung.BTEXT_NAME, "like", btext, null)
		}
		if (!Global.nes(uid)) {
			sql.append(null, WpBuchung.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(wpuid)) {
			sql.append(null, WpBuchung.WERTPAPIER_UID_NAME, "=", wpuid, null)
		}
		if (!Global.nes(auid)) {
			sql.append(null, WpBuchung.ANLAGE_UID_NAME, "=", auid, null)
		}
		if (von !== null) {
			sql.append(null, WpBuchung.DATUM_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, WpBuchung.DATUM_NAME, "<=", bis, null)
		}
		var order = new SqlBuilder(if (desc) "a.Mandant_Nr, a.Datum DESC, a.Uid" else "a.Mandant_Nr, a.Datum, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

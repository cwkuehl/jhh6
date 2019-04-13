package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.WpWertpapier
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.enums.WpStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="WP_Wertpapier")
class WpWertpapierRep {

	/** 
	 * Replication-Nr. 46 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq ne
	 * WHERE Bezeichnung: like
	 * WHERE Parameter: like
	 * WHERE Relation_Uid: eq
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung, Uid
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

		@Column(name="Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="Kuerzel", length=20, nullable=false)
		public String kuerzel

		@Column(name="Parameter", length=-1, nullable=true)
		public String parameter

		@Column(name="Datenquelle", length=35, nullable=false)
		public String datenquelle

		@Column(name="Status", length=10, nullable=false)
		public String status

		@Column(name="Relation_Uid", length=35, nullable=true)
		public String relationUid

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

	/** SelectFrom: (WP_Wertpapier a
	 *   LEFT JOIN WP_Wertpapier b ON a.Mandant_Nr=b.Mandant_Nr AND a.Relation_Uid=b.Uid)
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="a.Kuerzel", length=10, nullable=false)
		public String kuerzel

		@Column(name="a.Parameter", nullable=true)
		public String parameter

		@Column(name="a.Datenquelle", length=35, nullable=false)
		public String datenquelle

		@Column(name="a.Status", length=10, nullable=false)
		public String status

		@Column(name="a.Relation_Uid", length=35, nullable=true)
		public String relationUid

		@Column(name="a.Notiz", nullable=true)
		public String notiz

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Bezeichnung", nullable=true)
		public String relationBezeichnung

		@Column(name="b.Datenquelle", nullable=true)
		public String relationDatenquelle

		@Column(name="b.Kuerzel", nullable=true)
		public String relationKuerzel

		@Column(name="''", nullable=true)
		public String bewertung1

		@Column(name="''", nullable=true)
		public String bewertung2

		@Column(name="''", nullable=true)
		public String bewertung3

		@Column(name="''", nullable=true)
		public String bewertung4

		@Column(name="''", nullable=true)
		public String bewertung5

		@Column(name="''", nullable=true)
		public String bewertung

		@Column(name="''", nullable=true)
		public String aktuellerkurs

		@Column(name="0.0", nullable=true)
		public double signalkurs1

		@Column(name="''", nullable=true)
		public String signalkurs2

		@Column(name="''", nullable=true)
		public String stopkurs

		@Column(name="''", nullable=true)
		public String muster

		@Column(name="''", nullable=true)
		public String sortierung

		@Column(name="''", nullable=true)
		public String trend

		@Column(name="''", nullable=true)
		public String trend1

		@Column(name="''", nullable=true)
		public String trend2

		@Column(name="''", nullable=true)
		public String trend3

		@Column(name="''", nullable=true)
		public String trend4

		@Column(name="''", nullable=true)
		public String trend5

		@Column(name="''", nullable=true)
		public String kursdatum

		@Column(name="''", nullable=true)
		public String xo

		@Column(name="''", nullable=true)
		public String signalbew

		@Column(name="''", nullable=true)
		public String signalbez

		@Column(name="''", nullable=true)
		public String signaldatum

		@Column(name="''", nullable=true)
		public String konfiguration

		@Column(name="''", nullable=true)
		public String index1

		@Column(name="''", nullable=true)
		public String index2

		@Column(name="''", nullable=true)
		public String index3

		@Column(name="''", nullable=true)
		public String index4

		@Column(name="''", nullable=true)
		public String schnitt200

		@Column(name="''", nullable=true)
		public String typ // Aktie oder Anleihe

		@Column(name="''", nullable=true)
		public String waehrung
	}

	/** Wertpapier-Lang-Liste lesen. */
	override List<WpWertpapierLang> getWertpapierLangListe(ServiceDaten daten, String bez, String muster, String uid,
		String neuid, String relation, boolean nuraktiv) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(bez)) {
			sql.append(null, WpWertpapier.BEZEICHNUNG_NAME, "like", bez, null)
		}
		if (!Global.nesLike(muster)) {
			sql.append(null, WpWertpapier.PARAMETER_NAME, "like", muster, null)
		}
		if (!Global.nes(uid)) {
			sql.append(null, WpWertpapier.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(neuid)) {
			sql.append(null, WpWertpapier.UID_NAME, "<>", neuid, null)
		}
		if (!Global.nes(relation)) {
			sql.append(null, WpWertpapier.RELATION_UID_NAME, "=", relation, null)
		}
		if (nuraktiv) {
			sql.append(null, WpWertpapier.STATUS_NAME, "=", WpStatusEnum.AKTIV.toString, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

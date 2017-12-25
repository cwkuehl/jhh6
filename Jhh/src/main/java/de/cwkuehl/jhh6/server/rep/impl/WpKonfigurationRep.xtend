package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.WpKonfiguration
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
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
@Table(name="WP_Konfiguration")
class WpKonfigurationRep {

	/** 
	* Replication-Nr. 45 Attribut Uid 
	* WHERE Mandant_Nr: eq
	* WHERE Uid: eq ne
	* WHERE Status: eq
	* ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung, Uid
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

		@Column(name="Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="Parameter", nullable=false)
		public String parameter

		@Column(name="Status", length=10, nullable=false)
		public String status

		@Column(name="Notiz", nullable=true)
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

	/** SelectFrom: WP_Konfiguration a
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="a.Parameter", nullable=false)
		public String parameter

		@Column(name="a.Status", length=10, nullable=false)
		public String status

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

		@Column(name="0.0", nullable=true)
		public double box

		@Column(name="false", nullable=true)
		public boolean prozentual

		@Column(name="0", nullable=true)
		public int umkehr

		@Column(name="0", nullable=true)
		public int methode

		@Column(name="0", nullable=true)
		public int dauer

		@Column(name="false", nullable=true)
		public boolean relativ

		@Column(name="0", nullable=true)
		public int skala
	}

	/** Konfiguration-Lang-Liste lesen. */
	override List<WpKonfigurationLang> getKonfigurationLangListe(ServiceDaten daten, String uid, String status) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, WpKonfiguration.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(status)) {
			sql.append(null, WpKonfiguration.STATUS_NAME, "=", status, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

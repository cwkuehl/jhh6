package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmKonto
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="VM_Konto")
class VmKontoRep {

	/** 
	 * Replication-Nr. 11 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq ne
	 * WHERE Schluessel: eq
	 * WHERE Haus_Uid: eq
	 * WHERE Wohnung_Uid: eq
	 * WHERE Mieter_Uid: eq
	 * ORDER BY SCHLUESSEL: Mandant_Nr, Schluessel, Uid
	 * INDEX XRKVM_Konto: UNIQUE Mandant_Nr, Schluessel
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=false)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(HhKontoRep))
		@Column(name="Uid", length=35, nullable=false)
		public String uid

		@Column(name="Schluessel", length=10, nullable=true)
		public String schluessel

		@Column(name="Haus_Uid", length=35, nullable=true)
		public String hausUid

		@Column(name="Wohnung_Uid", length=35, nullable=true)
		public String wohnungUid

		@Column(name="Mieter_Uid", length=35, nullable=true)
		public String mieterUid

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

	override List<VmKonto> getKontoListe(ServiceDaten daten, String uid, String schluessel, String huid, String wuid, String muid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, VmKonto.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(schluessel)) {
			sql.append(null, VmKonto.SCHLUESSEL_NAME, "=", schluessel, null)
		}
		if (!Global.nes(huid)) {
			sql.append(null, VmKonto.HAUS_UID_NAME, "=", huid, null)
		}
		if (!Global.nes(wuid)) {
			sql.append(null, VmKonto.WOHNUNG_UID_NAME, "=", wuid, null)
		}
		if (!Global.nes(muid)) {
			sql.append(null, VmKonto.MIETER_UID_NAME, "=", muid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Schluessel, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}
}

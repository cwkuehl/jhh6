package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmMieter
import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.dto.VmWohnung
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
@Table(name="VM_Mieter")
class VmMieterRep {

	/** 
	 * Replication-Nr. 16 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Wohnung_Uid: eq
	 * WHERE Einzugdatum: le
	 * WHERE Auszugdatum: geOrNull
	 * ORDER BY NAME: Mandant_Nr, Name, Vorname, Uid
	 * ORDER BY EINZUG: Mandant_Nr, Einzugdatum, Uid
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

		@Column(name="Wohnung_Uid", length=35, nullable=false)
		public String wohnungUid

		@Column(name="Name", length=40, nullable=false)
		public String name

		@Column(name="Vorname", length=40, nullable=true)
		public String vorname

		@Column(name="Anrede", length=40, nullable=true)
		public String anrede

		@Column(name="Einzugdatum", nullable=true)
		public LocalDate einzugdatum

		@Column(name="Auszugdatum", nullable=true)
		public LocalDate auszugdatum

		@Column(name="Wohnung_Qm", nullable=false)
		public double wohnungQm

		@Column(name="Wohnung_Grundmiete", nullable=false)
		public double wohnungGrundmiete

		@Column(name="Wohnung_Kaution", nullable=false)
		public double wohnungKaution

		@Column(name="Wohnung_Antenne", nullable=false)
		public double wohnungAntenne

		@Column(name="Status", nullable=false)
		public int status

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

	/** SelectFrom: (VM_Mieter a inner join VM_Wohnung b
	 *   on a.Mandant_Nr=b.Mandant_Nr and a.Wohnung_Uid=b.Uid)
	 *   left join VM_Haus c on b.Mandant_Nr=c.Mandant_Nr and b.Haus_Uid=c.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Wohnung_Uid", length=35, nullable=false)
		public String wohnungUid

		@Column(name="a.Name", length=40, nullable=false)
		public String name

		@Column(name="a.Vorname", length=40, nullable=true)
		public String vorname

		@Column(name="a.Anrede", length=40, nullable=true)
		public String anrede

		@Column(name="a.Einzugdatum", nullable=true)
		public LocalDate einzugdatum

		@Column(name="a.Auszugdatum", nullable=true)
		public LocalDate auszugdatum

		@Column(name="a.Wohnung_Qm", nullable=false)
		public double wohnungQm

		@Column(name="a.Wohnung_Grundmiete", nullable=false)
		public double wohnungGrundmiete

		@Column(name="a.Wohnung_Kaution", nullable=false)
		public double wohnungKaution

		@Column(name="a.Wohnung_Antenne", nullable=false)
		public double wohnungAntenne

		@Column(name="a.Status", nullable=false)
		public int status

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
		public String wohnungBezeichnung

		@Column(name="b.Haus_Uid", nullable=true) // Where:  eq
		public String hausUid

		@Column(name="c.Bezeichnung", nullable=true)
		public String hausBezeichnung
	}

	/** Mieter-Lang-Liste lesen. */
	override List<VmMieterLang> getMieterLangListe(ServiceDaten daten, String uid, String wohnungUid, LocalDate von,
		LocalDate bis, String hausUid, boolean einzug) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (uid !== null) {
			sql.append(null, VmMieter.UID_NAME, "=", uid, null)
		}
		if (wohnungUid !== null) {
			sql.append(null, VmMieter.WOHNUNG_UID_NAME, "=", wohnungUid, null)
		}
		if (hausUid !== null) {
			sql.append(null, VmWohnung.HAUS_UID_NAME, "=", hausUid, null)
		}
		if (von !== null) {
			sql.append("(", "a.Auszugdatum IS NULL OR a.Auszugdatum", ">=", von, ")")
		}
		if (bis !== null) {
			sql.append(null, VmMieter.EINZUGDATUM_NAME, "<=", bis, null)
		}
		var order = new SqlBuilder(
			if(einzug) "a.Mandant_Nr, a.Einzugdatum DESC, a.Uid" else "a.Mandant_Nr, a.Name, a.Vorname, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

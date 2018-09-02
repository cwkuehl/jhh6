package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmMiete
import de.cwkuehl.jhh6.api.dto.VmMieteLang
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
@Table(name="VM_Miete")
class VmMieteRep {

	/** 
	 * Replication-Nr. 17 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Wohnung_Uid: eq
	 * WHERE Datum: le
	 * ORDER BY DATUM: Mandant_Nr, Wohnung_Uid, Datum DESC, Uid
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

		@Column(name="Datum", nullable=false)
		public LocalDate datum

		@Column(name="Miete", nullable=false)
		public double miete

		@Column(name="Nebenkosten", nullable=false)
		public double nebenkosten

		@Column(name="Garage", nullable=false)
		public double garage

		@Column(name="Heizung", nullable=false)
		public double heizung

		@Column(name="Personen", nullable=false)
		public int personen

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

	/** SelectFrom: (VM_Miete a inner join VM_Wohnung b
	 *   on a.Mandant_Nr=b.Mandant_Nr and a.Wohnung_Uid=b.Uid)
	 *   left join VM_Haus c on b.Mandant_Nr=c.Mandant_Nr and b.Haus_Uid=c.Uid
	 *  SelectOrderBy: a.Mandant_Nr, c.Bezeichnung, b.Bezeichnung, a.Datum DESC, a.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Wohnung_Uid", length=35, nullable=false)
		public String wohnungUid

		@Column(name="a.Datum", nullable=false)
		public LocalDate datum

		@Column(name="a.Miete", nullable=false)
		public double miete

		@Column(name="a.Nebenkosten", nullable=false)
		public double nebenkosten

		@Column(name="a.Garage", nullable=false)
		public double garage

		@Column(name="a.Heizung", nullable=false)
		public double heizung

		@Column(name="a.Personen", nullable=false)
		public int personen

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

		@Column(name="''", nullable=true)
		public String text1
	}

	/** Miete-Lang-Liste lesen. */
	override List<VmMieteLang> getMieteLangListe(ServiceDaten daten, String uid, String wohnungUid, String hausUid, LocalDate datum) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (uid !== null) {
			sql.append(null, VmMiete.UID_NAME, "=", uid, null)
		}
		if (wohnungUid !== null) {
			sql.append(null, VmMiete.WOHNUNG_UID_NAME, "=", wohnungUid, null)
		}
		if (hausUid !== null) {
			sql.append(null, "b.Haus_Uid", "=", hausUid, null)
		}
		if (datum !== null) {
			sql.append(null, VmMiete.DATUM_NAME, "<=", datum, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, c.Bezeichnung, b.Bezeichnung, a.Datum DESC, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

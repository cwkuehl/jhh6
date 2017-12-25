package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.VmAbrechnung
import de.cwkuehl.jhh6.api.dto.VmAbrechnungKurz
import de.cwkuehl.jhh6.api.dto.VmAbrechnungLang
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
@Table(name="VM_Abrechnung")
class VmAbrechnungRep {

	/** 
	 * Replication-Nr. 18 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Haus_Uid: eq
	 * WHERE Wohnung_Uid: eq isNull
	 * WHERE Mieter_Uid: eq isNull
	 * WHERE Datum_Von: le ge
	 * WHERE Datum_Bis: le ge
	 * WHERE Schluessel: eq
	 * ORDER BY DATUM: Mandant_Nr, Haus_Uid, Wohnung_Uid, Mieter_Uid, Datum_Von DESC, Datum_Bis DESC, Reihenfolge, Schluessel
	 * INDEX XRKVM_Abrechnung: Mandant_Nr, Haus_Uid, Wohnung_Uid, Mieter_Uid, Datum_Von, Datum_Bis, Schluessel
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

		@Column(name="Haus_Uid", length=35, nullable=false)
		public String hausUid

		@Column(name="Wohnung_Uid", length=35, nullable=true)
		public String wohnungUid

		@Column(name="Mieter_Uid", length=35, nullable=true)
		public String mieterUid

		@Column(name="Datum_Von", nullable=false)
		public LocalDate datumVon

		@Column(name="Datum_Bis", nullable=false)
		public LocalDate datumBis

		@Column(name="Schluessel", length=10, nullable=false)
		public String schluessel

		@Column(name="Beschreibung", length=255, nullable=true)
		public String beschreibung

		@Column(name="Wert", length=255, nullable=true)
		public String wert

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="Datum", nullable=true)
		public LocalDateTime datum

		@Column(name="Reihenfolge", length=10, nullable=false)
		public String reihenfolge

		@Column(name="Status", length=1, nullable=false)
		public String status

		@Column(name="Funktion", length=10, nullable=true)
		public String funktion

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

	/** SelectFrom: (VM_Abrechnung a
	 *   inner join VM_Haus b on a.Mandant_Nr=b.Mandant_Nr and a.Haus_Uid=b.Uid)
	 *  SelectOrderBy: a.Haus_Uid, a.Datum_Von, a.Datum_Bis, b.Bezeichnung
	 *  SelectGroupBy: a.Haus_Uid, a.Datum_Von, a.Datum_Bis, b.Bezeichnung */
	static class VoKurz {

		@Column(name="a.Haus_Uid", length=35, nullable=false)
		public String hausUid

		@Column(name="a.Datum_Von", nullable=false)
		public LocalDate datumVon

		@Column(name="a.Datum_Bis", nullable=false)
		public LocalDate datumBis

		@Column(name="b.Bezeichnung", nullable=true)
		public String hausBezeichnung
	}

	/** SelectFrom: ((VM_Abrechnung a
	 *   inner join VM_Haus b on a.Mandant_Nr=b.Mandant_Nr and a.Haus_Uid=b.Uid)
	 *   left join VM_Wohnung c on a.Mandant_Nr=c.Mandant_Nr and a.Wohnung_Uid=c.Uid)
	 *   left join VM_Mieter d on a.Mandant_Nr=d.Mandant_Nr and a.Mieter_Uid=d.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Haus_Uid", length=35, nullable=false)
		public String hausUid

		@Column(name="a.Wohnung_Uid", length=35, nullable=true)
		public String wohnungUid

		@Column(name="a.Mieter_Uid", length=35, nullable=true)
		public String mieterUid

		@Column(name="a.Datum_Von", nullable=false)
		public LocalDate datumVon

		@Column(name="a.Datum_Bis", nullable=false)
		public LocalDate datumBis

		@Column(name="a.Schluessel", length=10, nullable=false)
		public String schluessel

		@Column(name="a.Beschreibung", length=255, nullable=true)
		public String beschreibung

		@Column(name="a.Wert", length=255, nullable=true)
		public String wert

		@Column(name="a.Betrag", nullable=false)
		public double betrag

		@Column(name="a.Datum", nullable=true)
		public LocalDateTime datum

		@Column(name="a.Reihenfolge", length=10, nullable=false)
		public String reihenfolge

		@Column(name="a.Status", length=1, nullable=false)
		public String status

		@Column(name="a.Funktion", length=10, nullable=true)
		public String funktion

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
		public String hausBezeichnung

		@Column(name="c.Bezeichnung", nullable=true)
		public String wohnungBezeichnung

		@Column(name="d.Name", nullable=true)
		public String mieterName
	}

	/** Abrechnung-Lang-Liste lesen. */
	override List<VmAbrechnungLang> getAbrechnungLangListe(ServiceDaten daten, String uid, String schluessel,
		String hausUid, String wohnungUid, String mieterUid, LocalDate vonge, LocalDate bisle, LocalDate vonle,
		LocalDate bisge) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(uid)) {
			sql.append(null, VmAbrechnung.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(schluessel)) {
			sql.append(null, VmAbrechnung.SCHLUESSEL_NAME, "=", schluessel, null)
		}
		if (!Global.nes(hausUid)) {
			if (hausUid == "null") {
				sql.append("a.Haus_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.HAUS_UID_NAME, "=", hausUid, null)
			}
		}
		if (!Global.nes(wohnungUid)) {
			if (wohnungUid == "null") {
				sql.append("a.Wohnung_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.WOHNUNG_UID_NAME, "=", wohnungUid, null)
			}
		}
		if (!Global.nes(mieterUid)) {
			if (mieterUid == "null") {
				sql.append("a.Mieter_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.MIETER_UID_NAME, "=", mieterUid, null)
			}
		}
		if (vonge !== null) {
			sql.append(null, VmAbrechnung.DATUM_VON_NAME, ">=", vonge, null)
		}
		if (vonle !== null) {
			sql.append(null, VmAbrechnung.DATUM_VON_NAME, "<=", vonle, null)
		}
		if (bisle !== null) {
			sql.append(null, VmAbrechnung.DATUM_BIS_NAME, "<=", bisle, null)
		}
		if (bisge !== null) {
			sql.append(null, VmAbrechnung.DATUM_BIS_NAME, ">=", bisge, null)
		}
		var order = new SqlBuilder(
			"a.Mandant_Nr, a.Haus_Uid, a.Wohnung_Uid, a.Mieter_Uid, a.Datum_Von DESC, a.Datum_Bis DESC, a.Reihenfolge, a.Schluessel"
		)
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Abrechnung-Kurz-Liste lesen. */
	override List<VmAbrechnungKurz> getAbrechnungKurzListe(ServiceDaten daten, LocalDate datum, String hausUid,
		String wohnungUid, String mieterUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(hausUid)) {
			if (hausUid == "null") {
				sql.append("a.Haus_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.HAUS_UID_NAME, "=", hausUid, null)
			}
		}
		if (!Global.nes(wohnungUid)) {
			if (wohnungUid == "null") {
				sql.append("a.Wohnung_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.WOHNUNG_UID_NAME, "=", wohnungUid, null)
			}
		}
		if (!Global.nes(mieterUid)) {
			if (wohnungUid == "null") {
				sql.append("a.Mieter_Uid IS NULL")
			} else {
				sql.append(null, VmAbrechnung.MIETER_UID_NAME, "=", mieterUid, null)
			}
		}
		if (datum !== null) {
			// DatumVon <= datum und datum <= DatumBis
			sql.append(null, VmAbrechnung.DATUM_VON_NAME, "<=", datum, null)
			sql.append(null, VmAbrechnung.DATUM_BIS_NAME, ">=", datum, null)
		}
		var order = new SqlBuilder("a.Haus_Uid, a.Datum_Von, a.Datum_Bis, b.Bezeichnung")
		var l = getListeKurz(daten, daten.mandantNr, sql, order)
		return l
	}
}

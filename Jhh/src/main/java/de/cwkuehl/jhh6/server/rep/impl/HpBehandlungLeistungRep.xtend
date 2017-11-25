package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HpBehandlung
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistung
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungLang
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
@Table(name="HP_Behandlung_Leistung")
class HpBehandlungLeistungRep {

	/** 
	 * Replication-Nr. 47 Attribut Uid 
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

		@Column(name="Behandlung_Uid", length=35, nullable=false)
		public String behandlungUid

		@Column(name="Leistung_Uid", length=35, nullable=false)
		public String leistungUid

		@Column(name="Dauer", nullable=false)
		public double dauer

		@Column(name="Parameter", nullable=true)
		public String parameter

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: ((((HP_Behandlung_Leistung a
	 *   inner join HP_Behandlung b on a.Mandant_Nr=b.Mandant_Nr and a.Behandlung_Uid=b.Uid)
	 *   inner join HP_Leistung c on a.Mandant_Nr=c.Mandant_Nr and a.Leistung_Uid=c.Uid)
	 *   inner join HP_Patient d on b.Mandant_Nr=d.Mandant_Nr and b.Patient_Uid=d.Uid)
	 *   left join HP_Status e on b.Mandant_Nr=e.Mandant_Nr and b.Status_Uid=e.Uid)
	 *  SelectOrderBy: d.Name1, d.Vorname, b.Datum, b.Uid, c.Ziffer, a.Uid
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Behandlung_Uid", length=35, nullable=false)
		public String behandlungUid

		@Column(name="a.Leistung_Uid", length=35, nullable=false)
		public String leistungUid

		@Column(name="a.Dauer", nullable=true)
		public double dauer

		@Column(name="b.Datum", nullable=false)
		public LocalDate behandlungDatum

		@Column(name="b.Diagnose", length=50, nullable=true)
		public String behandlungDiagnose

		@Column(name="b.Rechnung_Uid", length=35, nullable=false)
		public String behandlungRechnungUid

		@Column(name="c.Ziffer", length=10, nullable=false)
		public String leistungZiffer

		@Column(name="c.Ziffer_Alt", nullable=true)
		public String leistungZifferAlt

		@Column(name="c.Beschreibung_Fett", nullable=true)
		public String leistungBeschreibungFett

		@Column(name="c.Beschreibung", nullable=true)
		public String leistungBeschreibung

		@Column(name="c.Faktor*a.Dauer+c.Festbetrag", nullable=true)
		public double leistungBetrag

		@Column(name="d.Uid", length=35, nullable=false)
		public String patientUid

		@Column(name="d.Name1", nullable=true)
		public String patientName

		@Column(name="d.Vorname", nullable=true)
		public String patientVorname

		@Column(name="e.Status", nullable=true)
		public String behandlungStatus

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Behandlung-Leistung-Liste lesen. */
	override public List<HpBehandlungLeistung> getBehandlungLeistungListe(ServiceDaten daten, String behandlungUid,
		String leistungUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(behandlungUid)) {
			sql.append(null, HpBehandlungLeistung.BEHANDLUNG_UID_NAME, "=", behandlungUid, null)
		}
		if (!Global.nes(leistungUid)) {
			sql.append(null, HpBehandlungLeistung.LEISTUNG_UID_NAME, "=", leistungUid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Behandlung-Leistung-Lang-Liste lesen. */
	override public List<HpBehandlungLeistungLang> getBehandlungLeistungLangListe(ServiceDaten daten, String behandlungUid,
		String leistungUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(behandlungUid)) {
			sql.append(null, HpBehandlungLeistung.BEHANDLUNG_UID_NAME, "=", behandlungUid, null)
		}
		if (!Global.nes(leistungUid)) {
			sql.append(null, HpBehandlungLeistung.LEISTUNG_UID_NAME, "=", leistungUid, null)
		}
		var l = getListeLang(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Behandlung-Liste lesen. */
	override public List<HpBehandlungLeistungLang> getBehandlungLangListe(ServiceDaten daten, String patientUid, String rechnungUid,
		String behandlungUid, LocalDate von, LocalDate bis, boolean auchNull) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(patientUid)) {
			sql.append("b.", HpBehandlung.PATIENT_UID_NAME, "=", patientUid, null)
		}
		if (!Global.nes(rechnungUid)) {
			if (auchNull) {
				var sql2 = new SqlBuilder
				sql2.append("(b.", HpBehandlung.RECHNUNG_UID_NAME, "=", rechnungUid, null)
				sql2.append(" OR b.").append(HpBehandlung.RECHNUNG_UID_NAME).append(" IS NULL").append(")")
				sql.append(sql2)
			} else {
				sql.append("b.", HpBehandlung.RECHNUNG_UID_NAME, "=", rechnungUid, null)
			}
		}
		if (!Global.nes(behandlungUid)) {
			sql.append(null, HpBehandlungLeistung.BEHANDLUNG_UID_NAME, "=", behandlungUid, null)
		}
		if (von !== null) {
			sql.append("b.", HpBehandlung.DATUM_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append("b.", HpBehandlung.DATUM_NAME, "<=", bis, null)
		}
		var l = getListeLang(daten, daten.mandantNr, sql, null)
		return l
	}
}

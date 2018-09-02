package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HpBehandlung
import de.cwkuehl.jhh6.api.dto.HpBehandlungLang
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
@Table(name="HP_Behandlung")
class HpBehandlungRep {

	/** 
	 * Replication-Nr. 19 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq in
	 * WHERE Patient_Uid: eq
	 * WHERE Datum: ge le
	 * WHERE Status_Uid: eq
	 * WHERE Leistung_Uid: eq
	 * WHERE Rechnung_Uid: eq eqOrNull
	 * ORDER BY DATUM: Mandant_Nr, Datum DESC, Patient_Uid, Uid
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

		@Column(name="Patient_Uid", length=35, nullable=false)
		public String patientUid

		@Column(name="Datum", nullable=false)
		public LocalDate datum

		@Column(name="Dauer", nullable=false)
		public double dauer

		@Column(name="Beschreibung", length=50, nullable=false)
		public String beschreibung

		@Column(name="Diagnose", length=50, nullable=true)
		public String diagnose

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="Leistung_Uid", length=35, nullable=false)
		public String leistungUid

		@Column(name="Rechnung_Uid", length=35, nullable=true)
		public String rechnungUid

		@Column(name="Status_Uid", length=35, nullable=false)
		public String statusUid

		@Column(name="Mittel", length=50, nullable=true)
		public String mittel

		@Column(name="Potenz", length=10, nullable=true)
		public String potenz

		@Column(name="Dosierung", length=100, nullable=true)
		public String dosierung

		@Column(name="Verordnung", length=255, nullable=true)
		public String verordnung

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

	/** SelectFrom: ((HP_Behandlung a
	 *   inner join HP_Patient b on a.Mandant_Nr=b.Mandant_Nr and a.Patient_Uid=b.Uid)
	 *   left join HP_Status c on a.Mandant_Nr=c.Mandant_Nr and a.Status_Uid=c.Uid)
	 *   left join HP_Leistung d on a.Mandant_Nr=d.Mandant_Nr and a.Leistung_Uid=d.Uid
	 *  SelectOrderBy: c.Sortierung, a.Datum DESC, b.Name1, b.Vorname
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Patient_Uid", length=35, nullable=false)
		public String patientUid

		@Column(name="a.Datum", nullable=false)
		public LocalDate datum

		@Column(name="a.Dauer", nullable=false)
		public double dauer

		@Column(name="a.Beschreibung", length=50, nullable=false)
		public String beschreibung

		@Column(name="a.Diagnose", length=50, nullable=true)
		public String diagnose

		@Column(name="a.Leistung_Uid", length=35, nullable=false)
		public String leistungUid

		@Column(name="a.Rechnung_Uid", length=35, nullable=true)
		public String rechnungUid

		@Column(name="a.Status_Uid", length=35, nullable=false)
		public String statusUid

		@Column(name="a.Mittel", length=50, nullable=true)
		public String mittel

		@Column(name="a.Potenz", length=10, nullable=true)
		public String potenz

		@Column(name="a.Dosierung", length=100, nullable=true)
		public String dosierung

		@Column(name="a.Verordnung", length=255, nullable=true)
		public String verordnung

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

		@Column(name="b.Name1", nullable=true)
		public String patientName

		@Column(name="b.Vorname", nullable=true)
		public String patientVorname

		@Column(name="c.Status", nullable=true)
		public String statusStatus

		@Column(name="d.Ziffer", nullable=true)
		public String leistungZiffer

		@Column(name="d.Ziffer_Alt", nullable=true)
		public String leistungZifferAlt

		@Column(name="d.Beschreibung_Fett", nullable=true)
		public String leistungBeschreibungFett

		@Column(name="d.Beschreibung", nullable=true)
		public String leistungBeschreibung

		@Column(name="d.Faktor*a.Dauer+d.Festbetrag", nullable=true)
		public double leistungBetrag
	}

	/** 
	 */
	static class VoDruck {

		@Column(name="a.Datum", nullable=false)
		public LocalDate datum

		@Column(name="a.Dauer", nullable=false)
		public double dauer

		@Column(name="''", nullable=true)
		public String ziffer

		@Column(name="''", nullable=true)
		public String zifferAlt

		@Column(name="''", nullable=true)
		public String leistung

		@Column(name="''", nullable=true)
		public String leistung2

		@Column(name="0", nullable=true)
		public double betrag
	}

	/** Anzahl der Status-Verwendungen. */
	override int getStatusAnzahl(ServiceDaten daten, String statusUid) {

		var sql = new SqlBuilder
		sql.append(null, HpBehandlung.STATUS_UID_NAME, "=", statusUid, null)
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l.size
	}

	/** Anzahl der Leistung-Verwendungen. */
	override int getLeistungAnzahl(ServiceDaten daten, String leistungUid) {

		var sql = new SqlBuilder
		sql.append(null, HpBehandlung.LEISTUNG_UID_NAME, "=", leistungUid, null)
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l.size
	}

	/** Behandlung-Liste lesen. */
	override public List<HpBehandlungLang> getBehandlungLangListe(ServiceDaten daten, String patientUid, LocalDate von,
		LocalDate bis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(patientUid)) {
			sql.append(null, HpBehandlung.PATIENT_UID_NAME, "=", patientUid, null)
		}
		if (von !== null) {
			sql.append(null, HpBehandlung.DATUM_NAME, ">=", von, null)
		}
		if (bis !== null) {
			sql.append(null, HpBehandlung.DATUM_NAME, "<=", bis, null)
		}
		var l = getListeLang(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Behandlung-Liste lesen. */
	override public List<HpBehandlung> getBehandlungListe(ServiceDaten daten, String rechnungUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(rechnungUid)) {
			sql.append(null, HpBehandlung.RECHNUNG_UID_NAME, "=", rechnungUid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Nächste Behandlung lesen (für Übernahme von Anamnesen). */
	override public HpBehandlung getNaechsteBehandlung(ServiceDaten daten, String patientUid, LocalDate von) {

		var w = new SqlBuilder
		w.praefix(null, " AND ")
		if (!Global.nes(patientUid)) {
			w.append(null, HpBehandlung.PATIENT_UID_NAME, "=", patientUid, null)
		}
		if (von !== null) {
			w.append(null, HpBehandlung.DATUM_NAME, ">=", von, null)
		}
		var o = new SqlBuilder("a.Datum")
		var sql = selectSql(null, daten.mandantNr, w, o)
		return selectOne(daten, sql, readDto, typeof(HpBehandlung));
	}

}

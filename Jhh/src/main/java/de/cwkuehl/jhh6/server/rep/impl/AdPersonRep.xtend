package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.AdPerson
import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.dto.AdSitz
import de.cwkuehl.jhh6.api.enums.PersonStatusEnum
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
@Table(name="AD_Person")
class AdPersonRep {

	/** 
	 * Replication-Nr. 4 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Geschlecht: eq
	 * WHERE Geburt: eq
	 * WHERE Name1: eq like
	 * WHERE Name2: eq
	 * WHERE Praedikat: eq
	 * WHERE Vorname: eq like
	 * WHERE Titel: eq
	 * WHERE GeburtK: ne bt nb
	 * WHERE Person_Status: eq
	 * WHERE Angelegt_Am: eq
	 * WHERE Angelegt_Von: eq
	 * ORDER BY GEBURTK: Mandant_Nr, GeburtK, Name1, Uid
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

		@Column(name="Typ", nullable=false)
		public int typ

		@Column(name="Geschlecht", length=1, nullable=false)
		public String geschlecht

		@Column(name="Geburt", nullable=true)
		public LocalDate geburt

		@Column(name="GeburtK", nullable=false)
		public int geburtk

		@Column(name="Anrede", nullable=false)
		public int anrede

		@Column(name="FAnrede", nullable=false)
		public int fanrede

		@Column(name="Name1", length=40, nullable=false)
		public String name1

		@Column(name="Name2", length=40, nullable=true)
		public String name2

		@Column(name="Praedikat", length=40, nullable=true)
		public String praedikat

		@Column(name="Vorname", length=40, nullable=true)
		public String vorname

		@Column(name="Titel", length=40, nullable=true)
		public String titel

		@Column(name="Person_Status", nullable=false)
		public int personStatus

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: (AD_Person a
	 *   LEFT JOIN AD_Sitz b ON a.Mandant_Nr=b.Mandant_Nr AND a.Uid=b.Person_Uid)
	 *   LEFT JOIN AD_Adresse c ON b.Mandant_Nr=c.Mandant_Nr AND b.Adresse_Uid=c.Uid
	 *  SelectOrderBy: a.Mandant_Nr, a.Name1, a.Vorname, a.Uid, b.Reihenfolge, b.Uid
	 */
	static class VoSitzAdresse {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Typ", nullable=false)
		public int typ

		@Column(name="a.Geschlecht", length=1, nullable=false)
		public String geschlecht

		@Column(name="a.Geburt", nullable=true)
		public LocalDate geburt

		@Column(name="a.Anrede", nullable=false)
		public int anrede

		@Column(name="a.Name1", length=40, nullable=false)
		public String name1

		@Column(name="a.Name2", length=40, nullable=true)
		public String name2

		@Column(name="a.Praedikat", length=40, nullable=true)
		public String praedikat

		@Column(name="a.Vorname", length=40, nullable=true)
		public String vorname

		@Column(name="a.Titel", length=40, nullable=true)
		public String titel

		@Column(name="a.Person_Status", nullable=false)
		public int personStatus

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="b.Person_Uid", nullable=true)
		public String personUid

		@Column(name="b.Reihenfolge", nullable=true)
		public int reihenfolge

		@Column(name="b.Uid", nullable=true) // Where:  eq
		public String siUid

		@Column(name="b.Typ", nullable=true)
		public int siTyp

		@Column(name="b.Name", nullable=true)
		public String name

		@Column(name="b.Adresse_Uid", nullable=true)
		public String adresseUid

		@Column(name="b.Telefon", nullable=true)
		public String telefon

		@Column(name="b.Fax", nullable=true)
		public String fax

		@Column(name="b.Mobil", nullable=true)
		public String mobil

		@Column(name="b.Email", nullable=true)
		public String email

		@Column(name="b.Homepage", nullable=true)
		public String homepage

		@Column(name="b.Postfach", nullable=true)
		public String postfach

		@Column(name="b.Bemerkung", nullable=true)
		public String bemerkung

		@Column(name="b.Sitz_Status", nullable=true) // Where:  eq
		public int sitzStatus

		@Column(name="b.Angelegt_Von", nullable=true)
		public String siAngelegtVon

		@Column(name="b.Angelegt_Am", nullable=true)
		public LocalDateTime siAngelegtAm

		@Column(name="b.Geaendert_Von", nullable=true)
		public String siGeaendertVon

		@Column(name="b.Geaendert_Am", nullable=true)
		public LocalDateTime siGeaendertAm

		@Column(name="c.Uid", nullable=true)
		public String adUid

		@Column(name="c.Staat", nullable=true)
		public String staat

		@Column(name="c.Plz", nullable=true)
		public String plz

		@Column(name="c.Ort", nullable=true)
		public String ort

		@Column(name="c.Strasse", nullable=true)
		public String strasse

		@Column(name="c.HausNr", nullable=true)
		public String hausnr

		@Column(name="c.Angelegt_Von", nullable=true)
		public String adAngelegtVon

		@Column(name="c.Angelegt_Am", nullable=true)
		public LocalDateTime adAngelegtAm

		@Column(name="c.Geaendert_Von", nullable=true)
		public String adGeaendertVon

		@Column(name="c.Geaendert_Am", nullable=true)
		public LocalDateTime adGeaendertAm
	}

	/** Geburtstags-Liste lesen. */
	override public List<AdPerson> getGeburtstagListe(ServiceDaten daten, LocalDate dvon, LocalDate dbis) {

		var dv = dvon.monthValue * 100 + dvon.dayOfMonth
		var db = dbis.monthValue * 100 + dbis.dayOfMonth
		var sql = new SqlBuilder
		sql.append(null, AdPerson.PERSON_STATUS_NAME, "=", PersonStatusEnum.AKTUELL.intValue, null)
		if (dbis.year != dvon.year) {
			sql.append(" AND ", AdPerson.GEBURTK_NAME, "<>", 0, null)
			sql.append(" AND (", AdPerson.GEBURTK_NAME, "<", db, null)
			sql.append(" OR ", AdPerson.GEBURTK_NAME, ">", dv, ")")
		} else {
			sql.append(" AND ", AdPerson.GEBURTK_NAME, ">=", dv, null)
			sql.append(" AND ", AdPerson.GEBURTK_NAME, "<=", db, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.GeburtK, a.Name1, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Personen-Liste lesen. */
	override public List<AdPersonSitzAdresse> getPersonenSitzAdresseListe(ServiceDaten daten, boolean nurAktuelle,
		String name, String vorname, String puid, String suid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (nurAktuelle) {
			sql.append("a.", AdPerson.PERSON_STATUS_NAME, "=", PersonStatusEnum.AKTUELL.intValue(), null)
			sql.append("b.", AdSitz.SITZ_STATUS_NAME, "=", PersonStatusEnum.AKTUELL.intValue(), null)
		}
		if (!Global.nesLike(name)) {
			sql.append("a.", AdPerson.NAME1_NAME, "like", name, null)
		}
		if (!Global.nesLike(vorname)) {
			sql.append("a.", AdPerson.VORNAME_NAME, "like", vorname, null)
		}
		if (!Global.nes(puid)) {
			sql.append("a.", AdPerson.UID_NAME, "=", puid, null)
		}
		if (!Global.nes(suid)) {
			sql.append("b.", AdSitz.UID_NAME, "=", suid, null)
		}
		var l = getListeSitzAdresse(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Person lesen. */
	override public String getUid(ServiceDaten daten, AdPerson p) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (p.geschlecht !== null) {
			sql.append("a.", AdPerson.GESCHLECHT_NAME, "=", p.geschlecht, null)
		}
		if (p.geburt !== null) {
			sql.append("a.", AdPerson.GEBURT_NAME, "=", p.geburt, null)
		}
		if (p.name1 !== null) {
			sql.append("a.", AdPerson.NAME1_NAME, "=", p.name1, null)
		}
		if (p.name2 !== null) {
			sql.append("a.", AdPerson.NAME2_NAME, "=", p.name2, null)
		}
		if (p.praedikat !== null) {
			sql.append("a.", AdPerson.PRAEDIKAT_NAME, "=", p.praedikat, null)
		}
		if (p.vorname !== null) {
			sql.append("a.", AdPerson.VORNAME_NAME, "=", p.vorname, null)
		}
		if (p.titel !== null) {
			sql.append("a.", AdPerson.TITEL_NAME, "=", p.titel, null)
		}
		if (p.angelegtVon !== null) {
			sql.append("a.", AdPerson.ANGELEGT_VON_NAME, "=", p.angelegtVon, null)
		}
		if (p.angelegtAm !== null) {
			sql.append("a.", AdPerson.ANGELEGT_AM_NAME, "=", p.angelegtAm, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		if (l.length > 0) {
			return l.get(0).uid
		}
		return null
	}

}

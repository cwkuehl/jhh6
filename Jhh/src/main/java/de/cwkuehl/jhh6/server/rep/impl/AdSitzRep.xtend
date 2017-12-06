package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.AdSitz
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
@Table(name="AD_Sitz")
class AdSitzRep {

	/** 
	 * Replication-Nr. 5 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Person_Uid: eq
	 * WHERE Uid: eq ne
	 * WHERE Name: eq
	 * WHERE Adresse_Uid: eq
	 * WHERE Telefon: eq
	 * WHERE Fax: eq
	 * WHERE Mobil: eq
	 * WHERE Email: eq
	 * WHERE Homepage: eq
	 * WHERE Postfach: eq
	 * WHERE Angelegt_Am: eq
	 * WHERE Angelegt_Von: eq
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Person_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(AdPersonRep))
		@Column(name="Person_Uid", length=35, nullable=true)
		public String personUid

		@PrimaryKeyJoinColumn(name="Reihenfolge")
		@Column(name="Reihenfolge", nullable=true)
		public int reihenfolge

		@PrimaryKeyJoinColumn(name="Uid")
		@Id
		@Column(name="Uid", length=35, nullable=true)
		public String uid

		@Column(name="Typ", nullable=false)
		public int typ

		@Column(name="Name", length=40, nullable=false)
		public String name

		@Column(name="Adresse_Uid", length=35, nullable=true)
		public String adresseUid

		@Column(name="Telefon", length=40, nullable=true)
		public String telefon

		@Column(name="Fax", length=40, nullable=true)
		public String fax

		@Column(name="Mobil", length=40, nullable=true)
		public String mobil

		@Column(name="Email", length=40, nullable=true)
		public String email

		@Column(name="Homepage", length=100, nullable=true)
		public String homepage

		@Column(name="Postfach", length=10, nullable=true)
		public String postfach

		@Column(name="Bemerkung", length=255, nullable=true)
		public String bemerkung

		@Column(name="Sitz_Status", nullable=false)
		public int sitzStatus

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Sitz-Liste lesen. */
	override public List<AdSitz> getSitzListe(ServiceDaten daten, String personUid, String sitzUid, String adressUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(personUid)) {
			sql.append(null, AdSitz.PERSON_UID_NAME, "=", personUid, null)
		}
		if (!Global.nes(sitzUid)) {
			sql.append(null, AdSitz.UID_NAME, "=", sitzUid, null)
		}
		if (!Global.nes(adressUid)) {
			sql.append(null, AdSitz.ADRESSE_UID_NAME, "=", adressUid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Anzahl der Adressenverwendungen. */
	override int getAdresseAnzahl(ServiceDaten daten, String adressUid) {

		var sql = new SqlBuilder
		sql.append(null, AdSitz.ADRESSE_UID_NAME, "=", adressUid, null)
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l.size
	}

	/** Sitz lesen. */
	override public String getUid(ServiceDaten daten, AdSitz p) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")

		sql.append("a.", AdSitz.PERSON_UID_NAME, "=", p.personUid, null)
        if (p.name !== null) {
			sql.append("a.", AdSitz.NAME_NAME, "=", p.name, null)
        }
        if (p.telefon !== null) {
			sql.append("a.", AdSitz.TELEFON_NAME, "=", p.telefon, null)
        }
        if (p.fax !== null) {
			sql.append("a.", AdSitz.FAX_NAME, "=", p.fax, null)
        }
        if (p.mobil !== null) {
			sql.append("a.", AdSitz.MOBIL_NAME, "=", p.mobil, null)
        }
        if (p.email !== null) {
			sql.append("a.", AdSitz.EMAIL_NAME, "=", p.email, null)
        }
        if (p.homepage !== null) {
			sql.append("a.", AdSitz.HOMEPAGE_NAME, "=", p.homepage, null)
        }
        if (p.postfach !== null) {
			sql.append("a.", AdSitz.POSTFACH_NAME, "=", p.postfach, null)
        }
        if (p.angelegtVon !== null) {
			sql.append("a.", AdSitz.ANGELEGT_VON_NAME, "=", p.angelegtVon, null)
        }
        if (p.angelegtAm !== null) {
			sql.append("a.", AdSitz.ANGELEGT_AM_NAME, "=", p.angelegtAm, null)
        }
		var l = getListe(daten, daten.mandantNr, sql, null)
		if (l.length > 0) {
			return l.get(0).uid
		}
		return null
	}
}

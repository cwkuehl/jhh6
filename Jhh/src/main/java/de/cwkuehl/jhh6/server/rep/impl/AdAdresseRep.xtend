package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.AdAdresse
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDateTime

@Repository
@Table(name="AD_Adresse")
class AdAdresseRep {

	/** 
	 * Replication-Nr. 3 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Staat: eq isNull
	 * WHERE Plz: eq isNull
	 * WHERE Ort: eq isNull
	 * WHERE Strasse: eq isNull
	 * WHERE HausNr: eq isNull
	 * WHERE Angelegt_Am: eq
	 * WHERE Angelegt_Von: eq
	 * ORDER BY STRASSE_ORT: Mandant_Nr, Strasse, Ort, Uid
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

		@Column(name="Staat", length=3, nullable=true)
		public String staat

		@Column(name="Plz", length=10, nullable=true)
		public String plz

		@Column(name="Ort", length=40, nullable=false)
		public String ort

		@Column(name="Strasse", length=40, nullable=true)
		public String strasse

		@Column(name="HausNr", length=20, nullable=true)
		public String hausnr

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Adresse lesen. */
	override public String getUid(ServiceDaten daten, AdAdresse p) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (p.staat === null) {
			sql.append('''a.«AdAdresse.STAAT_NAME» IS NULL''')
		} else {
			sql.append("a.", AdAdresse.STAAT_NAME, "=", p.staat, null)
		}
		if (p.plz === null) {
			sql.append('''a.«AdAdresse.PLZ_NAME» IS NULL''')
		} else {
			sql.append("a.", AdAdresse.PLZ_NAME, "=", p.plz, null)
		}
		if (p.ort === null) {
			sql.append('''a.«AdAdresse.ORT_NAME» IS NULL''')
		} else {
			sql.append("a.", AdAdresse.ORT_NAME, "=", p.ort, null)
		}
		if (p.strasse === null) {
			sql.append('''a.«AdAdresse.STRASSE_NAME» IS NULL''')
		} else {
			sql.append("a.", AdAdresse.STRASSE_NAME, "=", p.strasse, null)
		}
		if (p.hausnr === null) {
			sql.append('''a.«AdAdresse.HAUSNR_NAME» IS NULL''')
		} else {
			sql.append("a.", AdAdresse.HAUSNR_NAME, "=", p.hausnr, null)
		}
		if (p.angelegtVon !== null) {
			sql.append("a.", AdAdresse.ANGELEGT_VON_NAME, "=", p.angelegtVon, null)
		}
		if (p.angelegtAm !== null) {
			sql.append("a.", AdAdresse.ANGELEGT_AM_NAME, "=", p.angelegtAm, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		if (l.length > 0) {
			return l.get(0).uid
		}
		return null
	}
}

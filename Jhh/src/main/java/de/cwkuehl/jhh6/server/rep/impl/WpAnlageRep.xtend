package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.WpAnlage
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
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
@Table(name="WP_Anlage")
class WpAnlageRep {
/*
CREATE TABLE HH_Anlage (
Mandant_Nr int NOT NULL,Nr int NOT NULL,Bezeichnung varchar(50) NOT NULL,Art varchar(10) ,Url varchar(255) ,Zeichensatz varchar(20) ,Spaltenname varchar(255) ,Zeilenname varchar(255) ,Angelegt_Von varchar(20) ,Angelegt_Am datetime ,Geaendert_Von varchar(20) ,Geaendert_Am datetime 
) TYPE=INNODB;
ALTER TABLE HH_Anlage
 ADD (CONSTRAINT XPKHH_Anlage PRIMARY KEY (Mandant_Nr,Nr));

CREATE TABLE HH_Anlagebuchung (
Mandant_Nr int NOT NULL,Nr int NOT NULL,Anlage_Nr int NOT NULL,Lfd_Nr int NOT NULL,Datum date NOT NULL,Zahlungsbetrag double(21,4) NOT NULL,Rabattbetrag double(21,4) NOT NULL,Anteile double(21,4) NOT NULL,Zinsen double(21,4) NOT NULL,BText varchar(50) ,Angelegt_Von varchar(20) ,Angelegt_Am datetime ,Geaendert_Von varchar(20) ,Geaendert_Am datetime 
) TYPE=INNODB;
ALTER TABLE HH_Anlagebuchung
 ADD (CONSTRAINT XPKHH_Anlagebuchung PRIMARY KEY (Mandant_Nr,Nr));

CREATE TABLE HH_Anlagestand (
Mandant_Nr int NOT NULL,Anlage_Nr int NOT NULL,Datum date NOT NULL,Stueckpreis double(21,4) NOT NULL,Angelegt_Von varchar(20) ,Angelegt_Am datetime ,Geaendert_Von varchar(20) ,Geaendert_Am datetime 
) TYPE=INNODB;
ALTER TABLE HH_Anlagestand
 ADD (CONSTRAINT XPKHH_Anlagestand PRIMARY KEY (Mandant_Nr,Anlage_Nr,Datum));

CREATE TABLE HH_Anlageteil (
Mandant_Nr int NOT NULL,Anlage_Nr int NOT NULL,Lfd_Nr int NOT NULL,Person_Nr int NOT NULL,Name varchar(20) NOT NULL,Angelegt_Von varchar(20) ,Angelegt_Am datetime ,Geaendert_Von varchar(20) ,Geaendert_Am datetime 
) TYPE=INNODB;
ALTER TABLE HH_Anlageteil
 ADD (CONSTRAINT XPKHH_Anlageteil PRIMARY KEY (Mandant_Nr,Anlage_Nr,Lfd_Nr));
 */

	/** 
	 * Replication-Nr. 49 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Wertpapier_Uid: eq
	 * WHERE Bezeichnung: like
	 * ORDER BY BEZEICHNUNG: Mandant_Nr, Bezeichnung, Wertpapier_Uid, Uid
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

		@ManyToOne(targetEntity=typeof(WpWertpapierRep))
		@Column(name="Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@Column(name="Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="Parameter", length=-1, nullable=true)
		public String parameter

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

	/** SelectFrom: (WP_Anlage a
	 *   LEFT JOIN WP_Wertpapier b ON a.Mandant_Nr=b.Mandant_Nr AND a.Wertpapier_Uid=b.Uid)
	 */
	static class VoLang {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Wertpapier_Uid", length=35, nullable=false)
		public String wertpapierUid

		@Column(name="a.Bezeichnung", length=50, nullable=false)
		public String bezeichnung

		@Column(name="Parameter", nullable=true)
		public String parameter

		@Column(name="''", nullable=true)
		public String daten

		@Column(name="0.0", nullable=true)
		public double betrag

		@Column(name="0.0", nullable=true)
		public double anteile

		@Column(name="0.0", nullable=true)
		public double preis

		@Column(name="0.0", nullable=true)
		public double zinsen

		@Column(name="0.0", nullable=true)
		public double aktpreis

		@Column(name="null", nullable=true)
		public LocalDateTime aktdatum

		@Column(name="0.0", nullable=true)
		public double wert

		@Column(name="0.0", nullable=true)
		public double gewinn

		@Column(name="0.0", nullable=true)
		public double pgewinn

		@Column(name="''", nullable=true)
		public String waehrung

		@Column(name="0.0", nullable=true)
		public double kurs

		@Column(name="null", nullable=true)
		public LocalDateTime mindatum

		@Column(name="a.Notiz", nullable=true)
		public String notiz

		@Column(name="b.Bezeichnung", length=50, nullable=false)
		public String wertpapierBezeichnung

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Anlage-Lang-Liste lesen. */
	override List<WpAnlageLang> getAnlageLangListe(ServiceDaten daten, String bez, String uid,
		String wpuid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(bez)) {
			sql.append(null, WpAnlage.BEZEICHNUNG_NAME, "like", bez, null)
		}
		if (!Global.nes(uid)) {
			sql.append(null, WpAnlage.UID_NAME, "=", uid, null)
		}
		if (!Global.nes(wpuid)) {
			sql.append(null, WpAnlage.WERTPAPIER_UID_NAME, "=", wpuid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Bezeichnung, b.Bezeichnung, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

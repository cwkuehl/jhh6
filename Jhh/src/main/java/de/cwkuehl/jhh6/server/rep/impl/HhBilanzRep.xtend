package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.HhBilanz
import de.cwkuehl.jhh6.api.dto.HhBilanzKey
import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.dto.HhBilanzSumme
import de.cwkuehl.jhh6.api.dto.HhBilanzUpdate
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
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
@Table(name="HH_Bilanz")
class HhBilanzRep {

	/**  
	 * ReplicationCopy
	 * WHERE Mandant_Nr: eq
	 * WHERE Periode: eq gt ge lt le
	 * WHERE Kz: eq
	 * WHERE Konto_Uid: eq ne
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Periode", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(HhPeriodeRep))
		@Column(name="Periode", nullable=true)
		public int periode

		@PrimaryKeyJoinColumn(name="Kz")
		@Column(name="Kz", length=2, nullable=true)
		public String kz

		@PrimaryKeyJoinColumn(name="Konto_Uid", referencedColumnName="Uid")
		@ManyToOne(targetEntity=typeof(HhKontoRep))
		@Column(name="Konto_Uid", length=35, nullable=true)
		public String kontoUid

		@Column(name="SH", length=1, nullable=false)
		public String sh

		@Column(name="Betrag", nullable=false)
		public double betrag

		@Column(name="ESH", length=1, nullable=false)
		public String esh

		@Column(name="EBetrag", nullable=false)
		public double ebetrag

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: HH_Bilanz a
	 *   INNER JOIN HH_Konto b on a.Mandant_Nr = b.Mandant_Nr and a.Konto_Uid = b.Uid
	 *  SelectOrderBy: b.Sortierung, b.Name, a.Konto_Uid, a.SH, a.ESH
	 *  SelectGroupBy: b.Sortierung, b.Name, a.Konto_Uid, a.SH, a.ESH */
	static class VoSb {

		@Column(name="a.Konto_Uid", length=35, nullable=true)
		public String kontoUid

		@Column(name="b.Sortierung", nullable=true)
		public String sortierung

		@Column(name="b.Name", nullable=true)
		public String name

		@Column(name="0", nullable=true)
		public int art

		@Column(name="SUM(a.Betrag)", nullable=true)
		public double summe

		@Column(name="a.SH", nullable=true)
		public String sh

		@Column(name="SUM(a.EBetrag)", nullable=true)
		public double esumme

		@Column(name="a.ESH", nullable=true)
		public String esh
	}

	/** SelectFrom: HH_Bilanz a
	 *  SelectOrderBy: a.Mandant_Nr
	 *  SelectGroupBy: a.Mandant_Nr */
	static class VoSumme {

		@Column(name="a.Mandant_Nr", nullable=true)
		public int mandantNr

		@Column(name="SUM(a.Betrag)", nullable=true)
		public double summe

		@Column(name="SUM(a.EBetrag)", nullable=true)
		public double esumme
	}

	/** 
	 */
	static class VoDruck {

		@Column(name="", nullable=true)
		public String nr

		@Column(name="", nullable=true)
		public String name

		@Column(name="", nullable=true)
		public double betrag

		@Column(name="", nullable=true)
		public String nr2

		@Column(name="", nullable=true)
		public String name2

		@Column(name="", nullable=true)
		public double betrag2
	}

	/** Bilanz-Liste lesen. */
	override List<HhBilanz> getBilanzListe(ServiceDaten daten, String kz, int pnrvon, int pnrbis, String kontoUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kz)) {
			sql.append(null, HhBilanz.KZ_NAME, "=", kz, null)
		}
		if (pnrvon > Constant.PN_BERECHNET) {
			if (pnrvon == pnrbis) {
				sql.append(null, HhBilanz.PERIODE_NAME, "=", pnrvon, null)
			} else {
				sql.append(null, HhBilanz.PERIODE_NAME, ">=", pnrvon, null)
			}
		}
		if (pnrbis > Constant.PN_BERECHNET && pnrvon != pnrbis) {
			sql.append(null, HhBilanz.PERIODE_NAME, "<=", pnrbis, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBilanz.KONTO_UID_NAME, "=", kontoUid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Bilanz-SB-Liste lesen. */
	override List<HhBilanzSb> getBilanzSbListe(ServiceDaten daten, String kz, int pnrvon, int pnrbis, String kontoUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kz)) {
			sql.append(null, HhBilanz.KZ_NAME, "=", kz, null)
		}
		if (pnrvon > Constant.PN_BERECHNET) {
			if (pnrvon == pnrbis) {
				sql.append(null, HhBilanz.PERIODE_NAME, "=", pnrvon, null)
			} else {
				sql.append(null, HhBilanz.PERIODE_NAME, ">=", pnrvon, null)
			}
		}
		if (pnrbis > Constant.PN_BERECHNET && pnrvon != pnrbis) {
			sql.append(null, HhBilanz.PERIODE_NAME, "<=", pnrbis, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBilanz.KONTO_UID_NAME, "=", kontoUid, null)
		}
		var l = getListeSb(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Bilanz-Summe-Liste lesen. */
	override List<HhBilanzSumme> getBilanzSummeListe(ServiceDaten daten, String kz, int pnr, String kontoUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kz)) {
			sql.append(null, HhBilanz.KZ_NAME, "=", kz, null)
		}
		if (pnr > Constant.PN_BERECHNET) {
			sql.append(null, HhBilanz.PERIODE_NAME, "=", pnr, null)
		}
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBilanz.KONTO_UID_NAME, "<>", kontoUid, null)
		}
		var l = getListeSumme(daten, daten.mandantNr, sql, null)
		return l
	}

	override void deleteKontoVonBis(ServiceDaten daten, String kontoUid, int perVon, int perBis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(kontoUid)) {
			sql.append(null, HhBilanz.KONTO_UID_NAME, "=", kontoUid, null)
		}
		if (perVon > 0) {
			sql.append(null, HhBilanz.PERIODE_NAME, "<", perVon, null)
		}
		if (perBis > 0) {
			sql.append(null, HhBilanz.PERIODE_NAME, ">", perBis, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		for (HhBilanz b : l) {
			delete(daten, b)
		}
	}

	/**
	 * Anlegen oder Ändern eines Bilanz-Eintrages.
	 * @param daten Service-Daten für Datenbankzugriff.
	 * @param pnr Perioden-Nummer.
	 * @param strK Bilanz-Kennzeichen.
	 * @param kontoUid Konto-Nummer.
	 * @param strSh DM-Soll/Haben-Kennzeichen.
	 * @param dbB DM-Betrag.
	 * @param strESh Euro-Soll/Haben-Kennzeichen.
	 * @param dbEB Euro-Betrag.
	 * @param nurBetrag Schalter, ob nur der Betrag addiert werden soll.
	 */
	override void iuBilanz(ServiceDaten daten, int pnr, String strK, String kontoUid, String strSh, double dbB,
		String strESh, double dbEB, boolean nurBetrag) {

		var hhBilanz2 = get(daten, new HhBilanzKey(daten.mandantNr, pnr, strK, kontoUid))
		if (hhBilanz2 === null) {
			if (nurBetrag) {
				throw new MeldungException("Kein Bilanzsatz vorhanden! (Per. " + pnr + ", Kto. " + kontoUid + ")");
			}
			var hhBilanz = new HhBilanz()
			hhBilanz.setMandantNr(daten.mandantNr)
			hhBilanz.setPeriode(pnr)
			hhBilanz.setKz(strK)
			hhBilanz.setKontoUid(kontoUid)
			hhBilanz.setSh(strSh)
			hhBilanz.setBetrag(dbB)
			hhBilanz.setEsh(strESh)
			hhBilanz.setEbetrag(dbEB)
			hhBilanz.machAngelegt(daten.jetzt, daten.benutzerId)
			insert(daten, hhBilanz)
		} else {
			var hhBilanzU = new HhBilanzUpdate(hhBilanz2)
			if (nurBetrag) {
				hhBilanzU.setBetrag(hhBilanz2.betrag + dbB)
				hhBilanzU.setEbetrag(hhBilanz2.ebetrag + dbEB)
			} else {
				hhBilanzU.setSh(strSh)
				hhBilanzU.setBetrag(dbB)
				hhBilanzU.setEsh(strESh)
				hhBilanzU.setEbetrag(dbEB)
			}
			if (hhBilanzU.isChanged) {
				hhBilanzU.machGeaendert(daten.jetzt, daten.benutzerId)
				update(daten, hhBilanzU)
			}
		}
	}
}

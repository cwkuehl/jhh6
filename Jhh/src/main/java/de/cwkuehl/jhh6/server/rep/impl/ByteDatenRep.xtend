package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.ByteDatenUpdate
import de.cwkuehl.jhh6.api.global.Global
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
@Table(name="Byte_Daten")
class ByteDatenRep {

	/**  
	 * WHERE Mandant_Nr: eq
	 * WHERE Typ: eq
	 * WHERE Uid: eq
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Typ")
		@Column(name="Typ", length=20, nullable=true)
		public String typ

		@PrimaryKeyJoinColumn(name="Uid")
		@Column(name="Uid", length=35, nullable=true)
		public String uid

		@PrimaryKeyJoinColumn(name="Lfd_Nr")
		@Column(name="Lfd_Nr", nullable=true)
		public int lfdNr

		@Column(name="Metadaten", nullable=true)
		public String metadaten

		@Column(name="Bytes", nullable=true)
		public byte[] bytes

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** Bytes-Liste lesen. */
	override public List<ByteDaten> getBytesListe(ServiceDaten daten, String typ, String uid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nes(typ)) {
			sql.append(null, ByteDaten.TYP_NAME, "=", typ, null)
		}
		if (!Global.nes(uid)) {
			sql.append(null, ByteDaten.UID_NAME, "=", uid, null)
		}
		var l = getListe(daten, daten.mandantNr, sql, null)
		return l
	}

	/** Bytes-Liste lesen. */
	override public void saveBytesListe(ServiceDaten daten, String typ, String uid, List<ByteDaten> byteliste) {

		var liste = getBytesListe(daten, typ, uid)
		var anzahl = Global.listLaenge(byteliste)
		var ByteDaten bds = null
		var ByteDaten bdn = null
		for (var nr = 1; nr <= anzahl; nr++) {
			bdn = byteliste.get(nr - 1)
			bds = null;
			for (ByteDaten bd : liste) {
				if (bd.lfdNr == nr) {
					bds = bd;
				}
			}
			if (bds === null) {
				var bd = new ByteDaten
				bd.setMandantNr(daten.mandantNr)
				bd.setTyp(typ)
				bd.setUid(uid)
				bd.setLfdNr(nr)
				bd.setMetadaten(bdn.metadaten)
				bd.setBytes(bdn.bytes)
				bd.machAngelegt(daten.jetzt, daten.benutzerId)
				insert(daten, bd)
			} else {
				var bdu = new ByteDatenUpdate(bds)
				bdu.setMetadaten(bdn.metadaten)
				bdu.setBytes(bdn.bytes)
				if (bdu.isChanged) {
					bdu.machGeaendert(daten.jetzt, daten.benutzerId)
					update(daten, bdu)
				}
				liste.remove(bds)
			}
		}

		// restliche ByteDaten löschen
		for (ByteDaten bd : liste) {
			delete(daten, bd)
		}
	}
}

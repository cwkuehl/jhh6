package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.Benutzer
import de.cwkuehl.jhh6.api.dto.BenutzerLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List

@Repository
@Table(name="Benutzer")
class BenutzerRep {

	/**  
	 * WHERE Mandant_Nr: eq
	 * WHERE Benutzer_ID: eq
	 * WHERE Person_Nr: eq ne
	 * ORDER BY BENUTZER_ID: Mandant_Nr, Benutzer_ID, Person_Nr
	 * ORDER BY PERSON_NR: Mandant_Nr, Person_Nr
	 */
	static class Vo {

		@PrimaryKeyJoinColumn(name="Mandant_Nr", referencedColumnName="Nr")
		@ManyToOne(targetEntity=typeof(MaMandantRep))
		@Column(name="Mandant_Nr", nullable=true)
		public int mandantNr

		@PrimaryKeyJoinColumn(name="Benutzer_ID")
		@Column(name="Benutzer_ID", length=20, nullable=true)
		public String benutzerId

		@Column(name="Passwort", length=50, nullable=true)
		public String passwort

		@Column(name="Berechtigung", nullable=false)
		public int berechtigung

		@Column(name="Akt_Periode", nullable=false)
		public int aktPeriode

		@Column(name="Person_Nr", nullable=false)
		public int personNr

		@Column(name="Geburt", nullable=true)
		public LocalDate geburt

		@Column(name="Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm
	}

	/** SelectFrom: Benutzer a
	 */
	static class VoLang {

		@Column(name="a.Person_Nr", nullable=false)
		public int personNr

		@Column(name="a.Benutzer_ID", length=20, nullable=true)
		public String benutzerId

		@Column(name="a.Passwort", length=50, nullable=true)
		public String passwort

		@Column(name="a.Berechtigung", nullable=false)
		public int berechtigung

		@Column(name="a.Geburt", nullable=true)
		public LocalDate geburt

		@Column(name="a.Angelegt_Von", length=20, nullable=true)
		public String angelegtVon

		@Column(name="a.Angelegt_Am", nullable=true)
		public LocalDateTime angelegtAm

		@Column(name="a.Geaendert_Von", length=20, nullable=true)
		public String geaendertVon

		@Column(name="a.Geaendert_Am", nullable=true)
		public LocalDateTime geaendertAm

		@Column(name="''", nullable=true)
		public String rechte
	}

	/** Benutzer-Lang-Liste lesen. */
	override List<BenutzerLang> getBenutzerLangListe(ServiceDaten daten, int nr, String id, int nrne) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (nr > 0) {
			sql.append(null, Benutzer.PERSON_NR_NAME, "=", nr, null)
		}
		if (nrne > 0) {
			sql.append(null, Benutzer.PERSON_NR_NAME, "<>", nrne, null)
		}
		if (!Global.nes(id)) {
			sql.append(null, Benutzer.BENUTZER_ID_NAME, "=", id, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Benutzer_ID, a.Person_Nr")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

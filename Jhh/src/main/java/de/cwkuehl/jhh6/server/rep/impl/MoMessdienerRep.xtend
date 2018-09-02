package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.api.dto.MoMessdiener
import de.cwkuehl.jhh6.api.dto.MoMessdienerLang
import de.cwkuehl.jhh6.api.enums.MoStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.ManyToOne
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import de.cwkuehl.jhh6.generator.annotation.Table
import de.cwkuehl.jhh6.server.base.SqlBuilder
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.List

@Repository
@Table(name="MO_Messdiener")
class MoMessdienerRep {

	/** 
	 * Replication-Nr. 40 Attribut Uid 
	 * WHERE Mandant_Nr: eq
	 * WHERE Uid: eq
	 * WHERE Messdiener_Uid: eq
	 * WHERE Name: eq
	 * WHERE Vorname: eq
	 * WHERE Von: le
	 * WHERE Bis: geOrNull
	 * WHERE Verfuegbarkeit: like
	 * WHERE Dienste: like
	 * WHERE Status: eq
	 * ORDER BY NAME: Mandant_Nr, Name, Vorname, Uid
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

		@Column(name="Name", length=50, nullable=false)
		public String name

		@Column(name="Vorname", length=50, nullable=true)
		public String vorname

		@Column(name="Von", nullable=false)
		public LocalDate von

		@Column(name="Bis", nullable=true)
		public LocalDate bis

		@Column(name="Adresse1", length=50, nullable=true)
		public String adresse1

		@Column(name="Adresse2", length=50, nullable=true)
		public String adresse2

		@Column(name="Adresse3", length=50, nullable=true)
		public String adresse3

		@Column(name="Email", length=40, nullable=true)
		public String email

		@Column(name="Email2", length=40, nullable=true)
		public String email2

		@Column(name="Telefon", length=40, nullable=true)
		public String telefon

		@Column(name="Telefon2", length=40, nullable=true)
		public String telefon2

		@Column(name="Verfuegbarkeit", length=-1, nullable=true)
		public String verfuegbarkeit

		@Column(name="Dienste", length=-1, nullable=true)
		public String dienste

		@Column(name="Messdiener_Uid", length=35, nullable=true)
		public String messdienerUid

		@Column(name="Status", length=10, nullable=false) // null in Datenbank
		public String status

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

	/** SelectFrom: (MO_MESSDIENER a
	 *   left join MO_MESSDIENER b on a.Mandant_Nr=b.Mandant_Nr and a.Messdiener_Uid=b.Uid)
	 */
	static class VoLang {

		@Column(name="a.Uid", length=35, nullable=true)
		public String uid

		@Column(name="a.Name", length=50, nullable=false)
		public String name

		@Column(name="a.Vorname", length=50, nullable=true)
		public String vorname

		@Column(name="a.Von", nullable=false)
		public LocalDate von

		@Column(name="a.Bis", nullable=true)
		public LocalDate bis

		@Column(name="a.Adresse1", length=50, nullable=true)
		public String adresse1

		@Column(name="a.Adresse2", length=50, nullable=true)
		public String adresse2

		@Column(name="a.Adresse3", length=50, nullable=true)
		public String adresse3

		@Column(name="a.Email", length=40, nullable=true)
		public String email

		@Column(name="a.Email2", length=40, nullable=true)
		public String email2

		@Column(name="a.Telefon", length=40, nullable=true)
		public String telefon

		@Column(name="a.Telefon2", length=40, nullable=true)
		public String telefon2

		@Column(name="a.Verfuegbarkeit", nullable=true)
		public String verfuegbarkeit

		@Column(name="a.Dienste", nullable=true)
		public String dienste

		@Column(name="a.Messdiener_Uid", length=35, nullable=true)
		public String messdienerUid

		@Column(name="a.Status", length=10, nullable=false)
		public String status

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

		@Column(name="b.Name", nullable=true)
		public String messdienerName

		@Column(name="b.Vorname", nullable=true)
		public String messdienerVorname

		@Column(name="NULL", nullable=true)
		public LocalDateTime termin

		@Column(name="NULL", nullable=true)
		public String info
	}

	/** Messdiener-Liste lesen. */
	override List<MoMessdiener> getMessdienerListe(ServiceDaten daten, String name, String vorname, String mitUid) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (!Global.nesLike(name)) {
			sql.append(null, MoMessdiener.NAME_NAME, "like", name, null)
		}
		if (!Global.nesLike(vorname)) {
			sql.append(null, MoMessdiener.VORNAME_NAME, "like", vorname, null)
		}
		if (!Global.nes(mitUid)) {
			sql.append(null, MoMessdiener.MESSDIENER_UID_NAME, "=", mitUid, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Name, a.Vorname, a.Uid")
		var l = getListe(daten, daten.mandantNr, sql, order)
		return l
	}

	/** Messdiener-Lang-Liste lesen. */
	override List<MoMessdienerLang> getMessdienerLangListe(ServiceDaten daten, boolean automatisch,
		LocalDateTime termin, String dienst, LocalDate von, LocalDate bis) {

		var sql = new SqlBuilder
		sql.praefix(null, " AND ")
		if (automatisch) {
			if (termin !== null) {
				var v = termin.format(DateTimeFormatter.ofPattern("%EEE%"))
				if (termin.dayOfWeek == DayOfWeek.SUNDAY) {
					// Sonntag muss auch die Zeit stimmen.
					v = termin.format(DateTimeFormatter.ofPattern("%EEE HH:%"))
				}
				sql.append(null, MoMessdiener.VERFUEGBARKEIT_NAME, "like", v, null)
			}
			if (!Global.nesLike(dienst)) {
				sql.append(null, MoMessdiener.DIENSTE_NAME, "like", '''%«dienst»%'''.toString, null)
			}
			sql.append(null, MoMessdiener.STATUS_NAME, "=", MoStatusEnum.AUTOMATISCH.toString, null)
		}
		if (termin !== null) {
			sql.append(null, MoMessdiener.VON_NAME, "<=", termin, null)
			sql.append("(", '''a.«MoMessdiener.BIS_NAME» IS NULL OR a.«MoMessdiener.BIS_NAME»''', ">=",
				termin.plusDays(1), ")")
		}

		// Dienten im Zeitraum von:
		// if (von != null) {
		// // Auszugdatum >= von oder null
		// wo.setBisGeOrNull(von);
		// }
		// if (bis != null) {
		// // Einzugdatum <= bis
		// wo.setVonLe(bis);
		// }
		// Messdiener seit:
		if (bis !== null) {
			// Austritt im Zeitraum
			if (von !== null) {
				sql.append(null, MoMessdiener.BIS_NAME, ">=", von, null)
			}
			sql.append(null, MoMessdiener.BIS_NAME, "<=", bis, null)
		} else if (von !== null) {
			sql.append(null, MoMessdiener.VON_NAME, ">=", von, null)
		}
		var order = new SqlBuilder("a.Mandant_Nr, a.Name, a.Vorname, a.Uid")
		var l = getListeLang(daten, daten.mandantNr, sql, order)
		return l
	}
}

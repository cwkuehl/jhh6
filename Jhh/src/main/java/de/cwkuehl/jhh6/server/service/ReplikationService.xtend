package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.AdAdresse
import de.cwkuehl.jhh6.api.dto.AdAdresseKey
import de.cwkuehl.jhh6.api.dto.AdAdresseUpdate
import de.cwkuehl.jhh6.api.dto.AdPerson
import de.cwkuehl.jhh6.api.dto.AdPersonKey
import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.dto.AdPersonUpdate
import de.cwkuehl.jhh6.api.dto.AdSitz
import de.cwkuehl.jhh6.api.dto.AdSitzKey
import de.cwkuehl.jhh6.api.dto.AdSitzUpdate
import de.cwkuehl.jhh6.api.dto.Benutzer
import de.cwkuehl.jhh6.api.dto.BenutzerKey
import de.cwkuehl.jhh6.api.dto.BenutzerUpdate
import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.ByteDatenKey
import de.cwkuehl.jhh6.api.dto.ByteDatenUpdate
import de.cwkuehl.jhh6.api.dto.FzBuch
import de.cwkuehl.jhh6.api.dto.FzBuchKey
import de.cwkuehl.jhh6.api.dto.FzBuchUpdate
import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.dto.FzBuchautorKey
import de.cwkuehl.jhh6.api.dto.FzBuchautorUpdate
import de.cwkuehl.jhh6.api.dto.FzBuchserie
import de.cwkuehl.jhh6.api.dto.FzBuchserieKey
import de.cwkuehl.jhh6.api.dto.FzBuchserieUpdate
import de.cwkuehl.jhh6.api.dto.FzBuchstatus
import de.cwkuehl.jhh6.api.dto.FzBuchstatusKey
import de.cwkuehl.jhh6.api.dto.FzBuchstatusUpdate
import de.cwkuehl.jhh6.api.dto.FzFahrrad
import de.cwkuehl.jhh6.api.dto.FzFahrradKey
import de.cwkuehl.jhh6.api.dto.FzFahrradUpdate
import de.cwkuehl.jhh6.api.dto.FzFahrradstand
import de.cwkuehl.jhh6.api.dto.FzFahrradstandKey
import de.cwkuehl.jhh6.api.dto.FzFahrradstandUpdate
import de.cwkuehl.jhh6.api.dto.FzNotiz
import de.cwkuehl.jhh6.api.dto.FzNotizKey
import de.cwkuehl.jhh6.api.dto.FzNotizUpdate
import de.cwkuehl.jhh6.api.dto.HhBilanz
import de.cwkuehl.jhh6.api.dto.HhBilanzKey
import de.cwkuehl.jhh6.api.dto.HhBilanzUpdate
import de.cwkuehl.jhh6.api.dto.HhBuchung
import de.cwkuehl.jhh6.api.dto.HhBuchungKey
import de.cwkuehl.jhh6.api.dto.HhBuchungUpdate
import de.cwkuehl.jhh6.api.dto.HhEreignis
import de.cwkuehl.jhh6.api.dto.HhEreignisKey
import de.cwkuehl.jhh6.api.dto.HhEreignisUpdate
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.api.dto.HhKontoKey
import de.cwkuehl.jhh6.api.dto.HhKontoUpdate
import de.cwkuehl.jhh6.api.dto.HhPeriode
import de.cwkuehl.jhh6.api.dto.HhPeriodeKey
import de.cwkuehl.jhh6.api.dto.HhPeriodeUpdate
import de.cwkuehl.jhh6.api.dto.HpBehandlung
import de.cwkuehl.jhh6.api.dto.HpBehandlungKey
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistung
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungKey
import de.cwkuehl.jhh6.api.dto.HpBehandlungLeistungUpdate
import de.cwkuehl.jhh6.api.dto.HpBehandlungUpdate
import de.cwkuehl.jhh6.api.dto.HpLeistung
import de.cwkuehl.jhh6.api.dto.HpLeistungKey
import de.cwkuehl.jhh6.api.dto.HpLeistungUpdate
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppe
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppeKey
import de.cwkuehl.jhh6.api.dto.HpLeistungsgruppeUpdate
import de.cwkuehl.jhh6.api.dto.HpPatient
import de.cwkuehl.jhh6.api.dto.HpPatientKey
import de.cwkuehl.jhh6.api.dto.HpPatientUpdate
import de.cwkuehl.jhh6.api.dto.HpRechnung
import de.cwkuehl.jhh6.api.dto.HpRechnungKey
import de.cwkuehl.jhh6.api.dto.HpRechnungUpdate
import de.cwkuehl.jhh6.api.dto.HpStatus
import de.cwkuehl.jhh6.api.dto.HpStatusKey
import de.cwkuehl.jhh6.api.dto.HpStatusUpdate
import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.MaEinstellungKey
import de.cwkuehl.jhh6.api.dto.MaEinstellungUpdate
import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.dto.MaMandantKey
import de.cwkuehl.jhh6.api.dto.MaMandantUpdate
import de.cwkuehl.jhh6.api.dto.MaParameter
import de.cwkuehl.jhh6.api.dto.MaParameterKey
import de.cwkuehl.jhh6.api.dto.MaParameterUpdate
import de.cwkuehl.jhh6.api.dto.MoEinteilung
import de.cwkuehl.jhh6.api.dto.MoEinteilungKey
import de.cwkuehl.jhh6.api.dto.MoEinteilungUpdate
import de.cwkuehl.jhh6.api.dto.MoGottesdienst
import de.cwkuehl.jhh6.api.dto.MoGottesdienstKey
import de.cwkuehl.jhh6.api.dto.MoGottesdienstUpdate
import de.cwkuehl.jhh6.api.dto.MoMessdiener
import de.cwkuehl.jhh6.api.dto.MoMessdienerKey
import de.cwkuehl.jhh6.api.dto.MoMessdienerUpdate
import de.cwkuehl.jhh6.api.dto.MoProfil
import de.cwkuehl.jhh6.api.dto.MoProfilKey
import de.cwkuehl.jhh6.api.dto.MoProfilUpdate
import de.cwkuehl.jhh6.api.dto.SbEreignis
import de.cwkuehl.jhh6.api.dto.SbEreignisKey
import de.cwkuehl.jhh6.api.dto.SbEreignisUpdate
import de.cwkuehl.jhh6.api.dto.SbFamilie
import de.cwkuehl.jhh6.api.dto.SbFamilieKey
import de.cwkuehl.jhh6.api.dto.SbFamilieUpdate
import de.cwkuehl.jhh6.api.dto.SbKind
import de.cwkuehl.jhh6.api.dto.SbKindKey
import de.cwkuehl.jhh6.api.dto.SbKindUpdate
import de.cwkuehl.jhh6.api.dto.SbPerson
import de.cwkuehl.jhh6.api.dto.SbPersonKey
import de.cwkuehl.jhh6.api.dto.SbPersonUpdate
import de.cwkuehl.jhh6.api.dto.SbQuelle
import de.cwkuehl.jhh6.api.dto.SbQuelleKey
import de.cwkuehl.jhh6.api.dto.SbQuelleUpdate
import de.cwkuehl.jhh6.api.dto.TbEintrag
import de.cwkuehl.jhh6.api.dto.TbEintragKey
import de.cwkuehl.jhh6.api.dto.TbEintragUpdate
import de.cwkuehl.jhh6.api.dto.VmAbrechnung
import de.cwkuehl.jhh6.api.dto.VmAbrechnungKey
import de.cwkuehl.jhh6.api.dto.VmAbrechnungUpdate
import de.cwkuehl.jhh6.api.dto.VmBuchung
import de.cwkuehl.jhh6.api.dto.VmBuchungKey
import de.cwkuehl.jhh6.api.dto.VmBuchungUpdate
import de.cwkuehl.jhh6.api.dto.VmEreignis
import de.cwkuehl.jhh6.api.dto.VmEreignisKey
import de.cwkuehl.jhh6.api.dto.VmEreignisUpdate
import de.cwkuehl.jhh6.api.dto.VmHaus
import de.cwkuehl.jhh6.api.dto.VmHausKey
import de.cwkuehl.jhh6.api.dto.VmHausUpdate
import de.cwkuehl.jhh6.api.dto.VmKonto
import de.cwkuehl.jhh6.api.dto.VmKontoKey
import de.cwkuehl.jhh6.api.dto.VmKontoUpdate
import de.cwkuehl.jhh6.api.dto.VmMiete
import de.cwkuehl.jhh6.api.dto.VmMieteKey
import de.cwkuehl.jhh6.api.dto.VmMieteUpdate
import de.cwkuehl.jhh6.api.dto.VmMieter
import de.cwkuehl.jhh6.api.dto.VmMieterKey
import de.cwkuehl.jhh6.api.dto.VmMieterUpdate
import de.cwkuehl.jhh6.api.dto.VmWohnung
import de.cwkuehl.jhh6.api.dto.VmWohnungKey
import de.cwkuehl.jhh6.api.dto.VmWohnungUpdate
import de.cwkuehl.jhh6.api.dto.Zeinstellung
import de.cwkuehl.jhh6.api.dto.ZeinstellungKey
import de.cwkuehl.jhh6.api.dto.ZeinstellungUpdate
import de.cwkuehl.jhh6.api.enums.FzFahrradTypEnum
import de.cwkuehl.jhh6.api.enums.KontoartEnum
import de.cwkuehl.jhh6.api.enums.KontokennzeichenEnum
import de.cwkuehl.jhh6.api.enums.SpracheEnum
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.rollback.RollbackArtEnum
import de.cwkuehl.jhh6.api.rollback.RollbackListe
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.ServiceRef
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.base.RbRepository
import de.cwkuehl.jhh6.server.base.RemoteDb
import de.cwkuehl.jhh6.server.rep.IAdAdresseRep
import de.cwkuehl.jhh6.server.rep.IAdPersonRep
import de.cwkuehl.jhh6.server.rep.IAdSitzRep
import de.cwkuehl.jhh6.server.rep.IBenutzerRep
import de.cwkuehl.jhh6.server.rep.IByteDatenRep
import de.cwkuehl.jhh6.server.rep.IFzBuchRep
import de.cwkuehl.jhh6.server.rep.IFzBuchautorRep
import de.cwkuehl.jhh6.server.rep.IFzBuchserieRep
import de.cwkuehl.jhh6.server.rep.IFzBuchstatusRep
import de.cwkuehl.jhh6.server.rep.IFzFahrradRep
import de.cwkuehl.jhh6.server.rep.IFzFahrradstandRep
import de.cwkuehl.jhh6.server.rep.IFzNotizRep
import de.cwkuehl.jhh6.server.rep.IHhBilanzRep
import de.cwkuehl.jhh6.server.rep.IHhBuchungRep
import de.cwkuehl.jhh6.server.rep.IHhEreignisRep
import de.cwkuehl.jhh6.server.rep.IHhKontoRep
import de.cwkuehl.jhh6.server.rep.IHhPeriodeRep
import de.cwkuehl.jhh6.server.rep.IHpBehandlungLeistungRep
import de.cwkuehl.jhh6.server.rep.IHpBehandlungRep
import de.cwkuehl.jhh6.server.rep.IHpLeistungRep
import de.cwkuehl.jhh6.server.rep.IHpLeistungsgruppeRep
import de.cwkuehl.jhh6.server.rep.IHpPatientRep
import de.cwkuehl.jhh6.server.rep.IHpRechnungRep
import de.cwkuehl.jhh6.server.rep.IHpStatusRep
import de.cwkuehl.jhh6.server.rep.IMaEinstellungRep
import de.cwkuehl.jhh6.server.rep.IMaMandantRep
import de.cwkuehl.jhh6.server.rep.IMaParameterRep
import de.cwkuehl.jhh6.server.rep.IMoEinteilungRep
import de.cwkuehl.jhh6.server.rep.IMoGottesdienstRep
import de.cwkuehl.jhh6.server.rep.IMoMessdienerRep
import de.cwkuehl.jhh6.server.rep.IMoProfilRep
import de.cwkuehl.jhh6.server.rep.ISbEreignisRep
import de.cwkuehl.jhh6.server.rep.ISbFamilieRep
import de.cwkuehl.jhh6.server.rep.ISbKindRep
import de.cwkuehl.jhh6.server.rep.ISbPersonRep
import de.cwkuehl.jhh6.server.rep.ISbQuelleRep
import de.cwkuehl.jhh6.server.rep.ITbEintragRep
import de.cwkuehl.jhh6.server.rep.IVmAbrechnungRep
import de.cwkuehl.jhh6.server.rep.IVmBuchungRep
import de.cwkuehl.jhh6.server.rep.IVmEreignisRep
import de.cwkuehl.jhh6.server.rep.IVmHausRep
import de.cwkuehl.jhh6.server.rep.IVmKontoRep
import de.cwkuehl.jhh6.server.rep.IVmMieteRep
import de.cwkuehl.jhh6.server.rep.IVmMieterRep
import de.cwkuehl.jhh6.server.rep.IVmWohnungRep
import de.cwkuehl.jhh6.server.rep.IZeinstellungRep
import de.cwkuehl.jhh6.server.rep.impl.AdAdresseRep
import de.cwkuehl.jhh6.server.rep.impl.AdPersonRep
import de.cwkuehl.jhh6.server.rep.impl.AdSitzRep
import de.cwkuehl.jhh6.server.rep.impl.BenutzerRep
import de.cwkuehl.jhh6.server.rep.impl.ByteDatenRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchautorRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchserieRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchstatusRep
import de.cwkuehl.jhh6.server.rep.impl.FzFahrradRep
import de.cwkuehl.jhh6.server.rep.impl.FzFahrradstandRep
import de.cwkuehl.jhh6.server.rep.impl.FzNotizRep
import de.cwkuehl.jhh6.server.rep.impl.HhBilanzRep
import de.cwkuehl.jhh6.server.rep.impl.HhBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.HhEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.HhKontoRep
import de.cwkuehl.jhh6.server.rep.impl.HhPeriodeRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungLeistungRep
import de.cwkuehl.jhh6.server.rep.impl.HpBehandlungRep
import de.cwkuehl.jhh6.server.rep.impl.HpLeistungRep
import de.cwkuehl.jhh6.server.rep.impl.HpLeistungsgruppeRep
import de.cwkuehl.jhh6.server.rep.impl.HpPatientRep
import de.cwkuehl.jhh6.server.rep.impl.HpRechnungRep
import de.cwkuehl.jhh6.server.rep.impl.HpStatusRep
import de.cwkuehl.jhh6.server.rep.impl.MaEinstellungRep
import de.cwkuehl.jhh6.server.rep.impl.MaMandantRep
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.MoEinteilungRep
import de.cwkuehl.jhh6.server.rep.impl.MoGottesdienstRep
import de.cwkuehl.jhh6.server.rep.impl.MoMessdienerRep
import de.cwkuehl.jhh6.server.rep.impl.MoProfilRep
import de.cwkuehl.jhh6.server.rep.impl.SbEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.SbFamilieRep
import de.cwkuehl.jhh6.server.rep.impl.SbKindRep
import de.cwkuehl.jhh6.server.rep.impl.SbPersonRep
import de.cwkuehl.jhh6.server.rep.impl.SbQuelleRep
import de.cwkuehl.jhh6.server.rep.impl.TbEintragRep
import de.cwkuehl.jhh6.server.rep.impl.VmAbrechnungRep
import de.cwkuehl.jhh6.server.rep.impl.VmBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.VmEreignisRep
import de.cwkuehl.jhh6.server.rep.impl.VmHausRep
import de.cwkuehl.jhh6.server.rep.impl.VmKontoRep
import de.cwkuehl.jhh6.server.rep.impl.VmMieteRep
import de.cwkuehl.jhh6.server.rep.impl.VmMieterRep
import de.cwkuehl.jhh6.server.rep.impl.VmWohnungRep
import de.cwkuehl.jhh6.server.rep.impl.ZeinstellungRep
import de.cwkuehl.jhh6.server.service.impl.ReplTabelle
import java.util.List

@Service
class ReplikationService {

	@ServiceRef AdresseService adresseService
	@ServiceRef FreizeitService freizeitService
	@ServiceRef HaushaltService haushaltService
	@ServiceRef HeilpraktikerService hpService
	@ServiceRef TagebuchService tagebuchService
	@RepositoryRef AdAdresseRep adresseRep
	@RepositoryRef AdPersonRep personRep
	@RepositoryRef AdSitzRep sitzRep
	@RepositoryRef BenutzerRep benutzerRep
	@RepositoryRef ByteDatenRep byteRep
	@RepositoryRef FzBuchRep buchRep
	@RepositoryRef FzBuchautorRep buchautorRep
	@RepositoryRef FzBuchserieRep buchserieRep
	@RepositoryRef FzBuchstatusRep buchstatusRep
	@RepositoryRef FzFahrradRep fahrradRep
	@RepositoryRef FzFahrradstandRep fahrradstandRep
	@RepositoryRef FzNotizRep notizRep
	@RepositoryRef HhBilanzRep bilanzRep
	@RepositoryRef HhBuchungRep buchungRep
	@RepositoryRef HhEreignisRep ereignisRep
	@RepositoryRef HhKontoRep kontoRep
	@RepositoryRef HhPeriodeRep periodeRep
	@RepositoryRef HpBehandlungRep behandlungRep
	@RepositoryRef HpBehandlungLeistungRep behleistRep
	@RepositoryRef HpLeistungRep leistungRep
	@RepositoryRef HpLeistungsgruppeRep leistgruppeRep
	@RepositoryRef HpPatientRep patientRep
	@RepositoryRef HpRechnungRep rechnungRep
	@RepositoryRef HpStatusRep statusRep
	@RepositoryRef MaEinstellungRep maeinstellungRep
	@RepositoryRef MaMandantRep mandantRep
	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef MoEinteilungRep einteilungRep
	@RepositoryRef MoGottesdienstRep gottesdienstRep
	@RepositoryRef MoMessdienerRep messdienerRep
	@RepositoryRef MoProfilRep profilRep
	@RepositoryRef SbEreignisRep sbereignisRep
	@RepositoryRef SbFamilieRep familieRep
	@RepositoryRef SbKindRep kindRep
	@RepositoryRef SbPersonRep sbpersonRep
	@RepositoryRef SbQuelleRep quelleRep
	@RepositoryRef TbEintragRep tagebuchRep
	@RepositoryRef VmAbrechnungRep abrechnungRep
	@RepositoryRef VmBuchungRep vmbuchungRep
	@RepositoryRef VmEreignisRep vmereignisRep
	@RepositoryRef VmHausRep hausRep
	@RepositoryRef VmKontoRep vmkontoRep
	@RepositoryRef VmMieteRep mieteRep
	@RepositoryRef VmMieterRep mieterRep
	@RepositoryRef VmWohnungRep wohnungRep
	// @RepositoryRef WpAnlageRep anlageRep
	// @RepositoryRef WpBuchungRep wpbuchungRep
	// @RepositoryRef WpKonfigurationRep konfigurationRep
	// @RepositoryRef WpStandRep standRep
	// @RepositoryRef WpWertpapierRep wertpapierRep
	@RepositoryRef ZeinstellungRep zeinstellungRep

	/**
	 * Create example database entries.
	 * @param daten Service-Daten für Datenbankzugriff.
	 */
	@Transaction
	override ServiceErgebnis<Void> createExamples(ServiceDaten daten) {

		var r = new ServiceErgebnis<Void>(null)
		var mnr = daten.mandantNr
		var e = maeinstellungRep.get(daten, new MaEinstellungKey(mnr, Constant.EINST_MA_EXAMPLES))
		if (e !== null && Global.strInt(e.wert) > 0) {
			// maeinstellungRep.iuMaEinstellung(daten, null, Constant.EINST_MA_EXAMPLES, "0", null, null, null, null)
			return r
		}
		var pl = personRep.getListe(daten, mnr, null, null)
		if (pl.size <= 0) {
			var p = new AdPersonSitzAdresse
			p.name1 = Meldungen.M9000
			p.name = Meldungen.M9000
			p.ort = Meldungen.M9000
			adresseService.insertUpdatePerson(daten, p)
		}
		var fl = fahrradRep.getListe(daten, mnr, null, null)
		if (fl.size <= 0) {
			var f = freizeitService.insertUpdateFahrrad(daten, null, Meldungen.M9000,
				Global.strInt(FzFahrradTypEnum.TOUR.toString)).ergebnis
			freizeitService.insertUpdateFahrradstand(daten, f.uid, daten.heute.atStartOfDay, 0, 10, 0, 20.5,
				Meldungen.M9000)
		}
		var bl = buchRep.getListe(daten, mnr, null, null)
		if (bl.size <= 0) {
			var a = freizeitService.insertUpdateAutor(daten, null, Meldungen.M9000, Meldungen.M9000).ergebnis
			var s = freizeitService.insertUpdateSerie(daten, null, Meldungen.M9000).ergebnis
			freizeitService.insertUpdateBuch(daten, null, a.uid, s.uid, 1, Meldungen.M9000, 200,
				SpracheEnum.ENGLISCH.toString, false, daten.heute, null)
		}
		var nl = notizRep.getListe(daten, mnr, null, null)
		if (nl.size <= 0) {
			freizeitService.insertUpdateNotiz(daten, null, Meldungen.M9000, Meldungen.M9000)
		}
		var kl = kontoRep.getListe(daten, mnr, null, null)
		if (kl.size <= 2) {
			haushaltService.anlegenPeriode(daten, 12, true)
			var ak = haushaltService.insertUpdateKonto(daten, null, KontoartEnum.AKTIVKONTO.toString,
				KontokennzeichenEnum.OHNE.toString, Meldungen.M9000 + " AK", null, null, null, null, null, null, //
				null, false).ergebnis
			var aw = haushaltService.insertUpdateKonto(daten, null, KontoartEnum.AUFWANDSKONTO.toString,
				KontokennzeichenEnum.OHNE.toString, Meldungen.M9000 + " AW", null, null, null, null, null, null, //
				null, false).ergebnis
			haushaltService.insertUpdateEreignis(daten, null, null, ak.uid, aw.uid, Meldungen.M9000, Meldungen.M9000,
				null, null, null, null, null, false)
			haushaltService.insertUpdateBuchung(daten, null, daten.heute, 1, 2.5, ak.uid, aw.uid, Meldungen.M9000,
				Meldungen.M9000, daten.heute, null, null, null, null, null, false)
		}
		var pal = patientRep.getListe(daten, mnr, null, null)
		if (pal.size <= 0) {
			var s = hpService.insertUpdateStatus(daten, null, Meldungen.M9000, Meldungen.M9000, 10, 10, null).ergebnis
			var l = hpService.insertUpdateLeistung(daten, null, Meldungen.M9000, null, Meldungen.M9000, null, 2, 10,
				null, null).ergebnis
			var l2 = hpService.insertUpdateLeistung(daten, null, Meldungen.M9000, null, Meldungen.M9000, null, 2, 10,
				null, null).ergebnis
			hpService.insertUpdateLeistungsgruppe(daten, null, Meldungen.M9000, l2.uid, 10, null, null)
			var p = hpService.insertUpdatePatient(daten, null, Meldungen.M9000 + "2", null, null, null, null, null,
				null, null, null, null, null).ergebnis
			var b = hpService.insertUpdateBehandlung(daten, null, p.uid, daten.heute, 10, Meldungen.M9000, l.uid, s.uid,
				null, null, null, null, null, null).ergebnis
			hpService.insertUpdateBehandlung(daten, null, p.uid, daten.heute, 20, Meldungen.M9000, l2.uid, s.uid, null,
				null, null, null, null, null)
			var bhl = hpService.getBehandlungLeistungListe(daten, true, p.uid, null, b.uid, null, null, false, true).
				ergebnis
			hpService.insertUpdateRechnung(daten, null, daten.heute.toString, daten.heute, p.uid, 22, Meldungen.M9000,
				s.uid, null, bhl)
		}
		var tl = tagebuchRep.getListe(daten, mnr, null, null)
		if (tl.size <= 0) {
			tagebuchService.speichereEintrag(daten, daten.heute, Meldungen.M9000)
		}
		maeinstellungRep.iuMaEinstellung(daten, null, Constant.EINST_MA_EXAMPLES, "1", null, null, null, null)
		return r
	}

	/**
	 * Durchführen eines Rollbacks.
	 * @param daten Service-Daten für Datenbankzugriff.
	 */
	@Transaction
	override ServiceErgebnis<Void> rollback(ServiceDaten daten) {

		daten.rbListe.rollbackRedo = true
		synchronized (rbStack) {
			var RollbackListe rbListe = null
			if (!rbStack.empty()) {
				rbListe = rbStack.peek
			}
			if (rbListe !== null) {
				rollbackIntern(daten, rbListe)
				redoStack.add(rbListe)
				rbStack.pop
			}
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	/**
	 * Wiederherstellen eines Rollbacks.
	 * @param daten Service-Daten für Datenbankzugriff.
	 */
	@Transaction
	override ServiceErgebnis<Void> redo(ServiceDaten daten) {

		daten.rbListe.rollbackRedo = true
		synchronized (redoStack) {
			var RollbackListe rbListe = null
			if (!redoStack.empty()) {
				rbListe = redoStack.peek
			}
			if (rbListe !== null) {
				redoIntern(daten, rbListe)
				rbStack.add(rbListe)
				redoStack.pop
			}
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	def private void init() {

		if (reps.size > 0)
			return
		var ad = new RbRepository(adresseRep, typeof(IAdAdresseRep), typeof(AdAdresseKey), typeof(AdAdresse),
			typeof(AdAdresseUpdate))
		reps.put(typeof(AdAdresse), ad)
		reps.put(typeof(AdAdresseUpdate), ad)

		var ps = new RbRepository(personRep, typeof(IAdPersonRep), typeof(AdPersonKey), typeof(AdPerson),
			typeof(AdPersonUpdate))
		reps.put(typeof(AdPerson), ps)
		reps.put(typeof(AdPersonUpdate), ps)

		var si = new RbRepository(sitzRep, typeof(IAdSitzRep), typeof(AdSitzKey), typeof(AdSitz), typeof(AdSitzUpdate))
		reps.put(typeof(AdSitz), si)
		reps.put(typeof(AdSitzUpdate), si)

		var bn = new RbRepository(benutzerRep, typeof(IBenutzerRep), typeof(BenutzerKey), typeof(Benutzer),
			typeof(BenutzerUpdate))
		reps.put(typeof(Benutzer), bn)
		reps.put(typeof(BenutzerUpdate), bn)

		var by = new RbRepository(byteRep, typeof(IByteDatenRep), typeof(ByteDatenKey), typeof(ByteDaten),
			typeof(ByteDatenUpdate))
		reps.put(typeof(ByteDaten), by)
		reps.put(typeof(ByteDatenUpdate), by)

		var bc = new RbRepository(buchRep, typeof(IFzBuchRep), typeof(FzBuchKey), typeof(FzBuch), typeof(FzBuchUpdate))
		reps.put(typeof(FzBuch), bc)
		reps.put(typeof(FzBuchUpdate), bc)

		var ba = new RbRepository(buchautorRep, typeof(IFzBuchautorRep), typeof(FzBuchautorKey), typeof(FzBuchautor),
			typeof(FzBuchautorUpdate))
		reps.put(typeof(FzBuchautor), ba)
		reps.put(typeof(FzBuchautorUpdate), ba)

		var bs = new RbRepository(buchserieRep, typeof(IFzBuchserieRep), typeof(FzBuchserieKey), typeof(FzBuchserie),
			typeof(FzBuchserieUpdate))
		reps.put(typeof(FzBuchserie), bs)
		reps.put(typeof(FzBuchserieUpdate), bs)

		var bt = new RbRepository(buchstatusRep, typeof(IFzBuchstatusRep), typeof(FzBuchstatusKey),
			typeof(FzBuchstatus), typeof(FzBuchstatusUpdate))
		reps.put(typeof(FzBuchstatus), bt)
		reps.put(typeof(FzBuchstatusUpdate), bt)

		var fa = new RbRepository(fahrradRep, typeof(IFzFahrradRep), typeof(FzFahrradKey), typeof(FzFahrrad),
			typeof(FzFahrradUpdate))
		reps.put(typeof(FzFahrrad), fa)
		reps.put(typeof(FzFahrradUpdate), fa)

		var fs = new RbRepository(fahrradstandRep, typeof(IFzFahrradstandRep), typeof(FzFahrradstandKey),
			typeof(FzFahrradstand), typeof(FzFahrradstandUpdate))
		reps.put(typeof(FzFahrradstand), fs)
		reps.put(typeof(FzFahrradstandUpdate), fs)

		var nz = new RbRepository(notizRep, typeof(IFzNotizRep), typeof(FzNotizKey), typeof(FzNotiz),
			typeof(FzNotizUpdate))
		reps.put(typeof(FzNotiz), nz)
		reps.put(typeof(FzNotizUpdate), nz)

		var bi = new RbRepository(bilanzRep, typeof(IHhBilanzRep), typeof(HhBilanzKey), typeof(HhBilanz),
			typeof(HhBilanzUpdate))
		reps.put(typeof(HhBilanz), bi)
		reps.put(typeof(HhBilanzUpdate), bi)

		var bu = new RbRepository(buchungRep, typeof(IHhBuchungRep), typeof(HhBuchungKey), typeof(HhBuchung),
			typeof(HhBuchungUpdate))
		reps.put(typeof(HhBuchung), bu)
		reps.put(typeof(HhBuchungUpdate), bu)

		var er = new RbRepository(ereignisRep, typeof(IHhEreignisRep), typeof(HhEreignisKey), typeof(HhEreignis),
			typeof(HhEreignisUpdate))
		reps.put(typeof(HhEreignis), er)
		reps.put(typeof(HhEreignisUpdate), er)

		var ko = new RbRepository(kontoRep, typeof(IHhKontoRep), typeof(HhKontoKey), typeof(HhKonto),
			typeof(HhKontoUpdate))
		reps.put(typeof(HhKonto), ko)
		reps.put(typeof(HhKontoUpdate), ko)

		var pe = new RbRepository(periodeRep, typeof(IHhPeriodeRep), typeof(HhPeriodeKey), typeof(HhPeriode),
			typeof(HhPeriodeUpdate))
		reps.put(typeof(HhPeriode), pe)
		reps.put(typeof(HhPeriodeUpdate), pe)

		var be = new RbRepository(behandlungRep, typeof(IHpBehandlungRep), typeof(HpBehandlungKey),
			typeof(HpBehandlung), typeof(HpBehandlungUpdate))
		reps.put(typeof(HpBehandlung), be)
		reps.put(typeof(HpBehandlungUpdate), be)

		var bl = new RbRepository(behleistRep, typeof(IHpBehandlungLeistungRep), typeof(HpBehandlungLeistungKey),
			typeof(HpBehandlungLeistung), typeof(HpBehandlungLeistungUpdate))
		reps.put(typeof(HpBehandlungLeistung), bl)
		reps.put(typeof(HpBehandlungLeistungUpdate), bl)

		var le = new RbRepository(leistungRep, typeof(IHpLeistungRep), typeof(HpLeistungKey), typeof(HpLeistung),
			typeof(HpLeistungUpdate))
		reps.put(typeof(HpLeistung), le)
		reps.put(typeof(HpLeistungUpdate), le)

		var lg = new RbRepository(leistgruppeRep, typeof(IHpLeistungsgruppeRep), typeof(HpLeistungsgruppeKey),
			typeof(HpLeistungsgruppe), typeof(HpLeistungsgruppeUpdate))
		reps.put(typeof(HpLeistungsgruppe), lg)
		reps.put(typeof(HpLeistungsgruppeUpdate), lg)

		var pt = new RbRepository(patientRep, typeof(IHpPatientRep), typeof(HpPatientKey), typeof(HpPatient),
			typeof(HpPatientUpdate))
		reps.put(typeof(HpPatient), pt)
		reps.put(typeof(HpPatientUpdate), pt)

		var re = new RbRepository(rechnungRep, typeof(IHpRechnungRep), typeof(HpRechnungKey), typeof(HpRechnung),
			typeof(HpRechnungUpdate))
		reps.put(typeof(HpRechnung), re)
		reps.put(typeof(HpRechnungUpdate), re)

		var st = new RbRepository(statusRep, typeof(IHpStatusRep), typeof(HpStatusKey), typeof(HpStatus),
			typeof(HpStatusUpdate))
		reps.put(typeof(HpStatus), st)
		reps.put(typeof(HpStatusUpdate), st)

		var en = new RbRepository(maeinstellungRep, typeof(IMaEinstellungRep), typeof(MaEinstellungKey),
			typeof(MaEinstellung), typeof(MaEinstellungUpdate))
		reps.put(typeof(MaEinstellung), en)
		reps.put(typeof(MaEinstellungUpdate), en)

		var ma = new RbRepository(mandantRep, typeof(IMaMandantRep), typeof(MaMandantKey), typeof(MaMandant),
			typeof(MaMandantUpdate))
		reps.put(typeof(MaMandant), ma)
		reps.put(typeof(MaMandantUpdate), ma)

		var pa = new RbRepository(parameterRep, typeof(IMaParameterRep), typeof(MaParameterKey), typeof(MaParameter),
			typeof(MaParameterUpdate))
		reps.put(typeof(MaParameter), pa)
		reps.put(typeof(MaParameterUpdate), pa)

		var et = new RbRepository(einteilungRep, typeof(IMoEinteilungRep), typeof(MoEinteilungKey),
			typeof(MoEinteilung), typeof(MoEinteilungUpdate))
		reps.put(typeof(MoEinteilung), et)
		reps.put(typeof(MoEinteilungUpdate), et)

		var go = new RbRepository(gottesdienstRep, typeof(IMoGottesdienstRep), typeof(MoGottesdienstKey),
			typeof(MoGottesdienst), typeof(MoGottesdienstUpdate))
		reps.put(typeof(MoGottesdienst), go)
		reps.put(typeof(MoGottesdienstUpdate), go)

		var me = new RbRepository(messdienerRep, typeof(IMoMessdienerRep), typeof(MoMessdienerKey),
			typeof(MoMessdiener), typeof(MoMessdienerUpdate))
		reps.put(typeof(MoMessdiener), me)
		reps.put(typeof(MoMessdienerUpdate), me)

		var pr = new RbRepository(profilRep, typeof(IMoProfilRep), typeof(MoProfilKey), typeof(MoProfil),
			typeof(MoProfilUpdate))
		reps.put(typeof(MoProfil), pr)
		reps.put(typeof(MoProfilUpdate), pr)

		var se = new RbRepository(sbereignisRep, typeof(ISbEreignisRep), typeof(SbEreignisKey), typeof(SbEreignis),
			typeof(SbEreignisUpdate))
		reps.put(typeof(SbEreignis), se)
		reps.put(typeof(SbEreignisUpdate), se)

		var sf = new RbRepository(familieRep, typeof(ISbFamilieRep), typeof(SbFamilieKey), typeof(SbFamilie),
			typeof(SbFamilieUpdate))
		reps.put(typeof(SbFamilie), sf)
		reps.put(typeof(SbFamilieUpdate), sf)

		var sk = new RbRepository(kindRep, typeof(ISbKindRep), typeof(SbKindKey), typeof(SbKind), typeof(SbKindUpdate))
		reps.put(typeof(SbKind), sk)
		reps.put(typeof(SbKindUpdate), sk)

		var sp = new RbRepository(sbpersonRep, typeof(ISbPersonRep), typeof(SbPersonKey), typeof(SbPerson),
			typeof(SbPersonUpdate))
		reps.put(typeof(SbPerson), sp)
		reps.put(typeof(SbPersonUpdate), sp)
		var sq = new RbRepository(quelleRep, typeof(ISbQuelleRep), typeof(SbQuelleKey), typeof(SbQuelle),
			typeof(SbQuelleUpdate))
		reps.put(typeof(SbQuelle), sq)
		reps.put(typeof(SbQuelleUpdate), sq)

		var tb = new RbRepository(tagebuchRep, typeof(ITbEintragRep), typeof(TbEintragKey), typeof(TbEintrag),
			typeof(TbEintragUpdate))
		reps.put(typeof(TbEintrag), tb)
		reps.put(typeof(TbEintragUpdate), tb)

		var ab = new RbRepository(abrechnungRep, typeof(IVmAbrechnungRep), typeof(VmAbrechnungKey),
			typeof(VmAbrechnung), typeof(VmAbrechnungUpdate))
		reps.put(typeof(VmAbrechnung), ab)
		reps.put(typeof(VmAbrechnungUpdate), ab)

		var vb = new RbRepository(vmbuchungRep, typeof(IVmBuchungRep), typeof(VmBuchungKey), typeof(VmBuchung),
			typeof(VmBuchungUpdate))
		reps.put(typeof(VmBuchung), vb)
		reps.put(typeof(VmBuchungUpdate), vb)

		var ve = new RbRepository(vmereignisRep, typeof(IVmEreignisRep), typeof(VmEreignisKey), typeof(VmEreignis),
			typeof(VmEreignisUpdate))
		reps.put(typeof(VmEreignis), ve)
		reps.put(typeof(VmEreignisUpdate), ve)

		var ha = new RbRepository(hausRep, typeof(IVmHausRep), typeof(VmHausKey), typeof(VmHaus), typeof(VmHausUpdate))
		reps.put(typeof(VmHaus), ha)
		reps.put(typeof(VmHausUpdate), ha)

		var vk = new RbRepository(vmkontoRep, typeof(IVmKontoRep), typeof(VmKontoKey), typeof(VmKonto),
			typeof(VmKontoUpdate))
		reps.put(typeof(VmKonto), vk)
		reps.put(typeof(VmKontoUpdate), vk)

		var mi = new RbRepository(mieteRep, typeof(IVmMieteRep), typeof(VmMieteKey), typeof(VmMiete),
			typeof(VmMieteUpdate))
		reps.put(typeof(VmMiete), mi)
		reps.put(typeof(VmMieteUpdate), mi)

		var mr = new RbRepository(mieterRep, typeof(IVmMieterRep), typeof(VmMieterKey), typeof(VmMieter),
			typeof(VmMieterUpdate))
		reps.put(typeof(VmMieter), mr)
		reps.put(typeof(VmMieterUpdate), mr)

		var wo = new RbRepository(wohnungRep, typeof(IVmWohnungRep), typeof(VmWohnungKey), typeof(VmWohnung),
			typeof(VmWohnungUpdate))
		reps.put(typeof(VmWohnung), wo)
		reps.put(typeof(VmWohnungUpdate), wo)

//			var an = new RbRepository(anlageRep, typeof(IWpAnlageRep), typeof(WpAnlageKey),
//				typeof(WpAnlage), typeof(WpAnlageUpdate))
//			reps.put(typeof(WpAnlage), an)
//			reps.put(typeof(WpAnlageUpdate), an)
//			var wb = new RbRepository(wpbuchungRep, typeof(IWpBuchungRep), typeof(WpBuchungKey),
//				typeof(WpBuchung), typeof(WpBuchungUpdate))
//			reps.put(typeof(WpBuchung), wb)
//			reps.put(typeof(WpBuchungUpdate), wb)
//			var kf = new RbRepository(konfigurationRep, typeof(IWpKonfigurationRep), typeof(WpKonfigurationKey),
//				typeof(WpKonfiguration), typeof(WpKonfigurationUpdate))
//			reps.put(typeof(WpKonfiguration), kf)
//			reps.put(typeof(WpKonfigurationUpdate), kf)
//			var ws = new RbRepository(standRep, typeof(IWpStandRep), typeof(WpStandKey),
//				typeof(WpStand), typeof(WpStandUpdate))
//			reps.put(typeof(WpStand), ws)
//			reps.put(typeof(WpStandUpdate), ws)
//			var wp = new RbRepository(wertpapierRep, typeof(IWpWertpapierRep), typeof(WpWertpapierKey),
//				typeof(WpWertpapier), typeof(WpWertpapierUpdate))
//			reps.put(typeof(WpWertpapier), wp)
//			reps.put(typeof(WpWertpapierUpdate), wp)
		var ei = new RbRepository(zeinstellungRep, typeof(IZeinstellungRep), typeof(ZeinstellungKey),
			typeof(Zeinstellung), typeof(ZeinstellungUpdate))
		reps.put(typeof(Zeinstellung), ei)
		reps.put(typeof(ZeinstellungUpdate), ei)
	}

	def private void rollbackIntern(ServiceDaten daten, RollbackListe rbListe) {

		if (rbListe === null || rbListe.liste === null || rbListe.liste.size <= 0) {
			return
		}
		init
		try {
			for (r : rbListe.liste) {
				var rep = reps.get(r.eintrag.class)
				if (rep === null) {
					throw new RuntimeException('''RbRepository für «r.eintrag.class» fehlt.''')
				}
				switch (r.art) {
					case RollbackArtEnum.INSERT: rep.delete(daten, r.eintrag)
					case RollbackArtEnum.UPDATE: rep.update(daten, r.eintrag.clone2) // Umdrehen
					case RollbackArtEnum.DELETE: rep.insert(daten, r.eintrag)
				}
			}
		} finally {
			daten.rbListe.liste.clear
		}
	}

	def private void redoIntern(ServiceDaten daten, RollbackListe rbListe) {

		if (rbListe === null || rbListe.liste === null || rbListe.liste.size <= 0) {
			return
		}
		init
		try {
			// Redo in umgekehrter Reihenfolge
			for (r : rbListe.liste.reverseView) {
				var rep = reps.get(r.eintrag.class)
				if (rep === null) {
					throw new RuntimeException('''RbRepository für «r.eintrag.class» fehlt.''')
				}
				switch (r.art) {
					case RollbackArtEnum.INSERT: rep.insert(daten, r.eintrag)
					case RollbackArtEnum.UPDATE: rep.update(daten, r.eintrag)
					case RollbackArtEnum.DELETE: rep.delete(daten, r.eintrag)
				}
			}
		} finally {
			daten.rbListe.liste.clear
		}
	}

	def private List<ReplTabelle> alleTabellen() {

		var l = newArrayList(new ReplTabelle("AD_Adresse", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("AD_Person", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("AD_Sitz", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("Benutzer", "Mandant_Nr", "Mandant_Nr, Benutzer_Id", true, true),
			new ReplTabelle("Byte_Daten", "Mandant_Nr", "Mandant_Nr, Typ, Uid, Lfd_Nr", true, true),
			new ReplTabelle("FZ_Buch", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("FZ_Buchautor", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("FZ_Buchserie", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("FZ_Buchstatus", "Mandant_Nr", "Mandant_Nr, Buch_Uid", true, true),
			new ReplTabelle("FZ_Fahrrad", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("FZ_Fahrradstand", "Mandant_Nr", "Mandant_Nr, Fahrrad_Uid, Datum, Nr", true, true),
			new ReplTabelle("FZ_Lektion", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("FZ_Lektioninhalt", "Mandant_Nr", "Mandant_Nr, Lektion_Uid, Lfd_Nr", true, true),
			new ReplTabelle("FZ_Lektionstand", "Mandant_Nr", "Mandant_Nr, Lektion_Uid", true, true),
			new ReplTabelle("FZ_Notiz", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HH_Bilanz", "Mandant_Nr", "Mandant_Nr, Periode, Kz, Konto_Uid", true, true),
			new ReplTabelle("HH_Buchung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HH_Ereignis", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HH_Konto", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HH_Periode", "Mandant_Nr", "Mandant_Nr, Nr", true, true),
			new ReplTabelle("HP_Behandlung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Behandlung_Leistung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Leistung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Leistungsgruppe", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Patient", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Rechnung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("HP_Status", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("MA_Einstellung", "Mandant_Nr", "Mandant_Nr, Schluessel", false, false),
			new ReplTabelle("MA_Mandant", "Nr", "Nr", true, true), //
			new ReplTabelle("MA_Parameter", "Mandant_Nr", "Mandant_Nr, Schluessel", true, true),
			new ReplTabelle("MA_Replikation", "Mandant_Nr", "Mandant_Nr, Tabellen_Nr, Replikation_Uid", true, false),
			new ReplTabelle("MO_Einteilung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("MO_Gottesdienst", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("MO_Messdiener", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("MO_Profil", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("SB_Ereignis", "Mandant_Nr", "Mandant_Nr, Person_Uid, Familie_Uid, Typ", true, true),
			new ReplTabelle("SB_Familie", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("SB_Kind", "Mandant_Nr", "Mandant_Nr, Familie_Uid, Kind_Uid", true, true),
			new ReplTabelle("SB_Person", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("SB_Quelle", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("TB_Eintrag", "Mandant_Nr", "Mandant_Nr, Datum", true, true),
			new ReplTabelle("VM_Abrechnung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Buchung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Ereignis", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Haus", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Konto", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Miete", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Mieter", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("VM_Wohnung", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("WP_Konfiguration", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("WP_Wertpapier", "Mandant_Nr", "Mandant_Nr, Uid", true, true),
			new ReplTabelle("zEinstellung", null, "Schluessel", false, false))
		// l = newArrayList(new ReplTabelle("MA_Parameter", "Mandant_Nr", "Mandant_Nr, Schluessel", true, true))
		return l
	}

	def private void checkReplikationStatus(RemoteDb von, RemoteDb nach) {

		var vonuid = von.getMandantEinstellungWert(Constant.EINST_MA_REPLIKATION_UID)
		var nachuid = nach.getMandantEinstellungWert(Constant.EINST_MA_REPLIKATION_UID)
		if (Global.nes(vonuid) || Global.nes(nachuid)) {
			throw new MeldungException("Es fehlt eine Replikation-UID.")
		}
		if (Global.compString(vonuid, nachuid) == 0) {
			throw new MeldungException("Keine Kopie zwischen gleichen Replikation-UIDs.")
		}
		var vonbeginn = von.getMandantEinstellungWert(Constant.EINST_MA_REPLIKATION_BEGINN)
		var nachbeginn = nach.getMandantEinstellungWert(Constant.EINST_MA_REPLIKATION_BEGINN)
		if (!Global.nes(vonbeginn) || !Global.nes(nachbeginn)) {
			throw new MeldungException("Es läuft bereits eine Replikation.")
		}
		// Datenbank-Struktur vergleichen
		var vonversion = Global.strInt(von.getEinstellungWert(Constant.EINST_DB_VERSION))
		var nachversion = Global.strInt(nach.getEinstellungWert(Constant.EINST_DB_VERSION))
		if (vonversion == 0 || nachversion == 0 || vonversion != nachversion) {
			throw new MeldungException("Die Einstellung DB_VERSION ist unterschiedlich." +
				" Bitte Datenstruktur anpassen.")
		}
	}

	@Transaction
	override public ServiceErgebnis<Void> copyMandant(ServiceDaten daten, boolean vonRep, int repmandant,
		StringBuffer status, StringBuffer abbruch) {

		var RemoteDb von = null
		var RemoteDb nach = null
		var MaEinstellung e = null
		try {
			von = getRemoteDb(if(vonRep) repmandant else daten.mandantNr, vonRep)
			nach = getRemoteDb(if(!vonRep) repmandant else daten.mandantNr, !vonRep)
			checkReplikationStatus(von, nach)
			e = maeinstellungRep.iuMaEinstellung(daten, null, Constant.EINST_MA_REPLIKATION_BEGINN,
				Global.dateTimeStringForm(daten.jetzt), null, null, null, null)
			var anzahl = 0
			var liste = alleTabellen
			var abgleich = true
			for (t : liste) {
				log.debug('''Tabelle «t.name»''')
				status.length = 0
				status.append("Tabelle ").append(t.name).append(Constant.CRLF)
				status.append(anzahl).append(" Datensätze bisher")
				if (abbruch.length > 0) {
					throw new MeldungException("Abbruch")
				}
				if (t.loeschen || t.kopieren) {
					if (abgleich) {
						von.abgleichenMandantTabelle(nach, t, status)
					} else {
						try {
							von.vergleicheMandantTabelle(nach, t, status)
						} catch (Exception ex) {
							var a = von.kopiereMandantTabelle(nach, t, status)
							if (a > 0) {
								Global.machNichts
							}
							anzahl += a
						}
					}
				}
			// Thread.sleep(100)
			}
		} finally {
			log.debug('''copyMandant Ende''')
			if (von !== null) {
				von.con.close
			}
			if (nach !== null) {
				nach.con.close
			}
			if (e !== null) {
				maeinstellungRep.iuMaEinstellung(daten, null, Constant.EINST_MA_REPLIKATION_BEGINN, "", null, null,
					null, null)
			}
		}
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override public ServiceErgebnis<List<String>> getAlleTabellen(ServiceDaten daten) {

		var l = alleTabellen.map[t|t.name].toList
		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}
}

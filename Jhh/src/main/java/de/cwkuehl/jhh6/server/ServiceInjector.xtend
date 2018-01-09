package de.cwkuehl.jhh6.server

import de.cwkuehl.jhh6.api.service.IAdresseService
import de.cwkuehl.jhh6.api.service.IAnmeldungService
import de.cwkuehl.jhh6.api.service.IFreizeitService
import de.cwkuehl.jhh6.api.service.IHaushaltService
import de.cwkuehl.jhh6.api.service.IHeilpraktikerService
import de.cwkuehl.jhh6.api.service.IMessdienerService
import de.cwkuehl.jhh6.api.service.IReplikationService
import de.cwkuehl.jhh6.api.service.IStammbaumService
import de.cwkuehl.jhh6.api.service.ITagebuchService
import de.cwkuehl.jhh6.api.service.ITestService
import de.cwkuehl.jhh6.api.service.IVermietungService
import de.cwkuehl.jhh6.api.service.IWertpapierService
import de.cwkuehl.jhh6.server.base.AbstractModule
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
import de.cwkuehl.jhh6.server.rep.IWpAnlageRep
import de.cwkuehl.jhh6.server.rep.IWpBuchungRep
import de.cwkuehl.jhh6.server.rep.IWpKonfigurationRep
import de.cwkuehl.jhh6.server.rep.IWpStandRep
import de.cwkuehl.jhh6.server.rep.IWpWertpapierRep
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
import de.cwkuehl.jhh6.server.rep.impl.WpAnlageRep
import de.cwkuehl.jhh6.server.rep.impl.WpBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.WpKonfigurationRep
import de.cwkuehl.jhh6.server.rep.impl.WpStandRep
import de.cwkuehl.jhh6.server.rep.impl.WpWertpapierRep
import de.cwkuehl.jhh6.server.rep.impl.ZeinstellungRep
import de.cwkuehl.jhh6.server.service.AdresseService
import de.cwkuehl.jhh6.server.service.AnmeldungService
import de.cwkuehl.jhh6.server.service.FreizeitService
import de.cwkuehl.jhh6.server.service.HaushaltService
import de.cwkuehl.jhh6.server.service.HeilpraktikerService
import de.cwkuehl.jhh6.server.service.MessdienerService
import de.cwkuehl.jhh6.server.service.ReplikationService
import de.cwkuehl.jhh6.server.service.StammbaumService
import de.cwkuehl.jhh6.server.service.TagebuchService
import de.cwkuehl.jhh6.server.service.TestService
import de.cwkuehl.jhh6.server.service.VermietungService
import de.cwkuehl.jhh6.server.service.WertpapierService

class ServiceInjector extends AbstractModule {

	override protected configure() {

		// Services
		bind(typeof(IAdresseService)).to(typeof(AdresseService))
		bind(typeof(IAnmeldungService)).to(typeof(AnmeldungService))
		bind(typeof(IFreizeitService)).to(typeof(FreizeitService))
		bind(typeof(IHaushaltService)).to(typeof(HaushaltService))
		bind(typeof(IHeilpraktikerService)).to(typeof(HeilpraktikerService))
		bind(typeof(IMessdienerService)).to(typeof(MessdienerService))
		bind(typeof(IReplikationService)).to(typeof(ReplikationService))
		bind(typeof(IStammbaumService)).to(typeof(StammbaumService))
		bind(typeof(ITagebuchService)).to(typeof(TagebuchService))
		bind(typeof(IVermietungService)).to(typeof(VermietungService))
		bind(typeof(IWertpapierService)).to(typeof(WertpapierService))
		bind(typeof(ITestService)).to(typeof(TestService))

		// Repositories
		bind(typeof(IAdAdresseRep)).to(typeof(AdAdresseRep))
		bind(typeof(IAdPersonRep)).to(typeof(AdPersonRep))
		bind(typeof(IAdSitzRep)).to(typeof(AdSitzRep))
		bind(typeof(IBenutzerRep)).to(typeof(BenutzerRep))
		bind(typeof(IByteDatenRep)).to(typeof(ByteDatenRep))
		bind(typeof(IFzBuchRep)).to(typeof(FzBuchRep))
		bind(typeof(IFzBuchautorRep)).to(typeof(FzBuchautorRep))
		bind(typeof(IFzBuchserieRep)).to(typeof(FzBuchserieRep))
		bind(typeof(IFzBuchstatusRep)).to(typeof(FzBuchstatusRep))
		bind(typeof(IFzFahrradRep)).to(typeof(FzFahrradRep))
		bind(typeof(IFzFahrradstandRep)).to(typeof(FzFahrradstandRep))
		bind(typeof(IFzNotizRep)).to(typeof(FzNotizRep))
		bind(typeof(IHhBilanzRep)).to(typeof(HhBilanzRep))
		bind(typeof(IHhBuchungRep)).to(typeof(HhBuchungRep))
		bind(typeof(IHhEreignisRep)).to(typeof(HhEreignisRep))
		bind(typeof(IHhKontoRep)).to(typeof(HhKontoRep))
		bind(typeof(IHhPeriodeRep)).to(typeof(HhPeriodeRep))
		bind(typeof(IHpBehandlungRep)).to(typeof(HpBehandlungRep))
		bind(typeof(IHpBehandlungLeistungRep)).to(typeof(HpBehandlungLeistungRep))
		bind(typeof(IHpLeistungRep)).to(typeof(HpLeistungRep))
		bind(typeof(IHpLeistungsgruppeRep)).to(typeof(HpLeistungsgruppeRep))
		bind(typeof(IHpPatientRep)).to(typeof(HpPatientRep))
		bind(typeof(IHpRechnungRep)).to(typeof(HpRechnungRep))
		bind(typeof(IHpStatusRep)).to(typeof(HpStatusRep))
		bind(typeof(IMaEinstellungRep)).to(typeof(MaEinstellungRep))
		bind(typeof(IMaParameterRep)).to(typeof(MaParameterRep))
		bind(typeof(IMaMandantRep)).to(typeof(MaMandantRep))
		bind(typeof(IMoEinteilungRep)).to(typeof(MoEinteilungRep))
		bind(typeof(IMoGottesdienstRep)).to(typeof(MoGottesdienstRep))
		bind(typeof(IMoMessdienerRep)).to(typeof(MoMessdienerRep))
		bind(typeof(IMoProfilRep)).to(typeof(MoProfilRep))
		bind(typeof(ISbEreignisRep)).to(typeof(SbEreignisRep))
		bind(typeof(ISbFamilieRep)).to(typeof(SbFamilieRep))
		bind(typeof(ISbKindRep)).to(typeof(SbKindRep))
		bind(typeof(ISbPersonRep)).to(typeof(SbPersonRep))
		bind(typeof(ISbQuelleRep)).to(typeof(SbQuelleRep))
		bind(typeof(ITbEintragRep)).to(typeof(TbEintragRep))
		bind(typeof(IVmAbrechnungRep)).to(typeof(VmAbrechnungRep))
		bind(typeof(IVmBuchungRep)).to(typeof(VmBuchungRep))
		bind(typeof(IVmEreignisRep)).to(typeof(VmEreignisRep))
		bind(typeof(IVmHausRep)).to(typeof(VmHausRep))
		bind(typeof(IVmKontoRep)).to(typeof(VmKontoRep))
		bind(typeof(IVmMieteRep)).to(typeof(VmMieteRep))
		bind(typeof(IVmMieterRep)).to(typeof(VmMieterRep))
		bind(typeof(IVmWohnungRep)).to(typeof(VmWohnungRep))
		bind(typeof(IWpAnlageRep)).to(typeof(WpAnlageRep))
		bind(typeof(IWpBuchungRep)).to(typeof(WpBuchungRep))
		bind(typeof(IWpKonfigurationRep)).to(typeof(WpKonfigurationRep))
		bind(typeof(IWpStandRep)).to(typeof(WpStandRep))
		bind(typeof(IWpWertpapierRep)).to(typeof(WpWertpapierRep))
		bind(typeof(IZeinstellungRep)).to(typeof(ZeinstellungRep))
	}

}

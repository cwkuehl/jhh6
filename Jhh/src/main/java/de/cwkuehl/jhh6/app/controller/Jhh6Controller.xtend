package de.cwkuehl.jhh6.app.controller

import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.StartDialog
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.controller.ad.AD100PersonenController
import de.cwkuehl.jhh6.app.controller.ad.AD120GeburtstageController
import de.cwkuehl.jhh6.app.controller.ag.AG000InfoController
import de.cwkuehl.jhh6.app.controller.ag.AG010HilfeController
import de.cwkuehl.jhh6.app.controller.ag.AG100MandantenController
import de.cwkuehl.jhh6.app.controller.ag.AG200BenutzerController
import de.cwkuehl.jhh6.app.controller.ag.AG400SicherungenController
import de.cwkuehl.jhh6.app.controller.am.AM000AnmeldungController
import de.cwkuehl.jhh6.app.controller.am.AM100AenderungController
import de.cwkuehl.jhh6.app.controller.am.AM500EinstellungenController
import de.cwkuehl.jhh6.app.controller.am.AM510DialogeController
import de.cwkuehl.jhh6.app.controller.fz.FZ100StatistikController
import de.cwkuehl.jhh6.app.controller.fz.FZ200FahrraederController
import de.cwkuehl.jhh6.app.controller.fz.FZ250FahrradstaendeController
import de.cwkuehl.jhh6.app.controller.fz.FZ300AutorenController
import de.cwkuehl.jhh6.app.controller.fz.FZ320SerienController
import de.cwkuehl.jhh6.app.controller.fz.FZ340BuecherController
import de.cwkuehl.jhh6.app.controller.fz.FZ700NotizenController
import de.cwkuehl.jhh6.app.controller.hh.HH100PeriodenController
import de.cwkuehl.jhh6.app.controller.hh.HH200KontenController
import de.cwkuehl.jhh6.app.controller.hh.HH300EreignisseController
import de.cwkuehl.jhh6.app.controller.hh.HH400BuchungenController
import de.cwkuehl.jhh6.app.controller.hh.HH500BilanzenController
import de.cwkuehl.jhh6.app.controller.hp.HP100PatientenController
import de.cwkuehl.jhh6.app.controller.hp.HP150StatusController
import de.cwkuehl.jhh6.app.controller.hp.HP200BehandlungenController
import de.cwkuehl.jhh6.app.controller.hp.HP300LeistungenController
import de.cwkuehl.jhh6.app.controller.hp.HP350LeistungsgruppenController
import de.cwkuehl.jhh6.app.controller.hp.HP400RechnungenController
import de.cwkuehl.jhh6.app.controller.mo.MO100MessdienerController
import de.cwkuehl.jhh6.app.controller.mo.MO200GottesdiensteController
import de.cwkuehl.jhh6.app.controller.mo.MO300ProfileController
import de.cwkuehl.jhh6.app.controller.sb.SB200AhnenController
import de.cwkuehl.jhh6.app.controller.sb.SB300FamilienController
import de.cwkuehl.jhh6.app.controller.sb.SB400QuellenController
import de.cwkuehl.jhh6.app.controller.so.SO100SudokuController
import de.cwkuehl.jhh6.app.controller.so.SO200DetektivController
import de.cwkuehl.jhh6.app.controller.tb.TB100TagebuchController
import de.cwkuehl.jhh6.app.controller.vm.VM100HaeuserController
import de.cwkuehl.jhh6.app.controller.vm.VM200WohnungenController
import de.cwkuehl.jhh6.app.controller.vm.VM300MieterController
import de.cwkuehl.jhh6.app.controller.vm.VM400MietenController
import de.cwkuehl.jhh6.app.controller.vm.VM500BuchungenController
import de.cwkuehl.jhh6.app.controller.vm.VM600KontenController
import de.cwkuehl.jhh6.app.controller.vm.VM700EreignisseController
import de.cwkuehl.jhh6.app.controller.vm.VM800ForderungenController
import de.cwkuehl.jhh6.app.controller.vm.VM900AbrechnungenController
import de.cwkuehl.jhh6.server.FactoryService
import java.net.URL
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.ResourceBundle
import java.util.Timer
import java.util.TimerTask
import java.util.regex.Pattern
import javafx.application.Platform
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.event.ActionEvent
import javafx.fxml.FXML
import javafx.fxml.Initializable
import javafx.scene.control.Label
import javafx.scene.control.Menu
import javafx.scene.control.MenuItem
import javafx.scene.control.SeparatorMenuItem
import javafx.scene.control.Tab
import javafx.scene.control.TabPane

import static de.cwkuehl.jhh6.api.global.Global.g

class Jhh6Controller extends BaseController<String> implements Initializable {

	// @FXML MenuBar menue
	@FXML MenuItem menueAnmelden
	@FXML MenuItem menueAbmelden
	@FXML Label leftStatus
	@FXML SeparatorMenuItem sepFi1
	@FXML SeparatorMenuItem sepFi2
	@FXML MenuItem menueUndo
	@FXML MenuItem menueRedo
	@FXML MenuItem menueAD100
	@FXML MenuItem menueAG100
	@FXML MenuItem menueAG200
	@FXML MenuItem menueAG400
	@FXML SeparatorMenuItem sepAm1
	@FXML MenuItem menueAM100
	@FXML MenuItem menueAM500
	@FXML MenuItem menueAM510
	// @FXML MenuItem menueReset
	@FXML MenuItem menueFZ100
	@FXML MenuItem menueFZ200
	@FXML MenuItem menueFZ250
	@FXML MenuItem menueFZ300
	@FXML MenuItem menueFZ320
	@FXML MenuItem menueFZ340
	@FXML MenuItem menueFZ700
	@FXML SeparatorMenuItem sepFz1
	@FXML SeparatorMenuItem sepFz2
	@FXML SeparatorMenuItem sepFz3
	@FXML SeparatorMenuItem sepFz4
	@FXML Menu menueHp
	@FXML MenuItem menueHH100
	@FXML MenuItem menueHH200
	@FXML MenuItem menueHH300
	@FXML MenuItem menueHH400
	@FXML SeparatorMenuItem sepHh1
	@FXML MenuItem menueHH500EB
	@FXML MenuItem menueHH500GV
	@FXML MenuItem menueHH500SB
	@FXML MenuItem menueHP100
	@FXML MenuItem menueHP150
	@FXML MenuItem menueHP200
	@FXML MenuItem menueHP300
	@FXML MenuItem menueHP350
	@FXML MenuItem menueHP400
	@FXML Menu menueMo
	@FXML MenuItem menueMO100
	@FXML MenuItem menueMO200
	@FXML MenuItem menueMO300
	@FXML MenuItem menueSB200
	@FXML MenuItem menueSB300
	@FXML MenuItem menueSB400
	@FXML MenuItem menueSO100
	@FXML MenuItem menueSO200
	@FXML MenuItem menueTB100
	@FXML Menu menueVm
	@FXML SeparatorMenuItem sepVm1
	@FXML SeparatorMenuItem sepVm2
	@FXML SeparatorMenuItem sepVm3
	@FXML MenuItem menueVM100
	@FXML MenuItem menueVM200
	@FXML MenuItem menueVM300
	@FXML MenuItem menueVM400
	@FXML MenuItem menueVM500
	@FXML MenuItem menueVM600
	@FXML MenuItem menueVM700
	@FXML MenuItem menueVM800
	@FXML MenuItem menueVM900
	@FXML MenuItem menueVM920
	@FXML MenuItem menueVMHH100
	@FXML Menu menueWp
	@FXML MenuItem menueWP100
	@FXML MenuItem menueWP110
	@FXML MenuItem menueWP200
	@FXML MenuItem menueWP300
	@FXML MenuItem menueWP400
	@FXML MenuItem menueWP500
	@FXML SeparatorMenuItem sepWp1
	@FXML SeparatorMenuItem sepWp2
	@FXML MenuItem menueWP250
	@FXML TabPane tabs

	override void initialize(URL location, ResourceBundle resources) {

		// StyleManager.getInstance.addUserAgentStylesheet("com/sun/javafx/scene/control/skin/modena/whiteOnBlack.css")
		var Timer timer = new Timer
		timer.schedule(([|
			tabs.getSelectionModel.selectedItemProperty.addListener(
				([ ObservableValue<? extends Tab> ov, Tab alt, Tab neu |
					if (alt !== null && alt.getUserData instanceof BaseController<?>) {
						var BaseController<?> bc = (alt.getUserData as BaseController<?>)
						bc.removeAccelerators
					}
					if (neu !== null && neu.getUserData instanceof BaseController<?>) {
						var BaseController<?> bc = (neu.getUserData as BaseController<?>)
						bc.addAccelerators
					}
				] as ChangeListener<Tab>))
			var mandantNr = Global.strInt(Jhh6::einstellungen.getDateiParameter("AM000Anmeldung_Mandant"))
			if (mandantNr <= 0)
				mandantNr = 1
			var daten0 = new ServiceDaten(mandantNr, "(initDatenbank)")
			var r0 = FactoryService.anmeldungService.initDatenbank(daten0)
			get(r0)
			if (!r0.ok) {
				return
			}
			var daten = new ServiceDaten(mandantNr, Jhh6::einstellungen.benutzer)
			var r = FactoryService.getAnmeldungService.istOhneAnmelden(daten)
			if (get(r)) {
				Jhh6.setServiceDaten(daten)
				setRechte(daten.mandantNr, true)
				startDialoge(daten.mandantNr)
			} else {
				Platform.runLater([handleAnmelden(null)])
			}
		] as TimerTask), 100)
	}

	override protected String getTitel() {
		return null
	}

	def void setLeftStatus(String str) {
		if (leftStatus !== null) {
			Platform::runLater([leftStatus.text = str])
		}
	}

	@FXML def protected void handleAnmelden(ActionEvent e) {

		if (Werkzeug::isUpdateAvailable) {
			setLeftStatus(Meldungen.M3001)
		}
		var daten = getServiceDaten
		if (menueAnmelden.isVisible) {
			var s = starteDialog(typeof(AM000AnmeldungController), DialogAufrufEnum.OHNE)
			if ("Anmelden".equals(s)) {
				daten = getServiceDaten
				setRechte(daten.getMandantNr, true)
				startDialoge(daten.getMandantNr)
			// System.out.println("Angemeldet.")
			}
		} else {
			FactoryService.anmeldungService.abmelden(daten)
			Jhh6::einstellungen.refreshMandant
			setServiceDaten(null)
			setRechte(daten.getMandantNr, false)
			// alle Tabs schließen
			for (Tab t : getTabs.tabs) {
				if (t.getOnClosed !== null) {
					t.getOnClosed.handle(null)
				}
			}
			getTabs.tabs.clear
			Jhh6::einstellungen.refreshMandant
			// System.out.println("Abgemeldet.")
			handleAnmelden(null)
		}
	}

	@FXML def protected void handleBeenden(ActionEvent e) {
		Platform::exit // Anwendung beenden
	}

	def private void setRechte(int mandantNr, boolean ok) {

		sepFi1.setVisible(ok)
		sepFi2.setVisible(ok)
		menueUndo.setVisible(ok)
		menueRedo.setVisible(ok)
		menueAG100.setVisible(ok)
		menueAG200.setVisible(ok)
		menueAG400.setVisible(ok)
		sepAm1.setVisible(ok)
		menueAnmelden.setVisible(!ok)
		menueAbmelden.setVisible(ok)
		menueAD100.setVisible(ok)
		menueAM100.setVisible(ok)
		menueAM500.setVisible(ok)
		menueAM510.setVisible(ok)
		menueHp.setVisible(Jhh6::einstellungen.getMenuHeilpraktiker(mandantNr))
		menueHP100.setVisible(ok)
		menueHH100.setVisible(ok)
		menueHH200.setVisible(ok)
		menueHH300.setVisible(ok)
		menueHH400.setVisible(ok)
		sepHh1.setVisible(ok)
		menueHH500EB.setVisible(ok)
		menueHH500GV.setVisible(ok)
		menueHH500SB.setVisible(ok)
		menueHP150.setVisible(ok)
		menueHP200.setVisible(ok)
		menueHP300.setVisible(ok)
		menueHP350.setVisible(ok)
		menueHP400.setVisible(ok)
		menueMo.setVisible(Jhh6::einstellungen.getMenuMessdiener(mandantNr))
		menueMO100.setVisible(ok)
		menueMO200.setVisible(ok)
		menueMO300.setVisible(ok)
		menueSB200.setVisible(ok)
		menueSB300.setVisible(ok)
		menueSB400.setVisible(ok)
		menueSO100.setVisible(ok)
		menueSO200.setVisible(ok)
		menueTB100.setVisible(ok)
		sepFz1.setVisible(ok)
		sepFz2.setVisible(ok)
		sepFz3.setVisible(ok)
		sepFz4.setVisible(ok)
		menueFZ100.setVisible(ok)
		menueFZ200.setVisible(ok)
		menueFZ250.setVisible(ok)
		menueFZ300.setVisible(ok)
		menueFZ320.setVisible(ok)
		menueFZ340.setVisible(ok)
		menueFZ700.setVisible(ok)
		menueVm.setVisible(Jhh6::einstellungen.getMenuVermietung(mandantNr))
		sepVm1.setVisible(ok)
		sepVm2.setVisible(ok)
		sepVm3.setVisible(ok)
		menueVM100.setVisible(ok)
		menueVM200.setVisible(ok)
		menueVM300.setVisible(ok)
		menueVM400.setVisible(ok)
		menueVM500.setVisible(ok)
		menueVM600.setVisible(ok)
		menueVM700.setVisible(ok)
		menueVM800.setVisible(ok)
		menueVM900.setVisible(ok)
		menueVM920.setVisible(ok)
		menueVMHH100.setVisible(ok)
		menueWp.setVisible(ok)
		menueWP100.setVisible(ok)
		menueWP110.setVisible(ok)
		menueWP200.setVisible(ok)
		menueWP250.setVisible(ok)
		menueWP300.setVisible(ok)
		menueWP400.setVisible(ok)
		menueWP500.setVisible(ok)
		sepWp1.setVisible(ok)
		sepWp2.setVisible(ok)
		Platform::runLater([
			{
				Jhh6::aktualisiereTitel
				var boolean g = Global::objBool(Jhh6::einstellungen.getDateiParameter("AD120Geburtstage_Starten"))
				if (ok && g) {
					starteFormular(typeof(AD120GeburtstageController), DialogAufrufEnum.OHNE)
				}
			}
		])
	}

	def private void startDialoge(int mandantNr) {

		Platform::runLater([
			{
				var List<StartDialog> dliste = Jhh6Controller::dialogListe
				var String str = Global::nn(Jhh6::einstellungen.getStartdialoge(mandantNr))
				var String[] array = str.split(Pattern::quote("|"))
				val HashMap<String, StartDialog> map = new HashMap
				dliste.stream.forEach([a|map.put(a.getId, a)])
				for (String s : array) {
					var StartDialog d = map.get(s)
					if (d !== null) {
						starteFormular(d.clazz, DialogAufrufEnum::OHNE, d.parameter)
					}
				}
			}
		])
	}

	def static List<StartDialog> getDialogListe() {

		var List<StartDialog> l = new ArrayList<StartDialog>
		l.add(new StartDialog("#AG100", g("menu.clients"), typeof(AG100MandantenController), null))
		l.add(new StartDialog("#AG200", g("menu.users"), typeof(AG200BenutzerController), null))
		l.add(new StartDialog("#AG400", g("menu.backups"), typeof(AG400SicherungenController), null))
		l.add(new StartDialog("#TB100", g("menu.diary"), typeof(TB100TagebuchController), null))
		l.add(new StartDialog("#FZ700", g("menu.notes"), typeof(FZ700NotizenController), null))
		l.add(new StartDialog("#AD100", g("menu.persons"), typeof(AD100PersonenController), null))
		l.add(new StartDialog("#FZ250", g("menu.mileages"), typeof(FZ250FahrradstaendeController), null))
		l.add(new StartDialog("#FZ200", g("menu.bikes"), typeof(FZ200FahrraederController), null))
		l.add(new StartDialog("#FZ300", g("menu.authors"), typeof(FZ300AutorenController), null))
		l.add(new StartDialog("#FZ320", g("menu.series"), typeof(FZ320SerienController), null))
		l.add(new StartDialog("#FZ340", g("menu.books"), typeof(FZ340BuecherController), null))
		l.add(new StartDialog("#SO100", g("menu.sudoku"), typeof(SO100SudokuController), null))
		l.add(new StartDialog("#SO200", g("menu.detective"), typeof(SO200DetektivController), null))
		l.add(new StartDialog("#FZ100", g("menu.statistic"), typeof(FZ100StatistikController), null))
		l.add(new StartDialog("#HH400", g("menu.bookings"), typeof(HH400BuchungenController), null))
		l.add(new StartDialog("#HH300", g("menu.events"), typeof(HH300EreignisseController), null))
		l.add(new StartDialog("#HH200", g("menu.accounts"), typeof(HH200KontenController), null))
		l.add(new StartDialog("#HH100", g("menu.periods"), typeof(HH100PeriodenController), null))
		l.add(new StartDialog("#HH500;EB", g("menu.openingbalance"), typeof(HH500BilanzenController), "EB"))
		l.add(new StartDialog("#HH500;GV", g("menu.plbalance"), typeof(HH500BilanzenController), "GV"))
		l.add(new StartDialog("#HH500;SB", g("menu.finalbalance"), typeof(HH500BilanzenController), "SB"))
		l.add(new StartDialog("#VM500", g("menu.bookings2"), typeof(VM500BuchungenController), null))
		// l.add(new StartDialog("#VM920", g("menu.accountings"), typeof(VM920AbrechnungenController), null))
		l.add(new StartDialog("#HP100", g("menu.patients"), typeof(HP100PatientenController), null))
		l.add(new StartDialog("#HP200", g("menu.treatments"), typeof(HP200BehandlungenController), null))
		l.add(new StartDialog("#HP400", g("menu.invoices"), typeof(HP400RechnungenController), null))
		l.add(new StartDialog("#SB200", g("menu.ancestors"), typeof(SB200AhnenController), null))
		l.add(new StartDialog("#SB300", g("menu.families"), typeof(SB300FamilienController), null))
		l.add(new StartDialog("#VM300", g("menu.renters"), typeof(VM300MieterController), null))
		l.add(new StartDialog("#VM900", g("menu.houseaccountings"), typeof(VM900AbrechnungenController), null))
		// l.add(new StartDialog("#WP200", g("menu.stocks"), typeof(WP200WertpapiereController), null))
		// l.add(new StartDialog("#WP250", g("menu.investments"), typeof(WP250AnlagenController), null))
		// l.add(new StartDialog("#WP400", g("menu.bookings3"), typeof(WP400BuchungenController), null))
		// l.add(new StartDialog("#WP500", g("menu.prices"), typeof(WP500StaendeController), null))
		l.add(new StartDialog("#MO100", g("menu.acolytes"), typeof(MO100MessdienerController), null))
		l.add(new StartDialog("#MO200", g("menu.holymass"), typeof(MO200GottesdiensteController), null))
		return l
	}

	@FXML def void handleUndo() {
		get(Jhh6::rollback)
	}

	@FXML def void handleRedo() {
		get(Jhh6::redo)
	}

	@FXML def void handleReset() {
		Jhh6::einstellungen.reset
	}

	@FXML def void handleAD100() {
		starteFormular(typeof(AD100PersonenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAG000() {
		starteFormular(typeof(AG000InfoController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAG010() {
		starteFormular(typeof(AG010HilfeController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAG100() {
		starteFormular(typeof(AG100MandantenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAG200() {
		starteFormular(typeof(AG200BenutzerController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAG400() {
		starteFormular(typeof(AG400SicherungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAM100() {
		starteDialog(typeof(AM100AenderungController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAM500() {
		starteFormular(typeof(AM500EinstellungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleAM510() {
		starteFormular(typeof(AM510DialogeController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ100() {
		starteFormular(typeof(FZ100StatistikController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ200() {
		starteFormular(typeof(FZ200FahrraederController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ250() {
		starteFormular(typeof(FZ250FahrradstaendeController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ300() {
		starteFormular(typeof(FZ300AutorenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ320() {
		starteFormular(typeof(FZ320SerienController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ340() {
		starteFormular(typeof(FZ340BuecherController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleFZ700() {
		starteFormular(typeof(FZ700NotizenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHH100() {
		starteFormular(typeof(HH100PeriodenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHH200() {
		starteFormular(typeof(HH200KontenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHH300() {
		starteFormular(typeof(HH300EreignisseController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHH400() {
		starteFormular(typeof(HH400BuchungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHH500EB() {
		starteFormular(typeof(HH500BilanzenController), DialogAufrufEnum.OHNE, Constant.KZBI_EROEFFNUNG)
	}

	@FXML def void handleHH500GV() {
		starteFormular(typeof(HH500BilanzenController), DialogAufrufEnum.OHNE, Constant.KZBI_GV)
	}

	@FXML def void handleHH500SB() {
		starteFormular(typeof(HH500BilanzenController), DialogAufrufEnum.OHNE, Constant.KZBI_SCHLUSS)
	}

	@FXML def void handleHP100() {
		starteFormular(typeof(HP100PatientenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHP150() {
		starteFormular(typeof(HP150StatusController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHP200() {
		starteFormular(typeof(HP200BehandlungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHP300() {
		starteFormular(typeof(HP300LeistungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHP350() {
		starteFormular(typeof(HP350LeistungsgruppenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleHP400() {
		starteFormular(typeof(HP400RechnungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleMO100() {
		starteFormular(typeof(MO100MessdienerController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleMO200() {
		starteFormular(typeof(MO200GottesdiensteController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleMO300() {
		starteFormular(typeof(MO300ProfileController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleSB200() {
		starteFormular(typeof(SB200AhnenController), DialogAufrufEnum.OHNE)
	}

	def void handleSB300() {
		starteFormular(typeof(SB300FamilienController), DialogAufrufEnum.OHNE)
	}

	def void handleSB400() {
		starteFormular(typeof(SB400QuellenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleSO100() {
		starteFormular(typeof(SO100SudokuController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleSO200() {
		starteFormular(typeof(SO200DetektivController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleTB100() {
		starteFormular(typeof(TB100TagebuchController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM100() {
		starteFormular(typeof(VM100HaeuserController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM200() {
		starteFormular(typeof(VM200WohnungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM300() {
		starteFormular(typeof(VM300MieterController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM400() {
		starteFormular(typeof(VM400MietenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM500() {
		starteFormular(typeof(VM500BuchungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM600() {
		starteFormular(typeof(VM600KontenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM700() {
		starteFormular(typeof(VM700EreignisseController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM800() {
		starteFormular(typeof(VM800ForderungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM900() {
		starteFormular(typeof(VM900AbrechnungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVM920() { // starteFormular(typeof(VM920AbrechnungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleVMHH100() { // starteFormular(typeof(HH100PeriodenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP100() { // starteFormular(typeof(WP100ChartController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP110() { // starteFormular(typeof(WP110ChartsController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP200() { // starteFormular(typeof(WP200WertpapiereController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP250() { // starteFormular(typeof(WP250AnlagenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP300() { // starteFormular(typeof(WP300KonfigurationenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP400() { // starteFormular(typeof(WP400BuchungenController), DialogAufrufEnum.OHNE)
	}

	@FXML def void handleWP500() { // starteFormular(typeof(WP500StaendeController), DialogAufrufEnum.OHNE)
	}

	def TabPane getTabs() {
		return tabs
	}

	def void closeTabs() {

		for (Tab t : tabs.tabs) {
			// Close-Event händisch aufrufen
			t.getOnClosed.handle(null)
		}
		tabs.tabs.removeAll(tabs.tabs)
	}
}

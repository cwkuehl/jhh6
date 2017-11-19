package de.cwkuehl.jhh6.app.controller;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.ResourceBundle;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Pattern;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.service.ServiceDaten;
import de.cwkuehl.jhh6.app.Jhh6;
import de.cwkuehl.jhh6.app.base.BaseController;
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum;
import de.cwkuehl.jhh6.app.base.StartDialog;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SeparatorMenuItem;
import javafx.scene.control.Tab;
import javafx.scene.control.TabPane;

public class Jhh6Controller extends BaseController<String> implements Initializable {

    @FXML
    private MenuBar           menue;

    @FXML
    private MenuItem          menueAnmelden;

    @FXML
    private MenuItem          menueAbmelden;

    @FXML
    private Label             leftStatus;

    @FXML
    private SeparatorMenuItem sepFi1;

    @FXML
    private SeparatorMenuItem sepFi2;

    @FXML
    private MenuItem          menueUndo;

    @FXML
    private MenuItem          menueRedo;

    @FXML
    private MenuItem          menueAD100;

    @FXML
    private MenuItem          menueAG100;

    @FXML
    private MenuItem          menueAG200;

    @FXML
    private MenuItem          menueAG400;

    @FXML
    private SeparatorMenuItem sepAm1;

    @FXML
    private MenuItem          menueAM100;

    @FXML
    private MenuItem          menueAM500;

    @FXML
    private MenuItem          menueAM510;

    @FXML
    private MenuItem          menueReset;

    @FXML
    private MenuItem          menueFZ100;

    @FXML
    private MenuItem          menueFZ200;

    @FXML
    private MenuItem          menueFZ250;

    @FXML
    private MenuItem          menueFZ300;

    @FXML
    private MenuItem          menueFZ320;

    @FXML
    private MenuItem          menueFZ340;

    @FXML
    private MenuItem          menueFZ700;

    @FXML
    private SeparatorMenuItem sepFz1;

    @FXML
    private SeparatorMenuItem sepFz2;

    @FXML
    private SeparatorMenuItem sepFz3;

    @FXML
    private SeparatorMenuItem sepFz4;

    @FXML
    private Menu              menueHp;

    @FXML
    private MenuItem          menueHH100;

    @FXML
    private MenuItem          menueHH200;

    @FXML
    private MenuItem          menueHH300;

    @FXML
    private MenuItem          menueHH400;

    @FXML
    private SeparatorMenuItem sepHh1;

    @FXML
    private MenuItem          menueHH500EB;

    @FXML
    private MenuItem          menueHH500GV;

    @FXML
    private MenuItem          menueHH500SB;

    @FXML
    private MenuItem          menueHP100;

    @FXML
    private MenuItem          menueHP150;

    @FXML
    private MenuItem          menueHP200;

    @FXML
    private MenuItem          menueHP300;

    @FXML
    private MenuItem          menueHP350;

    @FXML
    private MenuItem          menueHP400;

    @FXML
    private Menu              menueMo;

    @FXML
    private MenuItem          menueMO100;

    @FXML
    private MenuItem          menueMO200;

    @FXML
    private MenuItem          menueMO300;

    @FXML
    private MenuItem          menueSB200;

    @FXML
    private MenuItem          menueSB300;

    @FXML
    private MenuItem          menueSB400;

    @FXML
    private MenuItem          menueSO100;

    @FXML
    private MenuItem          menueSO200;

    @FXML
    private MenuItem          menueTB100;

    @FXML
    private Menu              menueVm;

    @FXML
    private SeparatorMenuItem sepVm1;

    @FXML
    private SeparatorMenuItem sepVm2;

    @FXML
    private SeparatorMenuItem sepVm3;

    @FXML
    private MenuItem          menueVM100;

    @FXML
    private MenuItem          menueVM200;

    @FXML
    private MenuItem          menueVM300;

    @FXML
    private MenuItem          menueVM400;

    @FXML
    private MenuItem          menueVM500;

    @FXML
    private MenuItem          menueVM600;

    @FXML
    private MenuItem          menueVM700;

    @FXML
    private MenuItem          menueVM800;

    @FXML
    private MenuItem          menueVM900;

    @FXML
    private MenuItem          menueVM920;

    @FXML
    private MenuItem          menueVMHH100;

    @FXML
    private Menu              menueWp;

    @FXML
    private MenuItem          menueWP100;

    @FXML
    private MenuItem          menueWP110;

    @FXML
    private MenuItem          menueWP200;

    @FXML
    private MenuItem          menueWP300;

    @FXML
    private MenuItem          menueWP400;

    @FXML
    private MenuItem          menueWP500;

    @FXML
    private SeparatorMenuItem sepWp1;

    @FXML
    private SeparatorMenuItem sepWp2;

    @FXML
    private MenuItem          menueWP250;

    @FXML
    private TabPane           tabs;

    @Override
    public void initialize(URL location, ResourceBundle resources) {

        // StyleManager.getInstance().addUserAgentStylesheet("com/sun/javafx/scene/control/skin/modena/whiteOnBlack.css");
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {

            @Override
            public void run() {

                tabs.getSelectionModel().selectedItemProperty().addListener(new ChangeListener<Tab>() {
                    @Override
                    public void changed(ObservableValue<? extends Tab> ov, Tab alt, Tab neu) {

                        if (alt != null && alt.getUserData() instanceof BaseController<?>) {
                            BaseController<?> bc = (BaseController<?>) alt.getUserData();
                            bc.removeAccelerators();
                        }
                        if (neu != null && neu.getUserData() instanceof BaseController<?>) {
                            BaseController<?> bc = (BaseController<?>) neu.getUserData();
                            bc.addAccelerators();
                        }
                    }
                });
                // ServiceDaten daten0 = new ServiceDaten(1, "(initDatenbank)");
                // ServiceErgebnis<Void> r0 = FactoryService.getAnmeldungService().initDatenbank(daten0);
                // get(r0);
                // if (!r0.ok()) {
                // return;
                // }
                // int mandantNr = Global.strInt(Jhh6.getEinstellungen().getDateiParameter("AM000Anmeldung_Mandant"));
                // ServiceDaten daten = new ServiceDaten(mandantNr, Jhh6.getEinstellungen().getBenutzer());
                // ServiceErgebnis<Boolean> r = FactoryService.getAnmeldungService().istOhneAnmelden(daten);
                // if (get(r)) {
                // Jhh6.setServiceDaten(daten);
                // setRechte(daten.getMandantNr(), true);
                // startDialoge(daten.getMandantNr());
                // } else {
                // Platform.runLater(() -> {
                // handleAnmelden(null);
                // });
                // }
            }
        }, 100);
    }

    @Override
    protected String getTitel() {
        return null;
    }

    public void setLeftStatus(String str) {

        if (leftStatus != null) {
            Platform.runLater(() -> {
                leftStatus.setText(str);
            });
        }
    }

    @FXML
    protected void handleAnmelden(ActionEvent e) {

        ServiceDaten daten = getServiceDaten();
        if (menueAnmelden.isVisible()) {
            // String s = (String) starteDialog(AM000AnmeldungController.class, DialogAufrufEnum.OHNE);
            // if ("Anmelden".equals(s)) {
            // daten = getServiceDaten();
            // setRechte(daten.getMandantNr(), true);
            // startDialoge(daten.getMandantNr());
            // // System.out.println("Angemeldet.");
            // }
        } else {
            // FactoryService.getAnmeldungService().abmelden(daten);
            Jhh6.getEinstellungen().refreshMandant();
            setServiceDaten(null);
            setRechte(daten.getMandantNr(), false);
            // alle Tabs schließen
            for (Tab t : getTabs().getTabs()) {
                if (t.getOnClosed() != null) {
                    t.getOnClosed().handle(null);
                }
            }
            getTabs().getTabs().clear();
            Jhh6.getEinstellungen().refreshMandant();
            // System.out.println("Abgemeldet.");
            handleAnmelden(null);
        }
    }

    @FXML
    protected void handleBeenden(ActionEvent e) {
        Platform.exit(); // Anwendung beenden
    }

    private void setRechte(int mandantNr, boolean ok) {

        sepFi1.setVisible(ok);
        sepFi2.setVisible(ok);
        menueUndo.setVisible(ok);
        menueRedo.setVisible(ok);
        menueAG100.setVisible(ok);
        menueAG200.setVisible(ok);
        menueAG400.setVisible(ok);
        sepAm1.setVisible(ok);
        menueAnmelden.setVisible(!ok);
        menueAbmelden.setVisible(ok);
        menueAD100.setVisible(ok);
        menueAM100.setVisible(ok);
        menueAM500.setVisible(ok);
        menueAM510.setVisible(ok);
        menueHp.setVisible(Jhh6.getEinstellungen().getMenuHeilpraktiker(mandantNr));
        menueHP100.setVisible(ok);
        menueHH100.setVisible(ok);
        menueHH200.setVisible(ok);
        menueHH300.setVisible(ok);
        menueHH400.setVisible(ok);
        sepHh1.setVisible(ok);
        menueHH500EB.setVisible(ok);
        menueHH500GV.setVisible(ok);
        menueHH500SB.setVisible(ok);
        menueHP150.setVisible(ok);
        menueHP200.setVisible(ok);
        menueHP300.setVisible(ok);
        menueHP350.setVisible(ok);
        menueHP400.setVisible(ok);
        menueMo.setVisible(Jhh6.getEinstellungen().getMenuMessdiener(mandantNr));
        menueMO100.setVisible(ok);
        menueMO200.setVisible(ok);
        menueMO300.setVisible(ok);
        menueSB200.setVisible(ok);
        menueSB300.setVisible(ok);
        menueSB400.setVisible(ok);
        menueSO100.setVisible(ok);
        menueSO200.setVisible(ok);
        menueTB100.setVisible(ok);
        sepFz1.setVisible(ok);
        sepFz2.setVisible(ok);
        sepFz3.setVisible(ok);
        sepFz4.setVisible(ok);
        menueFZ100.setVisible(ok);
        menueFZ200.setVisible(ok);
        menueFZ250.setVisible(ok);
        menueFZ300.setVisible(ok);
        menueFZ320.setVisible(ok);
        menueFZ340.setVisible(ok);
        menueFZ700.setVisible(ok);
        menueVm.setVisible(Jhh6.getEinstellungen().getMenuVermietung(mandantNr));
        sepVm1.setVisible(ok);
        sepVm2.setVisible(ok);
        sepVm3.setVisible(ok);
        menueVM100.setVisible(ok);
        menueVM200.setVisible(ok);
        menueVM300.setVisible(ok);
        menueVM400.setVisible(ok);
        menueVM500.setVisible(ok);
        menueVM600.setVisible(ok);
        menueVM700.setVisible(ok);
        menueVM800.setVisible(ok);
        menueVM900.setVisible(ok);
        menueVM920.setVisible(ok);
        menueVMHH100.setVisible(ok);
        menueWp.setVisible(ok);
        menueWP100.setVisible(ok);
        menueWP110.setVisible(ok);
        menueWP200.setVisible(ok);
        menueWP250.setVisible(ok);
        menueWP300.setVisible(ok);
        menueWP400.setVisible(ok);
        menueWP500.setVisible(ok);
        sepWp1.setVisible(ok);
        sepWp2.setVisible(ok);
        Platform.runLater(() -> {
            Jhh6.aktualisiereTitel();
            boolean g = Global.objBool(Jhh6.getEinstellungen().getDateiParameter("AD120Geburtstage_Starten"));
            if (ok && g) {
                // starteFormular(AD120GeburtstageController.class, DialogAufrufEnum.OHNE);
            }
        });
    }

    private void startDialoge(int mandantNr) {

        Platform.runLater(() -> {
            List<StartDialog> dliste = Jhh6Controller.getDialogListe();
            String str = Global.nn(Jhh6.getEinstellungen().getStartdialoge(mandantNr));
            String[] array = str.split(Pattern.quote("|"));
            HashMap<String, StartDialog> map = new HashMap<>();
            dliste.stream().forEach(a -> map.put(a.getId(), a));
            for (String s : array) {
                StartDialog d = map.get(s);
                if (d != null) {
                    starteFormular(d.getClazz(), DialogAufrufEnum.OHNE, d.getParameter());
                }
            }
        });
    }

    private static ResourceBundle bundle = null;
    
    public static ResourceBundle getBundle() {
        
        if (bundle == null) {
            bundle = ResourceBundle.getBundle("Jhh6");
        }
        return bundle;
    }

    private static String g(String s) {

        String w = getBundle().getString(s);
        if (!Global.nes(w)) {
            w = w.replace("_", "");
        }
        return w;
    }

    public static List<StartDialog> getDialogListe() {

        List<StartDialog> l = new ArrayList<StartDialog>();
        // l.add(new StartDialog("#AG100", g("menu.title.clients"), AG100MandantenController.class, null));
        // l.add(new StartDialog("#AG200", g("menu.title.users"), AG200BenutzerController.class, null));
        // l.add(new StartDialog("#AG400", g("menu.title.backups"), AG400SicherungenController.class, null));
        // l.add(new StartDialog("#TB100", g("menu.title.diary"), TB100TagebuchController.class, null));
        // l.add(new StartDialog("#FZ700", g("menu.title.notes"), FZ700NotizenController.class, null));
        // l.add(new StartDialog("#AD100", g("menu.title.persons"), AD100PersonenController.class, null));
        // l.add(new StartDialog("#FZ250", g("menu.title.milages"), FZ250FahrradstaendeController.class, null));
        // l.add(new StartDialog("#FZ200", g("menu.title.bikes"), FZ200FahrraederController.class, null));
        // l.add(new StartDialog("#FZ300", g("menu.title.authors"), FZ300AutorenController.class, null));
        // l.add(new StartDialog("#FZ320", g("menu.title.series"), FZ320SerienController.class, null));
        // l.add(new StartDialog("#FZ340", g("menu.title.books"), FZ340BuecherController.class, null));
        // l.add(new StartDialog("#SO100", g("menu.title.sudoku"), SO100SudokuController.class, null));
        // l.add(new StartDialog("#SO200", g("menu.title.detective"), SO200DetektivController.class, null));
        // l.add(new StartDialog("#FZ100", g("menu.title.statistic"), FZ100StatistikController.class, null));
        // l.add(new StartDialog("#HH400", g("menu.title.bookings"), HH400BuchungenController.class, null));
        // l.add(new StartDialog("#HH300", g("menu.title.events"), HH300EreignisseController.class, null));
        // l.add(new StartDialog("#HH200", g("menu.title.accounts"), HH200KontenController.class, null));
        // l.add(new StartDialog("#HH100", g("menu.title.periods"), HH100PeriodenController.class, null));
        // l.add(new StartDialog("#HH500;EB", g("menu.title.openingbalance"), HH500BilanzenController.class, "EB"));
        // l.add(new StartDialog("#HH500;GV", g("menu.title.plbalance"), HH500BilanzenController.class, "GV"));
        // l.add(new StartDialog("#HH500;SB", g("menu.title.finalbalance"), HH500BilanzenController.class, "SB"));
        // l.add(new StartDialog("#VM500", g("menu.title.bookings2"), VM500BuchungenController.class, null));
        // l.add(new StartDialog("#VM920", g("menu.title.accountings"), VM920AbrechnungenController.class, null));
        // l.add(new StartDialog("#HP200", g("menu.title.treatments"), HP200BehandlungenController.class, null));
        // l.add(new StartDialog("#SB200", g("menu.title.ancestors"), SB200AhnenController.class, null));
        // l.add(new StartDialog("#SB300", g("menu.title.families"), SB300FamilienController.class, null));
        // l.add(new StartDialog("#VM300", g("menu.title.renters"), VM300MieterController.class, null));
        // l.add(new StartDialog("#WP200", g("menu.title.stocks"), WP200WertpapiereController.class, null));
        // l.add(new StartDialog("#WP250", g("menu.title.investments"), WP250AnlagenController.class, null));
        // l.add(new StartDialog("#WP400", g("menu.title.bookings3"), WP400BuchungenController.class, null));
        // l.add(new StartDialog("#WP500", g("menu.title.prices"), WP500StaendeController.class, null));
        // l.add(new StartDialog("#MO200", g("menu.title.holymass"), MO200GottesdiensteController.class, null));
        return l;
    }

    @FXML
    public void handleUndo() {
        get(Jhh6.rollback());
    }

    @FXML
    public void handleRedo() {
        get(Jhh6.redo());
    }

    @FXML
    public void handleAG100() {
        // starteFormular(AG100MandantenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAG200() {
        // starteFormular(AG200BenutzerController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAG400() {
        // starteFormular(AG400SicherungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAD100() {
        // starteFormular(AD100PersonenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAM100() {
        // starteDialog(AM100AenderungController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAM500() {
        // starteFormular(AM500EinstellungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAM510() {
        // starteFormular(AM510DialogeController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleReset() {
        Jhh6.getEinstellungen().reset();
    }

    @FXML
    public void handleAG000() {
        // starteFormular(AG000InfoController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleAG010() {
        // starteFormular(AG010HilfeController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ100() {
        // starteFormular(FZ100StatistikController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ200() {
        // starteFormular(FZ200FahrraederController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ250() {
        // starteFormular(FZ250FahrradstaendeController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ300() {
        // starteFormular(FZ300AutorenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ320() {
        // starteFormular(FZ320SerienController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ340() {
        // starteFormular(FZ340BuecherController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleFZ700() {
        // starteFormular(FZ700NotizenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHH100() {
        // starteFormular(HH100PeriodenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHH200() {
        // starteFormular(HH200KontenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHH300() {
        // starteFormular(HH300EreignisseController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHH400() {
        // starteFormular(HH400BuchungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHH500EB() {
        // starteFormular(HH500BilanzenController.class, DialogAufrufEnum.OHNE, Constant.KZBI_EROEFFNUNG);
    }

    @FXML
    public void handleHH500GV() {
        // starteFormular(HH500BilanzenController.class, DialogAufrufEnum.OHNE, Constant.KZBI_GV);
    }

    @FXML
    public void handleHH500SB() {
        // starteFormular(HH500BilanzenController.class, DialogAufrufEnum.OHNE, Constant.KZBI_SCHLUSS);
    }

    @FXML
    public void handleHP100() {
        // starteFormular(HP100PatientenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHP150() {
        // starteFormular(HP150StatusController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHP200() {
        // starteFormular(HP200BehandlungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHP300() {
        // starteFormular(HP300LeistungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHP350() {
        // starteFormular(HP350LeistungsgruppenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleHP400() {
        // starteFormular(HP400RechnungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleMO100() {
        // starteFormular(MO100MessdienerController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleMO200() {
        // starteFormular(MO200GottesdiensteController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleMO300() {
        // starteFormular(MO300ProfileController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleSB200() {
        // starteFormular(SB200AhnenController.class, DialogAufrufEnum.OHNE);
    }

    public void handleSB300() {
        // starteFormular(SB300FamilienController.class, DialogAufrufEnum.OHNE);
    }

    public void handleSB400() {
        // starteFormular(SB400QuellenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleSO100() {
        // starteFormular(SO100SudokuController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleSO200() {
        // starteFormular(SO200DetektivController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleTB100() {
        // starteFormular(TB100TagebuchController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM100() {
        // starteFormular(VM100HaeuserController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM200() {
        // starteFormular(VM200WohnungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM300() {
        // starteFormular(VM300MieterController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM400() {
        // starteFormular(VM400MietenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM500() {
        // starteFormular(VM500BuchungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM600() {
        // starteFormular(VM600KontenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM700() {
        // starteFormular(VM700EreignisseController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM800() {
        // starteFormular(VM800ForderungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM900() {
        // starteFormular(VM900AbrechnungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVM920() {
        // starteFormular(VM920AbrechnungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleVMHH100() {
        // starteFormular(HH100PeriodenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP100() {
        // starteFormular(WP100ChartController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP110() {
        // starteFormular(WP110ChartsController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP200() {
        // starteFormular(WP200WertpapiereController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP250() {
        // starteFormular(WP250AnlagenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP300() {
        // starteFormular(WP300KonfigurationenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP400() {
        // starteFormular(WP400BuchungenController.class, DialogAufrufEnum.OHNE);
    }

    @FXML
    public void handleWP500() {
        // starteFormular(WP500StaendeController.class, DialogAufrufEnum.OHNE);
    }

    public TabPane getTabs() {
        return tabs;
    }

    public void closeTabs() {

        for (Tab t : tabs.getTabs()) {
            // Close-Event händisch aufrufen
            t.getOnClosed().handle(null);
        }
        tabs.getTabs().removeAll(tabs.getTabs());
    }
}

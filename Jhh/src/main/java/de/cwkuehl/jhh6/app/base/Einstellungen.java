package de.cwkuehl.jhh6.app.base;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import org.apache.log4j.Logger;

import de.cwkuehl.jhh6.api.dto.MaParameter;
import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.global.Parameter;
import de.cwkuehl.jhh6.api.service.ServiceDaten;
import de.cwkuehl.jhh6.api.service.ServiceErgebnis;
import de.cwkuehl.jhh6.app.Jhh6;
import de.cwkuehl.jhh6.server.FactoryService;

public class Einstellungen {

    protected Logger   log          = null;
    private Properties properties   = null;
    private String     propertyFile = null;

    private String     builtTime    = null;
    private String     builtBy      = null;
    private String     benutzer     = null;
    private String     test         = null;

    public Einstellungen() {

        log = Logger.getLogger(Einstellungen.class);
        properties = new Properties();

        String homeDir = System.getProperty("user.home");
        if (homeDir == null)
            return;
        String prop = System.getProperty("jhh6.properties");
        if (prop == null) {
            prop = ".jhh6test.properties";
        }
        propertyFile = homeDir + File.separator + prop;
        // log.error("Properties: " + propertyFile);

        InputStream in = null;

        try {
            in = new FileInputStream(propertyFile);
            properties.load(in);
        } catch (IOException e) {
        } finally {
            if (in != null)
                try {
                    in.close();
                } catch (IOException e) {
                }
        }
        try {
            InputStream stream = getClass().getResourceAsStream("/META-INF/MANIFEST.MF");
            Manifest manifest = new Manifest(stream);
            Attributes attributes = manifest.getMainAttributes();

            builtTime = attributes.getValue("Built-Time");
            builtBy = attributes.getValue("Built-By");
        } catch (IOException e) {
            Global.machNichts();
        }
    }

    /**
     * Liefert Manifest-Eigenschaft Build-Time.
     * @return Manifest-Eigenschaft Build-Time.
     */
    public String getBuiltTime() {
        return builtTime;
    }

    /**
     * Liefert Manifest-Eigenschaft Build-By.
     * @return Manifest-Eigenschaft Build-By.
     */
    public String getBuiltBy() {
        return builtBy;
    }

    /**
     * Liefert Wert einer Einstellung aus der Resourcedaten-Datei.
     * @param key Name einer Eigenschaft.
     * @return String aus Resourcedaten-Datei.
     */
    public String holeResourceDaten(final String key) {

        String wert = properties.getProperty(key);
        // System.out.println("get " + key + "=" + wert);
        return wert;
    }

    /**
     * Liefert die Fenstergröße. Falls die Fenstergröße in den Resourcedaten gespeichert ist, werden diese Daten
     * genommen.
     * @param key Schlüssel für Resourcedaten.
     * @param pwidth Standardbreite. Faktor von Bildschirmbreite.
     * @param pheight Standardhöhe. Faktor von Bildschirmhöhe.
     * @return Groesse mit Breite, Höhe, x- und y-Position.
     */
    public Groesse getDialogGroesse(final String key) {

        Groesse groesse = new Groesse();
        String strGroesse = holeResourceDaten(key);

        if (!Global.nes(strGroesse)) {
            String[] array = strGroesse.split(";");
            if (array.length >= 4) {
                try {
                    groesse.setWidth(Global.strInt(array[0]));
                    groesse.setHeight(Global.strInt(array[1]));
                    groesse.setX(Global.strInt(array[2]));
                    groesse.setY(Global.strInt(array[3]));
                    // if (Global.istLinux()) {
                    // groesse.y -= 28;
                    // }
                } catch (Exception ex) {
                    Global.machNichts();
                }
            }
        }
        return groesse;
    }

    /**
     * Speichern der Fenstergröße in den Resourcedaten.
     * @param key Schlüssel für Resourcedaten.
     * @param g Größe, die gespeichert werden soll.
     */
    public void setDialogGroesse(final String key, Groesse g) {

        String groesse = "" + g.getWidth() + ";" + g.getHeight() + ";" + g.getX() + ";" + g.getY();
        setzeResourceDaten(key, groesse);
    }

    /**
     * Setzt ein Wert in der Resourcedaten-Datei für einen Schlüssel.
     * @param key Schlüssel.
     * @param value Wert.
     */
    public void setzeResourceDaten(final String key, final String value) {

        // System.out.println("set " + key + "=" + value);
        if (Global.nes(value)) {
            properties.setProperty(key, "");
        } else {
            properties.setProperty(key, value);
        }
    }

    /**
     * Liefert den Betriebssystem-Benutzer.
     * @return Betriebssystem-Benutzer.
     */
    public String getBenutzer() {

        String value = benutzer;
        if (value == null) {
            value = System.getProperty("user.name");
        }

        return (value == null) ? "" : value;
    }

    /**
     * Setzen des Betriebssystem-Benutzers.
     * @param benutzer Zu setzender Betriebssystem-Benutzer.
     */
    public void setBenutzer(String benutzer) {
        this.benutzer = benutzer;
    }

    public void setParameter(int mandantNr, String key, String value) {

        if (key == null || value == null) {
            return;
        }
        Parameter p = Parameter.getParameter().get(key);
        if (p != null) {
            p.wert = value;
            if (p.verschluesselt) {
                // Verschlüsseln
                value = Global.encryptString(value);
            }
            if (p.inDatenbank) {
                ServiceErgebnis<Void> r = FactoryService.getAnmeldungService().setParameter(Jhh6.getServiceDaten(),
                        mandantNr, key, value);
                if (r == null) {
                    Global.machNichts();
                }
            }
            if (p.inDatei) {
                properties.setProperty(key, value);
            }
        } else {
            properties.setProperty(key, value);
        }
    }

    public void save() {

        ServiceDaten daten = Jhh6.getServiceDaten();
        save(daten.getMandantNr());
    }

    public void save(int mandantNr) {

        if (propertyFile == null) {
            return;
        }
        OutputStream out = null;

        try {
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            if (cl == null) {
                // Kein thread context class loader: eigenen class loader
                cl = this.getClass().getClassLoader();
            }
            if (properties == null)
                return;
            StringBuilder komm = new StringBuilder();
            String ls = System.getProperty("line.separator");
            komm.append(" Property-Datei für Programm JHH6");
            for (Iterator<Parameter> it = Parameter.getParameter().values().iterator(); it.hasNext();) {
                Parameter p = it.next();
                if (p.inDatei && !Global.nes(p.kommentar))
                    komm.append(ls).append("# ").append(p.schluessel).append(": ").append(p.kommentar);
                getParameter(mandantNr, p.schluessel);
                setParameter(mandantNr, p.schluessel, p.wert);
            }
            out = new FileOutputStream(propertyFile);
            properties.store(out, komm.toString());
        } catch (IOException ex) {
            // log.error("save", ex);
            throw new RuntimeException(ex);
        } finally {
            if (out != null)
                try {
                    out.close();
                } catch (IOException e) {
                }
        }
    }

    public void reset() {

        Enumeration<Object> e = properties.keys();
        while (e.hasMoreElements()) {
            String key = e.nextElement().toString();
            Parameter p = Parameter.getParameter().get(key);
            if (p == null && key.endsWith("Controller")) {
                properties.remove(key);
            }
        }
        save();
    }

    public String getDateiParameter(final String key) {

        String str = properties.getProperty(key);
        return str;
    }

    private String getParameter(final int mandantNr, final String key) {

        Parameter p = Parameter.getParameter().get(key);
        if (p == null) {
            return null;
        }
        if (p.wert != null) {
            return p.wert;
        }
        String str = null;

        // Parameter aus Datenbank geht vor
        if (p.inDatenbank) {
            ServiceErgebnis<MaParameter> r = FactoryService.getAnmeldungService().getParameter(Jhh6.getServiceDaten(),
                    mandantNr, key);
            if (r.getErgebnis() != null) {
                str = r.getErgebnis().getWert();
            }
        }
        if (Global.nes(str) && p.inDatei) {
            str = properties.getProperty(key);
        }
        if (Global.nes(str)) {
            str = p.standard;
        }
        if (p.trim && !Global.nes(str)) {
            str = str.trim();
        }
        if (str == null) {
            str = "";
        }
        if (!Global.nes(str) && p.verschluesselt) {
            // Entschlüsseln
            str = Global.decryptString(str);
        }
        p.wert = str;
        return str;
    }

    /**
     * Liefert int-Array aus den Resourcedaten.
     * @return int-Array.
     */
    public int[] getIntArray(final String key) {

        int[] b = null;
        String resDaten = holeResourceDaten(key);
        if (!Global.nes(resDaten)) {
            String[] array = resDaten.split(";");
            if (array != null && array.length > 0) {
                b = new int[array.length];
                for (int i = 0; i < b.length; i++) {
                    b[i] = Global.strInt(array[i]);
                }
            }
        }
        if (b == null) {
            b = new int[0];
        }
        return b;
    }

    /**
     * Setzen des Test-Modus mit "TEST".
     * @param test Test-String.
     */
    public void setTest(String test) {
        this.test = test;
    }

    /**
     * Liefert Einstellung AG_TEST_PRODUKTION.
     * @return Einstellung.
     */
    public boolean isTest() {

        String str = test;
        if (str == null) {
            str = getParameter(0, Parameter.AG_TEST_PRODUKTION);
        }
        return "TEST".equalsIgnoreCase(str);
    }

    /**
     * Liefert Einstellung AG_ANWENDUNGS_TITEL.
     * @return Einstellung.
     */
    public String getAnwendungsTitel(int mandantNr) {
        return getParameter(mandantNr, Parameter.AG_ANWENDUNGS_TITEL);
    }

    /**
     * Liefert Einstellung AG_HILFE_DATEI.
     * @return Einstellung.
     */
    public String getHilfeDatei() {

        String str = getParameter(0, Parameter.AG_HILFE_DATEI);
        File f = new File(str);
        String pfad = f.getAbsolutePath();
        return pfad;
    }

    /**
     * Liefert Einstellung AG_TEMP_PFAD.
     * @return Einstellung AG_TEMP_PFAD.
     */
    public String getTempVerzeichnis() {

        String str = getParameter(0, Parameter.AG_TEMP_PFAD);
        if (Global.nes(str)) {
            str = System.getProperty("user.home") + File.separator + "temp";
        }
        return str;
    }

    /**
     * Einstellung AG_TEMP_PFAD wird gesetzt.
     * @param pfad temporäres Verzeichnis.
     */
    public void setTempVerzeichnis(final String pfad) {
        setParameter(0, Parameter.AG_TEMP_PFAD, pfad);
    }

    /**
     * Liefert Einstellung MENU_VERMIETUNG.
     * @return Einstellung MENU_VERMIETUNG.
     */
    public boolean getMenuVermietung(int mandantNr) {

        String str = getParameter(mandantNr, Parameter.MENU_VERMIETUNG);
        return Global.strInt(str) != 0;
    }

    /**
     * Liefert Einstellung MENU_HEILPRAKTIKER.
     * @return Einstellung MENU_HEILPRAKTIKER.
     */
    public boolean getMenuHeilpraktiker(int mandantNr) {

        String str = getParameter(mandantNr, Parameter.MENU_HEILPRAKTIKER);
        return Global.strInt(str) != 0;
    }

    /**
     * Liefert Einstellung MENU_MESSDIENER.
     * @return Einstellung MENU_MESSDIENER.
     */
    public boolean getMenuMessdiener(int mandantNr) {

        String str = getParameter(mandantNr, Parameter.MENU_MESSDIENER);
        return Global.strInt(str) != 0;
    }

    /**
     * Einstellung AG_STARTDIALOGE wird gesetzt.
     * @param str Liste der Start-Dialoge.
     */
    public void setStartdialoge(int mandantNr, final String str) {
        setParameter(mandantNr, Parameter.AG_STARTDIALOGE, str);
    }

    /**
     * Liefert Einstellung AG_STARTDIALOGE.
     * @return Einstellung AG_STARTDIALOGE.
     */
    public String getStartdialoge(int mandantNr) {

        String str = getParameter(mandantNr, Parameter.AG_STARTDIALOGE);
        return str;
    }

    /**
     * Parameter-Werte auf null, damit sie beim nächsten Lesen neu bestimmt werden.
     */
    public void refreshMandant() {

        for (Parameter p : Parameter.getParameter().values()) {
            if (p != null && p.inDatenbank) {
                // Werte auf null, damit die beim nächsten Lesen neu bestimmt werden.
                p.wert = null;
                // getParameter(p.schluessel);
            }
        }
    }

    public List<MaParameter> getEinstellungen(int mandantNr, boolean auchDatenbank) {

        ArrayList<MaParameter> liste = new ArrayList<>();
        boolean mo = getMenuMessdiener(mandantNr);
        boolean hp = getMenuHeilpraktiker(mandantNr);
        for (Parameter p : Parameter.getParameter().values()) {
            if (p != null && p.inDatei && (auchDatenbank || !p.inDatenbank) && (mo || !p.schluessel.startsWith("MO_"))
                    && (hp || !p.schluessel.startsWith("HP_"))) {
                MaParameter me = new MaParameter();
                me.setMandantNr(mandantNr);
                me.setSchluessel(p.schluessel);
                me.setWert(getParameter(mandantNr, p.schluessel));
                me.setAngelegtVon(p.kommentar);
                me.setGeaendertVon(p.standard);
                liste.add(me);
            }
        }
        Collections.sort(liste, new Comparator<MaParameter>() {
            public int compare(MaParameter o1, MaParameter o2) {
                return o1.getSchluessel().compareTo(o2.getSchluessel());
            }
        });
        return liste;
    }

}

package de.cwkuehl.jhh6.server.service.backup;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;

import de.cwkuehl.jhh6.api.global.Global;
import de.cwkuehl.jhh6.api.message.Meldungen;
import de.cwkuehl.jhh6.api.service.backup.Sicherungsdatei;
import de.cwkuehl.jhh6.api.service.backup.Sicherungsdaten;

/**
 * Klasse zum Speichern der notwendigen Aktionen bei einer Sicherung.
 */
public class Sicherung {

    /** Maximale Anzahl von Fehlern bei Sicherung. */
    public static final int            MAX_SICHERUNG_FEHLER   = 0;
    /**
     * Zeit in Millisekunden, die sich die Dateien unterscheiden dürfen, um als gleich zu gelten.
     */
    public static final long           MAX_SICHERUNG_DIFFZEIT = 2000;

    public static String               DIFF_PFAD              = "_diff_";
    public static String               NEU_PFAD               = "_neu_";
    public static String               GELOESCHT_PFAD         = "_geloescht_";

    /** Liste mit Aktionen für die Sicherung. */
    private ArrayList<Sicherungsdaten> daten                  = new ArrayList<Sicherungsdaten>();

    /**
     * Zeit in Millisekunden, die sich die Dateien unterscheiden dürfen, um als gleich zu gelten.
     */
    private long                       diffZeit               = 0;

    /**
     * In diese Liste werden die Dateien eingetragen, die nicht kopiert werden konnten.
     */
    private List<String>               kopierFehler           = null;

    /** Status-StringBuffer. */
    private StringBuffer               status                 = null;

    /** Anzahl der Fehler, nach denen abgebrochen wird. */
    private int                        maxFehler              = 0;

    /** Wenn StringBuffer-Länge größer 0 ist, wird das Kopieren abgebrochen. */
    private StringBuffer               abbruch                = null;

    /** True, wenn Differenz-Sicherung gemacht werden soll? */
    private boolean                    diffSicherung          = false;

    /** True, wenn Rück-Sicherung gemacht werden soll? */
    private boolean                    rueckSicherung         = false;

    /** Pfad für neue oder geänderte Dateien bei Differenz-Sicherung. */
    private String                     neuPfad                = null;

    /** Pfad für gelöschte Dateien bei Differenz-Sicherung. */
    private String                     geloeschtPfad          = null;

    /**
     * True, wenn alle Pfade und Dateien in Kleinbuchstaben umgewandelt werden müssen?
     */
    private boolean                    nurKleinbuchstaben     = false;

    /**
     * Konstruktor mit Initialisierung.
     * @param diffZeit Zeit in Millisekunden, die sich die Dateien unterscheiden dürfen, um als gleich zu gelten.
     * @param kopierFehler In diese Liste werden die Dateien eingetragen, die nicht kopiert werden konnten.
     * @param status Status-StringBuffer.
     * @param maxFehler Anzahl der Fehler, nach denen abgebrochen wird.
     * @param abbruch Wenn StringBuffer-Länge größer 0 ist, wird das Kopieren abgebrochen.
     * @param diffSicherung True, wenn Differenz-Sicherung gemacht werden soll?
     * @param rueckSicherung Soll eine Rücksicherung durchgeführt werden?
     * @param jetzt Aktuelle Uhrzeit.
     */
    public Sicherung(final long diffZeit, final List<String> kopierFehler, final StringBuffer status,
            final int maxFehler, final StringBuffer abbruch, final boolean diffSicherung, final boolean rueckSicherung,
            LocalDateTime jetzt) {

        this.diffZeit = diffZeit;
        this.kopierFehler = kopierFehler;
        this.status = status;
        this.maxFehler = maxFehler;
        this.abbruch = abbruch;
        this.diffSicherung = diffSicherung;
        this.rueckSicherung = rueckSicherung;
        this.nurKleinbuchstaben = false;

        if (diffSicherung) {
            DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            String diffPfad = DIFF_PFAD + jetzt.format(df);
            neuPfad = umsetzenPfadDatei(diffPfad + File.separator + NEU_PFAD, false);
            geloeschtPfad = umsetzenPfadDatei(diffPfad + File.separator + GELOESCHT_PFAD, false);
        }
    }

    public static String[] splitQuelleZiel(String str, boolean exception) {

        String[] array = null;
        array = str.split("<", 2);
        if (Global.arrayLaenge(array) < 2) {
            if (exception) {
                throw new RuntimeException(Meldungen.M1034());
            }
            array = new String[2];
            array[0] = str;
            array[1] = "";
        }
        return array;
    }

    /**
     * Die Erstellung oder Aktualisierung einer Sicherung eines Verzeichnisses wird vorbereitet.
     * @param strPfade Zeichenkette mit dem Verzeichnis, in dem die Kopie des zu sichernden Verzeichnisses liegt, und
     *        einer Liste von Pfaden, die gesichert werden sollen, z.B. I:&lt;D:/Fotos;D:/EigenC
     * @throws Exception im unerwarteten Fehlerfalle.
     */
    public void machSicherungVorbereitung(final String strPfade) throws Exception {

        String strPfad = null;
        String strSicherPfad = null;
        String[] array1 = null;
        String[] array2 = null;

        if (Global.nes(strPfade)) {
            throw new Exception(Meldungen.M1035());
        }
        array1 = splitQuelleZiel(strPfade, true);
        strSicherPfad = array1[0];
        array2 = array1[1].split(";");
        if (Global.arrayLaenge(array2) <= 0) {
            throw new Exception(Meldungen.M1036());
        }
        for (int i = 0; i < array2.length; i++) {
            strPfad = array2[i];
            machSicherungVorbereitung(strPfad, strSicherPfad);
        }
    }

    /**
     * Die Erstellung oder Aktualisierung einer Sicherung eines Verzeichnisses wird vorbereitet.
     * @param strPfad Zu sicherndes Verzeichnis.
     * @param strSicherPfad Verzeichnis, in dem die Kopie des zu sichernden Verzeichnisses liegt.
     * @throws Exception im unerwarteten Fehlerfalle.
     */
    private void machSicherungVorbereitung(final String strPfad, final String strSicherPfad) throws Exception {

        File pfad = null;
        File sicherung = null;
        String pfadPfad = null;
        String sichPfad = null;
        String sichBasisPfad = null;

        // Plausis
        if (Global.nes(strPfad)) {
            throw new Exception(Meldungen.M1037());
        }
        if (Global.nes(strSicherPfad)) {
            throw new Exception(Meldungen.M1035());
        }
        if (daten == null) {
            daten = new ArrayList<Sicherungsdaten>();
        }

        pfadPfad = umsetzenPfadDatei(strPfad, true);
        pfad = new File(pfadPfad);
        if (!pfad.exists() || !pfad.isDirectory()) {
            throw new Exception(Meldungen.M1038(strPfad));
        }
        sichPfad = umsetzenPfadDatei(strSicherPfad, true);
        sichBasisPfad = sichPfad;
        // Verzeichnis-Name im Sicherungs-Verzeichnis benutzen.
        sicherung = new File(sichPfad + pfad.getName());
        if (sicherung.exists()) {
            if (!sicherung.isDirectory()) {
                throw new Exception(Meldungen.M1038(sichPfad + pfad.getName()));
            }
        } else {
            // Evtl. auch Ober-Verzeichnisse des Sicherungs-Verzeichnisses
            // anlegen.
            sicherung.mkdirs();
        }

        pfadPfad = umsetzenPfadDatei(pfad.getPath(), true);
        sichPfad = umsetzenPfadDatei(sicherung.getPath(), true);

        // Dateilisten aufbauen
        machSicherungVorbereitung2(pfad, sicherung, pfadPfad, sichPfad, sichBasisPfad);
    }

    /**
     * Die Erstellung oder Aktualisierung einer Sicherung eines Verzeichnisses wird vorbereitet.
     * @param strPfad Zu sicherndes Verzeichnis.
     * @param strSicherPfad Verzeichnis, in dem die Kopie des zu sichernden Verzeichnisses liegt.
     * @throws Exception im unerwarteten Fehlerfalle.
     */
    private void machSicherungVorbereitung2(final File pfad, final File sicherung, final String pfadPfad,
            final String sichPfad, final String sichBasisPfad) throws Exception {

        Hashtable<String, Sicherungsdatei> pfadHt = null;
        Hashtable<String, Sicherungsdatei> sichHt = null;
        String datei = null;
        Sicherungsdatei sichDatei = null;
        long pfadVeraendert = 0;
        Hashtable<String, Sicherungsdatei> kopierListe = null;
        ArrayList<String> pfadVerzeichnis = null;
        ArrayList<String> sichVerzeichnis = null;
        ArrayList<String> verzeichnisListe = null;
        Hashtable<String, Sicherungsdatei> dateiListe = null;

        if (diffSicherung && rueckSicherung) {
            throw new Exception(Meldungen.M1039());
        }
        // Dateilisten aufbauen
        pfadHt = new Hashtable<String, Sicherungsdatei>();
        pfadVerzeichnis = new ArrayList<String>();
        sichHt = new Hashtable<String, Sicherungsdatei>();
        sichVerzeichnis = new ArrayList<String>();
        fuelleDateilisteRekursiv(pfad, pfadPfad, pfadHt, pfadVerzeichnis, sichPfad, false, false, false);
        fuelleDateilisteRekursiv(sicherung, sichPfad, sichHt, sichVerzeichnis, pfadPfad, false, false, false);

        // Differenz-Verzeichnisse einbeziehen
        File basisPfad = new File(sichBasisPfad);
        FilenameFilter fnf = new DiffFilenameFilter();
        String[] diffDirs = basisPfad.list(fnf);
        if (Global.arrayLaenge(diffDirs) > 0) {
            if (!diffSicherung && !rueckSicherung) {
                throw new Exception(Meldungen.M1040());
            }
            Arrays.sort(diffDirs);
            File diffSicherung = null;
            String diffSichPfad = null;
            for (int i = 0; i < diffDirs.length; i++) {
                diffSicherung = new File(sichBasisPfad + diffDirs[i] + File.separator + NEU_PFAD + File.separator + pfad
                        .getName());
                diffSichPfad = umsetzenPfadDatei(diffSicherung.getPath(), true);
                fuelleDateilisteRekursiv(diffSicherung, diffSichPfad, sichHt, sichVerzeichnis, pfadPfad, false,
                        rueckSicherung, true);
                diffSicherung = new File(sichBasisPfad + diffDirs[i] + File.separator + GELOESCHT_PFAD + File.separator
                        + pfad.getName());
                diffSichPfad = umsetzenPfadDatei(diffSicherung.getPath(), true);
                fuelleDateilisteRekursiv(diffSicherung, diffSichPfad, sichHt, sichVerzeichnis, pfadPfad, true, false,
                        true);
            }
        }

        // Dateilisten vergleichen
        kopierListe = new Hashtable<String, Sicherungsdatei>();
        for (Enumeration<String> e = pfadHt.keys(); e.hasMoreElements();) {
            datei = e.nextElement();
            sichDatei = sichHt.get(datei);
            if (sichDatei != null) {
                // Datei im Pfad und in Sicherung vorhanden.
                pfadVeraendert = pfadHt.get(datei).getModified();
                if (!isModifiedEqual(sichDatei.getModified(), pfadVeraendert)) {
                    // Datei im Pfad neuer oder älter: kopieren.
                    kopierListe.put(datei, pfadHt.get(datei));
                }
                sichHt.remove(datei);
            } else {
                // Datei nur im Pfad: kopieren.
                kopierListe.put(datei, pfadHt.get(datei));
            }
        }

        // Verzeichnislisten vergleichen
        String verzeichnis = null;
        int j = 0;
        for (int i = 0; i < pfadVerzeichnis.size(); i++) {
            verzeichnis = pfadVerzeichnis.get(i);
            j = sichVerzeichnis.indexOf(verzeichnis);
            if (j >= 0) {
                // Verzeichnis ist in beiden Listen: entfernen.
                pfadVerzeichnis.remove(i);
                i--;
                sichVerzeichnis.remove(j);
            }
        }

        // Verzeichnisse anlegen
        if (rueckSicherung) {
            verzeichnisListe = sichVerzeichnis;
        } else {
            verzeichnisListe = pfadVerzeichnis;
        }
        for (String kVerzeichnis : verzeichnisListe) {
            daten.add(new Sicherungsdaten("VA", kVerzeichnis, pfadPfad, sichPfad, sichBasisPfad, null));
        }

        // Dateien kopieren
        if (rueckSicherung) {
            dateiListe = sichHt;
        } else {
            dateiListe = kopierListe;
        }
        for (Enumeration<String> e = dateiListe.keys(); e.hasMoreElements();) {
            datei = e.nextElement();
            daten.add(new Sicherungsdaten("DK", datei, pfadPfad, sichPfad, sichBasisPfad, dateiListe.get(datei)
                    .getPfad()));
        }

        // überflüssige Dateien löschen
        if (rueckSicherung) {
            dateiListe = kopierListe;
        } else {
            dateiListe = sichHt;
        }
        for (Enumeration<String> e = dateiListe.keys(); e.hasMoreElements();) {
            datei = e.nextElement();
            daten.add(new Sicherungsdaten("DL", datei, pfadPfad, sichPfad, sichBasisPfad, null));
        }

        // überflüssige Verzeichnisse aus Sicherung löschen
        if (rueckSicherung) {
            verzeichnisListe = pfadVerzeichnis;
        } else {
            verzeichnisListe = sichVerzeichnis;
        }
        // Absteigend nach Länge sortieren, damit Unterverzeichnisse zuerst gelöscht werden.
        Collections.sort(verzeichnisListe, (a, b) -> {
            int la = a == null ? 0 : a.length();
            int lb = b == null ? 0 : b.length();
            return la == lb ? 0 : la < lb ? 1 : -1;
        });
        for (String kVerzeichnis : verzeichnisListe) {
            daten.add(new Sicherungsdaten("VL", kVerzeichnis, pfadPfad, sichPfad, sichBasisPfad, null));
        }
    }

    /**
     * Erstellt oder aktualisiert eine Sicherung eines Verzeichnisses.
     * @throws Exception im unerwarteten Fehlerfalle.
     */
    public void machSicherung() throws Exception {

        File vonFile = null;
        File nachFile = null;
        String aktion = null;
        int anzahl = 0;
        int zaehler = 0;
        int fehler = 0;

        if (daten == null || kopierFehler == null || status == null) {
            throw new Exception(Meldungen.M1041());
        }

        anzahl = daten.size();
        for (Sicherungsdaten sichdaten : daten) {
            zaehler++;
            // Status vor der Aktion setzen
            status.setLength(0);
            status.append(Meldungen.M1042(zaehler, anzahl, fehler, sichdaten.getName()));
            aktion = sichdaten.getAktion();
            try {
                if (!sichdaten.isErledigt()) {
                    if (diffSicherung) {
                        // Differenz-Sicherung
                        if (aktion.equals("VA")) {
                            // nachFile = getSichDatei(sichdaten);
                            // nachFile.mkdir();
                        } else if (aktion.equals("VL")) {
                            // nachFile = getSichDatei(sichdaten,
                            // diffSicherung);
                            // nachFile.delete();
                        } else if (aktion.equals("DK")) {
                            vonFile = getPfadDatei(sichdaten);
                            nachFile = getSichDateiDiff(sichdaten, neuPfad);
                            nachFile.getParentFile().mkdirs();
                            copyFile(vonFile, nachFile, vonFile.lastModified());
                        } else if (aktion.equals("DL")) {
                            vonFile = getSichDatei(sichdaten);
                            nachFile = getSichDateiDiff(sichdaten, geloeschtPfad);
                            nachFile.getParentFile().mkdirs();
                            copyFile(vonFile, nachFile, vonFile.lastModified());
                        }
                    } else if (!rueckSicherung) {
                        // Normalfall: Sicherung
                        if (aktion.equals("VA")) {
                            nachFile = getSichDatei(sichdaten);
                            nachFile.mkdir();
                        } else if (aktion.equals("VL")) {
                            // TODO Unterverzeichnisse zuerst löschen: sortieren und dann erst löschen
                            nachFile = getSichDatei(sichdaten);
                            nachFile.delete();
                        } else if (aktion.equals("DK")) {
                            vonFile = getPfadDatei(sichdaten);
                            nachFile = getSichDatei(sichdaten);
                            copyFile(vonFile, nachFile, vonFile.lastModified());
                        } else if (aktion.equals("DL")) {
                            nachFile = getSichDatei(sichdaten);
                            nachFile.delete();
                        }
                    } else {
                        // Rücksicherung
                        if (aktion.equals("VA")) {
                            nachFile = getPfadDatei(sichdaten);
                            nachFile.mkdir();
                        } else if (aktion.equals("VL")) {
                            nachFile = getPfadDatei(sichdaten);
                            nachFile.delete();
                        } else if (aktion.equals("DK")) {
                            vonFile = getDiffDatei(sichdaten);
                            nachFile = getPfadDatei(sichdaten);
                            copyFile(vonFile, nachFile, vonFile.lastModified());
                        } else if (aktion.equals("DL")) {
                            nachFile = getPfadDatei(sichdaten);
                            nachFile.delete();
                        }
                    }
                    sichdaten.setErledigt(true);
                }
            } catch (Exception ex) {
                if (aktion.equals("DK")) {
                    if (vonFile == null) {
                        kopierFehler.add(ex.getMessage());
                    } else {
                        kopierFehler.add(vonFile.getAbsolutePath());
                    }
                    fehler++;
                }
            }
            if (maxFehler > 0 && fehler > maxFehler) {
                break;
            }
            if (abbruch != null && abbruch.length() > 0) {
                break;
            }
        }
        status.setLength(0);
        if (maxFehler > 0 && fehler > maxFehler) {
            status.append(Meldungen.M1043());
        } else if (abbruch != null && abbruch.length() > 0) {
            status.append(Meldungen.M1044());
        } else {
            status.append(Meldungen.M1045(anzahl));
        }
    }

    private static File getPfadDatei(Sicherungsdaten sichdaten) {

        StringBuffer str = new StringBuffer();

        str.append(sichdaten.getPfadPfad()).append(sichdaten.getName());
        return new File(str.toString());
    }

    private static File getDiffDatei(Sicherungsdaten sichdaten) {

        StringBuffer str = new StringBuffer();

        if (sichdaten.getDiffPfad() == null) {
            str.append(sichdaten.getSichPfad()).append(sichdaten.getName());
        } else {
            str.append(sichdaten.getDiffPfad());
        }
        return new File(str.toString());
    }

    private static File getSichDatei(Sicherungsdaten sichdaten) {

        StringBuffer str = new StringBuffer();

        str.append(sichdaten.getSichPfad()).append(sichdaten.getName());
        return new File(str.toString());
    }

    private static File getSichDateiDiff(Sicherungsdaten sichdaten, String zusatz) {

        StringBuffer str = new StringBuffer();

        str.append(sichdaten.getSichBasisPfad());
        str.append(zusatz).append(File.separator);
        str.append(sichdaten.getSichPfad().substring(sichdaten.getSichBasisPfad().length()));
        str.append(sichdaten.getName());
        return new File(str.toString());
    }

    /**
     * Füllt die Hashtable mit Dateinamen und letztem Änderungszeitpunkt. Dabei werden rekursiv auch Unterverzeichnisse
     * berücksichtigt.
     * @param f Ausgangs-File.
     * @param pfad Pfad, der aus den Dateinamen abzuschneiden ist, sollte \ am Ende haben.
     * @param dateien Hashtable mit Dateinamen darf nicht null sein.
     * @param verzeichnisse ArrayList mit Verzeichnisnamen darf nicht null sein.
     * @param sichPfad Pfad zur Sicherung kann null sein.
     * @param loeschen Soll eine vorhandene Datei gelöscht werden?
     * @param diffZurueck Werden die Differenz-Dateien bei Rücksicherung bearbeitet?
     * @param diff Bearbeitung von Differenzen?
     * @throws Exception
     */
    private void fuelleDateilisteRekursiv(final File f, final String pfad,
            final Hashtable<String, Sicherungsdatei> dateien, final ArrayList<String> verzeichnisse,
            final String sichPfad, final boolean loeschen, final boolean diffZurueck, final boolean diff)
            throws Exception {

        File[] liste = null;
        String datei = null;
        long mod = 0;
        // long sichMod = 0;
        // File sichF = null;

        liste = f.listFiles();
        // Verzeichnis hinzufügen
        datei = umsetzenPfadDatei(f.getPath(), true);
        if (datei.startsWith(pfad)) {
            datei = datei.substring(pfad.length());
        }
        if (!Global.nes(datei)) {
            verzeichnisse.add(datei);
        }
        if (Global.arrayLaenge(liste) > 0) {
            for (int i = 0; i < liste.length; i++) {
                datei = umsetzenPfadDatei(liste[i].getPath(), false);
                if (datei.startsWith(pfad)) {
                    datei = datei.substring(pfad.length());
                }
                if (liste[i].isFile()) {
                    if (loeschen) {
                        if (dateien.containsKey(datei)) {
                            dateien.remove(datei);
                        }
                        continue;
                    }
                    mod = liste[i].lastModified();
                    if (sichPfad == null) {
                        // dateien.put(datei, new Sicherungsdatei(mod, null));
                        throw new Exception(Meldungen.M1035());
                    } else if (diff) {
                        // sichMod = 0;
                        // sichF = new File(sichPfad, datei);
                        // if (sichF.exists()) {
                        // if (!isModifiedEqual(sichF.lastModified(), mod)) {
                        // // Datei hat sich nicht verändert.
                        // sichMod = 1;
                        // }
                        // }
                        // if (sichMod == 0) {
                        if (diffZurueck) {
                            dateien.put(datei, new Sicherungsdatei(mod, umsetzenPfadDatei(liste[i].getPath(), false)));
                        } else {
                            dateien.put(datei, new Sicherungsdatei(mod, null));
                        }
                        // }
                    } else {
                        dateien.put(datei, new Sicherungsdatei(mod, null));
                    }
                } else {
                    // verzeichnisse.add(datei);
                    fuelleDateilisteRekursiv(liste[i], pfad, dateien, verzeichnisse, sichPfad, loeschen, diffZurueck,
                            diff);
                }
            }
        }
    }

    /**
     * Kopieren einer Datei.
     * @param in Zu kopierende Datei.
     * @param out Name der neuen Datei.
     * @param lastmodified Zeitpunkt der letzten Änderung wird gesetzt.
     * @throws Exception im unerwarteten Fehlerfalle.
     */
    public static void copyFile(final File in, final File out, final long lastmodified) throws Exception {

        FileInputStream ins = null;
        FileOutputStream outs = null;
        FileChannel sourceChannel = null;
        FileChannel destinationChannel = null;
        boolean fehler = false;
        // Exception exception = null;

        try {
            ins = new FileInputStream(in);
            sourceChannel = ins.getChannel();
            outs = new FileOutputStream(out);
            destinationChannel = outs.getChannel();
            sourceChannel.transferTo(0, sourceChannel.size(), destinationChannel);
            // or
            // destinationChannel.transferFrom(sourceChannel, 0,
            // sourceChannel.size());
        } catch (Exception ex) {
            // Global.machNichts();
            fehler = true;
            // exception = ex;
        } finally {
            if (sourceChannel != null) {
                sourceChannel.close();
            }
            if (ins != null) {
                ins.close();
            }
            if (destinationChannel != null) {
                destinationChannel.close();
            }
            if (outs != null) {
                outs.close();
            }
            if (fehler) {
                FileInputStream fin = null;
                FileOutputStream fout = null;

                try {
                    // Streams öffnen
                    fin = new FileInputStream(in);
                    fout = new FileOutputStream(out);

                    // eigentliches Kopieren blockweise
                    byte[] buffer = new byte[1000];
                    int nbytes;
                    for (;;) {
                        nbytes = fin.read(buffer);
                        if (nbytes == -1) {
                            break;
                        }
                        fout.write(buffer, 0, nbytes);
                    }
                    // } catch (IOException e) {
                    // System.err.println(e.toString());
                } finally {
                    // auf jeden Fall aufräumen
                    if (fin != null) {
                        try {
                            fin.close();
                        } catch (IOException e) {
                            Global.machNichts();
                        }
                    }
                    if (fout != null) {
                        try {
                            fout.close();
                        } catch (IOException e) {
                            Global.machNichts();
                        }
                    }
                }
            }
        }
        if (lastmodified != 0) {
            out.setLastModified(lastmodified);
        }
    }

    private boolean isModifiedEqual(long modified1, long modified2) {

        long m = modified1 - modified2;
        if (m < -diffZeit || m > diffZeit) {
            return false;
        }
        return true;
    }

    private class DiffFilenameFilter implements FilenameFilter {

        public boolean accept(File dir, String name) {
            return name.startsWith(DIFF_PFAD);
        };
    }

    private String umsetzenPfadDatei(String str, boolean sep) {

        if (str == null) {
            return null;
        }
        if (nurKleinbuchstaben) {
            str = str.toLowerCase();
        }
        if (sep) {
            while (str.endsWith("/") || str.endsWith("\\")) {
                // evtl. falschen Seperator entfernen
                str = str.substring(0, str.length() - 1);
            }
            if (!str.endsWith(File.separator)) {
                str += File.separator;
            }
        }
        return str;
    }

}

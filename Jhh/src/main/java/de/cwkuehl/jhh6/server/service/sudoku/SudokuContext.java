package de.cwkuehl.jhh6.server.service.sudoku;

import java.util.Stack;

import de.cwkuehl.jhh6.api.message.MeldungException;

public class SudokuContext {

    /** Feldgröße. */
    public static final int MAX      = 9;
    /** Wurzel der Feldgröße. */
    public static final int MAXW     = 3;
    /** Interne Liste der Sudoku-Zahlen. */
    public int[]            zahlen   = new int[MAX * MAX];
    /** Sind auf der Diagonalen alle Zahlen verschieden? (Schüssel-Variante) */
    private boolean         diagonal = false;

    public SudokuContext(int[] quelle, boolean diagonal) {

        copy(zahlen, quelle);
        this.diagonal = diagonal;
    }

    public static void copy(int[] ziel, int[] quelle) {

        if (ziel == null || quelle == null) {
            return;
        }
        int l = Math.min(ziel.length, quelle.length);
        for (int i = 0; i < l; i++) {
            ziel[i] = quelle[i];
        }
    }

    public int[] getClone() {
        return zahlen.clone();
    }

    /**
     * Bestimmung der Anzahl der belegten Felder.
     * @return Anzahl der belegten Felder.
     */
    public int getAnzahl() {

        int anzahl = 0;
        for (int i = 0; i < MAX * MAX; i++) {
            if (zahlen[i] > 0) {
                anzahl++;
            }
        }
        return anzahl;
    }

    public void leeren() {

        for (int i = 0; i < MAX * MAX; i++) {
            zahlen[i] = 0;
        }
    }

    /**
     * Sudoku-Spiel auf Widerspruch untersuchen.
     * @param c Kontext mit Daten zur Berechnung.
     * @param exception True, wenn Exception bei Widerspruch erfolgen soll.
     * @return Nummer des evtl. ersten widerspürchlichen Feldes.
     * @throws Exception falls Zahlen widersprüchlich sind.
     */
    public static final int sudokuTest(SudokuContext c, final boolean exception) {

        int feld = -1;

        try {
            // Zeilen, Spalten und Kästen bestimmen
            int[] zeilen = new int[MAX * MAX];
            int[] spalten = new int[MAX * MAX];
            int[] kaesten = new int[MAX * MAX];
            int[] diagonalen = new int[MAX * 2];
            for (int row = 0; row < MAX; row++) {
                for (int col = 0; col < MAX; col++) {
                    int wert = c.zahlen[row * MAX + col];
                    if (wert > 0) {
                        int knr = (row / MAXW) * MAXW + (col / MAXW);
                        if (zeilen[row * MAX + wert - 1] == 0) {
                            zeilen[row * MAX + wert - 1] = wert;
                        } else {
                            if (exception) {
                                throw new MeldungException("Widerspruch in Zeile " + (row + 1) + " mit Zahl " + wert
                                        + ".");
                            }
                            return row * MAX + col;
                        }
                        if (spalten[col * MAX + wert - 1] == 0) {
                            spalten[col * MAX + wert - 1] = wert;
                        } else {
                            if (exception) {
                                throw new MeldungException("Widerspruch in Spalte " + (col + 1) + " mit Zahl " + wert
                                        + ".");
                            }
                            return row * MAX + col;
                        }
                        if (kaesten[knr * MAX + wert - 1] == 0) {
                            kaesten[knr * MAX + wert - 1] = wert;
                        } else {
                            if (exception) {
                                throw new MeldungException("Widerspruch in Kasten " + (knr + 1) + " mit Zahl " + wert
                                        + ".");
                            }
                            return row * MAX + col;
                        }
                        if (c.diagonal) {
                            if (row == col) {
                                if (diagonalen[wert - 1] == 0) {
                                    diagonalen[wert - 1] = wert;
                                } else {
                                    if (exception) {
                                        throw new MeldungException("Widerspruch in Diagonale 1 Zeile " + (row + 1)
                                                + " mit Zahl " + wert + ".");
                                    }
                                    return row * MAX + col;
                                }
                            }
                            if (row == MAX - 1 - col) {
                                if (diagonalen[MAX + wert - 1] == 0) {
                                    diagonalen[MAX + wert - 1] = wert;
                                } else {
                                    if (exception) {
                                        throw new MeldungException("Widerspruch in Diagonale 2 Zeile " + (row + 1)
                                                + " mit Zahl " + wert + ".");
                                    }
                                    return row * MAX + col;
                                }
                            }
                        }
                    }
                }
            }
        } finally {
            if (feld == -1 && c.getAnzahl() >= MAX * MAX) {
                feld = -2; // vollständig gelöst
            }
        }
        return feld;
    }

    /**
     * Sudoku lösen versuchen.
     * @param c Kontext mit Daten zur Berechnung.
     * @param nur1Zug Soll nur 1 Zug berechnet werden?
     * @throws Exception falls Sudoku nicht vollständig oder nicht eindeutig lösbar.
     */
    public static void sudokuLoesen(SudokuContext c, boolean nur1Zug) {

        int anzahl = 1;
        int ergebnis = 0;
        boolean ende = false;
        int[] clone = null;
        int[] clone1 = null;
        int[] loesung = null;
        Stack<int[]> list = new Stack<int[]>();
        int[] feld = new int[1];
        int[] varianten = new int[MAX];

        sudokuTest(c, true);
        if (c.getAnzahl() >= MAX * MAX) {
            throw new MeldungException("Sudoku ist schon vollständig gelöst.");
        }
        if (nur1Zug) {
            clone1 = c.zahlen.clone();
        }
        do {
            anzahl = 0;
            do {
                anzahl++;
                ergebnis = sudokuEinzeln(c, anzahl, feld, varianten);
                // System.out.println("Anzahl: " + miAnzahl + " Variante: " +
                // varianten + " Ergebnis: " + ergebnis);
                if (ergebnis == -3) {
                    c.zahlen[feld[0]] = varianten[0];
                    // Andere Varianten merken.
                    for (int i = 1; i < anzahl; i++) {
                        clone = c.zahlen.clone();
                        clone[feld[0]] = varianten[i];
                        list.push(clone);
                    }
                    ergebnis = 0;
                } else if (ergebnis >= 0) {
                    if (sudokuTest(c, false) >= 0) {
                        // Andere Variante versuchen wegen Widerspruch.
                        if (list.empty()) {
                            if (loesung == null) {
                                throw new MeldungException("Sudoku nicht lösbar (fehlende Variante).");
                            }
                            ende = true;
                        } else {
                            SudokuContext.copy(c.zahlen, list.pop());
                        }
                    } else if (nur1Zug && list.empty()) {
                        ende = true;
                    }
                }
            } while (!ende && anzahl < MAX && (ergebnis == -1));
            if (c.getAnzahl() >= MAX * MAX) {
                if (loesung == null) {
                    loesung = c.zahlen.clone();
                    // Andere Variante versuchen.
                    if (!list.empty()) {
                        SudokuContext.copy(c.zahlen, list.pop());
                    }
                } else {
                    SudokuContext.copy(c.zahlen, loesung);
                    if (!list.empty()) {
                        throw new MeldungException("Sudoku lösbar, aber nicht eindeutig.");
                    }
                }
            }
        } while (!ende && ergebnis >= 0);
        if (loesung != null) {
            SudokuContext.copy(c.zahlen, loesung);
        }
        if (nur1Zug) {
            int i = 0;
            int[] clone2 = c.getClone();
            for (; i < clone1.length; i++) {
                if (clone1[i] != clone2[i]) {
                    clone1[i] = clone2[i];
                    break;
                }
            }
            if (i >= clone1.length) {
                throw new MeldungException("Keine Zahl mehr gefunden.");
            }
            SudokuContext.copy(c.zahlen, clone1);
        } else if (c.getAnzahl() < MAX * MAX) {
            throw new MeldungException("Sudoku nicht vollständig lösbar.");
        }
    }

    /**
     * Eine neue Zahl suchen.
     * @param c Kontext mit Daten zur Berechnung.
     * @param maxAnzahl Feld gesucht, dass höchstens diese Anzahl von Zahlen zulässt.
     * @param feldv Feld, das eine Variante hat.
     * @return Nummer des evtl. geänderten Feldes.
     * @throws Exception falls Zahlen widersprüchlich sind.
     */
    private static final int sudokuEinzeln(SudokuContext c, final int maxAnzahl, final int[] feldv,
            final int[] varianten) {

        int feld = -1;

        try {
            // Zeilen, Spalten und Kästen bestimmen
            int[] zeilen = new int[MAX * MAX];
            int[] spalten = new int[MAX * MAX];
            int[] kaesten = new int[MAX * MAX];
            int[] diagonalen = new int[MAX * 2];
            for (int row = 0; row < MAX; row++) {
                for (int col = 0; col < MAX; col++) {
                    int wert = c.zahlen[row * MAX + col];
                    if (wert > 0) {
                        int knr = (row / MAXW) * MAXW + (col / MAXW);
                        zeilen[row * MAX + wert - 1] = wert;
                        spalten[col * MAX + wert - 1] = wert;
                        kaesten[knr * MAX + wert - 1] = wert;
                        if (row == col) {
                            // 1. Diagonale
                            diagonalen[wert - 1] = wert;
                        }
                        if (row == MAX - 1 - col) {
                            // 2. Diagonale
                            diagonalen[MAX + wert - 1] = wert;
                        }
                    }
                }
            }
            // neue Zahl bestimmen, wenn nur noch eine fehlt
            for (int row = 0; row < MAX; row++) {
                for (int col = 0; col < MAX; col++) {
                    int wert = c.zahlen[row * MAX + col];
                    // leeres Feld untersuchen
                    if (wert == 0) {
                        int knr = (row / MAXW) * MAXW + (col / MAXW);
                        int versuchz = 0;
                        int versuchs = 0;
                        int versuchk = 0;
                        int versuch1 = 0;
                        int versuch2 = 0;
                        int anzahlz = 0;
                        int anzahls = 0;
                        int anzahlk = 0;
                        int anzahl1 = 0;
                        int anzahl2 = 0;
                        int[] varianten1 = new int[MAX];
                        int[] varianten2 = new int[MAX];
                        int[] variantenZ = new int[MAX];
                        int[] variantenS = new int[MAX];
                        int[] variantenK = new int[MAX];
                        for (int i = 0; i < MAX; i++) {
                            varianten[i] = 0;
                        }
                        for (int i = 0; i < MAX; i++) {
                            if (zeilen[row * MAX + i] == 0) {
                                versuchz = i + 1;
                                anzahlz++;
                                variantenZ[i] = 1;
                            }
                            if (spalten[col * MAX + i] == 0) {
                                versuchs = i + 1;
                                anzahls++;
                                variantenS[i] = 1;
                            }
                            if (kaesten[knr * MAX + i] == 0) {
                                versuchk = i + 1;
                                anzahlk++;
                                variantenK[i] = 1;
                            }
                            if (c.diagonal) {
                                if (row == col) {
                                    // 1. Diagonale
                                    if (diagonalen[i] == 0) {
                                        versuch1 = i + 1;
                                        anzahl1++;
                                        varianten1[i] = 1;
                                    }
                                }
                                if (row == MAX - 1 - col) {
                                    // 2. Diagonale
                                    if (diagonalen[MAX + i] == 0) {
                                        versuch2 = i + 1;
                                        anzahl2++;
                                        varianten2[i] = 1;
                                    }
                                }
                            }
                        }
                        // Genau eine Zahl passt in der Zeile.
                        if (anzahlz == 1) {
                            if (anzahls < 1 || anzahlk < 1) {
                                throw new MeldungException("Widerspruch Zeile in (" + (row + 1) + "," + (col + 1) + ")");
                            }
                            c.zahlen[row * MAX + col] = versuchz;
                            feld = row * MAX + col;
                            return feld;
                        }
                        // Genau eine Zahl passt in der Spalte.
                        if (anzahls == 1) {
                            if (anzahlz < 1 || anzahlk < 1) {
                                throw new MeldungException("Widerspruch Spalte in (" + (row + 1) + "," + (col + 1)
                                        + ")");
                            }
                            c.zahlen[row * MAX + col] = versuchs;
                            feld = row * MAX + col;
                            return feld;
                        }
                        // Genau eine Zahl passt im Kasten.
                        if (anzahlk == 1) {
                            if (anzahlz < 1 || anzahls < 1) {
                                throw new MeldungException("Widerspruch Kasten in (" + (row + 1) + "," + (col + 1)
                                        + ")");
                            }
                            c.zahlen[row * MAX + col] = versuchk;
                            feld = row * MAX + col;
                            return feld;
                        }
                        // Genau eine Zahl passt in Diagonale 1.
                        if (anzahl1 == 1) {
                            c.zahlen[row * MAX + col] = versuch1;
                            feld = row * MAX + col;
                            return feld;
                        }
                        // Genau eine Zahl passt in Diagonale 2.
                        if (anzahl2 == 1) {
                            c.zahlen[row * MAX + col] = versuch2;
                            feld = row * MAX + col;
                            return feld;
                        }
                        int anzahlv = 0; // Anzahl Varianten.
                        for (int i = 0; i < MAX; i++) {
                            if (variantenZ[i] > 0 && variantenS[i] > 0 && variantenK[i] > 0) {
                                varianten[anzahlv] = i + 1;
                                anzahlv++;
                            }
                        }
                        if (anzahlv == 1) {
                            c.zahlen[row * MAX + col] = varianten[0];
                            feld = row * MAX + col;
                            return feld;
                        } else if (anzahlv <= maxAnzahl) {
                            feldv[0] = row * MAX + col;
                            if (varianten[0] == 0) {
                                return -1;
                            }
                            return -3; // Lösen mit Varianten
                        }
                    }
                }
            }
            // neue Zahl für einen Kasten bestimmen
            // mit Ausschluss über Zeilen und Spalten
            int[] anzahl = new int[MAX];
            int[] pos = new int[MAX];
            for (int krow = 0; krow < MAXW; krow++) {
                for (int kcol = 0; kcol < MAXW; kcol++) {
                    // Untersuchung eines Kastens
                    for (int i = 0; i < MAX; i++) {
                        anzahl[i] = 0;
                        pos[i] = -1;
                        if (kaesten[(krow * MAXW + kcol) * MAX + i] > 0) {
                            // Zahl ist erledigt.
                            anzahl[i] = -1;
                        }
                    }
                    int knr = krow * MAXW + kcol;
                    for (int irow = 0; irow < MAXW; irow++) {
                        for (int icol = 0; icol < MAXW; icol++) {
                            int row = krow * MAXW + irow;
                            int col = kcol * MAXW + icol;
                            int wert = c.zahlen[row * MAX + col];
                            if (wert == 0) {
                                for (int i = 0; i < MAX; i++) {
                                    if (anzahl[i] >= 0 && zeilen[row * MAX + i] == 0 && spalten[col * MAX + i] == 0
                                            && kaesten[knr * MAX + i] == 0) {
                                        anzahl[i]++;
                                        pos[i] = row * MAX + col;
                                    }
                                }
                            }
                        }
                    }
                    for (int i = 0; i < MAX; i++) {
                        if (anzahl[i] == 1) {
                            feld = pos[i];
                            c.zahlen[feld] = i + 1;
                            return feld;
                        }
                    }
                }
            }
        } finally {
            if (feld == -1 && c.getAnzahl() >= MAX * MAX) {
                feld = -2; // vollständig gelöst
            }
        }
        return feld;
    }
}

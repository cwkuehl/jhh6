package de.cwkuehl.jhh6.api.rollback;

import java.util.ArrayList;
import java.util.List;

import de.cwkuehl.jhh6.api.dto.base.DtoBase;

public class RollbackListe {

    private List<RollbackEintrag> liste        = null;
    private boolean               rollbackRedo = false;

    // private LocalDateTime jetzt = null;
    // private boolean keineReplikation = false;

    /**
     * Standard-Konstruktor.
     */
    public RollbackListe(/* Date jetzt */) {

        liste = new ArrayList<RollbackEintrag>();
        // this.setJetzt(jetzt);
    }

    public void addInsert(DtoBase e) {
        liste.add(0, new RollbackEintrag(RollbackArtEnum.INSERT, e));
    }

    public void addUpdate(DtoBase e) {
        liste.add(0, new RollbackEintrag(RollbackArtEnum.UPDATE, e));
    }

    public void addDelete(DtoBase e) {
        liste.add(0, new RollbackEintrag(RollbackArtEnum.DELETE, e));
    }

    public List<RollbackEintrag> getListe() {
        return liste;
    }

    // public void addAll(RollbackListe rbListe) {
    //
    // if (rbListe != null) {
    // liste.addAll(rbListe.getListe());
    // }
    // }
    //
    // public static void addAll(RollbackListe ziel, RollbackListe quelle) {
    //
    // if (ziel != null) {
    // ziel.addAll(quelle);
    // }
    // }

    public boolean isRollbackRedo() {
        return rollbackRedo;
    }

    public void setRollbackRedo(boolean rollbackRedo) {
        this.rollbackRedo = rollbackRedo;
    }

    // public void setJetzt(LocalDateTime jetzt) {
    // this.jetzt = jetzt;
    // }
    //
    // public LocalDateTime getJetzt() {
    // return jetzt;
    // }
    //
    // public void setKeineReplikation(boolean keineReplikation) {
    // this.keineReplikation = keineReplikation;
    // }
    //
    // public boolean isKeineReplikation() {
    // return keineReplikation;
    // }

}

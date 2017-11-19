package de.cwkuehl.jhh6.api.rollback;

import de.cwkuehl.jhh6.api.dto.base.DtoBase;

public class RollbackEintrag {

    private RollbackArtEnum art = null;
    
    private DtoBase eintrag = null;
    
    /**
     * Standard-Konstruktor mit Initialisierung.
     * @param a Rollback-Art.
     * @param e DtoBase-Instanz.
     */
    public RollbackEintrag(RollbackArtEnum a, DtoBase e) {
        art = a;
        eintrag = e;
    }

    public DtoBase getEintrag() {
        return eintrag;
    }

    public RollbackArtEnum getArt() {
        return art;
    }

}

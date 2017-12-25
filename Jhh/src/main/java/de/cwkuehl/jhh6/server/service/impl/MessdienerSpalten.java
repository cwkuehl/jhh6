package de.cwkuehl.jhh6.server.service.impl;

public enum MessdienerSpalten {

    NAME("Name", true), VORNAME("Vorname", true), TELEFON("Telefon", false), SEIT("seit", false), BIS("bis", false), MANUELL(
            "manuell", false), NAME2("Mit-Name", true), VORNAME2("Mit-Vorname", true), EMAIL("Email", false), EMAIL2(
            "Email2", false), DI18("Di 18:00", false), DO18("Do 18:00", false), FR18("Fr 18:00", false), SA18(
            "Sa 18:00", false), SO08("So 08:00", false), SO10("So 10:00", false);

    public final String  name;
    public final boolean muss;

    private MessdienerSpalten(String name, boolean muss) {
        this.name = name;
        this.muss = muss;
    }

    public static MessdienerSpalten fromString(String text) {

        if (text != null) {
            text = text.trim();
            for (MessdienerSpalten b : MessdienerSpalten.values()) {
                if (text.equalsIgnoreCase(b.name)) {
                    return b;
                }
            }
        }
        return null;
    }
}

package de.cwkuehl.jhh6.server.service.impl

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class ReplTabelle {

	new(String name, String mandantnr, String pk, boolean loeschen, boolean kopieren) {

		this.name = name
		this.mandantnr = mandantnr
		this.pk = pk
		this.loeschen = loeschen
		this.kopieren = kopieren
	}

	private String name
	private String mandantnr
	private String pk
	private boolean loeschen
	private boolean kopieren
}
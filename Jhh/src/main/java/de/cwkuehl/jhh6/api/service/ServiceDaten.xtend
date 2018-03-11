package de.cwkuehl.jhh6.api.service

import de.cwkuehl.jhh6.api.rollback.RollbackListe
import java.time.LocalDate
import java.time.LocalDateTime
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(#[PRIVATE_SETTER, PUBLIC_GETTER])
class ServiceDaten {

	public new(int mandantNr, String benutzerId) {

		this.mandantNr = mandantNr
		this.benutzerId = benutzerId
		jetzt = LocalDateTime::now
		heute = LocalDate::now
		rbListe = new RollbackListe
	}

	@Accessors
	private int mandantNr

	private String benutzerId

	@Accessors
	private RollbackListe rbListe

	private LocalDateTime jetzt

	private LocalDate heute

	@Accessors
	private Object context

	@Accessors
	private Object contextRep
}

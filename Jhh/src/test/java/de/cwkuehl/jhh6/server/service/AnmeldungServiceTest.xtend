package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.server.FactoryService
import org.junit.Test

import static extension org.junit.Assert.*

class AnmeldungServiceTest {

	val service = FactoryService.anmeldungService
	
	@Test def void testService() {

		val daten = new ServiceDaten(1, "Heinz")
		val r = service.istOhneAnmelden(daten)
		assertNotNull(r)
		service.abmelden(daten)
		"1".assertEquals("1")
	}
}

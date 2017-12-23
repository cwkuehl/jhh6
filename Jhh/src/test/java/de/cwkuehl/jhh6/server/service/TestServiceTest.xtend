package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.server.FactoryService
import org.junit.Test

import static extension org.junit.Assert.*

class TestServiceTest {

	val service = FactoryService.testService
	private int mandantNr = 2;
	private String benutzerId = "Heinz";

	def private void assertOk(ServiceErgebnis<Boolean> r, boolean b) {

		r.assertNotNull
		r.ok.assertTrue
		r.ergebnis.assertEquals(b)
	}

	@Test def void testService() {

		val daten = new ServiceDaten(mandantNr, benutzerId)
		val m = service.mandantTest(daten, null)
		m.assertNotNull
	}

	@Test def void testRep() {

		val daten = new ServiceDaten(mandantNr, benutzerId)
		val r = service.testRep(daten)
		assertOk(r, true)
		Thread.sleep(2000)
	}

	@Test def void testTransaktion() {

		val daten = new ServiceDaten(mandantNr, benutzerId)
		var r = service.testTransaktion(daten, 0)
		assertOk(r, true)
		r = service.testTransaktion(daten, 1)
		r.assertNotNull
		r = service.testTransaktion(daten, 2)
		assertOk(r, true)
	}
}

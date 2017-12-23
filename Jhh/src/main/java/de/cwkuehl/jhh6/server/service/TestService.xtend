package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.AdAdresse
import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.dto.MaMandantKey
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.rollback.RollbackListe
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.rep.IAdAdresseRep
import de.cwkuehl.jhh6.server.rep.IFzBuchstatusRep
import de.cwkuehl.jhh6.server.rep.impl.AdAdresseRep
import de.cwkuehl.jhh6.server.rep.impl.FzBuchstatusRep
import de.cwkuehl.jhh6.server.rep.impl.MaMandantRep

// import static org.junit.Assert.*
@Service
class TestService {

	@RepositoryRef MaMandantRep mandantRep
	@RepositoryRef AdAdresseRep adresseRep
	@RepositoryRef FzBuchstatusRep statusRep

	override ServiceErgebnis<MaMandant> mandantTest(ServiceDaten daten, String test) {

		var key = new MaMandantKey
		key.nr = daten.mandantNr
		var m = mandantRep.get(daten, key)
		val r = new ServiceErgebnis<MaMandant>(m)
		return r
	}

	override Void initDatenbank(ServiceDaten daten, String test) {}

	override Void getFunktion(ServiceDaten daten, String test) {}

	override Void holeFunktion(ServiceDaten daten, String test) {}

	override RollbackListe andereFunktion(ServiceDaten daten, String test) { null }

	override String getErgebnis(ServiceDaten daten, String test) {}

	override Void rollback(ServiceDaten daten, RollbackListe liste, int anzahl) {}

	@Transaction(true)
	override ServiceErgebnis<Boolean> testRep(ServiceDaten daten) {

		log.error("testRep")
		testAdresseRep(daten, adresseRep)
		testBuchstatusRep(daten, statusRep)
		val r = new ServiceErgebnis<Boolean>(true)
		return r
	}

	def private void assertTrue(boolean b) {
		if (!b)
			throw new RuntimeException("assertTrue == false")
	}

	def private void assertEquals(int expected, int actual) {
		if (expected != actual)
			throw new RuntimeException('''assertEquals: expected «expected» != actual «actual»''')
	}

	def private void testAdresseRep(ServiceDaten daten, IAdAdresseRep rep) {

		val mandantNr = daten.mandantNr
		var liste = rep.getListe(daten, mandantNr, null, null)
		liste.forEach[rep.delete(daten, it)]
		var dto = rep.iuAdAdresse(daten, null, null, "D", "PLZ", "Ort", "Straße", "10", null, null, null, null)
		dto = rep.iuAdAdresse(daten, null, dto.uid, "D2", "PLZ2", "Ort2", "Straße2", "102", null, null, null, null)
		liste = rep.getListe(daten, mandantNr, null, null)
		var anz = liste.size
		assertTrue(anz > 0)
		rep.delete(daten, dto)
		liste = rep.getListe(daten, mandantNr, null, null)
		assertEquals(anz - 1, liste.size)
	}

	def private void testBuchstatusRep(ServiceDaten daten, IFzBuchstatusRep rep) {

		val mandantNr = daten.mandantNr
		var liste = rep.getListe(daten, mandantNr, null, null)
		liste.forEach[rep.delete(daten, it)]
		var dto = rep.iuFzBuchstatus(daten, null, Global.UID, true, daten.heute, daten.heute, null, null, null, null)
		dto = rep.iuFzBuchstatus(daten, null, dto.buchUid, false, null, null, null, null, null, null)
		liste = rep.getListe(daten, mandantNr, null, null)
		var anz = liste.size
		assertTrue(anz > 0)
		rep.delete(daten, dto)
		liste = rep.getListe(daten, mandantNr, null, null)
		assertEquals(anz - 1, liste.size)
	}

	@Transaction(true)
	override ServiceErgebnis<Boolean> testTransaktion(ServiceDaten daten, int stufe) {

		if (stufe == 0) {
			// alles löschen
			var liste = adresseRep.getListe(daten, daten.mandantNr, null, null)
			liste.forEach[adresseRep.delete(daten, it)]
		} else if (stufe == 1 || stufe == 2) {
			var a = new AdAdresse
			a.mandantNr = daten.mandantNr
			a.uid = "1"
			a.ort = "xxx"
			a.angelegtAm = daten.jetzt
			a.angelegtVon = daten.benutzerId
			adresseRep.insert(daten, a)
			if (stufe == 1) {
				throw new MeldungException("Hallo")
			}
		// var dto = adresseRep.iuAdAdresse(daten, null, "1", "D", "PLZ", "Ort", "Straße", "10", null, null, null,
		// null)
		}
		val r = new ServiceErgebnis<Boolean>(true)
		return r
	}
}

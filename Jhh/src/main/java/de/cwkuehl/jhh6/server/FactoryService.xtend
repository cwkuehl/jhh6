package de.cwkuehl.jhh6.server

import de.cwkuehl.jhh6.api.service.IAdresseService
import de.cwkuehl.jhh6.api.service.IAnmeldungService
import de.cwkuehl.jhh6.api.service.IFreizeitService
import de.cwkuehl.jhh6.api.service.IHaushaltService
import de.cwkuehl.jhh6.api.service.IHeilpraktikerService
import de.cwkuehl.jhh6.api.service.IMessdienerService
import de.cwkuehl.jhh6.api.service.IReplikationService
import de.cwkuehl.jhh6.api.service.IStammbaumService
import de.cwkuehl.jhh6.api.service.ITagebuchService
import de.cwkuehl.jhh6.api.service.ITestService
import de.cwkuehl.jhh6.api.service.IVermietungService
import de.cwkuehl.jhh6.server.base.WkInjector

class FactoryService {

	// Guice-Like-Injector
	val static injector = WkInjector.createInjector(new ServiceInjector())

	def static IAdresseService getAdresseService() {
		return injector.getInstance(typeof(IAdresseService))
	}

	def static IAnmeldungService getAnmeldungService() {
		return injector.getInstance(typeof(IAnmeldungService))
	}

	def static IFreizeitService getFreizeitService() {
		return injector.getInstance(typeof(IFreizeitService))
	}

	def static IHaushaltService getHaushaltService() {
		return injector.getInstance(typeof(IHaushaltService))
	}

	def static IHeilpraktikerService getHeilpraktikerService() {
		return injector.getInstance(typeof(IHeilpraktikerService))
	}

	def static IMessdienerService getMessdienerService() {
		return injector.getInstance(typeof(IMessdienerService))
	}

	def static IReplikationService getReplikationService() {
		return injector.getInstance(typeof(IReplikationService))
	}

	def static IStammbaumService getStammbaumService() {
		return injector.getInstance(typeof(IStammbaumService))
	}

	def static ITagebuchService getTagebuchService() {
		return injector.getInstance(typeof(ITagebuchService))
	}

	def static ITestService getTestService() {
		return injector.getInstance(typeof(ITestService))
	}

	def static IVermietungService getVermietungService() {
		return injector.getInstance(typeof(IVermietungService))
	}

// def static IWertpapierService getWertpapierService() {
// return injector.getInstance(typeof(IWertpapierService))
// }
}

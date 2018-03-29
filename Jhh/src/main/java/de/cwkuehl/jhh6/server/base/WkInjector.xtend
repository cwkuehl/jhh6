package de.cwkuehl.jhh6.server.base

import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.generator.annotation.Inject
import java.util.Hashtable

class WkInjector {

	private AbstractModule injector
	private var instances = new Hashtable<Class<?>, Object>

	private new(AbstractModule injector) {
		this.injector = injector
	}

	def static WkInjector createInjector(AbstractModule injector) {

		injector.configure
		val i = new WkInjector(injector)

		// alles instanziieren
		injector.bindings.forEach [ p1, p2 |
			val obj = p2.implClass.newInstance
			i.instances.put(p1, obj)
		]
		
		// Referenzen setzen
		i.instances.forEach [ p1, p2 |
			p2.class.methods.forEach [
				if (name.startsWith("set") && parameters.length == 1 && annotations.exists [
					it.annotationType == typeof(Inject)
				]) {
					val clazz = parameters.get(0).type
					val obj = i.instances.get(clazz)
					invoke(p2, obj)
				}
			]
		]
		return i
	}

	def public <T> T getInstance(Class<T> clazz) {

		if (clazz === null) {
			return null
		}
		var obj = instances.get(clazz)
		if (obj === null) {
			throw new RuntimeException(Meldungen.M1057(clazz.name))
		}
		return clazz.cast(obj)
	}

}

class AbstractModule {

	private var bindings = new Hashtable<Class<?>, BindingBuilder<?>>

	def protected void configure() {
		// Überschreiben
	}

	def protected <T> BindingBuilder<T> bind(Class<T> clazz) {

		val bb = new BindingBuilder<T>(clazz)
		bindings.put(clazz, bb)
		return bb
	}

	def getBindings() {
		return bindings
	}
}

class BindingBuilder<T> {

	private Class<T> interfaceClass
	private Class<? extends T> implClass

	new(Class<T> clazz) {
		interfaceClass = clazz
	}

	def void to(Class<? extends T> clazz) {
		implClass = clazz
	}

	def public getImplClass() {
		return implClass
	}
}

package de.cwkuehl.jhh6.api.service

import de.cwkuehl.jhh6.api.message.Meldung
import de.cwkuehl.jhh6.api.message.MeldungException
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors

class ServiceErgebnis<T> {

	public new() {
	}

	public new(T e) {
		ergebnis = e
	}

	@Accessors(#[PUBLIC_GETTER, PUBLIC_SETTER])
	var private T ergebnis

	@Accessors(PUBLIC_GETTER)
	var fehler = new ArrayList<Meldung>

	def boolean ok() { fehler.length <= 0 }

	def public <S> boolean get(ServiceErgebnis<S> r) {

		if (r === null) {
			return false
		}
		fehler.addAll(r.fehler)
		return ok
	}
	
	def void throwErstenFehler() {
		
		if (fehler.length > 0) {
			throw new MeldungException(fehler.get(0))
		}
	}
}

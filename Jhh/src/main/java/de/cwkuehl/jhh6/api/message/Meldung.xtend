package de.cwkuehl.jhh6.api.message

import org.eclipse.xtend.lib.annotations.Accessors

class Meldung {
	
	@Accessors(PUBLIC_GETTER)
	private String meldung
	
	public new(String md) {
		meldung = md
	}
	
	def public static Meldung Neu(String md) {
		return new Meldung(md)
	} 
}
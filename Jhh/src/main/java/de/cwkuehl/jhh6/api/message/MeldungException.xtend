package de.cwkuehl.jhh6.api.message

class MeldungException extends RuntimeException {

	public new(Meldung md) {
		super(md.meldung)
	}

	public new(String md) {
		super(md)
	}
}
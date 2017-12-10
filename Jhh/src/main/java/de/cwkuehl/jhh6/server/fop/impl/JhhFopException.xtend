package de.cwkuehl.jhh6.server.fop.impl

/** 
 * Fop-Exception für JHH.
 */
class JhhFopException extends RuntimeException {

	/** 
	 * Standard-Version.
	 */
	// static final long serialVersionUID = 1L
	/** 
	 * Konstruktor.
	 * @param message Exception-Message.
	 */
	new(String message) {
		super(message)
	}

	/** 
	 * Konstruktor.
	 * @param t Throwable.
	 */
	new(Throwable t) {
		super(t)
	}
}

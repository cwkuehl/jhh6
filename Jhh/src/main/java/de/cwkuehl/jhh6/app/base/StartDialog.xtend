package de.cwkuehl.jhh6.app.base

import org.eclipse.xtend.lib.annotations.Accessors

/** Klasse für einen Start-Dialog. */
@Accessors
class StartDialog {

	new(String i, String t, Class<?> c, String p) {

		id = i
		titel = t
		clazz = c
		parameter = p
	}

	/** Dialog-ID. */
	String id = null

	/** Dialog-Titel. */
	String titel = null

	/** Controller-Class. */
	Class<?> clazz = null

	/** Start-Parameter. */
	String parameter = null
}

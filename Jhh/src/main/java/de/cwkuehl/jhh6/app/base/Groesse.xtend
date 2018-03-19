package de.cwkuehl.jhh6.app.base

import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Klasse zur Weitergabe von Fenstergrößen.
 */
@Accessors
public class Groesse {

	/** Breite. */
	double width = 0
	/** Höhe. */
	double height = 0
	/** x-Position. */
	double x = 0
	/** y-Position. */
	double y = 0

	def boolean leer() {
		return width == 0 && height == 0 && x == 0 && y == 0
	}
}

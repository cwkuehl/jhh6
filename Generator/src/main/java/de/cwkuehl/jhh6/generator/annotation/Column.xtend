package de.cwkuehl.jhh6.generator.annotation

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/** 
 * Diese Annotation markiert Tabellenspalten.
 * <p>
 * Erstellt am 24.11.2017.
 */
@Retention(RetentionPolicy.RUNTIME) @Target(#[ElementType.FIELD]) public annotation Column {
	String name = ""
	boolean nullable = true
	int length = 255
}

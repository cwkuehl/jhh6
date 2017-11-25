package de.cwkuehl.jhh6.generator.annotation

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/** 
 * Diese Annotation markiert Datenbank-Tabellen.
 * <p>
 * Erstellt am 24.11.2017.
 */
@Retention(RetentionPolicy.RUNTIME) @Target(#[ElementType.TYPE]) public annotation Table {
	String name = ""
}

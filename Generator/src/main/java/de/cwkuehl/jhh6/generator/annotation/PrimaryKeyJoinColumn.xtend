package de.cwkuehl.jhh6.generator.annotation

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/** 
 * Diese Annotation markiert Primary Key-Tabellenspalten.
 * <p>
 * Erstellt am 24.11.2017.
 */
@Retention(RetentionPolicy.RUNTIME) @Target(#[ElementType.FIELD]) annotation PrimaryKeyJoinColumn {
	String name = ""
	String referencedColumnName = ""
}

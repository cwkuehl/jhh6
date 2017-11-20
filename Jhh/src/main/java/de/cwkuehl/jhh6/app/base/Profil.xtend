package de.cwkuehl.jhh6.app.base

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/** 
 * Elemente, die mit dieser Annotation versehen sind, werden im Profil gespeichert.
 * <p>
 * Erstellt am 18.02.2007.
 */
@Retention(RetentionPolicy.RUNTIME) @Target(#[ElementType.FIELD, ElementType.METHOD]) public annotation Profil {
	String defaultValue = ""
}

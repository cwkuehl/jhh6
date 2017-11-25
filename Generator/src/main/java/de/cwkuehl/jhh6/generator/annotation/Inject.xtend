package de.cwkuehl.jhh6.generator.annotation

import java.lang.annotation.Documented
import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(#[METHOD, CONSTRUCTOR, FIELD])
@Retention(RUNTIME)
@Documented
annotation Inject {
}

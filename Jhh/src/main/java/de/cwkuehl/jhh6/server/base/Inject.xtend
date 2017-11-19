package de.cwkuehl.jhh6.server.base

import java.lang.annotation.Documented
import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(#[METHOD, CONSTRUCTOR, FIELD])
@Retention(RUNTIME)
@Documented
annotation Inject {
}

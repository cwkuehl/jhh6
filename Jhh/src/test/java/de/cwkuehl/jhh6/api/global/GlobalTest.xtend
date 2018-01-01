package de.cwkuehl.jhh6.api.global

import java.time.LocalDateTime
import org.junit.Test

import static org.junit.Assert.*

class GlobalTest {

	@Test def void strdat() {

		var d = Global.strdat("2017-12-31 23:51:16")
		assertNotNull(d)
		assertEquals(LocalDateTime.of(2017, 12, 31, 23, 51, 16).toString, d.toString)
		d = Global.strdat("2017-12-31")
		assertNotNull(d)
		assertEquals(LocalDateTime.of(2017, 12, 31, 0, 0, 0).toString, d.toString)
	}
}

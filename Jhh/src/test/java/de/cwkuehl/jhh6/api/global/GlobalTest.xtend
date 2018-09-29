package de.cwkuehl.jhh6.api.global

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.Locale
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

	@Test def void objDat2() {

		var d = Global.objDat2("31.12.17")
		assertNotNull(d)
		assertEquals(LocalDate.of(17, 12, 31).toString, d.toString)
		d = Global.objDat2("31.12.2017")
		assertNotNull(d)
		assertEquals(LocalDate.of(2017, 12, 31).toString, d.toString)
	}

	@Test def void strint() {

		assertEquals(6200, Global.strInt("6.200,00", Locale.GERMAN))
		assertEquals(6, Global.strInt("6.200,00", Locale.ENGLISH))
		assertEquals(6, Global.strInt("6,200.00", Locale.GERMAN))
		assertEquals(6200, Global.strInt("6,200.00", Locale.ENGLISH))
	}

	@Test def void strlng() {

		assertEquals(6200l, Global.strLng("6.200,00", Locale.GERMAN))
		assertEquals(6l, Global.strLng("6.200,00", Locale.ENGLISH))
		assertEquals(6l, Global.strLng("6,200.00", Locale.GERMAN))
		assertEquals(6200l, Global.strLng("6,200.00", Locale.ENGLISH))
	}

	@Test def void strdbl() {

		val d = 0.005
		assertEquals(6200.0, Global.strDbl("6.200,00", Locale.GERMAN), d)
		assertEquals(6.2, Global.strDbl("6.200,00", Locale.ENGLISH), d)
		assertEquals(6.2, Global.strDbl("6,200.00", Locale.GERMAN), d)
		assertEquals(6200.0, Global.strDbl("6,200.00", Locale.ENGLISH), d)
	}
}

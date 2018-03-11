package de.cwkuehl.jhh6.api.message

import java.time.LocalDateTime
import java.util.Locale
import org.junit.Test

import static extension org.junit.Assert.*

class MeldungenTest {

	@Test def void m1011_de() {

		Meldungen::clearCache(Locale.GERMAN);
		var x = Meldungen::M1011(LocalDateTime.of(2015, 5, 23, 18, 40, 27), "Hallo");
		"23.05.2015 18:40:27 von Hallo".assertEquals(x)
		Meldungen::M1011(null, null).assertNotEquals("")
		Meldungen::M1011(null, "xxx").assertNotEquals("")
	// Meldungen::M1011(null, "xxx").assertEquals("x")
	}

	@Test def void m1011_en() {

		Meldungen::clearCache(Locale.ENGLISH)
		var x = Meldungen::M1011(LocalDateTime.of(2015, 5, 23, 18, 40, 27), "Hallo");
		"2015-05-23 18:40:27 of Hallo".assertEquals(x)
		Meldungen::M1011(null, null).assertNotEquals("")
		Meldungen::M1011(null, "xxx").assertNotEquals("")
	}
}

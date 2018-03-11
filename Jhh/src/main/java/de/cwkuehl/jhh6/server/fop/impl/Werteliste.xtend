package de.cwkuehl.jhh6.server.fop.impl

import java.util.HashMap

class Werteliste {

	static HashMap<String, String> map = new HashMap<String, String>

	def static String getKeyValue(String wertelistenName, String key) {

		var schluessel = key
		if (wertelistenName !== null) {
			schluessel = wertelistenName + key
		}
		if (map.containsKey(schluessel)) {
			return map.get(schluessel)
		}
		return null
	}
}

package de.cwkuehl.jhh6

class TestBase {
	
	def protected boolean skipForBuild() {
		return (System.getProperty("skipForBuild") !== null)
	}
}
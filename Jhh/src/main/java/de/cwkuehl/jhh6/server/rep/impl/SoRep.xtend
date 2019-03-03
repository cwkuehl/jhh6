package de.cwkuehl.jhh6.server.rep.impl

import de.cwkuehl.jhh6.generator.Repository
import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Table
import java.time.LocalDateTime

@Repository
@Table(name="SO")
class SoRep {

	/**  
	*/
	static class Vo {
	}

	/** 
	 */
	static class VoKurse {

		@Column(name="Id", nullable=true)
		public LocalDateTime datum

		@Column(name="0", nullable=true)
		public double open

		@Column(name="0", nullable=true)
		public double high

		@Column(name="0", nullable=true)
		public double low

		@Column(name="0", nullable=true)
		public double close

		@Column(name="0", nullable=true)
		public double preis

		@Column(name="Bewertung", nullable=true)
		public String bewertung

		@Column(name="Trend", nullable=true)
		public String trend

		@Column(name="Bemerkung", nullable=true)
		public String bemerkung
	}
}

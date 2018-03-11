package de.cwkuehl.jhh6.server.base

import de.cwkuehl.jhh6.api.dto.base.DtoBase
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceDaten
import java.math.BigDecimal
import java.sql.Blob
import java.sql.Connection
import java.sql.Date
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.Timestamp
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import java.util.function.Function
import org.slf4j.LoggerFactory

class RepositoryBase {

	val protected log = LoggerFactory.getLogger(typeof(RepositoryBase));

	def protected DbContext getDb(ServiceDaten d) {

		if (d === null) {
			return null
		}
		var DbContext ctx
		if (d.context !== null && d.context instanceof DbContext) {
			ctx = d.context as DbContext
		} else {
			ctx = new DbContext
		}
		return ctx
	}

	def public static int conv(Integer i) {

		if (i === null) {
			return 0
		}
		return i.intValue
	}

	def public static byte[] conv(byte[] b) {
		return b
	}

	def public static byte[] conv(Blob b) {

		if (b === null) {
			return null
		}
		return b.getBytes(1, b.length as int)
	}

	def public static LocalDate conv(Date ts) {

		if (ts === null) {
			return null
		}
		return ts.toLocalDate
	}

	def public static LocalDateTime conv(Timestamp ts) {

		if (ts === null) {
			return null
		}
		return ts.toLocalDateTime
	}

	/** LocalDateTime nach Timestamp ohne Nanos konvertieren. */
	def public static Timestamp conv(LocalDateTime d) {

		if (d === null) {
			return null
		}
		var t = Timestamp.valueOf(d)
		t.nanos = 0
		return t
	}

	def public static Date conv(LocalDate d) {

		if (d === null) {
			return null
		}
		return Date.valueOf(d)
	}

	def public static BigDecimal conv(Double d) {

		if (d === null) {
			return new BigDecimal(0)
		}
		return new BigDecimal(d)
	}

	def public static double conv(BigDecimal d) {

		if (d === null) {
			return 0
		}
		return d.doubleValue
	}

	/** Konvertieren von DTO-Typen nach SQL-Typen. */
	def public static Object convSql(Object v) {

		var w = v
		if (v !== null) {
			if (v instanceof LocalDate) {
				w = RepositoryBase.conv(v)
			} else if (v instanceof LocalDateTime) {
				w = RepositoryBase.conv(v)
			}
		}
		return w
	}

	/** Konvertieren von SQL-Typen nach DTO-Typen. */
	def public static Object convDto(Object v) {

		var w = v
		if (v !== null) {
			if (v instanceof Timestamp) {
				w = RepositoryBase.conv(v)
			} else if (v instanceof Date) {
				w = RepositoryBase.conv(v)
			}
		}
		return w
	}

	/** Lesen eines Datensatzes. */		
	def protected Object selectOne(ServiceDaten daten, SqlBuilder sql) {
		return selectOne(daten.db.con, sql)
	}

	/** Lesen eines Datensatzes. */		
	def protected Object selectOne(Connection con, SqlBuilder sql) {

		var PreparedStatement stmt = null
		var ResultSet rs = null
		var Object t = null
		try {
			log.info('''selectOne: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				stmt.setObject(i, p.value)
				i++
			}
			stmt.maxRows = 1
			rs = stmt.executeQuery
			if (rs.next()) {
				t = rs.getObject(1)
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
			if (rs !== null) {
				rs.close
			}
		}
		return t
	}

	def protected <K extends DtoBase, T extends K> T selectOne(ServiceDaten daten, SqlBuilder sql,
		Function<ResultSet, T> inst, Class<T> c) {

		val con = daten.db.con
		var PreparedStatement stmt
		var ResultSet rs
		var T t = null
		try {
			log.info('''selectOne: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				stmt.setObject(i, p.value)
				i++
			}
			stmt.maxRows = 1
			rs = stmt.executeQuery
			if (rs.next() && inst !== null) {
				t = inst.apply(rs)
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
			if (rs !== null) {
				rs.close
			}
		}
		return t
	}

	def protected <K extends DtoBase, T extends K> List<T> selectList(ServiceDaten daten, SqlBuilder sql,
		Function<ResultSet, T> inst, Class<T> c) {

		val con = daten.db.con
		var PreparedStatement stmt
		var ResultSet rs
		var list = new ArrayList<T>
		var T t = null

		if (inst === null) {
			return list
		}
		try {
			log.info('''selectList: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				// System.out.println(i)
				stmt.setObject(i, p.value)
				i++
			}
			rs = stmt.executeQuery
			var anz = sql.max
			while (rs.next() && (anz == 0 || list.size < anz)) {
				t = inst.apply(rs)
				list.add(t)
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
			if (rs !== null) {
				rs.close
			}
		}
		return list
	}

	def protected int insert(ServiceDaten daten, DtoBase e, SqlBuilder sql) {

		val con = daten.db.con
		var PreparedStatement stmt
		var rs = 0
		try {
			log.info('''insert: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				stmt.setObject(i, p.value)
				i++
			}
			rs = stmt.executeUpdate
			if (rs != 1) {
				throw new RuntimeException("Falsche Anzahl bei Insert.")
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
		}
		if (!daten.rbListe.rollbackRedo) {
			daten.rbListe.addInsert(e.clone)
		}
		return rs
	}

	def protected int update(ServiceDaten daten, DtoBase e, SqlBuilder sql) {

		val con = daten.db.con
		var PreparedStatement stmt
		var rs = 0
		try {
			log.info('''update: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				stmt.setObject(i, p.value)
				i++
			}
			rs = stmt.executeUpdate
			if (rs != 1) {
				throw new RuntimeException("Falsche Anzahl bei Update.")
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
		}
		if (!daten.rbListe.rollbackRedo) {
			daten.rbListe.addUpdate(e.clone)
		}
		return rs
	}

	def protected int delete(ServiceDaten daten, DtoBase e, SqlBuilder sql) {

		val con = daten.db.con
		var PreparedStatement stmt
		var rs = 0
		try {
			log.info('''delete: «sql.toString»''')
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : sql.params) {
				stmt.setObject(i, p.value)
				i++
			}
			rs = stmt.executeUpdate
			if (rs != 1) {
				throw new RuntimeException("Falsche Anzahl bei Delete.")
			}
		} finally {
			if (stmt !== null) {
				stmt.close
			}
		}
		if (!daten.rbListe.rollbackRedo) {
			daten.rbListe.addDelete(e.clone)
		}
		return rs
	}

	def protected boolean nes(String str) {
		return str === null || str.length <= 0
	}

	def protected String getUid() {
		return Global.UID
	}
}

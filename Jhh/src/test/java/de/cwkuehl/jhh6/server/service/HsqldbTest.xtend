package de.cwkuehl.jhh6.server.service

import java.sql.Connection
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.SQLException
import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.function.Function
import org.junit.Test

import static extension org.junit.Assert.*
import de.cwkuehl.jhh6.TestBase

class HsqldbTest extends TestBase {

	@Test def void testHsqldb234() {

		if (skipForBuild) {
			return
		}

		// using hsqldb-2.3.4: OK
		// using hsqldb-2.3.5:
		// java.lang.RuntimeException: java.sql.SQLFeatureNotSupportedException: feature not supported
		// using hsqldb-2.4.0:
		// java.lang.RuntimeException: java.sql.SQLSyntaxErrorException: incompatible data type in conversion
		try {
			Class.forName("org.hsqldb.jdbc.JDBCDriver")
		} catch (Exception e) {
			System.err.println("ERROR: failed to load HSQLDB JDBC driver.")
			e.printStackTrace
			return
		}

		var con = DriverManager.getConnection("jdbc:hsqldb:mem:jhh6", "SA", "");
		var sql = '''
			CREATE CACHED TABLE IF NOT EXISTS zEinstellung (
			  Schluessel varchar(50) COLLATE SQL_TEXT_UCC NOT NULL,
			  Wert varchar(255) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Angelegt_Von varchar(20) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Angelegt_Am datetime DEFAULT NULL,
			  Geaendert_Von varchar(20) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Geaendert_Am datetime DEFAULT NULL,
			  PRIMARY KEY (Schluessel)
			);
		'''
		execute(con, sql)
		sql = '''
			INSERT INTO zEinstellung(Schluessel, Wert, Angelegt_Von, Angelegt_Am, Geaendert_Von, Geaendert_Am)
			  VALUES (?, ?, ?, ?, ?, ?)
		'''
		val params = #["Schluessel234", "Wert", "Von", conv(LocalDateTime::now), null, null]
		insert(con, sql, params)
		sql = '''
			SELECT a.Schluessel, a.Wert, a.Angelegt_Von, a.Angelegt_Am, a.Geaendert_Von, a.Geaendert_Am
			  FROM zEinstellung a
		'''
		selectOne(con, sql, null, readDto234)
		"1".assertEquals("1")
	}

	@Test def void testHsqldb240() {

		// using hsqldb-2.3.4: OK
		// using hsqldb-2.3.5:
		// java.lang.RuntimeException: java.sql.SQLFeatureNotSupportedException: feature not supported
		// using hsqldb-2.4.0: OK
		try {
			Class.forName("org.hsqldb.jdbc.JDBCDriver")
		} catch (Exception e) {
			System.err.println("ERROR: failed to load HSQLDB JDBC driver.")
			e.printStackTrace
			return
		}

		var con = DriverManager.getConnection("jdbc:hsqldb:mem:jhh6", "SA", "");
		var sql = '''
			CREATE CACHED TABLE IF NOT EXISTS zEinstellung (
			  Schluessel varchar(50) COLLATE SQL_TEXT_UCC NOT NULL,
			  Wert varchar(255) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Angelegt_Von varchar(20) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Angelegt_Am datetime DEFAULT NULL,
			  Geaendert_Von varchar(20) COLLATE SQL_TEXT_UCC DEFAULT NULL,
			  Geaendert_Am datetime DEFAULT NULL,
			  PRIMARY KEY (Schluessel)
			);
		'''
		execute(con, sql)
		sql = '''
			INSERT INTO zEinstellung(Schluessel, Wert, Angelegt_Von, Angelegt_Am, Geaendert_Von, Geaendert_Am)
			  VALUES (?, ?, ?, ?, ?, ?)
		'''
		val params = #["Schluessel240", "Wert", "Von", conv(LocalDateTime::now), null, null]
		insert(con, sql, params)
		sql = '''
			SELECT a.Schluessel, a.Wert, a.Angelegt_Von, a.Angelegt_Am, a.Geaendert_Von, a.Geaendert_Am
			  FROM zEinstellung a
		'''
		selectOne(con, sql, null, readDto240)
		"1".assertEquals("1")
	}

	static class Zeinstellung {
		String schluessel
		String wert
		String angelegtVon
		LocalDateTime angelegtAm
		String geaendertVon
		LocalDateTime geaendertAm
	}

	val protected Function<ResultSet, Zeinstellung> readDto234 = [ rs |
		{
			var d = new Zeinstellung
			try {
				d.schluessel = rs.getObject(1, typeof(String))
				d.wert = rs.getObject(2, typeof(String))
				d.angelegtVon = rs.getObject(3, typeof(String))
				d.angelegtAm = conv(rs.getObject(4, typeof(Timestamp)))
				d.geaendertVon = rs.getObject(5, typeof(String))
				d.geaendertAm = conv(rs.getObject(6, typeof(Timestamp)))
			} catch (SQLException ex) {
				throw new RuntimeException(ex)
			}
			return d
		}
	]
	val protected Function<ResultSet, Zeinstellung> readDto240 = [ rs |
		{
			var d = new Zeinstellung
			try {
				d.schluessel = rs.getString(1)
				d.wert = rs.getString(2)
				d.angelegtVon = rs.getString(3)
				d.angelegtAm = conv(rs.getObject(4, typeof(Timestamp)))
				d.geaendertVon = rs.getString(5)
				d.geaendertAm = conv(rs.getObject(6, typeof(Timestamp)))
			} catch (SQLException ex) {
				throw new RuntimeException(ex)
			}
			return d
		}
	]

	def public static LocalDateTime conv(Timestamp ts) {

		if (ts === null) {
			return null
		}
		return ts.toLocalDateTime
	}

	def public static Timestamp conv(LocalDateTime d) {

		if (d === null) {
			return null
		}
		var t = Timestamp.valueOf(d)
		t.nanos = 0
		return t
	}

	def public int execute(Connection con, String s) {

		if (s === null || s == "") {
			return 0
		}
		var PreparedStatement stmt
		var rs = 0
		try {
			stmt = con.prepareStatement(s)
			rs = stmt.executeUpdate
		} finally {
			if (stmt !== null) {
				stmt.close
			}
		}
		return rs
	}

	def protected int insert(Connection con, String sql, Object[] params) {

		var PreparedStatement stmt
		var rs = 0
		try {
			stmt = con.prepareStatement(sql.toString)
			var i = 1
			for (p : params) {
				stmt.setObject(i, p)
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
		return rs
	}

	def protected Zeinstellung selectOne(Connection con, String sql, Object[] params,
		Function<ResultSet, Zeinstellung> inst) {

		var PreparedStatement stmt
		var ResultSet rs
		var Zeinstellung t
		try {
			stmt = con.prepareStatement(sql.toString)
			if (params !== null) {
				var i = 1
				for (p : params) {
					stmt.setObject(i, p)
					i++
				}
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

}

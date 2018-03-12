package de.cwkuehl.jhh6.server.base

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.server.service.impl.ReplTabelle
import java.math.BigDecimal
import java.sql.Blob
import java.sql.Connection
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.util.Arrays
import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class RemoteDb extends RepositoryBase {

	private int mandantNr
	private Connection con

	new(int mandantNr, Connection con) {
		this.mandantNr = mandantNr
		this.con = con
	}

	def public Object selectOne(SqlBuilder sql) {
		return selectOne(con, sql)
	}

	def public String getEinstellungWert(String schluessel) {

		var sql = new SqlBuilder("SELECT Wert FROM zEinstellung")
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, "Schluessel", "=", schluessel, null)
		var o = selectOne(sql)
		return if(o === null) null else o.toString
	}

	def public String getMandantEinstellungWert(String schluessel) {

		var sql = new SqlBuilder("SELECT Wert FROM MA_Einstellung")
		sql.praefix(" WHERE ", " AND ")
		sql.append(null, "Mandant_Nr", "=", mandantNr, null)
		sql.append(null, "Schluessel", "=", schluessel, null)
		var o = selectOne(sql)
		return if(o === null) null else o.toString
	}

	def public int vergleicheMandantTabelle(RemoteDb rdb, ReplTabelle t, StringBuffer status) {

		if (Global.nes(t.mandantnr)) {
			return 0
		}
		var msql = new SqlBuilder("SELECT * FROM ")
		msql.append(t.name)
		msql.append(" WHERE ", t.mandantnr, "=", mandantNr, null)
		if (!Global.nes(t.pk)) {
			msql.append(" ORDER BY ").append(t.pk)
		}

		var PreparedStatement mstmt
		var ResultSet mr
		var PreparedStatement rstmt
		var ResultSet rr
		try {
			mstmt = con.prepareStatement(msql.toString)
			var j = 1
			for (p : msql.params) {
				mstmt.setObject(j, p.value)
				j++
			}
			mr = mstmt.executeQuery
			val l = mr.metaData.columnCount
			var mandantspalte = -1
			var rsql = new SqlBuilder("SELECT ")
			for (i : 1 .. l) {
				if (i > 1) {
					rsql.append(", ")
				}
				if (mr.metaData.getColumnName(i).toLowerCase.equals(t.mandantnr.toLowerCase)) {
					mandantspalte = i
				}
				rsql.append(mr.metaData.getColumnName(i))
			}
			rsql.append(" FROM ").append(t.name)
			rsql.append(" WHERE ", t.mandantnr, "=", rdb.mandantNr, null)
			if (!Global.nes(t.pk)) {
				rsql.append(" ORDER BY ").append(t.pk)
			}

			rstmt = rdb.con.prepareStatement(rsql.toString)
			j = 1
			for (p : rsql.params) {
				rstmt.setObject(j, p.value)
				j++
			}
			rr = rstmt.executeQuery
			var anzahl = 0
			while (mr.next) {
				if (anzahl % 100 == 0) {
					status.length = 0
					status.append(anzahl).append(" Datensätze aus Tabelle ").append(t.name).append(" verglichen")
				}
				anzahl++
				// if (anzahl == 237) {
				// anzahl = 237
				// }
				if (!rr.next) {
					throw new MeldungException('''Tabelle «t.name» auf dem Server hat weniger Datensätze (1)''')
				}
				for (i : 1 .. l) {
					var mObj = mr.getObject(i)
					var rObj = rr.getObject(i)
					// if (anzahl <= 10000) {
					// if (i == 8) {
					// System.out.println("Jet " + mObj + "  My " + rObj)
					// }
					// } else
					if (i != mandantspalte &&
						!vergleicheWerte(
							mObj,
							rObj
						)
					) {
						// System.out.println("Jet " + mObj + "  My " + rObj)
						throw new MeldungException('''Tabelle «t.name» hat unterschiedliche Werte (2) Satz-Nr. «anzahl» Spalte «i»''')
					}
				}
			}
			if (rr.next) {
				throw new MeldungException('''Tabelle «t.name» auf dem Client hat weniger Datensätze (3)''')
			}
			return anzahl
		} finally {
			if (mstmt !== null) {
				mstmt.close
			}
			if (mr !== null) {
				mr.close
			}
			if (rstmt !== null) {
				rstmt.close
			}
			if (rr !== null) {
				rr.close
			}
		}
	}

	def public int kopiereMandantTabelle(RemoteDb rdb, ReplTabelle t, StringBuffer status) {

		if (!t.loeschen || Global.nes(t.mandantnr)) {
			return 0
		}
		var PreparedStatement mstmt
		var ResultSet mr
		var PreparedStatement rstmt
		try {
			var rsql = new SqlBuilder("DELETE FROM ")
			rsql.append(t.name)
			rsql.append(" WHERE ", t.mandantnr, "=", rdb.mandantNr, null)
			rstmt = rdb.con.prepareStatement(rsql.toString)
			var j = 1
			for (p : rsql.params) {
				rstmt.setObject(j, p.value)
				j++
			}
			rstmt.execute
			rstmt.close
			if (!t.kopieren) {
				return 0
			}
			var max = 0
			var msql = new SqlBuilder("SELECT COUNT(*) FROM ")
			msql.append(t.name)
			msql.append(" WHERE ", t.mandantnr, "=", mandantNr, null)
			mstmt = con.prepareStatement(msql.toString)
			j = 1
			for (p : msql.params) {
				mstmt.setObject(j, p.value)
				j++
			}
			mr = mstmt.executeQuery
			if (mr.next) {
				max = mr.getInt(1)
			}
			mr.close
			mstmt.close

			msql = new SqlBuilder("SELECT * FROM ")
			msql.append(t.name)
			msql.append(" WHERE ", t.mandantnr, "=", mandantNr, null)
			if (!Global.nes(t.pk)) {
				msql.append(" ORDER BY ").append(t.pk)
			}
			mstmt = con.prepareStatement(msql.toString)
			j = 1
			for (p : msql.params) {
				mstmt.setObject(j, p.value)
				j++
			}
			mr = mstmt.executeQuery
			val l = mr.metaData.columnCount
			var mandantspalte = -1
			rsql = new SqlBuilder("INSERT INTO ")
			rsql.append(t.name).append(" (")
			for (i : 1 .. l) {
				if (i > 1) {
					rsql.append(", ")
				}
				if (mr.metaData.getColumnName(i).toLowerCase.equals(t.mandantnr.toLowerCase)) {
					mandantspalte = i
				}
				rsql.append(mr.metaData.getColumnName(i))
			}
			rsql.append(") VALUES (")
			for (i : 1 .. l) {
				if (i > 1) {
					rsql.append(", ")
				}
				rsql.append("?")
			}
			rsql.append(")")
			rstmt = rdb.con.prepareStatement(rsql.toString)
			var anzahl = 0
			while (mr.next) {
				if (anzahl % 100 == 0) {
					status.length = 0
					status.append(anzahl).append(" von ").append(max).append(" Datensätze aus Tabelle ").append(t.name).
						append(" kopiert")
					rstmt.executeBatch
				}
				for (i : 1 .. l) {
					rstmt.setObject(i, if(i == mandantspalte) rdb.mandantNr else mr.getObject(i))
				}
				rstmt.addBatch
				anzahl++
			}
			rstmt.executeBatch
			return anzahl
		} finally {
			if (mstmt !== null) {
				mstmt.close
			}
			if (mr !== null) {
				mr.close
			}
			if (rstmt !== null) {
				rstmt.close
			}
		}
	}

	/**
	 * Vergleich von beliebigen Werten.
	 * @param alt bestehender Wert.
	 * @param neu neuer Wert.
	 * @return True, wenn Werte gleich sind.
	 */
	def public static boolean vergleicheWerte(Object alt, Object neu) {

		var gleich = false
		var objAlt = alt
		if (objAlt === null) {
			if (neu === null) {
				gleich = true
			} else {
				objAlt = new Object
			}
		} else if (neu !== null) {
			if (objAlt.toString.equals(neu.toString)) {
				gleich = true
			} else if (objAlt instanceof Date && neu instanceof Date) {
				if ((objAlt as Date).time == (neu as Date).time) {
					gleich = true
				}
			} else if (objAlt instanceof BigDecimal && neu instanceof Double) {
				if (Global.compDouble4((objAlt as BigDecimal).doubleValue, (neu as Double).doubleValue) == 0) {
					gleich = true
				}
			} else if (objAlt instanceof Double && neu instanceof BigDecimal) {
				if (Global.compDouble4((objAlt as Double).doubleValue, (neu as BigDecimal).doubleValue) == 0) {
					gleich = true
				}
			} else if ((objAlt instanceof Blob || objAlt instanceof byte[]) &&
				(neu instanceof Blob || neu instanceof byte[])) {
				var b1 = if(objAlt instanceof Blob) objAlt else null
				var b2 = if(neu instanceof Blob) neu else null
				var a1 = if(objAlt instanceof byte[]) objAlt else b1.getBytes(1, b1.length as int)
				var a2 = if(neu instanceof byte[]) neu else b2.getBytes(1, b2.length as int)
				gleich = Arrays.equals(a1, a2)
			} else {
				gleich = false
			}
		}
		return gleich
	}

	def public int abgleichenMandantTabelle(RemoteDb rdb, ReplTabelle t, StringBuffer status) {

		if (Global.nes(t.mandantnr) || Global.nes(t.pk)) {
			return 0
		}
		var msql = new SqlBuilder("SELECT * FROM ")
		msql.append(t.name)
		msql.append(" WHERE ", t.mandantnr, "=", mandantNr, null)
		if (!Global.nes(t.pk)) {
			msql.append(" ORDER BY ").append(t.pk)
		}
		var pka = t.pk.split(', *')
		var pk1 = -1
		var pk2 = -1
		var pk3 = -1
		var pk4 = -1
		if (pka.length > 4) {
			throw new MeldungException('''Primärschlüssel der Tabelle «t.name» zu lang.''')
		}
		var del = false
		var ins = false
		var PreparedStatement mstmt
		var ResultSet mr
		var PreparedStatement rstmt
		var ResultSet rr
		var PreparedStatement insert
		var PreparedStatement delete
		try {
			mstmt = con.prepareStatement(msql.toString)
			var j = 1
			for (p : msql.params) {
				mstmt.setObject(j, p.value)
				j++
			}
			mr = mstmt.executeQuery
			val l = mr.metaData.columnCount
			var mandantspalte = -1
			var rsql = new SqlBuilder("SELECT ")
			for (i : 1 .. l) {
				if (i > 1) {
					rsql.append(", ")
				}
				rsql.append(mr.metaData.getColumnName(i))
				if (pka.length > 0 && mr.metaData.getColumnName(i).toLowerCase.equals(pka.get(0).toLowerCase)) {
					pk1 = i
				}
				if (pka.length > 1 && mr.metaData.getColumnName(i).toLowerCase.equals(pka.get(1).toLowerCase)) {
					pk2 = i
				}
				if (pka.length > 2 && mr.metaData.getColumnName(i).toLowerCase.equals(pka.get(2).toLowerCase)) {
					pk3 = i
				}
				if (pka.length > 3 && mr.metaData.getColumnName(i).toLowerCase.equals(pka.get(3).toLowerCase)) {
					pk4 = i
				}
				if (mr.metaData.getColumnName(i).toLowerCase.equals(t.mandantnr.toLowerCase)) {
					mandantspalte = i
				}
			}
			rsql.append(" FROM ").append(t.name)
			for (i : 1 .. l) {
				if (i == pk1) {
					rsql.append(" WHERE ").append(pka.get(0)).append("=?")
				} else if (i == pk2) {
					rsql.append(" AND ").append(pka.get(1)).append("=?")
				} else if (i == pk3) {
					rsql.append(" AND ").append(pka.get(2)).append("=?")
				} else if (i == pk4) {
					rsql.append(" AND ").append(pka.get(3)).append("=?")
				}
			}
			rstmt = rdb.con.prepareStatement(rsql.toString)
			var anzahl = 0
			while (mr.next) {
				if (anzahl % 100 == 0) {
					status.length = 0
					status.append(anzahl).append(" Datensätze aus Tabelle ").append(t.name).append(" abgeglichen")
				}
				anzahl++
				j = 1
				for (i : 1 .. l) {
					if (i == pk1 || i == pk2 || i == pk3 || i == pk4) {
						rstmt.setObject(j, mr.getObject(i))
						j++
					}
				}
				rstmt.maxRows = 1
				rr = rstmt.executeQuery
				del = false
				ins = false
				if (rr.next) {
					for (i : 1 .. l) {
						var mObj = mr.getObject(i)
						var rObj = rr.getObject(i)
						if (i != mandantspalte && !vergleicheWerte(
							mObj,
							rObj
						)) {
							// throw new MeldungException('''Tabelle «t.name» hat unterschiedliche Werte (2) Satz-Nr. «anzahl» Spalte «i»''')
							del = true
							ins = true
						}
					}
				} else {
					ins = true
				}
				if (del) {
					if (delete === null) {
						rsql = new SqlBuilder("DELETE FROM ")
						rsql.append(t.name)
						for (i : 1 .. l) {
							if (i == pk1) {
								rsql.append(" WHERE ").append(pka.get(0)).append("=?")
							} else if (i == pk2) {
								rsql.append(" AND ").append(pka.get(1)).append("=?")
							} else if (i == pk3) {
								rsql.append(" AND ").append(pka.get(2)).append("=?")
							} else if (i == pk4) {
								rsql.append(" AND ").append(pka.get(3)).append("=?")
							}
						}
						delete = rdb.con.prepareStatement(rsql.toString)
					}
					j = 1
					for (i : 1 .. l) {
						if (i == pk1 || i == pk2 || i == pk3 || i == pk4) {
							delete.setObject(j, mr.getObject(i))
							j++
						}
					}
					delete.execute
				}
				if (ins) {
					// throw new MeldungException('''Tabelle «t.name» fehlt Datensatz «anzahl»''')
					if (insert === null) {
						rsql = new SqlBuilder("INSERT INTO ")
						rsql.append(t.name).append(" (")
						for (i : 1 .. l) {
							if (i > 1) {
								rsql.append(", ")
							}
							rsql.append(mr.metaData.getColumnName(i))
						}
						rsql.append(") VALUES (")
						for (i : 1 .. l) {
							if (i > 1) {
								rsql.append(", ")
							}
							rsql.append("?")
						}
						rsql.append(")")
						insert = rdb.con.prepareStatement(rsql.toString)
					}
					// var sb = new StringBuffer
					for (i : 1 .. l) {
						var o = mr.getObject(i)
						// sb.append(if (sb.length > 0) ", " else "")
						// sb.append(if (o == null) "null" else o.toString)
						insert.setObject(i, if(i == mandantspalte) rdb.mandantNr else o)
					}
					// System.out.println('''Insert: «sb.toString»''')
					insert.execute
				}
			}
			return anzahl
		} finally {
			if (mstmt !== null) {
				mstmt.close
			}
			if (mr !== null) {
				mr.close
			}
			if (rstmt !== null) {
				rstmt.close
			}
			if (rr !== null) {
				rr.close
			}
			if (insert !== null) {
				insert.close
			}
			if (delete !== null) {
				delete.close
			}
		}
	}
}

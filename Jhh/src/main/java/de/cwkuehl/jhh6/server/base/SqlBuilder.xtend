package de.cwkuehl.jhh6.server.base

import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors

class SqlBuilder {

	/** SQL-Befehl zum Zusammensetzen. */
	private val sql = new StringBuffer

	/** 1. Präfix. */
	private var String praefix1 = null

	/** Folgendes Präfix. */
	private var String praefix2 = null

	/** Ist Präfix 1 dran? */
	private var praefixEins = true

	/** Maximale Anzahl von Datensätzen. */
	@Accessors var int max = 0

	/** Liste von SQL-Parametern. */
	@Accessors(PUBLIC_GETTER) private val params = new ArrayList<SqlParameter>

	/** Standard-Konstruktor. */
	new() {
	}

	/** Konstruktor mit ersten String-Bestandteil. */
	new(String s) {
		append(s)
	}

	/**
	 * Anhängen eines Strings.
	 */
	def public SqlBuilder append(String s) {

		if (s !== null && s.length > 0) {
			appendPraefix
			sql.append(s)
		}
		return this
	}

	/**
	 * Anhängen eines Strings mit Parameter.
	 */
	def public SqlBuilder append(String s, Class<?> c, Object p) {

		appendPraefix
		sql.append(s)
		params.add(new SqlParameter(c, p))
		return this
	}

	/** Setzen zweier Präfixe für die folgenden Append-Befehle. */
	def public void praefix(String p1, String p2) {

		praefix1 = p1
		praefix2 = p2
		if (p2 === null) {
			praefix2 = p1
		}
		praefixEins = true
	}

	/**
	 * Anhängen eines Strings mit Where-Bedingung.
	 * @param pf0 Präfix.
	 * @param s String.
	 * @param pf1 Postfix.
	 */
	def public SqlBuilder append(String pf0, String s, String pf1, boolean ignorePraefix) {

		if (!ignorePraefix) {
			appendPraefix
		}
		if (pf0 !== null) {
			sql.append(pf0)
		}
		if (s !== null) {
			sql.append(s)
		}
		if (pf1 !== null) {
			sql.append(pf1)
		}
		return this
	}

	/**
	 * Anhängen eines Strings mit Where-Bedingung.
	 * @param pf0 Präfix.
	 * @param spalte Spaltenname.
	 */
	def public SqlBuilder append(String pf0, String spalte, String op, Object v, String pf1, boolean ignorePraefix) {

		if (!ignorePraefix) {
			appendPraefix
		}
		if (pf0 !== null) {
			sql.append(pf0)
		}
		// Leerzeichen wegen like
		sql.append(spalte).append(' ').append(op).append(' ').append('?')
		var w = RepositoryBase.convSql(v)
		params.add(new SqlParameter(null, w))
		if (pf1 !== null) {
			sql.append(pf1)
		}
		return this
	}

	/**
	 * Anhängen eines Strings mit Where-Bedingung.
	 * @param pf0 Präfix.
	 * @param spalte Spaltenname.
	 */
	def public SqlBuilder append(String pf0, String spalte, String op, Object v, String pf1) {
		return append(pf0, spalte, op, v, pf1, false)
	}

	/**
	 * Anhängen eines SqlBuilder.
	 */
	def public SqlBuilder append(SqlBuilder s) {

		if (s !== null && s.sql.length > 0) {
			if (s.max > 0) {
				max = s.max
			}
			appendPraefix
			sql.append(s.toString)
			params.addAll(s.params)
		}
		return this
	}

	override public String toString() {
		return sql.toString
	}

	def public int length() {
		return sql.length
	}

	def private void appendPraefix() {

		if (praefix1 !== null || praefix2 !== null) {
			if (praefixEins) {
				if (praefix1 !== null) {
					sql.append(praefix1)
				}
				praefixEins = false
			} else if (praefix2 !== null) {
				sql.append(praefix2)
			}
		}
	}
}

class SqlParameter {

	private Class<?> type
	@Accessors(PUBLIC_GETTER) private Object value

	public new(Class<?> type, Object value) {
		this.type = type
		this.value = value
	}
}

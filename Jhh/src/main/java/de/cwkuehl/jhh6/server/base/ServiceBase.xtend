package de.cwkuehl.jhh6.server.base

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import de.cwkuehl.jhh6.api.dto.base.DtoBase
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldung
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.rollback.RollbackListe
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.server.db.DatenbankArt
import de.cwkuehl.jhh6.server.fop.impl.JhhFop
import de.cwkuehl.jhh6.server.fop.impl.JhhFopDokumentImpl
import java.io.File
import java.lang.reflect.Method
import java.util.ArrayList
import java.util.Hashtable
import java.util.List
import java.util.Properties
import java.util.Stack
import javax.sql.DataSource
import org.apache.avalon.framework.configuration.DefaultConfigurationBuilder
import org.apache.fop.apps.FopFactoryBuilder
import org.slf4j.LoggerFactory

class ServiceBase {

	val protected static log = LoggerFactory.getLogger(typeof(ServiceBase))

	/** primäre Datenquelle. */
	private static DataSource ds
	/** Datenquelle für Replikation. */
	private static DataSource dsRep
	/** Rollback-Stack. */
	val protected static rbStack = new Stack<RollbackListe>
	/** Redo-Stack. */
	val protected static redoStack = new Stack<RollbackListe>
	/** Mapping zwischen DTOs und Repository. */
	val protected static reps = new Hashtable<Class<?>, RbRepository>
	/** Instanz zur Dokument-Erzeugung. */
	private static JhhFop jhhFop
	/** Datenbankart. */
	private DatenbankArt dbart = DatenbankArt.KEINE

	/** Liefert eine Remote-Datenbank. */
	def protected RemoteDb getRemoteDb(int mandantNr, boolean rep) {

		val ds = if(rep) dataSourceRep else dataSource
		var db = new RemoteDb(mandantNr, ds.connection)
		return db
	}

	def protected void init(ServiceDaten d, boolean transaction) {

		if (d === null) {
			return
		}
		d.getDb(transaction)
	}

	def protected void exit(ServiceDaten d, boolean commit) {

		val db = if(d === null) null else d.db
		if (db === null) {
			return
		}
		if (db.tiefe == 0) {
			try {
				d.context = null
				if (db.transaction) {
					if (commit) {
						// System.out.println("commit")
						db.con.commit
						if (d.rbListe.liste.length > 0) {
							rbStack.add(d.rbListe)
						}
					} else {
						// System.out.println("rollback")
						db.con.rollback
					}
				}
			} finally {
				db.con.close
			}
		} else {
			db.tiefe = db.tiefe - 1
		}
	}

	def protected void handleException(ServiceDaten d, Throwable ex, ServiceErgebnis<?> r) {

		val db = if(d === null) null else d.db
		if (db === null || db.tiefe == 0) {
			if (r !== null) {
				r.fehler.add(new Meldung(Global.getExceptionText(ex)))
			}
			if (ex !== null && !(ex instanceof MeldungException)) {
				log.error("handleException", ex)
			}
		} else {
			throw ex
		}
	}

	def protected void handleException(ServiceDaten d, Throwable ex) {
		handleException(d, ex, null)
	}

	def private DataSource getDataSource() {

		if (ds === null) {
			synchronized (log) {
				ds = getDataSource(false)
			}
		}
		return ds
	}

	def private DataSource getDataSourceRep() {

		if (dsRep === null) {
			synchronized (log) {
				dsRep = getDataSource(true)
			}
		}
		return dsRep
	}

	def private DataSource getDataSource(boolean replikation) {

		val props = new Properties()
		val input = typeof(RepositoryBase).classLoader.getResourceAsStream(Global.serverConfigProperties)
		props.load(input)
		val config = new HikariConfig
		if (replikation) {
			config.setJdbcUrl(props.getProperty("REPLIKATION_CONNECT"))
			config.setUsername(props.getProperty("REPLIKATION_USERNAME"))
			config.setPassword(props.getProperty("REPLIKATION_PASSWORD"))
		} else {
			var jdbcUrl = props.getProperty("DB_DRIVER_CONNECT")
			dbart = getDbArt(jdbcUrl)
			config.setJdbcUrl(jdbcUrl)
			config.setUsername(props.getProperty("DB_DRIVER_USERNAME"))
			config.setPassword(props.getProperty("DB_DRIVER_PASSWORD"))
		}
		config.addDataSourceProperty("cachePrepStmts", "true")
		config.addDataSourceProperty("prepStmtCacheSize", "250")
		config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048")
		config.setMaximumPoolSize(5)
		// config.setInitializationFailFast(true)

		val ds = new HikariDataSource(config)
		return ds
	}

	def private DatenbankArt getDbArt(String jdbcUrl) {

		var dbType = DatenbankArt.KEINE
		if (jdbcUrl !== null) {
			if (jdbcUrl.indexOf("Microsoft Access-Treiber (*.mdb)") >= 0) {
				dbType = DatenbankArt.JET
			} else if (jdbcUrl.startsWith("jdbc:mysql")) {
				dbType = DatenbankArt.MYSQL
			} else if (jdbcUrl.startsWith("jdbc:hsqldb")) {
				dbType = DatenbankArt.HSQLDB
			} else {
				dbType = DatenbankArt.SQL70
			}
		}
		return dbType
	}

	def protected DatenbankArt getDbArt() {
		return dbart
	}

	def protected DbContext getDb(ServiceDaten d, boolean transaction) {

		// System.out.println("getDb2")
		if (d === null) {
			return null
		}
		var DbContext ctx
		if (d.context !== null && d.context instanceof DbContext) {
			ctx = d.context as DbContext
		} else {
			// System.out.println("getDb2 new DbContext")
			ctx = new DbContext
		}
		if (ctx.con === null) {
			ctx.con = dataSource.connection
			ctx.con.autoCommit = !transaction
			// if (transaction) {
			// System.out.println("transaction")
			// }
			ctx.transaction = transaction
			d.rbListe = new RollbackListe
		} else {
			ctx.tiefe = ctx.tiefe + 1
		}
		// } else if (ctx.transaction != transaction) {
		// throw new Exception('Inkonsistenter Transaktion-Schalter.')
		// }
		d.context = ctx
		return ctx
	}

	def protected DbContext getDbRep(ServiceDaten d, boolean transaction) {

		// System.out.println("getDbRep")
		if (d === null) {
			return null
		}
		var DbContext ctx
		if (d.contextRep !== null && d.contextRep instanceof DbContext) {
			ctx = d.contextRep as DbContext
		} else {
			// System.out.println("getDbRep new DbContext")
			ctx = new DbContext
		}
		if (ctx.con === null) {
			ctx.con = dataSourceRep.connection
			ctx.con.autoCommit = !transaction
			ctx.transaction = transaction
		} else {
			ctx.tiefe = ctx.tiefe + 1
		}
		d.contextRep = ctx
		return ctx
	}

	def protected DbContext getDb(ServiceDaten d) {

		// System.out.println("getDb1")
		if (d === null) {
			return null
		}
		var DbContext ctx
		if (d.context !== null && d.context instanceof DbContext) {
			ctx = d.context as DbContext
		} else {
			// System.out.println("getDb1 new DbContext")
			ctx = new DbContext
		}
		return ctx
	}

	def protected JhhFopDokumentImpl newFopDokument() {

		if (jhhFop === null) {
			var stream = getClass.getResourceAsStream("/fop.xconf")
			var cfgBuilder = new DefaultConfigurationBuilder
			var cfg = cfgBuilder.build(stream)
			var baseUri = new File(".").toURI
			var fopFactoryBuilder = new FopFactoryBuilder(baseUri).setConfiguration(cfg)
			var fopFactory = fopFactoryBuilder.build
			jhhFop = new JhhFop
			jhhFop.fopFactory = fopFactory
		}
		var doc = new JhhFopDokumentImpl(jhhFop)
		return doc
	}

	def protected <R extends DtoBase> exportListeFuellen(List<String> spaltennamen, List<R> zeilen, R dto,
		List<String> l) {

		var methods = new ArrayList<Method>()
		val Class<?>[] keinParameter = newArrayOfSize(0)

		for (s : spaltennamen) {
			methods.add(dto.getClass.getMethod("get" + s, keinParameter))
		}
		for (z : zeilen) {
			var felder = new ArrayList<String>()
			for (m : methods) {
				felder.add(Global.objStr(Global.formatString(m.invoke(z))))
			}
			l.add(Global.encodeCSV(felder))
		}
	}

	/** Liefert getrimmten String. Wenn String null oder leer ist, wird null geliefert. */
	def protected String n(String s) {

		if (s === null || s.trim == "") {
			return null
		}
		return s.trim
	}
}

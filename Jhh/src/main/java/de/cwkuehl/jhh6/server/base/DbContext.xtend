package de.cwkuehl.jhh6.server.base

import java.sql.Connection
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DbContext {
	private Connection con
	// private Connection conRep
	private boolean transaction
	private int tiefe = 0
}

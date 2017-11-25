package de.cwkuehl.jhh6.server.base

import de.cwkuehl.jhh6.api.dto.base.DtoBase
import de.cwkuehl.jhh6.api.service.ServiceDaten
import java.lang.reflect.Method

public class RbRepository {

	private Object rep
	private Method insert
	private Method update
	private Method delete

	public new(Object rep, Class<?> irep, Class<? extends DtoBase> key, Class<? extends DtoBase> dto,
		Class<? extends DtoBase> u) {

		this.rep = rep
		insert = irep.getMethod("insert", typeof(ServiceDaten), dto)
		update = irep.getMethod("update", typeof(ServiceDaten), u)
		delete = irep.getMethod("delete", typeof(ServiceDaten), key)
	}

	def public insert(ServiceDaten daten, Object dto) {
		insert.invoke(rep, daten, dto)
	}

	def public update(ServiceDaten daten, Object u) {
		update.invoke(rep, daten, u)
	}

	def public delete(ServiceDaten daten, Object key) {
		delete.invoke(rep, daten, key)
	}

}


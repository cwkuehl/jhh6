package de.cwkuehl.jhh6.generator

import de.cwkuehl.jhh6.generator.MachDto.Dtos
import java.sql.ResultSet
import java.sql.SQLException
import java.util.List
import java.util.function.Function
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.cwkuehl.jhh6.generator.Fragmente.*
import static extension de.cwkuehl.jhh6.generator.Global.*

class MachRep {

	@Accessors
	static class Reps {
		public MutableInterfaceDeclaration interfaceType
		public TypeReference sqlBuilder
	}

	def static doRegisterGlobalsRep(ClassDeclaration c, extension RegisterGlobalsContext context) {

		registerInterface(c.repInterfaceName)
	}

	def static void doTransformRep(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		var r = new Reps
		r.interfaceType = findInterface(c.repInterfaceName)
		r.sqlBuilder = findTypeGlobally(sqlBuilderName).newTypeReference
		// r.rbListe = findTypeGlobally(rbListeName).newTypeReference
		c.repInterface(context, r, d)
		c.rep(context, r, d)
	}

	// Repository-Interface
	def static void repInterface(MutableClassDeclaration c, extension TransformationContext context, Reps r, Dtos d) {

		r.interfaceType.primarySourceElement = null

		r.interfaceType.addMethod("get") [
			docComment = '''Lesen eines Datensatzes in der Tabelle «d.tablename» nach Primärschlüssel.'''
			returnType = d.dtoType.newTypeReference
			addParameter("daten", d.serviceDaten)
			addParameter("key", d.dtoKeyType.newTypeReference)
		]

		r.interfaceType.addMethod("getListe") [
			docComment = '''
			Lesen aller Datensätze der Tabelle «d.tablename» für einen Mandanten.
			@param daten Service-Daten für Datenbankzugriff.
			@param mandantNr Mandantennummer.
			@param where Zusätzliche Where-Klausel.
			@param order Order By-Klausel.
			@return Liste von DTO-Instanzen.'''
			returnType = List.newTypeReference(d.dtoType.newTypeReference)
			addParameter("daten", d.serviceDaten)
			if (d.hasMandantNr) {
				addParameter("mandantNr", int.newTypeReference)
			}
			addParameter("where", r.sqlBuilder)
			addParameter("order", r.sqlBuilder)
		]

		if (d.insert) {
			r.interfaceType.addMethod("insert") [
				docComment = '''
				Einfügen eines Datensatzes in die Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				@param dto DTO-Instanz.'''
				// returnType = d.dtoType.newTypeReference
				addParameter("daten", d.serviceDaten)
				addParameter("dto", d.dtoType.newTypeReference)
			]
			r.interfaceType.addMethod("insert") [
				docComment = '''
				Einfügen eines Datensatzes in die Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				@param dto DTO-Instanz.
				@param rev Revisionsdaten für das Ändern werden überschrieben.'''
				// returnType = d.dtoType.newTypeReference
				addParameter("daten", d.serviceDaten)
				addParameter("dto", d.dtoType.newTypeReference)
				addParameter("rev", boolean.newTypeReference)
			]
		}

		if (d.update) {
			r.interfaceType.addMethod("update") [
				docComment = '''
				Aktualisieren eines Datensatzes in die Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				@param u DTO-Update-Instanz.'''
				addParameter("daten", d.serviceDaten)
				addParameter("u", d.dtoUpdateType.newTypeReference)
			]
			r.interfaceType.addMethod("update") [
				docComment = '''
				Aktualisieren eines Datensatzes in die Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				@param u DTO-Update-Instanz.
				@param rev Revisionsdaten für das Anlegen werden überschrieben.'''
				addParameter("daten", d.serviceDaten)
				addParameter("u", d.dtoUpdateType.newTypeReference)
				addParameter("rev", boolean.newTypeReference)
			]
		}

		if (d.delete) {
			r.interfaceType.addMethod("delete") [
				docComment = '''
				Löschen eines Datensatzes in der Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				@param key DTO-Key-Instanz.'''
				// returnType = d.dtoType.newTypeReference
				addParameter("daten", d.serviceDaten)
				addParameter("key", d.dtoKeyType.newTypeReference)
			]
		}

		r.interfaceType.fragmentIuEntity(context, d, false)

		for (m : c.declaredMethods) {
			if (m.visibility == Visibility.PUBLIC) {
				r.interfaceType.addMethod(m.simpleName) [
					docComment = m.docComment
					returnType = m.returnType
					for (p : m.parameters) {
						addParameter(p.simpleName, p.type)
					}
				]
			}
		}

		d.vos.forEach [ x |
			r.interfaceType.addMethod('getListe' + x.voname) [
				docComment = '''
				Lesen von Datensätzen der Tabelle «d.tablename».
				@param daten Service-Daten für Datenbankzugriff.
				«IF d.hasMandantNr»@param mandantNr Mandantennummer.«ENDIF»
				@param where Where-Bedingung kann null sein.
				@param order Order By-Klausel.
				@return Liste von DTO-Instanzen.'''
				returnType = List.newTypeReference(x.voType.newTypeReference)
				addParameter("daten", d.serviceDaten)
				if (d.hasMandantNr) {
					addParameter("mandantNr", int.newTypeReference)
				}
				addParameter("where", r.sqlBuilder)
				addParameter("order", r.sqlBuilder)
			]
		]

	}

	// Repository
	def static void rep(MutableClassDeclaration c, extension TransformationContext context, Reps r, Dtos d) {

		// add the interface to the list of implemented interfaces
		c.implementedInterfaces = c.implementedInterfaces + #[r.interfaceType.newTypeReference]
		c.extendedClass = findTypeGlobally(repBaseName).newTypeReference

		c.addMethod("get") [
			docComment = '''Lesen eines Datensatzes in der Tabelle «d.tablename» nach Primärschlüssel.'''
			returnType = d.dtoType.newTypeReference
			addParameter("daten", d.serviceDaten)
			addParameter("key", d.dtoKeyType.newTypeReference)
			body = [
				'''
				«r.sqlBuilder» sql = selectSql(key«IF d.hasMandantNr», null«ENDIF», null, null);
				return selectOne(daten, sql, readDto, «d.dtoType.newTypeReference».class);'''
			]
		]

		c.addMethod("getListe") [
			docComment = '''Lesen aller Datensätze der Tabelle «d.tablename» für einen Mandanten.'''
			returnType = List.newTypeReference(d.dtoType.newTypeReference)
			addParameter("daten", d.serviceDaten)
			if (d.hasMandantNr) {
				addParameter("mandantNr", int.newTypeReference)
			}
			addParameter("where", r.sqlBuilder)
			addParameter("order", r.sqlBuilder)
			body = [
				'''
				«r.sqlBuilder» sql = selectSql(null«IF d.hasMandantNr», mandantNr«ENDIF», where, order);
				return selectList(daten, sql, readDto, «d.dtoType.newTypeReference».class);'''
			]
		]

		if (d.insert) {
			c.addMethod("insert") [
				docComment = '''Einfügen eines Datensatzes in die Tabelle «d.tablename».'''
				addParameter("daten", d.serviceDaten)
				addParameter("dto", d.dtoType.newTypeReference)
				body = ['''insert(daten, dto, true);''']
			]

			c.addMethod("insert") [
				docComment = '''Einfügen eines Datensatzes in die Tabelle «d.tablename».'''
				addParameter("daten", d.serviceDaten)
				addParameter("dto", d.dtoType.newTypeReference)
				addParameter("rev", boolean.newTypeReference)
				body = [
					'''
					if (dto == null) {
						return;
					}
					if (rev && !daten.getRbListe().isRollbackRedo()) {
						dto.machAngelegt(daten.getJetzt(), daten.getBenutzerId());
					}
					«r.sqlBuilder» sql = insertSql(dto);
					insert(daten, dto, sql);'''
				]
			]

			c.addMethod("insertSql") [
				docComment = '''Erstellen des Insert-Befehls für Tabelle «d.tablename».'''
				visibility = Visibility.PROTECTED
				returnType = r.sqlBuilder
				addParameter("dto", d.dtoType.newTypeReference)
				body = [
					'''
					«r.sqlBuilder» sql = new «r.sqlBuilder»();
					sql.append("INSERT INTO «d.tablename»(");
					«FOR a : d.attribute.indexed»
						sql.append("«a.v.name»«IF !a.last», «ENDIF»");
					«ENDFOR»
					sql.append(") VALUES (");
					«FOR a : d.attribute.indexed»
						sql.append("?«IF !a.last», «ENDIF»", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»dto.«a.v.name.getterName»()«a.v.conv2»);
					«ENDFOR»
					sql.append(")");
					return sql;'''
				]
			]
		}

		if (d.update) {
			c.addMethod("update") [
				docComment = '''Aktualisieren eines Datensatzes in die Tabelle «d.tablename».'''
				addParameter("daten", d.serviceDaten)
				addParameter("u", d.dtoUpdateType.newTypeReference)
				body = ['''update(daten, u, true);''']
			]

			c.addMethod("update") [
				docComment = '''Aktualisieren eines Datensatzes in die Tabelle «d.tablename».'''
				addParameter("daten", d.serviceDaten)
				addParameter("u", d.dtoUpdateType.newTypeReference)
				addParameter("rev", boolean.newTypeReference)
				body = [
					'''
					if (u == null || !u.isChanged()) {
						return;
					}
					if (rev && !daten.getRbListe().isRollbackRedo()) {
						u.machGeaendert(daten.getJetzt(), daten.getBenutzerId());
					}
					«r.sqlBuilder» sql = updateSql(u);
					update(daten, u, sql);'''
				]
			]

			c.addMethod("updateSql") [
				docComment = '''Erstellen des Update-Befehls für Tabelle «d.tablename».'''
				visibility = Visibility.PROTECTED
				returnType = r.sqlBuilder
				addParameter("u", d.dtoUpdateType.newTypeReference)
				body = [
					'''
					«r.sqlBuilder» sql = new «r.sqlBuilder»();
					sql.append("UPDATE «d.tablename»");
					sql.praefix(" SET ", ", ");
					«FOR a : d.attribute.indexed»
						if (u.«a.v.getterName»Changed())
							sql.append("«a.v.name»=?", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»u.«a.v.name.getterName»()«a.v.conv2»);
					«ENDFOR»
					sql.praefix(" WHERE ", " AND ");
					«FOR a : d.keyAttribute.indexed»
						sql.append("«IF !a.first»«ENDIF»«a.v.name»=?", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»u.«a.v.name.getterName»Old()«a.v.conv2»);
					«ENDFOR»
					«FOR a : d.notKeyAttribute.filter[javaTyp.simpleName!='byte[]'].indexed»
						if (u.«a.v.getterName»OldNull())
							sql.append("«a.v.name» IS NULL");
						else	
							sql.append("«a.v.name»=?", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»u.«a.v.getterName»Old()«a.v.conv2»);
					«ENDFOR»
					return sql;'''
				]
			]
		}

		if (d.delete) {
			c.addMethod("delete") [
				docComment = '''Löschen eines Datensatzes in der Tabelle «d.tablename».'''
				// returnType = d.dtoType.newTypeReference
				addParameter("daten", d.serviceDaten)
				addParameter("key", d.dtoKeyType.newTypeReference)
				body = [
					'''
					if (key == null) {
						return;
					}
					«d.dtoType.newTypeReference» dto = get(daten, key);
					if (dto != null) {
						«r.sqlBuilder» sql = deleteSql(key);
						delete(daten, dto, sql);
					}'''
				]
			]

			c.addMethod("deleteSql") [
				docComment = '''Erstellen des Delete-Befehls für Tabelle «d.tablename».'''
				visibility = Visibility.PROTECTED
				returnType = r.sqlBuilder
				addParameter("key", d.dtoKeyType.newTypeReference)
				body = [
					'''
					«r.sqlBuilder» sql = new «r.sqlBuilder»();
					sql.append("DELETE FROM «d.tablename»");
					sql.praefix(" WHERE ", " AND ");
					«FOR a : d.keyAttribute.indexed»
						sql.append("«a.v.name»=?", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»key.«a.v.getterName»()«a.v.conv2»);
					«ENDFOR»
					return sql;'''
				]
			]
		}

		c.fragmentIuEntity(context, d, true)

		c.addMethod("columns") [
			docComment = '''Liefert Spalten der Tabelle «d.tablename».'''
			visibility = Visibility.PROTECTED
			returnType = r.sqlBuilder
			addParameter("prefix", String.newTypeReference)
			body = [
				'''
				«String.newTypeReference» p = prefix == null || prefix.equals("") ? "" : prefix + ".";
				«r.sqlBuilder» sql = new «r.sqlBuilder»();
				«FOR a : d.attribute.indexed»
					sql.append(p).append("«a.v.name»«IF !a.last», «ENDIF»");
				«ENDFOR»
				return sql;'''
			]
		]

		c.addMethod("selectSql") [
			docComment = '''Erstellen des Select-Befehls für Tabelle «d.tablename».'''
			visibility = Visibility.PROTECTED
			returnType = r.sqlBuilder
			addParameter("key", d.dtoKeyType.newTypeReference)
			if (d.hasMandantNr) {
				addParameter("mandantNr", Integer.newTypeReference)
			}
			addParameter("where", r.sqlBuilder)
			addParameter("order", r.sqlBuilder)
			body = [
				'''
				«r.sqlBuilder» sql = new «r.sqlBuilder»();
				sql.append("SELECT ").append(columns("a"));
				sql.append(" FROM «d.tablename» a");
				boolean w = false;
				if (key != null) {
					w = true;
					«FOR a : d.keyAttribute.indexed»
						«IF a.first»sql.append(" WHERE ");«ENDIF»
						sql.append("a.«a.v.name»=?", «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class, «a.v.conv1»key.«a.v.getterName»()«a.v.conv2»)«IF a.last»;«ELSE».append(" AND ");«ENDIF»
					«ENDFOR»
				«IF d.hasMandantNr»
					} else if (mandantNr != null) {
						w = true;
						sql.append(" WHERE a.Mandant_Nr=?", int.class, mandantNr.intValue());
				«ENDIF»
				}
				if (where != null && where.length() > 0) {
					if (w) {
						sql.append(" AND ");
					} else {
						sql.append(" WHERE ");
					}
					sql.append(where);
				}
				if (order != null) {
					sql.append(" ORDER BY ").append(order);
				}
				return sql;'''
			]
		]

		for (p : c.declaredFields) {
			if (p.simpleName != 'REP_NR') {
				p.remove
			}
		}

		c.addField('readDto') [
			docComment = '''Funktion zum Lesen des DTO aus dem ResultSet.'''
			visibility = Visibility.PROTECTED
			type = Function.newTypeReference(ResultSet.newTypeReference, d.dtoType.newTypeReference)
			initializer = [
				'''
				rs -> {
					«d.dtoType.newTypeReference» d = new «d.dtoType.newTypeReference»();
					«IF d.attribute.size > 0»
						try {
							«FOR a : d.attribute.indexed»
							d.«a.v.setterName»(«a.v.conv1»rs.«IF a.v.convget===null»getObject(«a.index1», «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class)«ELSE»«a.v.convget»(«a.index1»)«ENDIF»«a.v.conv2»);
						«ENDFOR»
						} catch (java.sql.«SQLException.newTypeReference» ex) {
							throw new «RuntimeException.newTypeReference»(ex);
						}
					«ENDIF»
					return d;
				}'''
			]
		]

		d.vos.forEach [ x |
			c.addMethod('getListe' + x.voname) [
				docComment = '''Lesen von Datensätzen der Tabelle «d.tablename».'''
				returnType = List.newTypeReference(x.voType.newTypeReference)
				addParameter("daten", d.serviceDaten)
				if (d.hasMandantNr) {
					addParameter("mandantNr", int.newTypeReference)
				}
				addParameter("where", r.sqlBuilder)
				addParameter("order", r.sqlBuilder)
				body = [
					'''
					«r.sqlBuilder» sql = new «r.sqlBuilder»();
					sql.append("SELECT ");
					«FOR a : x.attribute.indexed»
						sql.append("«IF !a.first», «ENDIF»«a.v.selectString»");
					«ENDFOR»
					sql.append(" FROM «IF x.selectFrom.nn==''»«d.tablename» a«ELSE»«x.selectFrom»«ENDIF»");
					sql.praefix(" WHERE ", " AND ");
					«IF d.hasMandantNr»sql.append("a.Mandant_Nr=?", int.class, mandantNr);«ENDIF»
					if (where != null) {
						sql.append(where);
					}
					sql.praefix(null, null);
					«IF x.selectGroupBy.nn != ""»
						sql.append(" GROUP BY «x.selectGroupBy»");
					«ENDIF»
					if (order != null) {
						sql.append(" ORDER BY ").append(order);
					«IF x.selectOrderBy.nn != ""»
						} else {
							sql.append(" ORDER BY «x.selectOrderBy»");
					«ENDIF»
					}
					return selectList(daten, sql, readDto«x.voname», «x.voType.newTypeReference».class);'''
				]
			]

			c.addField('readDto' + x.voname) [
				docComment = '''Funktion zum Lesen des VO aus dem ResultSet.'''
				visibility = Visibility.PROTECTED
				type = Function.newTypeReference(ResultSet.newTypeReference, x.voType.newTypeReference)
				initializer = [
					'''
					rs -> {
						«x.voType.newTypeReference» d = new «x.voType.newTypeReference»();
						«IF x.attribute.size > 0»
							try {
								«FOR a : x.attribute.indexed»
									d.«a.v.setterName»(«a.v.conv1»rs.getObject(«a.index1», «IF a.v.jdbcJavaTyp===null»«a.v.javaTyp»«ELSE»«a.v.jdbcJavaTyp»«ENDIF».class)«a.v.conv2»);
								«ENDFOR»
							} catch (java.sql.«SQLException.newTypeReference» ex) {
								throw new «RuntimeException.newTypeReference»(ex);
							}
						«ENDIF»
						return d;
					}'''
				]
			]
		]

	}
}

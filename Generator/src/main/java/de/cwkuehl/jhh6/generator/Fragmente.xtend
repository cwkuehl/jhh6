package de.cwkuehl.jhh6.generator

import de.cwkuehl.jhh6.generator.MachDto.Attribute
import de.cwkuehl.jhh6.generator.MachDto.Dtos
import de.cwkuehl.jhh6.generator.MachDto.Vo
import java.util.function.BiConsumer
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.cwkuehl.jhh6.generator.Global.*

class Fragmente {

	def static void fragmentSerialVersionUID(MutableClassDeclaration c, extension TransformationContext context) {

		c.addField("serialVersionUID") [
			docComment = "Versionsnummer."
			type = long.newTypeReference
			final = true
			static = true
			initializer = ['1l']
		]
	}

	def static void fragmentAttributeBean(MutableClassDeclaration c, extension TransformationContext context,
		TypeReference javaTyp, String attName, String initValue, String getterName, String setterName, String nameDoc,
		String getterDoc, String setterDoc, String setterBodyExt) {

		if (nameDoc !== null) {
			c.addField(attName) [
				type = javaTyp
				if (initValue !== null) {
					initializer = [initValue]
				}
				docComment = nameDoc
			]
		}
		if (getterName !== null) {
			c.addMethod(getterName) [
				returnType = javaTyp
				docComment = getterDoc
				body = ['''return «attName»;''']
			]
		}
		if (setterName !== null) {
			c.addMethod(setterName) [
				returnType = void.newTypeReference
				docComment = setterDoc
				addParameter("v", javaTyp)
				body = ['''this.«attName» = v;«IF setterBodyExt !== null»«"\n"»«setterBodyExt»«ENDIF»''']
			]
		}
	}

	def static void fragmentAttributeBean(Attribute a, MutableClassDeclaration c,
		extension TransformationContext context) {

		fragmentAttributeBean(c, context, a.javaTyp, a.attName, null, a.getterName,
			a.setterName, '''Spalte «a.name».''', '''
			Liefert Wert der Spalte «a.name».
			@return Wert der Spalte «a.name».''', '''
			Setzen eines neuen Wertes für Spalte «a.name».
			@param v Neuer Wert der Spalte «a.name».''', null)
	}

	def static void fragmentAttributeBeanList(MutableClassDeclaration c, extension TransformationContext context,
		Iterable<Attribute> liste) {

		for (a : liste) {
			a.fragmentAttributeBean(c, context)
		}
	}

	def static void fragmentAttributeTypLaengeList(MutableClassDeclaration c, extension TransformationContext context,
		Iterable<Attribute> liste) {

		for (a : liste) {
			if (a.length > 0 && a.javaTyp.simpleName == "String") {
				c.addField(a.name.typLaengeName) [
					type = int.newTypeReference
					initializer = ['''«a.length»''']
					docComment = '''Länge der Spalte «a.name».'''
					visibility = Visibility.PUBLIC
					final = true
					static = true
				]
			}
		}
	}

	def static void fragmentAttributeNameList(MutableClassDeclaration c, extension TransformationContext context,
		Iterable<Attribute> liste) {

		for (a : liste) {
			c.addField(a.name.attNameName) [
				type = String.newTypeReference
				initializer = ['''"«a.name»"''']
				docComment = '''Name der Spalte «a.name».'''
				visibility = Visibility.PUBLIC
				final = true
				static = true
			]
		}
	}

	def static void fragmentGetPk(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		c.addMethod("getPk") [
			returnType = d.dtoKeyType.newTypeReference
			docComment = '''
			Liefert Instanz des Primärschlüssels.
			@return Primärschlüssel.'''
			body = [
				'''
				«d.dtoKeyType.newTypeReference» pk = new «d.dtoKeyType.newTypeReference»();
				«FOR a : d.keyAttribute»
					pk.«a.setterName»(«a.getterName»());
				«ENDFOR»
				return pk;'''
			]
		]
	}

	def static void fragmentGetClone(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		c.addMethod("getClone") [
			returnType = d.dtoType.newTypeReference
			docComment = '''
			Liefert Kopie der Instanz.
			@return Kopie der Instanz.'''
			body = [
				'''
				«d.dtoType.newTypeReference» c = new «d.dtoType.newTypeReference»();
				c.setReplikation(isReplikation());
				«FOR a : d.attribute»
					c.«a.setterName»(«a.getterName»());
				«ENDFOR»
				return c;'''
			]
		]
	}

	def static void fragmentGetCloneUpdate(MutableClassDeclaration c, extension TransformationContext context, Dtos d, boolean umgekehrt) {

		c.addMethod('''getClone«IF umgekehrt»2«ENDIF»''') [
			returnType = d.dtoUpdateType.newTypeReference
			docComment = '''
			Liefert«IF umgekehrt» umgekehrte«ENDIF» Kopie der Instanz.
			@return«IF umgekehrt» umgekehrte«ENDIF» Kopie der Instanz.'''
			body = [
				'''
				«d.dtoType.newTypeReference» vo = new «d.dtoType.newTypeReference»();
				vo.setReplikation(isReplikation());
				«FOR a : d.attribute»
					vo.«a.setterName»(«a.getterName»«IF !umgekehrt»Old«ENDIF»());
				«ENDFOR»
				«d.dtoUpdateType.newTypeReference» c = new «d.dtoUpdateType.newTypeReference»(vo);
				«FOR a : d.attribute»
					c.«a.setterName»(«a.getterName»«IF umgekehrt»Old«ENDIF»());
				«ENDFOR»
				return c;'''
			]
		]
	}

	def static void fragmentGetCloneDtoUpdate(MutableClassDeclaration c, extension TransformationContext context,
		Dtos d) {

		c.addMethod("getCloneDto") [
			returnType = d.dtoType.newTypeReference
			docComment = '''
			Liefert Kopie als DTO.
			@return Kopie als DTO.'''
			body = [
				'''
				«d.dtoType.newTypeReference» vo = new «d.dtoType.newTypeReference»();
				vo.setReplikation(isReplikation());
				«FOR a : d.attribute»
					vo.«a.setterName»(«a.getterName»());
				«ENDFOR»
				return vo;'''
			]
		]
	}

	def static void fragmentGetCloneVo(MutableClassDeclaration c, extension TransformationContext context, Vo vo) {

		c.addMethod("getClone") [
			returnType = vo.voType.newTypeReference
			docComment = '''
			Liefert Kopie der Instanz.
			@return Kopie der Instanz.'''
			body = [
				'''
				«vo.voType.newTypeReference» c = new «vo.voType.newTypeReference»();
				c.setReplikation(isReplikation());
				«FOR a : vo.attribute»
					c.«a.setterName»(«a.getterName»());
				«ENDFOR»
				return c;'''
			]
		]
	}

	def static void fragmentAttributeBeanListUpdate(MutableClassDeclaration c, extension TransformationContext context,
		Dtos d) {

		for (a : d.attribute) {
			c.fragmentAttributeBean(context, a.javaTyp, a.attName + "Old", null, a.getterName + "Old",
				null, '''Alter Wert der Spalte «a.name».''', '''
				Liefert den alten Wert der Spalte «a.name».
				@return alter Wert der Spalte «a.name».''', null, null)
			c.fragmentAttributeBean(context, a.javaTyp, a.attName + "New", null, a.getterName,
				a.
					setterName
				, '''Neuer Wert der Spalte «a.name».''', '''
				Liefert den neuen Wert der Spalte «a.name».
				@return neuer Wert der Spalte «a.name».''', '''
				Setzen des neuen Wertes für Spalte «a.name».
				@param v Neuer Wert der Spalte «a.name».''', '''«a.attName»Changed = unequals(«a.attName»Old, «a.attName»New);''')
				c.fragmentAttributeBean(context, boolean.newTypeReference, a.attName + "Changed", null,
					a.getterName + "Changed", null, '''Wurde Spalte «a.name» geändert?''', '''
					Ist alter Wert der Spalte «a.name» null?.
					@return true, wenn alter Wert der Spalte «a.name» null ist.''', null, null)
				c.addMethod(a.getterName + "OldNull") [
					returnType = boolean.newTypeReference
					docComment = '''
					Ist alter Wert der Spalte «a.name» null?.
					@return true, wenn alter Wert der Spalte «a.name» null ist.'''
					body = ['''return isNull0(«a.attName»Old);''']
				]
			}
		}

		def static void fragmentIuEntity(MutableTypeDeclaration c, extension TransformationContext context, Dtos d,
			boolean impl) {

			if (d.insert && d.update) {
				c.addMethod("iu" + d.dtoType.simpleName) [
					if (impl) {
						visibility = Visibility.PUBLIC
					}
					returnType = d.dtoType.newTypeReference
					docComment = '''
					Anlegen oder Ändern eines Datensatzes in die Tabelle «d.tablename».
					«IF !impl»
						@param daten Service-Daten mit Mandantennummer.
						«FOR a : d.getIuAttribute»
							@param «a.attName» Wert der Spalte «a.name».
						«ENDFOR»
					«ENDIF»
					@return Daten als DTO.'''
					addParameter("daten", d.serviceDaten)
					addParameter("beforeEvent", BiConsumer.newTypeReference(d.dtoType.newTypeReference, d.dtoUpdateType.newTypeReference))
					for (a : d.iuAttribute) {
						addParameter(a.attName, a.javaTyp)
					}
					if (impl) {
						body = [
							'''
							«d.dtoKeyType.newTypeReference» key = new «d.dtoKeyType.newTypeReference»();
							«d.dtoType.newTypeReference» vo2 = null;
							«IF d.hasMandantNr»
								int mandantNr = daten.getMandantNr();
							«ENDIF»
							«IF d.replicationNr > 0 && d.replicationPrimaryKey»
								if (!nes(«d.replicationAttr.attName»)) {
									«FOR a : d.keyAttribute»
										key.«a.setterName»(«a.attName»);
									«ENDFOR»
									vo2 = get(daten, key);
								}
							«ELSE»
								«FOR a : d.keyAttribute»
									key.«a.setterName»(«a.attName»);
								«ENDFOR»
								vo2 = get(daten, key);
							«ENDIF»
							if (vo2 == null) {
								«IF d.replicationNr > 0 && d.replicationPrimaryKey»
									«IF d.uidAbhaengig»
									if (nes(«d.replicationAttr.attName»)) {
										throw new «RuntimeException.newTypeReference»("«d.dtoType.simpleName.substring(2)»-Nr. nicht vorhanden.");
									}
									«ELSE»
									if (!nes(«d.replicationAttr.attName»)) {
										throw new «RuntimeException.newTypeReference»("«d.dtoType.simpleName.substring(2)»-Nr. " + «d.replicationAttr.attName» + " nicht vorhanden.");
									}
									«ENDIF»
								«ENDIF»
								«d.dtoType.newTypeReference» vo = new «d.dtoType.newTypeReference»();
								«IF d.hasMandantNr»
									vo.setMandantNr(mandantNr);
								«ENDIF»
								«FOR a : d.getIuAttribute»
									«IF d.replicationNr > 0 && d.replicationAttr.attName == a.attName && !d.uidAbhaengig»
										if (nes(«a.attName»)) {
											vo.«a.setterName»(getUid());
										}
									«ELSE»
										vo.«a.setterName»(«a.attName»);
									«ENDIF»
								«ENDFOR»
								«IF d.replicationAttr !== null && !d.replicationPrimaryKey»
									vo.«d.replicationAttr.setterName»(getUid());
								«ENDIF»
								if (beforeEvent != null) {
									beforeEvent.accept(vo, null);
								}
								insert(daten, vo«IF d.revision>0», angelegtVon == null«ENDIF»);
								return vo;
							} else {
								«d.dtoUpdateType.newTypeReference» voU = new «d.dtoUpdateType.newTypeReference»(vo2);
								«IF d.hasMandantNr»
									voU.setMandantNr(mandantNr);
								«ENDIF»
								«FOR a : d.iuAttribute.filter[x|x.name!='Angelegt_Von' && x.name!='Angelegt_Am' && x.name!='Geaendert_Von' && x.name!='Geaendert_Am']»
									«IF d.replicationNr > 0 && d.replicationAttr.attName == a.attName»
										if (nes(voU.«a.getterName»())) {
											voU.«a.setterName»(getUid());
										}
									«ELSE»
										voU.«a.setterName»(«a.attName»);
									«ENDIF»
								«ENDFOR»
								«IF d.revision>0»
									if (angelegtVon != null) {
										voU.setAngelegtVon(angelegtVon);
										voU.setAngelegtAm(angelegtAm);
										voU.setGeaendertVon(geaendertVon);
										voU.setGeaendertAm(geaendertAm);
									}
								«ENDIF»
								«IF d.replicationAttr !== null && !d.replicationPrimaryKey»
									if (nes(voU.«d.replicationAttr.getterName»())) {
										voU.«d.replicationAttr.setterName»(getUid());
									}
								«ENDIF»
								if (beforeEvent != null) {
									beforeEvent.accept(null, voU);
								}
								update(daten, voU«IF d.revision>0», angelegtVon == null«ENDIF»);
								return voU.getCloneDto();
							}'''
						]
					}
				]
			}
		}

	}

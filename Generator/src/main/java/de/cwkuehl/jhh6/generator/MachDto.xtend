package de.cwkuehl.jhh6.generator

import de.cwkuehl.jhh6.generator.annotation.Column
import de.cwkuehl.jhh6.generator.annotation.Id
import de.cwkuehl.jhh6.generator.annotation.PrimaryKeyJoinColumn
import java.io.Serializable
import java.util.ArrayList
import java.util.List
import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.cwkuehl.jhh6.generator.Fragmente.*
import static extension de.cwkuehl.jhh6.generator.Global.*

class MachDto {

	@Accessors
	static class Dtos {
		public String tablename
		public TypeReference dtoBaseType
		public MutableClassDeclaration dtoKeyType
		public MutableClassDeclaration dtoType
		public MutableClassDeclaration dtoUpdateType
		public TypeReference serializableType
		public TypeReference serviceDaten
		public TypeReference longType
		public List<Attribute> keyAttribute = new ArrayList<Attribute>
		public List<Attribute> notKeyAttribute = new ArrayList<Attribute>
		public List<Attribute> attribute = new ArrayList<Attribute>
		public List<Attribute> iuAttribute = new ArrayList<Attribute>
		public List<Vo> vos = new ArrayList<Vo>
		public boolean hasMandantNr
		public int revision
		public boolean insert
		public boolean update
		public boolean delete
		public int replicationNr
		public Attribute replicationAttr
		public boolean replicationPrimaryKey
		public boolean replicationCopy
		public boolean uidAbhaengig
	}

	@Accessors
	static class Attribute {
		public String name
		public int length
		public boolean nullable
		public TypeReference javaTyp
		public String jdbcJavaTyp
		public String conv1
		public String conv2
		public String convget
		public String selectString
		public boolean namenbehalten

		def public String attName() {
			if (namenbehalten) {
				return name.toFirstLower
			}
			name.javaName
		}

		def public String getterName() {
			if (namenbehalten) {
				return '''get«name.toFirstUpper»'''
			}
			name.getterName
		}

		def public String setterName() {
			if (namenbehalten) {
				return '''set«name.toFirstUpper»'''
			}
			name.setterName
		}

		def public void updateJdbc() {

			if (javaTyp === null) {
				return
			}
			if (javaTyp.simpleName == 'LocalDate') {
				jdbcJavaTyp = 'java.sql.Date'
				conv1 = 'conv('
				conv2 = ')'
				convget = 'getDate'
			} else if (javaTyp.simpleName == 'LocalDateTime') {
				jdbcJavaTyp = 'java.sql.Timestamp'
				conv1 = 'conv('
				conv2 = ')'
				convget = 'getTimestamp'
			} else if (javaTyp.simpleName == 'String') {
				jdbcJavaTyp = 'String'
				conv1 = ''
				conv2 = ''
				convget = 'getString'
			} else if (javaTyp.simpleName == 'int') {
				jdbcJavaTyp = 'int'
				conv1 = ''
				conv2 = ''
				convget = 'getInt'
			} else if (javaTyp.simpleName == 'double') {
				jdbcJavaTyp = 'java.math.BigDecimal'
				conv1 = 'conv('
				conv2 = ')'
			} else if (javaTyp.simpleName == 'byte[]') {
				jdbcJavaTyp = 'byte[]'
				conv1 = 'conv('
				conv2 = ')'
				convget = 'getBlob'
			} else {
				jdbcJavaTyp = null
				conv1 = ''
				conv2 = ''
			}
		}
	}

	@Accessors
	static class Vo {
		public String voname
		public MutableClassDeclaration voType
		public String selectFrom
		public String selectGroupBy
		public String selectOrderBy
		public List<Attribute> attribute = new ArrayList<Attribute>
	}

	val static Pattern repNr = Pattern.compile('^Replication-Nr. ([0-9]+) Attribut ([^ \\r]+)')
	val static Pattern repCopy = Pattern.compile('^ReplicationCopy')
	val static Pattern select = Pattern.compile(
		'^SelectFrom: (.+?)(( SelectOrderBy: )(.+?))?(( SelectGroupBy: )(.+?))?$')

	def static doRegisterGlobalsDto(ClassDeclaration c, extension RegisterGlobalsContext context) {

		c.declaredClasses.forEach [
			if (simpleName.startsWith('Vo')) {
				if (simpleName == 'Vo') {
					registerClass(c.dtoKeyName)
					registerClass(c.dtoName)
					registerClass(c.dtoUpdateName)
				} else {
					registerClass(c.voName(simpleName))
				}
			}
		]

	}

	def static Dtos doTransformDto(MutableClassDeclaration c, extension TransformationContext context) {

		val d = new Dtos
		d.tablename = tablename(c)
		if (d.tablename.nn == "") {
			c.addError('Kein Tabellenname mit @Table(name="Tabellenname") angegeben.')
			return null
		}
		if (d.tablename.javaClassName != c.dtoSimpleName) {
			c.
				addError('''Tabellenname («d.tablename») passt nicht zum Repository. Es sollte «d.tablename.javaClassName»Rep heißen.''')
			return null
		}

		val vo = c.declaredClasses.findFirst[a|a.simpleName == 'Vo']
		if (vo === null) {
			c.addError('static class Vo fehlt.')
			return null
		}

		val dtoBaseType = findTypeGlobally(dtoBaseName)
		if (dtoBaseType === null) {
			c.addError('''Klasse «dtoBaseName» fehlt.''')
			return null
		}
		d.serializableType = Serializable.newTypeReference
		d.serviceDaten = findTypeGlobally(serviceDatenName).newTypeReference
		d.longType = long.newTypeReference
		d.dtoBaseType = dtoBaseType.newTypeReference
		if (c.simpleName == 'SoRep') {
			d.insert = false
			d.update = false
			d.delete = false
		} else {
			d.insert = true
			d.update = true
			d.delete = true
		}
		var String repName
		val m = repNr.matcher(vo.docComment)
		if (m.find) {
			d.replicationNr = Integer.parseInt(m.group(1))
			repName = m.group(2).nn
		}
		val replicationName = repName
		// c.addError('''Nr. «d.replicationNr» replicationName: «replicationName»''')
		d.replicationCopy = repCopy.matcher(vo.docComment).matches
		d.uidAbhaengig = d.tablename == 'VM_Buchung' || d.tablename == 'VM_Ereignis' || d.tablename == 'VM_Konto'

		val coa = Column.newTypeReference.type
		val pka = PrimaryKeyJoinColumn.newTypeReference.type
		val ida = Id.newTypeReference.type

		// Attribute und Key-Attribute bestimmen
		vo.declaredFields.forEach [
			var Attribute ka = null
			var a = findAnnotation(coa)
			if (a !== null) {
				ka = new Attribute
				ka.name = a.getStringValue("name").nn
				ka.length = a.getIntValue("length")
				ka.nullable = a.getBooleanValue("nullable")
				ka.javaTyp = type
				ka.updateJdbc
				d.attribute.add(ka)
				if (ka.name == "Mandant_Nr") {
					d.hasMandantNr = true
				} else {
					if (ka.name == "Angelegt_Am" || ka.name == "Angelegt_Von" || ka.name == "Geaendert_Am" ||
						ka.name == "Geaendert_Von") {
						d.revision++
					}
				}
				if (ka.name == replicationName) {
					d.replicationAttr = ka
				}
				a = findAnnotation(pka)
				if (a !== null) {
					d.keyAttribute.add(ka)
					d.replicationPrimaryKey = replicationName == ka.name
				} else {
					a = findAnnotation(ida)
					if (a !== null) {
						d.keyAttribute.add(ka)
					} else {
						d.notKeyAttribute.add(ka)
					}
				}
			}
		]

		d.attribute.forEach [a|
			if (a.name != "Mandant_Nr" && (a.name != replicationName || d.replicationPrimaryKey)) {
				d.iuAttribute.add(a)
			}
		]
		
		if (d.revision < 4) {
			d.revision = 0
		}

		c.declaredClasses.forEach [
			if (simpleName.startsWith('Vo') && simpleName != 'Vo') {
				val v = new Vo
				var dc = docComment.replace("\r\n", " ").replace("\r", " ").replace("\n", " ")
				val mm = select.matcher(dc)
				if (mm.find) {
					v.selectFrom = mm.group(1)
					v.selectOrderBy = mm.group(4)
					v.selectGroupBy = mm.group(7)
				} else {
					v.selectFrom = dc
				}
				v.voname = simpleName.ohneVo.toFirstUpper
				v.voType = findClass(c.voName(simpleName))
				declaredFields.forEach [
					var a = findAnnotation(coa)
					var ka = new Attribute
					val att = d.attribute.findFirst[x|x.attName == simpleName]
					if (a !== null) {
						if (att === null) {
							ka.name = simpleName.toFirstUpper
							ka.length = a.getIntValue("length")
							ka.nullable = a.getBooleanValue("nullable")
							ka.javaTyp = type
							ka.updateJdbc
						} else {
							ka.name = att.attName
							ka.length = att.length
							ka.nullable = att.nullable
							ka.javaTyp = att.javaTyp
							ka.jdbcJavaTyp = att.jdbcJavaTyp
							ka.conv1 = att.conv1
							ka.conv2 = att.conv2
							ka.convget = att.convget
						}
						ka.selectString = a.getStringValue("name").nn
						ka.namenbehalten = true
						v.attribute.add(ka)
					}
				]
				d.vos.add(v)
			}
		]

		if (d.replicationNr > 0) {
			c.addField('REP_NR') [
				docComment = '''Replikationsnummer.'''
				type = int.newTypeReference
				initializer = ['''«d.replicationNr»''']
			]
		}

		c.dtoKey(context, d)
		c.dto(context, d)
		c.dtoUpdate(context, d)
		c.dtoVo(context, d)

		return d
	}

	// DTO-VO
	def static void dtoVo(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		d.vos.forEach [
			voType.docComment = '''Generiertes Data Transfer Object für Tabelle «d.tablename».'''
			voType.extendedClass = d.dtoBaseType
			voType.fragmentAttributeBeanList(context, attribute)
			voType.fragmentGetCloneVo(context, it)
		]
//		// d.dtoType.primarySourceElement = c
//		d.dtoType.fragmentSerialVersionUID(context)
//		d.dtoType.fragmentAttributeTypLaengeList(context, d.notKeyAttribute)
//		d.dtoType.fragmentAttributeNameList(context, d.notKeyAttribute)
//		d.dtoType.fragmentGetPk(context, d)
//		d.dtoType.fragmentAttributeBeanList(context, d.notKeyAttribute)
	}

	// DTO-Key
	def static void dtoKey(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		d.dtoKeyType = findClass(c.dtoKeyName)
		d.dtoKeyType.extendedClass = d.dtoBaseType
		d.dtoKeyType.implementedInterfaces = c.implementedInterfaces + #[d.serializableType]
		d.dtoKeyType.docComment = '''Generiertes Data Transfer Object für Primärschlüssel der Tabelle «d.tablename».'''
		// d.dtoKeyType.primarySourceElement = c
		d.dtoKeyType.fragmentSerialVersionUID(context)
		d.dtoKeyType.addField('TAB_NAME') [
			type = String.newTypeReference
			initializer = ['''"«d.tablename»"''']
			docComment = '''Name der Spalte «d.tablename».'''
			visibility = Visibility.PUBLIC
			final = true
			static = true
		]

		d.dtoKeyType.fragmentAttributeTypLaengeList(context, d.keyAttribute)
		d.dtoKeyType.fragmentAttributeNameList(context, d.keyAttribute)
		d.dtoKeyType.addConstructor() [
			docComment = '''Standard-Konstruktor.'''
			body = ['''''']
		]
		if (d.keyAttribute.size > 0) {
			d.dtoKeyType.addConstructor() [
				docComment = '''Konstruktor mit Initialisierung.'''
				for (a : d.keyAttribute) {
					addParameter(a.attName, a.javaTyp)
				}
				body = [
					'''
					«FOR a : d.keyAttribute»
						this.«a.attName» = «a.attName»;
					«ENDFOR»'''
				]
			]
		}
		d.dtoKeyType.fragmentAttributeBeanList(context, d.keyAttribute)
	}

	// DTO
	def static void dto(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		d.dtoType = findClass(c.dtoName)
		d.dtoType.extendedClass = d.dtoKeyType.newTypeReference
		d.dtoType.docComment = '''Generiertes Data Transfer Object für Tabelle «d.tablename».'''
		// d.dtoType.primarySourceElement = c
		d.dtoType.fragmentSerialVersionUID(context)
		d.dtoType.fragmentAttributeTypLaengeList(context, d.notKeyAttribute)
		d.dtoType.fragmentAttributeNameList(context, d.notKeyAttribute)
		d.dtoType.fragmentGetPk(context, d)
		d.dtoType.fragmentGetClone(context, d)
		d.dtoType.fragmentAttributeBeanList(context, d.notKeyAttribute)
	}

	def static void dtoUpdate(MutableClassDeclaration c, extension TransformationContext context, Dtos d) {

		d.dtoUpdateType = findClass(c.dtoUpdateName)
		d.dtoUpdateType.extendedClass = d.dtoBaseType
		d.dtoUpdateType.implementedInterfaces = c.implementedInterfaces + #[d.serializableType]
		d.dtoUpdateType.fragmentSerialVersionUID(context)
		d.dtoUpdateType.addConstructor() [
			docComment = '''
			Konstruktor mit Initialisierung.
			@param dto DTO-Instanz.'''
			addParameter("dto", d.dtoType.newTypeReference)
			body = [
				'''
					«d.dtoType.newTypeReference» c = dto.getClone();
					setReplikation(dto.isReplikation());
					«FOR a : d.attribute»
						«IF a.javaTyp.simpleName == "double"»
							«a.attName»Old = rundeBetrag4(c.«a.getterName»());
						«ELSEIF a.javaTyp.simpleName == "byte[]" && a.javaTyp.array»
							«a.attName»Old = clone(c.«a.getterName»());
						«ELSE»
							«a.attName»Old = c.«a.getterName»();
						«ENDIF»
						«a.attName»New = «a.attName»Old;
					«ENDFOR»
				'''
			]
		]
		d.dtoUpdateType.fragmentGetCloneUpdate(context, d, false)
		d.dtoUpdateType.fragmentGetCloneUpdate(context, d, true)
		d.dtoUpdateType.fragmentGetCloneDtoUpdate(context, d)
		d.dtoUpdateType.fragmentAttributeBeanListUpdate(context, d)
//        d.dtoUpdateType.fragmentToBufferUpdate(x.members, e.attribute)
		d.dtoUpdateType.addMethod("isChanged") [
			returnType = boolean.newTypeReference
			docComment = '''
			Hat sich irgendeine Spalte geändert?
			@return true, wenn sich irgendeine Spalte geändert hat.'''
			body = [
				'''return «IF d.attribute.size<=0»false«ELSE»«FOR a : d.attribute SEPARATOR " || "»«a.attName»Changed«ENDFOR»«ENDIF»;'''
			]
		]
	}

	def private static String tablename(ClassDeclaration c) { // , extension TypeReferenceProvider context) {
	// val t = c.findAnnotation(Table.newTypeReference.type)
		val t = c.annotations.findFirst[a|a.annotationTypeDeclaration.simpleName == 'Table']
		if (t === null) {
			return "" // c.simpleName
		}
		val name = t.getValue("name").toString.nn
		if (name == "") {
			return "" // c.simpleName
		}
		return name
	}
}

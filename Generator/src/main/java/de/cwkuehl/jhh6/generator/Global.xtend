package de.cwkuehl.jhh6.generator

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.file.Path

public class Global {

	public var static copyGenFiles = false
	public val static genComment = "Generierte Datei. BITTE NICHT AENDERN!"
	// val static anwendungPackage = "de.cwkuehl.jhh6.app"
	val static schnittstellePackage = "de.cwkuehl.jhh6.api"
	val static schnittstelleServicePackage = schnittstellePackage + ".service"
	val static schnittstelleDtoPackage = schnittstellePackage + ".dto"
	val static repPackage = "de.cwkuehl.jhh6.server.rep"
	val static serverPackage = "de.cwkuehl.jhh6.server"

	def static String serviceInterfaceName(String simpleName) {
		return schnittstelleServicePackage + '.I' + simpleName.toFirstUpper
	}

	def static String serviceInterfaceName(ClassDeclaration e) {
		return e.simpleName.serviceInterfaceName
	}

	def static Path serviceInterfaceJava(Path pf, ClassDeclaration e) {
		val f = pf.append("src/main/xtend-gen").append(schnittstelleServicePackage.replace('.', '/')).append(
			"I" + e.simpleName.toFirstUpper + ".java")
		return f
	}

	def static Path serviceInterfacePfad(Path pf) {
		val f = pf.append("src/main/java").append(schnittstelleServicePackage.replace('.', '/'))
		return f
	}

	def static String serviceBaseName(ClassDeclaration e) {
		return e.qualifiedName + "Base"
	}

	def static String serviceDatenName() {
		return schnittstelleServicePackage + '.ServiceDaten'
	}

	def static String serviceContainerName() {
		return serverPackage + ".base.ServiceBase"
	}

	def static String serviceFactoryName() {
		return serverPackage + ".FactoryService"
	}

	def static String repBaseName() {
		return serverPackage + ".base.RepositoryBase"
	}

	def static String sqlBuilderName() {
		return serverPackage + ".base.SqlBuilder"
	}

	def static String rbListeName() {
		return schnittstellePackage + ".rollback.RollbackListe"
	}

	def static String repInterfaceName(String simpleName) {
		return repPackage + '.I' + simpleName.toFirstUpper
	}

	def static String repInterfaceName(ClassDeclaration e) {
		return e.simpleName.repInterfaceName
	}

	def static String dtoBaseName() {
		return schnittstelleDtoPackage + ".base.DtoBase"
	}

	def static String dtoKeyName(ClassDeclaration e) {
		return '''«schnittstelleDtoPackage».«e.simpleName.ohneRep.toFirstUpper»Key'''
	}

	def static String dtoName(ClassDeclaration e) {
		return '''«schnittstelleDtoPackage».«e.simpleName.ohneRep.toFirstUpper»'''
	}

	def static String dtoUpdateName(ClassDeclaration e) {
		return '''«schnittstelleDtoPackage».«e.simpleName.ohneRep.toFirstUpper»Update'''
	}

	def static String voName(ClassDeclaration e, String simpleName) {
		return '''«e.dtoName»«simpleName.ohneVo.toFirstUpper»'''
	}

	def static String dtoSimpleName(ClassDeclaration e) {
		return '''«e.simpleName.ohneRep.toFirstUpper»'''
	}

	def static String javaName(String name) {
		javaClassName(name).toFirstLower
	}

	def static String getterName(String name) {
		"get" + name.javaName.toFirstUpper
	}

	def static String setterName(String name) {
		"set" + name.javaName.toFirstUpper
	}

	/** Liefert leeren String, wenn null; sonst den String */
	def public static String nn(String s) {
		if (s === null) "" else s
	}

	def private static String ohneRep(String n) {
		if (n === null || n == "") {
			return ""
		}
		if (n.endsWith("Rep")) {
			return n.substring(0, n.length - 3)
		}
		return n
	}

	def public static String ohneVo(String n) {
		if (n === null || n == "") {
			return ""
		}
		if (n.startsWith("Vo")) {
			return n.substring(2)
		}
		return n
	}

	def public static String javaClassName(String n) {
		if (n === null || n == "") {
			return ""
		}
		var name = n
		var StringBuffer str = new StringBuffer
		// if (isJetName(name)) {
		// name = name.substring(1, name.length() - 1)
		// }
		var String[] array = name.split("_|-");
		if (array.size <= 1) {
			// 20.03.11 WK: Entity mit JavaClassName ohne _
			str.append(name.substring(0, 1).toUpperCase)
			str.append(name.substring(1).toLowerCase)
			return str.toString
		}
		for (int i : 0 .. array.size - 1) {
			str.append(array.get(i).substring(0, 1).toUpperCase)
			str.append(array.get(i).substring(1).toLowerCase)
		}
		return str.toString
	}

	def public static String typLaengeName(String n) {
		var name = n
		var StringBuffer str = new StringBuffer
		// if (isJetName(name)) {
		// name = name.substring(1, name.length() - 1);
		// }
		var String[] array = name.split("_|-")
		for (int i : 0 .. array.size - 1) {
			if (i > 0) {
				str.append("_")
			}
			str.append(array.get(i).toUpperCase)
		}
		str.append("_LAENGE")
		return str.toString
	}

	def public static String attNameName(String n) {
		var name = n
		var StringBuffer str = new StringBuffer
		var String[] array = name.split("_|-")
		for (int i : 0 .. array.size - 1) {
			if (i > 0) {
				str.append("_")
			}
			str.append(array.get(i).toUpperCase)
		}
		str.append("_NAME")
		return str.toString
	}

	def public static <T> indexed(Iterable<T> list) {
		var List<ListItem<T>> result = newArrayList
		val lastIndex = list.size - 1
		var currentIndex = 0

		for (item : list) {
			result += new ListItem<T>(
				item,
				currentIndex,
				currentIndex + 1,
				currentIndex == 0,
				currentIndex == lastIndex
			)
			currentIndex = currentIndex + 1
		}

		return result
	}

}

@Accessors
public class ListItem<T> {

	public new(T v, int index, int index1, boolean isFirst, boolean isLast) {

		this.v = v
		this.index = index
		this.index1 = index1
		this.isFirst = isFirst
		this.isLast = isLast
	}

	T v
	int index
	int index1
	boolean isFirst
	boolean isLast
}

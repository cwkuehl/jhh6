package de.cwkuehl.jhh6.generator

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static de.cwkuehl.jhh6.generator.Global.*
import static de.cwkuehl.jhh6.generator.MachDto.*
import static de.cwkuehl.jhh6.generator.MachRep.*

@Target(ElementType.TYPE)
@Active(RepositoryProcessor)
annotation Repository {
}

@Target(ElementType.FIELD)
// @Active(RepositoryProcessor)
annotation RepositoryRef {
}

class RepositoryProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration c, extension RegisterGlobalsContext context) {

		doRegisterGlobalsDto(c, context)
		doRegisterGlobalsRep(c, context)
		// val xx = (c.qualifiedName + '.' + "Entityx").findSourceClass
		// if (xx == null) {
		// return
		// }
	}

	override doTransform(MutableClassDeclaration c, extension TransformationContext context) {

		val dtos = doTransformDto(c, context)
		if (dtos === null) {
			return
		}
		doTransformRep(c, context, dtos)
		
		// val xx = (c.qualifiedName + '.' + "Entityx").findClass
		// if (xx == null) {
		// return
		// }
		// for (p : xx.declaredFields) {
		// p.remove
		// }
	}

	override doGenerateCode(List<? extends ClassDeclaration> annotatedSourceElements,
		extension CodeGenerationContext context) {

		if (!copyGenFiles) {
			return
		}
		// Kopieren der Dateien ins Projekt Schnittstelle
		for (clazz : annotatedSourceElements) {
			val filePath = clazz.compilationUnit.filePath
			// val file = filePath.targetFolder.append(clazz.qualifiedName.replace('.', '/') + ".properties")
			val q = Global.serviceInterfaceJava(filePath.projectFolder, clazz)
			val z = Global.serviceInterfacePfad(filePath.projectFolder).append(q.lastSegment)
			z.contents = '''«q.contents»'''
		// q.delete
		}
	}

}

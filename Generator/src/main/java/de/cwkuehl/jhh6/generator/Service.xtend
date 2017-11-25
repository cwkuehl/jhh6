package de.cwkuehl.jhh6.generator

import de.cwkuehl.jhh6.generator.annotation.Inject
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

import static de.cwkuehl.jhh6.generator.SignaturHelper.*

import static extension de.cwkuehl.jhh6.generator.Global.*

@Target(ElementType.TYPE)
@Active(ServiceProcessor)
annotation Service {
	String value = 'nix'
}

@Target(ElementType.FIELD)
// @Active(ServiceProcessor)
annotation ServiceRef {
}

@Target(ElementType.METHOD)
annotation Transaction {
	boolean value = true
}

class ServiceProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(List<? extends ClassDeclaration> annotatedClasses,
		extension RegisterGlobalsContext context) {

		// try {
		// registerClass(serviceFactoryName)
		// factory = true
		// } catch (Exception ex) {
		// factory = false
		// }
		for (ClassDeclaration annotatedClass : annotatedClasses) {
			doRegisterGlobals(annotatedClass, context);
		}
	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {

		registerInterface(annotatedClass.serviceInterfaceName)
		registerClass(annotatedClass.serviceBaseName)
	}

	override doTransform(List<? extends MutableClassDeclaration> annotatedClasses,
		extension TransformationContext context) {

		annotatedClasses.forEach [
			doTransform(context)
		]
	}

	override doTransform(MutableClassDeclaration c, extension TransformationContext context) {

		// Service-Base
		val baseType = findClass(c.serviceBaseName)
		var base2Type = findTypeGlobally(serviceContainerName).newTypeReference
		baseType.primarySourceElement = c
		baseType.docComment = genComment // + ' ' + annotatedClass.serviceBaseName
		baseType.extendedClass = base2Type

		// Service-Interface
		val interfaceType = findInterface(c.serviceInterfaceName)
		interfaceType.primarySourceElement = c
		// add the interface to the list of implemented interfaces
		c.implementedInterfaces = c.implementedInterfaces + #[interfaceType.newTypeReference]
		c.extendedClass = baseType.newTypeReference

		for (method : c.declaredMethods) {

			// Öffentliche Methode mit Transaktion versehen
			if (method.visibility == Visibility.PUBLIC && !method.static) {

				if (method.parameters.length <= 0 || method.parameters.get(0).type.name != serviceDatenName) {
					method.addError("Die Service-Funktion braucht einen ersten Parameter vom Typ ServiceDaten.")
				} else {
					interfaceType.addMethod(method.simpleName) [
						if (method.docComment !== null) {
							docComment = method.docComment
						}
						returnType = method.returnType
						// addParameter("daten", ServiceDaten.newTypeReference)
						for (p : method.parameters) {
							addParameter(p.simpleName, p.type)
						}
						exceptions = method.exceptions
						primarySourceElement = method
					]
					val tx = method.findAnnotation(Transaction.newTypeReference.type)
					val tr = tx !== null && tx.getBooleanValue('value') == true
					val params = method.
						parameters
					val StringConcatenationClient b = '''
						
							«IF !method.returnType.void»«method.returnType» r = «IF method.returnType.primitive»«IF method.returnType.toString=='boolean'»false«ELSE»0«ENDIF»«ELSE»null«ENDIF»;«ENDIF»
							«IF tr»boolean commit = false;«ENDIF»
							init(«method.parameters.get(0).simpleName», «IF tr»true«ELSE»false«ENDIF»);
							try {
								«IF !method.returnType.void»r = «ENDIF»«method.simpleName»Ot(«params.map[simpleName].join(", ")»);
								«IF tr»commit = true;«ENDIF»
							} catch (Throwable ex) {
								«IF method.returnType.simpleName.startsWith('ServiceErgebnis')»r = new «method.returnType»(«IF method.returnType.actualTypeArguments.get(0).simpleName=='Boolean'»false«ENDIF»);«ENDIF»
								handleException(«method.parameters.get(0).simpleName», ex«IF method.returnType.simpleName.startsWith('ServiceErgebnis')», r«ENDIF»);
							} finally {
								exit(«method.parameters.get(0).simpleName», «IF tr»commit«ELSE»true«ENDIF»);
							}
							«IF !method.returnType.void»return r;«ENDIF»
					'''
					addIndirection(baseType, method, method.simpleName + 'Ot', b, context)
				}
			}

			// Sonstige nicht öffentliche Methoden in die Basis verschieben.
			if ((method.visibility == Visibility.PRIVATE || method.visibility == Visibility.PROTECTED) &&
				!method.static) {
				addIndirection(baseType, method, method.simpleName, null, context)
				method.remove
			}
		}

		val ina = typeof(Inject)
		val sr = ServiceRef.newTypeReference.type
		val rr = RepositoryRef.newTypeReference.type
		for (field : c.declaredFields) {
			var a = field.findAnnotation(sr)
			if (a !== null) {
				val iftype = field.type.simpleName.serviceInterfaceName.newTypeReference
				baseType.addField(field.simpleName) [
					docComment = '''Service-Referenz «field.simpleName».'''
					visibility = Visibility.PROTECTED
					type = iftype
				]
				baseType.addMethod("set" + field.simpleName.toFirstUpper) [
					addAnnotation(ina.newAnnotationReference)
					returnType = typeof(void).newTypeReference
					docComment = '''Setzen der Service-Referenz «field.simpleName».'''
					addParameter("v", iftype)
					body = ['''this.«field.simpleName» = v;''']
				]
				field.remove
			} else {
				a = field.findAnnotation(rr)
				if (a !== null) {
					val iftype = field.type.simpleName.repInterfaceName.newTypeReference
					baseType.addField(field.simpleName) [
						docComment = '''Repository-Referenz «field.simpleName».'''
						visibility = Visibility.PROTECTED
						type = iftype
					]
					baseType.addMethod("set" + field.simpleName.toFirstUpper) [
						addAnnotation(ina.newAnnotationReference)
						returnType = findTypeGlobally(typeof(void)).newTypeReference
						docComment = '''Setzen der Repository-Referenz «field.simpleName».'''
						addParameter("v", iftype)
						body = ['''this.«field.simpleName» = v;''']
					]
					field.remove
				} else {
					// Sonstige nicht öffentliche Felder in die Basis verschieben.
					if ((field.visibility == Visibility.PRIVATE || field.visibility == Visibility.PROTECTED) &&
						!field.static) {
						addIndirection(baseType, field, field.simpleName, null, context)
						field.remove
					}
				}
			}
		}
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

class TransactionProcessor implements TransformationParticipant<MutableMethodDeclaration> {

	override doTransform(List<? extends MutableMethodDeclaration> methods, extension TransformationContext context) {
//		methods.forEach [
//			val StringConcatenationClient b = '''return null;'''
//			addIndirection(it.declaringType, it, simpleName + 'Ot', b, context)
//		]
	}

}

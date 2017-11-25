package de.cwkuehl.jhh6.generator

import com.google.common.annotations.Beta
import com.google.common.collect.Maps
import java.util.Map
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedMethod
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

/**
 * Helps you with copying signatures of existing methods.
 * 
 * You should use this as an extension for maximum convenience, e.g.:
 * 
 * <pre>
 * override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
 *	val extension transformations = new CommonTransformations(context)
 *	...
 * }
 * </pre>
 */
@Beta
//@FinalFieldsConstructor
class SignaturHelper {

	/**
	 * Moves the body of this method to a new private method with the given name.
	 * The original method then gets the newly specified body which can delegate to the inner method.
	 * @return the new inner method.
	 */
	def static addIndirection(MutableTypeDeclaration parent, MutableMethodDeclaration wrapper, String innerMethodName, StringConcatenationClient indirection, extension TransformationContext context) {

		val inner = createInnerMethod(parent, wrapper, innerMethodName, context)
		if (indirection !== null)
			wrapper.body = indirection
		inner
	}

	private def static createInnerMethod(MutableTypeDeclaration parent, MutableMethodDeclaration wrapper, String innerMethodName, extension TransformationContext context) {

		parent.addMethod(innerMethodName) [
			val resolvedMethod = wrapper.declaringType.newSelfTypeReference.declaredResolvedMethods.findFirst[declaration == wrapper]
			copySignatureFrom(resolvedMethod, context)
			visibility = Visibility.PROTECTED
			body = wrapper.body
			// primarySourceElement = wrapper
		]
	}
	
	/**
	 * Copies the fully resolved signature from the source to this method, including type parameter resolution
	 */
	def static copySignatureFrom(MutableMethodDeclaration it, ResolvedMethod source, extension TransformationContext context) {
		copySignatureFrom(it, source, #{}, context)
	}

	/**
	 * Copies the fully resolved signature from the source to this method, including type parameter resolution. 
	 * The class-level type parameters assign each type parameter in the target method to a type parameter in the source method.
	 */
	def static copySignatureFrom(MutableMethodDeclaration it, ResolvedMethod source, Map<TypeReference, TypeReference> classTypeParameterMappings,
		extension TransformationContext context) {
		abstract = source.declaration.abstract
		deprecated = source.declaration.deprecated
		^default = source.declaration.^default
		docComment = source.declaration.docComment
		final = source.declaration.final
		native = source.declaration.native
		static = source.declaration.static
		strictFloatingPoint = source.declaration.strictFloatingPoint
		synchronized = source.declaration.synchronized
		varArgs = source.declaration.varArgs
		visibility = source.declaration.visibility

		val typeParameterMappings = Maps.newHashMap(classTypeParameterMappings)
		source.resolvedTypeParameters.forEach [ param |
			val copy = addTypeParameter(param.declaration.simpleName, param.resolvedUpperBounds)
			typeParameterMappings.put(param.declaration.newTypeReference, copy.newTypeReference)
			copy.upperBounds = copy.upperBounds.map[replace(typeParameterMappings, context)]
		]
		exceptions = source.resolvedExceptionTypes.map[replace(typeParameterMappings, context)]
		returnType = source.resolvedReturnType.replace(typeParameterMappings, context)
		source.resolvedParameters.forEach [ p |
			val addedParam = addParameter(p.declaration.simpleName, p.resolvedType.replace(typeParameterMappings, context))
			p.declaration.annotations.forEach[addedParam.addAnnotation(it)]
		]
	}

	private def static TypeReference replace(TypeReference target,
		Map<? extends TypeReference, ? extends TypeReference> mappings, extension TransformationContext context) {
		mappings.entrySet.fold(target)[result, mapping|result.replace(mapping.key, mapping.value, context)]
	}

	private def static TypeReference replace(TypeReference target, TypeReference oldType, TypeReference newType,
		extension TransformationContext context) {
		if (target == oldType)
			return newType
		if (!target.actualTypeArguments.isEmpty)
			return newTypeReference(target.type, target.actualTypeArguments.map[replace(oldType, newType, context)])
		if (target.wildCard) {
			if (target.upperBound != object)
				return target.upperBound.replace(oldType, newType, context).newWildcardTypeReference
			else if (!target.lowerBound.isAnyType)
				return target.lowerBound.replace(oldType, newType, context).newWildcardTypeReferenceWithLowerBound
		}
		if(target.isArray)
			return target.arrayComponentType.replace(oldType, newType, context).newArrayTypeReference
		return target
	}

	def static addIndirection(MutableTypeDeclaration parent, MutableFieldDeclaration wrapper, String fieldName, StringConcatenationClient indirection, extension TransformationContext context) {

		val inner = createInnerField(parent, wrapper, fieldName, context)
		if (indirection !== null)
			wrapper.initializer = indirection
		inner
	}

	private def static createInnerField(MutableTypeDeclaration parent, MutableFieldDeclaration wrapper, String fieldName, extension TransformationContext context) {

		parent.addField(fieldName) [
			//val resolvedMethod = wrapper.declaringType.newSelfTypeReference.ge.findFirst[declaration == wrapper]
			//copySignatureFrom(resolvedMethod, context)
			visibility = Visibility.PROTECTED
			initializer = wrapper.initializer
			// primarySourceElement = wrapper
		]
	}
	
}

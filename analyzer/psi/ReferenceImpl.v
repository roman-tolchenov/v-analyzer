module psi

import analyzer.psi.types

pub struct ReferenceImpl {
	element   ReferenceExpressionBase
	file      &PsiFileImpl
	for_types bool
}

pub fn new_reference(file &PsiFileImpl, element ReferenceExpressionBase, for_types bool) &ReferenceImpl {
	return &ReferenceImpl{
		element: element
		file: file
		for_types: for_types
	}
}

fn (r &ReferenceImpl) element() PsiElement {
	return r.element as PsiElement
}

fn (r &ReferenceImpl) resolve() ?PsiElement {
	sub := SubResolver{
		containing_file: r.file
		element: r.element
	}
	mut processor := ResolveProcessor{
		containing_file: r.file
		ref: r.element
	}
	sub.process_resolve_variants(mut processor)

	if processor.result.len > 0 {
		return processor.result.first()
	}
	return none
}

struct SubResolver {
	containing_file &PsiFileImpl
	element         ReferenceExpressionBase
}

fn (r &SubResolver) element() PsiElement {
	return r.element as PsiElement
}

pub fn (r &SubResolver) process_resolve_variants(mut processor ResolveProcessor) bool {
	return if qualifier := r.element.qualifier() {
		r.process_qualifier_expression(qualifier, mut processor)
	} else {
		r.process_unqualified_resolve(mut processor)
	}
}

pub fn (r &SubResolver) process_qualifier_expression(qualifier PsiElement, mut processor ResolveProcessor) bool {
	if qualifier is PsiTypedElement {
		typ := qualifier.get_type()
		if typ !is types.UnknownType {
			r.process_type(typ, mut processor)
		}
	}

	return true
}

pub fn (r &SubResolver) process_type(typ types.Type, mut processor ResolveProcessor) bool {
	if typ is types.StructType {
		if struct_ := r.find_struct(stubs_index, typ.name()) {
			for field in struct_.fields() {
				if !processor.execute(field) {
					return false
				}
			}
		}
	}
	return true
}

pub fn (r &SubResolver) process_unqualified_resolve(mut processor ResolveProcessor) bool {
	if parent := r.element().parent() {
		if parent is FieldName {
			return r.process_type_initializer_field(mut processor)
		}
	}

	if !r.process_block(mut processor) {
		return false
	}
	if !r.process_file(mut processor) {
		return false
	}

	element := r.element()
	if element is PsiNamedElement {
		if func := r.find_function(stubs_index, element.name()) {
			if !processor.execute(func) {
				return false
			}
		}

		if struct_ := r.find_struct(stubs_index, element.name()) {
			if !processor.execute(struct_) {
				return false
			}
		}

		if constant := r.find_constant(stubs_index, element.name()) {
			if !processor.execute(constant) {
				return false
			}
		}
	}

	return true
}

pub fn (r &SubResolver) walk_up(element PsiElement, mut processor ResolveProcessor) bool {
	mut run := element
	for {
		if mut run is Block {
			if !run.process_declarations(mut processor) {
				return false
			}

			if !r.process_parameters(run, mut processor) {
				return false
			}

			if !r.process_receiver(run, mut processor) {
				return false
			}
		}

		run = run.parent() or { break }
	}
	return true
}

pub fn (_ &SubResolver) process_parameters(b Block, mut processor PsiScopeProcessor) bool {
	parent := b.parent() or { return true }

	if parent is SignatureOwner {
		signature := parent.signature() or { return true }

		params := signature.parameters()
		for param in params {
			if !processor.execute(param) {
				return false
			}
		}
	}

	return true
}

pub fn (_ &SubResolver) process_receiver(b Block, mut processor PsiScopeProcessor) bool {
	parent := b.parent() or { return true }

	if parent is FunctionOrMethodDeclaration {
		receiver := parent.receiver() or { return true }
		if !processor.execute(receiver) {
			return false
		}
	}

	return true
}

pub fn (r &SubResolver) process_block(mut processor ResolveProcessor) bool {
	mut delegate := ResolveProcessor{
		...processor
	}
	r.walk_up(r.element as PsiElement, mut delegate)

	if delegate.result.len == 0 {
		return true
	}

	for result in delegate.result {
		processor.result << result
	}

	return false
}

pub fn (r &SubResolver) process_file(mut processor ResolveProcessor) bool {
	return r.containing_file.process_declarations(mut processor)
}

pub fn (r &SubResolver) process_type_initializer_field(mut processor ResolveProcessor) bool {
	init_expr := r.element().parent_of_type(.type_initializer) or { return true }
	if init_expr is PsiTypedElement {
		typ := init_expr.get_type()
		if typ is types.StructType {
			if struct_ := r.find_struct(stubs_index, typ.name()) {
				fields := struct_.fields()
				for field in fields {
					if !processor.execute(field) {
						return false
					}
				}
			}
		}
	}

	return true
}

pub fn (_ &SubResolver) find_function(stubs_index StubIndex, name string) ?&FunctionOrMethodDeclaration {
	found := stubs_index.get_elements(.functions, name)
	if found.len != 0 {
		first := found.first()
		if first is FunctionOrMethodDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_struct(stubs_index StubIndex, name string) ?&StructDeclaration {
	found := stubs_index.get_elements(.structs, name)
	if found.len != 0 {
		first := found.first()
		if first is StructDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_constant(stubs_index StubIndex, name string) ?&ConstantDefinition {
	found := stubs_index.get_elements(.constants, name)
	if found.len != 0 {
		first := found.first()
		if first is ConstantDefinition {
			return first
		}
	}
	return none
}

pub struct ResolveProcessor {
	containing_file &PsiFileImpl
	ref             ReferenceExpressionBase
mut:
	result []PsiElement
}

fn (mut r ResolveProcessor) execute(element PsiElement) bool {
	if element.is_equal(r.ref as PsiElement) {
		r.result << element
		return false
	}
	if element is PsiNamedElement {
		name := element.name()
		ref_name := r.ref.name()
		if name == ref_name {
			r.result << element as PsiElement
			return false
		}
	}
	return true
}

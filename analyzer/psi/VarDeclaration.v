module psi

pub struct VarDeclaration {
	PsiElementImpl
}

fn (v VarDeclaration) index_of(def VarDefinition) int {
	first_child := v.first_child() or { return -1 }
	defs := first_child.children().filter(it is VarDefinition)
	for i, definition in defs {
		if definition.is_equal(def) {
			return i
		}
	}
	return -1
}

fn (v VarDeclaration) initializer_of(def VarDefinition) ?Expression {
	index := v.index_of(def)
	if index == -1 {
		return none
	}

	expressions := v.expressions()
	if index >= expressions.len {
		return none
	}

	return expressions[index]
}

fn (v VarDeclaration) vars() []PsiElement {
	first_child := v.first_child() or { return [] }
	return first_child
		.children()
		.filter(it is VarDefinition || it is MutExpression)
		.map(fn (it PsiElement) PsiElement {
			if it is MutExpression {
				return it.last_child() or { return it }
			}
			return it
		})
}

fn (v VarDeclaration) expressions() []Expression {
	last_child := v.last_child() or { return [] }
	return last_child
		.children()
		.filter(it is Expression)
		.map(it as Expression)
}

[translated]
module psi

__global psi_counter = 0

pub fn create_element(node AstNode, containing_file &PsiFileImpl) PsiElement {
	base_node := new_psi_node(psi_counter++, containing_file, node)
	if node.type_name == .module_clause {
		return ModuleClause{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .identifier {
		return Identifier{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .selector_expression {
		return SelectorExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .reference_expression {
		if parent := node.parent_nth(2) {
			if parent.type_name == .var_declaration {
				return VarDefinition{
					PsiElementImpl: base_node
				}
			}
		}
		return ReferenceExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .type_reference_expression {
		return TypeReferenceExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .type_declaration {
		return TypeAliasDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .type_initializer {
		return TypeInitializer{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .field_name {
		return FieldName{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .function_declaration {
		return FunctionDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .struct_declaration {
		return StructDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .var_declaration {
		return VarDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .block {
		return Block{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .mutable_expression {
		return MutExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .signature {
		return Signature{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .literal {
		return Literal{
			PsiElementImpl: base_node
		}
	}

	return base_node
}

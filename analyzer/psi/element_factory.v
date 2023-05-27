[translated]
module psi

__global psi_counter = 0

pub fn create_element(node AstNode, containing_file &PsiFileImpl) PsiElement {
	base_node := new_psi_node(psi_counter, containing_file, node)
	psi_counter++

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

	if node.type_name == .plain_type {
		return PlainType{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .selector_expression {
		return SelectorExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .for_statement {
		return ForStatement{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .call_expression {
		return CallExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .argument {
		return Argument{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .index_expression {
		return IndexExpression{
			PsiElementImpl: base_node
		}
	}

	var := node_to_var_definition(node, containing_file, base_node)
	if !isnil(var) {
		return var
	}

	if node.type_name == .reference_expression {
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
		return FunctionOrMethodDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .receiver {
		return Receiver{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .struct_declaration {
		return StructDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .enum_declaration {
		return EnumDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .struct_field_declaration {
		return FieldDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .struct_field_scope {
		return StructFieldScope{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .enum_field_definition {
		return EnumFieldDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .const_declaration {
		return ConstantDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .const_definition {
		return ConstantDefinition{
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

	if node.type_name == .parameter_list {
		return ParameterList{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .parameter_declaration {
		return ParameterDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .literal {
		return Literal{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .comment {
		return Comment{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .mutability_modifiers {
		return MutabilityModifiers{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .visibility_modifiers {
		return VisibilityModifiers{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .attributes {
		return Attributes{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .attribute {
		return Attribute{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .attribute_expression {
		return AttributeExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .value_attribute {
		return ValueAttribute{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .range {
		return Range{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .interpreted_string_literal {
		return StringLiteral{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .unsafe_expression {
		return UnsafeExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .array_creation {
		return ArrayCreation{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .fixed_array_creation {
		return ArrayCreation{
			PsiElementImpl: base_node
			is_fixed: true
		}
	}

	if node.type_name == .map_init_expression {
		return MapInitExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .map_keyed_element {
		return MapKeyedElement{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .function_literal {
		return FunctionLiteral{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .if_expression {
		return IfExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .compile_time_if_expression {
		return CompileTimeIfExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .match_expression {
		return MatchExpression{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_spec {
		return ImportSpec{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .qualified_type {
		return QualifiedType{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_list {
		return ImportList{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_declaration {
		return ImportDeclaration{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_path {
		return ImportPath{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_name {
		return ImportName{
			PsiElementImpl: base_node
		}
	}

	if node.type_name == .import_alias {
		return ImportAlias{
			PsiElementImpl: base_node
		}
	}

	return base_node
}

[inline]
pub fn node_to_var_definition(node AstNode, containing_file &PsiFileImpl, base_node ?PsiElementImpl) &VarDefinition {
	if node.type_name == .var_definition {
		return &VarDefinition{
			PsiElementImpl: base_node or { new_psi_node(psi_counter, containing_file, node) }
		}
	}

	if node.type_name == .reference_expression {
		parent := node.parent() or { return unsafe { nil } }
		if parent.type_name != .expression_list && parent.type_name != .mutable_expression {
			return unsafe { nil }
		}

		grand := parent.parent() or { return unsafe { nil } }

		if grand.type_name == .var_declaration {
			return &VarDefinition{
				PsiElementImpl: base_node or { new_psi_node(psi_counter, containing_file, node) }
			}
		}
		if grand_grand := grand.parent() {
			if grand_grand.type_name == .var_declaration && parent.type_name == .mutable_expression {
				return &VarDefinition{
					PsiElementImpl: base_node or {
						new_psi_node(psi_counter, containing_file, node)
					}
				}
			}
		}
	}

	return unsafe { nil }
}

module psi

pub struct IfExpression {
	PsiElementImpl
}

pub fn (n IfExpression) block() ?&Block {
	block := n.find_child_by_type(.block)?
	if block is Block {
		return block
	}
	return none
}

pub fn (n IfExpression) else_branch() ?PsiElement {
	return n.find_child_by_name('else_branch')
}

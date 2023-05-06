module lserver

import lsp
import analyzer.index
import analyzer.psi
import analyzer

pub fn (mut ls LanguageServer) definition(params lsp.TextDocumentPositionParams, mut wr ResponseWriter) ?[]lsp.LocationLink {
	uri := params.text_document.uri.normalize()
	println('definition in ' + uri.str())
	file := ls.get_file(uri) or { return none }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_reference_at(offset) or {
		println('cannot find reference at ' + offset.str())
		return none
	}

	if element is psi.ReferenceExpressionBase {
		resolved := ls.analyzer_instance.resolver.resolve_local(file, element) or {
			println('cannot resolve ' + element.name())
			return none
		}

		data := analyzer.new_resolve_result(resolved.containing_file, resolved)

		return [
			lsp.LocationLink{
				target_uri: 'file://' + data.filepath
				target_range: pos_to_range(data.pos)
				target_selection_range: pos_to_range(data.pos)
			},
		]
	}

	return []
}

fn pos_to_range(pos index.Pos) lsp.Range {
	return lsp.Range{
		start: lsp.Position{
			line: pos.line
			character: pos.column
		}
		end: lsp.Position{
			line: pos.end_line
			character: pos.end_column
		}
	}
}

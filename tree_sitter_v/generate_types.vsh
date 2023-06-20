import json
import strings
import os

// This is a script file which creates static type declarations
// for tree-sitter-v's node types by using the information found
// in 'node-types.json' and turn it into a pseudo-sum type using enums
// and create a `NodeTypeFactory` implementation that will convert type names
// into respective `NodeType` enum.
// Anonymous nodes are automatically identified as `NodeType.unknown`.
//
// See: https://tree-sitter.github.io/tree-sitter/using-parsers#static-node-types

const to_be_escaped = ['none', 'true', 'false', 'map', 'type', 'nil']

fn escape_name(name string) string {
	if name in to_be_escaped {
		return name + '_'
	}
	return name
}

fn write_enum_member(mut wr strings.Builder, type_name string, member_name string) {
	wr.write_string('${type_name}.${escape_name(member_name)}')
}

fn write_enum_array(mut wr strings.Builder, enum_type_name string, list []string) {
	wr.writeln('[')
	for i, name in list {
		wr.write_string('   ')

		// write fully qualified name for enum member only for the first member
		type_name := if i == 0 { enum_type_name } else { '' }
		write_enum_member(mut wr, type_name, name)

		if i < list.len - 1 {
			wr.write_u8(`,`)
		}
		wr.write_u8(`\n`)
	}
	wr.write_u8(`]`)
}

fn write_const_enum_array(mut wr strings.Builder, var_name string, enum_type_name string, list []string) {
	wr.write_string('\nconst ${var_name} = ')
	write_enum_array(mut wr, enum_type_name, list)
	wr.write_u8(`\n`)
}

struct NodeType {
	name     string     [json: 'type']
	named    bool
	subtypes []NodeType
}

fn (typ NodeType) is_anon() bool {
	return !typ.named || typ.name.len == 0 || typ.name[0] == `_`
}

cur_dir := dir(@FILE)
node_types_json := read_file(join_path(cur_dir, 'src', 'node-types.json'))!
node_types := json.decode([]NodeType, node_types_json)!
node_type_enum_name := 'NodeType'
super_type_enum_name := 'SuperType'

file_path := join_path(cur_dir, 'node_types.v')
mut file := open_file(file_path, 'w+')!
mut sb := strings.new_builder(1024 * 1024)
mut supertype_node_groups := map[string][]string{}

sb.writeln('// This is an AUTO-GENERATED file. DO NOT EDIT this file directly! See `generate_types.vsh`')

sb.writeln('module tree_sitter_v')
sb.writeln('\n')
sb.writeln('import arrays { merge }')

// write supertypes
sb.writeln('pub enum ${super_type_enum_name} {')
sb.writeln('   unknown')
for node_type in node_types {
	if !node_type.named || node_type.name.len == 0 || node_type.name[0] != `_`
		|| node_type.subtypes.len == 0 {
		continue
	}
	sb.writeln('   ${escape_name(node_type.name[1..])}')
	supertype_node_groups[node_type.name] = node_type.subtypes.map(it.name)
}
sb.writeln('}\n')

sb.writeln('pub enum ${node_type_enum_name} {')
sb.writeln('   unknown')
sb.writeln('   error')

mut declaration_node_types := []string{cap: 100}
mut identifier_node_types := []string{cap: 100}
mut literal_node_types := []string{cap: 100}

// write node types as enum members
for node_type in node_types {
	if node_type.is_anon() {
		continue
	}

	if node_type.name.ends_with('_declaration') {
		declaration_node_types << node_type.name
	} else if node_type.name == 'identifier' || node_type.name.ends_with('_identifier') {
		identifier_node_types << node_type.name
	} else if node_type.name.ends_with('_literal') {
		literal_node_types << node_type.name
	}

	sb.writeln('   ${escape_name(node_type.name)}')
}
sb.writeln('}')

for supertype_name, supertype_node_types in supertype_node_groups {
	sb.write_string('\n')
	sb.write_string('const supertype_${supertype_name}_nodes = ')
	super_type_members := supertype_node_types.filter(it.starts_with('_'))
	for type_member in super_type_members {
		sb.write_string('merge(supertype_${type_member}_nodes, ')
	}
	write_enum_array(mut sb, node_type_enum_name, supertype_node_types.filter(!it.starts_with('_')))
	sb.writeln(')'.repeat(super_type_members.len))
}

sb.write_string('\n')
sb.write_string('pub fn (typ ${node_type_enum_name}) group() ${super_type_enum_name} {')
sb.write_string('   return ')

supertype_ordered_names := [
	'top_level_declaration',
	'expression',
	'expression_with_blocks',
	'statement',
	'unknown',
]
mut super_type_index := 0
for supertype_name in supertype_ordered_names {
	if super_type_index < supertype_ordered_names.len - 1 {
		sb.write_string('if typ in supertype__${supertype_name}_nodes ')
	}
	sb.write_string('{\n      ')
	write_enum_member(mut sb, super_type_enum_name, supertype_name)
	sb.write_string('\n   }')
	if super_type_index < supertype_ordered_names.len - 1 {
		sb.write_string(' else ')
	} else {
		sb.write_u8(`\n`)
	}
	super_type_index++
}
sb.writeln('}')

// write constants
write_const_enum_array(mut sb, 'declaration_node_types', node_type_enum_name, declaration_node_types)
write_const_enum_array(mut sb, 'identifier_node_types', node_type_enum_name, identifier_node_types)
write_const_enum_array(mut sb, 'literal_node_types', node_type_enum_name, literal_node_types)

sb.writeln('\n')
sb.writeln('pub fn (typ ${node_type_enum_name}) is_declaration() bool { return typ in declaration_node_types }')
sb.writeln('pub fn (typ ${node_type_enum_name}) is_identifier() bool { return typ in identifier_node_types }')
sb.writeln('pub fn (typ ${node_type_enum_name}) is_literal() bool { return typ in literal_node_types }')

// create VNodeTypeFactory
node_type_factory_sym_name := 'VNodeTypeFactory'

sb.writeln('\n')
sb.writeln('pub const type_factory = &${node_type_factory_sym_name}{}')
sb.writeln('\n')
sb.writeln('pub struct ${node_type_factory_sym_name} {}')
sb.writeln('\n')
sb.writeln('pub fn (nf ${node_type_factory_sym_name}) get_type(type_name string) ${node_type_enum_name} {')
sb.writeln('   return tree_sitter_v.node_type_name_to_enum[type_name] or { NodeType.unknown }')
sb.writeln('}')
sb.writeln('\n')
sb.writeln('const node_type_name_to_enum = {')

for node_type in node_types {
	if node_type.is_anon() {
		continue
	}
	sb.write_string("      '${node_type.name}': ")
	write_enum_member(mut sb, node_type_enum_name, node_type.name)
	sb.writeln('')
}
sb.writeln('}')

file.write(sb)!
file.close()

res := os.execute('v fmt -w ${file_path}')
if res.exit_code != 0 {
	panic('v fmt failed:\n\n${res.output}')
}

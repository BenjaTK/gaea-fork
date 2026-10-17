extends GutTest


const NODES_PATH := "res://addons/gaea/runtime/graph_nodes/root/"

var node_paths: Array[String]
var node_resources: Array[GaeaNodeResource]


func before_all() -> void:
	node_paths = _get_nodes_in_folder()
	node_resources = _load_nodes(node_paths)


func _get_nodes_in_folder(folder_path: String = NODES_PATH) -> Array[String]:
	var dir := DirAccess.open(folder_path)
	var array: Array[String] = []

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".gd"):
			file_name = dir.get_next()
			continue

		var file_path = folder_path + file_name
		if dir.current_is_dir():
			array.append_array(_get_nodes_in_folder(file_path + "/"))

		if file_name.ends_with(".gd"):
			array.append(folder_path + file_name)

		file_name = dir.get_next()

	return array


func _load_nodes(paths: Array[String]) -> Array[GaeaNodeResource]:
	var array: Array[GaeaNodeResource]

	for path in paths:
		var script = load(path)
		if script is GDScript and script.is_tool():
			var is_valid_node_resource := false
			var base_script: GDScript = script
			while is_instance_valid(base_script):
				base_script = base_script.get_base_script()
				if base_script == GaeaNodeResource:
					is_valid_node_resource = true
					break

			if is_valid_node_resource:
				var resource: GaeaNodeResource = script.new()
				if resource.is_available():
					for item in resource.get_tree_items():
						array.append(item)
	return array


func _get_node_path(object: Object) -> String:
	if object is Script:
		return object.resource_path.trim_prefix(NODES_PATH)
	return object.get_script().resource_path.trim_prefix(NODES_PATH)


func test_instantiate(path = use_parameters(node_paths)) -> void:
	var script = load(path)
	assert_true(script.can_instantiate(), "Script at %s couldn't compile." % _get_node_path(script))


func test_is_tool(path = use_parameters(node_paths)) -> void:
	var script = load(path)
	assert_true(script.is_tool(), "Script at %s isn't a tool script." % _get_node_path(script))


func test_has_outputs(node = use_parameters(node_resources)) -> void:
	assert_false(node.get_output_ports_list().is_empty(), "Node at [b]%s[/b] has no outputs." % _get_node_path(node))


## Tests that no `GaeaNodeResource`s in the root have an invalid or null type.
func test_null_type(node = use_parameters(node_resources)) -> void:
	var valid_types := GaeaValue.Type.values()

	assert_has(valid_types, node.get_type(), "Type of node at [b]%s[/b] is not a valid type." % _get_node_path(node))
	assert_ne(node.get_type(), GaeaValue.Type.NULL, "Type of node at [b]%s[/b] is null." % _get_node_path(node))

	for argument in node.get_arguments_list():
		assert_has(
			valid_types, node.get_argument_type(argument),
			"Type of argument [b]%s[/b] is not a valid type.\nNode: %s" % [argument, _get_node_path(node)]
		)
		assert_ne(
			node.get_argument_type(argument), GaeaValue.Type.NULL,
			"Type of argument [b]%s[/b] is null.\nNode: %s" % [argument, _get_node_path(node)]
		)

	for output in node.get_output_ports_list():
		assert_has(
			valid_types, node.get_output_port_type(output),
			"Type of output [b]%s[/b] is not a valid type.\nNode: %s" % [output, _get_node_path(node)]
		)
		assert_ne(
			node.get_output_port_type(output), GaeaValue.Type.NULL,
			"Type of output [b]%s[/b] is null.\nNode: %s" % [output, _get_node_path(node)]
		)


## Check that all nodes have descriptions.
func test_has_description(node = use_parameters(node_resources)) -> void:
	assert_false(
		node.get_description().is_empty(),
		"Description of node at [b]%s[/b] is empty." % _get_node_path(node)
	)


## Check that all nodes have a valid scene.
func test_node_scene(node = use_parameters(node_resources)) -> void:
	var scene = node.get_scene()
	assert_true(
		is_instance_valid(scene), "_get_scene at %s returns an invalid instance" % _get_node_path(node)
	)
	assert_is(
		scene, PackedScene, "_get_scene at [b]%s[/b] isn't a PackedScene." % _get_node_path(node)
	)

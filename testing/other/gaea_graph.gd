extends GutTest


const NODE1_ID = 1

@onready var walker_graph: GaeaGraph = load("uid://3ogbw502hfvu") # base_walker.tres
@onready var walker_demo: PackedScene = load("uid://dh5c2eomfri6n") # walker_demo.tscn

var graph: GaeaGraph
var node2_id: int


func test_graph_creation() -> void:
	graph = GaeaGraph.new()
	assert_true(is_instance_valid(graph), "New GaeaGraph is null.")
	assert_is(graph, GaeaGraph, "Attempt at creating new graph doesn't inherit GaeaGraph.")
	assert_eq(graph.get_nodes().size(), 1, "New GaeaGraph doesn't include output node.")
	assert_is(graph.get_nodes().front(), GaeaNodeOutput, "New GaeaGraph starts with non-output node.")


func test_add_node() -> void:
	var node := GaeaNodeSamplesOp.new()
	graph.add_node(node, Vector2.ZERO, NODE1_ID)
	assert_false(graph.get_nodes().is_empty(), "GaeaGraph's node list is empty after adding node.")
	assert_eq(graph.get_nodes().size(), 2, "GaeaGraph node list size incorrect after adding node.")
	assert_same(graph.get_node(NODE1_ID), node, "GaeaGraph added incorrect node.")
	assert_true(graph.has_node(NODE1_ID), "Graph's has_node returns false on added node.")


func test_node_data() -> void:
	var node_data := graph.get_node_data(NODE1_ID)
	assert_false(node_data.is_empty(), "Added node's data is empty.")
	assert_true(node_data.has(&"position"), "Added node doesn't have position key in data.")
	assert_eq(graph.get_node_position(NODE1_ID), Vector2.ZERO, "Added node's position is not as expected.")


func test_argument() -> void:
	pass


func test_connection() -> void:
	node2_id = graph.add_node(GaeaNodeTextureSampler.new(), Vector2(-50, 0))

	assert_eq(graph.connect_nodes(node2_id, 0, NODE1_ID, 0), OK, "Valid connection didn't return OK")
	assert_true(graph.has_connection(node2_id, 0, NODE1_ID, 0), "GaeaGraph's has_connection returned false on connected nodes.")
	assert_ne(graph.connect_nodes(node2_id, 0, NODE1_ID, 0), OK, "Attempt at existing connection didn't return error.")

	assert_ne(graph.connect_nodes(NODE1_ID, 0, node2_id, 0), OK, "Invalid connection didn't return error.")
	assert_false(graph.has_connection(NODE1_ID, 0, node2_id, 0), "GaeaGraph's has_connection returned true on not connected nodes.")

	assert_eq(graph.get_all_connections().size(), 1, "GaeaGraph's connections list has unexpected size.")
	assert_eq(
		graph.get_connections_to(NODE1_ID).size(), 1,
		"List of connections to node of id %s has unexpected size." % NODE1_ID
	)
	assert_eq(
		graph.get_connections_from(node2_id).size(), 1,
		"List of connections from node of id %s has unexpected size." % node2_id
	)


func test_disconnection() -> void:
	graph.disconnect_nodes(node2_id, 0, NODE1_ID, 0)

	assert_false(graph.has_connection(node2_id, 0, NODE1_ID, 0), "GaeaGraph's has_connection returned true on removed connection.")
	assert_eq(graph.get_all_connections().size(), 0, "GaeaGraph's connections list has unexpected size.")


func test_frame() -> void:
	var frame_id := graph.add_frame(Vector2.ONE)

	assert_false(graph.get_node_data(frame_id).is_empty(), "Added frame's data is empty.")
	assert_eq(graph.get_node_position(frame_id), Vector2.ONE, "Added frame's position is unexpected.")

	graph.attach_node_to_frame(NODE1_ID, frame_id)
	var attached: Array[int] = graph.get_nodes_attached_to_frame(frame_id)
	assert_eq(attached.size(), 1, "Frame's attached list has unexpected size.")
	assert_eq_deep(attached, [NODE1_ID], "Frame's attached list has unexpected size.")

	assert_ne(graph.attach_node_to_frame(frame_id, frame_id), OK, "Attempt to attach frame to itself returned OK.")
	assert_does_not_have(graph.get_nodes_attached_to_frame(frame_id), frame_id, "Attaching frame to itself was allowed.")

	graph.detach_node_from_frame(NODE1_ID)
	assert_does_not_have(graph.get_nodes_attached_to_frame(frame_id), NODE1_ID, "Frame's attached list still has node after detaching it.")


func test_remove_node() -> void:
	graph.remove_node(1)

	assert_bool(graph.has_node(1))\
		.override_failure_message("Graph's [code]has_node[/code] returns [code]true[/code] on removed node.")\
		.is_false()

	var _nodes := graph.get_nodes()
	assert_array(_nodes)\
		.override_failure_message("Graph's node resources list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_nodes.size(), 1])\
		.has_size(1)


func test_assign_to_generator() -> void:
	var premade_graph = walker_graph
	var scene: GaeaGenerationTester = auto_free(walker_demo.instantiate())
	var _runner := scene_runner(scene)
	scene.gaea_generator.graph = premade_graph
	await scene.test_generation()
	assert_dict(scene.last_result._grid).is_not_empty()


# Dictionary comparison for use in [method test_duplciate].
func compare_dictionaries(expecteds:Array, currents:Array, target_base_path:StringName):
		for i in range(expecteds.size()):
			var expected = expecteds[i]
			var current = currents[i]
			for key in expected.keys():
				if expected[key] is Resource and ((current[key] as Resource).resource_path.begins_with(target_base_path)):
					continue
				elif expected[key] != current[key]:
					return false
		return true


### It is expected that the results of [GaeaGraph] duplication should have matching storage-exported fields:
### [member GaeaGraph._connections], [member GaeaGraph._node_data], [member GaeaGraph._parameters], and [member GaeaGraph.save_version].
func test_duplicate() -> void:
	# Duplication
	var _source = walker_graph
	var _copy: GaeaGraph = _source.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)

	# Connections
	var _copy_connections = _copy.get_raw_connections()
	var _source_connections = _source.get_raw_connections()
	assert_array(_copy_connections)\
		.override_failure_message("Duplicate graph's connections do not match the original.")\
		.append_failure_message("Size: %d\nExpected: %d" % [_copy_connections.size(), _source_connections.size()])\
		.contains_same(_source_connections)

	# Nodes
	var _copy_nodes = _copy.get_all_node_data()
	var _source_nodes = _source.get_all_node_data()

	# Node IDs
	assert_array(_copy_nodes.keys())\
		.override_failure_message("Duplicate graph's node ids do not match the original.")\
		.contains_same(_source_nodes.keys())

	# Node Values
	assert_bool(compare_dictionaries(_source_nodes.values(), _copy_nodes.values(), _copy.resource_path))\
		.override_failure_message("Duplicate graph's node values do not match the original.")\
		.is_true()

	# Parameters
	var _copy_parameters = _copy.get_parameter_list()
	var _source_parameters = _source.get_parameter_list()

	# Parameter Keys
	assert_array(_copy_parameters.keys())\
		.override_failure_message("Duplicate graph's parameter keys do not match the original.")\
		.contains_same(_source_parameters.keys())

	# Parameter Values
	assert_bool(compare_dictionaries(_source_parameters.values(), _copy_parameters.values(), _copy.resource_path))\
		.override_failure_message("Duplicate graph's parameter values do not match the original.")\
		.is_true()

	# Save Version
	assert_int(_copy.save_version)\
		.override_failure_message("Duplicate graph's save version does not match the original.")\
		.is_equal(_source.save_version)


func _add_nodes_for_copy_paste_test() -> void:
	var constant_id := graph.add_node(GaeaNodeIntConstant.new(), Vector2.ZERO)
	graph.set_node_argument(constant_id, &"value", 4)

	var floor_walker_id := graph.add_node(GaeaNodeFloorWalker.new(), Vector2.ZERO)
	graph.connect_nodes(constant_id, 0, floor_walker_id, 0)

	var frame_id := graph.add_frame(Vector2.ZERO)
	graph.attach_node_to_frame(constant_id, frame_id)
	graph.attach_node_to_frame(floor_walker_id, frame_id)


func test_copy_paste() -> void:
	_add_nodes_for_copy_paste_test()

	var ids := graph.get_ids()
	var copy := GaeaNodesCopy.new()
	for id in ids:
		if graph.get_node_type(id) == GaeaGraph.NodeType.NODE:
			copy.add_node(
				id,
				graph.get_node(id).duplicate(),
				graph.get_node_position(id),
				graph.get_node_data(id).duplicate(true)
			)

			copy.add_connections(graph.get_connections_to(id))
		else:
			copy.add_frame(
				id,
				graph.get_node_position(id),
				graph.get_node_data(id).duplicate(true)
			)

	var id_mapping: Dictionary[int, int]
	var copy_ids := graph.paste_nodes(copy, copy.get_origin() + Vector2(24, 24))
	for idx in copy_ids.size():
		id_mapping[ids[idx]] = copy_ids[idx]

	assert_array(ids)\
		.override_failure_message("Amount of copied nodes is different from original.")\
		.has_size(copy_ids.size())

	for original_id in id_mapping.keys():
		var copy_id: int = id_mapping.get(original_id)
		for argument in graph.get_node_argument_list(original_id):
			var original_value = graph.get_node_argument(original_id, argument, 1)
			var copied_value = graph.get_node_argument(copy_id, argument, 2)
			assert_bool(original_value == copied_value)\
				.override_failure_message(
					"Copied node's argument [b]%s[/b] was not copied correctly." % argument
				)\
				.append_failure_message(
					"Original: %s\nCopied: %s" % [original_value, copied_value]
				)\
				.is_true()

		var original_connections := graph.get_connections_to(original_id)
		var copied_connections := graph.get_connections_to(copy_id)
		assert_array(original_connections)\
			.override_failure_message("Connections were not copied correctly (amount is different).")\
			.has_size(copied_connections.size())

		for connection_idx in original_connections.size():
			var original_connection := original_connections[connection_idx]
			var copied_connection := copied_connections[connection_idx]
			assert_int(id_mapping.get(original_connection[&"to_node"]))\
				.override_failure_message("Connection was not copied correctly (to_node)")\
				.append_failure_message(
					"Original Connection: %s\nCopied Connection: %s" % [original_connection, copied_connection]
				)\
				.is_equal(copied_connection[&"to_node"])

			assert_int(id_mapping.get(original_connection[&"from_node"]))\
				.override_failure_message("Connection was not copied correctly (from_node)")\
				.append_failure_message(
					"Original Connection: %s\nCopied Connection: %s" % [original_connection, copied_connection]
				)\
				.is_equal(copied_connection[&"from_node"])

			assert_int(original_connection[&"to_port"])\
				.override_failure_message("Connection was not copied correctly (to_port)")\
				.append_failure_message(
					"Original Connection: %s\nCopied Connection: %s" % [original_connection, copied_connection]
				)\
				.is_equal(copied_connection[&"to_port"])

			assert_int(original_connection[&"from_port"])\
				.override_failure_message("Connection was not copied correctly (from_port)")\
				.append_failure_message(
					"Original Connection: %s\nCopied Connection: %s" % [original_connection, copied_connection]
				)\
				.is_equal(copied_connection[&"from_port"])

		if graph.get_node_type(original_id) == GaeaGraph.NodeType.FRAME:
			var original_attached: Array = graph.get_nodes_attached_to_frame(original_id)
			var copy_attached: Array = graph.get_nodes_attached_to_frame(copy_id)
			if original_attached.is_empty():
				assert_array(copy_attached).is_empty()
				continue

			var expected: Array = original_attached.map(
				func(value: int) -> int: return id_mapping.get(value, -1)
			)
			assert_int(copy_attached.hash())\
				.override_failure_message("Copied frame did not attach proper nodes.")\
				.append_failure_message("Expected: %s\nCopy: %s" % [expected, copy_attached])\
				.is_equal(expected.hash())

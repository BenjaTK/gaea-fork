@abstract
class_name GraphNodeGutTest
extends GutTest


var node: GaeaNodeResource


func before_each():
	_initialize_node()


## Set [member node] to [code]autofree([TheNodeClassToTest].new())[/code] in this method,
## and also set any argument values you want to reuse every test.
@abstract
func _initialize_node() -> void


func _get_data(
	area: AABB, args: Dictionary[StringName, Variant], output: StringName
) -> Variant:
	if not node.get_output_ports_list().has(output):
		push_error("Attempted to access nonexistent output %s." % output)

	for arg_name in args:
		node.set_argument_value(arg_name, args[arg_name])

	var generation_settings: GaeaGenerationSettings = GaeaGenerationSettings.new()
	generation_settings.seed = 0
	var pouch: GaeaGenerationPouch = autofree(GaeaGenerationPouch.new(generation_settings, area))
	pouch.settings.seed = 0
	node._define_rng(pouch)

	var graph: GaeaGraph = GaeaGraph.new()
	graph.ensure_initialized()
	graph.add_node(node, Vector2i.ZERO)

	var data = node._get_data(output, pouch)
	return data


func _create_dummy_sample(area: AABB, fill_value: float = 1.0) -> GaeaValue.Sample:
	var sample := GaeaValue.Sample.new()
	sample.fill(area, fill_value)
	return sample


func _create_dummy_map(area: AABB, fill_material: GaeaMaterial = TileMapGaeaMaterial.new()) -> GaeaValue.Map:
	var map := GaeaValue.Map.new()
	map.fill(area, fill_material)
	return map

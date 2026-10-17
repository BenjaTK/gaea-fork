extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(2, 2, 2))
const FLAG_1 := 1
const FLAG_2 := 2
const FLAG_3 := 4


var test_params = ParameterFactory.named_parameters(
	["match_all", "expected_removed_cells"],
	[[false, [Vector3i.ONE]], [true, [Vector3i.ONE, Vector3i(1, 0, 0), Vector3i(0, 1, 0)]]]
)
var input: GaeaValue.Sample


func _initialize_node() -> void:
	node = GaeaNodeFlagsMapper.new()

	input = _create_dummy_sample(AREA, FLAG_1 | FLAG_3)
	input.set_cell(Vector3i.ONE, FLAG_1 | FLAG_2)
	input.set_cell(Vector3i(1, 0, 0), FLAG_1)
	input.set_cell(Vector3i(0, 1, 0), FLAG_3)
	node.set_argument_value(&"reference", input)
	node.set_argument_value(&"match_flags", [FLAG_1, FLAG_3])
	node.set_argument_value(&"exclude_flags", [FLAG_2])


func test_get_data(params = use_parameters(test_params)) -> void:
	var material: GaeaMaterial = TileMapGaeaMaterial.new()
	var grid: GaeaValue.Map = _get_data(
		AREA,
		{ &"match_all": params.match_all, &"material": material },
		&"map"
	)

	for cell in params.expected_removed_cells:
		assert_false(cell in grid.get_cells(), "Cell %s should've been removed" % cell)

	for cell in grid.get_cells():
		var value := roundi(input.get_cell(cell))
		var check := (value & FLAG_1) and (value & FLAG_3)
		if not params.match_all:
			check = (value & FLAG_1) or (value & FLAG_3)
		assert_true( check and not (value & FLAG_2), "Flag check failed at cell: %s" % cell)
		if is_failing():
			return

		assert_same(material, grid.get_cell(cell), "Wrong material mapped at cell: %s." % cell)
		if is_failing():
			return

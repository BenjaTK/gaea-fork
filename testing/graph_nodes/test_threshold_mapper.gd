extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(4, 4, 4))

var test_params = ParameterFactory.named_parameters(
	["min", "max", "expected_removed_cells"],
	[[0.5, 1.0, [Vector3.ONE, Vector3.ZERO]], [-INF, 1.0, [Vector3.ZERO]], [1.0, INF, [Vector3.ONE]]]
)
var input: GaeaValue.Sample


func _initialize_node():
	node = GaeaNodeThresholdMapper.new()
	input = _create_dummy_sample(AREA)
	input.set_cell(Vector3.ONE, 0.0)
	input.set_cell(Vector3.ZERO, 1.5)
	node.set_argument_value(&"reference", input)


func test_get_data(params = use_parameters(test_params)) -> void:
	var material: GaeaMaterial = TileMapGaeaMaterial.new()
	var grid: GaeaValue.Map = _get_data(
		AREA,
		{ &"range": {"min": params.min, "max": params.max}, &"material": material },
		&"map"
	)

	for cell in params.expected_removed_cells:
		assert_false(cell in grid.get_cells(), "Cell %s should've been removed" % cell)

	for cell in grid.get_cells():
		assert_between(
			input.get_cell(cell),
			params.min, params.max,
			"Threshold check failed at cell: %s." % cell
		)

		if is_failing():
			return

		assert_same(material, grid.get_cell(cell), "Wrong material mapped at cell: %s." % cell)
		if is_failing():
			return


func test_empty_get_data():
	assert_true(
		_get_data(
			AREA,
			{ &"range": {"min": 3.0, "max": 2.0}, &"material": TileMapGaeaMaterial.new() },
			&"map"
		).is_empty(),
		"Unexpected result, should've been empty."
	)

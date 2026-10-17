extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))

var test_params = ParameterFactory.named_parameters(
	["chance"],
	[[50.0], [0.0], [100.0]]
)


func _initialize_node() -> void:
	node = GaeaNodeRandomFilter.new()
	node.set_argument_value(&"input_grid", _create_dummy_sample(AREA))


func test_get_data(params = use_parameters(test_params)) -> void:
	var grid: GaeaValue.Sample = _get_data(
		AREA, { &"chance": params.chance }, &"filtered_grid"
	)

	assert_almost_eq(
		float(grid._grid.size()) / float(AREA.size.x ** 3),
		params.chance / 100.0,
		0.005,
		"Ratio of empty cells too far from expected."
	)

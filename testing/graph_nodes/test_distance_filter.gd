extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
var test_params = ParameterFactory.named_parameters(
	["min", "max", "to_point"],
	[[0.0, 2.0, Vector3.ZERO], [2.0, INF, Vector3(4, 4, 4)], [2.0, 3.0, Vector3(15, 0, 15)]]
)


func _initialize_node():
	node = GaeaNodeDistanceFilter.new()
	node.set_argument_value(&"input_grid", _create_dummy_sample(AREA))


func test_get_data(params = use_parameters(test_params)) -> void:
	var grid: GaeaValue.Sample = _get_data(
		AREA,
		{
			&"distance_range": {"min": params.min, "max": params.max},
			&"to_point": params.to_point
		},
		&"filtered_grid"
	)

	for cell in grid.get_cells():
		var distance := Vector3(cell).distance_squared_to(params.to_point)
		assert_between(
			distance,
			params.min ** 2,
			params.max ** 2,
			"Distance check failed at cell %s." % cell
		)

		if is_failing():
			return


func test_empty_get_data():
	assert_true(
		_get_data(
			AREA,
			{ &"distance_range": {"min": 3.0, "max": 2.0}},
			&"filtered_grid"
		).is_empty(),
		"Unexpected result, should've been empty."
	)

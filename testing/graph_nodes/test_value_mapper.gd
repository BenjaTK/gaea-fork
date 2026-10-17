extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))

var input: GaeaValue.Sample


func _initialize_node():
	node = GaeaNodeValueMapper.new()
	input = _create_dummy_sample(AREA)
	input.fill(AREA.grow(-2), 2.0)
	node.set_argument_value(&"reference", input)


func test_get_data() -> void:
	var material: GaeaMaterial = TileMapGaeaMaterial.new()

	var grid: GaeaValue.Map = _get_data(
		AREA,
		{ &"value": 1.0, &"material": material },
		&"map"
	)

	for cell in grid.get_cells():
		assert_eq(
			input.get_cell(cell), 1.0, "Value check failed at cell: %s" % cell
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
			{ "value": 0.0, &"material": TileMapGaeaMaterial.new() },
			&"map"
		).is_empty(),
		"Unexpected result, should've been empty."
	)

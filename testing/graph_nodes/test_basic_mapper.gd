extends GraphNodeGutTest


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))


func _initialize_node() -> void:
	node = GaeaNodeBasicMapper.new()
	node.set_argument_value(&"reference", _create_dummy_sample(AREA))


func test_basic_mapper() -> void:
	var material: GaeaMaterial = TileMapGaeaMaterial.new()
	var grid: GaeaValue.Map = _get_data(AREA, { &"material": material  }, &"map")

	assert_eq(
		int(AREA.size.x ** 3), grid.get_cells().size(), "Resulting map is of a different size than input grid."
	)

	for cell in grid.get_cells():
		assert_same(material, grid.get_cell(cell), "Wrong material mapped at cell: %s." % cell)

		if is_failing():
			return

extends OpNodeGutTest.SampleTest


func _initialize_node() -> void:
	node = GaeaNodeSamplesOp.new()


func _get_test_params() -> Array[Array]:
	return [
		[GaeaNodeSamplesOp.Operation.ADD, [2.0, 1.0], 3.0], [GaeaNodeSamplesOp.Operation.ADD, [1.0, -0.5], 0.5],
		[GaeaNodeSamplesOp.Operation.SUBTRACT, [2.0, 1.0], 1.0], [GaeaNodeSamplesOp.Operation.SUBTRACT, [1.0, -0.5], 1.5],
		[GaeaNodeSamplesOp.Operation.MULTIPLY, [4.0, 2.0], 8.0], [GaeaNodeSamplesOp.Operation.MULTIPLY, [4.0, -0.5], -2.0],
		[GaeaNodeSamplesOp.Operation.DIVIDE, [4.0, 2.0], 2.0], [GaeaNodeSamplesOp.Operation.DIVIDE, [1.0, -0.5], -2.0], [GaeaNodeSamplesOp.Operation.DIVIDE, [2.0, 0.0], 0.0],
		[GaeaNodeSamplesOp.Operation.LERP, [1.0, 2.0, 0.5], 1.5], [GaeaNodeSamplesOp.Operation.LERP, [1.0, -0.5, 0.5], 0.25],
	]

extends OpNodeGutTest.SampleTest


func _initialize_node() -> void:
	node = GaeaNodeSampleOp.new()


func _get_test_params() -> Array[Array]:
	return [
		[GaeaNodeSampleOp.Operation.ADD, [2.0, 1.0], 3.0], [GaeaNodeSampleOp.Operation.ADD, [1.0, -0.5], 0.5],
		[GaeaNodeSampleOp.Operation.SUBTRACT, [2.0, 1.0], 1.0], [GaeaNodeSampleOp.Operation.SUBTRACT, [1.0, -0.5], 1.5],
		[GaeaNodeSampleOp.Operation.MULTIPLY, [4.0, 2.0], 8.0], [GaeaNodeSampleOp.Operation.MULTIPLY, [4.0, -0.5], -2.0],
		[GaeaNodeSampleOp.Operation.DIVIDE, [4.0, 2.0], 2.0], [GaeaNodeSampleOp.Operation.DIVIDE, [1.0, -0.5], -2.0], [GaeaNodeSampleOp.Operation.DIVIDE, [2.0, 0.0], 0.0],
		[GaeaNodeSampleOp.Operation.POWER, [2.0, 2.0], 4.0], [GaeaNodeSampleOp.Operation.POWER, [1.0, 0.0], 1.0], [GaeaNodeSampleOp.Operation.POWER, [2.0, -1.0], 0.5],
		[GaeaNodeSampleOp.Operation.MAX, [1.0, 2.0], 2.0], [GaeaNodeSampleOp.Operation.MIN, [1.0, 2.0], 1.0],
		[GaeaNodeSampleOp.Operation.ABS, [-2.0], 2.0], [GaeaNodeSampleOp.Operation.ABS, [2.0], 2.0],
		[GaeaNodeSampleOp.Operation.CEIL, [0.5], 1.0], [GaeaNodeSampleOp.Operation.FLOOR, [0.5], 0.0],
		[GaeaNodeSampleOp.Operation.ROUND, [0.4], 0.0], [GaeaNodeSampleOp.Operation.ROUND, [0.6], 1.0],
		[GaeaNodeSampleOp.Operation.CLAMP, [0.5, 0.0, 1.0], 0.5], [GaeaNodeSampleOp.Operation.CLAMP, [-INF, 0.0, 1.0], 0.0], [GaeaNodeSampleOp.Operation.CLAMP, [INF, 0.0, 1.0], 1.0],
		[GaeaNodeSampleOp.Operation.REMAP, [0.5, 0.0, 1.0, 2.0, 4.0], 3.0],
		[GaeaNodeSampleOp.Operation.SIGN, [2.0], 1.0], [GaeaNodeSampleOp.Operation.SIGN, [-2.0], -1.0], [GaeaNodeSampleOp.Operation.SIGN, [0.0], 0.0],
		[GaeaNodeSampleOp.Operation.SMOOTHSTEP, [0.0, 1.0, 0.9], smoothstep(0.0, 1.0, 0.9)],
		[GaeaNodeSampleOp.Operation.STEP, [0.6, 0.5], 1.0], [GaeaNodeSampleOp.Operation.STEP, [0.4, 0.5], 0.0], [GaeaNodeSampleOp.Operation.STEP, [0.5, 0.5], 1.0],
		[GaeaNodeSampleOp.Operation.WRAP, [1.5, 0.0, 1.0], 0.5], [GaeaNodeSampleOp.Operation.WRAP, [0.5, 0.0, 1.0], 0.5], [GaeaNodeSampleOp.Operation.WRAP, [-0.5, 0.0, 1.0], 0.5]
	]

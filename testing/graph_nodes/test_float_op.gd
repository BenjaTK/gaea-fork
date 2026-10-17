extends OpNodeGutTest


func _initialize_node():
	node = GaeaNodeFloatOp.new()


func _get_test_params() -> Array[Array]:
	return [
		[GaeaNodeFloatOp.Operation.ADD, [2.0, 1.0], 3.0], [GaeaNodeFloatOp.Operation.ADD, [1.0, -0.5], 0.5],
		[GaeaNodeFloatOp.Operation.SUBTRACT, [2.0, 1.0], 1.0], [GaeaNodeFloatOp.Operation.SUBTRACT, [1.0, -0.5], 1.5],
		[GaeaNodeFloatOp.Operation.MULTIPLY, [4.0, 2.0], 8.0], [GaeaNodeFloatOp.Operation.MULTIPLY, [4.0, -0.5], -2.0],
		[GaeaNodeFloatOp.Operation.DIVIDE, [4.0, 2.0], 2.0], [GaeaNodeFloatOp.Operation.DIVIDE, [1.0, -0.5], -2.0], [GaeaNodeFloatOp.Operation.DIVIDE, [2.0, 0.0], 0.0],
		[GaeaNodeFloatOp.Operation.POWER, [2.0, 2.0], 4.0], [GaeaNodeFloatOp.Operation.POWER, [1.0, 0.0], 1.0], [GaeaNodeFloatOp.Operation.POWER, [2.0, -1.0], 0.5],
		[GaeaNodeFloatOp.Operation.MAX, [1.0, 2.0], 2.0], [GaeaNodeFloatOp.Operation.MIN, [1.0, 2.0], 1.0],
		[GaeaNodeFloatOp.Operation.ABS, [-2.0], 2.0], [GaeaNodeFloatOp.Operation.ABS, [2.0], 2.0],
		[GaeaNodeFloatOp.Operation.CEIL, [0.5], 1.0], [GaeaNodeFloatOp.Operation.FLOOR, [0.5], 0.0],
		[GaeaNodeFloatOp.Operation.ROUND, [0.4], 0.0], [GaeaNodeFloatOp.Operation.ROUND, [0.6], 1.0],
		[GaeaNodeFloatOp.Operation.CLAMP, [0.5, 0.0, 1.0], 0.5], [GaeaNodeFloatOp.Operation.CLAMP, [-INF, 0.0, 1.0], 0.0], [GaeaNodeFloatOp.Operation.CLAMP, [INF, 0.0, 1.0], 1.0],
		[GaeaNodeFloatOp.Operation.REMAP, [0.5, 0.0, 1.0, 2.0, 4.0], 3.0],
		[GaeaNodeFloatOp.Operation.SIGN, [2.0], 1.0], [GaeaNodeFloatOp.Operation.SIGN, [-2.0], -1.0], [GaeaNodeFloatOp.Operation.SIGN, [0.0], 0.0],
		[GaeaNodeFloatOp.Operation.SMOOTHSTEP, [0.0, 1.0, 0.9], smoothstep(0.0, 1.0, 0.9)],
		[GaeaNodeFloatOp.Operation.STEP, [0.6, 0.5], 1.0], [GaeaNodeFloatOp.Operation.STEP, [0.4, 0.5], 0.0], [GaeaNodeFloatOp.Operation.STEP, [0.5, 0.5], 1.0],
		[GaeaNodeFloatOp.Operation.WRAP, [1.5, 0.0, 1.0], 0.5], [GaeaNodeFloatOp.Operation.WRAP, [0.5, 0.0, 1.0], 0.5], [GaeaNodeFloatOp.Operation.WRAP, [-0.5, 0.0, 1.0], 0.5]
	]

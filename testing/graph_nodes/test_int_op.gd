extends OpNodeGutTest


func _initialize_node():
	node = GaeaNodeIntOp.new()


func _get_test_params() -> Array[Array]:
	return [
		[GaeaNodeIntOp.Operation.ADD, [2, 1], 3], [GaeaNodeIntOp.Operation.ADD, [1, -1], 0],
		[GaeaNodeIntOp.Operation.SUBTRACT, [2, 1], 1], [GaeaNodeIntOp.Operation.SUBTRACT, [1, -1], 2],
		[GaeaNodeIntOp.Operation.MULTIPLY, [4, 2], 8], [GaeaNodeIntOp.Operation.MULTIPLY, [4, -2], -8],
		[GaeaNodeIntOp.Operation.DIVIDE, [4, 2], 2], [GaeaNodeIntOp.Operation.DIVIDE, [4, -2], -2], [GaeaNodeIntOp.Operation.DIVIDE, [2, 0], 0],
		[GaeaNodeIntOp.Operation.POWER, [2, 2], 4], [GaeaNodeIntOp.Operation.POWER, [1, 0], 1],
		[GaeaNodeIntOp.Operation.MAX, [1, 2], 2], [GaeaNodeIntOp.Operation.MIN, [1, 2], 1],
		[GaeaNodeIntOp.Operation.ABS, [-2], 2], [GaeaNodeIntOp.Operation.ABS, [2], 2],
		[GaeaNodeIntOp.Operation.CLAMP, [1, 0, 2], 1], [GaeaNodeIntOp.Operation.CLAMP, [-999, 0, 1], 0], [GaeaNodeIntOp.Operation.CLAMP, [999, 0, 1], 1],
		[GaeaNodeIntOp.Operation.SIGN, [2], 1], [GaeaNodeIntOp.Operation.SIGN, [-2], -1], [GaeaNodeIntOp.Operation.SIGN, [0], 0],
		[GaeaNodeIntOp.Operation.STEP, [2, 1], 1], [GaeaNodeIntOp.Operation.STEP, [0, 1], 0], [GaeaNodeIntOp.Operation.STEP, [1, 1], 1],
		[GaeaNodeIntOp.Operation.WRAP, [3, 0, 2], 1], [GaeaNodeIntOp.Operation.WRAP, [1, 0, 2], 1], [GaeaNodeIntOp.Operation.WRAP, [-1, 0, 2], 1]
	]

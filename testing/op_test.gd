@abstract
class_name OpNodeGutTest
extends GraphNodeGutTest



func test_operation(params = use_parameters(_get_test_params())) -> void:
	node.set_enum_value(0, params[0])
	_assert_operation_result(_modify_args(params[1]), params[2])


@abstract
func _get_test_params() -> Array[Array]


func _assert_operation_result(args: Array[Variant], expected: Variant) -> Variant:
	var arguments_dict: Dictionary[StringName, Variant]

	var args_list: Array[StringName] = node.get_arguments_list()
	var idx: int = 0
	for arg_name in args_list:
		if not GaeaValue.is_wireable(node.get_argument_type(arg_name)):
			continue

		if idx >= args.size():
			break

		arguments_dict.set(arg_name, args[idx])
		idx += 1
	print(arguments_dict)

	var result = _get_data(AABB(), arguments_dict, &"result")
	_assert_result(result, expected)
	return result


func _assert_result(result: Variant, expected: Variant) -> void:
	assert_eq(result, expected, "Unexpected value in operation result.")


func _modify_args(args: Array) -> Array:
	return args


@abstract
class SampleTest:
	extends OpNodeGutTest

	func _modify_args(args: Array) -> Array:
		var args_list := node.get_arguments_list()
		var idx: int = 0
		for arg_name in args_list:
			if not node.get_argument_type(arg_name) == GaeaValue.Type.SAMPLE:
				if GaeaValue.is_wireable(node.get_argument_type(arg_name)):
					idx += 1
				continue

			if idx >= args.size():
				break

			args[idx] = _create_dummy_sample(AABB(Vector3.ZERO, Vector3.ONE), args[idx])
			idx += 1
		return args


	func _assert_result(result: Variant, expected: Variant) -> void:
		assert_false(result.is_empty(), "Unexpected empty grid.")

		for cell in result.get_cells():
			assert_eq(result.get_cell(cell), expected, "Unexpected value in operation result.")

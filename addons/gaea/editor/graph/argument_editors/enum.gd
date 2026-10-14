@tool
class_name GaeaEditorEnumArgument
extends GaeaEditorGraphNodeArgument

@onready var option_button: OptionButton = %OptionButton


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	option_button.item_selected.connect(_on_option_button_item_selected)


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	if hint.has("options"):
		var options: Variant = hint.get("options")
		if typeof(options) == TYPE_STRING:
			for option: String in options.split(","):
				var id: int = -1
				var split_option: PackedStringArray = option.split(":")
				if split_option.size() > 1 and split_option[1].is_valid_int():
					id = int(split_option[1])
				option_button.add_item(option, id)
		elif typeof(options) == TYPE_DICTIONARY:
			for key: String in options.keys():
				option_button.add_item(key.capitalize(), options[key])


func get_arg_value() -> Variant:
	return option_button.get_selected_id()


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_INT:
		return ERR_INVALID_DATA

	option_button.select(option_button.get_item_index(new_value))
	return OK


func _on_option_button_item_selected(index: int) -> void:
	argument_value_changed.emit(option_button.get_item_id(index))

@tool
class_name GaeaGDExtensionMigration
extends EditorScript

const CLASS_RENAMES: Dictionary[String, String] = {
	"GaeaValue.Sample": "GaeaSample",
	"GaeaValue.Map": "GaeaMap",
	"GaeaValue.GridType": "GaeaGrid",
	"PickRandomGaeaMaterial": "RandomGaeaMaterial",
	"PointwiseRandomGaeaMaterial": "RandomGaeaMaterial",
	"GaeaValueCast": "GaeaValue",
}
const MIGRATION_EXTENSIONS: PackedStringArray = ["tscn", "tres", "gd"]
const UID_CLASS_NAME_EQUIVALENTS: Dictionary[String, String] = {
	"e45byecr4gi6": "TileMapGaeaMaterial",
	"cs0htewp12cyu": "GridMapGaeaMaterial",
	"dy1s0h57bh7vp": "GradientGaeaMaterial",
	"jlxuofu2p4bf": "RandomGaeaMaterial",  # Both random materials were merged into one.
	"dtocuov1r8agi": "RandomGaeaMaterial",
	"cj08rybcfwlle": "GaeaMaterial",
	"ct2w70ehn4avu": "GaeaGenerationSettings",
	"3qsmwhn2sk47": "GaeaLayer",
}

var external_resource_regex: RegEx = RegEx.create_from_string(
	r'\[ext_resource type="Script" uid="uid:\/\/([^"]*)" .* id="([^"]*)".*\]'
)
var sub_resource_regex: RegEx = RegEx.create_from_string(r'\[sub_resource type="(.*)" id="(.*)"\]')
var script_regex: RegEx = RegEx.create_from_string(r'script = ExtResource\("(.*)"\)')
var category_regex: RegEx = RegEx.create_from_string(r"\[(.*)\]")
var custom_type_script_regex: RegEx = RegEx.create_from_string(
	r'metadata\/_custom_type_script = "uid:\/\/(.*)"'
)
var ext_resource_reference_regex: RegEx = RegEx.create_from_string(r'ExtResource\("([^"]*)"\)')
var gd_resource_regex: RegEx = RegEx.create_from_string(
	r'\[gd_resource type="(.*)" script_class="(.*)" .*\]'
)
var class_regexes: Dictionary[String, RegEx]


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	_create_regexes()
	for file_path in _get_files():
		var lines: Array[SourceLine]
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		if not is_instance_valid(file):
			push_error('Unable to read content of "%s"' % file_path)
			continue

		while not file.eof_reached():
			lines.append(SourceLine.new(file.get_line()))

		var file_content_before: String = string_from_lines(lines)
		var hash_before: int = file_content_before.hash()

		print('Attempting to migrate "%s"' % file_path)

		var external_resources: Dictionary[String, String] = _get_external_resources(lines)
		_rename_classes(lines)
		if file_path.ends_with(".tres"):
			_convert_script_class(lines)
			_convert_subresources(lines, external_resources)
			_convert_external_resource_references(lines, external_resources)
		elif file_path.ends_with(".tscn"):
			_convert_subresources(lines, external_resources)
			_convert_external_resource_references(lines, external_resources)
		elif file_path.ends_with(".gd"):
			_custom_rename(lines, r"GaeaValue\.Type\.", "GaeaValue.ARG_TYPE_")
			_custom_rename(lines, r"GaeaValue\.Type", "GaeaValue.ArgType")
			_custom_rename(lines, r"GaeaValue\.ARG_TYPE_NULL", "GaeaValue.ARG_TYPE_NIL")
			_custom_rename(lines, r"GaeaValue\.ARG_TYPE_BOOL", "GaeaValue.ARG_TYPE_BOOLEAN")

			_custom_rename(lines, r"GaeaValue\.CheckMode\.", "GaeaValue.CELL_CHECK_MODE_")
			_custom_rename(lines, r"GaeaValue\.CheckMode", "GaeaValue.CellCheckMode")

			_custom_rename(lines, r"GaeaValue\.CoordinateFormat\.", "GaeaValue.COORDINATE_FORMAT_")
			_custom_rename(
				lines, r"GaeaValue\.COORDINATE_FORMAT_BOOL", "GaeaValue.COORDINATE_FORMAT_BOOLEAN"
			)

			_custom_rename(lines, r"TileMapGaeaMaterial\.Type\.", "GaeaValue.TYPE_")
			_custom_rename(lines, r"GaeaPriority\.new", "GaeaBasicPriority.create")
			_custom_rename(lines, r"GaeaGenerationPriority\.new", "GaeaGenerationPriority.create")
			_custom_rename(lines, r"GaeaGenerationPriority\.get_recommended_task_limit", "GaeaGenerationTask.get_recommended_task_limit")
		_custom_rename(lines, "randomize_seed_on_generate", "randomize_seed_on_generate")

		var file_content_after: String = string_from_lines(lines)
		var hash_after: int = file_content_after.hash()
		if hash_before != hash_after:
			var write_file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
			if not is_instance_valid(write_file):
				push_error('Unable to apply changes to "%s", no writing access.' % file_path)
				continue
			write_file.store_string(file_content_after)
			print('File "%s" converted by GaeaGDExtensionMigration' % file_path)


func _create_regexes() -> void:
	for renamed_class in CLASS_RENAMES:
		class_regexes[renamed_class] = RegEx.create_from_string(
			r"\b" + renamed_class.replace(".", r"\.") + r"(?!\.tscn)(?!\.gd)(?!\.gdshader)\b"
		)


func _get_external_resources(lines: Array[SourceLine]) -> Dictionary[String, String]:
	var external_resources: Dictionary[String, String]  # [id, uid]
	for i in lines.size():
		var text: String = lines[i].text

		if text.begins_with("[ext_resource"):
			var regex_match: RegExMatch = external_resource_regex.search(text)
			if not is_instance_valid(regex_match):
				continue

			var uid: String = regex_match.get_string(1)
			if UID_CLASS_NAME_EQUIVALENTS.has(uid):
				lines[i].ignore_in_result = true
				external_resources.set(regex_match.get_string(2), uid)

	return external_resources


func _convert_script_class(lines: Array[SourceLine]) -> void:
	for i in lines.size():
		var regex_match: RegExMatch = gd_resource_regex.search(lines[i].text)
		if not is_instance_valid(regex_match):
			continue

		var original_type: String = regex_match.get_string(1)
		var script_class: String = regex_match.get_string(2)

		if script_class in UID_CLASS_NAME_EQUIVALENTS.values():
			lines[i].text = lines[i].text.replace(
				'type="%s"' % original_type, 'type="%s"' % script_class
			)
			lines[i].text = lines[i].text.replace('script_class="%s" ' % script_class, "")


func _convert_subresources(
	lines: Array[SourceLine], external_resources: Dictionary[String, String]
) -> void:
	for i in lines.size():
		var text: String = lines[i].text

		if text.begins_with("[sub_resource"):
			var regex_match: RegExMatch = sub_resource_regex.search(text)
			if not is_instance_valid(regex_match):
				continue

			var type: String = regex_match.get_string(1)
			var id: String = regex_match.get_string(2)

			if type == "Resource":
				var external_script: String
				var j: int = i + 1
				while (
					j < lines.size() and not is_instance_valid(category_regex.search(lines[j].text))
				):
					if lines[j].text.begins_with("script"):
						external_script = script_regex.search(lines[j].text).get_string(1)
						break
					j += 1

				if external_script.is_empty():
					push_error('Failed to find script ExtResource for "%s"' % id)
					continue

				if not external_resources.has(external_script):
					continue

				if not UID_CLASS_NAME_EQUIVALENTS.has(external_resources.get(external_script)):
					continue

				lines[i].text = text.replace(
					'type="Resource"',
					(
						'type="%s"'
						% UID_CLASS_NAME_EQUIVALENTS.get(external_resources.get(external_script))
					)
				)

		if text.begins_with("script"):
			var regex_match: RegExMatch = script_regex.search(text)
			if not is_instance_valid(regex_match):
				continue

			if not external_resources.has(regex_match.get_string(1)):
				continue

			lines[i].ignore_in_result = true
			print("Removed line: %s" % lines[i].text)

		if text.begins_with("metadata/_custom_type_script"):
			var regex_match: RegExMatch = custom_type_script_regex.search(text)
			if not is_instance_valid(regex_match):
				continue

			if UID_CLASS_NAME_EQUIVALENTS.has(regex_match.get_string(1)):
				lines[i].ignore_in_result = true


func _convert_external_resource_references(
	lines: Array[SourceLine], external_resources: Dictionary[String, String]
) -> void:
	for i in lines.size():
		var text: String = lines[i].text

		var regex_match: RegExMatch = ext_resource_reference_regex.search(text)
		if not is_instance_valid(regex_match):
			continue

		var ext_resource_id: String = regex_match.get_string(1)
		if not external_resources.has(ext_resource_id):
			continue

		var uid: String = external_resources.get(ext_resource_id)
		if not UID_CLASS_NAME_EQUIVALENTS.has(uid):
			continue

		lines[i].text = text.replace(
			regex_match.get_string(0), "%s" % UID_CLASS_NAME_EQUIVALENTS.get(uid)
		)


func _rename_classes(lines: Array[SourceLine]) -> void:
	for i in lines.size():
		for renamed_class in CLASS_RENAMES.keys():
			if not lines[i].text.contains(renamed_class):
				continue

			if renamed_class == "PointwiseRandomGaeaMaterial":
				push_warning(
					"PointwiseRandomGaeaMaterial found. This class was merged into RandomGaeaMaterial with the pointwise boolean."
				)

			lines[i].text = class_regexes[renamed_class].sub(
				lines[i].text, CLASS_RENAMES[renamed_class], true
			)


func _custom_rename(lines: Array[SourceLine], from: String, to: String) -> void:
	var regex: RegEx = RegEx.create_from_string(r"\b" + from + r"\b")
	if not is_instance_valid(regex):
		push_error('Couldn\'t rename "%s" to "%s", invalid RegEx.' % [from, to])
		return

	for i in lines.size():
		lines[i].text = regex.sub(lines[i].text, to, true)


func _get_files() -> PackedStringArray:
	var files: PackedStringArray

	var dirs_to_check: PackedStringArray
	dirs_to_check.push_back("res://")
	while not dirs_to_check.is_empty():
		var path: String = dirs_to_check.get(dirs_to_check.size() - 1)
		dirs_to_check.resize(dirs_to_check.size() - 1)

		var dir: DirAccess = DirAccess.open(path)
		if not is_instance_valid(dir):
			continue

		dir.list_dir_begin()
		var current_dir: String = dir.get_current_dir()
		var file_name: String = dir.get_next()

		while not file_name.is_empty():
			if dir.current_is_dir():
				if current_dir != "addons" or file_name == "gaea":
					dirs_to_check.append(current_dir.path_join(file_name) + "/")
			else:
				if file_name.get_extension() in MIGRATION_EXTENSIONS:
					if file_name != "gdextension_migration.gd":
						files.append(current_dir.path_join(file_name))
			file_name = dir.get_next()

	return files


func string_from_lines(array: Array[SourceLine]) -> String:
	var string: String = ""
	var filtered_array: Array[SourceLine] = array.filter(
		func(source_line: SourceLine) -> bool: return not source_line.ignore_in_result
	)
	for i in filtered_array.size():
		string += filtered_array[i].text

		if i != filtered_array.size() - 1:
			string += "\n"

	return string


class SourceLine:
	var text: String:
		set = set_text
	var ignore_in_result: bool = false

	func set_text(value: String) -> void:
		if text.hash() != value.hash():
			if not text.is_empty():
				prints("Line Changed:\n%s -> %s" % [text, value])
			text = value

	func _init(from_line: String) -> void:
		text = from_line

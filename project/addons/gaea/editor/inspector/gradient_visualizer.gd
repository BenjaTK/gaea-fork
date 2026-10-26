@tool
extends Control

var gradient: GradientGaeaMaterial


func _ready() -> void:
	custom_minimum_size = Vector2(128, 48)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	tooltip_text = "Color used is the GaeaMaterial's preview_color"
	gradient.changed.connect(queue_redraw)

func _draw() -> void:
	draw_texture_rect(
		EditorInterface.get_editor_theme().get_icon(&"GuiMiniCheckerboard", &"EditorIcons"), Rect2(0, 0, get_size().x, size.y), true
	)

	for x in get_size().x:
		var relative: float = float(x) / get_size().x
		var gaea_material: GaeaMaterial = gradient.sample(relative)
		if not is_instance_valid(gaea_material):
			continue
		var color: Color = gaea_material.preview_color

		draw_rect(
			Rect2(x, 0, 1, get_size().y), color
		)

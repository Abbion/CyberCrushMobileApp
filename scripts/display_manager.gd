extends Node

var base_width: float = float(ProjectSettings.get_setting("display/window/size/viewport_width"))
var base_height: float = float(ProjectSettings.get_setting("display/window/size/viewport_height"))

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(on_gui_focus_chaned)

func base_to_viewport_point_converter(value: Vector2) -> Vector2:
	var viewport_size = get_viewport().size
	var viewport_ratio = float(viewport_size.x) / float(viewport_size.y)
	
	var scale = base_width / float(viewport_size.x)
	if (viewport_ratio > 1) :
		scale = base_height / float(viewport_size.y)

	return value * scale

func on_gui_focus_chaned(node: Node) -> void:
	if node.get_meta("skip_vk_check") == true:
		return
	
	if node is LineEdit or node is TextEdit:
		DisplayServer.virtual_keyboard_show(node.text)
	else:
		DisplayServer.virtual_keyboard_hide()

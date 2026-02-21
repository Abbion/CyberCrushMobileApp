#Can be deleted
extends LineEdit

enum VK_KEYBOARD_TYPE {
	PASSWORD,
	ONE_LINE,
	NUMBER
}

@export var vk_type_type: VK_KEYBOARD_TYPE = VK_KEYBOARD_TYPE.ONE_LINE

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		match vk_type_type:
			VK_KEYBOARD_TYPE.PASSWORD:
				DisplayServer.virtual_keyboard_show(text, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_PASSWORD)
			VK_KEYBOARD_TYPE.ONE_LINE:
				DisplayServer.virtual_keyboard_show(text, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_DEFAULT)
			VK_KEYBOARD_TYPE.NUMBER:
				DisplayServer.virtual_keyboard_show(text, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_NUMBER)

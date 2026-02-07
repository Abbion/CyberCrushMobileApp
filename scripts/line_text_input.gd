extends LineEdit

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		DisplayServer.virtual_keyboard_show(text)

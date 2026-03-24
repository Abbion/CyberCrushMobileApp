extends Control

@export var info_message_text: String = ""
@onready var info_message_label = $main_panel/main_margin/info_message

func _ready() -> void:
	if info_message_text.length() == 0:
		info_message_label.text = "Null"
	else:
		info_message_label.text = tr(info_message_text)

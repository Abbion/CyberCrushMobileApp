extends Control

@export var info_message_text: String = ""
@onready var info_message_label = $main_panel/main_margin/info_message

func _ready() -> void:
	info_message_label.text = info_message_text

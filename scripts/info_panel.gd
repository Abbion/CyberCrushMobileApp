extends Control

@export var info_message_text: String = ""
@onready var info_message_label = $main_panel/main_margin/info_message

func _ready() -> void:
	if info_message_text.length() == 0:
		info_message_label.text = "Null"
	else:
		if info_message_text.contains(GlobalConstants.TRANSLATION_MARK):
			var message = info_message_text.replace(GlobalConstants.TRANSLATION_MARK, "")
			info_message_label.text = tr(message)
		else:
			info_message_label.text = info_message_text

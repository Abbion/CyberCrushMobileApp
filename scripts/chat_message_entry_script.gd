extends Control

@export var message_alignment: GlobalTypes.CHAT_MESSAGE_ALIGNMENT
@export var message_text: String
@export var timestamp_text: String

@onready var message_container: VBoxContainer = $message_container
@onready var message_label: Label = $message_container/message_label
@onready var timestamp_label: Label = $message_container/timestamp_label
@onready var message_background: ColorRect = $message_background

const message_container_separator = 5

func _ready() -> void:
	message_label.text = message_text
	timestamp_label.text = timestamp_text
	
	var lines = message_text.split("\n")
	var max_line_width: float = 0.0
	var message_height = 0.0
	
	for line in lines:
		var bounds = message_label.get_theme_font("font").get_string_size(line)
		if bounds.x > max_line_width:
			max_line_width = bounds.x
	
	if max_line_width < message_container.size.x:
		message_container.size.x = max_line_width
		message_label.custom_minimum_size.x = max_line_width
	else:
		message_label.custom_minimum_size.x = message_container.size.x
	
	if message_alignment == GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT:
		message_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		message_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	else:
		var page_width = size.x
		var message_container_position = page_width - message_container.size.x
		message_container.position.x = message_container_position
		message_background.position.x = page_width - max_line_width
		
		message_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		message_label.size_flags_horizontal = Control.SIZE_SHRINK_END

	var message_label_height = 0.0
	for i in range(message_label.get_line_count()):
		message_label_height += message_label.get_line_height(i)
	
	custom_minimum_size.y = message_label_height + timestamp_label.get_line_height(0) + message_container_separator
	
	message_background.size.x = message_label.custom_minimum_size.x
	message_background.size.y = message_label_height

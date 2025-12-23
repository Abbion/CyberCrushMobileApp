extends Control

enum TIMESTAMP_ALIGNMENT { LEFT, RIGHT }
@export var timestamp_alignment: TIMESTAMP_ALIGNMENT

@onready var timestamp_label = $VBoxContainer/message_label;
@onready var message_label = $VBoxContainer/message_label

func _ready() -> void:
	if timestamp_alignment == TIMESTAMP_ALIGNMENT.LEFT:
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func set_text(text: String) -> void:
	message_label.text = text

func set_timestamp(timestamp: String) -> void:
	timestamp_label.text = timestamp

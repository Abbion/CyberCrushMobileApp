extends PanelContainer

@export var chat_title: String = "Chat title"
@export var last_message: String = "Last message"
@export var last_timestamp: String = "12:00"

@onready var chat_title_label: Label = $VBoxContainer/chat_title_label
@onready var last_message_label: Label = $VBoxContainer/HBoxContainer/last_message_label
@onready var last_timestamp_label: Label = $VBoxContainer/HBoxContainer/last_timestamp_label

func _ready() -> void:
	chat_title_label.text = chat_title
	last_message_label.text = last_message
	last_timestamp_label.text = last_timestamp

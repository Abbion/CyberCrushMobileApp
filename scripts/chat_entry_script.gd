extends PanelContainer

@export var chat_id: int = -1
@export var chat_title: String = "Chat title"
@export var last_message: String = "Last message"
@export var last_timestamp: String = "12:00"

@onready var chat_title_label: Label = $margin_container/VBoxContainer/chat_title_label
@onready var last_message_label: Label = $margin_container/VBoxContainer/HBoxContainer/last_message_label
@onready var last_timestamp_label: Label = $margin_container/VBoxContainer/HBoxContainer/last_timestamp_label

signal chat_opened(chat_id: int)

func _ready() -> void:
	chat_title_label.text = chat_title
	last_message_label.text = last_message
	var timestamp = GlobalTypes.DateTime.from_string(last_timestamp)
	last_timestamp_label.text = timestamp.get_string()

func _on_chat_interactor_pressed() -> void:
	chat_opened.emit(chat_id)

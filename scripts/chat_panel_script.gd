extends Control

var message_entry: PackedScene = preload("res://scenes/custom_controlls/chat_message_entry.tscn")

@onready var messages: VBoxContainer = $messages

func _ready() -> void:
	var message_1 = message_entry.instantiate()
	messages.add_child(message_1)
	message_1.set_text("Hello")
	message_1.set_timestamp("Hello")

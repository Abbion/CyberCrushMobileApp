extends Control

var message_entry: PackedScene = preload("res://scenes/custom_controlls/chat_message_entry.tscn")

@onready var messages: VBoxContainer = $messages

func _ready() -> void:
	var message_1 = message_entry.instantiate()
	message_1.message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.RIGHT
	message_1.message_text = "Hejoo"
	message_1.timestamp_text = "28.12.2025: 16:30 Abbion"
	messages.add_child(message_1)
	
	var message_2 = message_entry.instantiate()
	message_2.message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.RIGHT
	message_2.message_text = "Masz czas jutro?"
	message_2.timestamp_text = "28.12.2025: 16:30 Abbion"
	messages.add_child(message_2)
	
	var message_3 = message_entry.instantiate()
	message_3.message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT
	message_3.message_text = "No nie wiem. Dużo mam na głowie, ale myśle, że trochę czasu uda mi się zorganizować ;) AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	message_3.timestamp_text = "28.12.2025: 16:30 Abbion"
	messages.add_child(message_3)
	
	var message_4 = message_entry.instantiate()
	message_4.message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.RIGHT
	message_4.message_text = "No to umówieni\nbtw mam twoje majtki"
	message_4.timestamp_text = "28.12.2025: 16:30 Abbion"
	messages.add_child(message_4)
	#pass

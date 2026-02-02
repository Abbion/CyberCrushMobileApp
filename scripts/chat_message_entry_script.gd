extends PanelContainer

@export var message_alignment: GlobalTypes.CHAT_MESSAGE_ALIGNMENT
@export var message_text: String
@export var timestamp_text: String
@export var sender_username: String
@export var container_width: int
@export var in_chat_index: int

@onready var message_container: VBoxContainer = $message_container
@onready var message_label: Label = $message_container/message_label
@onready var timestamp_label: Label = $message_container/timestamp_label
@onready var sender_username_label: Label = $message_container/sender_username_label

const message_container_separator = 5
const max_message_width_ratio = 0.7
var text_resized = false

func _ready() -> void:
	message_label.text = message_text
	timestamp_label.text = timestamp_text
	sender_username_label.text = sender_username
	
	if message_alignment == GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT:
		sender_username_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		sender_username_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _on_message_label_resized() -> void:
	if text_resized or message_label == null:
		return
		
	var text_length = message_label.text.length()
	
	if text_length == 0:
		return
	
	var last_character = message_label.get_character_bounds(text_length - 1)
	var message_width = last_character.position.x + last_character.size.x
	var viewport_width = get_viewport_rect().size.x
	var max_message_width = viewport_width * max_message_width_ratio
	
	if message_width > max_message_width:
		message_label.custom_minimum_size.x = container_width * max_message_width_ratio
		message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		var last_sender_character = sender_username_label.text.length()
		var last_timestamp_character = timestamp_label.text.length()
		if last_sender_character == 0 or last_timestamp_character == 0:
			return
		
		var sender_last_character = sender_username_label.get_character_bounds(last_sender_character - 1)
		var timestamp_last_character = timestamp_label.get_character_bounds(last_timestamp_character - 1)
		
		var sender_width = sender_last_character.position.x + sender_last_character.size.x
		var timestamp_width = timestamp_last_character.position.x + timestamp_last_character.size.x
		
		var anchor = message_width / viewport_width
		anchor = max(anchor, sender_width / viewport_width)
		anchor = max(anchor, timestamp_width / viewport_width)
		
		anchor_right = anchor
		
	text_resized = true

#Refactor 1
extends PanelContainer

@export var message_alignment: GlobalTypes.CHAT_MESSAGE_ALIGNMENT
@export var message_text: String
@export var sender_username: String
@export var container_width: int
@export var in_chat_index: int
@export var min_chat_box_size: int
@export var max_chat_box_size: int
var timestamp: GlobalTypes.DateTime

@onready var sender_username_label: Label = $username_float/username_label
@onready var message_label: Label = $inner_message_margin/inner_message_v_box/message_panel/message_margin/message_label
@onready var timestamp_label: Label = $inner_message_margin/inner_message_v_box/timestamp_margin/timestamp_label
@onready var message_panel: PanelContainer = $inner_message_margin/inner_message_v_box/message_panel
@onready var copy_timer: Timer = $copy_timer

var outline_style: StyleBox = preload("res://themes/box_styles/panel_container_light_outline.tres")
var fill_style: StyleBox = preload("res://themes/box_styles/panel_container_light_fill.tres")

const max_message_width_ratio := 0.7
var text_resized := false
var base_time_stamp

var elapsed_time := 0.0
const TIME_TO_REFRESH_TIMESTAMP := 90.0 # In seconds

func _ready() -> void:
	var text_size := HelperFunctions.measure_text(message_text)
	var chat_box_size = clamp(text_size.x, min_chat_box_size, max_chat_box_size)
	custom_minimum_size.x = chat_box_size
	
	message_label.text = message_text
	timestamp_label.text = timestamp.get_string()
	sender_username_label.text = sender_username
	
	if message_alignment == GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT:
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		message_panel.add_theme_stylebox_override("panel", fill_style)
		message_label.add_theme_color_override("font_color", Color.BLACK)

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > TIME_TO_REFRESH_TIMESTAMP:
		timestamp_label.text = timestamp.get_string()
		elapsed_time = 0.0

func on_message_label_resized() -> void:
	if text_resized or message_label == null:
		return
	
	var text_length = message_label.text.length()
	
	if text_length == 0:
		return
	
	var message_width := HelperFunctions.measure_text(message_label.text, message_label.get_theme_font_size("font_size")).x
	var viewport_width := get_viewport_rect().size.x
	var max_message_width := viewport_width * max_message_width_ratio
	
	if message_width > max_message_width:
		message_label.custom_minimum_size.x = container_width * max_message_width_ratio
		message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		var last_sender_character := sender_username_label.text.length()
		var last_timestamp_character := timestamp_label.text.length()
		if last_sender_character == 0 or last_timestamp_character == 0:
			return
		
		var sender_last_character := sender_username_label.get_character_bounds(last_sender_character - 1)
		var timestamp_last_character := timestamp_label.get_character_bounds(last_timestamp_character - 1)
		
		var sender_width := sender_last_character.position.x + sender_last_character.size.x
		var timestamp_width := timestamp_last_character.position.x + timestamp_last_character.size.x
		
		var anchor := message_width / viewport_width
		anchor = max(anchor, sender_width / viewport_width)
		anchor = max(anchor, timestamp_width / viewport_width)
		
		anchor_right = anchor
	
	text_resized = true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			copy_timer.start()
		else:
			copy_timer.stop()
	
	if event is InputEventScreenDrag:
		copy_timer.stop()

func on_copy_timer_timeout() -> void:
	PopupDisplayServer.push_info(tr("MESSAGE_COPIED"))
	DisplayServer.clipboard_set(message_label.text)
	Input.vibrate_handheld(100, 0.25)

extends Control

signal panel_closed;
const INPUT_CHAT_LAYOUT_SIZE = 280;
const FADE_SPEED = 15
const MAX_GROUP_CHAT_TITLE_LENGHT = 32
const MIN_GROUP_CHAT_TITLE_LENGTH = 5;

enum { SELECTOR, DIRECT_CHAT, GROUP_CHAT }
var current_state: int = SELECTOR
var transition_in_progress: bool = false
var selector_visible: bool = true
var initial_background_bottom_offset: int = 0

@onready var background = $background
@onready var new_chat_selector_layout: VBoxContainer = $background/new_chat_selector_layout
@onready var new_direct_chat_layout: Control = $background/new_direct_chat_layout
@onready var new_group_chat_layout: Control = $background/new_group_chat_layout
@onready var direct_chat_username_input = $background/new_direct_chat_layout/username_input
@onready var group_chat_title_input = $background/new_group_chat_layout/new_group_chat_options/chat_name_input

func _ready() -> void:
	initial_background_bottom_offset = background.offset_bottom

func reset_state() -> void:
	current_state = SELECTOR
	transition_in_progress = false
	new_direct_chat_layout.hide()
	new_group_chat_layout.hide()
	new_chat_selector_layout.show()
	direct_chat_username_input.clear()
	group_chat_title_input.text = ""

func _on_cancel_button_pressed() -> void:
	reset_state()
	panel_closed.emit()

func _on_new_direct_chat_button_pressed() -> void:
	#transition_in_progress = true
	current_state = DIRECT_CHAT
	new_chat_selector_layout.hide()
	new_direct_chat_layout.show()
	#new_direct_chat_layout.modulate.a = 0.0

func _on_new_group_chat_button_pressed() -> void:
	#transition_in_progress = true
	current_state = GROUP_CHAT
	new_chat_selector_layout.hide()
	new_group_chat_layout.show()
	#new_group_chat_layout.modulate.a = 0.0	

func _on_begin_direct_chat_button_pressed() -> void:
	var partner_username = direct_chat_username_input.get_value()
	var chat_id = await ServerRequest.create_direct_chat(partner_username)
	if chat_id < 0:
		return
	GlobalSignals.new_chat_created.emit(chat_id)
	reset_state()

func _on_begin_group_chat_button_pressed() -> void:
	var title: String = group_chat_title_input.text;
	title = title.strip_edges()
	
	if title.length() < MIN_GROUP_CHAT_TITLE_LENGTH:
		PopupDisplayServer.push_error("Tytuł czatu grupowego jest za krótki. Wymagane minimum %s znaków" % MAX_GROUP_CHAT_TITLE_LENGHT)
		return
	if title.length() > MAX_GROUP_CHAT_TITLE_LENGHT:
		PopupDisplayServer.push_error("Tytuł czatu grupowego jest za długi. Ograniczenie %s znaków" % MAX_GROUP_CHAT_TITLE_LENGHT)
		return
	
	var chat_id = await ServerRequest.create_group_chat(title)
	if chat_id < 0:
		return
	
	GlobalSignals.new_chat_created.emit(chat_id)
	reset_state()

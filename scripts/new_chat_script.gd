#Refactor 1

extends Control

signal panel_closed;
const INPUT_CHAT_LAYOUT_SIZE: int = 280;
const FADE_SPEED : int= 15
const MAX_GROUP_CHAT_TITLE_LENGHT: int = 32
const MIN_GROUP_CHAT_TITLE_LENGTH: int = 5;

enum { SELECTOR, DIRECT_CHAT, GROUP_CHAT }
var current_state: int = SELECTOR
var transition_in_progress: bool = false
var selector_visible: bool = true

@onready var new_chat_selector_layout: VBoxContainer = $layouts_margin/new_chat_selector_layout
@onready var new_direct_chat_layout: VBoxContainer = $layouts_margin/new_direct_chat_layout
@onready var new_group_chat_layout: VBoxContainer = $layouts_margin/new_group_chat_layout
@onready var direct_chat_username_input = $layouts_margin/new_direct_chat_layout/username_input
@onready var group_chat_title_input: LineEdit = $layouts_margin/new_group_chat_layout/chat_name_input

@onready var suggestion_margin: MarginContainer = $layouts_margin/new_direct_chat_layout/username_input/v_box/layout_override/suggestion_margin
@onready var new_direct_chat_actions: HBoxContainer = $layouts_margin/new_direct_chat_layout/new_direct_chat_actions

func _ready() -> void:
	direct_chat_username_input.all_suggestions = await ServerRequest.all_usernames(true)

func reset_state() -> void:
	current_state = SELECTOR
	transition_in_progress = false
	new_direct_chat_layout.hide()
	new_group_chat_layout.hide()
	new_chat_selector_layout.show()
	direct_chat_username_input.clear()
	group_chat_title_input.text = ""

func on_cancel_button_pressed() -> void:
	reset_state()
	panel_closed.emit()

func on_new_direct_chat_button_pressed() -> void:
	current_state = DIRECT_CHAT
	new_chat_selector_layout.hide()
	new_direct_chat_layout.show()

func on_new_group_chat_button_pressed() -> void:
	current_state = GROUP_CHAT
	new_chat_selector_layout.hide()
	new_group_chat_layout.show()

func on_begin_direct_chat_button_pressed() -> void:
	if direct_chat_username_input.is_in_suggestions() == false:
		PopupDisplayServer.push_error(tr("USERNAME_DOES_NOT_EXIST"), tr("DIRECT_CHAT_CREATION_PANEL"))
		return
	
	var partner_username: String = direct_chat_username_input.get_value()
	var chat_id := await ServerRequest.create_direct_chat(partner_username)
	if chat_id < 0:
		return
	GlobalSignals.new_chat_created.emit(chat_id)
	reset_state()

func on_begin_group_chat_button_pressed() -> void:
	var title := group_chat_title_input.text;
	title = title.strip_edges()
	
	if title.length() < MIN_GROUP_CHAT_TITLE_LENGTH:
		match AppSessionState.get_language():
			GlobalTypes.LANGUAGE.ENGLISH:
				PopupDisplayServer.push_error("Group chat title is too short. Has to have minumum %s characters" % MIN_GROUP_CHAT_TITLE_LENGTH)
			GlobalTypes.LANGUAGE.POLISH:
				PopupDisplayServer.push_error("Tytuł czatu grupowego jest za krótki. Wymagane minimum %s znaków" % MIN_GROUP_CHAT_TITLE_LENGTH)
		return
	if title.length() > MAX_GROUP_CHAT_TITLE_LENGHT:
		match AppSessionState.get_language():
			GlobalTypes.LANGUAGE.ENGLISH:
				PopupDisplayServer.push_error("Group chat title is too long. %s character limit" % MIN_GROUP_CHAT_TITLE_LENGTH)
			GlobalTypes.LANGUAGE.POLISH:
				PopupDisplayServer.push_error("Tytuł czatu grupowego jest za długi. Ograniczenie %s znaków" % MAX_GROUP_CHAT_TITLE_LENGHT)
		return
	
	var chat_id := await ServerRequest.create_group_chat(title)
	if chat_id < 0:
		return
	
	GlobalSignals.new_chat_created.emit(chat_id)
	reset_state()

func on_suggestion_margin_visibility_changed() -> void:
	if suggestion_margin.visible == true:
		new_direct_chat_actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for actions in new_direct_chat_actions.get_children():
			actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		new_direct_chat_actions.mouse_filter = Control.MOUSE_FILTER_PASS
		for actions in new_direct_chat_actions.get_children():
			actions.mouse_filter = Control.MOUSE_FILTER_STOP

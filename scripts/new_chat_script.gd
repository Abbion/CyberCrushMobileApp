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

var create_new_direct_chat_request : HTTPRequest
const create_new_direct_chat_url = "http://127.0.0.1:3003/create_new_direct_chat"
var create_new_group_chat_request : HTTPRequest
const create_new_group_chat_url = "http://127.0.0.1:3003/create_new_group_chat"

@onready var background = $background
@onready var new_chat_selector_layout: VBoxContainer = $background/new_chat_selector_layout
@onready var new_direct_chat_layout: Control = $background/new_direct_chat_layout
@onready var new_group_chat_layout: Control = $background/new_group_chat_layout
@onready var direct_chat_username_input = $background/new_direct_chat_layout/username_input
@onready var group_chat_title_input = $background/new_group_chat_layout/new_group_chat_options/chat_name_input

func _ready() -> void:
	initial_background_bottom_offset = background.offset_bottom
	
	create_new_direct_chat_request = HTTPRequest.new()
	create_new_direct_chat_request.request_completed.connect(create_new_direct_chat_request_completed)
	add_child(create_new_direct_chat_request)
	
	create_new_group_chat_request = HTTPRequest.new()
	create_new_group_chat_request.request_completed.connect(create_new_group_chat_request_completed)
	add_child(create_new_group_chat_request)

#func _process(delta: float) -> void:
	#if transition_in_progress == false:
	#	return
	
	#var selector_opacity = new_chat_selector_layout.modulate.a
	#var transition_progress = (1.0 - selector_opacity)
	
	#if new_chat_selector_layout.visible:
	#	selector_opacity -= (delta * FADE_SPEED)
	#	var selector_transition_progress = max(selector_opacity, 0.0)
	#	new_chat_selector_layout.modulate.a = selector_transition_progress
	
	#	if selector_opacity <= 0:
	#		new_chat_selector_layout.hide()
	
	#if current_state == DIRECT_CHAT and new_chat_selector_layout.visible == false:
	#	var direct_chat_opacity = new_direct_chat_layout.modulate.a
	#	direct_chat_opacity += (delta * FADE_SPEED)
	#	var direct_transition_progress  = min(direct_chat_opacity, 1.0)
	#	new_direct_chat_layout.modulate.a = direct_transition_progress
	#	transition_progress += direct_transition_progress
		
	#	if direct_chat_opacity >= 1:
	#		transition_in_progress = false
			
	#elif current_state == GROUP_CHAT and new_chat_selector_layout.visible == false:
	#	var group_chat_opacity = new_group_chat_layout.modulate.a
	#	group_chat_opacity += (delta * FADE_SPEED)
	#	var group_transition_progress  = min(group_chat_opacity, 1.0)
	#	new_group_chat_layout.modulate.a = group_transition_progress
	#	transition_progress += group_transition_progress
		
	#	if group_chat_opacity >= 1:
	#		transition_in_progress = false
	
	#var background_size_transition = (INPUT_CHAT_LAYOUT_SIZE - initial_background_bottom_offset) * (transition_progress * 0.5)
	#ackground.offset_bottom = background_size_transition + initial_background_bottom_offset

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

func create_new_direct_chat(partner_username: String):
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"partner_username" : partner_username,
		"creation_message" : AppSessionState.get_username() + " rozpoczął czat"
	}

	var result = create_new_direct_chat_request.request(
				create_new_direct_chat_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the direct chat creation HTTP request.")

func create_new_direct_chat_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Create direct chat response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Create direct chat response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	#TODO Add a code for already existing chat
	#TODO ITS exists not exsists
	if response_status["success"] == false:
		if response_status["status_message"] != "Direct chat already exsits!":
			print(response_status["status_message"])
			return
	
	GlobalSignals.new_chat_created.emit(response_data["chat_id"])
	reset_state()

func create_new_group_chat(title: String):
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"title" : title,
		"creation_message" : AppSessionState.get_username() + " stworzył czat"
	}

	var result = create_new_group_chat_request.request(
				create_new_group_chat_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the group chat creation HTTP request.")

func create_new_group_chat_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Create group chat response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Create group chat response was not a valid Json")
		return
	
	#Implement on success false
	var response_data = json_response.data
	var response_status =  response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return
	
	GlobalSignals.new_chat_created.emit(response_data["chat_id"])
	reset_state()

func _on_begin_direct_chat_button_pressed() -> void:
	var partner_username = direct_chat_username_input.get_value()
	create_new_direct_chat(partner_username)

func _on_begin_group_chat_button_pressed() -> void:
	var title: String = group_chat_title_input.text;
	title = title.strip_edges()
	
	if title.length() > MAX_GROUP_CHAT_TITLE_LENGHT:
		return #INFORM USER
	if title.length() < MIN_GROUP_CHAT_TITLE_LENGTH:
		return
		
	create_new_group_chat(title)

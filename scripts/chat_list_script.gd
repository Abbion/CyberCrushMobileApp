extends Control

const DIRECT_CHAT: int = 0
const GROUP_CHAT: int = 1

class ChatSortData:
	var chat_type: int
	var chat_id: int
	var time_stamp: Dictionary

@onready var chat_list = $ScrollContainer/chat_list
@onready var create_chat_overlay = $create_chat_overlay

signal open_chat(chat_id: int)

var chat_entry : PackedScene = load("res://scenes/custom_controlls/chat_entry.tscn")

var get_user_chats_request : HTTPRequest
const get_user_chats_url = "http://127.0.0.1:3003/get_user_chats"

func _ready() -> void:
	get_user_chats_request = HTTPRequest.new()
	get_user_chats_request.request_completed.connect(get_user_chats_request_completed)
	add_child(get_user_chats_request)
	get_user_chats()

func get_user_chats_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Get user chats response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Get user chats response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["message"])
		return
	
	var direct_chats = response_data["direct_chats"]
	var group_chats = response_data["group_chats"]
	
	var sorted_chats: Array
	
	for chat in direct_chats:
		if chat["last_message"] == null:
			continue
		
		var chat_to_sort: ChatSortData = ChatSortData.new()
		chat_to_sort.chat_type = DIRECT_CHAT
		chat_to_sort.chat_id = int(chat["chat_id"])		
		chat_to_sort.time_stamp = Time.get_datetime_dict_from_datetime_string(chat["last_message_time_stamp"], false)
		sorted_chats.push_back(chat_to_sort)
	
	for chat in group_chats:
		if chat["last_message"] == null:
			continue
		
		var chat_to_sort: ChatSortData = ChatSortData.new()
		chat_to_sort.chat_type = GROUP_CHAT
		chat_to_sort.chat_id = int(chat["chat_id"])
		chat_to_sort.time_stamp = Time.get_datetime_dict_from_datetime_string(chat["last_message_time_stamp"], false)
		sorted_chats.push_back(chat_to_sort)

	sorted_chats.sort_custom(func(a,b): 
		var a_timestamp: Dictionary = a.time_stamp;
		var b_timestamp: Dictionary = b.time_stamp;
		
		var time_a = [a_timestamp["year"], a_timestamp["month"], a_timestamp["day"], a_timestamp["hour"], a_timestamp["minute"], a_timestamp["second"]]
		var time_b = [b_timestamp["year"], b_timestamp["month"], b_timestamp["day"], b_timestamp["hour"], b_timestamp["minute"], b_timestamp["second"]]
		return time_a > time_b
	)
	
	print(direct_chats)
	
	for chat in sorted_chats:
		var chat_type = chat.chat_type
	
		if chat_type == DIRECT_CHAT:
			var direct_chat_index = direct_chats.find_custom(func(ch):
				if chat.chat_id == int(ch["chat_id"]):
					return true
				return false
			)
			
			if direct_chat_index < 0:
				print("Chat not found")
				continue
			
			var direct_chat = direct_chats[direct_chat_index]
			var chat_entry_instance = chat_entry.instantiate()
			chat_entry_instance.chat_id = direct_chat["chat_id"]
			chat_entry_instance.chat_title = direct_chat["chat_partner"]
			chat_entry_instance.last_message = direct_chat["last_message"]
			chat_entry_instance.last_timestamp = direct_chat["last_message_time_stamp"]
			chat_entry_instance.chat_opened.connect(on_chat_opened)
			chat_list.add_child(chat_entry_instance)
		else:
			var group_chat_index = group_chats.find_custom(func(ch):
				if chat.chat_id == int(ch["chat_id"]):
					return true
				return false
			)
			
			if group_chat_index < 0:
				print("Chat not found")
				continue
			
			var group_chat = group_chats[group_chat_index]
			var chat_entry_instance = chat_entry.instantiate()
			chat_entry_instance.chat_id = group_chat["chat_id"]
			chat_entry_instance.chat_title = group_chat["title"]
			chat_entry_instance.last_message = group_chat["last_message"]
			chat_entry_instance.last_timestamp = group_chat["last_message_time_stamp"]
			chat_entry_instance.chat_opened.connect(on_chat_opened)
			chat_list.add_child(chat_entry_instance)

func get_user_chats():
	var payload = {
		"token" : AppSessionState.get_server_token()
	}

	var result = get_user_chats_request.request(
				get_user_chats_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the user chats HTTP request.")


func _on_add_chat_pressed() -> void:
	create_chat_overlay.show()

func _on_new_chat_panel_closed() -> void:
	create_chat_overlay.hide()

func on_chat_opened(chat_id: int) -> void:
	open_chat.emit(chat_id);

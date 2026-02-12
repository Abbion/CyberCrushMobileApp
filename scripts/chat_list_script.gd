#Refactor 1
extends Control

const DIRECT_CHAT: int = 0
const GROUP_CHAT: int = 1

class ChatSortData:
	var chat_type: int
	var chat_id: int
	var time_stamp: Dictionary

@onready var chat_list = $chat_list_container/chat_list
@onready var overlay_margin = $overlay_margin
@onready var overlay_center_container = $overlay_margin/center_container

@onready var chat_list_container = $chat_list_container
@onready var spinner_container = $spinner_container
@onready var empty_chat_list_container = $empty_chat_list_container

@export var chat_entry : PackedScene

signal open_chat(chat_id: int)

func _ready() -> void:
	refresh_chat_list()

func update_chats_list():
	var user_chats := await ServerRequest.user_chats()
	if user_chats.is_empty():
		return
	var direct_chats = user_chats["direct"]
	var group_chats = user_chats["group"]
	
	clear_chats_list()
	var sorted_chats: Array
	
	for chat in direct_chats:
		if chat["last_message"] == null:
			continue
		
		var chat_to_sort := ChatSortData.new()
		chat_to_sort.chat_type = DIRECT_CHAT
		chat_to_sort.chat_id = int(chat["chat_id"])
		chat_to_sort.time_stamp = Time.get_datetime_dict_from_datetime_string(chat["last_message_time_stamp"], false)
		sorted_chats.push_back(chat_to_sort)
	
	for chat in group_chats:
		if chat["last_message"] == null:
			continue
		
		var chat_to_sort := ChatSortData.new()
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
	
	for chat in sorted_chats:
		var chat_type = chat.chat_type
	
		if chat_type == DIRECT_CHAT:
			var direct_chat_index = direct_chats.find_custom(func(ch):
				if chat.chat_id == int(ch["chat_id"]):
					return true
				return false
			)
			
			if direct_chat_index < 0:
				PopupDisplayServer.push_warning("Nie odnaleziono czatu bezpośredniego")
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
				PopupDisplayServer.push_warning("Nie odnaleziono czatu grupowego")
				continue
			
			var group_chat = group_chats[group_chat_index]
			var chat_entry_instance = chat_entry.instantiate()
			chat_entry_instance.chat_id = group_chat["chat_id"]
			chat_entry_instance.chat_title = group_chat["title"]
			chat_entry_instance.last_message = group_chat["last_message"]
			chat_entry_instance.last_timestamp = group_chat["last_message_time_stamp"]
			chat_entry_instance.chat_opened.connect(on_chat_opened)
			chat_list.add_child(chat_entry_instance)

func clear_chats_list() -> void:
	for entry in chat_list.get_children():
		chat_list.remove_child(entry)
		entry.queue_free()

func refresh_chat_list() -> void:
	spinner_container.show()
	chat_list_container.hide()
	empty_chat_list_container.hide()
	
	await update_chats_list()
	
	spinner_container.hide()
	chat_list_container.show()
	
	if chat_list.get_child_count() == 0:
		chat_list.hide()
		empty_chat_list_container.show()

func reset_layout() -> void:
	overlay_margin.hide()

func on_add_chat_pressed() -> void:
	overlay_margin.show()

func on_new_chat_panel_closed() -> void:
	reset_layout()

func on_chat_opened(chat_id: int) -> void:
	open_chat.emit(chat_id);

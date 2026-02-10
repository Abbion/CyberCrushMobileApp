extends Control

var chat_socket: WebSocketPeer
var socket_state: GlobalTypes.REALTIME_CHAT_SOCKET_STATE = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.NULL
var chat_id: int = -1
var chat_admin: String
var message_queue: Array
var anchor_message_log: bool = true
var lock_message_input_height: bool = false
var locketd_message_input_height: int = 0
var chunk_counter: int = 0
var scroll_to_new_chunk: bool = false

@onready var message_scroll_log: ScrollContainer = $board_margin/board/scroll_message_log
@onready var message_log: VBoxContainer  = $board_margin/board/scroll_message_log/message_log
@onready var title: Label = $board_margin/board/top_panel/HBoxContainer/title_margin/title
@onready var message_input: TextEdit = $board_margin/board/message_panel/message_input
@onready var chat_settings_button: Button = $board_margin/board/top_panel/HBoxContainer/chat_settings_button
@onready var settings_overlay: MarginContainer = $settings_overlay
@onready var message_board = $board

@export var chat_settings: PackedScene;
@export var message_entry: PackedScene

func load_chat_at_id(id: int) -> void:
	chat_id = id
	
	var metadata = await ServerRequest.chat_metadata(chat_id)
	if metadata.is_empty():
		close_chat()
		return
	
	update_meta_data(metadata)
	
	var chat_history = await ServerRequest.chat_history(chat_id)
	buld_chat_chunk(chat_history)

	chat_socket = WebSocketPeer.new()
	
	var connection_state = chat_socket.connect_to_url("ws://127.0.0.1:3003/realtime_chat")
	if connection_state == OK:
		socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CREATED
	else:
		PopupDisplayServer.push_error("Błąd podczas łączenia się z czatem")
		close_chat()
		return

func _ready() -> void:
	message_scroll_log.get_v_scroll_bar().connect("value_changed", on_scroll_value_changed)
	message_scroll_log.get_v_scroll_bar().connect("changed", on_scroll_changed)
	var v_scroll = message_scroll_log.get_v_scroll_bar()
	v_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if chat_socket == null or socket_state == GlobalTypes.REALTIME_CHAT_SOCKET_STATE.NULL:
		return
	
	chat_socket.poll()
	var state = chat_socket.get_ready_state()
	
	if state == WebSocketPeer.State.STATE_CONNECTING:
		return
	
	if state == WebSocketPeer.State.STATE_OPEN:
		match socket_state:
			GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CREATED:
				init_realtime_chat_connection()
			GlobalTypes.REALTIME_CHAT_SOCKET_STATE.INITIALIZED:
				confirm_realtime_chat_initialization()
			GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CONNECTED:
				if try_consume_new_messages() == false:
					close_chat()
					return
				if try_send_queued_messages() == false:
					close_chat()
					return
		if should_load_older_messages() == true:
			load_older_messages()

func init_realtime_chat_connection() -> void:
	var user_token = AppSessionState.get_server_token()
	var init = { "type": "init", "token": user_token, "chat_id": chat_id }
	var init_stirng = JSON.stringify(init, "", false)
	var send_status = chat_socket.send_text(init_stirng)
	
	if send_status == OK:
		socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.INITIALIZED
	else:
		PopupDisplayServer.push_error("Błąd inicjalizacji czatu")
		close_chat()

func confirm_realtime_chat_initialization() -> void:
	var initialization_confirmed: bool = false
	var packed_read = false
	
	while chat_socket.get_available_packet_count():
		var packet = chat_socket.get_packet().get_string_from_utf8()
		var json_packet = JSON.new()
		packed_read = true
		
		if json_packet.parse(packet) != OK:
			PopupDisplayServer.push_error("Otrzymano wiadomość, której nie udało się przetworzyć", "Potwierdzenie inicjalizacji się nie powiodło")
			continue
				
		var packet_data = json_packet.data
		if packet_data["type"] != "info":
			PopupDisplayServer.push_error("Połączenie z czatem się nie powiodło", "Typ pakietu: %s" % packet_data["type"])
			continue
		
		var packet_content: String = packet_data["text"]
		if  packet_content.contains("fail") == false:
			initialization_confirmed = true
			break
		else:
			PopupDisplayServer.push_error("Połączenie z czatem się nie powiodło", "Kod odpowiedzi: %s" % packet_data["response_code"])
	
	if packed_read == false:
		return
	
	if initialization_confirmed == true:
		socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CONNECTED
	else:
		PopupDisplayServer.push_error("Nie rozopznano członka czatu")
		close_chat()

func try_consume_new_messages() -> bool:
	var first_chunk = get_first_chunk()
	
	if first_chunk == null:
		PopupDisplayServer.push_error("Nie można odczytać nowych wiadomości", "First chunk was not found")
		close_chat()
		return false
	
	while chat_socket.get_available_packet_count():
		var packet = chat_socket.get_packet().get_string_from_utf8()
		var json_packet = JSON.new()
	
		if json_packet.parse(packet) != OK:
			PopupDisplayServer.push_error("Otrzymano wiadomość, której nie udało się przetworzyć", "Odczytanie nowej wiadomości nie powiodło się")
			return false
				
		var packet_data = json_packet.data
		var dateTime: GlobalTypes.DateTime = GlobalTypes.DateTime.from_string(packet_data["time_stamp"])
		var message_entry = create_message_entry(packet_data["in_chat_index"], packet_data["message"], packet_data["sender"], dateTime)
		first_chunk.add_child(message_entry)
		
	return true

func try_send_queued_messages() -> bool:
	var user_token = AppSessionState.get_server_token()
	while not message_queue.is_empty():
		var message_to_send = message_queue.pop_front()
		var message_packet = { "type": "msg", "token": user_token, "message": message_to_send }
		var message_packet_stirng = JSON.stringify(message_packet, "", false)
		var send_status = chat_socket.send_text(message_packet_stirng)
		
		if send_status != OK:
			PopupDisplayServer.push_error("Błąd podczas wysyłania wiadomości", "Status %s" % send_status)
			return false
	return true

func should_load_older_messages() -> bool:
	var scroll_value = message_scroll_log.scroll_vertical
	if scroll_value > 0:
		return false
		
	var last_chat_chunk = message_log.get_child(0)
	var last_message = last_chat_chunk.get_child(0)
	if last_message == null:
		return false
	
	if last_message.in_chat_index == 0:
		return false
	
	return true

#load_older_messages variable seciton
var lock_requesting_chat_history = false
#------------------

#TODO pass the index to not look for last message twice
func load_older_messages() -> void:
	if lock_requesting_chat_history == true:
		return
		
	lock_requesting_chat_history = true
	
	var last_chat_chunk = message_log.get_child(0)
	var last_message = last_chat_chunk.get_child(0)
	if last_message == null:
		return
	
	var last_message_index = last_message.in_chat_index
	var new_messages = await ServerRequest.chat_history(chat_id, last_message_index)
	buld_chat_chunk(new_messages)
	scroll_to_new_chunk = true
	
	lock_requesting_chat_history = false

func buld_chat_chunk(messages: Array) -> void:
	var chunk = VBoxContainer.new()
	chunk.name = "chunk_%s" % chunk_counter
	chunk_counter += 1
	fill_chunk(chunk, messages)
	message_log.add_child(chunk)
	message_log.move_child(chunk, 0)

func fill_chunk(chunk: VBoxContainer, messages: Array) -> void:
	for message in messages:
		var dateTime: GlobalTypes.DateTime = GlobalTypes.DateTime.from_string(message["time_stamp"])
		var message_entry = create_message_entry(message["in_chat_index"], message["message"], message["sender"], dateTime)
		chunk.add_child(message_entry)

func update_meta_data(metadata: Dictionary) -> void:
	var username = AppSessionState.get_username()
	var chat_type: GlobalTypes.CHAT_TYPE = GlobalTypes.CHAT_TYPE.DIRECT
	
	if metadata.has("Group"):
		chat_type = GlobalTypes.CHAT_TYPE.GROUP
		
	if chat_type == GlobalTypes.CHAT_TYPE.GROUP:
		var group_chat_metadata = metadata["Group"]
		chat_admin = group_chat_metadata["admin_username"]
		if username == chat_admin:
			chat_settings_button.show()
		
		title.text = group_chat_metadata["title"]
	else:
		var direct_chat_metadata = metadata["Direct"]
		var username_a = direct_chat_metadata["username_a"]
		var username_b = direct_chat_metadata["username_b"]
		var partner = username_a
		
		if partner == username:
			partner = username_b
			
		title.text = partner
	pass

func clear_chat() -> void:
	chunk_counter = 0
	for entry in message_log.get_children():
		message_log.remove_child(entry)
		entry.queue_free()

func disconnect_from_chat() -> void:
	if chat_socket != null:
		chat_socket.close()
	socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CLOSED
	chat_id = -1
	message_queue.clear()

func _on_back_button_pressed() -> void:
	close_chat()

func _on_message_send_button_pressed() -> void:
	var message_to_send = message_input.get_cleaned_text()
	message_to_send = message_to_send.strip_edges()
	
	if message_to_send.is_empty():
		message_input.text = ""
		return
	
	var first_chunk = get_first_chunk()
	if first_chunk == null:
		PopupDisplayServer.push_error("Nie można wysłać waidomości", "First chunk was not found")
		close_chat()
		return
	
	var username = AppSessionState.get_username()
	var date_time = GlobalTypes.DateTime.now()
	var message_entry = create_message_entry(-1, message_to_send, username, date_time)
	first_chunk.add_child(message_entry)
	message_queue.push_back(message_to_send)
	message_input.text = ""
	
	anchor_message_log = true

func create_message_entry(index: int, message: String, sender: String, dateTime: GlobalTypes.DateTime):
	var username = AppSessionState.get_username()
	var message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT
	var size_flag = Control.SIZE_SHRINK_BEGIN
	var container_width = size.x
	
	if sender == username:
		message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.RIGHT
		size_flag = Control.SIZE_SHRINK_END
		
	var message_entry = message_entry.instantiate()
	message_entry.message_alignment = message_alignment
	message_entry.message_text = message
	message_entry.timestamp = dateTime
	message_entry.sender_username = sender
	message_entry.in_chat_index = index
	message_entry.size_flags_horizontal = size_flag
	message_entry.container_width = container_width
	return message_entry

func scroll_to_bottom() -> void:
	var max_value = message_scroll_log.get_v_scroll_bar().max_value
	message_scroll_log.scroll_vertical = int(max_value)

func scroll_to_chunk(chunk_index: int) -> void:
	var chunk = message_log.get_child(chunk_index)
	if chunk == null:
		return
	
	message_scroll_log.scroll_vertical = chunk.size.y

func _on_chat_settings_button_pressed() -> void:
	settings_overlay.show()
	
	var settings = chat_settings.instantiate()
	settings.chat_id = chat_id
	settings.connect("closed", settings_panel_closed)
	await settings.initialize()
	settings_overlay.add_child(settings)

func settings_panel_closed(settings: Node) -> void:
	settings_overlay.hide()
	settings_overlay.remove_child(settings)
	settings.queue_free()

func close_chat() -> void:
	disconnect_from_chat();
	clear_chat();
	GlobalSignals.close_chat_board.emit()

func _on_tree_exiting() -> void:
	close_chat()

func on_scroll_value_changed(value: float) -> void:
	var scroll_message_log_height = message_scroll_log.size.y
	var max_value = message_scroll_log.get_v_scroll_bar().max_value
	
	if scroll_message_log_height > max_value:
		return
	
	if value == (max_value - scroll_message_log_height):
		anchor_message_log = true
	else:
		anchor_message_log = false

func on_scroll_changed() -> void:
	if anchor_message_log == true:
		scroll_to_bottom()
	if scroll_to_new_chunk == true:
		scroll_to_chunk(0)
		var v_scroll = message_scroll_log.get_v_scroll_bar()
		scroll_to_new_chunk = false

func get_first_chunk() -> VBoxContainer:
	return message_log.get_child(chunk_counter - 1)

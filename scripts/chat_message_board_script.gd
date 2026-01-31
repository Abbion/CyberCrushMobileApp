extends Control

var chat_socket: WebSocketPeer
var socket_state: GlobalTypes.REALTIME_CHAT_SOCKET_STATE = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.NULL
var chat_id: int = -1
var chat_admin: String
var message_queue: Array

@onready var message_scroll_log: ScrollContainer = $board/scroll_message_log
@onready var message_log: VBoxContainer  = $board/scroll_message_log/message_log
@onready var title: Label = $board/top_panel/HBoxContainer/title
@onready var message_input: TextEdit = $board/message_panel/message_input
@onready var chat_settings_button: Button = $board/top_panel/HBoxContainer/chat_settings_button
@onready var overlay: ColorRect = $overlay
@onready var message_board = $board

@export var chat_settings: PackedScene;
@export var message_entry: PackedScene
var anchor_message_log = true

func load_chat_at_id(id: int) -> void:
	#TODO After every call check if the id is VALID!!!!
	var metadata = await ServerRequest.chat_metadata(id)
	update_meta_data(metadata)
	
	var chat_history = await ServerRequest.chat_history(id)
	build_message_log(chat_history)

	chat_id = id
	chat_socket = WebSocketPeer.new()
	#TODO check the connection_state
	var connection_state = chat_socket.connect_to_url("ws://127.0.0.1:3003/realtime_chat")
	socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CREATED

func _ready() -> void:
	message_scroll_log.get_v_scroll_bar().connect("value_changed", on_scroll_value_changed)
	message_scroll_log.get_v_scroll_bar().connect("changed", on_scroll_changed)

func _process(delta: float) -> void:
	message_board.anchor_bottom = HelperFunctions.virtual_keyboard_normalized_size_from_bottom(AppSessionState.app_selector_height)
	
	if chat_socket == null:
		return
		
	message_log.modulate.a = 1.0
	
	chat_socket.poll()
	var state = chat_socket.get_ready_state()
	
	if state == WebSocketPeer.State.STATE_CONNECTING:
		return
	
	if state == WebSocketPeer.State.STATE_OPEN:
		if socket_state == GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CREATED:
			var user_token = AppSessionState.get_server_token()
			var init = { "type": "init", "token": user_token, "chat_id": chat_id }
			var init_stirng = JSON.stringify(init, "", false)
			#TODO check send_status
			var send_status = chat_socket.send_text(init_stirng)
			socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.INITIALIZED
		if socket_state == GlobalTypes.REALTIME_CHAT_SOCKET_STATE.INITIALIZED:
			while chat_socket.get_available_packet_count():
				var packet = chat_socket.get_packet().get_string_from_utf8()
				var json_packet = JSON.new()
	
				if json_packet.parse(packet) != OK:
					#TODO close connection and exit
					print("Packet cannot be read")
					return
				
				var packet_data = json_packet.data
				if packet_data["type"] != "info":
					#TODO close connection and exit
					return
				
				#if packet_data["response_code"] != "ConnectionSuccess":
					#TODO close connection and exit
					#return
				
				socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CONNECTED
		if socket_state == GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CONNECTED:
			var user_token = AppSessionState.get_server_token()
			
			while chat_socket.get_available_packet_count():
				var packet = chat_socket.get_packet().get_string_from_utf8()
				var json_packet = JSON.new()
	
				if json_packet.parse(packet) != OK:
					#TODO close connection and exit
					print("Packet cannot be read")
					return
				
				var packet_data = json_packet.data
				
				print("Packet: ", packet_data)
				var dateTime: GlobalTypes.DateTime = GlobalTypes.DateTime.from_string(packet_data["time_stamp"])
				create_message_entry(packet_data["message"], packet_data["sender"], dateTime)
			
			while not message_queue.is_empty():
				var message_to_send = message_queue.pop_front()
				var message_packet = { "type": "msg", "token": user_token, "message": message_to_send }
				var message_packet_stirng = JSON.stringify(message_packet, "", false)
				#TODO check send_status
				var send_status = chat_socket.send_text(message_packet_stirng)
				
				print("send status: ", send_status)
	

func build_message_log(messages: Array):
	for message in messages:
		var dateTime: GlobalTypes.DateTime = GlobalTypes.DateTime.from_string(message["time_stamp"])
		create_message_entry(message["message"], message["sender"], dateTime)

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
	for entry in message_log.get_children():
		message_log.remove_child(entry)
		entry.queue_free()

func disconnect_from_chat() -> void:
	chat_socket.close()
	socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CLOSED
	chat_id = -1
	message_queue.clear()

func _on_back_button_pressed() -> void:
	GlobalSignals.close_chat_board.emit()

func _on_message_send_button_pressed() -> void:
	var message_to_send = message_input.text
	message_to_send = message_to_send.strip_edges()
	
	if message_to_send.is_empty():
		message_input.text = ""
		return
	
	var username = AppSessionState.get_username()
	var date_time = GlobalTypes.DateTime.now()
	create_message_entry(message_to_send, username, date_time)
	message_queue.push_back(message_to_send)
	message_input.text = ""
	
	anchor_message_log = true

func create_message_entry(message: String, sender: String, dateTime: GlobalTypes.DateTime):
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
	message_entry.timestamp_text = dateTime.get_string()
	message_entry.sender_username = sender
	message_entry.size_flags_horizontal = size_flag
	message_entry.container_width = container_width
	message_log.add_child(message_entry)

func scroll_to_bottom() -> void:
	if anchor_message_log == true:
		var max_value = message_scroll_log.get_v_scroll_bar().max_value
		message_scroll_log.scroll_vertical = int(max_value)

func _on_chat_settings_button_pressed() -> void:
	overlay.show()
	
	var settings = chat_settings.instantiate()
	settings.chat_id = chat_id
	settings.connect("closed", settings_panel_closed)
	await settings.initialize()
	overlay.add_child(settings)

func settings_panel_closed() -> void:
	overlay.hide()
	
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()

func close_chat() -> void:
	disconnect_from_chat();
	clear_chat();

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
	scroll_to_bottom()

func _on_scroll_message_log_resized() -> void:
	scroll_to_bottom()

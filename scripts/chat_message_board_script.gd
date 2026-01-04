extends Control

var message_entry: PackedScene = preload("res://scenes/custom_controlls/chat_message_entry.tscn")

var get_chat_history_request : HTTPRequest
const get_chat_history_url = "http://127.0.0.1:3003/get_chat_history"

var get_chat_metadata_request : HTTPRequest
var get_chat_metadata_url = "http://127.0.0.1:3003/get_chat_metadata"

var update_group_chat_member_request : HTTPRequest
var update_group_chat_member_url = "http://127.0.0.1:3003/update_group_chat_member"

var chat_socket: WebSocketPeer
var socket_state: GlobalTypes.REALTIME_CHAT_SOCKET_STATE = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.NULL
var chat_id: int = -1
var message_queue: Array

@onready var message_log: VBoxContainer = $message_log
@onready var title: Label = $top_panel/title
@onready var message_input: TextEdit = $message_panel/message_input

signal exit_chat

func _ready() -> void:
	get_chat_history_request = HTTPRequest.new()
	get_chat_history_request.request_completed.connect(get_chat_history_request_completed)
	add_child(get_chat_history_request)
	
	get_chat_metadata_request = HTTPRequest.new()
	get_chat_metadata_request.request_completed.connect(get_chat_metadata_request_completed)
	add_child(get_chat_metadata_request)
	
	update_group_chat_member_request = HTTPRequest.new()
	update_group_chat_member_request.request_completed.connect(update_group_chat_member_request_completed)
	add_child(update_group_chat_member_request)

func load_chat_at_id(id: int) -> void:
	#TODO After every call check if the id is VALID!!!!
	get_chat_metadata_at_id(id)
	get_chat_history_at_id(id)
	chat_id = id
	chat_socket = WebSocketPeer.new()
	#TODO check the connection_state
	var connection_state = chat_socket.connect_to_url("ws://127.0.0.1:3003/realtime_chat")
	socket_state = GlobalTypes.REALTIME_CHAT_SOCKET_STATE.CREATED

func _process(delta: float) -> void:
	if chat_socket == null:
		return
	
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
				
				if packet_data["response_code"] != "ConnectionSuccess":
					#TODO close connection and exit
					return
				
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
			
			while not message_queue.is_empty():
				var message_to_send = message_queue.pop_front()
				var message_packet = { "type": "msg", "token": user_token, "message": message_to_send }
				var message_packet_stirng = JSON.stringify(message_packet, "", false)
				#TODO check send_status
				var send_status = chat_socket.send_text(message_packet_stirng)
				print("send status: ", send_status)
	
	#print("ss: ", state)
	#print("sw: ", socket_state)
	#chat_socket.send_text(init_stirng)
	#chat_socket.poll()

func build_message_log(messages):
	for message in messages:
		var dateTime: GlobalTypes.DateTime = GlobalTypes.DateTime.from_string(message["time_stamp"])
		create_message_entry(message["message"], message["sender"], dateTime)

func update_meta_data(metadata: Dictionary) -> void:
	var chat_type: GlobalTypes.CHAT_TYPE = GlobalTypes.CHAT_TYPE.DIRECT
	print(metadata)
	
	if metadata.has("Group"):
		chat_type = GlobalTypes.CHAT_TYPE.GROUP
		
	if chat_type == GlobalTypes.CHAT_TYPE.GROUP:
		var group_chat_metadata = metadata["Group"]
		title.text = group_chat_metadata["chat_title"]
	else:
		var username = AppSessionState.get_username()
		var direct_chat_metadata = metadata["Direct"]
		var username_a = direct_chat_metadata["username_a"]
		var username_b = direct_chat_metadata["username_b"]
		var partner = username_a
		
		if partner == username:
			partner = username_b
			
		title.text = partner
	pass

func get_chat_history_at_id(id: int):
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : id,
		"history_time_stamp" : null
	}

	var result = get_chat_history_request.request(
				get_chat_history_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the user chat history HTTP request.")

func get_chat_history_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Get user chat history response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Get user chat history response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return
		
	build_message_log(response_data["messages"])

func get_chat_metadata_at_id(id: int):
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : id,
	}

	var result = get_chat_metadata_request.request(
				get_chat_metadata_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the chat metadata HTTP request.")

func get_chat_metadata_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Get chat metadata response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Get chat metadata response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return
	
	update_meta_data(response_data["metadata"])

func update_group_chat_member():
	var payload = {
		"admin_token" : AppSessionState.get_server_token(),
		"chat_id" : 2,
		"update": {
			"action": "AddMember",
			#"action": "DeleteMember",
			"username": "Amadeus"
		}
	}
	
	print("JSON", JSON.stringify(payload))

	var result = update_group_chat_member_request.request(
				update_group_chat_member_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the update group chat member HTTP request.")
	pass

func update_group_chat_member_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Update group chat member response code: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Update group chat member response was not a valid Json")
		return
	
	var response_data = json_response.data
	print("Update group chat member response body: ", response_data)

func _on_back_button_pressed() -> void:
	for entry in message_log.get_children():
		message_log.remove_child(entry)
		entry.queue_free()
	
	title.text = ""
	exit_chat.emit()

func _on_message_send_button_pressed() -> void:
	var message_to_send = message_input.text
	if message_to_send.is_empty():
		return
	
	var username = AppSessionState.get_username()
	var date_time = GlobalTypes.DateTime.now()
	create_message_entry(message_to_send, username, date_time)
	message_queue.push_back(message_to_send)
	message_input.text = ""

func create_message_entry(message: String, sender: String, dateTime: GlobalTypes.DateTime):
	var username = AppSessionState.get_username()
	var message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.LEFT
	if sender == username:
		message_alignment = GlobalTypes.CHAT_MESSAGE_ALIGNMENT.RIGHT
		
	var message_entry = message_entry.instantiate()
	message_entry.message_alignment = message_alignment
	message_entry.message_text = message
	message_entry.timestamp_text = dateTime.get_string()
	message_log.add_child(message_entry)

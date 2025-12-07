extends Control

var get_all_usernames_request : HTTPRequest
const get_all_usernames_url = "http://127.0.0.1:3001/get_all_usernames"

var get_chat_history_request : HTTPRequest
const get_chat_history_url = "http://127.0.0.1:3003/get_chat_history"

var create_new_direct_chat_request : HTTPRequest
const create_new_direct_chat_url = "http://127.0.0.1:3003/create_new_direct_chat"

var create_new_group_chat_request : HTTPRequest
const create_new_group_chat_url = "http://127.0.0.1:3003/create_new_group_chat"

var get_chat_metadata_request : HTTPRequest
var get_chat_metadata_url = "http://127.0.0.1:3003/get_chat_metadata"

var update_group_chat_member_request : HTTPRequest
var update_group_chat_member_url = "http://127.0.0.1:3003/update_group_chat_member"

@onready var bank_panel = $VBoxContainer/PanelContainer/bank_panel
@onready var my_id_panel = $VBoxContainer/PanelContainer/my_id_panel

func _ready() -> void:	
	get_all_usernames_request = HTTPRequest.new()
	get_all_usernames_request.request_completed.connect(get_all_usernames_request_completed)
	add_child(get_all_usernames_request)
	#get_all_usernames()
	
	get_chat_history_request = HTTPRequest.new()
	get_chat_history_request.request_completed.connect(get_chat_history_request_completed)
	add_child(get_chat_history_request)
	#get_chat_history();
	
	get_chat_metadata_request = HTTPRequest.new()
	get_chat_metadata_request.request_completed.connect(get_chat_metadata_request_completed)
	add_child(get_chat_metadata_request)
	#get_chat_metadata()
	
	create_new_direct_chat_request = HTTPRequest.new()
	create_new_direct_chat_request.request_completed.connect(create_new_direct_chat_request_completed)
	add_child(create_new_direct_chat_request)
	#create_new_direct_chat()
	
	create_new_group_chat_request = HTTPRequest.new()
	create_new_group_chat_request.request_completed.connect(create_new_group_chat_request_completed)
	add_child(create_new_group_chat_request)
	#create_new_group_chat()
	
	update_group_chat_member_request = HTTPRequest.new()
	update_group_chat_member_request.request_completed.connect(update_group_chat_member_request_completed)
	add_child(update_group_chat_member_request)
	#update_group_chat_member()

func get_all_usernames():
	var result = get_all_usernames_request.request(get_all_usernames_url)
	if result != OK:
		print("An error occured in the HTTP request.")

func get_all_usernames_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Usernames data: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Login response was not a valid Json")
		return
	
	var response_data = json_response.data
	print(response_data)

func get_chat_history():
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : 2,
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
	print("Get user chat history response body: ", response_data)

func get_chat_metadata():
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : 2,
	}

	var result = get_chat_history_request.request(
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
	print("Get chat metadata response body: ", response_data)

func create_new_direct_chat():
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"partner_username" : "Victor",
		"first_message" : "Hello xoxo"
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
	print("Create direct chat response body: ", response_data)

func create_new_group_chat():
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"title" : "Black mass group"
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
	
	var response_data = json_response.data
	print("Create group chat response body: ", response_data)

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


func _on_app_selector_bank_selected() -> void:
	bank_panel.visible = true
	my_id_panel.visible = false

func _on_app_selector_my_id_selected() -> void:
	my_id_panel.visible = true
	bank_panel.visible = false

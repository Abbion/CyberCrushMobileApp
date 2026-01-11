extends Node

enum GroupChatUpdateAction {
	ADD_MEMBER,
	REMOVE_MEMBER
}

const login_url = "http://127.0.0.1:3000/login"
var login_request:  HTTPRequest

const token_validation_url = "http://127.0.0.1:3000/validate_token"
var validation_request: HTTPRequest

const get_user_data_url = "http://127.0.0.1:3001/get_user_data"
var user_data_request: HTTPRequest

const get_all_usernames_url = "http://127.0.0.1:3001/get_all_usernames"
var get_all_usernames_request : HTTPRequest

const get_user_chats_url = "http://127.0.0.1:3003/get_user_chats"
var get_user_chats_request : HTTPRequest

const get_chat_history_url = "http://127.0.0.1:3003/get_chat_history"
var get_chat_history_request : HTTPRequest

const get_chat_metadata_url = "http://127.0.0.1:3003/get_chat_metadata"
var get_chat_metadata_request : HTTPRequest

const update_group_chat_member_url = "http://127.0.0.1:3003/update_group_chat_member"
var update_group_chat_member_request : HTTPRequest

const create_direct_chat_url = "http://127.0.0.1:3003/create_new_direct_chat"
var create_direct_chat_request : HTTPRequest

const create_group_chat_url = "http://127.0.0.1:3003/create_new_group_chat"
var create_group_chat_request : HTTPRequest

const get_user_funds_url = "http://127.0.0.1:3002/get_user_funds"
var get_user_funds_request : HTTPRequest

const transfer_funds_url = "http://127.0.0.1:3002/transfer_funds"
var transfer_funds_request : HTTPRequest

const get_user_transaction_history_url = "http://127.0.0.1:3002/get_user_transaction_history"
var get_user_transaction_history_request : HTTPRequest

func _ready() -> void:
	login_request = HTTPRequest.new()
	add_child(login_request)
	
	validation_request = HTTPRequest.new()
	add_child(validation_request)
	
	user_data_request = HTTPRequest.new()
	add_child(user_data_request)
	
	get_all_usernames_request = HTTPRequest.new()
	add_child(get_all_usernames_request)
	
	get_user_chats_request = HTTPRequest.new()
	add_child(get_user_chats_request)
	
	get_chat_history_request = HTTPRequest.new()
	add_child(get_chat_history_request)
	
	get_chat_metadata_request = HTTPRequest.new()
	add_child(get_chat_metadata_request)
	
	update_group_chat_member_request = HTTPRequest.new()
	add_child(update_group_chat_member_request)
	
	create_direct_chat_request = HTTPRequest.new()
	add_child(create_direct_chat_request)
	
	create_group_chat_request = HTTPRequest.new()
	add_child(create_group_chat_request)
	
	get_user_funds_request = HTTPRequest.new()
	add_child(get_user_funds_request)
	
	transfer_funds_request = HTTPRequest.new()
	add_child(transfer_funds_request)
	
	get_user_transaction_history_request = HTTPRequest.new()
	add_child(get_user_transaction_history_request)

func login(username: String, password: String) -> String:
	#=Request=============================================================
	var payload = {
		"username" : username,
		"password" : password
	}
	
	var request_state = login_request.request(login_url,
				GlobalConstants.JSON_HTTP_HEADER, 
				HTTPClient.METHOD_POST, 
				JSON.stringify(payload))
				
	if request_state != OK:
		print("Login failed. HTTP request state: %s" % [request_state])
		return ""
	var response = await login_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Login failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return ""
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Login failed. Json cannot parse response")
		return ""
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_data["status_message"])
		return ""
	
	var token = response_data["token"]
	return token

func validate_token(token: String) -> bool:
	#=Request=============================================================
	var payload = {
		"token" : token,
	}

	var request_state = validation_request.request(token_validation_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Validateing user token failed. HTTP request state: %s" % [request_state])
		return false
	
	var response = await validation_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Validateing user token failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Validateing user token failed. Json cannot parse response")
		return false
	
	var response_data = json_response.data
	if response_data["success"] == false:
		print(response_data["status_message"])
		return false
		
	return true

func user_data() -> GlobalTypes.UserData:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var request_state = user_data_request.request(get_user_data_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting user data failed. HTTP request state: %s" % [request_state])
		return null
	
	var response = await user_data_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting user data failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return null
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting user data failed. Json cannot parse response")
		return null
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return null
	
	var user_data = GlobalTypes.UserData.new()
	user_data.username = response_data["username"]
	user_data.personal_number = response_data["personal_number"]
	
	var json_extra_data = JSON.new()
	if json_extra_data.parse(response_data["extra_data"]) != OK:
		print("Getting user data failed. Json cannot parse extra data")
	
	user_data.extra_data = json_extra_data.data
	return user_data

func all_usernames() -> PackedStringArray:
	#=Request=============================================================
	var request_state = get_all_usernames_request.request(get_all_usernames_url)
	
	if request_state != OK:
		print("Getting all usernames failed. HTTP request state: %s" % request_state)
		return PackedStringArray()
	
	var response = await get_all_usernames_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting all usernames failed. HTTP response state: %s code: %s" % 
			[response_state, response_code])
		return PackedStringArray()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting all usernames failed. Json cannot parse response")
		return PackedStringArray()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return PackedStringArray()
	
	return response_data["usernames"]

func user_chats() -> Dictionary:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token()
	}

	var request_state = get_user_chats_request.request(
				get_user_chats_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting user chats failed. HTTP request state: %s" % [request_state])
		return Dictionary()
	
	var response = await get_user_chats_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting user chats failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return Dictionary()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting user chats failed. Json cannot parse response")
		return Dictionary()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return Dictionary()
	
	var user_chats: Dictionary = Dictionary()
	user_chats.set("direct", response_data["direct_chats"])
	user_chats.set("group", response_data["group_chats"])
	
	return user_chats

func chat_metadata(chat_id: int) -> Dictionary:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : chat_id,
	}

	var request_state = get_chat_metadata_request.request(
				get_chat_metadata_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting chat %s metadata failed. HTTP request state: %s" % [chat_id, request_state])
		return Dictionary()
	
	var response = await get_chat_metadata_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting chat %s metadata failed. HTTP response state: %s code: %s" %
				[chat_id, response_state, response_code])
		return Dictionary()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting chat %s metadata failed. Json cannot parse response" % chat_id)
		return Dictionary()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return Dictionary()
		
	return response_data["metadata"]

func chat_history(chat_id: int) -> Array:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"chat_id" : chat_id,
		"history_time_stamp" : null
	}

	var request_state = get_chat_history_request.request(
				get_chat_history_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting chat %s history failed. HTTP request state: %s" % [chat_id, request_state])
		return Array()
	
	var response = await get_chat_history_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting chat %s history failed. HTTP response state: %s code: %s" %
				[chat_id, response_state, response_code])
		return Array()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting chat %s history failed. Json cannot parse response" % chat_id)
		return Array()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return Array()
		
	return response_data["messages"]

func update_group_chat_member(chat_id: int, action: GroupChatUpdateAction, username: String) -> bool:
	#=Request=============================================================
	var action_string: String = "AddMember" if action == GroupChatUpdateAction.ADD_MEMBER else "DeleteMember"
	
	var payload = {
		"admin_token" : AppSessionState.get_server_token(),
		"chat_id" : chat_id,
		"update": {
			"action": action_string,
			"username": username
		}
	}

	var request_state = update_group_chat_member_request.request(
				update_group_chat_member_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Updateing group chat %s members failed. HTTP request state: %s" % [chat_id, request_state])
		return false
	
	var response = await update_group_chat_member_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Updateing group chat %s members failed. HTTP response state: %s code: %s" %
				[chat_id, response_state, response_code])
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Updateing group chat %s members failed.. Json cannot parse response" % chat_id)
		return false
	
	var response_status = json_response.data
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return false
	
	return true;

func create_direct_chat(partner_username: String) -> int:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"partner_username" : partner_username,
		"creation_message" : AppSessionState.get_username() + " rozpoczął czat"
	}

	var request_state = create_direct_chat_request.request(create_direct_chat_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Creating direct chat failed. HTTP request state: %s" % request_state)
		return -1
	
	var response = await create_direct_chat_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Creating direct chat failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return -1
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Creating direct chat failed. Json cannot parse response")
		return -1
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return -1
	
	return response_data["chat_id"]

func create_group_chat(title: String) -> int:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"title" : title,
		"creation_message" : AppSessionState.get_username() + " stworzył czat"
	}

	var request_state = create_group_chat_request.request(create_group_chat_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Creating group chat failed. HTTP request state: %s" % request_state)
		return -1
	
	var response = await create_group_chat_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Creating group chat failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return -1
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Creating group chat failed. Json cannot parse response")
		return -1
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return -1
	
	return response_data["chat_id"]

func bank_funds() -> int:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var request_state = get_user_funds_request.request(get_user_funds_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting bank funds failed. HTTP request state: %s" % request_state)
		return 0
	
	var response = await get_user_funds_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting bank funds failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return 0
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting bank funds failed. Json cannot parse response")
		return 0
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return 0
	
	return int(response_data["funds"])

func transfer_funds(receiver: String, title: String, amount: int) -> bool:
	#=Request=============================================================
	var payload = {
		"sender_token" : AppSessionState.get_server_token(),
		"receiver_username" : receiver,
		"message" : title,
		"amount" : amount
	}

	var request_state = transfer_funds_request.request(transfer_funds_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Transfering funds failed. HTTP request state: %s" % request_state)
		return false
	
	var response = await transfer_funds_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Transfering funds failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Transfering funds failed. Json cannot parse response")
		return false
	
	var response_data = json_response.data
	
	if response_data["success"] == false:
		print(response_data["status_message"])
		return false
	
	return true

func bank_transaction_history() -> Array:
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var request_state = get_user_transaction_history_request.request(
				get_user_transaction_history_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		print("Getting bank transaction history failed. HTTP request state: %s" % request_state)
		return Array()
	
	var response = await get_user_transaction_history_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		print("Getting bank transaction history failed. HTTP response state: %s code: %s" %
				[response_state, response_code])
		return Array()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Getting bank transaction history failed. Json cannot parse response")
		return Array()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return Array()
	
	return response_data["transactions"]

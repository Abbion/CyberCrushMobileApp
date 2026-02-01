extends Node

#TODO Add time outs to requests

enum GroupChatUpdateAction {
	ADD_MEMBER,
	REMOVE_MEMBER
}

const dev_ip = "127.0.0.1"
const local_ip = "192.168.50.162"
const current_ip = dev_ip

const REQUEST_STATE_ERROR: String = "Nie znaleziono serwera"
const RESPONSE_STATE_ERROR: String = "Błąd opowiedzi"
const JSON_PARSE_ERROR: String = "Niepoprawny format danych"
const RESPONSE_STATUS_ERROR: String = "Błąd dostępu do danych"

const login_url = "http://%s:3000/login" % current_ip
var login_request:  HTTPRequest

const token_validation_url = "http://%s:3000/validate_token" % current_ip
var validation_request: HTTPRequest

const get_user_data_url = "http://%s:3001/get_user_data" % current_ip
var user_data_request: HTTPRequest

const get_all_usernames_url = "http://%s:3001/get_all_usernames" % current_ip
var get_all_usernames_request : HTTPRequest

const get_user_chats_url = "http://%s:3003/get_user_chats" % current_ip
var get_user_chats_request : HTTPRequest

const get_chat_history_url = "http://%s:3003/get_chat_history" % current_ip
var get_chat_history_request : HTTPRequest

const get_chat_metadata_url = "http://%s:3003/get_chat_metadata" % current_ip
var get_chat_metadata_request : HTTPRequest

const update_group_chat_member_url = "http://%s:3003/update_group_chat_member" % current_ip
var update_group_chat_member_request : HTTPRequest

const create_direct_chat_url = "http://%s:3003/create_new_direct_chat" % current_ip
var create_direct_chat_request : HTTPRequest

const create_group_chat_url = "http://%s:3003/create_new_group_chat" % current_ip
var create_group_chat_request : HTTPRequest

const get_user_funds_url = "http://%s:3002/get_user_funds" % current_ip
var get_user_funds_request : HTTPRequest

const transfer_funds_url = "http://%s:3002/transfer_funds" % current_ip
var transfer_funds_request : HTTPRequest

const get_user_transaction_history_url = "http://%s:3002/get_user_transaction_history" % current_ip
var get_user_transaction_history_request : HTTPRequest

const get_news_feed_url = "http://%s:3004/get_news_feed" % current_ip
var get_news_feed_request: HTTPRequest

const post_news_article_url = "http://%s:3004/post_news_article" % current_ip
var post_news_article_request: HTTPRequest

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
	
	get_news_feed_request = HTTPRequest.new()
	add_child(get_news_feed_request)
	
	post_news_article_request = HTTPRequest.new()
	add_child(post_news_article_request)

func login(username: String, password: String) -> String:
	const LOGIN_ERROR = "Błąd logowania"
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
		var error_message = "%s. %s" % [LOGIN_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Login failed. HTTP request state: %s" % [request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return ""
	var response = await login_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [LOGIN_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Login failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return ""
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [LOGIN_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return ""
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. Nie rozpoznano nazwy użytkownika lub hasła" % LOGIN_ERROR
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return ""
	
	var token = response_data["token"]
	return token

func validate_token(token: String) -> bool:
	const TOKEN_VALIDATION_ERROR = "Błąd uwierzytelniania"
	#=Request=============================================================
	var payload = {
		"token" : token,
	}

	var request_state = validation_request.request(token_validation_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		var error_message = "%s. %s" % [TOKEN_VALIDATION_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Validateing user token failed. HTTP request state: %s" % [request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	var response = await validation_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [TOKEN_VALIDATION_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Validateing user token failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [TOKEN_VALIDATION_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return false
	
	var response_data = json_response.data
	if response_data["success"] == false:
		var error_message = "%s. Nie rozpoznano użytkownika" % TOKEN_VALIDATION_ERROR
		var verbose = response_data["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
		
	return true

func user_data() -> GlobalTypes.UserData:
	const USER_DATA_ERROR = "Bład dostępu do danych użytkownika"
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var request_state = user_data_request.request(get_user_data_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		var error_message = "%s. %s" % [USER_DATA_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting user data failed. HTTP request state: %s" % [request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return null
	
	var response = await user_data_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:				
		var error_message = "%s. %s" % [USER_DATA_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting user data failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return null
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [USER_DATA_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return null
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [USER_DATA_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return null
	
	var user_data = GlobalTypes.UserData.new()
	user_data.username = response_data["username"]
	user_data.personal_number = response_data["personal_number"]
	
	var json_extra_data = JSON.new()
	if json_extra_data.parse(response_data["extra_data"]) != OK:
		var error_message = "%s. %s" % [USER_DATA_ERROR, JSON_PARSE_ERROR]
		var verbose = "Getting user data failed. Json cannot parse extra data"
		PopupDisplayServer.push_error(error_message, verbose)
	
	user_data.extra_data = json_extra_data.data
	return user_data

func all_usernames() -> PackedStringArray:
	const ALL_USERNAMES_ERROR = "Bład dostępu do użytkowników"
	#=Request=============================================================
	var request_state = get_all_usernames_request.request(get_all_usernames_url)
	
	if request_state != OK:
		var error_message = "%s. %s" % [ALL_USERNAMES_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting all usernames failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
	
	var response = await get_all_usernames_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [ALL_USERNAMES_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting all usernames failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [ALL_USERNAMES_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return PackedStringArray()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [ALL_USERNAMES_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
	
	return response_data["usernames"]

func user_chats() -> Dictionary:
	const USER_CHATS_ERROR = "Bład dostępu do czatów użytkownika"
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
		var error_message = "%s. %s" % [USER_CHATS_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting user chats failed. HTTP request state: %s" % [request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	
	var response = await get_user_chats_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [USER_CHATS_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting user chats failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [USER_CHATS_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return Dictionary()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [USER_CHATS_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	
	var user_chats: Dictionary = Dictionary()
	user_chats.set("direct", response_data["direct_chats"])
	user_chats.set("group", response_data["group_chats"])
	
	return user_chats

func chat_metadata(chat_id: int) -> Dictionary:
	const USER_CHAT_METADATA_ERROR = "Bład dostępu do danych czatu"
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
		var error_message = "%s. %s" % [USER_CHAT_METADATA_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting chat %s metadata failed. HTTP request state: %s" % [chat_id, request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	
	var response = await get_chat_metadata_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [USER_CHAT_METADATA_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting chat %s metadata failed. HTTP response state: %s code: %s" % [chat_id, response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [USER_CHAT_METADATA_ERROR, JSON_PARSE_ERROR]
		var verbose = "Getting chat %s metadata failed. Json cannot parse response" % chat_id
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [USER_CHAT_METADATA_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return Dictionary()
		
	return response_data["metadata"]

func chat_history(chat_id: int) -> Array:
	const USER_CHAT_HISTORY_ERROR = "Bład dostępu do danych czatu"
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
		var error_message = "%s. %s" % [USER_CHAT_HISTORY_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting chat %s history failed. HTTP request state: %s" % [chat_id, request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	
	var response = await get_chat_history_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [USER_CHAT_HISTORY_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting chat %s history failed. HTTP response state: %s code: %s" % [chat_id, response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [USER_CHAT_HISTORY_ERROR, JSON_PARSE_ERROR]
		var verbose = "Getting chat %s history failed. Json cannot parse response" % chat_id
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [USER_CHAT_HISTORY_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
		
	return response_data["messages"]

func update_group_chat_member(chat_id: int, action: GroupChatUpdateAction, username: String) -> bool:
	const GROUP_CHAT_UPDATE_ERROR = "Bład aktualizacji czatu grupowego"
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
		var error_message = "%s. %s" % [GROUP_CHAT_UPDATE_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Updateing group chat %s members failed. HTTP request state: %s" % [chat_id, request_state]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	var response = await update_group_chat_member_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [GROUP_CHAT_UPDATE_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Updateing group chat %s members failed. HTTP response state: %s code: %s" % [chat_id, response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [GROUP_CHAT_UPDATE_ERROR, JSON_PARSE_ERROR]
		var verbose = "Updateing group chat %s members failed.. Json cannot parse response" % chat_id
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	var response_status = json_response.data
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [GROUP_CHAT_UPDATE_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	return true;

func create_direct_chat(partner_username: String) -> int:
	const DIRECT_CHAT_CREATION_ERROR = "Bład tworzenia czatu bezpośredniego"
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
		var error_message = "%s. %s" % [DIRECT_CHAT_CREATION_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Creating direct chat failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	
	var response = await create_direct_chat_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [DIRECT_CHAT_CREATION_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Creating direct chat failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [DIRECT_CHAT_CREATION_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return -1
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [DIRECT_CHAT_CREATION_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	
	return response_data["chat_id"]

func create_group_chat(title: String) -> int:
	const GROUP_CHAT_CREATION_ERROR = "Bład tworzenia czatu grupowego"
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
		var error_message = "%s. %s" % [GROUP_CHAT_CREATION_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Creating group chat failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	
	var response = await create_group_chat_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [GROUP_CHAT_CREATION_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Creating group chat failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [GROUP_CHAT_CREATION_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return -1
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [GROUP_CHAT_CREATION_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return -1
	
	return response_data["chat_id"]

func bank_funds() -> int:
	const BANK_FUNDS_ERROR = "Bład pozyksania danych o stanie konta bankowego"
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var request_state = get_user_funds_request.request(get_user_funds_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		var error_message = "%s. %s" % [BANK_FUNDS_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting bank funds failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return 0
	
	var response = await get_user_funds_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [BANK_FUNDS_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting bank funds failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return 0
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [BANK_FUNDS_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return 0
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [BANK_FUNDS_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return 0
	
	return int(response_data["funds"])

func transfer_funds(receiver: String, title: String, amount: int) -> bool:
	const TRANSFER_FUNDS_ERROR = "Bład transferu środków bankowych"
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
		var error_message = "%s. %s" % [TRANSFER_FUNDS_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Transfering funds failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	var response = await transfer_funds_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [TRANSFER_FUNDS_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Transfering funds failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [TRANSFER_FUNDS_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return false
	
	var response_data = json_response.data
	
	if response_data["success"] == false:
		var error_message = "%s. %s" % [TRANSFER_FUNDS_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_data["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	return true

func bank_transaction_history() -> Array:
	const BANK_TRANSACTION_HISTORY_ERROR = "Bład dostępu do histori transakcji bankowych"
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
		var error_message = "%s. %s" % [BANK_TRANSACTION_HISTORY_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting bank transaction history failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	
	var response = await get_user_transaction_history_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [BANK_TRANSACTION_HISTORY_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting bank transaction history failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [BANK_TRANSACTION_HISTORY_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return Array()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [BANK_TRANSACTION_HISTORY_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return Array()
	
	return response_data["transactions"]

func news_feed() -> Array:
	const MEWS_FEED_ERROR = "Bład systemu informacji"
	#=Request=============================================================
	var request_state = get_news_feed_request.request(get_news_feed_url)
	
	if request_state != OK:
		var error_message = "%s. %s" % [MEWS_FEED_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Getting news feed failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
		
	var response = await get_news_feed_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [MEWS_FEED_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Getting news feed failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [MEWS_FEED_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return PackedStringArray()
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		var error_message = "%s. %s" % [MEWS_FEED_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_status["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return PackedStringArray()
	
	return response_data["articles"]

func post_news_article(title: String, content: String) -> bool:
	const POST_ARTICLE_ERROR = "Bład wysłania posta"
	#=Request=============================================================
	var payload = {
		"token" : AppSessionState.get_server_token(),
		"title" : title,
		"content" : content
	}
	
	var request_state = post_news_article_request.request(post_news_article_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_state != OK:
		var error_message = "%s. %s" % [POST_ARTICLE_ERROR, REQUEST_STATE_ERROR]
		var verbose = "Posting news article failed. HTTP request state: %s" % request_state
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	var response = await post_news_article_request.request_completed
	#=Response============================================================
	var response_state: int = response[0]
	var response_code: int = response[1]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]
	
	if response_state != HTTPRequest.RESULT_SUCCESS:
		var error_message = "%s. %s" % [POST_ARTICLE_ERROR, RESPONSE_STATE_ERROR]
		var verbose = "Posting news article failed. HTTP response state: %s code: %s" % [response_state, response_code]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	#=Parse===============================================================
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		var error_message = "%s. %s" % [POST_ARTICLE_ERROR, JSON_PARSE_ERROR]
		PopupDisplayServer.push_error(error_message)
		return false
	
	var response_data = json_response.data
	
	if response_data["success"] == false:
		var error_message = "%s. %s" % [POST_ARTICLE_ERROR, RESPONSE_STATUS_ERROR]
		var verbose = response_data["status_message"]
		PopupDisplayServer.push_error(error_message, verbose)
		return false
	
	return true

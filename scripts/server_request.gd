extends Node

enum GroupChatUpdateAction {
	ADD_MEMBER,
	REMOVE_MEMBER
}

const get_all_usernames_url = "http://127.0.0.1:3001/get_all_usernames"
var get_all_usernames_request : HTTPRequest

const get_chat_metadata_url = "http://127.0.0.1:3003/get_chat_metadata"
var get_chat_metadata_request : HTTPRequest

const update_group_chat_member_url = "http://127.0.0.1:3003/update_group_chat_member"
var update_group_chat_member_request : HTTPRequest

func _ready() -> void:
	get_all_usernames_request = HTTPRequest.new()
	add_child(get_all_usernames_request)
	
	get_chat_metadata_request = HTTPRequest.new()
	add_child(get_chat_metadata_request)
	
	update_group_chat_member_request = HTTPRequest.new()
	add_child(update_group_chat_member_request)

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

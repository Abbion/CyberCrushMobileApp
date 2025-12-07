extends Control

var login_request:  HTTPRequest
var validation_request: HTTPRequest
var user_data_request: HTTPRequest
const login_url = "http://127.0.0.1:3000/login"
const token_validation_url = "http://127.0.0.1:3000/validate_token"
const get_user_data_url = "http://127.0.0.1:3001/get_user_data"
@onready var username_input = $login_panel/username_input
@onready var password_input = $login_panel/password_input
@onready var login_button = $login_panel/login_button

func _ready() -> void:
	lock_input();
	var token = AppSessionState.get_server_token();
	var is_token_validated = await validate_token(token);
	remove_child(validation_request)
	
	if is_token_validated:
		load_main_page();
	else:
		unlock_input()
		login_request = HTTPRequest.new()
		login_request.request_completed.connect(login_request_completed)
		add_child(login_request)

func load_main_page():
	get_tree().change_scene_to_file(GlobalConstants.MAIN_PAGE_SCENE)
	
func lock_input():
	username_input.editable = false
	password_input.editable = false
	login_button.disabled = true

func unlock_input():
	username_input.editable = true
	password_input.editable = true
	login_button.disabled = false

func validate_token(token: String) -> bool:
	validation_request = HTTPRequest.new()
	add_child(validation_request)
	
	var payload = {
		"token" : token,
	}

	var request_result = validation_request.request(token_validation_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_result != OK:
		print("Login: Error occured in the token validation HTTP request.")
		return false
	
	var response = await validation_request.request_completed;
	var response_result = response[0]
	
	if response_result != OK:
		print("Login: Error occured in the token validation HTTP response.")
		return false
	
	var response_code = response[1]
	if response_code != GlobalConstants.HTTP_SUCCESS_CODE:
		return false
	
	var response_body = response[3].get_string_from_utf8()
	var parsed_response = JSON.parse_string(response_body)
	
	if parsed_response["success"] == false:
		print(parsed_response["status_message"])
		return false
	
	return true

func save_user_data(token: String) -> bool:
	user_data_request = HTTPRequest.new()
	add_child(user_data_request)
	
	var payload = {
		"token" : token,
	}

	var request_result = user_data_request.request(get_user_data_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
	
	if request_result != OK:
		print("Login: Error occured while requesting user data HTTP request.")
		return false
	
	var response = await user_data_request.request_completed;
	var response_result = response[0]
	
	if response_result != OK:
		print("Login: Error occured while reading response for user data HTTP request.")
	
	var response_code = response[1]
	if response_code != GlobalConstants.HTTP_SUCCESS_CODE:
		return false
	
	var response_body = response[3].get_string_from_utf8()
	var parsed_response = JSON.parse_string(response_body)
	var response_status = parsed_response["response_status"];
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		return false
	
	return AppSessionState.set_user_data(parsed_response["username"], parsed_response["personal_number"])

func _on_login_button_pressed() -> void:
	lock_input()
	
	var payload = {
		"username" : username_input.text,
		"password" : password_input.text
	}
	
	var result = login_request.request(login_url,
				GlobalConstants.JSON_HTTP_HEADER, 
				HTTPClient.METHOD_POST, 
				JSON.stringify(payload))
				
	if result != OK:
		print("Login: Error occured in the login HTTP request.")
		unlock_input()
	
func login_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != OK:
		print("Login: Error request failed with error code: %s" % result)
		unlock_input()
		return
	
	if response_code != GlobalConstants.HTTP_SUCCESS_CODE:
		unlock_input()
		return
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Login: Error response was not a valid Json")
		unlock_input()
		return
		
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["status_message"])
		unlock_input()
		return
	
	var token = response_data["token"]
	var user_data_save_result = await save_user_data(token)
	var token_save_result = AppSessionState.set_server_token(token)
	
	if user_data_save_result and token_save_result:
		load_main_page()
	else:
		AppSessionState.clear()
		unlock_input()

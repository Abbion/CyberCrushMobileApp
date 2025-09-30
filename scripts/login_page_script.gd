extends Control

var login_request:  HTTPRequest
var validation_request: HTTPRequest
const login_url = "http://127.0.0.1:3000/login"
const token_validation_url = "http://127.0.0.1:3000/validate_token"
@onready var username_input = $login_panel/username_input
@onready var password_input = $login_panel/password_input

func _ready() -> void:
	var token = AppSessionState.get_server_token();
	var is_token_validated = await validate_token(token);
	remove_child(validation_request)
	
	if is_token_validated:
		LoadMainPage();
	else:
		login_request = HTTPRequest.new()
		login_request.request_completed.connect(login_request_completed)
		add_child(login_request)

func LoadMainPage():
	get_tree().change_scene_to_file(GlobalConstants.MAIN_PAGE_SCENE)

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
		print("An error occured in the token validation HTTP request.")
		return false
	
	var response = await validation_request.request_completed;
	var response_result = response[0]
	
	if response_result != OK:
		print("An error occured in the token validation HTTP response.")
		return false
	
	var response_code = response[1]
	print("Token validation response code: ", response_code)
	if response_code != GlobalConstants.HTTP_SUCCESS_CODE:
		return false
	
	var response_body = response[3].get_string_from_utf8()
	var parsed_response = JSON.parse_string(response_body)
	
	if parsed_response["success"] == false:
		print(parsed_response["message"])
		return false
	
	return true

func _on_login_button_pressed() -> void:
	var payload = {
		"username" : username_input.text,
		"password" : password_input.text
	}
	
	var result = login_request.request(login_url,
				GlobalConstants.JSON_HTTP_HEADER, 
				HTTPClient.METHOD_POST, 
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the login HTTP request.")
	
func login_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != OK:
		print("Request failed with error code: %s" % result)
		return
	
	print("Login response code: ", response_code)
	if response_code != GlobalConstants.HTTP_SUCCESS_CODE:
		return
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Login response was not a valid Json")
		return
		
	var response_data = json_response.data
	var response_state = response_data["success"]
	var response_message = response_data["message"]
	
	if response_state == false:
		print("Login failed: ", response_message)
		return
	
	var token = response_data["token"]
	AppSessionState.set_server_token(token)	
	LoadMainPage()

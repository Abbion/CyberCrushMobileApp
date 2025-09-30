extends Control

var get_user_data_request : HTTPRequest
const get_user_data_url = "http://127.0.0.1:3001/get_user_data"
var get_all_usernames_request : HTTPRequest
const get_all_usernames_url = "http://127.0.0.1:3001/get_all_usernames"

@onready var username_label = $VBoxContainer/PanelContainer/my_id_page/username;
@onready var user_data_label = $VBoxContainer/PanelContainer/my_id_page/user_data

func _ready() -> void:
	get_user_data_request = HTTPRequest.new()
	get_user_data_request.request_completed.connect(get_user_data_request_completed)
	add_child(get_user_data_request)
	get_user_data()
	
	get_all_usernames_request = HTTPRequest.new()
	get_all_usernames_request.request_completed.connect(get_all_usernames_request_completed)
	add_child(get_all_usernames_request)
	get_all_usernames()

func get_user_data():
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var result = get_user_data_request.request(get_user_data_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("An error occured in the HTTP request.")

func get_user_data_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("User data: ", response_code)
	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("User data response was not a valid Json")
		return
	
	var response_data = json_response.data
	var username = response_data["username"]
	var psersonal_number = response_data["personal_number"]
	var json_extra_data = JSON.new()
	
	if json_extra_data.parse(response_data["extra_data"]) != OK:
		print("Extra user data was not a valid Json")
		return
		
	var extra_data = json_extra_data.data
	
	username_label.text += " " + username
	user_data_label.text += "\nPersonal number: " + psersonal_number;
	
	for key in extra_data:
		user_data_label.text += "\n" + key + " : " + extra_data[key]

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

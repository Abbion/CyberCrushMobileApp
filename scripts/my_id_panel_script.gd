extends VBoxContainer

var get_user_data_request : HTTPRequest
const get_user_data_url = "http://127.0.0.1:3001/get_user_data"
var id_page_entry = load("res://scenes/custom_controlls/id_page_entry.tscn")
@onready var id_entries = $id_entires

func _ready() -> void:
	get_user_data_request = HTTPRequest.new()
	get_user_data_request.request_completed.connect(get_user_data_request_completed)
	add_child(get_user_data_request)
	get_user_data()

func get_user_data():
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var result = get_user_data_request.request(get_user_data_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("Getting user data failed. Request result: ", result);

func get_user_data_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):	
	var response_text : String = body.get_string_from_utf8()
	var json_response : JSON = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("User data response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["message"])
		return
	
	var username = response_data["username"]
	var personal_number = response_data["personal_number"]
	
	var json_extra_data = JSON.new()
	if json_extra_data.parse(response_data["extra_data"]) != OK:
		print("Extra user data was not a valid Json")
		return
		
	var extra_data = json_extra_data.data
	
	var id_page_entry_username_instance = id_page_entry.instantiate()
	id_page_entry_username_instance.key = "username"
	id_page_entry_username_instance.value = username
	id_entries.add_child(id_page_entry_username_instance)
	
	var id_page_entry_personal_number_instance = id_page_entry.instantiate()
	id_page_entry_personal_number_instance.key = "personal number"
	id_page_entry_personal_number_instance.value = personal_number
	id_entries.add_child(id_page_entry_personal_number_instance)
	
	for key in extra_data:
		var id_page_entry_extra_data_instance = id_page_entry.instantiate()
		id_page_entry_extra_data_instance.key = key
		#TODO check the type of extra_data[key] and convert float, int, bool into str
		id_page_entry_extra_data_instance.value = str(extra_data[key])
		id_entries.add_child(id_page_entry_extra_data_instance)

func _on_logout_button_button_down() -> void:
	AppSessionState.clear()
	get_tree().change_scene_to_file(GlobalConstants.LOGIN_PAGE_SCENE)

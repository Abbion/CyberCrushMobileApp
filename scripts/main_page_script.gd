extends Control

var get_all_usernames_request : HTTPRequest
const get_all_usernames_url = "http://127.0.0.1:3001/get_all_usernames"

@onready var bank_panel = $VBoxContainer/PanelContainer/bank_panel
@onready var my_id_panel = $VBoxContainer/PanelContainer/my_id_panel
@onready var chat_panel = $VBoxContainer/PanelContainer/chat_panel

func _ready() -> void:	
	get_all_usernames_request = HTTPRequest.new()
	get_all_usernames_request.request_completed.connect(get_all_usernames_request_completed)
	add_child(get_all_usernames_request)
	#get_all_usernames()

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

func _on_app_selector_bank_selected() -> void:
	bank_panel.visible = true
	my_id_panel.visible = false
	chat_panel.visible = false;

func _on_app_selector_my_id_selected() -> void:
	my_id_panel.visible = true
	bank_panel.visible = false
	chat_panel.visible = false;
	

func _on_app_selector_messages_selected() -> void:
	chat_panel.visible = true;
	my_id_panel.visible = false
	bank_panel.visible = false

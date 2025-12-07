extends Control

var get_user_funds_request : HTTPRequest
const get_user_funds_url = "http://127.0.0.1:3002/get_user_funds"

var get_user_transaction_history_request : HTTPRequest
const get_user_transaction_history_url = "http://127.0.0.1:3002/get_user_transaction_history"

var transaction_entry : PackedScene = load("res://scenes/custom_controlls/transaction_entry.tscn")
@onready var transaction_entries : VBoxContainer = $main_panel/transactions_scroll_window/transactions_list
@onready var funds_label : Label = $main_panel/card/funds_label
@onready var main_panel_overlay : ColorRect = $main_panel_overlay
@onready var new_transaction_window : ColorRect = $new_transaction

var user_funds : int = 0

func _ready() -> void:
	get_user_funds_request = HTTPRequest.new()
	get_user_funds_request.request_completed.connect(get_user_funds_request_completed)
	add_child(get_user_funds_request)
	get_user_funds()
	
	get_user_transaction_history_request = HTTPRequest.new()
	get_user_transaction_history_request.request_completed.connect(get_user_transaction_history_request_completed)
	add_child(get_user_transaction_history_request)
	get_user_transaction_history()
	
	var cancel_button : Button = new_transaction_window.find_child("cancel_action");
	cancel_button.pressed.connect(cancel_new_transaction)

func get_user_funds():
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var result = get_user_funds_request.request(get_user_funds_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("Getting user funds failed. Request result: ", result);

func get_user_funds_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("User funds data response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["message"])
		return
	
	user_funds = int(response_data["funds"])
	funds_label.text = "Funds: " + str(user_funds)

func get_user_transaction_history():
	var payload = {
		"token" : AppSessionState.get_server_token(),
	}

	var result = get_user_transaction_history_request.request(
				get_user_transaction_history_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("Getting user transaction history failed. Request result: ", result);

func get_user_transaction_history_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Transaction history response was not a valid Json")
		return
	
	var response_data = json_response.data
	var response_status = response_data["response_status"]
	
	if response_status["success"] == false:
		print(response_status["message"])
		return
	
	var username = AppSessionState.get_username()
	
	for transaction in response_data["transactions"]:
		var sender_username = transaction["sender_username"]
		var receiver_username = transaction["receiver_username"]
		var title = transaction["message"]
		var amount = transaction["amount"]
		var date = transaction["time_stamp"]
		
		if sender_username == username:
			amount = -amount
		
		var transaction_entry_instance = transaction_entry.instantiate()
		transaction_entry_instance.title = title
		transaction_entry_instance.amount = int(amount)
		transaction_entry_instance.peer = sender_username + " -> " + receiver_username
		transaction_entry_instance.date = date
		transaction_entries.add_child(transaction_entry_instance)

func refresh_user_bank_account() -> void:
	for transaction in transaction_entries.get_children():
		transaction_entries.remove_child(transaction)
	get_user_transaction_history()
	get_user_funds()
	
func _on_refresh_button_down() -> void:
	refresh_user_bank_account()

func _on_new_transaction_pressed() -> void:
	new_transaction_window.visible = true
	main_panel_overlay.visible = true

func cancel_new_transaction() -> void:
	new_transaction_window.visible = false
	main_panel_overlay.visible = false

func _on_new_transaction_transaction_completed(bool: Variant) -> void:
	cancel_new_transaction()
	refresh_user_bank_account()

extends ColorRect

var get_user_funds_request : HTTPRequest
const get_user_funds_url = "http://127.0.0.1:3002/get_user_funds"

var transfer_funds_request : HTTPRequest
const transfer_funds_url = "http://127.0.0.1:3002/transfer_funds"

@onready var funds_label = $transaction_elements/funds_label
@onready var title_input = $transaction_elements/title_input
@onready var amount_input = $transaction_elements/amount_input
@onready var recepiant_input = $recepiant_input

signal transaction_completed(bool)
var user_funds : int = 0;

func _init() -> void:
	get_user_funds_request = HTTPRequest.new()
	get_user_funds_request.request_completed.connect(get_user_funds_request_completed)
	add_child(get_user_funds_request)
	
	transfer_funds_request = HTTPRequest.new()
	transfer_funds_request.request_completed.connect(transfer_funds_request_completed)
	add_child(transfer_funds_request)

func transfer_funds(receiver: String, title: String, amount: int):
	var payload = {
		"sender_token" : AppSessionState.get_server_token(),
		"receiver_username" : receiver,
		"message" : title,
		"amount" : amount
	}

	var result = transfer_funds_request.request(
				transfer_funds_url,
				GlobalConstants.JSON_HTTP_HEADER,
				HTTPClient.METHOD_POST,
				JSON.stringify(payload))
				
	if result != OK:
		print("Getting user funds transfer failed. Request result: ", result);
	
func transfer_funds_request_completed(ult: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:	
	var response_text = body.get_string_from_utf8()
	var json_response = JSON.new()
	
	if json_response.parse(response_text) != OK:
		print("Transfer funds response was not a valid Json")
		return
	
	var response_data = json_response.data
	if response_data["success"] == false:
		print(response_data["status_message"])
		transaction_completed.emit(false)
		clear_inputs()
		return
		
	transaction_completed.emit(true)
	clear_inputs()

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
	funds_label.text = "Dostępne środki: " + str(user_funds)

func _on_transer_action_pressed() -> void:
	var recepiant : String = recepiant_input.get_value()
	
	if recepiant.is_empty():
		## TODO Make input border red and send notification
		return
	
	var title_value : String = title_input.text
	
	if title_value.is_empty():
		## TODO Make input border red and send notification
		return
	
	var amount_value : String = amount_input.text
	if not amount_value.is_valid_int():
		## TODO Make input border red and send notification
		amount_input.text = ""
		return
	
	var amount_value_int = int(amount_value)
	if amount_value_int < 0 or amount_value_int > user_funds:
		## TODO Make input border red and send notification
		amount_input.text = ""
		return;
	
	transfer_funds(recepiant, title_value, amount_value_int)

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

func clear_inputs() -> void:
	title_input.clear()
	amount_input.clear()
	recepiant_input.clear()

func _on_visibility_changed() -> void:
	if visible == false:
		return
	get_user_funds()

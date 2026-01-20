extends ColorRect

@onready var funds_label = $transaction_elements/funds_label
@onready var title_input = $transaction_elements/title_input
@onready var amount_input = $transaction_elements/amount_input
@onready var recepiant_input = $recepiant_input

signal transaction_completed(bool)
var user_funds : int = 0;

func _ready() -> void:
	var all_usernames = await ServerRequest.all_usernames()
	recepiant_input.all_suggestions = all_usernames

func update_user_funds() -> void:
	var funds = await ServerRequest.bank_funds()
	user_funds = funds
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
	
	var transfer_result = await ServerRequest.transfer_funds(recepiant, title_value, amount_value_int)
	transaction_completed.emit(transfer_result)
	clear_inputs()

func clear_inputs() -> void:
	title_input.clear()
	amount_input.clear()
	recepiant_input.clear()

func _on_visibility_changed() -> void:
	if visible == false:
		return
	update_user_funds()

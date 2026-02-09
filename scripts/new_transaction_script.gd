extends Control

@onready var funds_label = $background/transaction_elements/funds_label
@onready var title_input = $background/transaction_elements/title_input
@onready var amount_input = $background/transaction_elements/amount_input
@onready var recepiant_input = $background/recepiant_input

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
		PopupDisplayServer.push_error("Pole odbiorcy przelewu jest puste")
		## TODO Make input border red
		return
	
	var title_value : String = title_input.text
	
	if title_value.is_empty():
		PopupDisplayServer.push_error("Pole tytułu przelewu jest puste")
		## TODO Make input border red and send notification
		return
	
	var amount_value : String = amount_input.text
	if not amount_value.is_valid_int():
		PopupDisplayServer.push_error("Wartość pola przelewanych środków jest nieprawidłowa")
		## TODO Make input border red and send notification
		amount_input.text = ""
		return
	
	var amount_value_int = int(amount_value)
	if amount_value_int < 0:
		PopupDisplayServer.push_error("Wartość pola przelewanych środków jest ujemna")
		## TODO Make input border red and send notification
		amount_input.text = ""
		return;
	if  amount_value_int > user_funds:
		PopupDisplayServer.push_error("Próbujesz przelewać więcej środków niż jest obecnie dostępnych")
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

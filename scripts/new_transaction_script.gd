#Refactor 1
extends Control

const MAX_TITLE_LENGTH = 32

@onready var funds_label: Label = $margin/transaction_elements/top_info_v_box/funds_label
@onready var title_input: LineEdit = $margin/transaction_elements/title_input
@onready var amount_input: LineEdit = $margin/transaction_elements/amount_input
@onready var recepiant_input = $margin/transaction_elements/recepiant_input

@onready var suggestion_margin: MarginContainer = $margin/transaction_elements/recepiant_input/v_box/layout_override/suggestion_margin

signal transaction_completed(bool)
signal transaction_canceled()
var user_funds : int = 0;

func _ready() -> void:
	var all_usernames = await ServerRequest.all_usernames(true)
	recepiant_input.all_suggestions = all_usernames

func update_user_funds() -> void:
	var funds = await ServerRequest.bank_funds()
	user_funds = funds
	funds_label.text =  tr("AVAILABLE_FUNDS_KEY") + ": " + str(user_funds) + GlobalConstants.MONEY_SYMBOL

func on_transer_action_pressed() -> void:
	if recepiant_input.is_in_suggestions() == false:
		PopupDisplayServer.push_error(tr("RECIPIENT_DOES_NOT_EXIST"), tr("BANKING_TRANSACTION_PANEL"))
		return
	
	var recepiant: String = recepiant_input.get_value()
	if recepiant.is_empty():
		PopupDisplayServer.push_error(tr("EMPTY_TRANSFER_RECIPIENT"))
		## TODO Make input border red
		return
	
	var title_value: String = title_input.text
	
	if title_value.is_empty():
		PopupDisplayServer.push_error(tr("EMPTY_TRANSACTION_TITLE"))
		## TODO Make input border red and send notification
		return
	
	if title_value.length() > MAX_TITLE_LENGTH:
		match AppSessionState.get_language():
			GlobalTypes.LANGUAGE.ENGLISH:
				PopupDisplayServer.push_error("Transaction title is too long. %s character limit" % MAX_TITLE_LENGTH)
			GlobalTypes.LANGUAGE.POLISH:
				PopupDisplayServer.push_error("Tytuł transakcji jest za długi. Maksymalnie %s znaki" % MAX_TITLE_LENGTH)
		return
	
	var amount_value: String = amount_input.text
	if not amount_value.is_valid_int():
		PopupDisplayServer.push_error(tr("INCORRECT_TRANSFER_VALUE"))
		## TODO Make input border red and send notification
		amount_input.text = ""
		return
	
	var amount_value_int := int(amount_value)
	if amount_value_int <= 0:
		PopupDisplayServer.push_error(tr("NEGATIVE_OR_ZERO_TRANSFER_VALUE"))
		## TODO Make input border red and send notification
		amount_input.text = ""
		return;
	if  amount_value_int > user_funds:
		PopupDisplayServer.push_error(tr("NOT_AVAILABLE_FUNDS_AMOUNT"))
		## TODO Make input border red and send notification
		amount_input.text = ""
		return;
	
	var transfer_result := await ServerRequest.transfer_funds(recepiant, title_value, amount_value_int)
	transaction_completed.emit(transfer_result)
	clear_inputs()

func clear_inputs() -> void:
	title_input.clear()
	amount_input.clear()
	recepiant_input.clear()

func on_cancel_action_pressed() -> void:
	clear_inputs()
	transaction_canceled.emit()

func on_suggestion_margin_visibility_changed() -> void:
	if suggestion_margin.visible == true:
		title_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
		amount_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		title_input.mouse_filter = Control.MOUSE_FILTER_STOP
		amount_input.mouse_filter = Control.MOUSE_FILTER_STOP

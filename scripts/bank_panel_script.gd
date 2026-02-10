extends Control

var transaction_entry: PackedScene = load("res://scenes/custom_controlls/transaction_entry.tscn")
@onready var transactions_list: VBoxContainer = $main_panel/transactions_scroll/transactions_list
@onready var funds_label: Label = $main_panel/card/funds_label
@onready var overlay_margin: MarginContainer = $overlay_margin
@onready var new_transaction_window: Control = $overlay_margin/center_container/new_transaction

@onready var transactions_scroll = $main_panel/transactions_scroll
@onready var spinner_container: CenterContainer = $main_panel/spinner_container
@onready var empty_transactions_container: CenterContainer = $main_panel/empty_transactions

var user_funds : int = 0

func _ready() -> void:
	refresh_user_bank_account()
	
	var cancel_button : Button = new_transaction_window.find_child("cancel_action");
	cancel_button.pressed.connect(cancel_new_transaction)

func update_transaction_history():
	var transactions = await ServerRequest.bank_transaction_history()
	var username = AppSessionState.get_username()
	
	for transaction in transactions:
		var sender_username = transaction["sender_username"]
		var receiver_username = transaction["receiver_username"]
		var title = transaction["message"]
		var amount = transaction["amount"]
		var date = transaction["time_stamp"]
		
		if sender_username == username:
			amount = -amount
			
		var datetime = GlobalTypes.DateTime.from_string(date)
		
		var transaction_entry_instance = transaction_entry.instantiate()
		transaction_entry_instance.title = title
		transaction_entry_instance.amount = int(amount)
		transaction_entry_instance.peer = sender_username + " -> " + receiver_username
		transaction_entry_instance.date = datetime.get_string()
		transactions_list.add_child(transaction_entry_instance)

func refresh_user_bank_account() -> void:
	spinner_container.show()
	transactions_scroll.hide()
	empty_transactions_container.hide()
	
	for transaction in transactions_list.get_children():
		transactions_list.remove_child(transaction)
		transaction.queue_free()
		
	await update_transaction_history()
	user_funds = await ServerRequest.bank_funds()
	funds_label.text = "Dostępne środki: " + str(user_funds)
	
	spinner_container.hide()
	transactions_scroll.show()
	
	if transactions_list.get_child_count() == 0:
		transactions_scroll.hide()
		empty_transactions_container.show()
	
func _on_refresh_button_down() -> void:
	refresh_user_bank_account()

func _on_new_transaction_pressed() -> void:
	new_transaction_window.update_user_funds()
	overlay_margin.visible = true

func cancel_new_transaction() -> void:
	overlay_margin.visible = false

func _on_new_transaction_transaction_completed(bool: Variant) -> void:
	cancel_new_transaction()
	refresh_user_bank_account()

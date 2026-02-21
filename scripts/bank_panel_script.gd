#Refactor 1
extends Control

@export var transaction_entry: PackedScene
@onready var transactions_list: VBoxContainer = $bank_container/transactions_scroll/transactions_list
@onready var funds_label: Label = $bank_container/card/funds_label
@onready var overlay_margin: MarginContainer = $overlay_margin
@onready var new_transaction_window: Control = $overlay_margin/center_container/new_transaction
@onready var refresh_button: Button = $bank_container/bank_actions/refresh

@onready var transactions_scroll: ScrollContainer = $bank_container/transactions_scroll
@onready var spinner_container: CenterContainer = $bank_container/spinner_container
@onready var empty_transactions_container: CenterContainer = $bank_container/empty_transactions

var user_funds : int = 0

func _ready() -> void:
	refresh_user_bank_account()

func update_transaction_history():
	var transactions := await ServerRequest.bank_transaction_history()
	var username := AppSessionState.get_username()
	
	for transaction in transactions:
		var sender_username = transaction["sender_username"]
		var receiver_username = transaction["receiver_username"]
		var title = transaction["message"]
		var founds_trsfered = transaction["amount"]
		var date = transaction["time_stamp"]
		
		if sender_username == username:
			founds_trsfered = -founds_trsfered
			
		var datetime := GlobalTypes.DateTime.from_string(date)
		
		var transaction_entry_instance := transaction_entry.instantiate()
		transaction_entry_instance.title = title
		transaction_entry_instance.founds_trsfered = int(founds_trsfered)
		transaction_entry_instance.peer = sender_username + " -> " + receiver_username
		transaction_entry_instance.date = datetime.get_string()
		transactions_list.add_child(transaction_entry_instance)

func refresh_user_bank_account() -> void:
	refresh_button.disabled = true
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
	
	refresh_button.disabled = false
	
func on_refresh_button_pressed() -> void:
	refresh_user_bank_account()

func on_new_transaction_pressed() -> void:
	new_transaction_window.update_user_funds()
	overlay_margin.visible = true

func on_new_transaction_transaction_completed(_competed: bool) -> void:
	overlay_margin.hide()
	refresh_user_bank_account()

func on_new_transaction_transaction_canceled() -> void:
	overlay_margin.hide()

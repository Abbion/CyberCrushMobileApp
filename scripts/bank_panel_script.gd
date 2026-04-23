#Refactor 1
extends Control

@export var transaction_entry: PackedScene
@onready var transactions_list: VBoxContainer = $main_margin/bank_container/transactions_scroll/transactions_list
@onready var username_label: Label = $main_margin/bank_container/card_panel/card_margin/card_v_box/top_data_h_box/v_box/username_label
@onready var funds_label: Label = $main_margin/bank_container/card_panel/card_margin/card_v_box/top_data_h_box/v_box/funds_label
@onready var card_code_label: Label = $main_margin/bank_container/card_panel/card_margin/card_v_box/card_code_label
@onready var overlay_margin: MarginContainer = $overlay_margin
@onready var new_transaction_window: Control = $overlay_margin/center_container/new_transaction
@onready var refresh_button: Button = $main_margin/bank_container/bank_actions/refresh
@onready var transactions_scroll: ScrollContainer = $main_margin/bank_container/transactions_scroll
@onready var spinner_container: CenterContainer = $main_margin/bank_container/spinner_container
@onready var empty_transactions_container: CenterContainer = $main_margin/bank_container/empty_transactions

var user_funds : int = 0

func _ready() -> void:
	var username := AppSessionState.get_username()
	username_label.text = username
	var card_code := str(hash(username))
	card_code_label.text = "************%s" % card_code.substr(0, 4)
	
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
	funds_label.text = tr("AVAILABLE_FUNDS_KEY") + ": " + str(user_funds) + GlobalConstants.MONEY_SYMBOL
	
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

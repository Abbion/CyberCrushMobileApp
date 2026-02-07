extends Control

var transaction_entry: PackedScene = load("res://scenes/custom_controlls/transaction_entry.tscn")
@onready var transaction_entries: VBoxContainer = $main_panel/transactions_scroll_window/transactions_list
@onready var funds_label: Label = $main_panel/card/funds_label
@onready var overlay_margin: MarginContainer = $overlay_margin
@onready var new_transaction_window: Control = $overlay_margin/center_container/new_transaction

var user_funds : int = 0

func _ready() -> void:
	refresh_user_bank_account()
	
	var cancel_button : Button = new_transaction_window.find_child("cancel_action");
	cancel_button.pressed.connect(cancel_new_transaction)

func _process(delta: float) -> void:
	if GlobalConstants.os_is_mobile() == true:
		var vk_height: int = DisplayServer.virtual_keyboard_get_height()
		
		var top_margin = 0.0
		var bottom_margin = 0.0
		if vk_height > 0.0:
			bottom_margin = AppSessionState.app_selector_height
			top_margin = DisplayServer.get_display_safe_area().position.y
		
		var margin = DisplayManager.base_to_viewport_point_converter(Vector2(0.0, float(vk_height - bottom_margin - top_margin)))
		overlay_margin.add_theme_constant_override("margin_bottom", margin.y)

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
		
		var transaction_entry_instance = transaction_entry.instantiate()
		transaction_entry_instance.title = title
		transaction_entry_instance.amount = int(amount)
		transaction_entry_instance.peer = sender_username + " -> " + receiver_username
		transaction_entry_instance.date = date
		transaction_entries.add_child(transaction_entry_instance)

func refresh_user_bank_account() -> void:
	for transaction in transaction_entries.get_children():
		transaction_entries.remove_child(transaction)
		transaction.queue_free()
		
	update_transaction_history()
	user_funds = await ServerRequest.bank_funds()
	funds_label.text = "Funds: " + str(user_funds)
	
func _on_refresh_button_down() -> void:
	refresh_user_bank_account()

func _on_new_transaction_pressed() -> void:
	new_transaction_window.visible = true
	overlay_margin.visible = true

func cancel_new_transaction() -> void:
	new_transaction_window.visible = false
	overlay_margin.visible = false

func _on_new_transaction_transaction_completed(bool: Variant) -> void:
	cancel_new_transaction()
	refresh_user_bank_account()

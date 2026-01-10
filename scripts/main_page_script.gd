extends Control

@onready var bank_panel = $VBoxContainer/PanelContainer/bank_panel
@onready var my_id_panel = $VBoxContainer/PanelContainer/my_id_panel
@onready var chat_panel = $VBoxContainer/PanelContainer/chat_panel

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

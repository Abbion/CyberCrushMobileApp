extends Control

@onready var news_panel = $VBoxContainer/PanelContainer/news_panel
@onready var bank_panel = $VBoxContainer/PanelContainer/bank_panel
@onready var my_id_panel = $VBoxContainer/PanelContainer/my_id_panel
@onready var chat_panel = $VBoxContainer/PanelContainer/chat_panel
@onready var app_selector = $VBoxContainer/app_selector
@onready var popup_container = $popup_container/information_popup

func _ready() -> void:
	AppSessionState.app_selector_height = app_selector.size.y

func _on_app_selector_socials_selected() -> void:
	news_panel.show()
	bank_panel.hide()
	chat_panel.hide()
	my_id_panel.hide()

func _on_app_selector_bank_selected() -> void:
	news_panel.hide()
	bank_panel.show()
	chat_panel.hide()
	my_id_panel.hide()
	
func _on_app_selector_messages_selected() -> void:
	news_panel.hide()
	bank_panel.hide()
	chat_panel.show()
	my_id_panel.hide()

func _on_app_selector_my_id_selected() -> void:
	news_panel.hide()
	bank_panel.hide()
	chat_panel.hide()
	my_id_panel.show()

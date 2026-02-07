extends Control

@onready var top_bar: ColorRect = $VBoxContainer/top_bar
@onready var news_panel = $VBoxContainer/PanelContainer/news_panel
@onready var bank_panel = $VBoxContainer/PanelContainer/bank_panel
@onready var my_id_panel = $VBoxContainer/PanelContainer/my_id_panel
@onready var chat_panel = $VBoxContainer/PanelContainer/chat_panel
@onready var app_selector = $VBoxContainer/app_selector
@onready var popup_margin: MarginContainer = $popup_margin

func _ready() -> void:
	AppSessionState.app_selector_height = app_selector.size.y
	if GlobalConstants.os_is_mobile() == true:
		var safe_area = DisplayServer.get_display_safe_area()
		var top_margin = DisplayManager.base_to_viewport_point_converter(safe_area.position)
		top_bar.custom_minimum_size.y = top_margin.y
		popup_margin.add_theme_constant_override("margin_top", top_margin.y)
	else:
		popup_margin.add_theme_constant_override("margin_top", top_bar.size.y)

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

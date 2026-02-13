#Refactor 1
#TODO: look at low_processor_usage_mode and screen_is_kept_on and set_max_fps to save power

extends Control

@onready var top_bar: ColorRect = $main_page_container/top_bar
@onready var panel_margin: MarginContainer = $main_page_container/panel_margin
@onready var app_selector: ColorRect = $main_page_container/app_selector
@onready var popup_margin: MarginContainer = $popup_margin

@export var news_panel_scene: PackedScene
@export var bank_panel_scene: PackedScene
@export var chat_panel_scene: PackedScene
@export var id_panel_scene: PackedScene

var current_panel: Control = null

func _ready() -> void:
	AppSessionState.app_selector_height = int(app_selector.size.y)
	if GlobalConstants.os_is_mobile() == true:
		var safe_area := DisplayServer.get_display_safe_area()
		var top_margin := DisplayManager.base_to_viewport_point_converter(safe_area.position)
		
		if top_margin.y < 1:
			top_margin.y = get_viewport().size.y * 0.075
		
		var top_bar_height := top_margin.y * 1.25
		top_bar.custom_minimum_size.y = top_bar_height
		popup_margin.add_theme_constant_override("margin_top", int(top_bar_height))
	else:
		popup_margin.add_theme_constant_override("margin_top", int(top_bar.size.y))
	
	change_panel(news_panel_scene)

func change_panel(panel: PackedScene) -> void:
	if current_panel != null:
		panel_margin.remove_child(current_panel)
	current_panel = panel.instantiate()
	panel_margin.add_child(current_panel)

func on_app_selector_socials_selected() -> void:
	change_panel(news_panel_scene)
	
func on_app_selector_bank_selected() -> void:
	change_panel(bank_panel_scene)
	
func on_app_selector_messages_selected() -> void:
	change_panel(chat_panel_scene)

func on_app_selector_my_id_selected() -> void:
	change_panel(id_panel_scene)

func logout():
	AppSessionState.clear()
	UserManager.clear_last_used_credentials()
	PopupDisplayServer.popup_list.clear()
	get_tree().change_scene_to_file(GlobalConstants.LOGIN_PAGE_SCENE)

func on_tree_entered() -> void:
	GlobalSignals.logout.connect(logout)

func on_tree_exited() -> void:
	GlobalSignals.logout.disconnect(logout)

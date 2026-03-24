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
@export var info_panel: PackedScene

var current_panel: Control = null
var game_start: bool = true

func _ready() -> void:
	game_start = AppSessionState.is_game_online()
	AppSessionState.app_selector_height = int(app_selector.size.y)
	
	if AppSessionState.os_is_mobile() == true:
		var safe_area := DisplayServer.get_display_safe_area()
		var top_margin := DisplayManager.base_to_viewport_point_converter(safe_area.position)
		
		if top_margin.y < 1:
			top_margin.y = 25
		
		var top_bar_height := top_margin.y * 1.15
		top_bar.custom_minimum_size.y = top_bar_height
		popup_margin.add_theme_constant_override("margin_top", int(top_bar_height))
	else:
		popup_margin.add_theme_constant_override("margin_top", int(top_bar.custom_minimum_size.y))
	
	on_app_selector_socials_selected()

func change_panel(panel: PackedScene) -> void:
	if current_panel != null:
		panel_margin.remove_child(current_panel)
	current_panel = panel.instantiate()
	panel_margin.add_child(current_panel)

func change_to_info_panel(info_message: String) -> void:
	if current_panel != null:
		panel_margin.remove_child(current_panel)
	current_panel = info_panel.instantiate()
	current_panel.info_message_text = tr(info_message)
	panel_margin.add_child(current_panel)

func on_app_selector_socials_selected() -> void:
	if game_start:
		change_panel(news_panel_scene)
	else:
		change_to_info_panel(AppSessionState.get_info_panel_text())
	
func on_app_selector_bank_selected() -> void:
	if game_start:
		change_panel(bank_panel_scene)
	else:
		change_to_info_panel("INFO_MESSAGE_GAME_NOT_STARTED")
	
func on_app_selector_messages_selected() -> void:
	if game_start:
		change_panel(chat_panel_scene)
	else:
		change_to_info_panel("INFO_MESSAGE_GAME_NOT_STARTED")

func on_app_selector_my_id_selected() -> void:
	change_panel(id_panel_scene)

func logout():
	AppSessionState.clear()
	UserManager.clear_last_used_credentials()
	PopupDisplayServer.reset()
	get_tree().change_scene_to_file(GlobalConstants.LOGIN_PAGE_SCENE)

func on_tree_entered() -> void:
	GlobalSignals.logout.connect(logout)

func on_tree_exited() -> void:
	GlobalSignals.logout.disconnect(logout)

extends Control

@onready var username_input: LineEdit = $AspectRatioContainer/login_margin/login_panel/username_input
@onready var password_input: LineEdit = $AspectRatioContainer/login_margin/login_panel/password_input
@onready var login_button: Button = $AspectRatioContainer/login_margin/login_panel/login_button
@onready var login_margin: MarginContainer = $AspectRatioContainer/login_margin
@onready var popup_margin: MarginContainer = $popup_margin
@onready var login_spinner_margin: MarginContainer = $AspectRatioContainer/login_margin/login_panel/spinner_margin

func _ready() -> void:	
	var safe_area = DisplayServer.get_display_safe_area()
	var margin = DisplayManager.base_to_viewport_point_converter(safe_area.position)
	popup_margin.add_theme_constant_override("margin_top", margin.y)
	
	lock_input();
	var token = AppSessionState.get_server_token();
	if token.is_empty() == false:
		var is_token_validated = await ServerRequest.validate_token(token);
		if is_token_validated == true:
			load_main_page();
	
	unlock_input()

func load_main_page():
	get_tree().change_scene_to_file(GlobalConstants.MAIN_PAGE_SCENE)

func save_user_data(token: String) -> bool:
	var user_data = await ServerRequest.user_data();
	return AppSessionState.set_user_data(user_data.username, str(user_data.personal_number))

func _on_login_button_pressed() -> void:
	lock_input()
	var token = await ServerRequest.login(username_input.text, password_input.text)
	
	if token.is_empty():
		unlock_input()
		return
	
	var token_save_result = AppSessionState.set_server_token(token)
	var user_data_save_result = await save_user_data(token)
	
	if token_save_result and user_data_save_result:
		load_main_page()
	else:
		AppSessionState.clear()
		unlock_input()

func lock_input():
	username_input.editable = false
	password_input.editable = false
	login_button.disabled = true
	login_spinner_margin.show()
	
func unlock_input():
	username_input.editable = true
	password_input.editable = true
	login_button.disabled = false
	login_spinner_margin.hide()

func _process(delta: float) -> void:
	if GlobalConstants.os_is_mobile() == true:
		var vk_height: int = DisplayServer.virtual_keyboard_get_height()
		var top_margin = 0.0
		if vk_height > 0:
			top_margin = DisplayServer.get_display_safe_area().position.y
		
		var margin = DisplayManager.base_to_viewport_point_converter(Vector2(0.0, float(vk_height - top_margin)))
		login_margin.add_theme_constant_override("margin_bottom", margin.y)

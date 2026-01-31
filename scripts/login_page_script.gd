extends Control
#get_display_cutouts

@onready var username_input = $center_container/aspect_ratio_container/login_panel/username_input
@onready var password_input = $center_container/aspect_ratio_container/login_panel/password_input
@onready var login_button = $center_container/aspect_ratio_container/login_panel/login_button
@onready var center_container = $center_container

func _ready() -> void:
	lock_input();
	var token = AppSessionState.get_server_token();
	var is_token_validated = await ServerRequest.validate_token(token);
	
	if is_token_validated:
		load_main_page();
	else:
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

func unlock_input():
	username_input.editable = true
	password_input.editable = true
	login_button.disabled = false

func _process(delta: float) -> void:
	center_container.anchor_bottom = HelperFunctions.virtual_keyboard_normalized_size_from_bottom()

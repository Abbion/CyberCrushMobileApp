#Refactor 1
extends Control

@onready var username_input: LineEdit = $aspect_ration_container/login_margin/login_panel/username_input_options/username_input
@onready var password_input: LineEdit = $aspect_ration_container/login_margin/login_panel/password_input
@onready var show_saved_users_button: Button = $aspect_ration_container/login_margin/login_panel/username_input_options/show_saved_users_button
@onready var saved_users_list: ItemList = $aspect_ration_container/login_margin/login_panel/saved_users_list
@onready var login_button: Button = $aspect_ration_container/login_margin/login_panel/login_button
@onready var login_margin: MarginContainer = $aspect_ration_container/login_margin
@onready var login_spinner_margin: MarginContainer = $aspect_ration_container/login_margin/login_panel/spinner_margin
@onready var popup_margin: MarginContainer = $popup_margin

const MAX_VISIBLE_SAVED_USERS: int = 3

func _ready() -> void:
	setup_ui()
	lock_input()
	
	var last_used_credentials := UserManager.get_last_used_credentials()
	if last_used_credentials.is_empty() == false:
		var is_token_validated = await ServerRequest.validate_token(last_used_credentials["token"]);
		if is_token_validated == true:
			AppSessionState.set_username(last_used_credentials["username"])
			AppSessionState.set_server_token(last_used_credentials["token"])
			load_main_page();
			return
		
	load_saved_user_credentials()
	unlock_input()

func _process(_delta: float) -> void:
	if GlobalConstants.os_is_mobile() == true:
		var vk_height := DisplayServer.virtual_keyboard_get_height()
		var top_margin: float = 0.0
		if vk_height > 0:
			top_margin = DisplayServer.get_display_safe_area().position.y
		
		var margin := DisplayManager.base_to_viewport_point_converter(Vector2(0.0, float(vk_height - top_margin)))
		login_margin.add_theme_constant_override("margin_bottom", int(margin.y))

func load_main_page():
	get_tree().change_scene_to_file(GlobalConstants.MAIN_PAGE_SCENE)

func on_login_button_pressed() -> void:
	lock_input()
	var username = username_input.text
	var token := await ServerRequest.login(username, password_input.text)
	
	if token.is_empty():
		unlock_input()
		return
	
	UserManager.save_user_credentails(username, token)
	UserManager.save_as_last_used(username, token)
	AppSessionState.set_username(username)
	AppSessionState.set_server_token(token)
	
	load_main_page()

func lock_input():
	username_input.editable = false
	password_input.editable = false
	login_button.disabled = true
	show_saved_users_button.disabled = true
	login_spinner_margin.show()
	
func unlock_input():
	username_input.editable = true
	password_input.editable = true
	login_button.disabled = false
	show_saved_users_button.disabled = false
	login_spinner_margin.hide()

func on_show_saved_users_button_pressed() -> void:
	saved_users_list.visible = !saved_users_list.visible

func load_saved_user_credentials() -> void:
	var all_credentials := UserManager.get_all_saved_credentials()
	
	if all_credentials.is_empty():
		return
		
	show_saved_users_button.show()
	for username in all_credentials:
		saved_users_list.add_item(username)
	update_user_list_size.call_deferred()

func setup_ui() -> void:
	var safe_area := DisplayServer.get_display_safe_area()
	var margin := DisplayManager.base_to_viewport_point_converter(safe_area.position)
	popup_margin.add_theme_constant_override("margin_top", int(margin.y))

func on_saved_users_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	lock_input()
	var username := saved_users_list.get_item_text(index)
	var token := UserManager.get_token(username)
	var validation_success := await ServerRequest.validate_token(token)
	
	if validation_success == false:
		UserManager.remove_user_credentails(username)
		saved_users_list.remove_item(index)
		update_user_list_size.call_deferred()
		
		if saved_users_list.item_count == 0:
			show_saved_users_button.hide()
			saved_users_list.hide()
		
		unlock_input()
		return
	
	UserManager.save_as_last_used(username, token)
	AppSessionState.set_username(username)
	AppSessionState.set_server_token(token)
	load_main_page()

func update_user_list_size() -> void:
	var item_count := saved_users_list.item_count
	if item_count <= MAX_VISIBLE_SAVED_USERS:
		saved_users_list.auto_height = true
		return
	
	saved_users_list.auto_height = false
	var v_sep := saved_users_list.get_theme_constant("v_separation")
	var item_height := saved_users_list.get_item_rect(0).size.y
	var total_height = (item_height * MAX_VISIBLE_SAVED_USERS) + (v_sep * MAX_VISIBLE_SAVED_USERS - 1)
	saved_users_list.custom_minimum_size.y = total_height

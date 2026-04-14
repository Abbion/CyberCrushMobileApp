#Refactor 1
extends Control

@export var up_arrow_icon: DPITexture
@export var down_arrow_icon: DPITexture

@onready var username_input: LineEdit = $aspect_ration_container/login_margin/login_panel/username_settings/username_input_options/username_input
@onready var password_input: LineEdit = $aspect_ration_container/login_margin/login_panel/password_input
@onready var show_saved_users_button: Button = $aspect_ration_container/login_margin/login_panel/username_settings/username_input_options/show_saved_users_button
@onready var saved_users_list: ItemList = $aspect_ration_container/login_margin/login_panel/username_settings/saved_users_list
@onready var login_button: Button = $aspect_ration_container/login_margin/login_panel/login_button
@onready var login_margin: MarginContainer = $aspect_ration_container/login_margin
@onready var popup_margin: MarginContainer = $popup_margin
@onready var language_selector: OptionButton = $language_panel/language_panel_margin/language_options/language_selector
@onready var spinner: Control = $aspect_ration_container/login_margin/login_panel/spinner

const MAX_VISIBLE_SAVED_USERS: int = 3

func _ready() -> void:
	setup_ui()
	lock_input()
	load_saved_user_credentials()
	
	var last_used_credentials := UserManager.get_last_used_credentials()
	if last_used_credentials.is_empty() == false:
		var is_token_validated = await ServerRequest.validate_token(last_used_credentials["token"]);
		if is_token_validated == true:
			AppSessionState.set_username(last_used_credentials["username"])
			AppSessionState.set_server_token(last_used_credentials["token"])
			await request_app_state_variables()
			load_main_page();
			return

	unlock_input()

func _process(_delta: float) -> void:
	if AppSessionState.os_is_mobile() == true:
		var vk_height := DisplayServer.virtual_keyboard_get_height()
		var top_margin: float = 0.0
		if vk_height > 0:
			top_margin = DisplayServer.get_display_safe_area().position.y
		
		var margin := DisplayManager.base_to_viewport_point_converter(Vector2(0.0, float(vk_height - top_margin)))
		login_margin.add_theme_constant_override("margin_bottom", int(margin.y))

func load_main_page():
	AppSessionState.set_server_game_state(await ServerRequest.game_state())
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
	await request_app_state_variables()

	load_main_page()

func request_app_state_variables() -> void:
	var user_data := await  ServerRequest.user_data()
	AppSessionState.set_can_publish_posts(user_data.can_publish_posts)
	AppSessionState.set_cyber_defence_level(user_data.cyber_defence_level)

func lock_input():
	username_input.editable = false
	password_input.editable = false
	login_button.disabled = true
	show_saved_users_button.disabled = true
	spinner.show()
	
func unlock_input():
	username_input.editable = true
	password_input.editable = true
	login_button.disabled = false
	show_saved_users_button.disabled = false
	spinner.hide()

func on_show_saved_users_button_pressed() -> void:
	saved_users_list.visible = !saved_users_list.visible

func load_saved_user_credentials() -> void:
	var all_credentials := UserManager.get_all_saved_credentials()
	
	if all_credentials.is_empty():
		return
		
	show_saved_users_button.show()
	for username in all_credentials:
		saved_users_list.add_item(username)
		saved_users_list.set_item_tooltip_enabled(saved_users_list.item_count - 1, false)
		
	update_user_list_size.call_deferred()

func setup_ui() -> void:
	var safe_area := DisplayServer.get_display_safe_area()
	var margin := DisplayManager.base_to_viewport_point_converter(safe_area.position)
	popup_margin.add_theme_constant_override("margin_top", int(margin.y))
	language_selector.select(AppSessionState.get_language())

func on_saved_users_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	lock_input()
	saved_users_list.hide()
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
	await request_app_state_variables()
	load_main_page()

func update_user_list_size() -> void:
	var item_count := saved_users_list.item_count
	var visible_items = min(item_count, MAX_VISIBLE_SAVED_USERS)
	
	saved_users_list.auto_height = true
	var v_sep := saved_users_list.get_theme_constant("v_separation") / 2.0
	var item_height := saved_users_list.get_item_rect(0).size.y
	var total_height = (item_height * visible_items) + v_sep
	saved_users_list.custom_minimum_size.y = total_height
	saved_users_list.hide()
	
	if item_count > MAX_VISIBLE_SAVED_USERS:
		saved_users_list.auto_height = false

func on_language_selector_item_selected(index: int) -> void:
	match index:
		0:
			AppSessionState.set_language(GlobalTypes.LANGUAGE.ENGLISH)
		1:
			AppSessionState.set_language(GlobalTypes.LANGUAGE.POLISH)


func on_password_input_focus_entered() -> void:
	saved_users_list.hide()

func on_username_input_focus_entered() -> void:
	saved_users_list.hide()

func on_language_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		language_selector.show_popup()

func on_saved_users_list_visibility_changed() -> void:
	if saved_users_list == null:
		return

	if saved_users_list.visible == true:
		show_saved_users_button.icon = up_arrow_icon
	else:
		show_saved_users_button.icon = down_arrow_icon

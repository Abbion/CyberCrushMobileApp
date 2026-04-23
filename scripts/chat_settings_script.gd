#Refactor 1
extends PanelContainer

var chat_members: PackedStringArray
var free_slots: int = 0

@onready var actions_layout: VBoxContainer = $layouts_margin/actions_layout
@onready var add_user_layout: Control = $layouts_margin/add_user_layout
@onready var remove_user_layout: VBoxContainer = $layouts_margin/remove_user_layout
@onready var free_slots_label: Label = $layouts_margin/actions_layout/free_slots_label
@onready var remove_user_list: VBoxContainer = $layouts_margin/remove_user_layout/user_list_outline/users_list_container/user_list
@onready var add_user_input = $layouts_margin/add_user_layout/find_control
@onready var new_user_suggestion_margin: MarginContainer = $layouts_margin/add_user_layout/find_control/v_box/layout_override/suggestion_margin
@onready var add_user_actions: HBoxContainer = $layouts_margin/add_user_layout/add_user_actions

var checkbox_theme: Theme = preload("res://themes/accent_dark_buttons.tres")
var chat_id: int = -1;
signal closed(settings: Node)

func update_settings_panel(id) -> void:
	chat_id = id
	await get_metadata()
	update_free_slots_label()
	update_member_remove_list()
	var usernames := await ServerRequest.all_usernames(true)
	var username := AppSessionState.get_username()
	var username_index := usernames.find(username)
	if username_index >= 0:
		usernames.remove_at(username_index)
	add_user_input.all_suggestions = usernames

func get_metadata():
	if chat_id >= 0:
		var metadata := await ServerRequest.chat_metadata(chat_id)
		#TODO change Group to lowercase
		if metadata.has("Group"):
			var group_metadata = metadata["Group"]
			chat_members = group_metadata["members"]
			free_slots = GlobalConstants.MAX_MEMBERS_IN_GROUP_CHAT - len(chat_members)

func update_free_slots_label() -> void:
	free_slots_label.text =  tr("FREE_SLOTS_KEY") + (": %s" % free_slots)

func update_member_remove_list() -> void:
	clear_remove_user_list()
	var username := AppSessionState.get_username()
	
	for member in chat_members:
		if username == member:
			continue
		var member_checkbox := CheckBox.new()
		member_checkbox.text = member
		member_checkbox.theme = checkbox_theme
		member_checkbox.mouse_filter = Control.MOUSE_FILTER_PASS
		remove_user_list.add_child(member_checkbox)

func clear_remove_user_list() -> void:
	for user in remove_user_list.get_children():
		remove_user_list.remove_child(user)
		user.queue_free()

func go_to_selector_layout() -> void:
	actions_layout.show()
	add_user_layout.hide()
	remove_user_layout.hide()

func go_to_add_user_layout() -> void:
	actions_layout.hide()
	add_user_layout.show()

func go_to_remove_user_layout() -> void:
	actions_layout.hide()
	remove_user_layout.show()
	
	for member in remove_user_list.get_children():
		member.button_pressed = false

func close_chat_settings() -> void:
	closed.emit(self)

func on_remove_button_pressed() -> void:
	var any_member_removed := false
	
	for member in remove_user_list.get_children():
		if member.button_pressed:
			var update_reult := await ServerRequest.update_group_chat_member(
				chat_id, ServerRequest.GroupChatUpdateAction.REMOVE_MEMBER, member.text)
				
			if update_reult == true:
				any_member_removed = true
				remove_user_list.remove_child(member)
				member.queue_free()
	
	if any_member_removed:
		await get_metadata()
		update_free_slots_label()

func on_add_button_pressed() -> void:
	if len(chat_members) >= GlobalConstants.MAX_MEMBERS_IN_GROUP_CHAT:
		return
	
	if add_user_input.is_in_suggestions() == false:
		PopupDisplayServer.push_error(tr("USERNAME_DOES_NOT_EXIST"), tr("GROUP_CHAT_SETTINGS_PANEL"))
		return
		
	var username = add_user_input.get_value()
	
	var update_reult := await ServerRequest.update_group_chat_member(
		chat_id, ServerRequest.GroupChatUpdateAction.ADD_MEMBER, username)
		
	if update_reult == true:
		match AppSessionState.get_language():
			GlobalTypes.LANGUAGE.ENGLISH:
				PopupDisplayServer.push_info("User %s has beend added to the chat" % username)
			GlobalTypes.LANGUAGE.POLISH:
				PopupDisplayServer.push_info("Dodano użytkownika %s do czatu" % username)
		
		await get_metadata()
		update_free_slots_label()
		update_member_remove_list()
		add_user_input.clear()

func on_suggestion_margin_visibility_changed() -> void:
	if new_user_suggestion_margin.visible == true:
		add_user_actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for actions in add_user_actions.get_children():
			actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		add_user_actions.mouse_filter = Control.MOUSE_FILTER_PASS
		for actions in add_user_actions.get_children():
			actions.mouse_filter = Control.MOUSE_FILTER_STOP

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if add_user_layout.visible == true and new_user_suggestion_margin.visible == true:
			add_user_input.clear()

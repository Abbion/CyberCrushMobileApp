extends CenterContainer

var chat_members: PackedStringArray
var free_slots: int = 0

@onready var selector_view: VBoxContainer = $ColorRect/selector_view
@onready var add_user_view: Control = $ColorRect/add_user_view
@onready var remove_user_view: VBoxContainer = $ColorRect/remove_user_view

@onready var free_slots_label: Label = $ColorRect/selector_view/free_slots_label
@onready var remove_user_list: VBoxContainer = $ColorRect/remove_user_view/users_list_container/user_list
@onready var add_user_input = $ColorRect/add_user_view/find_control

@export var chat_id: int = -1;
signal closed

func initialize() -> void:
	await get_metadata()

func _ready() -> void:
	update_free_slots_label()
	update_member_remove_list()
	var usernames = await ServerRequest.all_usernames()
	var username = AppSessionState.get_username()
	var username_index = usernames.find(username)
	if username_index >= 0:
		usernames.remove_at(username_index)
	add_user_input.all_suggestions = usernames

func get_metadata():
	if chat_id >= 0:
		var metadata = await ServerRequest.chat_metadata(chat_id)
		#TODO change Group to lowercase
		if metadata.has("Group"):
			var group_metadata = metadata["Group"]
			chat_members = group_metadata["members"]
			free_slots = GlobalConstants.MAX_MEMBERS_IN_GROUP_CHAT - len(chat_members)

func update_free_slots_label() -> void:
	free_slots_label.text = ("Wolne miejsca: %s" % free_slots)

func update_member_remove_list() -> void:
	clear_remove_user_list()
	var username = AppSessionState.get_username()
	
	for member in chat_members:
		if username == member:
			continue
		var member_checkbox: CheckBox = CheckBox.new()
		member_checkbox.text = member
		remove_user_list.add_child(member_checkbox)

func clear_remove_user_list() -> void:
	for user in remove_user_list.get_children():
		remove_user_list.remove_child(user)
		user.queue_free()

func go_to_selector_view() -> void:
	selector_view.show()
	add_user_view.hide()
	remove_user_view.hide()

func go_to_add_user_view() -> void:
	selector_view.hide()
	add_user_view.show()

func go_to_remove_user_view() -> void:
	selector_view.hide()
	remove_user_view.show()

func close_chat_settings() -> void:
	closed.emit()

func _on_remove_button_pressed() -> void:
	var any_member_removed = false
	
	for member in remove_user_list.get_children():
		if member.button_pressed:
			var update_reult = await ServerRequest.update_group_chat_member(
				chat_id, ServerRequest.GroupChatUpdateAction.REMOVE_MEMBER, member.text)
				
			if update_reult == true:
				any_member_removed = true
				remove_user_list.remove_child(member)
				member.queue_free()
	
	if any_member_removed:
		await get_metadata()
		update_free_slots_label()

func _on_add_button_pressed() -> void:
	if len(chat_members) >= GlobalConstants.MAX_MEMBERS_IN_GROUP_CHAT:
		return
	
	var update_reult = await ServerRequest.update_group_chat_member(
		chat_id, ServerRequest.GroupChatUpdateAction.ADD_MEMBER, add_user_input.get_value())
	if update_reult == true:
		await get_metadata()
		update_free_slots_label()
		update_member_remove_list()
		add_user_input.clear()

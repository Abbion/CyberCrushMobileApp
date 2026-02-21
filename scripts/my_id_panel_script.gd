#Refactor 1
extends Control

@export var id_page_entry: PackedScene
@export var popup_log_entry: PackedScene

@onready var attributes: VBoxContainer = $attributes_margin/attributes
@onready var spinner_container: CenterContainer = $spinner_container
@onready var overlay: ColorRect = $overlay
@onready var popup_log: VBoxContainer = $overlay/popup_log_container/popup_data/log_scroll_container/log_stack

func _ready() -> void:
	var user_data := await ServerRequest.user_data()
	spinner_container.show()
	
	attributes.hide()
	
	build_data_entires(user_data)
	spinner_container.hide()
	attributes.show()

func build_data_entires(user_data: GlobalTypes.UserData) -> void:
	var id_page_entry_username_instance = id_page_entry.instantiate()
	id_page_entry_username_instance.key = "username"
	id_page_entry_username_instance.value = user_data.username
	attributes.add_child(id_page_entry_username_instance)
	
	var id_page_entry_personal_number_instance = id_page_entry.instantiate()
	id_page_entry_personal_number_instance.key = "personal number"
	id_page_entry_personal_number_instance.value = str(user_data.personal_number)
	attributes.add_child(id_page_entry_personal_number_instance)
	
	for key in user_data.extra_data:
		var id_page_entry_extra_data_instance = id_page_entry.instantiate()
		id_page_entry_extra_data_instance.key = key
		#TODO check the type of extra_data[key] and convert float, int, bool into str
		id_page_entry_extra_data_instance.value = str(user_data.extra_data[key])
		attributes.add_child(id_page_entry_extra_data_instance)

func _on_logout_button_button_down() -> void:
	GlobalSignals.logout.emit()

func build_bug_log() -> void:
	var popup_list := PopupDisplayServer.popup_list
	
	if popup_list.is_empty():
		return
	
	for entry in popup_log.get_children():
		popup_log.remove_child(entry)
		entry.queue_free()
	
	for index in range(popup_list.size() -1, -1, -1):
		var popup = popup_list[index]
		var popup_entry = popup_log_entry.instantiate()
		popup_entry.type = popup.type
		popup_entry.short_description = popup.content
		popup_entry.long_description = popup.verbose
		popup_log.add_child(popup_entry)

func on_popup_log_button_pressed() -> void:
	build_bug_log()
	overlay.show()

func on_popup_log_exit_button_pressed() -> void:
	overlay.hide()

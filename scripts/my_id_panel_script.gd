extends Control

var id_page_entry = load("res://scenes/custom_controlls/id_page_entry.tscn")
@onready var attributes = $attributes_margin/attributes
@onready var spinner_container: CenterContainer = $spinner_container

func _ready() -> void:
	var user_data = await ServerRequest.user_data()
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

extends PanelContainer

@export var type: PopupDisplayServer.PopupType
@export var short_description: String
@export var long_description: String

@onready var type_label: Label = $data_margin/data_stack_container/type_label
@onready var short_description_label: Label = $data_margin/data_stack_container/short_description_label
@onready var long_description_label: Label = $data_margin/data_stack_container/long_description_label

func _ready() -> void:
	type_label.text = "Typ: " + PopupDisplayServer.popup_type_to_string(type)
	type_label.add_theme_color_override("font_color", get_type_color())
	
	short_description_label.text = "Opis: %s" % short_description
	
	if long_description.is_empty():
		long_description_label.hide()
		return
	
	long_description_label.text = "Opis długi: %s" % long_description

func get_type_color() -> Color:
	match type:
		PopupDisplayServer.PopupType.ERROR:
			return Color.RED
		PopupDisplayServer.PopupType.WARNING:
			return Color.YELLOW
	
	return Color.WHITE

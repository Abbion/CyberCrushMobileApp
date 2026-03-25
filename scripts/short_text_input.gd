extends VBoxContainer

@export var max_character_limit: int = 12
@export var over_character_limit_labal_color: Color
@export var under_character_limit_labal_color: Color

@onready var character_limit_counter_label: Label = $character_limit_margin/character_limit_counter
@onready var input: LineEdit = $input

func _ready() -> void:
	update_text_length()

func on_input_text_changed(_new_text: String) -> void:
	update_text_length()

func is_text_over_character_limit() -> bool:
	return input.text.length() > max_character_limit

func update_text_length():
	var text_length := input.text.length()
	
	if text_length > max_character_limit:
		character_limit_counter_label.add_theme_color_override("font_color", over_character_limit_labal_color)
	else:
		character_limit_counter_label.add_theme_color_override("font_color", under_character_limit_labal_color)
	
	character_limit_counter_label.text = "%s/%s" % [text_length, max_character_limit]

func get_cleaned_text() -> String:
	var cleaned_text := input.text
	cleaned_text = cleaned_text.strip_edges()
	return cleaned_text

func clear_text_box():
	input.text = ""
	update_text_length()

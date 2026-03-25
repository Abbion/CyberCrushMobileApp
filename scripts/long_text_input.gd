#Refactor 1
extends TextEdit

enum CHARACTER_LIMIT_ANCHOR {
	IN_TEXT_INPUT,
	OUTSIDE_TEXT_INPUT
}

@export var character_limit_anchor: CHARACTER_LIMIT_ANCHOR = CHARACTER_LIMIT_ANCHOR.IN_TEXT_INPUT
@export var max_visible_lines: int = 3
@export var max_character_limit: int = 12
@export var over_character_limit_labal_color: Color
@export var under_character_limit_labal_color: Color

@onready var character_limit_counter_label: Label = $character_limit_margin/character_limit_counter
@onready var character_limit_margin: MarginContainer = $character_limit_margin

var outside_text_input_style: StyleBoxFlat = preload("res://themes/box_styles/character_limit.tres")

const min_visible_lines: int = 1
var vertical_margins: float = 0.0
var initial_character_limit_right_margin: int = 0

func _ready() -> void:
	character_limit_counter_label.text = "0/%s" % max_character_limit
	get_v_scroll_bar().visibility_changed.connect(update_limit_counter_label)
	var stylebox = get_theme_stylebox("normal")
	var margin_bottom = stylebox.content_margin_bottom if stylebox.content_margin_bottom > 0 else 0
	var margin_top = stylebox.content_margin_top if stylebox.content_margin_top > 0 else 0
	
	vertical_margins = margin_bottom + margin_top
	initial_character_limit_right_margin = character_limit_margin.get_theme_constant("margin_right")
	
	check_for_resize_text_input()
	update_text_length()
	update_character_limit_anchor()

func on_text_changed() -> void:
	check_for_resize_text_input()
	update_text_length()

func check_for_resize_text_input():
	var lines := get_line_count()

	var used_lines: int = 0
	for line in range(lines):
		used_lines += get_line_wrap_count(line) + 1
	
	var target_lines = clamp(used_lines, min_visible_lines, max_visible_lines)
	custom_minimum_size.y = (target_lines * get_line_height()) + vertical_margins
	
	if used_lines > max_visible_lines:
		update_scroll_to_bottom()
	else:
		scroll_vertical = 0

func update_scroll_to_bottom() -> void:
	await get_tree().process_frame
	center_viewport_to_caret()

func update_text_length():
	var text_length := text.length()
	
	if text_length > max_character_limit:
		character_limit_counter_label.add_theme_color_override("font_color", over_character_limit_labal_color)
	else:
		character_limit_counter_label.add_theme_color_override("font_color", under_character_limit_labal_color)
	
	character_limit_counter_label.text = "%s/%s" % [text_length, max_character_limit]

func update_limit_counter_label() -> void:
	if character_limit_anchor != CHARACTER_LIMIT_ANCHOR.IN_TEXT_INPUT:
		return
	
	var v_scroll := get_v_scroll_bar()
	if v_scroll.visible == true:
		var l_padding := v_scroll.get_theme_constant("padding_left");
		character_limit_margin.add_theme_constant_override("margin_right", -int(v_scroll.size.x - l_padding / 2.0))
	else:
		character_limit_margin.add_theme_constant_override("margin_right", initial_character_limit_right_margin)

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		DisplayServer.virtual_keyboard_show(text, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_MULTILINE)

func is_text_over_character_limit() -> bool:
	return text.length() > max_character_limit
	
func get_cleaned_text() -> String:
	var text_length := text.length()
	if text_length > max_character_limit:
		return ""
	
	var cleaned_text := text
	cleaned_text = cleaned_text.strip_edges()
	var regex := RegEx.new()
	regex.compile("\n+")
	cleaned_text = regex.sub(cleaned_text, "\n", true)
	return cleaned_text

func update_character_limit_anchor() -> void:
	if character_limit_anchor == CHARACTER_LIMIT_ANCHOR.IN_TEXT_INPUT:
		character_limit_margin.add_theme_constant_override("margin_bottom", 0)
	elif character_limit_anchor == CHARACTER_LIMIT_ANCHOR.OUTSIDE_TEXT_INPUT:
		var font_size = character_limit_counter_label.get_theme_font_size("font_size")
		var margins = outside_text_input_style.content_margin_bottom + outside_text_input_style.content_margin_top
		character_limit_margin.add_theme_constant_override("margin_bottom", -(font_size + margins + 1))
		character_limit_counter_label.add_theme_stylebox_override("normal", outside_text_input_style)

func clear_text_box():
	text = ""
	on_text_changed()

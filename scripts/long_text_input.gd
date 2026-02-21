#Refactor 1
extends TextEdit

@export var max_visible_lines: int = 3
@export var max_character_limit: int = 12
@export var over_character_limit_labal_color: Color
@export var under_character_limit_labal_color: Color

@onready var character_limit_counter_label: Label = $character_limit_margin/character_limit_counter
@onready var character_limit_margin: MarginContainer = $character_limit_margin

const min_visible_lines: int = 1
var vertical_margins = 0.0

func _ready() -> void:
	character_limit_counter_label.text = "0/%s" % max_character_limit
	get_v_scroll_bar().visibility_changed.connect(update_limit_counter_label)
	var stylebox = get_theme_stylebox("normal")
	vertical_margins = stylebox.content_margin_bottom + stylebox.content_margin_top
	check_for_resize_text_input()

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
	var v_scroll := get_v_scroll_bar()
	if v_scroll.visible == true:
		character_limit_margin.add_theme_constant_override("margin_right", int(v_scroll.size.x * 2.0))
	else:
		character_limit_margin.add_theme_constant_override("margin_right", 0)

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		DisplayServer.virtual_keyboard_show(text, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_MULTILINE)

func get_cleaned_text() -> String:
	var cleaned_text := text
	cleaned_text = cleaned_text.strip_edges()
	var regex := RegEx.new()
	regex.compile("\n+")
	cleaned_text = regex.sub(cleaned_text, "\n", true)
	return cleaned_text

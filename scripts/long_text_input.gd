extends TextEdit

@export var max_visible_lines: int = 3
@export var max_character_limit: int = 12
@export var over_character_limit_labal_color: Color
@export var under_character_limit_labal_color: Color

@onready var character_limit_counter_label: Label = $character_limit_margin/character_limit_counter
@onready var character_limit_margin: MarginContainer = $character_limit_margin

enum SizeState {
	DYNAMIC,
	LOCKED,
	READY_FOR_LOCK,
	READY_FOR_DYNAMIC
}

var size_state: SizeState = SizeState.DYNAMIC

var locked_height_obtained: bool = false
var locked_height_value: float = 0.0

var start_height_obtained: bool = false
var start_height_value: float = 0.0

func _ready() -> void:
	#start_height = size.y
	character_limit_counter_label.text = "0/%s" % max_character_limit
	get_v_scroll_bar().visibility_changed.connect(update_limit_counter_label)

func _process(delta: float) -> void:	
	if size_state == SizeState.READY_FOR_LOCK and locked_height_obtained == true:
		scroll_fit_content_height = false
		custom_minimum_size.y = start_height_value + (get_line_height() * (max_visible_lines - 1))
		update_scroll()
		size_state = SizeState.LOCKED
	if size_state == SizeState.READY_FOR_DYNAMIC and start_height_obtained == true:
		scroll_fit_content_height = true
		custom_minimum_size.y = start_height_value
		update_scroll()
		size_state = SizeState.DYNAMIC

func on_text_changed() -> void:
	check_for_resize_text_input()
	update_text_length()

var last_line_used: int = 0
func check_for_resize_text_input():
	var lines: int = get_line_count()

	var used_lines: int = 0
	for line in range(lines):
		used_lines += get_line_wrap_count(line) + 1
	
	var line_diff = used_lines - last_line_used
	last_line_used = used_lines 
	
	if used_lines >= max_visible_lines:
		if size_state != SizeState.LOCKED:
			size_state = SizeState.READY_FOR_LOCK
	else:
		if size_state != SizeState.DYNAMIC:
			size_state = SizeState.READY_FOR_DYNAMIC
	
	if line_diff > 0:
		update_scroll()
		
	if get_caret_line() == get_line_count() - 1:
		force_scroll_to_bottom()
	
func update_text_length():
	var text_length = text.length()
	
	if text_length > max_character_limit:
		character_limit_counter_label.add_theme_color_override("font_color", over_character_limit_labal_color)
	else:
		character_limit_counter_label.add_theme_color_override("font_color", under_character_limit_labal_color)
	
	character_limit_counter_label.text = "%s/%s" % [text_length, max_character_limit]

# Sometimes the scroll length does not update
# This function forces the scroll to update
# The scroll does not automaticaly update when eg.
# last line is deleted
func update_scroll() -> void:
	var v_scroll = get_v_scroll_bar()
	v_scroll.value = v_scroll.value - 1
	v_scroll.value = v_scroll.value + 1

func force_scroll_to_bottom() -> void:
	var v_scroll = get_v_scroll_bar()
	v_scroll.value = v_scroll.max_value

func update_limit_counter_label() -> void:
	var v_scroll = get_v_scroll_bar()
	if v_scroll.visible == true:
		character_limit_margin.add_theme_constant_override("margin_right", v_scroll.size.x * 2.0)
	else:
		character_limit_margin.add_theme_constant_override("margin_right", 0.0)

func on_text_set() -> void:
	update_text_length()
	check_for_resize_text_input()

func _on_resized() -> void:
	if size_state == SizeState.READY_FOR_LOCK and locked_height_obtained == false:
		locked_height_value = size.y
		locked_height_obtained = true

func _on_focus_entered() -> void:
	if start_height_obtained == false:
		start_height_value = size.y
		start_height_obtained = true

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		DisplayServer.virtual_keyboard_show(text)

func on_caret_changed() -> void:
	var height_diff = get_caret_draw_pos().y - get_line_height()
	if height_diff < 0:
		get_v_scroll_bar().value -= 1

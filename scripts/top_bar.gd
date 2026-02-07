extends ColorRect

#TODO: look at low_processor_usage_mode and screen_is_kept_on and set_max_fps to save power

@onready var date_time_label: Label = $top_bar_margin/VBoxContainer/date_time
@onready var battery_level_label: Label = $top_bar_margin/VBoxContainer/battery_level

func _ready() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	safe_area
	if safe_area.position.y > 0:
		var margin = DisplayManager.base_to_viewport_point_converter(safe_area.position)
		size.y = margin.y
	
	update_time()
	var time_update_timer := Timer.new()
	time_update_timer.wait_time = 1.0
	time_update_timer.autostart = true
	time_update_timer.timeout.connect(update_time)
	add_child(time_update_timer)
	
func update_time():
	var current_time = Time.get_datetime_dict_from_system()
	var hour = str(current_time.hour).pad_zeros(2)
	var minute = str(current_time.minute).pad_zeros(2)
	date_time_label.text = "%s:%s" % [hour, minute]

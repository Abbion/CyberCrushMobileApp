extends ColorRect

@onready var date_time_label: Label = $date_time

func _ready() -> void:
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

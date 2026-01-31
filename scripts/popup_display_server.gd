extends Node

enum PopupType {
	ERROR,
	WARNING,
	INFO,
	HAPPY_INFO
}

class PopupInfo:
	var type: PopupType
	var content: String
	var verbose: String

var popup_info_queue: Array
var popup_list: Array
var ready_to_consume = true

func _ready() -> void:
	GlobalSignals.popup_closed.connect(set_ready_to_consume)

func set_ready_to_consume() -> void:
	ready_to_consume = true
	if popup_info_queue.size() > 0:
		try_consume()

func try_consume() -> void:
	if ready_to_consume == false:
		return
	
	var popup_to_consume = popup_info_queue.pop_front()
	if popup_to_consume == null:
		return
		
	GlobalSignals.consume_popup.emit(popup_to_consume)
	ready_to_consume = false

func push_error(content: String, verbose: String = "") -> void:
	var error_popup: PopupInfo = PopupInfo.new()
	error_popup.type = PopupType.ERROR
	error_popup.content = content
	error_popup.verbose = verbose
	popup_info_queue.push_back(error_popup)
	popup_list.push_back(error_popup)
	try_consume()
	
func push_warning(content: String, verbose: String = "") -> void:
	var warning_popup: PopupInfo = PopupInfo.new()
	warning_popup.type = PopupType.WARNING
	warning_popup.content = content
	warning_popup.verbose = verbose
	popup_info_queue.push_back(warning_popup)
	try_consume()
	
func push_info(content: String, verbose: String = "") -> void:
	var info_popup: PopupInfo = PopupInfo.new()
	info_popup.type = PopupType.INFO
	info_popup.content = content
	info_popup.verbose = verbose
	popup_info_queue.push_back(info_popup)
	try_consume()
	
func push_happy_info(content: String, verbose: String = "") -> void:
	var happy_info_popup: PopupInfo = PopupInfo.new()
	happy_info_popup.type = PopupType.HAPPY_INFO
	happy_info_popup.content = content
	happy_info_popup.verbose = verbose
	popup_info_queue.push_back(happy_info_popup)
	try_consume()

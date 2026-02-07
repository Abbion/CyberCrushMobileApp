extends Control

@onready var background: ColorRect = $background
@onready var margin: MarginContainer =$background/margin
@onready var popup_type_label: Label = $background/margin/data/popup_type_label
@onready var content_label: Label = $background/margin/data/content
@onready var popup_timer: Timer = $timer

func _ready() -> void:
	hide()
	GlobalSignals.consume_popup.connect(on_consume_request)

func on_consume_request(popup_info: PopupDisplayServer.PopupInfo) -> void:
	match popup_info.type:
		PopupDisplayServer.PopupType.ERROR:
			error_popup(popup_info.content)
		PopupDisplayServer.PopupType.WARNING:
			warning_popup(popup_info.content)
		PopupDisplayServer.PopupType.INFO:
			info_popup(popup_info.content)
		PopupDisplayServer.PopupType.HAPPY_INFO:
			happy_info_popup(popup_info.content)
	
	show()
	popup_timer.start()

func error_popup(content: String) -> void:
	popup_type_label.text = "Błąd"
	popup_type_label.add_theme_color_override("font_color", Color.RED)
	content_label.text = content

func warning_popup(content: String) -> void:
	popup_type_label.text = "Uwaga"
	popup_type_label.add_theme_color_override("font_color", Color.YELLOW)
	content_label.text = content

func info_popup(content: String) -> void:
	popup_type_label.text = "Informacja"
	popup_type_label.add_theme_color_override("font_color", Color.WHITE)
	content_label.text = content

func happy_info_popup(content: String) -> void:
	popup_type_label.text = "Informacja"
	popup_type_label.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	content_label.text = content

func _on_timer_timeout() -> void:
	hide()
	GlobalSignals.popup_closed.emit()

func _on_tree_exited() -> void:
	GlobalSignals.consume_popup.disconnect(on_consume_request)

func _on_margin_resized() -> void:
	if margin == null or background == null:
		return
	background.size.y = margin.size.y

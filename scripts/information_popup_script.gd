#Refactor 1
extends Control

@onready var background: ColorRect = $background
@onready var shadow: ColorRect = $shadow
@onready var timer_progress: ColorRect = $timer_progress
@onready var margin: MarginContainer =$background/margin
@onready var popup_type_label: Label = $background/margin/data/popup_type_label
@onready var content_label: Label = $background/margin/data/content
@onready var popup_timer: Timer = $timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const error_red: Color = Color("d70909ff")
const warning_yellow: Color = Color("6288ffff")

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	timer_progress.scale.x = popup_timer.time_left / popup_timer.wait_time

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
	animation_player.play("pop_in")

func error_popup(content: String) -> void:
	popup_type_label.text = tr("ERROR")
	popup_type_label.add_theme_color_override("font_color", error_red)
	content_label.text = content

func warning_popup(content: String) -> void:
	popup_type_label.text = tr("WARNING")
	popup_type_label.add_theme_color_override("font_color", warning_yellow)
	content_label.text = content

func info_popup(content: String) -> void:
	popup_type_label.text = tr("INFORMATION")
	popup_type_label.add_theme_color_override("font_color", Color.BLACK)
	content_label.text = content

func happy_info_popup(content: String) -> void:
	popup_type_label.text = tr("INFORMATION")
	popup_type_label.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	content_label.text = content

func on_timer_timeout() -> void:
	animation_player.play("pop_out")
	GlobalSignals.popup_closed.emit()

func on_tree_entered() -> void:
		GlobalSignals.consume_popup.connect(on_consume_request)

func on_tree_exited() -> void:
	GlobalSignals.consume_popup.disconnect(on_consume_request)

func on_margin_resized() -> void:
	if margin == null or background == null:
		return
	
	background.size.y = margin.size.y
	timer_progress.position.y = background.position.y + background.size.y
	shadow.size.y = background.size.y + timer_progress.size.y + 15

func on_close_button_pressed() -> void:
	popup_timer.stop()
	animation_player.play("pop_out")
	GlobalSignals.popup_closed.emit()

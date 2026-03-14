#Refactor 1
extends ColorRect
enum AppPanels {
	SOCIAL,
	BANK,
	CHAT,
	ID
}

@onready var socials_button: TextureButton = $app_selector_container/socials
@onready var bank_button: TextureButton = $app_selector_container/bank
@onready var chat_button: TextureButton = $app_selector_container/chat
@onready var my_id_button: TextureButton = $app_selector_container/my_id

var current_panel := AppPanels.SOCIAL

signal socials_selected
signal bank_selected
signal messages_selected
signal my_id_selected

func _ready() -> void:
	socials_button.modulate = GlobalConstants.MAIN_THEME_COLOR

func on_socials_pressed() -> void:
	reset_color()
	socials_button.modulate = GlobalConstants.MAIN_THEME_COLOR
	current_panel = AppPanels.SOCIAL
	socials_selected.emit()

func on_bank_pressed() -> void:
	reset_color()
	bank_button.modulate = GlobalConstants.MAIN_THEME_COLOR
	current_panel = AppPanels.BANK
	bank_selected.emit()
	
func on_chat_pressed() -> void:
	reset_color()
	chat_button.modulate = GlobalConstants.MAIN_THEME_COLOR
	current_panel = AppPanels.CHAT
	messages_selected.emit()

func on_my_id_pressed() -> void:
	reset_color()
	my_id_button.modulate = GlobalConstants.MAIN_THEME_COLOR
	current_panel = AppPanels.ID
	my_id_selected.emit()

func reset_color() -> void:
	socials_button.modulate = Color.WHITE
	bank_button.modulate = Color.WHITE
	chat_button.modulate = Color.WHITE
	my_id_button.modulate = Color.WHITE

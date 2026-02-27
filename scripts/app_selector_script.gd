#Refactor 1
extends ColorRect
enum AppPanels {
	SOCIAL,
	BANK,
	CHAT,
	ID
}

var current_panel := AppPanels.SOCIAL

signal socials_selected
signal bank_selected
signal messages_selected
signal my_id_selected

func on_socials_pressed() -> void:
	current_panel = AppPanels.SOCIAL
	socials_selected.emit()

func on_bank_pressed() -> void:
	current_panel = AppPanels.BANK
	bank_selected.emit()
	
func on_chat_pressed() -> void:
	current_panel = AppPanels.CHAT
	messages_selected.emit()

func on_my_id_pressed() -> void:
	current_panel = AppPanels.ID
	my_id_selected.emit()

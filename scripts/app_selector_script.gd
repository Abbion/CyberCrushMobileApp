extends ColorRect

signal socials_selected
signal bank_selected
signal messages_selected
signal my_id_selected

func _on_socials_pressed() -> void:
	socials_selected.emit()

func _on_bank_pressed() -> void:
	bank_selected.emit()
	
func _on_messages_pressed() -> void:
	messages_selected.emit()

func _on_my_id_pressed() -> void:
	my_id_selected.emit()

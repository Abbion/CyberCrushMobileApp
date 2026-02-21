#Refactor 1
extends MarginContainer

func _process(_delta: float) -> void:	
	if GlobalConstants.os_is_mobile() == true:
		var vk_height := DisplayServer.virtual_keyboard_get_height()
		var vis_rect := get_viewport().get_visible_rect()
		var panel_rect := get_global_rect()
		
		var top_margin := 0.0
		var bottom_margin := 0.0
		if vk_height > 0.0:
			top_margin = panel_rect.position.y
			bottom_margin = vis_rect.size.y - (panel_rect.size.y + top_margin)
			
		$Label.text = "vk: %s" % vk_height
		
		var viewport_vk = DisplayManager.base_to_viewport_point_converter(Vector2(0.0, float(vk_height)))
		add_theme_constant_override("margin_bottom", viewport_vk.y - bottom_margin)

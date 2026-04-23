extends Button

func _ready():
	if AppSessionState.os_is_mobile():
		replace_hover_style()

func replace_hover_style():
	var normal_style = get_theme_stylebox("normal")
	add_theme_stylebox_override("hover", normal_style)
	
	var normal_font_color = get_theme_color("font_color")
	add_theme_color_override("font_hover_color", normal_font_color)
	
	var normal_icon_color = get_theme_color("icon_normal_color")
	add_theme_color_override("icon_hover_color", normal_icon_color)

#Refactor 1
extends MarginContainer

@export var all_suggestions: PackedStringArray
@export var max_suggestions: int = 5
@export var place_holder: String = ""
@onready var find_input: LineEdit = $v_box/input_field
@onready var suggestion_list: ItemList = $v_box/layout_override/suggestion_margin/suggestion_v_box/suggestion_list
@onready var suggestion_margin: MarginContainer = $v_box/layout_override/suggestion_margin

func _ready() -> void:
	find_input.placeholder_text = place_holder
	

func on_suggestion_list_item_selected(index: int) -> void:
	find_input.text = suggestion_list.get_item_text(index)
	suggestion_margin.hide()

func on_text_changed(new_text: String) -> void:
	suggestion_list.clear()
	
	if new_text.is_empty():
		suggestion_margin.hide()
		return
	
	var fit_dir: Dictionary = {}
	
	for suggestion in all_suggestions:
		var fit := HelperFunctions.fuzzy_string(new_text.to_lower(), suggestion.to_lower())
		fit_dir[suggestion] = fit
	
	var highest_fit: Dictionary = {}
	
	for suggestion in fit_dir.keys():
		if len(highest_fit) < max_suggestions:
			highest_fit[suggestion] = fit_dir[suggestion]
		else:
			var min_value: float = 2.0
			var min_key: String = ""
			
			for highest_suggestion in highest_fit.keys():
				if highest_fit[highest_suggestion] < min_value:
					min_value = highest_fit[highest_suggestion]
					min_key = highest_suggestion
			
			if fit_dir[suggestion] > min_value:
				highest_fit.erase(min_key)
				highest_fit[suggestion] = fit_dir[suggestion]
		
	var ordered_fit: Array = []
	
	while len(highest_fit) != len(ordered_fit):
		var max_fit: float = -1
		var max_key: String = ""
		
		for suggestion in highest_fit.keys():
			if suggestion in ordered_fit:
				continue
				
			var current_fit = highest_fit[suggestion]
			if current_fit > max_fit:
				max_fit = current_fit
				max_key = suggestion
		
		ordered_fit.append(max_key)
	
	var saturation: float = 0.0;
	for suggestion in ordered_fit:
		var current_fit = highest_fit[suggestion]
		if current_fit < 0.1:
			continue
			
		saturation += current_fit
		suggestion_list.add_item(suggestion)
		suggestion_list.set_item_tooltip_enabled(suggestion_list.item_count - 1, false)
		
		if saturation >= 1.0:
			break
	
	if suggestion_list.item_count > 0:
		suggestion_margin.show()
	else:
		suggestion_margin.hide()

func is_in_suggestions() -> bool:
	if find_input.text in all_suggestions:
		return true
	return false

func get_value() -> String:
	if is_in_suggestions():
		return find_input.text
	return ""

func clear() -> void:
	find_input.text = ""
	suggestion_margin.hide()

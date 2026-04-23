#Refactor 1
extends Node

var main_font: Font = preload("res://assets/fonts/VT323-Regular.ttf")

func measure_text(text: String, font_size: int = 20) -> Vector2:
	return main_font.get_string_size(text, 0, -1, font_size)

func fuzzy_string(input: String, target: String) -> float:
	if input.is_empty() and target.is_empty(): return 1.0
	if input.is_empty() or target.is_empty(): return 0.0

	var len_1: = input.length()
	var len_2: = target.length()

	# 1. Standard Levenshtein Logic
	var dist = []
	for i in range(len_1 + 1):
		dist.append([])
		for j in range(len_2 + 1):
			dist[i].append(i if j == 0 else (j if i == 0 else 0))

	for i in range(1, len_1 + 1):
		for j in range(1, len_2 + 1):
			var cost = 0 if input[i - 1] == target[j - 1] else 1
			dist[i][j] = min(dist[i - 1][j] + 1, min(dist[i][j - 1] + 1, dist[i - 1][j - 1] + cost))

	var distance := float(dist[len_1][len_2])
	var max_len := float(max(len_1, len_2))
	var score := 1.0 - (distance / max_len)

	# 2. The Fix: Prefix Bonus
	# Check how many characters at the start match exactly
	var prefix_match := 0
	var max_prefix = min(4, min(len_1, len_2))
	for i in range(max_prefix):
		if input[i] == target[i]:
			prefix_match += 1
		else:
			break
	
	score += prefix_match * 0.1 * (1.0 - score)

	return clamp(score, 0.0, 1.0)

func virtual_keyboard_normalized_size_from_bottom(bottom_offset: float = 0) -> float:
	var vk_height: int = DisplayServer.virtual_keyboard_get_height()
	
	if vk_height < 1:
		return 1.0
		
	var window_height: int = DisplayServer.window_get_size().y
	var ratio: float = float(window_height) / float(GlobalConstants.DEFAULT_VIEWPORT_HEIGHT)
	
	return 1.0 - (float(vk_height) / float(window_height + (bottom_offset * ratio)))

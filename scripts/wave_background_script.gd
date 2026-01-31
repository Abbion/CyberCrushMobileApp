extends Node2D

@export var x_lines = 10
@export var line_points = 20
@export var noise: FastNoiseLite
var time: float = 0.0
@onready var line_holder = $Node2D

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	var width = 405
	var height = 300
	
	for i in range(x_lines):
		var line: Line2D = Line2D.new()
		var pos_y = (float(i) / float((x_lines - 1))) * height
	
		for j in range(line_points):
			var pos_x = (float(j) / float(line_points - 1)) * width
			line.add_point(Vector2(pos_x, 100 + pos_y))
		
		line.width = 2
		line.antialiased = true
		line.default_color = Color(1, 0, 1, 1)
		line.modulate = Color(50, 0, 50, 1)
		line_holder.add_child(line)

func _process(delta: float) -> void:
	time += delta
	var line_counter = 0
	var width = 405
	var height = 300
	var amp = 50
	
	for line: Line2D in line_holder.get_children():
		var pos_y = (float(line_counter) / float((x_lines - 1))) * height
		
		for j in range(line_points):
			var pos_x = (float(j) / float(line_points - 1)) * width
			var current_point_position = Vector2(pos_x, 100 + pos_y)
			var offset = noise.get_noise_2d(current_point_position.x, current_point_position.y  + time * 50)
			offset *= amp
			line.set_point_position(j, Vector2(current_point_position.x, current_point_position.y + offset))
		line_counter += 1

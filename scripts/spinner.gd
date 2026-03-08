extends Control

@export var spinner_size: float = 40.0
@onready var plane_1 = $plane_1
@onready var plane_2 = $plane_2

func _ready() -> void:
	var plane_size = Vector2(spinner_size, spinner_size)
	
	plane_1.custom_minimum_size = plane_size
	plane_2.custom_minimum_size = plane_size

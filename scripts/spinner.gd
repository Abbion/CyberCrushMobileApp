#Refactor 1
extends Control

@export var spinner_scale: float = 1.0
@onready var ring: TextureProgressBar = $ring

var tween: Tween = null

func _ready() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(ring, "radial_initial_angle", 360.0, 1.5).as_relative()
	ring.scale = Vector2(spinner_scale, spinner_scale)

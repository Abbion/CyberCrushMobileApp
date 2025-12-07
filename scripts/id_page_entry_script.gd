extends HBoxContainer

@export var key : String = "Default key";
@export var value : String = "Default value";

@onready var key_label = $key_panel/key;
@onready var value_label = $value_panel/value;

func _ready() -> void:
	key_label.text = key;
	value_label.text = value;

#Refactor 1
extends HBoxContainer

@export var key := "Default key";
@export var value := "Default value";

@onready var key_label: Label = $key_panel/key;
@onready var value_label: Label = $value_panel/value;

func _ready() -> void:
	key_label.text = key;
	value_label.text = value;

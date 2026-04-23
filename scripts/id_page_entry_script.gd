#Refactor 1
extends PanelContainer

@export var key := "Default key";
@export var value := "Default value";

@onready var key_label: Label = $attribute_margin/h_box_container/key_bg/key
@onready var value_label: Label = $attribute_margin/h_box_container/value_bg/value

func _ready() -> void:
	key_label.text = " %s" % key;
	value_label.text = "%s " % value;

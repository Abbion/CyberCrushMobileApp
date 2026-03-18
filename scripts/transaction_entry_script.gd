#Refactor 1
extends MarginContainer

@export var title: String = "Default title"
@export var founds_trsfered: int = 0
@export var peer: String = "Default peer"
@export var date: String = "01.01.01"

@onready var title_label : Label = $data_container/title
@onready var amount_label : Label = $data_container/amount
@onready var peer_label : Label = $data_container/peer
@onready var date_label : Label = $data_container/date

func _ready() -> void:
	title_label.text = title
	peer_label.text = peer
	date_label.text = date
	setAmount(founds_trsfered)

func setAmount(amount: int) -> void:
	amount_label.text = "%s¥" % str(amount)
	
	if amount < 0:
		amount_label.add_theme_color_override("font_color", GlobalConstants.RED_COLOR_1)
	else:
		amount_label.add_theme_color_override("font_color", GlobalConstants.GREEN_COLOR_1)

extends MarginContainer

@export var title : String = "Default title"
@export var amount : int = 0
@export var peer : String = "Default peer"
@export var date : String = "01.01.01"

@onready var title_label : Label = $v_box_container/title
@onready var amount_label : Label = $v_box_container/amount
@onready var peer_label : Label = $v_box_container/peer
@onready var date_label : Label = $v_box_container/date

func _ready() -> void:
	title_label.text = title
	peer_label.text = peer
	date_label.text = date
	setAmount(amount)

func setAmount(amount: int) -> void:
	amount_label.text = str(amount)
	
	if amount < 0:
		amount_label.modulate = Color(1, 0, 0, 1)
	else:
		amount_label.modulate = Color(0, 1, 0, 1)

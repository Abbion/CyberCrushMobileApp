extends TextureRect

@export var base_pack_texture: DPITexture
@export var plus_pack_texture: DPITexture
@export var pro_pack_texture: DPITexture

func _ready() -> void:
	update_defence_pack_icon(AppSessionState.get_cyber_defence_level())

func update_defence_pack_icon(pack: int) -> void:
	match pack:
		2:
			texture = plus_pack_texture
		3:
			texture = pro_pack_texture
		_:
			texture = base_pack_texture

func on_tree_entered() -> void:
	GlobalSignals.connect("cyber_defence_pack_changed", update_defence_pack_icon)
	
func on_tree_exiting() -> void:
	GlobalSignals.disconnect("cyber_defence_pack_changed", update_defence_pack_icon)

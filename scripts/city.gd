class_name City
extends Area2D


signal city_destroyed

const MAX_HP: int = 10

var _hp: int = MAX_HP:
	set(value):
		_hp = clampi(value, 0, MAX_HP)
		
		if _hp == 0:
			city_destroyed.emit()
			queue_free()
		
		sprite.frame = MAX_HP - _hp

@onready var sprite: Sprite2D = $Sprite2D


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion") and not area.is_player_explosion:
		_hp -= 1

class_name City
extends Area2D


signal city_destroyed

const MAX_HP: int = 5

var _hp: int = MAX_HP:
	set(value):
		_hp = clampi(value, 0, MAX_HP)
		
		if _hp < 1:
			city_destroyed.emit()
			hide()
			collision.set_deferred("disabled", true)
		
		sprite.frame = clampi(MAX_HP - _hp, 0, 4)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func restore() -> void:
	_hp = MAX_HP
	collision.disabled = false
	
	show()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion") and not area.is_player_explosion:
		_hp -= 1

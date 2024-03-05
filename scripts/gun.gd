class_name Gun
extends Area2D


signal gun_destroyed

const MAX_HP: int = 20

var _hp: int = MAX_HP:
	set(value):
		_hp = clampi(value, 0, MAX_HP)
		print("GUN: " + str(_hp))
		
		if _hp == 0:
			gun_destroyed.emit()
			queue_free()

@onready var barrel: Sprite2D = $Barrel
@onready var ready_indicator: Sprite2D = $ReadyIndicator


func _process(_delta: float) -> void:
	barrel.look_at(get_global_mouse_position())
	barrel.rotation = deg_to_rad(clampf(barrel.rotation_degrees, -160, -20))


func fire_bullet(bullet_scene: PackedScene) -> void:
	var bullet := bullet_scene.instantiate() as PlayerBullet
	bullet.global_position = barrel.global_position
	bullet.direction = Vector2.RIGHT.rotated(barrel.rotation).normalized()
	bullet.distance_to_travel = global_position.distance_to(get_global_mouse_position())
	
	add_sibling(bullet)
	
	ready_indicator.hide()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion") and not area.is_player_explosion:
		_hp -= 1

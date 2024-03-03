class_name Gun
extends Area2D


@onready var barrel: Sprite2D = $Barrel


func _process(_delta: float) -> void:
	barrel.look_at(get_global_mouse_position())
	barrel.rotation = deg_to_rad(clampf(barrel.rotation_degrees, -160, -20))


func fire_bullet(bullet_scene: PackedScene) -> void:
	var bullet := bullet_scene.instantiate() as PlayerBullet
	bullet.global_position = barrel.global_position
	bullet.direction = Vector2.RIGHT.rotated(barrel.rotation).normalized()
	bullet.explode_position = get_global_mouse_position()
	
	add_sibling(bullet)

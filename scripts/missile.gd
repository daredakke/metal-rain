class_name Missile
extends Area2D


signal missile_destroyed

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion.tscn")

var speed: float = 15
var direction: Vector2


func _ready() -> void:
	rotation = direction.angle()


func _process(delta) -> void:
	position += direction * speed * delta


func destroy() -> void:
	missile_destroyed.emit()
	queue_free()


func explode() -> void:
	var explosion := EXPLOSION_SCENE.instantiate() as Explosion
	explosion.global_position = global_position
	explosion.scale = Vector2(0.2, 0.2)
	
	add_sibling(explosion)
	destroy()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion"):
		if area.is_friendly:
			destroy()
	elif area.is_in_group("player_bullet"):
		call_deferred("destroy")
	else:
		call_deferred("explode")

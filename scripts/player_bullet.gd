class_name PlayerBullet
extends Area2D


const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion.tscn")

var speed: float = 167
var direction: Vector2
var distance_to_travel: float

var _distance_traveled: float = 0
var _last_position: Vector2


func _ready() -> void:
	_last_position = global_position


func _process(delta) -> void:
	position += direction * speed * delta
	_distance_traveled += _last_position.distance_to(global_position)
	
	if _distance_traveled > distance_to_travel:
		var explosion := EXPLOSION_SCENE.instantiate() as Explosion
		explosion.global_position = global_position
		explosion.scale = Vector2(0.3, 0.3)
		explosion.is_friendly = true
		
		add_sibling(explosion)
		queue_free()
	
	_last_position = global_position


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("missile"):
		queue_free()

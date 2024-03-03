class_name PlayerBullet
extends Area2D


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
		queue_free()
	
	_last_position = global_position

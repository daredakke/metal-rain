class_name Crosshair
extends Sprite2D


var _rotation_speed: float = 0.8


func _ready() -> void:
	randomise_rotation()


func _process(delta):
	global_position = get_global_mouse_position()
	rotation += _rotation_speed * delta


func randomise_rotation() -> void:
	if randf() > 0.5:
		_rotation_speed = -_rotation_speed

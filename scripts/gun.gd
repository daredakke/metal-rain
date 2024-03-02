class_name Gun
extends Area2D


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation = deg_to_rad(clampf(rotation_degrees, -160, -20))

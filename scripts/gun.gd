class_name Gun
extends Area2D


@onready var barrel: Sprite2D = $Barrel


func _process(_delta: float) -> void:
	barrel.look_at(get_global_mouse_position())
	barrel.rotation = deg_to_rad(clampf(barrel.rotation_degrees, -160, -20))

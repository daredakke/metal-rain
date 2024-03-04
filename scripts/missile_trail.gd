class_name MissileTrail
extends Line2D


var node_to_follow: Missile
var wait: bool = true


func _process(_delta: float) -> void:
	if wait:
		wait = false
		show()
	
	set_point_position(1, node_to_follow.global_position)


func set_anchor(pos: Vector2) -> void:
	set_point_position(0, pos)


func destroy() -> void:
	queue_free()

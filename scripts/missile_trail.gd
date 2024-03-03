class_name MissileTrail
extends Line2D


var node_to_follow: Missile


func _process(_delta: float) -> void:
	set_point_position(1, node_to_follow.global_position)


func set_anchor(pos: Vector2) -> void:
	set_point_position(0, pos)


func destroy() -> void:
	queue_free()

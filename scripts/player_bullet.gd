class_name PlayerBullet
extends Area2D


var speed: float = 200
var direction: Vector2
var explode_position: Vector2

var _overlap_radius: float = 5.0


func _process(delta) -> void:
	position += direction * speed * delta
	
	var x_pos_reached: bool = abs(global_position.x - explode_position.x) < _overlap_radius
	var y_pos_reached: bool = abs(global_position.y - explode_position.y) < _overlap_radius
	
	if x_pos_reached and y_pos_reached:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet_kill_plane"):
		queue_free()

class_name Missile
extends Area2D


signal missile_destroyed

var speed: float = 25
var direction: Vector2


func _ready() -> void:
	rotation = direction.angle()


func _process(delta) -> void:
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ground"):
		_destroy()


func _destroy() -> void:
	missile_destroyed.emit()
	queue_free()

class_name Cities
extends Node2D


signal city_damaged(shake_strength: float, shake_speed: float)
signal city_destroyed(shake_strength: float, shake_speed: float)
signal all_cities_destroyed

var _cities_destroyed: int = 0


func _ready() -> void:
	for city in get_children():
		city.city_damaged.connect(_on_city_damaged)
		city.city_destroyed.connect(_on_city_destroyed)


func _on_city_damaged() -> void:
	city_damaged.emit(3.0, 30.0)


func _on_city_destroyed() -> void:
	_cities_destroyed += 1
	
	city_destroyed.emit(10.0, 20.0)
	
	if _cities_destroyed == get_child_count():
		_cities_destroyed = 0
		all_cities_destroyed.emit()

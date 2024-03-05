class_name Cities
extends Node2D


signal all_cities_destroyed

var _cities_destroyed: int = 0


func _ready() -> void:
	for city in get_children():
		city.city_destroyed.connect(_on_city_destroyed)


func _on_city_destroyed() -> void:
	_cities_destroyed += 1
	
	if _cities_destroyed == get_child_count():
		all_cities_destroyed.emit()

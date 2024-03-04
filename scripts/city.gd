class_name City
extends Area2D


signal city_destroyed

const MAX_HP: int = 10

var _hp: int = MAX_HP:
	set(value):
		_hp = clampi(value, 0, MAX_HP)
		print("CITY: " + str(_hp))
		
		if _hp == 0:
			city_destroyed.emit()
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion") and not area.is_friendly:
		_hp -= 1

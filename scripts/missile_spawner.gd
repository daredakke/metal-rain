class_name MissileSpawner
extends Node2D


const MISSILE_SCENE = preload("res://scenes/missile.tscn")
const MISSILE_TRAIL_SCENE = preload("res://scenes/missile_trail.tscn")

@onready var spawn_delay: Timer = %SpawnDelay


func _ready() -> void:
	spawn_delay.timeout.connect(_spawn_missile)


func start() -> void:
	spawn_delay.start()


func stop() -> void:
	spawn_delay.stop()


func _spawn_missile() -> void:
	var missile := MISSILE_SCENE.instantiate() as Missile
	missile.global_position = _spawn_point()
	missile.direction = _spawn_direction()
	
	add_sibling(missile)
	
	var missile_trail := MISSILE_TRAIL_SCENE.instantiate() as MissileTrail
	missile_trail.node_to_follow = missile
	missile_trail.set_anchor(missile.global_position)
	
	missile.missile_destroyed.connect(missile_trail.destroy)
	
	add_sibling(missile_trail)


func _spawn_point() -> Vector2i:
	var x_pos := randi_range(50, get_viewport().size.x - 50)
	var y_pos := randi_range(-80, -20)
	
	return Vector2i(x_pos, y_pos)


func _spawn_direction() -> Vector2:
	return Vector2.DOWN.rotated(deg_to_rad(randf_range(-30, 30)))

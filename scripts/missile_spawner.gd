class_name MissileSpawner
extends Node2D


const MAX_SPAWN_X: int = 320
const SPREAD: float = -15.0
const MISSILE_SCENE: PackedScene = preload("res://scenes/missile.tscn")
const MISSILE_TRAIL_SCENE: PackedScene = preload("res://scenes/missile_trail.tscn")

var salvo_size: int = 10:
	set(value):
		salvo_size = clampi(value, 1, 99)

var _missiles_fired: int = 0

@onready var spawn_delay: Timer = %SpawnDelay


func _ready() -> void:
	spawn_delay.timeout.connect(_spawn_missile)


func _process(_delta: float) -> void:
	if _missiles_fired >= salvo_size:
		stop()


func start() -> void:
	spawn_delay.start()


func stop() -> void:
	spawn_delay.stop()


func _spawn_missile() -> void:
	var missile := MISSILE_SCENE.instantiate() as Missile
	missile.global_position = _spawn_point()
	missile.direction = _spawn_direction(missile.global_position.x)
	
	add_sibling(missile)
	
	_missiles_fired += 1
	
	var missile_trail := MISSILE_TRAIL_SCENE.instantiate() as MissileTrail
	missile_trail.node_to_follow = missile
	missile_trail.set_anchor(missile.global_position)
	
	missile.missile_destroyed.connect(missile_trail.destroy)
	
	add_sibling(missile_trail)


func _spawn_point() -> Vector2i:
	var x_pos := randi_range(0, MAX_SPAWN_X)
	var y_pos := randi_range(-50, -10)
	
	return Vector2i(x_pos, y_pos)


func _spawn_direction(x_pos: float) -> Vector2:
	# Direction bias based on missile x position
	var rand_angle := randf_range(-SPREAD, SPREAD) + floorf(x_pos * 0.1 + -16.0)
	
	return Vector2.DOWN.rotated(deg_to_rad(rand_angle))

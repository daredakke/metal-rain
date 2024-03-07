class_name MissileSpawner
extends Node2D


signal level_over

const MAX_SPAWN_X: int = 320
const SPREAD: float = -24
const INIT_MIRV_CHANCE: float = 0.05
const INIT_SALVO_SIZE: int = 3
const INIT_MISSILE_SPEED: float = 15.5
const INIT_SPAWN_DELAY: float = 1.95
const MISSILE_SCENE: PackedScene = preload("res://scenes/missile.tscn")
const MISSILE_TRAIL_SCENE: PackedScene = preload("res://scenes/missile_trail.tscn")

var mirv_chance: float:
	set(value):
		mirv_chance = clampf(value, 0.05, 0.825)
var salvo_size: int:
	set(value):
		salvo_size = clampi(value, 1, 99)
var missile_speed: float
var spawn_delay: float:
	set(value):
		spawn_delay = clampf(value, 0.05, INIT_SPAWN_DELAY)
		
		spawn_delay_timer.wait_time = spawn_delay

var _missile_fired: int = 0
var _look_for_missiles: bool = false

@onready var spawn_delay_timer: Timer = %SpawnDelay


func _ready() -> void:
	spawn_delay_timer.timeout.connect(_spawn_missile)


func _process(_delta: float) -> void:
	# End level once all missiles are destroyed after the whole salvo is fired
	if _look_for_missiles and not _missiles_active():
		_look_for_missiles = false
		
		level_over.emit()


func start() -> void:
	_missile_fired = 0
	spawn_delay_timer.start()


func stop() -> void:
	spawn_delay_timer.stop()


func reset() -> void:
	mirv_chance = INIT_MIRV_CHANCE
	salvo_size = INIT_SALVO_SIZE
	missile_speed = INIT_MISSILE_SPEED
	spawn_delay = INIT_SPAWN_DELAY
	
	# Destroy any active missiles
	for node in get_children():
		if node is Missile:
			node.destroy()


func _missiles_active() -> bool:
	for node in get_children():
		if node is Missile:
			return true
	
	return false


func _spawn_missile() -> void:
	var missile := MISSILE_SCENE.instantiate() as Missile
	missile.global_position = _spawn_point()
	missile.direction = _spawn_direction(missile.global_position.x)
	missile.speed = missile_speed + randf_range(-6.0, 6.0)
	missile.is_mirv = randf() < mirv_chance
	
	add_child(missile)
	
	_missile_fired += 1
	
	var missile_trail := MISSILE_TRAIL_SCENE.instantiate() as MissileTrail
	missile_trail.node_to_follow = missile
	missile_trail.set_anchor(missile.global_position)
	missile.missile_destroyed.connect(missile_trail.destroy)
	
	add_child(missile_trail)
	
	if _missile_fired >= salvo_size:
		spawn_delay_timer.stop()
		_look_for_missiles = true


func _spawn_point() -> Vector2i:
	var x_pos := randi_range(0, MAX_SPAWN_X)
	var y_pos := randi_range(-50, -10)
	
	return Vector2i(x_pos, y_pos)


func _spawn_direction(x_pos: float) -> Vector2:
	# Direction bias based on missile x position
	var rand_angle := randf_range(-SPREAD, SPREAD) + floorf(x_pos * 0.1 + -16.0)
	
	return Vector2.DOWN.rotated(deg_to_rad(rand_angle))
